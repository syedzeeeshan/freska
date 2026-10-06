<?php

declare(strict_types=1);

namespace App\DTOs\Notification;

use App\Http\Requests\V1\Notification\RegisterDeviceRequest;

readonly class RegisterDeviceDTO
{
    public function __construct(
        public int $userId,
        public string $deviceId,
        public ?string $fcmToken = null,
        public ?string $deviceModel = null,
        public ?string $osVersion = null,
        public ?string $appVersion = null,
    ) {}

    public static function fromRequest(RegisterDeviceRequest $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            deviceId: (string) $request->validated('device_id'),
            fcmToken: $request->validated('fcm_token'),
            deviceModel: $request->validated('device_model'),
            osVersion: $request->validated('os_version'),
            appVersion: $request->validated('app_version'),
        );
    }
}
