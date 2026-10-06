<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('incidents_and_sos', function (Blueprint $table) {
            $table->id();
            $table->string('incident_number', 50)->unique();
            $table->foreignId('rider_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()->constrained('orders')->nullOnDelete();
            $table->enum('type', [
                'sos_panic',
                'road_accident',
                'vehicle_breakdown',
                'customer_harassment',
                'dog_bite',
                'weather_hazard'
            ]);
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->text('location_address')->nullable();
            $table->text('description')->nullable();
            $table->json('media_urls')->nullable();
            $table->boolean('medical_assistance_needed')->default(false);
            $table->enum('status', [
                'triggered',
                'acknowledged',
                'ops_dispatched',
                'resolved',
                'false_alarm'
            ])->default('triggered');
            $table->timestamp('acknowledged_at')->nullable();
            $table->foreignId('acknowledged_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('resolution_report')->nullable();
            $table->timestamps();

            $table->index(['type', 'status']);
            $table->index('rider_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('incidents_and_sos');
    }
};
