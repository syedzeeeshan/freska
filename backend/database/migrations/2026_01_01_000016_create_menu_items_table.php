<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('menu_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vendor_id')->constrained('vendors')->cascadeOnDelete();
            $table->foreignId('category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->string('name', 150);
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->decimal('discount_price', 10, 2)->nullable();
            $table->string('image_url', 500)->nullable();
            $table->boolean('is_available')->default(true);
            $table->boolean('is_vegetarian')->default(true);
            $table->boolean('is_cold_chain')->default(false);
            $table->boolean('is_fragile')->default(false);
            $table->decimal('rating', 3, 2)->default(4.8);
            $table->integer('preparation_time_mins')->default(15);
            $table->json('variants')->nullable();
            $table->json('addons')->nullable();
            $table->timestamps();

            $table->index(['vendor_id', 'is_available']);
            $table->index('category_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('menu_items');
    }
};
