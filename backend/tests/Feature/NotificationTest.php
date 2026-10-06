<?php

namespace Tests\Feature;

use App\Enums\KycStatus;
use App\Enums\NotificationType;
use App\Models\Notification;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_rider_can_fetch_notifications_and_mark_as_read(): void
    {
        $user = User::factory()->create();
        RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
        ]);

        $notification = Notification::create([
            'user_id' => $user->id,
            'title' => 'Weekly Payout Disbursed',
            'body' => 'Your weekly payout of ₹4,850 has been credited to your bank account.',
            'type' => NotificationType::PAYOUT_CREDITED,
            'data' => ['payout_id' => 12],
            'is_read' => false,
            'created_at' => now(),
        ]);

        Sanctum::actingAs($user);

        // 1. Fetch Notifications List & Unread Count
        $response = $this->getJson('/api/v1/rider/notifications');

        $response->assertStatus(200)
            ->assertJsonPath('data.unread_count', 1)
            ->assertJsonStructure([
                'data' => [
                    'notifications' => [
                        'data' => [
                            '*' => ['id', 'title', 'body', 'type', 'is_read', 'created_at'],
                        ],
                    ],
                    'unread_count',
                ],
            ]);

        // 2. Mark Single Notification as Read
        $patchResponse = $this->patchJson("/api/v1/rider/notifications/{$notification->id}/read");
        $patchResponse->assertStatus(200);

        $this->assertDatabaseHas('notifications', [
            'id' => $notification->id,
            'is_read' => true,
        ]);

        // 3. Register Device FCM Token
        $deviceResponse = $this->postJson('/api/v1/rider/devices/register', [
            'device_id' => 'device-fcm-uuid-9842',
            'fcm_token' => 'fcm_token_sample_abc123',
            'device_model' => 'Pixel 8',
            'os_version' => 'Android 14',
            'app_version' => '1.0.0+1',
        ]);

        $deviceResponse->assertStatus(200)
            ->assertJsonPath('data.is_active', true);

        $this->assertDatabaseHas('devices', [
            'user_id' => $user->id,
            'device_id' => 'device-fcm-uuid-9842',
            'fcm_token' => 'fcm_token_sample_abc123',
        ]);
    }
}
