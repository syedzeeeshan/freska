<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Enums\OfferStatus;
use App\Enums\OrderStatus;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Models\Order;
use App\Models\OrderAssignmentOffer;
use App\Models\RiderEarning;
use Carbon\Carbon;
use DomainException;
use Illuminate\Support\Facades\DB;

class OrderRepository implements OrderRepositoryInterface
{
    public function getActiveOrderForRider(int $riderId): ?Order
    {
        return Order::with(['vendor'])
            ->where('rider_id', $riderId)
            ->whereIn('status', [
                OrderStatus::ACCEPTED->value,
                OrderStatus::ARRIVED_VENDOR->value,
                OrderStatus::PICKED_UP->value,
                OrderStatus::IN_TRANSIT->value,
                OrderStatus::ARRIVED_CUSTOMER->value,
            ])
            ->latest('assignment_accepted_at')
            ->first();
    }

    public function getPendingOfferForRider(int $riderId): ?OrderAssignmentOffer
    {
        return OrderAssignmentOffer::with(['order.vendor'])
            ->where('rider_id', $riderId)
            ->where('status', OfferStatus::OFFERED->value)
            ->where('expires_at', '>', now())
            ->latest('offered_at')
            ->first();
    }

    public function findOrderById(int $orderId): ?Order
    {
        return Order::with(['vendor'])->find($orderId);
    }

    public function findOfferById(int $offerId): ?OrderAssignmentOffer
    {
        return OrderAssignmentOffer::with(['order.vendor'])->find($offerId);
    }

    public function findOfferForRider(int $orderId, int $riderId): ?OrderAssignmentOffer
    {
        return OrderAssignmentOffer::with(['order.vendor'])
            ->where('order_id', $orderId)
            ->where('rider_id', $riderId)
            ->latest()
            ->first();
    }

    public function acceptOffer(int $orderId, int $riderId, float $latitude, float $longitude): Order
    {
        return DB::transaction(function () use ($orderId, $riderId) {
            /** @var Order|null $order */
            $order = Order::lockForUpdate()->find($orderId);

            if (!$order) {
                throw new DomainException('Order not found.');
            }

            if ($order->rider_id !== null && $order->rider_id !== $riderId) {
                throw new DomainException('Order has already been assigned to another partner.');
            }

            /** @var OrderAssignmentOffer|null $offer */
            $offer = OrderAssignmentOffer::where('order_id', $orderId)
                ->where('rider_id', $riderId)
                ->where('status', OfferStatus::OFFERED->value)
                ->lockForUpdate()
                ->first();

            if (!$offer || $offer->expires_at->isPast()) {
                if ($offer) {
                    $offer->update([
                        'status' => OfferStatus::EXPIRED->value,
                        'response_timestamp' => now(),
                    ]);
                }
                throw new DomainException('This delivery assignment offer has expired.');
            }

            // Accept offer
            $offer->update([
                'status' => OfferStatus::ACCEPTED->value,
                'response_timestamp' => now(),
            ]);

            // Expire any other offers for this order
            OrderAssignmentOffer::where('order_id', $orderId)
                ->where('id', '!=', $offer->id)
                ->where('status', OfferStatus::OFFERED->value)
                ->update([
                    'status' => OfferStatus::EXPIRED->value,
                    'response_timestamp' => now(),
                ]);

            // Update order
            $order->update([
                'rider_id' => $riderId,
                'status' => OrderStatus::ACCEPTED->value,
                'assignment_accepted_at' => now(),
            ]);

            return $order->fresh(['vendor']);
        });
    }

    public function rejectOffer(int $orderId, int $riderId, string $reason): void
    {
        DB::transaction(function () use ($orderId, $riderId, $reason) {
            $offer = OrderAssignmentOffer::where('order_id', $orderId)
                ->where('rider_id', $riderId)
                ->where('status', OfferStatus::OFFERED->value)
                ->lockForUpdate()
                ->first();

            if ($offer) {
                $offer->update([
                    'status' => OfferStatus::REJECTED->value,
                    'rejection_reason' => $reason,
                    'response_timestamp' => now(),
                ]);
            }

            /** @var Order|null $order */
            $order = Order::find($orderId);
            if ($order && $order->rider_id === $riderId) {
                $order->update([
                    'rider_id' => null,
                    'status' => OrderStatus::DISPATCHED->value,
                ]);
            }
        });
    }

    public function expireOffer(int $offerId): void
    {
        OrderAssignmentOffer::where('id', $offerId)
            ->where('status', OfferStatus::OFFERED->value)
            ->update([
                'status' => OfferStatus::EXPIRED->value,
                'response_timestamp' => now(),
            ]);
    }

    public function createOffer(int $orderId, int $riderId, int $ttlSeconds = 30): OrderAssignmentOffer
    {
        $offer = OrderAssignmentOffer::create([
            'order_id' => $orderId,
            'rider_id' => $riderId,
            'offered_at' => now(),
            'expires_at' => now()->addSeconds($ttlSeconds),
            'status' => OfferStatus::OFFERED->value,
        ]);

        Order::where('id', $orderId)->update([
            'status' => OrderStatus::OFFERED->value,
            'assignment_offered_at' => now(),
        ]);

        return $offer->fresh(['order.vendor']);
    }

    public function getTodayCompletedDeliveriesCount(int $riderId): int
    {
        return Order::where('rider_id', $riderId)
            ->where('status', OrderStatus::DELIVERED->value)
            ->whereDate('delivered_at', Carbon::today())
            ->count();
    }

    public function getTodayEarningsSum(int $riderId): float
    {
        $earningsFromLedger = (float) RiderEarning::where('rider_id', $riderId)
            ->whereDate('date', Carbon::today())
            ->sum('amount');

        if ($earningsFromLedger > 0) {
            return $earningsFromLedger;
        }

        // Fallback to sum of total_rider_payout for today's delivered orders
        return (float) Order::where('rider_id', $riderId)
            ->where('status', OrderStatus::DELIVERED->value)
            ->whereDate('delivered_at', Carbon::today())
            ->sum('total_rider_payout');
    }

    public function markArrivedAtVendor(int $orderId, int $riderId, float $latitude, float $longitude): Order
    {
        return DB::transaction(function () use ($orderId, $riderId) {
            /** @var Order $order */
            $order = Order::lockForUpdate()->findOrFail($orderId);

            if ($order->rider_id !== $riderId) {
                throw new DomainException('You are not assigned to this order.');
            }

            if ($order->status !== OrderStatus::ACCEPTED) {
                throw new DomainException("Cannot mark arrival: order is currently in '{$order->status->label()}' status.");
            }

            $order->update([
                'status' => OrderStatus::ARRIVED_VENDOR->value,
                'arrived_vendor_at' => now(),
            ]);

            return $order->fresh(['vendor']);
        });
    }

    public function markPickedUp(int $orderId, int $riderId, float $latitude, float $longitude): Order
    {
        return DB::transaction(function () use ($orderId, $riderId) {
            /** @var Order $order */
            $order = Order::lockForUpdate()->findOrFail($orderId);

            if ($order->rider_id !== $riderId) {
                throw new DomainException('You are not assigned to this order.');
            }

            if ($order->status !== OrderStatus::ARRIVED_VENDOR) {
                throw new DomainException("Cannot confirm pickup: you must first mark arrival at the vendor store.");
            }

            $order->update([
                'status' => OrderStatus::IN_TRANSIT->value,
                'picked_up_at' => now(),
            ]);

            return $order->fresh(['vendor']);
        });
    }

    public function markArrivedAtCustomer(int $orderId, int $riderId, float $latitude, float $longitude): Order
    {
        return DB::transaction(function () use ($orderId, $riderId) {
            /** @var Order $order */
            $order = Order::lockForUpdate()->findOrFail($orderId);

            if ($order->rider_id !== $riderId) {
                throw new DomainException('You are not assigned to this order.');
            }

            if ($order->status !== OrderStatus::IN_TRANSIT) {
                throw new DomainException("Cannot mark customer arrival: order must be in 'In Transit' status.");
            }

            $order->update([
                'status' => OrderStatus::ARRIVED_CUSTOMER->value,
            ]);

            return $order->fresh(['vendor']);
        });
    }

    /**
     * @param array<string, mixed> $deliveryData
     */
    public function confirmDelivery(int $orderId, int $riderId, array $deliveryData): Order
    {
        return DB::transaction(function () use ($orderId, $riderId, $deliveryData) {
            /** @var Order $order */
            $order = Order::lockForUpdate()->findOrFail($orderId);

            if ($order->rider_id !== $riderId) {
                throw new DomainException('You are not assigned to this order.');
            }

            if ($order->status !== OrderStatus::ARRIVED_CUSTOMER) {
                throw new DomainException("Cannot confirm delivery: rider must arrive at the customer location first.");
            }

            $updateData = [
                'status' => OrderStatus::DELIVERED->value,
                'delivered_at' => now(),
                'delivery_proof_photo_url' => $deliveryData['proof_photo_url'] ?? null,
                'delivery_signature_url' => $deliveryData['signature_url'] ?? null,
            ];

            if ($order->payment_mode->value === 'cod') {
                $updateData['is_cod_collected'] = true;
                $updateData['cod_collected_at'] = now();
            }

            $order->update($updateData);

            // Credit earnings ledger entry
            RiderEarning::create([
                'rider_id' => $riderId,
                'order_id' => $orderId,
                'earning_type' => 'delivery_fee',
                'amount' => $order->total_rider_payout,
                'description' => "Delivery fee for order #{$order->order_number}",
                'date' => now()->toDateString(),
                'status' => 'pending',
            ]);

            return $order->fresh(['vendor']);
        });
    }

    public function generateDeliveryOtp(int $orderId): string
    {
        $otp = (string) random_int(1000, 9999);

        Order::where('id', $orderId)->update([
            'delivery_otp' => $otp,
        ]);

        return $otp;
    }

    public function verifyDeliveryOtp(int $orderId, string $otp): bool
    {
        $order = Order::where('id', $orderId)->first();

        if (!$order) {
            return false;
        }

        return $order->delivery_otp === $otp;
    }
}

