<?php

declare(strict_types=1);

namespace App\DTOs\Order;

readonly class ConfirmDeliveryDTO
{
    public function __construct(
        public int $userId,
        public int $orderId,
        public string $otp,
        public float $latitude,
        public float $longitude,
        public ?string $proofPhotoPath,
        public ?string $signaturePath,
        public string $ipAddress,
        public string $userAgent,
    ) {}
}
