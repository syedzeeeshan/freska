<?php

declare(strict_types=1);

namespace App\DTOs\Safety;

use App\Http\Requests\V1\Safety\CreateSupportTicketRequest;
use Illuminate\Http\UploadedFile;

readonly class CreateSupportTicketDTO
{
    public function __construct(
        public int $riderId,
        public string $category,
        public string $subject,
        public string $description,
        public string $priority,
        public ?int $orderId = null,
        public ?UploadedFile $attachment = null,
    ) {}

    public static function fromRequest(CreateSupportTicketRequest $request): self
    {
        return new self(
            riderId: (int) $request->user()->id,
            category: (string) $request->validated('category'),
            subject: (string) $request->validated('subject'),
            description: (string) $request->validated('description'),
            priority: (string) $request->validated('priority', 'medium'),
            orderId: $request->has('order_id') ? (int) $request->validated('order_id') : null,
            attachment: $request->file('attachment'),
        );
    }
}
