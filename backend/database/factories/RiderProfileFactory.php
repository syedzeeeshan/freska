<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Enums\KycStatus;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class RiderProfileFactory extends Factory
{
    protected $model = RiderProfile::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'vehicle_type' => 'bike',
            'vehicle_number' => 'KA01AB' . fake()->numerify('####'),
            'license_number' => 'DL' . fake()->numerify('##########'),
            'license_expiry' => now()->addYears(3),
            'kyc_status' => KycStatus::VERIFIED,
            'is_online' => true,
            'current_latitude' => 12.971598,
            'current_longitude' => 77.594562,
            'max_cash_limit' => 5000.00,
            'current_cash_in_hand' => 0.00,
            'rating_average' => 5.00,
            'completed_deliveries_count' => 10,
        ];
    }
}
