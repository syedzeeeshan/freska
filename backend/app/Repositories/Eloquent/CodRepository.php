<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Enums\CodHandoverStatus;
use App\Interfaces\Repositories\CodRepositoryInterface;
use App\Models\AuditLog;
use App\Models\CodCollection;
use App\Models\RiderProfile;
use DomainException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class CodRepository implements CodRepositoryInterface
{
    public function getCodSummary(int $riderId): array
    {
        $profile = RiderProfile::where('user_id', $riderId)->first();

        $cashInHand = (float) ($profile?->current_cash_in_hand ?? 0.00);
        $maxLimit = (float) ($profile?->max_cash_limit ?? 5000.00);

        $pendingCount = CodCollection::query()
            ->where('rider_id', $riderId)
            ->where('handover_status', CodHandoverStatus::HELD_IN_HAND)
            ->count();

        return [
            'current_cash_in_hand' => $cashInHand,
            'max_cash_limit' => $maxLimit,
            'pending_settlement_count' => $pendingCount,
            'is_blocked_from_assignments' => $cashInHand >= $maxLimit,
        ];
    }

    public function getPendingCodOrders(int $riderId): Collection
    {
        return CodCollection::query()
            ->with(['order.vendor'])
            ->where('rider_id', $riderId)
            ->where('handover_status', CodHandoverStatus::HELD_IN_HAND)
            ->orderByDesc('collected_at')
            ->get();
    }

    public function submitHandover(int $riderId, array $data): CodCollection
    {
        return DB::transaction(function () use ($riderId, $data) {
            $profile = RiderProfile::query()->lockForUpdate()->where('user_id', $riderId)->first();

            if (!$profile || (float) $profile->current_cash_in_hand <= 0) {
                throw new DomainException('No pending cash in hand available for remittance.');
            }

            $amountToRemit = (float) ($data['amount'] ?? $profile->current_cash_in_hand);

            $collection = CodCollection::create([
                'order_id' => $data['order_id'] ?? null,
                'rider_id' => $riderId,
                'amount' => $amountToRemit,
                'collected_at' => now(),
                'handover_status' => CodHandoverStatus::SUBMITTED,
                'handover_method' => $data['handover_method'],
                'handover_reference' => $data['handover_reference'] ?? null,
                'handover_receipt_url' => $data['receipt_url'] ?? null,
                'submitted_at' => now(),
            ]);

            // Deduct cash from running balance
            $newBalance = max(0.0, (float) $profile->current_cash_in_hand - $amountToRemit);
            $profile->update(['current_cash_in_hand' => $newBalance]);

            // Audit Trail
            AuditLog::create([
                'user_id' => $riderId,
                'action' => 'COD_REMITTANCE_SUBMITTED',
                'metadata' => [
                    'amount' => $amountToRemit,
                    'method' => $data['handover_method'],
                    'reference' => $data['handover_reference'] ?? null,
                    'remaining_cash_in_hand' => $newBalance,
                ],
            ]);

            return $collection;
        });
    }
}
