<?php

declare(strict_types=1);

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RiderProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'vehicle_type' => $this->vehicle_type,
            'vehicle_number' => $this->vehicle_number,
            'license_number' => $this->license_number,
            'license_expiry' => $this->license_expiry?->toDateString(),
            'kyc_status' => $this->kyc_status?->value ?? 'pending',
            'bank_account_holder' => $this->bank_account_holder,
            'bank_name' => $this->bank_name,
            'bank_account_number' => $this->bank_account_number ? '••••' . substr((string) $this->bank_account_number, -4) : null,
            'bank_ifsc_code' => $this->bank_ifsc_code,
            'bank_upi_id' => $this->bank_upi_id,
            'bank_verified' => (bool) $this->bank_verified,
            'emergency_contact_name' => $this->emergency_contact_name,
            'emergency_contact_phone' => $this->emergency_contact_phone,
            'emergency_contact_relation' => $this->emergency_contact_relation,
            'is_online' => (bool) $this->is_online,
            'max_cash_limit' => (float) $this->max_cash_limit,
            'current_cash_in_hand' => (float) $this->current_cash_in_hand,
            'rating_average' => (float) $this->rating_average,
            'completed_deliveries_count' => (int) $this->completed_deliveries_count,
            'tier' => $this->tier ?? 'bronze',
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
