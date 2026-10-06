<?php

declare(strict_types=1);

namespace App\Enums;

enum CodHandoverMethod: string
{
    case HUB_DEPOSIT = 'hub_deposit';
    case BANK_CDM = 'bank_cdm';
    case UPI_CLAWBACK = 'upi_clawback';
}
