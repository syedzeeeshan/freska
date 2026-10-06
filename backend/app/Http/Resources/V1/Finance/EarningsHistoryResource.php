<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Finance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EarningsHistoryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'order_number' => $this->order?->order_number,
            'earning_type' => $this->earning_type,
            'amount' => (float) $this->amount,
            'description' => $this->description,
            'date' => $this->date->format('Y-m-d'),
            'status' => $this->status,
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
