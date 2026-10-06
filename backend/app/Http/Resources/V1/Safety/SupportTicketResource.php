<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Safety;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupportTicketResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'ticket_number' => $this->ticket_number,
            'category' => $this->category->value,
            'subject' => $this->subject,
            'description' => $this->description,
            'priority' => $this->priority->value,
            'status' => $this->status->value,
            'attachment_url' => $this->attachment_url,
            'order_id' => $this->order_id,
            'order_number' => $this->order?->order_number,
            'resolution_notes' => $this->resolution_notes,
            'resolved_at' => $this->resolved_at?->toIso8601String(),
            'created_at' => $this->created_at->toIso8601String(),
        ];
    }
}
