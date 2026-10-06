<?php

declare(strict_types=1);

namespace App\Enums;

enum OrderStatus: string
{
    case CREATED = 'created';
    case DISPATCHED = 'dispatched';
    case OFFERED = 'offered';
    case ACCEPTED = 'accepted';
    case ARRIVED_VENDOR = 'arrived_vendor';
    case PICKED_UP = 'picked_up';
    case IN_TRANSIT = 'in_transit';
    case ARRIVED_CUSTOMER = 'arrived_customer';
    case DELIVERED = 'delivered';
    case CANCELLED = 'cancelled';
    case REJECTED = 'rejected';
    case FAILED = 'failed';

    public function label(): string
    {
        return match ($this) {
            self::CREATED => 'Created',
            self::DISPATCHED => 'Dispatched',
            self::OFFERED => 'Offered',
            self::ACCEPTED => 'Accepted',
            self::ARRIVED_VENDOR => 'Arrived at Store',
            self::PICKED_UP => 'Picked Up',
            self::IN_TRANSIT => 'In Transit',
            self::ARRIVED_CUSTOMER => 'Arrived at Customer',
            self::DELIVERED => 'Delivered',
            self::CANCELLED => 'Cancelled',
            self::REJECTED => 'Rejected',
            self::FAILED => 'Failed',
        };
    }

    public function isActive(): bool
    {
        return in_array($this, [
            self::ACCEPTED,
            self::ARRIVED_VENDOR,
            self::PICKED_UP,
            self::IN_TRANSIT,
            self::ARRIVED_CUSTOMER,
        ], true);
    }
}
