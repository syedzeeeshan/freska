<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete()->unique();
            $table->date('date_of_birth')->nullable();
            $table->enum('gender', ['male', 'female', 'other'])->nullable();
            $table->string('blood_group', 10)->nullable();
            $table->enum('vehicle_type', ['bike', 'scooter', 'ev_two_wheeler', 'bicycle'])->default('bike');
            $table->string('vehicle_number', 30)->nullable();
            
            // License & KYC
            $table->string('license_number', 50)->nullable();
            $table->date('license_expiry')->nullable();
            $table->string('license_front_url', 500)->nullable();
            $table->string('license_back_url', 500)->nullable();
            $table->string('rc_book_url', 500)->nullable();
            $table->enum('id_proof_type', ['aadhaar', 'pan', 'passport', 'voter_id'])->default('aadhaar');
            $table->string('id_proof_number', 50)->nullable();
            $table->string('id_proof_url', 500)->nullable();
            $table->enum('kyc_status', ['pending', 'submitted', 'verified', 'rejected'])->default('pending');
            $table->text('kyc_rejection_reason')->nullable();
            $table->timestamp('kyc_reviewed_at')->nullable();
            $table->foreignId('kyc_reviewed_by')->nullable()->constrained('users');

            // Bank Details
            $table->string('bank_account_holder', 150)->nullable();
            $table->string('bank_name', 100)->nullable();
            $table->string('bank_account_number', 50)->nullable();
            $table->string('bank_ifsc_code', 20)->nullable();
            $table->string('bank_upi_id', 100)->nullable();
            $table->boolean('bank_verified')->default(false);

            // Emergency Contact
            $table->string('emergency_contact_name', 120)->nullable();
            $table->string('emergency_contact_phone', 20)->nullable();
            $table->string('emergency_contact_relation', 50)->nullable();

            // Duty & Location
            $table->boolean('is_online')->default(false);
            $table->decimal('current_latitude', 10, 8)->nullable();
            $table->decimal('current_longitude', 11, 8)->nullable();
            $table->timestamp('last_location_updated_at')->nullable();

            // COD Limits & Cash In Hand
            $table->decimal('max_cash_limit', 10, 2)->default(5000.00);
            $table->decimal('current_cash_in_hand', 10, 2)->default(0.00);

            // Performance & Ratings
            $table->decimal('rating_average', 3, 2)->default(5.00);
            $table->unsignedInteger('rating_count')->default(0);
            $table->decimal('acceptance_rate', 5, 2)->default(100.00);
            $table->decimal('on_time_rate', 5, 2)->default(100.00);
            $table->unsignedInteger('completed_deliveries_count')->default(0);
            $table->enum('tier', ['bronze', 'silver', 'gold', 'platinum'])->default('bronze');

            // Insurance (Conditionally shown if provided by Freska - Page 10)
            $table->string('insurance_policy_number', 100)->nullable();
            $table->string('insurance_provider', 150)->nullable();
            $table->date('insurance_valid_until')->nullable();
            $table->string('insurance_document_url', 500)->nullable();

            $table->timestamps();

            $table->index(['is_online', 'current_latitude', 'current_longitude'], 'idx_rider_online_loc');
            $table->index('kyc_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rider_profiles');
    }
};
