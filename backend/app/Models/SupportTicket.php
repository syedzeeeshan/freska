<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\SupportCategory;
use App\Enums\SupportPriority;
use App\Enums\SupportStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SupportTicket extends Model
{
    use HasFactory;

    protected $table = 'support_tickets';

    protected $fillable = [
        'ticket_number',
        'rider_id',
        'order_id',
        'category',
        'subject',
        'description',
        'attachment_url',
        'priority',
        'status',
        'assigned_to',
        'resolution_notes',
        'resolved_at',
    ];

    protected $casts = [
        'category' => SupportCategory::class,
        'priority' => SupportPriority::class,
        'status' => SupportStatus::class,
        'resolved_at' => 'datetime',
    ];

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function assignedAgent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }
}
