<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Enums\KycStatus;
use App\Enums\OfferStatus;
use App\Enums\OrderStatus;
use App\Enums\UserRole;
use App\Models\Device;
use App\Models\Order;
use App\Models\OrderAssignmentOffer;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DutyAndDispatchTest extends TestCase
{
    use RefreshDatabase;

    private User $rider;
    private Device $device;
    private string $token;
    private string $deviceId = 'device-freska-uuid-test';

    protected function setUp(): void
    {
        parent::setUp();

        $this->rider = User::factory()->create([
            'phone' => '+919876543210',
            'role' => UserRole::RIDER,
            'status' => 'active',
        ]);

        $this->device = Device::create([
            'user_id' => $this->rider->id,
            'device_id' => $this->deviceId,
            'platform' => 'android',
            'is_active' => true,
            'last_active_at' => now(),
        ]);

        $this->token = $this->rider->createToken('test_token')->plainTextToken;
    }

    public function test_duty_toggle_fails_if_kyc_is_not_verified(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::SUBMITTED,
            'is_online' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->postJson('/api/v1/rider/duty/toggle', [
            'is_online' => true,
            'latitude' => 12.971598,
            'longitude' => 77.594562,
        ]);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'error_code' => 'ERR_KYC_NOT_VERIFIED',
            ]);
    }

    public function test_duty_toggle_succeeds_when_kyc_is_verified(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => false,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->postJson('/api/v1/rider/duty/toggle', [
            'is_online' => true,
            'latitude' => 12.971598,
            'longitude' => 77.594562,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'is_online' => true,
                ],
            ]);

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $this->rider->id,
            'is_online' => true,
        ]);
    }

    public function test_location_heartbeat_updates_rider_coordinates(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->postJson('/api/v1/rider/location', [
            'latitude' => 12.972100,
            'longitude' => 77.595100,
            'heading' => 90.0,
            'speed' => 25.0,
            'battery_percentage' => 85,
            'is_mock' => false,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Location updated.',
            ]);

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $this->rider->id,
            'current_latitude' => 12.97210000,
            'current_longitude' => 77.59510000,
        ]);
    }

    public function test_dashboard_summary_returns_metrics(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
            'rating_average' => 4.90,
            'acceptance_rate' => 99.00,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->getJson('/api/v1/rider/dashboard/summary');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'is_online',
                    'metrics' => [
                        'today_earnings',
                        'today_deliveries_count',
                        'today_online_hours',
                        'acceptance_rate',
                        'rating_average',
                        'current_cash_in_hand',
                        'max_cash_limit',
                    ],
                    'has_active_order',
                    'has_pending_offer',
                ],
            ]);
    }

    public function test_accept_order_offer_successfully(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
        ]);

        $vendor = Vendor::create([
            'name' => 'Freska Hub Indiranagar',
            'store_code' => 'FSK-HUB-01',
            'phone' => '+918049281200',
            'address' => '100 Feet Road, Indiranagar',
            'latitude' => 12.978369,
            'longitude' => 77.640835,
        ]);

        $order = Order::create([
            'order_number' => 'FSK-2026-90001',
            'vendor_id' => $vendor->id,
            'customer_name' => 'Rahul Sharma',
            'customer_phone' => '+919988776655',
            'delivery_address' => 'Flat 402, Sunshine Apts, Indiranagar',
            'delivery_area' => 'Indiranagar 1st Stage',
            'delivery_latitude' => 12.979000,
            'delivery_longitude' => 77.642000,
            'status' => OrderStatus::OFFERED,
            'estimated_distance_km' => 3.2,
            'estimated_duration_mins' => 15,
            'base_payout' => 45.00,
            'distance_payout' => 15.00,
            'total_rider_payout' => 60.00,
        ]);

        OrderAssignmentOffer::create([
            'order_id' => $order->id,
            'rider_id' => $this->rider->id,
            'offered_at' => now(),
            'expires_at' => now()->addSeconds(30),
            'status' => OfferStatus::OFFERED,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->postJson("/api/v1/rider/orders/{$order->id}/accept", [
            'latitude' => 12.971598,
            'longitude' => 77.594562,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'order_id' => $order->id,
                    'status' => 'accepted',
                ],
            ]);

        $this->assertDatabaseHas('orders', [
            'id' => $order->id,
            'rider_id' => $this->rider->id,
            'status' => OrderStatus::ACCEPTED->value,
        ]);
    }

    public function test_reject_order_offer_successfully(): void
    {
        RiderProfile::create([
            'user_id' => $this->rider->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
        ]);

        $vendor = Vendor::create([
            'name' => 'Freska Hub Indiranagar',
            'store_code' => 'FSK-HUB-02',
            'phone' => '+918049281200',
            'address' => '100 Feet Road, Indiranagar',
            'latitude' => 12.978369,
            'longitude' => 77.640835,
        ]);

        $order = Order::create([
            'order_number' => 'FSK-2026-90002',
            'vendor_id' => $vendor->id,
            'customer_name' => 'Sneha Patel',
            'customer_phone' => '+919988776655',
            'delivery_address' => 'Flat 101, Green View, Indiranagar',
            'delivery_area' => 'Indiranagar',
            'delivery_latitude' => 12.979000,
            'delivery_longitude' => 77.642000,
            'status' => OrderStatus::OFFERED,
            'estimated_distance_km' => 2.5,
            'estimated_duration_mins' => 12,
            'base_payout' => 40.00,
            'total_rider_payout' => 40.00,
        ]);

        OrderAssignmentOffer::create([
            'order_id' => $order->id,
            'rider_id' => $this->rider->id,
            'offered_at' => now(),
            'expires_at' => now()->addSeconds(30),
            'status' => OfferStatus::OFFERED,
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer {$this->token}",
            'X-Device-Id' => $this->deviceId,
        ])->postJson("/api/v1/rider/orders/{$order->id}/reject", [
            'reason' => 'Vehicle puncture / mechanical issue',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Order declined.',
            ]);

        $this->assertDatabaseHas('order_assignment_offers', [
            'order_id' => $order->id,
            'rider_id' => $this->rider->id,
            'status' => OfferStatus::REJECTED->value,
            'rejection_reason' => 'Vehicle puncture / mechanical issue',
        ]);
    }
}
