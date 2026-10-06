<?php

declare(strict_types=1);

namespace App\Enums;

enum PaymentMode: string
{
    case PREPAID = 'prepaid';
    case COD = 'cod';
}
