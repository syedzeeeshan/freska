<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\Order;
use App\Models\OrderAssignmentOffer;

interface OrderRepositoryInterface
{
    public function getActiveOrderForRider(int $riderId): ?Order;

    public function getPendingOfferForRider(int $riderId): ?OrderAssignmentOffer;

    public function findOrderById(int $orderId): ?Order;

    public function findOfferById(int $offerId): ?OrderAssignmentOffer;

    public function findOfferForRider(int $orderId, int $riderId): ?OrderAssignmentOffer;

    public function acceptOffer(int $orderId, int $riderId, float $latitude, float $longitude): Order;

    public function rejectOffer(int $orderId, int $riderId, string $reason): void;

    public function expireOffer(int $offerId): void;

    public function createOffer(int $orderId, int $riderId, int $ttlSeconds = 30): OrderAssignmentOffer;

    public function getTodayCompletedDeliveriesCount(int $riderId): int;

    public function getTodayEarningsSum(int $riderId): float;

    public function markArrivedAtVendor(int $orderId, int $riderId, float $latitude, float $longitude): Order;

    public function markPickedUp(int $orderId, int $riderId, float $latitude, float $longitude): Order;

    public function markArrivedAtCustomer(int $orderId, int $riderId, float $latitude, float $longitude): Order;

    /**
     * @param array<string, mixed> $deliveryData
     */
    public function confirmDelivery(int $orderId, int $riderId, array $deliveryData): Order;

    public function generateDeliveryOtp(int $orderId): string;

    public function verifyDeliveryOtp(int $orderId, string $otp): bool;
}

