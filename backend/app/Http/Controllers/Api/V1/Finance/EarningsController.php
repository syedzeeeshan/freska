<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\Finance\EarningsHistoryResource;
use App\Http\Resources\V1\Finance\EarningsSummaryResource;
use App\Interfaces\Repositories\EarningsRepositoryInterface;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EarningsController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly EarningsRepositoryInterface $earningsRepository,
    ) {}

    public function summary(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $summary = $this->earningsRepository->getEarningsSummary($userId);
        $weeklyBreakdown = $this->earningsRepository->getWeeklyDailyBreakdown($userId);

        return $this->successResponse(
            data: [
                'summary' => (new EarningsSummaryResource($summary))->resolve($request),
                'weekly_daily_chart' => $weeklyBreakdown,
            ],
            message: 'Earnings summary retrieved successfully.'
        );
    }

    public function history(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $perPage = (int) $request->query('per_page', 20);

        $paginator = $this->earningsRepository->getEarningsHistory($userId, $perPage);

        return $this->successResponse(
            data: EarningsHistoryResource::collection($paginator)->response()->getData(true),
            message: 'Earnings history retrieved successfully.'
        );
    }
}
