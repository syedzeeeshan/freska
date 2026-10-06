<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\RiderProfile;
use App\Models\User;

class RiderProfilePolicy
{
    /**
     * Determine if user can view the rider profile.
     */
    public function view(User $user, RiderProfile $profile): bool
    {
        return $user->id === $profile->user_id || $user->role !== 'rider';
    }

    /**
     * Determine if user can update the rider profile.
     */
    public function update(User $user, RiderProfile $profile): bool
    {
        return $user->id === $profile->user_id;
    }

    /**
     * Determine if user can review KYC documents (operations/admin only).
     */
    public function reviewKyc(User $user): bool
    {
        return in_array($user->role->value ?? (string) $user->role, [
            'operations_manager',
            'super_admin',
        ], true);
    }
}
