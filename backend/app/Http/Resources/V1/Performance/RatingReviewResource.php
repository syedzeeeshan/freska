<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Performance;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RatingReviewResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'order_number' => $this->order?->order_number,
            'rating' => $this->rating,
            'badges' => $this->badges ?? [],
            'feedback_comment' => $this->feedback_comment,
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
