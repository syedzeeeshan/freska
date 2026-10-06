<?php

declare(strict_types=1);

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KycStatusResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'kyc_status' => $this['kyc_status'] ?? 'pending',
            'rejection_reason' => $this['rejection_reason'] ?? null,
            'reviewed_at' => $this['reviewed_at'] ?? null,
            'vehicle_number' => $this['vehicle_number'] ?? null,
            'license_number' => $this['license_number'] ?? null,
        ];
    }
}
