<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120)->nullable();
            $table->string('phone', 20)->unique();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('email', 150)->unique()->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password')->nullable();
            $table->string('avatar_url', 500)->nullable();
            $table->enum('role', ['rider', 'dispatcher', 'support_agent', 'operations_manager', 'super_admin'])->default('rider');
            $table->enum('status', ['active', 'suspended', 'inactive', 'pending_kyc'])->default('pending_kyc');
            $table->rememberToken();
            $table->timestamps();
            $table->softDeletes();

            $table->index('phone');
            $table->index(['role', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
