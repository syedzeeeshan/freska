<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Device;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Device>
 */
class DeviceFactory extends Factory
{
    protected $model = Device::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'device_id' => (string) Str::uuid(),
            'fcm_token' => Str::random(64),
            'device_model' => 'Pixel 8 Pro',
            'os_version' => 'Android 14',
            'app_version' => '1.0.0+1',
            'is_active' => true,
            'last_active_at' => now(),
        ];
    }
}
