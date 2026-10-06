<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Safety;

use App\DTOs\Safety\TriggerSosDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Safety\TriggerSosRequest;
use App\Http\Resources\V1\Safety\IncidentResource;
use App\Http\Resources\V1\Safety\InsuranceCardResource;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Services\Safety\EmergencySosService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SosController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly EmergencySosService $emergencySosService,
        private readonly RiderProfileRepositoryInterface $profileRepository,
    ) {}

    public function triggerSos(TriggerSosRequest $request): JsonResponse
    {
        $dto = TriggerSosDTO::fromRequest($request);
        $incident = $this->emergencySosService->triggerSos($dto);

        return $this->successResponse(
            data: (new IncidentResource($incident))->resolve($request),
            message: 'EMERGENCY SOS TRIGGERED: 24/7 Operations Desk alerted & SMS dispatched to next of kin.',
            statusCode: Response::HTTP_CREATED
        );
    }

    public function getInsurance(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $profile = $this->profileRepository->findByUserId($userId);

        return $this->successResponse(
            data: (new InsuranceCardResource($profile))->resolve($request),
            message: 'Insurance policy details retrieved.'
        );
    }
}
