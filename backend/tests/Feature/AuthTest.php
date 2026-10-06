<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_request_otp_with_valid_phone(): void
    {
        $response = $this->postJson('/api/v1/auth/otp/send', [
            'phone' => '+919876543210',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.phone', '+919876543210')
            ->assertJsonPath('data.resend_in_seconds', 60);

        $this->assertTrue(Cache::has('otp_code:+919876543210'));
    }

    public function test_send_otp_fails_with_invalid_phone_format(): void
    {
        $response = $this->postJson('/api/v1/auth/otp/send', [
            'phone' => '12345', // Missing country code +
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone']);
    }

    public function test_can_verify_otp_and_receive_sanctum_token(): void
    {
        // Preset OTP in cache
        Cache::put('otp_code:+919876543210', '458921', 300);

        $response = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => '+919876543210',
            'otp' => '458921',
            'device_id' => 'test-device-uuid-1234',
            'device_model' => 'Pixel 8 Pro',
            'os_version' => 'Android 14',
            'app_version' => '1.0.0',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'token',
                    'user' => [
                        'id',
                        'phone',
                        'role',
                        'status',
                        'kyc_status',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'phone' => '+919876543210',
            'role' => 'rider',
        ]);

        $this->assertDatabaseHas('devices', [
            'device_id' => 'test-device-uuid-1234',
            'is_active' => true,
        ]);
    }

    public function test_verify_otp_fails_with_wrong_code(): void
    {
        Cache::put('otp_code:+919876543210', '458921', 300);

        $response = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => '+919876543210',
            'otp' => '000000', // Invalid code
            'device_id' => 'test-device-uuid-1234',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['otp']);
    }

    public function test_authenticated_rider_can_fetch_profile(): void
    {
        $user = User::factory()->create(['phone' => '+919876543210']);
        $user->riderProfile()->create([
            'is_online' => true,
            'current_cash_in_hand' => 0.00,
            'max_cash_limit' => 5000.00,
        ]);
        $device = $user->devices()->create([
            'device_id' => 'test-device-uuid-1234',
            'is_active' => true,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid-1234')
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.phone', '+919876543210');
    }
}
