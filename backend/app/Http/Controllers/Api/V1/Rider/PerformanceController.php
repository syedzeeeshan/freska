<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Rider;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\Performance\PerformanceResource;
use App\Http\Resources\V1\Performance\RatingReviewResource;
use App\Services\Rider\PerformanceMetricsService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PerformanceController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly PerformanceMetricsService $performanceService,
    ) {}

    public function getMetrics(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $metrics = $this->performanceService->getMetrics($userId);

        return $this->successResponse(
            data: (new PerformanceResource($metrics))->resolve($request),
            message: 'Performance metrics retrieved.'
        );
    }

    public function getReviews(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $perPage = (int) $request->query('per_page', 15);

        $reviews = $this->performanceService->getReviews($userId, $perPage);

        return $this->successResponse(
            data: RatingReviewResource::collection($reviews)->response()->getData(true),
            message: 'Customer ratings and compliments retrieved.'
        );
    }
}
