<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\CodCollection;
use Illuminate\Support\Collection;

interface CodRepositoryInterface
{
    /**
     * @return array{current_cash_in_hand: float, max_cash_limit: float, pending_settlement_count: int, is_blocked_from_assignments: bool}
     */
    public function getCodSummary(int $riderId): array;

    /**
     * @return Collection<int, CodCollection>
     */
    public function getPendingCodOrders(int $riderId): Collection;

    /**
     * @param array<string, mixed> $data
     */
    public function submitHandover(int $riderId, array $data): CodCollection;
}
