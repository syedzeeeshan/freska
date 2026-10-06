<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Finance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EarningsSummaryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'today_earnings' => (float) ($this['today_earnings'] ?? 0.0),
            'today_deliveries' => (int) ($this['today_deliveries'] ?? 0),
            'this_week_earnings' => (float) ($this['this_week_earnings'] ?? 0.0),
            'this_week_deliveries' => (int) ($this['this_week_deliveries'] ?? 0),
            'surge_bonus' => (float) ($this['surge_bonus'] ?? 0.0),
            'tips_total' => (float) ($this['tips_total'] ?? 0.0),
            'milestone_progress_percentage' => (float) ($this['milestone_progress_percentage'] ?? 0.0),
        ];
    }
}
