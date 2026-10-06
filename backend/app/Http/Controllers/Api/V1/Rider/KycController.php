<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Rider;

use App\DTOs\Rider\SubmitKycDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Rider\SubmitKycRequest;
use App\Http\Resources\V1\KycStatusResource;
use App\Http\Resources\V1\RiderProfileResource;
use App\Services\Rider\KycService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class KycController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly KycService $kycService,
    ) {}

    /**
     * Upload multi-document KYC package.
     */
    public function submitKyc(SubmitKycRequest $request): JsonResponse
    {
        $dto = SubmitKycDTO::fromRequest($request);
        $profile = $this->kycService->submitKycDocuments($dto);

        return $this->successResponse(
            data: new RiderProfileResource($profile),
            message: 'KYC documents submitted for operations review.',
            statusCode: Response::HTTP_CREATED
        );
    }

    /**
     * Fetch real-time KYC status.
     */
    public function getStatus(Request $request): JsonResponse
    {
        $status = $this->kycService->getKycStatus((int) $request->user()->id);

        return $this->successResponse(
            data: new KycStatusResource($status),
            message: 'KYC status retrieved.'
        );
    }
}
