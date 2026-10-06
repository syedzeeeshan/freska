<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number', 50)->unique();
            $table->foreignId('vendor_id')->constrained('vendors')->restrictOnDelete();
            $table->foreignId('rider_id')->nullable()->constrained('users')->nullOnDelete();

            // Customer details
            $table->string('customer_name', 120);
            $table->string('customer_phone', 20);
            $table->text('delivery_address');
            $table->string('delivery_area', 150);
            $table->decimal('delivery_latitude', 10, 8);
            $table->decimal('delivery_longitude', 11, 8);
            $table->text('delivery_instructions')->nullable();

            // Package & Type
            $table->enum('order_type', ['fresh_produce', 'dairy_cold_chain', 'grocery', 'bakery', 'express'])->default('grocery');
            $table->unsignedInteger('item_count')->default(1);
            $table->json('package_details')->nullable();
            $table->boolean('is_fragile')->default(false);
            $table->boolean('is_cold_chain')->default(false);

            // Lifecycle Status
            $table->enum('status', [
                'created',
                'dispatched',
                'offered',
                'accepted',
                'arrived_vendor',
                'picked_up',
                'in_transit',
                'arrived_customer',
                'delivered',
                'cancelled',
                'rejected',
                'failed'
            ])->default('created');

            // Payment & COD
            $table->enum('payment_mode', ['prepaid', 'cod'])->default('prepaid');
            $table->decimal('cod_amount', 10, 2)->default(0.00);
            $table->boolean('is_cod_collected')->default(false);
            $table->timestamp('cod_collected_at')->nullable();

            // Delivery Confirmation
            $table->string('delivery_otp', 6)->nullable();
            $table->string('delivery_signature_url', 500)->nullable();
            $table->string('delivery_proof_photo_url', 500)->nullable();

            // Distances & Payouts
            $table->decimal('estimated_distance_km', 6, 2);
            $table->unsignedInteger('estimated_duration_mins');
            $table->decimal('base_payout', 8, 2);
            $table->decimal('distance_payout', 8, 2)->default(0.00);
            $table->decimal('surge_payout', 8, 2)->default(0.00);
            $table->decimal('tip_amount', 8, 2)->default(0.00);
            $table->decimal('total_rider_payout', 8, 2);

            // Timestamps
            $table->timestamp('assignment_offered_at')->nullable();
            $table->timestamp('assignment_accepted_at')->nullable();
            $table->timestamp('arrived_vendor_at')->nullable();
            $table->timestamp('picked_up_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();

            $table->timestamps();

            $table->index('status');
            $table->index(['rider_id', 'status']);
            $table->index('vendor_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
