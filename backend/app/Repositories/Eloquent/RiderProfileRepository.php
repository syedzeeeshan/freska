<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Models\RiderProfile;

class RiderProfileRepository implements RiderProfileRepositoryInterface
{
    public function findByUserId(int $userId): ?RiderProfile
    {
        return RiderProfile::where('user_id', $userId)->first();
    }

    public function updateKycSubmission(int $userId, array $attributes): RiderProfile
    {
        $profile = RiderProfile::firstOrCreate(['user_id' => $userId]);
        $profile->update($attributes);
        return $profile->fresh();
    }

    public function updateBankDetails(int $userId, array $attributes): RiderProfile
    {
        $profile = RiderProfile::firstOrCreate(['user_id' => $userId]);
        $profile->update($attributes);
        return $profile->fresh();
    }

    public function updateEmergencyContact(int $userId, array $attributes): RiderProfile
    {
        $profile = RiderProfile::firstOrCreate(['user_id' => $userId]);
        $profile->update($attributes);
        return $profile->fresh();
    }

    public function updateDutyStatus(int $userId, bool $isOnline, ?float $lat, ?float $lng): RiderProfile
    {
        $profile = RiderProfile::firstOrCreate(['user_id' => $userId]);
        $profile->update([
            'is_online' => $isOnline,
            'current_latitude' => $lat,
            'current_longitude' => $lng,
            'last_location_updated_at' => now(),
        ]);
        return $profile->fresh();
    }

    public function updateLocation(int $userId, float $latitude, float $longitude): RiderProfile
    {
        $profile = RiderProfile::firstOrCreate(['user_id' => $userId]);
        $profile->update([
            'current_latitude' => $latitude,
            'current_longitude' => $longitude,
            'last_location_updated_at' => now(),
        ]);
        return $profile->fresh();
    }
}

