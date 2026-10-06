<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Safety;

use App\DTOs\Safety\ReportIncidentDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Safety\ReportIncidentRequest;
use App\Http\Resources\V1\Safety\IncidentResource;
use App\Services\Safety\EmergencySosService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class IncidentController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly EmergencySosService $emergencySosService,
    ) {}

    public function reportIncident(ReportIncidentRequest $request): JsonResponse
    {
        $dto = ReportIncidentDTO::fromRequest($request);
        $incident = $this->emergencySosService->reportIncident($dto);

        return $this->successResponse(
            data: (new IncidentResource($incident))->resolve($request),
            message: 'Incident reported. Safety team will follow up.',
            statusCode: Response::HTTP_CREATED
        );
    }
}
