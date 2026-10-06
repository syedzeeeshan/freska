<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Rider;

use App\DTOs\Rider\LocationHeartbeatDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Rider\LocationHeartbeatRequest;
use App\Services\Rider\LocationService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;

class LocationController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly LocationService $locationService,
    ) {}

    public function heartbeat(LocationHeartbeatRequest $request): JsonResponse
    {
        $dto = LocationHeartbeatDTO::fromRequest($request);
        $this->locationService->recordHeartbeat($dto);

        return $this->successResponse(
            data: null,
            message: 'Location updated.'
        );
    }
}
