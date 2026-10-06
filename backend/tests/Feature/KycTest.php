<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Enums\KycStatus;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class KycTest extends TestCase
{
    use RefreshDatabase;

    private User $rider;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');

        $this->rider = User::factory()->create(['role' => 'rider', 'status' => 'pending_kyc']);
        $this->rider->riderProfile()->create([
            'kyc_status' => KycStatus::PENDING,
            'is_online' => false,
            'current_cash_in_hand' => 0.00,
            'max_cash_limit' => 5000.00,
        ]);
        $this->rider->devices()->create([
            'device_id' => 'test-device-uuid',
            'is_active' => true,
        ]);
    }

    public function test_rider_can_submit_kyc_documents(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid')
            ->postJson('/api/v1/rider/documents', [
                'vehicle_type' => 'bike',
                'vehicle_number' => 'KA01AB1234',
                'license_number' => 'DL1420110012345',
                'license_expiry' => now()->addYears(2)->toDateString(),
                'license_front' => UploadedFile::fake()->image('license_front.jpg'),
                'license_back' => UploadedFile::fake()->image('license_back.jpg'),
                'rc_book' => UploadedFile::fake()->create('rc_book.pdf', 100),
                'id_proof_type' => 'aadhaar',
                'id_proof_number' => '123456789012',
                'id_proof_document' => UploadedFile::fake()->create('aadhaar.pdf', 100),
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.kyc_status', 'submitted')
            ->assertJsonPath('data.vehicle_number', 'KA01AB1234');

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $this->rider->id,
            'kyc_status' => 'submitted',
            'license_number' => 'DL1420110012345',
        ]);

        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $this->rider->id,
            'action' => 'KYC_DOCUMENTS_SUBMITTED',
        ]);
    }

    public function test_kyc_submission_fails_with_expired_license(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid')
            ->postJson('/api/v1/rider/documents', [
                'vehicle_type' => 'bike',
                'vehicle_number' => 'KA01AB1234',
                'license_number' => 'DL1420110012345',
                'license_expiry' => now()->subDay()->toDateString(), // Expired
                'license_front' => UploadedFile::fake()->image('license_front.jpg'),
                'license_back' => UploadedFile::fake()->image('license_back.jpg'),
                'rc_book' => UploadedFile::fake()->create('rc_book.pdf', 100),
                'id_proof_type' => 'aadhaar',
                'id_proof_number' => '123456789012',
                'id_proof_document' => UploadedFile::fake()->create('aadhaar.pdf', 100),
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['license_expiry']);
    }

    public function test_rider_can_update_bank_details(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid')
            ->putJson('/api/v1/rider/bank-details', [
                'bank_account_holder' => 'Arjun Sharma',
                'bank_name' => 'HDFC Bank',
                'bank_account_number' => '50100234918231',
                'bank_ifsc_code' => 'HDFC0001234',
                'bank_upi_id' => 'arjun@okhdfcbank',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.bank_name', 'HDFC Bank')
            ->assertJsonPath('data.bank_verified', true);

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $this->rider->id,
            'bank_ifsc_code' => 'HDFC0001234',
            'bank_verified' => true,
        ]);
    }

    public function test_bank_details_fail_with_invalid_ifsc(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid')
            ->putJson('/api/v1/rider/bank-details', [
                'bank_account_holder' => 'Arjun Sharma',
                'bank_name' => 'HDFC Bank',
                'bank_account_number' => '50100234918231',
                'bank_ifsc_code' => 'INVALID_IFSC',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['bank_ifsc_code']);
    }

    public function test_rider_can_update_emergency_contact(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->withHeader('X-Device-Id', 'test-device-uuid')
            ->putJson('/api/v1/rider/emergency-contact', [
                'emergency_contact_name' => 'Sunita Sharma',
                'emergency_contact_phone' => '+919811223344',
                'emergency_contact_relation' => 'Mother',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.emergency_contact_name', 'Sunita Sharma');

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $this->rider->id,
            'emergency_contact_phone' => '+919811223344',
        ]);
    }
}
