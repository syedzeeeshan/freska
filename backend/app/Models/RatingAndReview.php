<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RatingAndReview extends Model
{
    use HasFactory;

    protected $table = 'ratings_and_reviews';

    public $timestamps = false;

    protected $fillable = [
        'order_id',
        'rider_id',
        'rating',
        'badges',
        'feedback_comment',
        'created_at',
    ];

    protected $casts = [
        'rating' => 'integer',
        'badges' => 'array',
        'created_at' => 'datetime',
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }
}
