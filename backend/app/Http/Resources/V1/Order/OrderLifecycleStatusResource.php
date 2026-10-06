<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Order;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property \App\Models\Order $resource
 */
class OrderLifecycleStatusResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'order_id' => $this->resource->id,
            'order_number' => $this->resource->order_number,
            'status' => $this->resource->status->value,
            'status_label' => $this->resource->status->label(),
            'arrived_vendor_at' => $this->resource->arrived_vendor_at?->toIso8601String(),
            'picked_up_at' => $this->resource->picked_up_at?->toIso8601String(),
            'delivered_at' => $this->resource->delivered_at?->toIso8601String(),
        ];
    }
}
