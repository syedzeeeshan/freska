<?php

declare(strict_types=1);

namespace App\Enums;

enum OfferStatus: string
{
    case OFFERED = 'offered';
    case ACCEPTED = 'accepted';
    case REJECTED = 'rejected';
    case EXPIRED = 'expired';
}
