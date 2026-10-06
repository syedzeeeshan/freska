<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_earnings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rider_id')->constrained('users');
            $table->foreignId('order_id')->nullable()->constrained('orders')->nullOnDelete();
            $table->enum('earning_type', [
                'delivery_fee',
                'distance_bonus',
                'surge_bonus',
                'customer_tip',
                'daily_incentive',
                'weekly_milestone',
                'deduction'
            ]);
            $table->decimal('amount', 8, 2);
            $table->string('description', 255);
            $table->date('date');
            $table->unsignedBigInteger('payout_id')->nullable();
            $table->enum('status', ['pending', 'processed', 'paid'])->default('pending');
            $table->timestamps();

            $table->index(['rider_id', 'date']);
            $table->index('payout_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rider_earnings');
    }
};
