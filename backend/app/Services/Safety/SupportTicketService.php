<?php

declare(strict_types=1);

namespace App\Services\Safety;

use App\DTOs\Safety\CreateSupportTicketDTO;
use App\Enums\SupportCategory;
use App\Enums\SupportPriority;
use App\Enums\SupportStatus;
use App\Interfaces\Repositories\SupportTicketRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\SupportTicket;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class SupportTicketService
{
    public function __construct(
        private readonly SupportTicketRepositoryInterface $ticketRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    public function createTicket(CreateSupportTicketDTO $dto): SupportTicket
    {
        $attachmentUrl = null;
        if ($dto->attachment) {
            $attachmentUrl = $this->storageService->uploadKycDocument(
                $dto->attachment,
                $dto->riderId,
                'ticket_attachment_' . time()
            );
        }

        return $this->ticketRepository->createTicket([
            'rider_id' => $dto->riderId,
            'order_id' => $dto->orderId,
            'category' => SupportCategory::from($dto->category),
            'subject' => $dto->subject,
            'description' => $dto->description,
            'priority' => SupportPriority::from($dto->priority),
            'status' => SupportStatus::OPEN,
            'attachment_url' => $attachmentUrl,
        ]);
    }

    public function getRiderTickets(int $riderId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->ticketRepository->getRiderTickets($riderId, $perPage);
    }

    public function getTicketDetails(int $ticketId, int $riderId): ?SupportTicket
    {
        return $this->ticketRepository->findById($ticketId, $riderId);
    }
}
