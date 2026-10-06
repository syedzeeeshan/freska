<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('label', 50)->default('Home'); // Home, Work, Other
            $table->string('recipient_name', 100)->nullable();
            $table->string('recipient_phone', 20)->nullable();
            $table->text('address_line');
            $table->string('area', 100);
            $table->string('landmark', 150)->nullable();
            $table->string('city', 100)->default('Bengaluru');
            $table->string('pincode', 20)->default('560034');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->boolean('is_default')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'is_default']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_addresses');
    }
};
