<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\Notification;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface NotificationRepositoryInterface
{
    /**
     * @return LengthAwarePaginator<Notification>
     */
    public function getNotificationsForUser(int $userId, int $perPage = 20): LengthAwarePaginator;

    public function markAsRead(int $notificationId, int $userId): bool;

    public function markAllAsRead(int $userId): int;

    public function getUnreadCount(int $userId): int;
}
