<?php

declare(strict_types=1);

namespace App\Enums;

enum EarningType: string
{
    case DELIVERY_FEE = 'delivery_fee';
    case DISTANCE_BONUS = 'distance_bonus';
    case SURGE_BONUS = 'surge_bonus';
    case CUSTOMER_TIP = 'customer_tip';
    case DAILY_INCENTIVE = 'daily_incentive';
    case WEEKLY_MILESTONE = 'weekly_milestone';
    case DEDUCTION = 'deduction';
}
