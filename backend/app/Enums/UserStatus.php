<?php

declare(strict_types=1);

namespace App\Enums;

enum UserStatus: string
{
    case ACTIVE = 'active';
    case SUSPENDED = 'suspended';
    case INACTIVE = 'inactive';
    case PENDING_KYC = 'pending_kyc';

    public function canOperate(): bool
    {
        return $this === self::ACTIVE;
    }
}
