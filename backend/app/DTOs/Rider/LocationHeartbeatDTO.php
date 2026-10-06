<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

readonly class LocationHeartbeatDTO
{
    public function __construct(
        public int $userId,
        public float $latitude,
        public float $longitude,
        public ?float $heading,
        public ?float $speed,
        public ?int $batteryPercentage,
        public bool $isMock,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            latitude: (float) $request->input('latitude'),
            longitude: (float) $request->input('longitude'),
            heading: $request->input('heading') !== null ? (float) $request->input('heading') : null,
            speed: $request->input('speed') !== null ? (float) $request->input('speed') : null,
            batteryPercentage: $request->input('battery_percentage') !== null ? (int) $request->input('battery_percentage') : null,
            isMock: (bool) $request->input('is_mock', false),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
