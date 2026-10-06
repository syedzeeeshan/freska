<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\RiderEarning;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

interface EarningsRepositoryInterface
{
    /**
     * @return array{today_earnings: float, today_deliveries: int, this_week_earnings: float, this_week_deliveries: int, surge_bonus: float, tips_total: float, milestone_progress_percentage: float}
     */
    public function getEarningsSummary(int $riderId): array;

    /**
     * @return LengthAwarePaginator<RiderEarning>
     */
    public function getEarningsHistory(int $riderId, int $perPage = 20): LengthAwarePaginator;

    /**
     * @return Collection<int, array{day: string, date: string, amount: float, count: int}>
     */
    public function getWeeklyDailyBreakdown(int $riderId): Collection;
}
