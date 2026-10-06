<?php

declare(strict_types=1);

namespace App\Enums;

enum NotificationType: string
{
    case ORDER_ASSIGNMENT = 'order_assignment';
    case PICKUP_REMINDER = 'pickup_reminder';
    case DELIVERY_UPDATE = 'delivery_update';
    case PAYOUT_CREDITED = 'payout_credited';
    case ANNOUNCEMENT = 'announcement';
    case SECURITY_ALERT = 'security_alert';
}
