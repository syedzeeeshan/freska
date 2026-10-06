<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Finance;

use App\DTOs\Finance\SubmitCodHandoverDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Finance\SubmitCodHandoverRequest;
use App\Http\Resources\V1\Finance\CodSummaryResource;
use App\Interfaces\Repositories\CodRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Traits\ApiResponseTrait;
use DomainException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CodController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly CodRepositoryInterface $codRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    public function summary(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $summary = $this->codRepository->getCodSummary($userId);

        return $this->successResponse(
            data: (new CodSummaryResource($summary))->resolve($request),
            message: 'COD summary retrieved.'
        );
    }

    public function pendingOrders(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $orders = $this->codRepository->getPendingCodOrders($userId);

        return $this->successResponse(
            data: $orders->map(function ($item) {
                return [
                    'id' => $item->id,
                    'order_id' => $item->order_id,
                    'order_number' => $item->order?->order_number,
                    'vendor_name' => $item->order?->vendor?->name,
                    'amount' => (float) $item->amount,
                    'collected_at' => $item->collected_at->toIso8601String(),
                    'handover_status' => $item->handover_status->value,
                ];
            }),
            message: 'Pending COD collections retrieved.'
        );
    }

    public function handover(SubmitCodHandoverRequest $request): JsonResponse
    {
        try {
            $dto = SubmitCodHandoverDTO::fromRequest($request);
            $receiptUrl = null;

            if ($dto->receiptPhoto) {
                $receiptUrl = $this->storageService->uploadKycDocument(
                    $dto->receiptPhoto,
                    $dto->riderId,
                    'cod_receipt_' . time()
                );
            }

            $collection = $this->codRepository->submitHandover($dto->riderId, [
                'amount' => $dto->amount,
                'handover_method' => $dto->handoverMethod,
                'handover_reference' => $dto->handoverReference,
                'receipt_url' => $receiptUrl,
                'order_id' => $dto->orderId,
            ]);

            return $this->successResponse(
                data: [
                    'id' => $collection->id,
                    'amount' => (float) $collection->amount,
                    'handover_status' => $collection->handover_status->value,
                    'submitted_at' => $collection->submitted_at?->toIso8601String(),
                ],
                message: 'COD remittance submitted for reconciliation.'
            );
        } catch (DomainException $e) {
            return $this->errorResponse(
                message: $e->getMessage(),
                statusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
                errorCode: 'ERR_COD_HANDOVER_FAILED'
            );
        }
    }
}
