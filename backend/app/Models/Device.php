<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Device extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'device_id',
        'fcm_token',
        'device_model',
        'os_version',
        'app_version',
        'is_active',
        'last_active_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'last_active_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
