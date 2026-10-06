<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\Device;
use Illuminate\Database\Eloquent\Collection;

interface DeviceRepositoryInterface
{
    public function findByDeviceId(string $deviceId): ?Device;

    public function registerOrUpdateDevice(
        int $userId,
        string $deviceId,
        ?string $fcmToken,
        ?string $deviceModel,
        ?string $osVersion,
        ?string $appVersion
    ): Device;

    public function deactivateOtherDevices(int $userId, string $activeDeviceId): void;

    public function deactivateDevice(string $deviceId): bool;

    public function getActiveDevicesForUser(int $userId): Collection;
}
