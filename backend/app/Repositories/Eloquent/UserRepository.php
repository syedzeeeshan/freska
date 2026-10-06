<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Enums\KycStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Interfaces\Repositories\UserRepositoryInterface;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class UserRepository implements UserRepositoryInterface
{
    public function findById(int $id): ?User
    {
        return User::with('riderProfile')->find($id);
    }

    public function findByPhone(string $phone): ?User
    {
        return User::with('riderProfile')->where('phone', $phone)->first();
    }

    public function createRider(string $phone): User
    {
        return DB::transaction(function () use ($phone) {
            $user = User::create([
                'phone' => $phone,
                'role' => UserRole::RIDER,
                'status' => UserStatus::PENDING_KYC,
            ]);

            $user->riderProfile()->create([
                'kyc_status' => KycStatus::PENDING,
                'is_online' => false,
                'current_cash_in_hand' => 0.00,
                'max_cash_limit' => 5000.00,
                'rating_average' => 5.00,
                'rating_count' => 0,
                'acceptance_rate' => 100.00,
                'on_time_rate' => 100.00,
            ]);

            return $user->fresh('riderProfile');
        });
    }

    public function markPhoneVerified(User $user): bool
    {
        return $user->update([
            'phone_verified_at' => now(),
        ]);
    }

    public function updateProfile(User $user, array $attributes): bool
    {
        return $user->update($attributes);
    }
}
