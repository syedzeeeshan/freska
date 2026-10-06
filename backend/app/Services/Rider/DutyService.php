<?php

declare(strict_types=1);

namespace App\Services\Rider;

use App\DTOs\Rider\ToggleDutyDTO;
use App\Enums\KycStatus;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Models\AuditLog;
use App\Models\RiderProfile;
use App\Services\Dispatch\RiderMatchingService;
use DomainException;

class DutyService
{
    public function __construct(
        private readonly RiderProfileRepositoryInterface $riderProfileRepository,
        private readonly RiderMatchingService $riderMatchingService,
    ) {}

    public function toggleDuty(ToggleDutyDTO $dto): RiderProfile
    {
        $profile = $this->riderProfileRepository->findByUserId($dto->userId);

        if (!$profile || $profile->kyc_status !== KycStatus::VERIFIED) {
            throw new DomainException('Duty switch is blocked. Your KYC documents must be approved first.');
        }

        if ($dto->isOnline && ($dto->latitude === null || $dto->longitude === null)) {
            throw new DomainException('Current GPS coordinates are required to switch duty to Online.');
        }

        $updatedProfile = $this->riderProfileRepository->updateDutyStatus(
            $dto->userId,
            $dto->isOnline,
            $dto->latitude,
            $dto->longitude
        );

        if ($dto->isOnline && $dto->latitude !== null && $dto->longitude !== null) {
            $this->riderMatchingService->setRiderLocation($dto->userId, $dto->latitude, $dto->longitude);
        } else {
            $this->riderMatchingService->removeRiderLocation($dto->userId);
        }

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'rider.duty_toggled',
            'entity_type' => RiderProfile::class,
            'entity_id' => $updatedProfile->id,
            'old_values' => ['is_online' => $profile->is_online],
            'new_values' => [
                'is_online' => $dto->isOnline,
                'latitude' => $dto->latitude,
                'longitude' => $dto->longitude,
            ],
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $updatedProfile;
    }
}
