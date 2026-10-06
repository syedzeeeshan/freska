<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Order;

use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Order\AcceptOrderRequest;
use App\Http\Requests\V1\Order\RejectOrderRequest;
use App\Http\Resources\V1\Order\ActiveOrderResource;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Traits\ApiResponseTrait;
use DomainException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class OrderOfferController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly OrderRepositoryInterface $orderRepository,
    ) {}

    public function active(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $activeOrder = $this->orderRepository->getActiveOrderForRider($userId);

        if ($activeOrder === null) {
            return $this->successResponse(
                data: [
                    'has_active_order' => false,
                    'order' => null,
                ],
                message: 'No active order assignment.'
            );
        }

        return $this->successResponse(
            data: [
                'has_active_order' => true,
                'order' => (new ActiveOrderResource($activeOrder))->resolve($request),
            ],
            message: 'Active order retrieved.'
        );
    }

    public function accept(AcceptOrderRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $latitude = (float) $request->input('latitude');
        $longitude = (float) $request->input('longitude');

        try {
            $order = $this->orderRepository->acceptOffer($id, $userId, $latitude, $longitude);

            return $this->successResponse(
                data: [
                    'order_id' => $order->id,
                    'status' => $order->status->value,
                    'accepted_at' => $order->assignment_accepted_at?->toIso8601String(),
                ],
                message: 'Order accepted successfully.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_OFFER_ACCEPTANCE_FAILED'
            );
        }
    }

    public function reject(RejectOrderRequest $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $reason = (string) $request->input('reason');

        $this->orderRepository->rejectOffer($id, $userId, $reason);

        return $this->successResponse(
            data: null,
            message: 'Order declined.'
        );
    }
}
