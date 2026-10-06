<?php

declare(strict_types=1);

namespace App\Services\Rider;

use App\DTOs\Rider\UpdateBankDetailsDTO;
use App\DTOs\Rider\UpdateEmergencyContactDTO;
use App\DTOs\Rider\UploadProfilePhotoDTO;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Interfaces\Repositories\UserRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\AuditLog;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class RiderProfileService
{
    public function __construct(
        private readonly RiderProfileRepositoryInterface $profileRepository,
        private readonly UserRepositoryInterface $userRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    /**
     * Upload and update rider profile selfie avatar.
     */
    public function uploadProfilePhoto(UploadProfilePhotoDTO $dto): string
    {
        $path = $this->storageService->uploadProfilePhoto($dto->photo, $dto->userId);

        $user = $this->userRepository->findById($dto->userId);
        if ($user) {
            $this->userRepository->updateProfile($user, ['avatar_url' => $path]);
        }

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'PROFILE_PHOTO_UPDATED',
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $path;
    }

    /**
     * Update bank payout credentials.
     */
    public function updateBankDetails(UpdateBankDetailsDTO $dto): RiderProfile
    {
        return DB::transaction(function () use ($dto) {
            $profile = $this->profileRepository->updateBankDetails($dto->userId, [
                'bank_account_holder' => $dto->bankAccountHolder,
                'bank_name' => $dto->bankName,
                'bank_account_number' => $dto->bankAccountNumber,
                'bank_ifsc_code' => $dto->bankIfscCode,
                'bank_upi_id' => $dto->bankUpiId,
                'bank_verified' => true,
            ]);

            AuditLog::create([
                'user_id' => $dto->userId,
                'action' => 'BANK_DETAILS_UPDATED',
                'ip_address' => $dto->ipAddress,
                'user_agent' => $dto->userAgent,
                'metadata' => [
                    'bank_name' => $dto->bankName,
                    'ifsc' => $dto->bankIfscCode,
                    'has_upi' => !empty($dto->bankUpiId),
                ],
            ]);

            return $profile;
        });
    }

    /**
     * Update emergency contact details.
     */
    public function updateEmergencyContact(UpdateEmergencyContactDTO $dto): RiderProfile
    {
        return DB::transaction(function () use ($dto) {
            $profile = $this->profileRepository->updateEmergencyContact($dto->userId, [
                'emergency_contact_name' => $dto->contactName,
                'emergency_contact_phone' => $dto->contactPhone,
                'emergency_contact_relation' => $dto->contactRelation,
            ]);

            AuditLog::create([
                'user_id' => $dto->userId,
                'action' => 'EMERGENCY_CONTACT_UPDATED',
                'ip_address' => $dto->ipAddress,
                'user_agent' => $dto->userAgent,
            ]);

            return $profile;
        });
    }

    /**
     * Retrieve full rider profile with relations.
     */
    public function getProfile(int $userId): ?User
    {
        return $this->userRepository->findById($userId);
    }
}
