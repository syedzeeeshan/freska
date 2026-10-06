<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Finance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CodSummaryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'current_cash_in_hand' => (float) ($this['current_cash_in_hand'] ?? 0.0),
            'max_cash_limit' => (float) ($this['max_cash_limit'] ?? 5000.0),
            'pending_settlement_count' => (int) ($this['pending_settlement_count'] ?? 0),
            'is_blocked_from_assignments' => (bool) ($this['is_blocked_from_assignments'] ?? false),
            'headroom_available' => max(0.0, (float) ($this['max_cash_limit'] ?? 5000.0) - (float) ($this['current_cash_in_hand'] ?? 0.0)),
        ];
    }
}
