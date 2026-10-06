<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\Finance\PayoutResource;
use App\Models\Payout;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PayoutController extends Controller
{
    use ApiResponseTrait;

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;

        $payouts = Payout::query()
            ->where('rider_id', $userId)
            ->orderByDesc('period_end')
            ->paginate(15);

        return $this->successResponse(
            data: PayoutResource::collection($payouts)->response()->getData(true),
            message: 'Payout statements retrieved.'
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;

        $payout = Payout::query()
            ->with('earnings')
            ->where('rider_id', $userId)
            ->findOrFail($id);

        return $this->successResponse(
            data: (new PayoutResource($payout))->resolve($request),
            message: 'Payout details retrieved.'
        );
    }
}
