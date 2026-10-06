<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\OfferStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderAssignmentOffer extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'rider_id',
        'offered_at',
        'expires_at',
        'status',
        'rejection_reason',
        'response_timestamp',
    ];

    protected function casts(): array
    {
        return [
            'offered_at' => 'datetime',
            'expires_at' => 'datetime',
            'status' => OfferStatus::class,
            'response_timestamp' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function isExpired(): bool
    {
        return $this->status === OfferStatus::EXPIRED || now()->greaterThan($this->expires_at);
    }
}
