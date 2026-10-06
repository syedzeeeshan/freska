<?php

declare(strict_types=1);

namespace App\DTOs\Finance;

use App\Http\Requests\V1\Finance\SubmitCodHandoverRequest;
use Illuminate\Http\UploadedFile;

readonly class SubmitCodHandoverDTO
{
    public function __construct(
        public int $riderId,
        public float $amount,
        public string $handoverMethod,
        public ?string $handoverReference = null,
        public ?UploadedFile $receiptPhoto = null,
        public ?int $orderId = null,
    ) {}

    public static function fromRequest(SubmitCodHandoverRequest $request): self
    {
        return new self(
            riderId: (int) $request->user()->id,
            amount: (float) $request->validated('amount'),
            handoverMethod: (string) $request->validated('handover_method'),
            handoverReference: $request->validated('handover_reference'),
            receiptPhoto: $request->file('receipt_photo'),
            orderId: $request->has('order_id') ? (int) $request->validated('order_id') : null,
        );
    }
}
