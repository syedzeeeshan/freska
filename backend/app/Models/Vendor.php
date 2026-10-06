<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vendor extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'store_code',
        'category',
        'rating',
        'review_count',
        'estimated_delivery_time',
        'image_url',
        'banner_url',
        'phone',
        'email',
        'address',
        'landmark',
        'latitude',
        'longitude',
        'pickup_instructions',
        'contact_person',
        'is_active',
        'is_open',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'rating' => 'decimal:2',
            'review_count' => 'integer',
            'is_active' => 'boolean',
            'is_open' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function menuItems(): HasMany
    {
        return $this->hasMany(MenuItem::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
