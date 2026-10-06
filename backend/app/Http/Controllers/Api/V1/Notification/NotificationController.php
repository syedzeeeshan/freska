<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Notification;

use App\DTOs\Notification\RegisterDeviceDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Notification\RegisterDeviceRequest;
use App\Http\Resources\V1\Notification\NotificationResource;
use App\Services\Notification\NotificationService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly NotificationService $notificationService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $perPage = (int) $request->query('per_page', 20);

        $notifications = $this->notificationService->getNotifications($userId, $perPage);
        $unreadCount = $this->notificationService->getUnreadCount($userId);

        return $this->successResponse(
            data: [
                'notifications' => NotificationResource::collection($notifications)->response()->getData(true),
                'unread_count' => $unreadCount,
            ],
            message: 'Notifications retrieved successfully.'
        );
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $this->notificationService->markAsRead($id, $userId);

        return $this->successResponse(
            data: null,
            message: 'Notification marked as read.'
        );
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $count = $this->notificationService->markAllAsRead($userId);

        return $this->successResponse(
            data: ['marked_count' => $count],
            message: 'All notifications marked as read.'
        );
    }

    public function registerDevice(RegisterDeviceRequest $request): JsonResponse
    {
        $dto = RegisterDeviceDTO::fromRequest($request);
        $device = $this->notificationService->registerDevice($dto);

        return $this->successResponse(
            data: [
                'device_id' => $device->device_id,
                'is_active' => (bool) $device->is_active,
                'registered_at' => $device->updated_at?->toIso8601String(),
            ],
            message: 'Device & FCM push token registered successfully.'
        );
    }
}
