<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payouts', function (Blueprint $table) {
            $table->id();
            $table->string('payout_number', 50)->unique();
            $table->foreignId('rider_id')->constrained('users')->cascadeOnDelete();
            $table->date('period_start');
            $table->date('period_end');
            $table->unsignedInteger('deliveries_count');
            $table->decimal('base_amount', 10, 2);
            $table->decimal('incentives_amount', 10, 2)->default(0.00);
            $table->decimal('tips_amount', 10, 2)->default(0.00);
            $table->decimal('deductions_amount', 10, 2)->default(0.00);
            $table->decimal('net_payout_amount', 10, 2);
            $table->string('bank_reference_number', 100)->nullable();
            $table->enum('payment_method', ['bank_transfer', 'upi_payout', 'instant_transfer'])->default('bank_transfer');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->timestamp('processed_at')->nullable();
            $table->text('failure_reason')->nullable();
            $table->timestamps();

            $table->index(['rider_id', 'status']);
        });

        // Add foreign key constraint to rider_earnings if table exists
        if (Schema::hasTable('rider_earnings')) {
            Schema::table('rider_earnings', function (Blueprint $table) {
                $table->foreign('payout_id')->references('id')->on('payouts')->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('rider_earnings')) {
            Schema::table('rider_earnings', function (Blueprint $table) {
                $table->dropForeign(['payout_id']);
            });
        }
        Schema::dropIfExists('payouts');
    }
};
