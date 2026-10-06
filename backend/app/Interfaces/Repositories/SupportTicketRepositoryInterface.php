<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\SupportTicket;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface SupportTicketRepositoryInterface
{
    /**
     * @param array<string, mixed> $data
     */
    public function createTicket(array $data): SupportTicket;

    /**
     * @return LengthAwarePaginator<SupportTicket>
     */
    public function getRiderTickets(int $riderId, int $perPage = 15): LengthAwarePaginator;

    public function findById(int $ticketId, int $riderId): ?SupportTicket;
}
