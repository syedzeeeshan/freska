<?php

declare(strict_types=1);

namespace App\Enums;

enum CodHandoverStatus: string
{
    case HELD_IN_HAND = 'held_in_hand';
    case SUBMITTED = 'submitted';
    case VERIFIED_RECONCILED = 'verified_reconciled';
    case DISPUTED = 'disputed';
}
