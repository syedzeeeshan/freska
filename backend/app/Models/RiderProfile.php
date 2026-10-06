<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\KycStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiderProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date_of_birth',
        'gender',
        'blood_group',
        'vehicle_type',
        'vehicle_number',
        'license_number',
        'license_expiry',
        'license_front_url',
        'license_back_url',
        'rc_book_url',
        'id_proof_type',
        'id_proof_number',
        'id_proof_url',
        'kyc_status',
        'kyc_rejection_reason',
        'kyc_reviewed_at',
        'kyc_reviewed_by',
        'bank_account_holder',
        'bank_name',
        'bank_account_number',
        'bank_ifsc_code',
        'bank_upi_id',
        'bank_verified',
        'emergency_contact_name',
        'emergency_contact_phone',
        'emergency_contact_relation',
        'is_online',
        'current_latitude',
        'current_longitude',
        'last_location_updated_at',
        'max_cash_limit',
        'current_cash_in_hand',
        'rating_average',
        'rating_count',
        'acceptance_rate',
        'on_time_rate',
        'completed_deliveries_count',
        'tier',
        'insurance_policy_number',
        'insurance_provider',
        'insurance_valid_until',
        'insurance_document_url',
    ];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'license_expiry' => 'date',
            'kyc_status' => KycStatus::class,
            'kyc_reviewed_at' => 'datetime',
            'bank_verified' => 'boolean',
            'is_online' => 'boolean',
            'current_latitude' => 'decimal:8',
            'current_longitude' => 'decimal:8',
            'last_location_updated_at' => 'datetime',
            'max_cash_limit' => 'decimal:2',
            'current_cash_in_hand' => 'decimal:2',
            'rating_average' => 'decimal:2',
            'acceptance_rate' => 'decimal:2',
            'on_time_rate' => 'decimal:2',
            'insurance_valid_until' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'kyc_reviewed_by');
    }
}
