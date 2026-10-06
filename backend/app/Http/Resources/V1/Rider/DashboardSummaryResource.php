<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Rider;

use App\Http\Resources\V1\Order\ActiveOrderResource;
use App\Http\Resources\V1\Order\OrderOfferResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardSummaryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var array<string, mixed> $data */
        $data = $this->resource;

        return [
            'is_online' => (bool) ($data['is_online'] ?? false),
            'last_location_updated_at' => $data['last_location_updated_at'] ?? null,
            'current_latitude' => $data['current_latitude'] ?? null,
            'current_longitude' => $data['current_longitude'] ?? null,
            'metrics' => [
                'today_earnings' => (float) ($data['metrics']['today_earnings'] ?? 0.00),
                'today_deliveries_count' => (int) ($data['metrics']['today_deliveries_count'] ?? 0),
                'today_online_hours' => (float) ($data['metrics']['today_online_hours'] ?? 0.0),
                'acceptance_rate' => (float) ($data['metrics']['acceptance_rate'] ?? 100.0),
                'rating_average' => (float) ($data['metrics']['rating_average'] ?? 5.0),
                'current_cash_in_hand' => (float) ($data['metrics']['current_cash_in_hand'] ?? 0.00),
                'max_cash_limit' => (float) ($data['metrics']['max_cash_limit'] ?? 5000.00),
            ],
            'has_active_order' => (bool) ($data['has_active_order'] ?? false),
            'active_order' => isset($data['active_order']) && $data['active_order'] !== null
                ? new ActiveOrderResource($data['active_order'])
                : null,
            'has_pending_offer' => (bool) ($data['has_pending_offer'] ?? false),
            'pending_offer' => isset($data['pending_offer']) && $data['pending_offer'] !== null
                ? $data['pending_offer']
                : null,
        ];
    }
}
