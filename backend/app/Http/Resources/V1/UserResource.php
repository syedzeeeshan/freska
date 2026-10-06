<?php

declare(strict_types=1);

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $profile = $this->riderProfile;

        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'avatar_url' => $this->avatar_url,
            'role' => $this->role->value ?? (string) $this->role,
            'status' => $this->status->value ?? (string) $this->status,
            'kyc_status' => $profile?->kyc_status?->value ?? 'pending',
            'is_online' => (bool) ($profile?->is_online ?? false),
            'rating_average' => (float) ($profile?->rating_average ?? 5.0),
            'completed_deliveries_count' => (int) ($profile?->completed_deliveries_count ?? 0),
            'tier' => $profile?->tier ?? 'bronze',
            'phone_verified' => $this->phone_verified_at !== null,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
