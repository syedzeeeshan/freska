<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'vendor_id',
        'category_id',
        'name',
        'description',
        'price',
        'discount_price',
        'image_url',
        'is_available',
        'is_vegetarian',
        'is_cold_chain',
        'is_fragile',
        'rating',
        'preparation_time_mins',
        'variants',
        'addons',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'discount_price' => 'decimal:2',
            'rating' => 'decimal:2',
            'is_available' => 'boolean',
            'is_vegetarian' => 'boolean',
            'is_cold_chain' => 'boolean',
            'is_fragile' => 'boolean',
            'preparation_time_mins' => 'integer',
            'variants' => 'array',
            'addons' => 'array',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
