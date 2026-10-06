<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Safety;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class IncidentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'incident_number' => $this->incident_number,
            'type' => $this->type->value,
            'order_id' => $this->order_id,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            'location_address' => $this->location_address,
            'description' => $this->description,
            'media_urls' => $this->media_urls ?? [],
            'medical_assistance_needed' => (bool) $this->medical_assistance_needed,
            'status' => $this->status->value,
            'acknowledged_at' => $this->acknowledged_at?->toIso8601String(),
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
