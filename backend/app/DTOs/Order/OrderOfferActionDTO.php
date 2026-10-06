<?php

declare(strict_types=1);

namespace App\DTOs\Order;

readonly class OrderOfferActionDTO
{
    public function __construct(
        public int $userId,
        public int $orderId,
        public ?float $latitude,
        public ?float $longitude,
        public ?string $reason,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function forAccept(\Illuminate\Http\Request $request, int $orderId): self
    {
        return new self(
            userId: (int) $request->user()->id,
            orderId: $orderId,
            latitude: (float) $request->input('latitude'),
            longitude: (float) $request->input('longitude'),
            reason: null,
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }

    public static function forReject(\Illuminate\Http\Request $request, int $orderId): self
    {
        return new self(
            userId: (int) $request->user()->id,
            orderId: $orderId,
            latitude: null,
            longitude: null,
            reason: trim((string) $request->input('reason')),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
