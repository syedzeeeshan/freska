<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Interfaces\Repositories\DeviceRepositoryInterface;
use App\Models\Device;
use Illuminate\Database\Eloquent\Collection;

class DeviceRepository implements DeviceRepositoryInterface
{
    public function findByDeviceId(string $deviceId): ?Device
    {
        return Device::where('device_id', $deviceId)->first();
    }

    public function registerOrUpdateDevice(
        int $userId,
        string $deviceId,
        ?string $fcmToken,
        ?string $deviceModel,
        ?string $osVersion,
        ?string $appVersion
    ): Device {
        return Device::updateOrCreate(
            ['device_id' => $deviceId],
            [
                'user_id' => $userId,
                'fcm_token' => $fcmToken,
                'device_model' => $deviceModel,
                'os_version' => $osVersion,
                'app_version' => $appVersion,
                'is_active' => true,
                'last_active_at' => now(),
            ]
        );
    }

    public function deactivateOtherDevices(int $userId, string $activeDeviceId): void
    {
        Device::where('user_id', $userId)
            ->where('device_id', '!=', $activeDeviceId)
            ->update(['is_active' => false]);
    }

    public function deactivateDevice(string $deviceId): bool
    {
        return (bool) Device::where('device_id', $deviceId)->update(['is_active' => false]);
    }

    public function getActiveDevicesForUser(int $userId): Collection
    {
        return Device::where('user_id', $userId)
            ->where('is_active', true)
            ->get();
    }
}
