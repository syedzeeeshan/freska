<?php

declare(strict_types=1);

namespace App\Services\Order;

use App\DTOs\Order\ConfirmDeliveryDTO;
use App\DTOs\Order\OrderLifecycleDTO;
use App\Enums\OrderStatus;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\AuditLog;
use App\Models\Order;
use DomainException;
use Illuminate\Http\UploadedFile;

class OrderLifecycleService
{
    public function __construct(
        private readonly OrderRepositoryInterface $orderRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    public function arriveAtVendor(OrderLifecycleDTO $dto): Order
    {
        $order = $this->orderRepository->markArrivedAtVendor(
            $dto->orderId,
            $dto->userId,
            $dto->latitude,
            $dto->longitude
        );

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'order.arrived_vendor',
            'entity_type' => Order::class,
            'entity_id' => $order->id,
            'new_values' => [
                'status' => $order->status->value,
                'arrived_vendor_at' => $order->arrived_vendor_at?->toIso8601String(),
                'rider_latitude' => $dto->latitude,
                'rider_longitude' => $dto->longitude,
            ],
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $order;
    }

    public function pickupOrder(
        OrderLifecycleDTO $dto,
        bool $packageVerified
    ): Order {
        if (!$packageVerified) {
            throw new DomainException('Package checklist must be fully verified before confirming pickup.');
        }

        $order = $this->orderRepository->markPickedUp(
            $dto->orderId,
            $dto->userId,
            $dto->latitude,
            $dto->longitude
        );

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'order.picked_up',
            'entity_type' => Order::class,
            'entity_id' => $order->id,
            'new_values' => [
                'status' => $order->status->value,
                'picked_up_at' => $order->picked_up_at?->toIso8601String(),
                'rider_latitude' => $dto->latitude,
                'rider_longitude' => $dto->longitude,
            ],
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $order;
    }

    public function arriveAtCustomer(OrderLifecycleDTO $dto): Order
    {
        $order = $this->orderRepository->markArrivedAtCustomer(
            $dto->orderId,
            $dto->userId,
            $dto->latitude,
            $dto->longitude
        );

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'order.arrived_customer',
            'entity_type' => Order::class,
            'entity_id' => $order->id,
            'new_values' => [
                'status' => $order->status->value,
                'rider_latitude' => $dto->latitude,
                'rider_longitude' => $dto->longitude,
            ],
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $order;
    }

    public function confirmDelivery(ConfirmDeliveryDTO $dto): Order
    {
        // Verify OTP
        $isValidOtp = $this->orderRepository->verifyDeliveryOtp($dto->orderId, $dto->otp);

        if (!$isValidOtp) {
            throw new DomainException('Invalid delivery OTP. Please confirm the 4-digit code with the customer.');
        }

        /** @var array<string, string|null> $deliveryData */
        $deliveryData = [
            'proof_photo_url' => $dto->proofPhotoPath,
            'signature_url' => $dto->signaturePath,
        ];

        $order = $this->orderRepository->confirmDelivery(
            $dto->orderId,
            $dto->userId,
            $deliveryData
        );

        AuditLog::create([
            'user_id' => $dto->userId,
            'action' => 'order.delivered',
            'entity_type' => Order::class,
            'entity_id' => $order->id,
            'new_values' => [
                'status' => $order->status->value,
                'delivered_at' => $order->delivered_at?->toIso8601String(),
                'earnings_credited' => $order->total_rider_payout,
                'has_proof_photo' => $dto->proofPhotoPath !== null,
                'has_signature' => $dto->signaturePath !== null,
            ],
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
        ]);

        return $order;
    }

    public function uploadProofOfDelivery(UploadedFile $file, int $orderId): string
    {
        return $this->storageService->uploadProofOfDelivery($file, $orderId);
    }
}
