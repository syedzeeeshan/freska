<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Order;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property \App\Models\OrderAssignmentOffer $resource
 */
class OrderOfferResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $order = $this->resource->order;
        $now = now();
        $remainingSeconds = max(0, $now->diffInSeconds($this->resource->expires_at, false));

        return [
            'id' => $this->resource->id,
            'order_id' => $this->resource->order_id,
            'order_number' => $order->order_number,
            'vendor_name' => $order->vendor->name,
            'vendor_address' => $order->vendor->address,
            'vendor_latitude' => (float) $order->vendor->latitude,
            'vendor_longitude' => (float) $order->vendor->longitude,
            'delivery_area' => $order->delivery_area,
            'estimated_distance_km' => (float) $order->estimated_distance_km,
            'estimated_duration_mins' => $order->estimated_duration_mins,
            'total_rider_payout' => (float) $order->total_rider_payout,
            'is_cold_chain' => (bool) $order->is_cold_chain,
            'is_fragile' => (bool) $order->is_fragile,
            'item_count' => $order->item_count,
            'payment_mode' => $order->payment_mode->value,
            'cod_amount' => (float) $order->cod_amount,
            'offered_at' => $this->resource->offered_at->toIso8601String(),
            'expires_at' => $this->resource->expires_at->toIso8601String(),
            'remaining_seconds' => $remainingSeconds,
        ];
    }
}
