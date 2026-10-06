<?php

declare(strict_types=1);

namespace App\Enums;

enum Tier: string
{
    case BRONZE = 'bronze';
    case SILVER = 'silver';
    case GOLD = 'gold';
    case PLATINUM = 'platinum';

    public function multiplier(): float
    {
        return match ($this) {
            self::BRONZE => 1.00,
            self::SILVER => 1.05,
            self::GOLD => 1.10,
            self::PLATINUM => 1.15,
        };
    }

    public function minimumDeliveries(): int
    {
        return match ($this) {
            self::BRONZE => 0,
            self::SILVER => 50,
            self::GOLD => 200,
            self::PLATINUM => 500,
        };
    }

    public function nextTier(): ?self
    {
        return match ($this) {
            self::BRONZE => self::SILVER,
            self::SILVER => self::GOLD,
            self::GOLD => self::PLATINUM,
            self::PLATINUM => null,
        };
    }
}
