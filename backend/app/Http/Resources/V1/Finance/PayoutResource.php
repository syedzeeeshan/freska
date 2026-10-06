<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Finance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PayoutResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'payout_number' => $this->payout_number,
            'period_start' => $this->period_start->format('Y-m-d'),
            'period_end' => $this->period_end->format('Y-m-d'),
            'deliveries_count' => $this->deliveries_count,
            'base_amount' => (float) $this->base_amount,
            'incentives_amount' => (float) $this->incentives_amount,
            'tips_amount' => (float) $this->tips_amount,
            'deductions_amount' => (float) $this->deductions_amount,
            'net_payout_amount' => (float) $this->net_payout_amount,
            'bank_reference_number' => $this->bank_reference_number,
            'payment_method' => $this->payment_method->value,
            'status' => $this->status->value,
            'processed_at' => $this->processed_at?->toIso8601String(),
            'failure_reason' => $this->failure_reason,
        ];
    }
}
