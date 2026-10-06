<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Rider;

use App\DTOs\Rider\UpdateBankDetailsDTO;
use App\DTOs\Rider\UpdateEmergencyContactDTO;
use App\DTOs\Rider\UploadProfilePhotoDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Rider\UpdateBankDetailsRequest;
use App\Http\Requests\V1\Rider\UpdateEmergencyContactRequest;
use App\Http\Requests\V1\Rider\UploadProfilePhotoRequest;
use App\Http\Resources\V1\RiderProfileResource;
use App\Http\Resources\V1\UserResource;
use App\Services\Rider\RiderProfileService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly RiderProfileService $profileService,
    ) {}

    /**
     * Upload profile avatar selfie.
     */
    public function uploadPhoto(UploadProfilePhotoRequest $request): JsonResponse
    {
        $dto = UploadProfilePhotoDTO::fromRequest($request);
        $url = $this->profileService->uploadProfilePhoto($dto);

        return $this->successResponse(
            data: ['avatar_url' => $url],
            message: 'Profile photo updated successfully.'
        );
    }

    /**
     * Update bank payout details.
     */
    public function updateBankDetails(UpdateBankDetailsRequest $request): JsonResponse
    {
        $dto = UpdateBankDetailsDTO::fromRequest($request);
        $profile = $this->profileService->updateBankDetails($dto);

        return $this->successResponse(
            data: new RiderProfileResource($profile),
            message: 'Bank account and payout credentials updated.'
        );
    }

    /**
     * Update emergency contact.
     */
    public function updateEmergencyContact(UpdateEmergencyContactRequest $request): JsonResponse
    {
        $dto = UpdateEmergencyContactDTO::fromRequest($request);
        $profile = $this->profileService->updateEmergencyContact($dto);

        return $this->successResponse(
            data: new RiderProfileResource($profile),
            message: 'Emergency contact updated successfully.'
        );
    }

    /**
     * Get detailed profile.
     */
    public function getProfile(Request $request): JsonResponse
    {
        $user = $this->profileService->getProfile((int) $request->user()->id);

        return $this->successResponse(
            data: new UserResource($user),
            message: 'Profile retrieved successfully.'
        );
    }
}
