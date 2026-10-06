<?php

declare(strict_types=1);

namespace App\Enums;

enum UserRole: string
{
    case CUSTOMER = 'customer';
    case VENDOR = 'vendor';
    case RIDER = 'rider';
    case DISPATCHER = 'dispatcher';
    case SUPPORT_AGENT = 'support_agent';
    case OPERATIONS_MANAGER = 'operations_manager';
    case SUPER_ADMIN = 'super_admin';

    public function isAdministrative(): bool
    {
        return match ($this) {
            self::CUSTOMER, self::VENDOR, self::RIDER => false,
            self::DISPATCHER, self::SUPPORT_AGENT, self::OPERATIONS_MANAGER, self::SUPER_ADMIN => true,
        };
    }
}
