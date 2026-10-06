<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_assignment_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('rider_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('offered_at')->useCurrent();
            $table->timestamp('expires_at');
            $table->enum('status', ['offered', 'accepted', 'rejected', 'expired'])->default('offered');
            $table->string('rejection_reason')->nullable();
            $table->timestamp('response_timestamp')->nullable();
            $table->timestamps();

            $table->index(['order_id', 'rider_id', 'status'], 'idx_offers_order_rider_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_assignment_offers');
    }
};
