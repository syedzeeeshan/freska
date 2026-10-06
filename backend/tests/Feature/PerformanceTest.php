<?php

namespace Tests\Feature;

use App\Enums\KycStatus;
use App\Models\Order;
use App\Models\RatingAndReview;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PerformanceTest extends TestCase
{
    use RefreshDatabase;

    public function test_rider_can_fetch_performance_metrics_and_tier(): void
    {
        $user = User::factory()->create();
        RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
            'completed_deliveries_count' => 75,
            'rating_average' => 4.92,
            'rating_count' => 68,
            'acceptance_rate' => 96.5,
            'on_time_rate' => 98.2,
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/rider/performance');

        $response->assertStatus(200)
            ->assertJsonPath('data.tier', 'silver')
            ->assertJsonPath('data.completed_deliveries_count', 75)
            ->assertJsonPath('data.rating_average', 4.92)
            ->assertJsonStructure([
                'data' => [
                    'rating_average',
                    'rating_count',
                    'acceptance_rate',
                    'on_time_rate',
                    'completed_deliveries_count',
                    'tier',
                    'tier_multiplier',
                    'next_tier',
                    'deliveries_to_next_tier',
                    'tier_progress_percentage',
                    'top_compliments',
                ],
            ]);
    }

    public function test_rider_can_fetch_customer_reviews(): void
    {
        $user = User::factory()->create();
        $vendor = Vendor::create([
            'name' => 'Store 1',
            'store_code' => 'S1',
            'phone' => '+919988001122',
            'address' => 'Store Rd',
            'latitude' => 12.9,
            'longitude' => 77.6,
        ]);

        $order = Order::create([
            'order_number' => 'FSK-REV-01',
            'vendor_id' => $vendor->id,
            'rider_id' => $user->id,
            'customer_name' => 'Aditi S',
            'customer_phone' => '+919876543210',
            'delivery_address' => 'House 12',
            'delivery_area' => 'HSR',
            'delivery_latitude' => 12.91,
            'delivery_longitude' => 77.63,
            'status' => 'delivered',
            'base_payout' => 40.0,
            'total_rider_payout' => 50.0,
            'estimated_distance_km' => 3.0,
            'estimated_duration_mins' => 15,
        ]);

        RatingAndReview::create([
            'order_id' => $order->id,
            'rider_id' => $user->id,
            'rating' => 5,
            'badges' => ['fast_delivery', 'polite_rider'],
            'feedback_comment' => 'Very polite and arrived super quick!',
            'created_at' => now(),
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/rider/performance/reviews');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'data' => [
                        '*' => ['id', 'order_id', 'order_number', 'rating', 'badges', 'feedback_comment'],
                    ],
                ],
            ]);
    }
}
