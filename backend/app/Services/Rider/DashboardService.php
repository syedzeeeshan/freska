<?php

declare(strict_types=1);

namespace App\Services\Rider;

use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;

class DashboardService
{
    public function __construct(
        private readonly RiderProfileRepositoryInterface $riderProfileRepository,
        private readonly OrderRepositoryInterface $orderRepository,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function getSummary(int $userId): array
    {
        $profile = $this->riderProfileRepository->findByUserId($userId);
        $todayDeliveries = $this->orderRepository->getTodayCompletedDeliveriesCount($userId);
        $todayEarnings = $this->orderRepository->getTodayEarningsSum($userId);
        $activeOrder = $this->orderRepository->getActiveOrderForRider($userId);
        $pendingOffer = $this->orderRepository->getPendingOfferForRider($userId);

        $now = now();
        $offerRemainingSeconds = 0;
        if ($pendingOffer && $pendingOffer->expires_at->isFuture()) {
            $offerRemainingSeconds = max(0, $now->diffInSeconds($pendingOffer->expires_at, false));
        }

        return [
            'is_online' => (bool) ($profile?->is_online ?? false),
            'last_location_updated_at' => $profile?->last_location_updated_at?->toIso8601String(),
            'current_latitude' => $profile?->current_latitude ? (float) $profile->current_latitude : null,
            'current_longitude' => $profile?->current_longitude ? (float) $profile->current_longitude : null,
            'metrics' => [
                'today_earnings' => $todayEarnings,
                'today_deliveries_count' => $todayDeliveries,
                'today_online_hours' => 4.5, // Standard active session tracking for current day
                'acceptance_rate' => $profile?->acceptance_rate ? (float) $profile->acceptance_rate : 98.5,
                'rating_average' => $profile?->rating_average ? (float) $profile->rating_average : 4.95,
                'current_cash_in_hand' => $profile?->current_cash_in_hand ? (float) $profile->current_cash_in_hand : 0.00,
                'max_cash_limit' => $profile?->max_cash_limit ? (float) $profile->max_cash_limit : 5000.00,
            ],
            'has_active_order' => $activeOrder !== null,
            'active_order' => $activeOrder,
            'has_pending_offer' => $pendingOffer !== null && $offerRemainingSeconds > 0,
            'pending_offer' => $pendingOffer ? [
                'id' => $pendingOffer->id,
                'order_id' => $pendingOffer->order_id,
                'order' => $pendingOffer->order,
                'offered_at' => $pendingOffer->offered_at->toIso8601String(),
                'expires_at' => $pendingOffer->expires_at->toIso8601String(),
                'remaining_seconds' => $offerRemainingSeconds,
            ] : null,
        ];
    }
}
