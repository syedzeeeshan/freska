<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Enums\EarningType;
use App\Interfaces\Repositories\EarningsRepositoryInterface;
use App\Models\Order;
use App\Models\RiderEarning;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class EarningsRepository implements EarningsRepositoryInterface
{
    public function getEarningsSummary(int $riderId): array
    {
        $today = Carbon::today();
        $startOfWeek = Carbon::now()->startOfWeek();

        $todayEarnings = (float) RiderEarning::query()
            ->where('rider_id', $riderId)
            ->whereDate('date', $today)
            ->sum('amount');

        $todayDeliveries = Order::query()
            ->where('rider_id', $riderId)
            ->where('status', 'delivered')
            ->whereDate('delivered_at', $today)
            ->count();

        $thisWeekEarnings = (float) RiderEarning::query()
            ->where('rider_id', $riderId)
            ->whereBetween('date', [$startOfWeek->toDateString(), Carbon::now()->toDateString()])
            ->sum('amount');

        $thisWeekDeliveries = Order::query()
            ->where('rider_id', $riderId)
            ->where('status', 'delivered')
            ->whereBetween('delivered_at', [$startOfWeek, Carbon::now()])
            ->count();

        $surgeBonus = (float) RiderEarning::query()
            ->where('rider_id', $riderId)
            ->where('earning_type', EarningType::SURGE_BONUS->value)
            ->whereBetween('date', [$startOfWeek->toDateString(), Carbon::now()->toDateString()])
            ->sum('amount');

        $tipsTotal = (float) RiderEarning::query()
            ->where('rider_id', $riderId)
            ->where('earning_type', EarningType::CUSTOMER_TIP->value)
            ->whereBetween('date', [$startOfWeek->toDateString(), Carbon::now()->toDateString()])
            ->sum('amount');

        // Weekly 50-delivery milestone progress
        $milestoneTarget = 50;
        $progress = min(100.0, ($thisWeekDeliveries / $milestoneTarget) * 100);

        return [
            'today_earnings' => $todayEarnings,
            'today_deliveries' => $todayDeliveries,
            'this_week_earnings' => $thisWeekEarnings,
            'this_week_deliveries' => $thisWeekDeliveries,
            'surge_bonus' => $surgeBonus,
            'tips_total' => $tipsTotal,
            'milestone_progress_percentage' => round($progress, 1),
        ];
    }

    public function getEarningsHistory(int $riderId, int $perPage = 20): LengthAwarePaginator
    {
        return RiderEarning::query()
            ->with('order')
            ->where('rider_id', $riderId)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function getWeeklyDailyBreakdown(int $riderId): Collection
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $days = collect();

        for ($i = 0; $i < 7; $i++) {
            $currentDay = (clone $startOfWeek)->addDays($i);
            $dateStr = $currentDay->toDateString();

            $amount = (float) RiderEarning::query()
                ->where('rider_id', $riderId)
                ->whereDate('date', $dateStr)
                ->sum('amount');

            $count = Order::query()
                ->where('rider_id', $riderId)
                ->where('status', 'delivered')
                ->whereDate('delivered_at', $dateStr)
                ->count();

            $days->push([
                'day' => $currentDay->format('D'),
                'date' => $dateStr,
                'amount' => $amount,
                'count' => $count,
            ]);
        }

        return $days;
    }
}
