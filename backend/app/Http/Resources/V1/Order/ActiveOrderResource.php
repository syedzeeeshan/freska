<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Order;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property \App\Models\Order $resource
 */
class ActiveOrderResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $isPickedUp = $this->resource->isPickedUp();

        return [
            'id' => $this->resource->id,
            'order_number' => $this->resource->order_number,
            'status' => $this->resource->status->value,
            'order_type' => $this->resource->order_type->value,
            'vendor' => new VendorResource($this->resource->vendor),
            'customer' => [
                'name' => $this->resource->customer_name,
                'phone' => $isPickedUp
                    ? $this->resource->customer_phone
                    : 'Masked proxy: ' . substr($this->resource->customer_phone, -4),
                'delivery_area' => $this->resource->delivery_area,
                'delivery_address' => $isPickedUp
                    ? $this->resource->delivery_address
                    : 'Masked until picked up',
                'delivery_latitude' => (float) $this->resource->delivery_latitude,
                'delivery_longitude' => (float) $this->resource->delivery_longitude,
                'delivery_instructions' => $this->resource->delivery_instructions,
            ],
            'package_details' => [
                'item_count' => $this->resource->item_count,
                'is_fragile' => (bool) $this->resource->is_fragile,
                'is_cold_chain' => (bool) $this->resource->is_cold_chain,
                'items' => $this->resource->package_details ?? [],
            ],
            'payment_mode' => $this->resource->payment_mode->value,
            'cod_amount' => (float) $this->resource->cod_amount,
            'is_cod_collected' => (bool) $this->resource->is_cod_collected,
            'estimated_distance_km' => (float) $this->resource->estimated_distance_km,
            'estimated_duration_mins' => $this->resource->estimated_duration_mins,
            'base_payout' => (float) $this->resource->base_payout,
            'distance_payout' => (float) $this->resource->distance_payout,
            'surge_payout' => (float) $this->resource->surge_payout,
            'tip_amount' => (float) $this->resource->tip_amount,
            'total_rider_payout' => (float) $this->resource->total_rider_payout,
            'assignment_accepted_at' => $this->resource->assignment_accepted_at?->toIso8601String(),
            'arrived_vendor_at' => $this->resource->arrived_vendor_at?->toIso8601String(),
            'picked_up_at' => $this->resource->picked_up_at?->toIso8601String(),
        ];
    }
}
