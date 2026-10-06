<?php

declare(strict_types=1);

namespace App\DTOs\Order;

readonly class OrderLifecycleDTO
{
    public function __construct(
        public int $userId,
        public int $orderId,
        public float $latitude,
        public float $longitude,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request, int $orderId): self
    {
        return new self(
            userId: (int) $request->user()->id,
            orderId: $orderId,
            latitude: (float) $request->input('latitude'),
            longitude: (float) $request->input('longitude'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
