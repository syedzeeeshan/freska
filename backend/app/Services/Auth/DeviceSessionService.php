<?php

declare(strict_types=1);

namespace App\Services\Auth;

use App\Models\Device;
use App\Models\User;

class DeviceSessionService
{
    /**
     * Enforce single active device session per rider account.
     */
    public function bindDeviceSession(
        User $user,
        string $deviceId,
        ?string $deviceModel,
        ?string $osVersion,
        ?string $appVersion,
        ?string $fcmToken
    ): Device {
        // Deactivate all previous devices for this user
        $user->devices()->update(['is_active' => false]);

        // Revoke all previous tokens for strict single-session security
        $user->tokens()->delete();

        return Device::updateOrCreate(
            ['device_id' => $deviceId],
            [
                'user_id' => $user->id,
                'device_model' => $deviceModel,
                'os_version' => $osVersion,
                'app_version' => $appVersion,
                'fcm_token' => $fcmToken,
                'is_active' => true,
                'last_active_at' => now(),
            ]
        );
    }

    public function terminateDeviceSession(User $user, string $deviceId): bool
    {
        $user->devices()->where('device_id', $deviceId)->update(['is_active' => false]);
        $user->currentAccessToken()?->delete();
        return true;
    }
}
