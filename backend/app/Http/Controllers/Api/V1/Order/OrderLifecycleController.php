<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Order;

use App\DTOs\Order\ConfirmDeliveryDTO;
use App\DTOs\Order\OrderLifecycleDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Order\ArriveCustomerRequest;
use App\Http\Requests\V1\Order\ArriveVendorRequest;
use App\Http\Requests\V1\Order\ConfirmDeliveryRequest;
use App\Http\Requests\V1\Order\PickupOrderRequest;
use App\Http\Resources\V1\Order\OrderLifecycleStatusResource;
use App\Services\Order\OrderLifecycleService;
use App\Traits\ApiResponseTrait;
use DomainException;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class OrderLifecycleController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly OrderLifecycleService $orderLifecycleService,
    ) {}

    public function arriveVendor(ArriveVendorRequest $request, int $id): JsonResponse
    {
        try {
            $dto = OrderLifecycleDTO::fromRequest($request, $id);
            $order = $this->orderLifecycleService->arriveAtVendor($dto);

            return $this->successResponse(
                data: (new OrderLifecycleStatusResource($order))->resolve($request),
                message: 'Arrival recorded.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_LIFECYCLE_TRANSITION_INVALID'
            );
        }
    }

    public function pickupOrder(PickupOrderRequest $request, int $id): JsonResponse
    {
        try {
            $dto = OrderLifecycleDTO::fromRequest($request, $id);
            $packageVerified = (bool) $request->input('package_verified', false);
            $order = $this->orderLifecycleService->pickupOrder($dto, $packageVerified);

            /** @var string $customerPhone */
            $customerPhone = $order->customer_phone;
            /** @var string $deliveryAddress */
            $deliveryAddress = $order->delivery_address;

            return $this->successResponse(
                data: array_merge(
                    (new OrderLifecycleStatusResource($order))->resolve($request),
                    [
                        'customer_full_address' => $deliveryAddress,
                        'customer_phone' => $customerPhone,
                    ]
                ),
                message: 'Order picked up. Navigating to customer.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_LIFECYCLE_TRANSITION_INVALID'
            );
        }
    }

    public function arriveCustomer(ArriveCustomerRequest $request, int $id): JsonResponse
    {
        try {
            $dto = OrderLifecycleDTO::fromRequest($request, $id);
            $order = $this->orderLifecycleService->arriveAtCustomer($dto);

            return $this->successResponse(
                data: (new OrderLifecycleStatusResource($order))->resolve($request),
                message: 'Arrived at customer. Confirm delivery.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_LIFECYCLE_TRANSITION_INVALID'
            );
        }
    }

    public function confirmDelivery(ConfirmDeliveryRequest $request, int $id): JsonResponse
    {
        try {
            $userId = (int) $request->user()->id;
            $proofPhotoUrl = null;
            $signatureUrl = null;

            if ($request->hasFile('proof_photo')) {
                /** @var \Illuminate\Http\UploadedFile $proofFile */
                $proofFile = $request->file('proof_photo');
                $proofPhotoUrl = $this->orderLifecycleService->uploadProofOfDelivery($proofFile, $id);
            }

            if ($request->hasFile('signature')) {
                /** @var \Illuminate\Http\UploadedFile $signatureFile */
                $signatureFile = $request->file('signature');
                $signatureUrl = $this->orderLifecycleService->uploadProofOfDelivery($signatureFile, $id);
            }

            $dto = new ConfirmDeliveryDTO(
                userId: $userId,
                orderId: $id,
                otp: (string) $request->input('otp'),
                latitude: (float) $request->input('latitude'),
                longitude: (float) $request->input('longitude'),
                proofPhotoPath: $proofPhotoUrl,
                signaturePath: $signatureUrl,
                ipAddress: (string) $request->ip(),
                userAgent: (string) $request->userAgent(),
            );

            $order = $this->orderLifecycleService->confirmDelivery($dto);

            return $this->successResponse(
                data: [
                    'order_id' => $order->id,
                    'status' => $order->status->value,
                    'delivered_at' => $order->delivered_at?->toIso8601String(),
                    'earnings_credited' => (float) $order->total_rider_payout,
                    'cod_collected' => $order->payment_mode->value === 'cod'
                        ? (float) $order->cod_amount
                        : 0.00,
                ],
                message: 'Delivery completed successfully.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_DELIVERY_CONFIRMATION_FAILED'
            );
        }
    }
}
