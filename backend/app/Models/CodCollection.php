<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\CodHandoverMethod;
use App\Enums\CodHandoverStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CodCollection extends Model
{
    use HasFactory;

    protected $table = 'cod_collections';

    protected $fillable = [
        'order_id',
        'rider_id',
        'amount',
        'collected_at',
        'collection_latitude',
        'collection_longitude',
        'handover_status',
        'handover_method',
        'handover_reference',
        'handover_receipt_url',
        'submitted_at',
        'reconciled_at',
        'reconciled_by',
        'reconciliation_notes',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'collected_at' => 'datetime',
        'submitted_at' => 'datetime',
        'reconciled_at' => 'datetime',
        'collection_latitude' => 'decimal:8',
        'collection_longitude' => 'decimal:8',
        'handover_status' => CodHandoverStatus::class,
        'handover_method' => CodHandoverMethod::class,
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function reconciledByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reconciled_by');
    }
}
