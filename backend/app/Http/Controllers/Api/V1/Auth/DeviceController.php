<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\DeviceResource;
use App\Interfaces\Repositories\DeviceRepositoryInterface;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly DeviceRepositoryInterface $deviceRepository
    ) {}

    /**
     * List all registered devices for the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $devices = $this->deviceRepository->getActiveDevicesForUser((int) $request->user()->id);

        return $this->successResponse(
            data: DeviceResource::collection($devices),
            message: 'Active devices retrieved successfully.'
        );
    }

    /**
     * Deactivate a specific hardware device session.
     */
    public function deactivate(Request $request, string $deviceId): JsonResponse
    {
        $user = $request->user();
        $device = $this->deviceRepository->findByDeviceId($deviceId);

        if (!$device || $device->user_id !== $user->id) {
            return $this->errorResponse(
                message: 'Device not found or does not belong to user.',
                errorCode: 'ERR_DEVICE_NOT_FOUND',
                statusCode: 404
            );
        }

        $this->deviceRepository->deactivateDevice($deviceId);

        return $this->successResponse(
            message: 'Device session deactivated successfully.'
        );
    }
}
