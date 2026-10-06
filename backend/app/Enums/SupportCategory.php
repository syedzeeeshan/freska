<?php

declare(strict_types=1);

namespace App\Enums;

enum SupportCategory: string
{
    case CUSTOMER_ISSUE = 'customer_issue';
    case VENDOR_PICKUP_ISSUE = 'vendor_pickup_issue';
    case PAYMENT_PAYOUT_ISSUE = 'payment_payout_issue';
    case EMERGENCY_SUPPORT = 'emergency_support';
    case APP_TECHNICAL_ISSUE = 'app_technical_issue';
    case OTHER = 'other';
}
