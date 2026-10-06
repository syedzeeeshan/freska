<?php

declare(strict_types=1);

namespace App\Services\Dispatch;

use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Models\OrderAssignmentOffer;
use Illuminate\Support\Facades\Log;

class OfferBroadcastService
{
    public function __construct(
        private readonly OrderRepositoryInterface $orderRepository,
    ) {}

    public function broadcastOffer(int $orderId, int $riderId, int $ttlSeconds = 30): OrderAssignmentOffer
    {
        $offer = $this->orderRepository->createOffer($orderId, $riderId, $ttlSeconds);

        Log::info("Broadcasted Order Offer #{$offer->id} for Order #{$orderId} to Rider #{$riderId} (TTL: {$ttlSeconds}s)");

        return $offer;
    }
}
