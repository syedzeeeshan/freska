<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\OrderStatus;
use App\Enums\OrderType;
use App\Enums\PaymentMode;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'customer_id',
        'customer_address_id',
        'vendor_id',
        'rider_id',
        'customer_name',
        'customer_phone',
        'delivery_address',
        'delivery_area',
        'delivery_latitude',
        'delivery_longitude',
        'delivery_instructions',
        'order_type',
        'item_count',
        'package_details',
        'is_fragile',
        'is_cold_chain',
        'status',
        'payment_mode',
        'cod_amount',
        'subtotal',
        'delivery_fee',
        'taxes',
        'discount_amount',
        'total_amount',
        'is_cod_collected',
        'cod_collected_at',
        'delivery_otp',
        'delivery_signature_url',
        'delivery_proof_photo_url',
        'estimated_distance_km',
        'estimated_duration_mins',
        'base_payout',
        'distance_payout',
        'surge_payout',
        'tip_amount',
        'total_rider_payout',
        'assignment_offered_at',
        'assignment_accepted_at',
        'arrived_vendor_at',
        'picked_up_at',
        'delivered_at',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected function casts(): array
    {
        return [
            'order_type' => OrderType::class,
            'status' => OrderStatus::class,
            'payment_mode' => PaymentMode::class,
            'package_details' => 'array',
            'is_fragile' => 'boolean',
            'is_cold_chain' => 'boolean',
            'is_cod_collected' => 'boolean',
            'delivery_latitude' => 'decimal:8',
            'delivery_longitude' => 'decimal:8',
            'estimated_distance_km' => 'decimal:2',
            'cod_amount' => 'decimal:2',
            'subtotal' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'taxes' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'base_payout' => 'decimal:2',
            'distance_payout' => 'decimal:2',
            'surge_payout' => 'decimal:2',
            'tip_amount' => 'decimal:2',
            'total_rider_payout' => 'decimal:2',
            'cod_collected_at' => 'datetime',
            'assignment_offered_at' => 'datetime',
            'assignment_accepted_at' => 'datetime',
            'arrived_vendor_at' => 'datetime',
            'picked_up_at' => 'datetime',
            'delivered_at' => 'datetime',
            'cancelled_at' => 'datetime',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function address(): BelongsTo
    {
        return $this->belongsTo(CustomerAddress::class, 'customer_address_id');
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function rider(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rider_id');
    }

    public function offers(): HasMany
    {
        return $this->hasMany(OrderAssignmentOffer::class);
    }

    public function isPickedUp(): bool
    {
        return in_array($this->status, [
            OrderStatus::PICKED_UP,
            OrderStatus::IN_TRANSIT,
            OrderStatus::ARRIVED_CUSTOMER,
            OrderStatus::DELIVERED,
        ], true);
    }
}
