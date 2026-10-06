<?php

declare(strict_types=1);

namespace App\Enums;

enum OrderType: string
{
    case FRESH_PRODUCE = 'fresh_produce';
    case DAIRY_COLD_CHAIN = 'dairy_cold_chain';
    case GROCERY = 'grocery';
    case BAKERY = 'bakery';
    case EXPRESS = 'express';

    public function label(): string
    {
        return match ($this) {
            self::FRESH_PRODUCE => 'Fresh Produce',
            self::DAIRY_COLD_CHAIN => 'Dairy & Cold Chain',
            self::GROCERY => 'Grocery',
            self::BAKERY => 'Bakery',
            self::EXPRESS => 'Express Delivery',
        };
    }
}
