<?php

declare(strict_types=1);

namespace App\Services\Rider;

use App\DTOs\Rider\LocationHeartbeatDTO;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Models\AuditLog;
use App\Models\RiderProfile;
use App\Services\Dispatch\RiderMatchingService;
use Illuminate\Support\Facades\Log;

class LocationService
{
    public function __construct(
        private readonly RiderProfileRepositoryInterface $riderProfileRepository,
        private readonly RiderMatchingService $riderMatchingService,
    ) {}

    public function recordHeartbeat(LocationHeartbeatDTO $dto): void
    {
        $profile = $this->riderProfileRepository->findByUserId($dto->userId);

        if ($dto->isMock) {
            Log::warning("Mock GPS detected for rider ID {$dto->userId}", [
                'lat' => $dto->latitude,
                'lng' => $dto->longitude,
                'ip' => $dto->ipAddress,
            ]);

            AuditLog::create([
                'user_id' => $dto->userId,
                'action' => 'security.mock_gps_detected',
                'entity_type' => RiderProfile::class,
                'entity_id' => $profile?->id ?? $dto->userId,
                'old_values' => null,
                'new_values' => [
                    'latitude' => $dto->latitude,
                    'longitude' => $dto->longitude,
                    'is_mock' => true,
                ],
                'ip_address' => $dto->ipAddress,
                'user_agent' => $dto->userAgent,
            ]);
        }

        $this->riderProfileRepository->updateLocation($dto->userId, $dto->latitude, $dto->longitude);

        if ($profile && $profile->is_online) {
            $this->riderMatchingService->setRiderLocation($dto->userId, $dto->latitude, $dto->longitude);
        }
    }
}
