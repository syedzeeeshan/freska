<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cod_collections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->nullable()->constrained('orders');
            $table->foreignId('rider_id')->constrained('users');
            $table->decimal('amount', 10, 2);
            $table->timestamp('collected_at')->useCurrent();
            $table->decimal('collection_latitude', 10, 8)->nullable();
            $table->decimal('collection_longitude', 11, 8)->nullable();

            $table->enum('handover_status', ['held_in_hand', 'submitted', 'verified_reconciled', 'disputed'])->default('held_in_hand');
            $table->enum('handover_method', ['hub_deposit', 'bank_cdm', 'upi_clawback'])->nullable();
            $table->string('handover_reference', 100)->nullable();
            $table->string('handover_receipt_url', 500)->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('reconciled_at')->nullable();
            $table->foreignId('reconciled_by')->nullable()->constrained('users');
            $table->text('reconciliation_notes')->nullable();

            $table->timestamps();

            $table->index(['rider_id', 'handover_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cod_collections');
    }
};
