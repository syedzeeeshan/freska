<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Interfaces\Repositories\SupportTicketRepositoryInterface;
use App\Models\SupportTicket;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class SupportTicketRepository implements SupportTicketRepositoryInterface
{
    public function createTicket(array $data): SupportTicket
    {
        $ticketNumber = 'TCK-' . date('Y') . '-' . strtoupper(bin2hex(random_bytes(3)));

        return SupportTicket::create(array_merge($data, [
            'ticket_number' => $ticketNumber,
        ]));
    }

    public function getRiderTickets(int $riderId, int $perPage = 15): LengthAwarePaginator
    {
        return SupportTicket::query()
            ->with(['order'])
            ->where('rider_id', $riderId)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function findById(int $ticketId, int $riderId): ?SupportTicket
    {
        return SupportTicket::query()
            ->with(['order', 'assignedAgent'])
            ->where('rider_id', $riderId)
            ->find($ticketId);
    }
}
