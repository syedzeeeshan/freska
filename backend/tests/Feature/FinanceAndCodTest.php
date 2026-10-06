<?php

namespace Tests\Feature;

use App\Enums\CodHandoverMethod;
use App\Enums\CodHandoverStatus;
use App\Enums\EarningType;
use App\Enums\KycStatus;
use App\Models\CodCollection;
use App\Models\Order;
use App\Models\Payout;
use App\Models\RiderEarning;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceAndCodTest extends TestCase
{
    use RefreshDatabase;

    public function test_rider_can_fetch_earnings_summary_and_chart(): void
    {
        $user = User::factory()->create();
        RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
        ]);

        RiderEarning::create([
            'rider_id' => $user->id,
            'earning_type' => EarningType::DELIVERY_FEE->value,
            'amount' => 120.00,
            'description' => 'Delivery fee test',
            'date' => now()->toDateString(),
            'status' => 'pending',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/rider/earnings/summary');

        $response->assertStatus(200)
            ->assertJsonPath('data.summary.today_earnings', fn ($val) => (float) $val === 120.0)
            ->assertJsonStructure([
                'data' => [
                    'summary' => [
                        'today_earnings',
                        'today_deliveries',
                        'this_week_earnings',
                        'this_week_deliveries',
                        'surge_bonus',
                        'tips_total',
                        'milestone_progress_percentage',
                    ],
                    'weekly_daily_chart',
                ],
            ]);
    }

    public function test_rider_can_fetch_cod_summary_and_submit_remittance(): void
    {
        $user = User::factory()->create();
        $profile = RiderProfile::create([
            'user_id' => $user->id,
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
            'current_cash_in_hand' => 1500.00,
            'max_cash_limit' => 5000.00,
        ]);

        Sanctum::actingAs($user);

        // Fetch COD summary
        $this->getJson('/api/v1/rider/cod/summary')
            ->assertStatus(200)
            ->assertJsonPath('data.current_cash_in_hand', fn ($val) => (float) $val === 1500.0)
            ->assertJsonPath('data.headroom_available', fn ($val) => (float) $val === 3500.0);

        // Submit Remittance Handover
        $response = $this->postJson('/api/v1/rider/cod/handover', [
            'amount' => 1000.00,
            'handover_method' => 'bank_cdm',
            'handover_reference' => 'CDM-TXN-984210',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.amount', fn ($val) => (float) $val === 1000.0)
            ->assertJsonPath('data.handover_status', 'submitted');

        $this->assertDatabaseHas('rider_profiles', [
            'user_id' => $user->id,
            'current_cash_in_hand' => 500.00,
        ]);

        $this->assertDatabaseHas('cod_collections', [
            'rider_id' => $user->id,
            'amount' => 1000.00,
            'handover_status' => CodHandoverStatus::SUBMITTED->value,
        ]);
    }
}
