<?php

declare(strict_types=1);

namespace App\Services\Dispatch;

use App\Enums\KycStatus;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;

class RiderMatchingService
{
    private const REDIS_GEO_KEY = 'riders:online';

    public function __construct(
        private readonly OrderRepositoryInterface $orderRepository,
        private readonly RiderProfileRepositoryInterface $riderProfileRepository,
    ) {}

    /**
     * Update or add rider coordinates in Redis geospatial index.
     */
    public function setRiderLocation(int $riderId, float $latitude, float $longitude): void
    {
        try {
            Redis::geoadd(self::REDIS_GEO_KEY, $longitude, $latitude, (string) $riderId);
        } catch (\Throwable $e) {
            Log::warning("Redis geoadd failed for rider {$riderId}: " . $e->getMessage());
        }
    }

    /**
     * Remove rider from Redis geospatial index when duty turns offline.
     */
    public function removeRiderLocation(int $riderId): void
    {
        try {
            Redis::zrem(self::REDIS_GEO_KEY, (string) $riderId);
        } catch (\Throwable $e) {
            Log::warning("Redis zrem failed for rider {$riderId}: " . $e->getMessage());
        }
    }

    /**
     * Find eligible online riders within radius (in km) sorted by distance.
     *
     * @return array<int, array{rider_id: int, distance_km: float}>
     */
    public function findEligibleNearbyRiders(float $latitude, float $longitude, float $radiusKm = 5.0, int $limit = 5): array
    {
        $candidateRiders = [];

        try {
            // Redis GEORADIUS or GEOSEARCH: returns [member, distance]
            /** @var array<int, array{0: string, 1: string}> $rawResults */
            $rawResults = Redis::georadius(
                self::REDIS_GEO_KEY,
                $longitude,
                $latitude,
                $radiusKm,
                'km',
                ['WITHDIST', 'ASC', 'COUNT', $limit * 3]
            );

            foreach ($rawResults as $item) {
                $riderId = (int) $item[0];
                $distanceKm = (float) $item[1];

                if ($this->isRiderEligibleForDispatch($riderId)) {
                    $candidateRiders[] = [
                        'rider_id' => $riderId,
                        'distance_km' => $distanceKm,
                    ];

                    if (count($candidateRiders) >= $limit) {
                        break;
                    }
                }
            }
        } catch (\Throwable $e) {
            Log::error("Rider matching geospatial lookup failed: " . $e->getMessage());
        }

        return $candidateRiders;
    }

    /**
     * Verify rider has verified KYC, is online, has no active order, and cash within limits.
     */
    public function isRiderEligibleForDispatch(int $riderId): bool
    {
        $profile = $this->riderProfileRepository->findByUserId($riderId);

        if (!$profile) {
            return false;
        }

        if (!$profile->is_online || $profile->kyc_status !== KycStatus::VERIFIED) {
            return false;
        }

        // Must not have an active in-flight order
        $activeOrder = $this->orderRepository->getActiveOrderForRider($riderId);
        if ($activeOrder !== null) {
            return false;
        }

        // Check pending offer
        $pendingOffer = $this->orderRepository->getPendingOfferForRider($riderId);
        if ($pendingOffer !== null) {
            return false;
        }

        // Cash in hand check
        if ($profile->current_cash_in_hand >= $profile->max_cash_limit) {
            return false;
        }

        return true;
    }
}
