<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Interfaces\Repositories\NotificationRepositoryInterface;
use App\Models\Notification;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationRepository implements NotificationRepositoryInterface
{
    public function getNotificationsForUser(int $userId, int $perPage = 20): LengthAwarePaginator
    {
        return Notification::query()
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function markAsRead(int $notificationId, int $userId): bool
    {
        $notification = Notification::query()
            ->where('id', $notificationId)
            ->where('user_id', $userId)
            ->first();

        if ($notification && !$notification->is_read) {
            $notification->update([
                'is_read' => true,
                'read_at' => now(),
            ]);
            return true;
        }

        return false;
    }

    public function markAllAsRead(int $userId): int
    {
        return Notification::query()
            ->where('user_id', $userId)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);
    }

    public function getUnreadCount(int $userId): int
    {
        return Notification::query()
            ->where('user_id', $userId)
            ->where('is_read', false)
            ->count();
    }
}
