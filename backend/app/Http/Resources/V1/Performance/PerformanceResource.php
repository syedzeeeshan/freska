<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Performance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PerformanceResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'rating_average' => (float) ($this['rating_average'] ?? 5.0),
            'rating_count' => (int) ($this['rating_count'] ?? 0),
            'acceptance_rate' => (float) ($this['acceptance_rate'] ?? 100.0),
            'on_time_rate' => (float) ($this['on_time_rate'] ?? 100.0),
            'completed_deliveries_count' => (int) ($this['completed_deliveries_count'] ?? 0),
            'tier' => $this['tier'] ?? 'bronze',
            'tier_multiplier' => (float) ($this['tier_multiplier'] ?? 1.0),
            'next_tier' => $this['next_tier'],
            'deliveries_to_next_tier' => (int) ($this['deliveries_to_next_tier'] ?? 0),
            'tier_progress_percentage' => (float) ($this['tier_progress_percentage'] ?? 0.0),
            'top_compliments' => $this['top_compliments'] ?? [],
        ];
    }
}
