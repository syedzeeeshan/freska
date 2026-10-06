<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

readonly class ToggleDutyDTO
{
    public function __construct(
        public int $userId,
        public bool $isOnline,
        public ?float $latitude,
        public ?float $longitude,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            isOnline: (bool) $request->input('is_online'),
            latitude: $request->input('latitude') !== null ? (float) $request->input('latitude') : null,
            longitude: $request->input('longitude') !== null ? (float) $request->input('longitude') : null,
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
