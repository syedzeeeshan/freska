<?php

declare(strict_types=1);

namespace App\Enums;

enum PayoutMethod: string
{
    case BANK_TRANSFER = 'bank_transfer';
    case UPI_PAYOUT = 'upi_payout';
    case INSTANT_TRANSFER = 'instant_transfer';
}
