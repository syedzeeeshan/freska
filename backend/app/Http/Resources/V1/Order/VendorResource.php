<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Order;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property \App\Models\Vendor $resource
 */
class VendorResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->resource->id,
            'name' => $this->resource->name,
            'store_code' => $this->resource->store_code,
            'phone' => $this->resource->phone,
            'address' => $this->resource->address,
            'landmark' => $this->resource->landmark,
            'latitude' => (float) $this->resource->latitude,
            'longitude' => (float) $this->resource->longitude,
            'pickup_instructions' => $this->resource->pickup_instructions,
        ];
    }
}
