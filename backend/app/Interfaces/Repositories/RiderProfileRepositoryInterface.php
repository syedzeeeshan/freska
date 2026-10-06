<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\RiderProfile;

interface RiderProfileRepositoryInterface
{
    public function findByUserId(int $userId): ?RiderProfile;

    public function updateKycSubmission(int $userId, array $attributes): RiderProfile;

    public function updateBankDetails(int $userId, array $attributes): RiderProfile;

    public function updateEmergencyContact(int $userId, array $attributes): RiderProfile;

    public function updateDutyStatus(int $userId, bool $isOnline, ?float $lat, ?float $lng): RiderProfile;

    public function updateLocation(int $userId, float $latitude, float $longitude): RiderProfile;
}

