<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\PayoutMethod;
use App\Enums\PayoutStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Payout extends Model
{
    use HasFactory;

    protected $table = 'payouts';

    protected $fillable = [
        'payout_number',
        'rider_id',
        'period_start',
        'period_end',
        'deliveries_count',
        'base_amount',
        'incentives_amount',
        'tips_amount',
        'deductions_amount',
        'net_payout_amount',
        'bank_reference_number',
        'payment_method',
        'status',
        'processed_at',
        'failure_reason',
    ];

    protected $casts = [
        'period_start' => 'date',
        'period_end' => 'date',
        'deliveries_count' => 'integer',
        'base_amount' => 'decimal:2',
        'incentives_amount' => 'decimal:2',
        'tips_amount' => 'decimal:2',
        'deductions_amount' => 'decimal:2',
        'net_payout_amount' => 'decimal:2',
        'payment_method' => PayoutMethod::class,
        'status' => PayoutStatus::class,
        'processed_at' => 'datetime',
    ];

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function earnings(): HasMany
    {
        return $this->hasMany(RiderEarning::class, 'payout_id');
    }
}
