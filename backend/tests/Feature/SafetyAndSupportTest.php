<?php

namespace Tests\Feature;

use App\Enums\IncidentStatus;
use App\Enums\IncidentType;
use App\Enums\KycStatus;
use App\Enums\SupportCategory;
use App\Enums\SupportStatus;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SafetyAndSupportTest extends TestCase
{
    use RefreshDatabase;

    public function test_rider_can_trigger_emergency_sos_panic(): void
    {
        $user = User::factory()->create([
            'name' => 'Kiran Kumar',
            'phone' => '+919988776655',
        ]);

        RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
            'emergency_contact_phone' => '+919876500000',
            'emergency_contact_name' => 'Sunita Kumar',
        ]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/rider/safety/sos', [
            'latitude' => 12.9716,
            'longitude' => 77.5946,
            'location_address' => 'MG Road, Bangalore',
            'medical_assistance_needed' => true,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.type', 'sos_panic')
            ->assertJsonPath('data.medical_assistance_needed', true)
            ->assertJsonPath('data.status', 'triggered');

        $this->assertDatabaseHas('incidents_and_sos', [
            'rider_id' => $user->id,
            'type' => IncidentType::SOS_PANIC->value,
            'status' => IncidentStatus::TRIGGERED->value,
            'medical_assistance_needed' => true,
        ]);

        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $user->id,
            'action' => 'INCIDENT_RECORDED',
        ]);
    }

    public function test_rider_can_create_and_fetch_support_tickets(): void
    {
        $user = User::factory()->create();
        RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
        ]);

        Sanctum::actingAs($user);

        // 1. Create Ticket
        $response = $this->postJson('/api/v1/rider/support/tickets', [
            'category' => 'payment_payout_issue',
            'subject' => 'Surge bonus missing for delivery #892',
            'description' => 'I completed a delivery during rain surge but bonus was not credited.',
            'priority' => 'high',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.category', 'payment_payout_issue')
            ->assertJsonPath('data.status', 'open');

        $this->assertDatabaseHas('support_tickets', [
            'rider_id' => $user->id,
            'category' => SupportCategory::PAYMENT_PAYOUT_ISSUE->value,
            'status' => SupportStatus::OPEN->value,
        ]);

        // 2. Fetch Tickets List
        $this->getJson('/api/v1/rider/support/tickets')
            ->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'data' => [
                        '*' => ['id', 'ticket_number', 'category', 'subject', 'status'],
                    ],
                ],
            ]);
    }
}
