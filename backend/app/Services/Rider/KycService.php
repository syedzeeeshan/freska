<?php

declare(strict_types=1);

namespace App\Services\Rider;

use App\DTOs\Rider\SubmitKycDTO;
use App\Enums\KycStatus;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\AuditLog;
use App\Models\RiderProfile;
use Illuminate\Support\Facades\DB;

class KycService
{
    public function __construct(
        private readonly RiderProfileRepositoryInterface $profileRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    /**
     * Upload multi-part documents and transition rider KYC status to 'submitted'.
     */
    public function submitKycDocuments(SubmitKycDTO $dto): RiderProfile
    {
        return DB::transaction(function () use ($dto) {
            // Upload documents to secure storage
            $licenseFrontPath = $this->storageService->uploadKycDocument($dto->licenseFront, $dto->userId, 'license_front');
            $licenseBackPath = $this->storageService->uploadKycDocument($dto->licenseBack, $dto->userId, 'license_back');
            $rcBookPath = $this->storageService->uploadKycDocument($dto->rcBook, $dto->userId, 'rc_book');
            $idProofPath = $this->storageService->uploadKycDocument($dto->idProofDocument, $dto->userId, "id_{$dto->idProofType}");

            // Update rider profile
            $profile = $this->profileRepository->updateKycSubmission($dto->userId, [
                'vehicle_type' => $dto->vehicleType,
                'vehicle_number' => $dto->vehicleNumber,
                'license_number' => $dto->licenseNumber,
                'license_expiry' => $dto->licenseExpiry,
                'license_front_url' => $licenseFrontPath,
                'license_back_url' => $licenseBackPath,
                'rc_book_url' => $rcBookPath,
                'id_proof_type' => $dto->idProofType,
                'id_proof_number' => $dto->idProofNumber,
                'id_proof_url' => $idProofPath,
                'kyc_status' => KycStatus::SUBMITTED,
                'kyc_rejection_reason' => null,
            ]);

            // Compliance audit log
            AuditLog::create([
                'user_id' => $dto->userId,
                'action' => 'KYC_DOCUMENTS_SUBMITTED',
                'ip_address' => $dto->ipAddress,
                'user_agent' => $dto->userAgent,
                'metadata' => [
                    'license_number' => $dto->licenseNumber,
                    'vehicle_number' => $dto->vehicleNumber,
                    'id_proof_type' => $dto->idProofType,
                ],
            ]);

            return $profile;
        });
    }

    /**
     * Fetch current KYC review status.
     */
    public function getKycStatus(int $userId): array
    {
        $profile = $this->profileRepository->findByUserId($userId);

        return [
            'kyc_status' => $profile?->kyc_status?->value ?? 'pending',
            'rejection_reason' => $profile?->kyc_rejection_reason,
            'reviewed_at' => $profile?->kyc_reviewed_at?->toIso8601String(),
            'vehicle_number' => $profile?->vehicle_number,
            'license_number' => $profile?->license_number,
        ];
    }
}
