<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Rider;

use App\DTOs\Rider\ToggleDutyDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Rider\ToggleDutyRequest;
use App\Http\Resources\V1\Rider\DashboardSummaryResource;
use App\Services\Rider\DashboardService;
use App\Services\Rider\DutyService;
use App\Traits\ApiResponseTrait;
use DomainException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DutyController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly DutyService $dutyService,
        private readonly DashboardService $dashboardService,
    ) {}

    public function toggle(ToggleDutyRequest $request): JsonResponse
    {
        try {
            $dto = ToggleDutyDTO::fromRequest($request);
            $profile = $this->dutyService->toggleDuty($dto);

            $statusText = $profile->is_online ? 'Online' : 'Offline';

            return $this->successResponse(
                data: [
                    'is_online' => (bool) $profile->is_online,
                    'last_location_updated_at' => $profile->last_location_updated_at?->toIso8601String(),
                ],
                message: "Rider status is now {$statusText}."
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_DUTY_TOGGLE_FAILED'
            );
        }
    }

    public function summary(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $summary = $this->dashboardService->getSummary($userId);

        return $this->successResponse(
            data: (new DashboardSummaryResource($summary))->resolve($request),
            message: 'Dashboard summary retrieved successfully.'
        );
    }
}
