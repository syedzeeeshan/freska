<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'phone' => '+91' . fake()->numerify('98########'),
            'phone_verified_at' => now(),
            'email' => fake()->unique()->safeEmail(),
            'role' => UserRole::RIDER,
            'status' => UserStatus::ACTIVE,
        ];
    }

    public function pendingKyc(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => UserStatus::PENDING_KYC,
        ]);
    }
}
