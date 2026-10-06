<?php

declare(strict_types=1);

namespace App\Enums;

enum KycStatus: string
{
    case PENDING = 'pending';
    case SUBMITTED = 'submitted';
    case VERIFIED = 'verified';
    case REJECTED = 'rejected';

    public function isApproved(): bool
    {
        return $this === self::VERIFIED;
    }
}
