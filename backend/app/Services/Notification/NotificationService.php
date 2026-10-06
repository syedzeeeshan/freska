<?php

declare(strict_types=1);

namespace App\Services\Notification;

use App\DTOs\Notification\RegisterDeviceDTO;
use App\Interfaces\Repositories\DeviceRepositoryInterface;
use App\Interfaces\Repositories\NotificationRepositoryInterface;
use App\Models\Device;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationService
{
    public function __construct(
        private readonly NotificationRepositoryInterface $notificationRepository,
        private readonly DeviceRepositoryInterface $deviceRepository,
    ) {}

    public function getNotifications(int $userId, int $perPage = 20): LengthAwarePaginator
    {
        return $this->notificationRepository->getNotificationsForUser($userId, $perPage);
    }

    public function getUnreadCount(int $userId): int
    {
        return $this->notificationRepository->getUnreadCount($userId);
    }

    public function markAsRead(int $notificationId, int $userId): bool
    {
        return $this->notificationRepository->markAsRead($notificationId, $userId);
    }

    public function markAllAsRead(int $userId): int
    {
        return $this->notificationRepository->markAllAsRead($userId);
    }

    public function registerDevice(RegisterDeviceDTO $dto): Device
    {
        return Device::updateOrCreate(
            ['device_id' => $dto->deviceId],
            [
                'user_id' => $dto->userId,
                'fcm_token' => $dto->fcmToken,
                'device_model' => $dto->deviceModel,
                'os_version' => $dto->osVersion,
                'app_version' => $dto->appVersion,
                'is_active' => true,
                'last_active_at' => now(),
            ]
        );
    }
}
