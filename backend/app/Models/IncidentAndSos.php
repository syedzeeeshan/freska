<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\IncidentStatus;
use App\Enums\IncidentType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class IncidentAndSos extends Model
{
    use HasFactory;

    protected $table = 'incidents_and_sos';

    protected $fillable = [
        'incident_number',
        'rider_id',
        'order_id',
        'type',
        'latitude',
        'longitude',
        'location_address',
        'description',
        'media_urls',
        'medical_assistance_needed',
        'status',
        'acknowledged_at',
        'acknowledged_by',
        'resolution_report',
    ];

    protected $casts = [
        'type' => IncidentType::class,
        'status' => IncidentStatus::class,
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'media_urls' => 'array',
        'medical_assistance_needed' => 'boolean',
        'acknowledged_at' => 'datetime',
    ];

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function acknowledgedByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'acknowledged_by');
    }
}
