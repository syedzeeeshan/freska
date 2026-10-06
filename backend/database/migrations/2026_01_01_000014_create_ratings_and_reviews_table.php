<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ratings_and_reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('rider_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->json('badges')->nullable();
            $table->text('feedback_comment')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->unique('order_id');
            $table->index('rider_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings_and_reviews');
    }
};
