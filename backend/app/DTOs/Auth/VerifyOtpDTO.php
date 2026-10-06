<?php

declare(strict_types=1);

namespace App\DTOs\Auth;

readonly class VerifyOtpDTO
{
    public function __construct(
        public string $phone,
        public string $otp,
        public string $deviceId,
        public ?string $deviceModel,
        public ?string $osVersion,
        public ?string $appVersion,
        public ?string $fcmToken,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            phone: (string) $request->input('phone'),
            otp: (string) $request->input('otp'),
            deviceId: (string) $request->input('device_id'),
            deviceModel: $request->input('device_model'),
            osVersion: $request->input('os_version'),
            appVersion: $request->input('app_version'),
            fcmToken: $request->input('fcm_token'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
