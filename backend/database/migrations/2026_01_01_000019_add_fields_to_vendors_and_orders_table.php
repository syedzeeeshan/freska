<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('vendors', function (Blueprint $table) {
            if (!Schema::hasColumn('vendors', 'user_id')) {
                $table->foreignId('user_id')->nullable()->after('id')->constrained('users')->nullOnDelete();
            }
            if (!Schema::hasColumn('vendors', 'category')) {
                $table->string('category', 100)->default('Dairy & Fresh Food')->after('name');
            }
            if (!Schema::hasColumn('vendors', 'rating')) {
                $table->decimal('rating', 3, 2)->default(4.9)->after('category');
            }
            if (!Schema::hasColumn('vendors', 'review_count')) {
                $table->integer('review_count')->default(250)->after('rating');
            }
            if (!Schema::hasColumn('vendors', 'estimated_delivery_time')) {
                $table->string('estimated_delivery_time', 50)->default('20-30 min')->after('review_count');
            }
            if (!Schema::hasColumn('vendors', 'image_url')) {
                $table->string('image_url', 500)->nullable()->after('estimated_delivery_time');
            }
            if (!Schema::hasColumn('vendors', 'banner_url')) {
                $table->string('banner_url', 500)->nullable()->after('image_url');
            }
            if (!Schema::hasColumn('vendors', 'is_open')) {
                $table->boolean('is_open')->default(true)->after('is_active');
            }
        });

        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'customer_id')) {
                $table->foreignId('customer_id')->nullable()->after('id')->constrained('users')->nullOnDelete();
            }
            if (!Schema::hasColumn('orders', 'subtotal')) {
                $table->decimal('subtotal', 10, 2)->default(0)->after('cod_amount');
            }
            if (!Schema::hasColumn('orders', 'delivery_fee')) {
                $table->decimal('delivery_fee', 10, 2)->default(40.00)->after('subtotal');
            }
            if (!Schema::hasColumn('orders', 'taxes')) {
                $table->decimal('taxes', 10, 2)->default(0)->after('delivery_fee');
            }
            if (!Schema::hasColumn('orders', 'discount_amount')) {
                $table->decimal('discount_amount', 10, 2)->default(0)->after('taxes');
            }
            if (!Schema::hasColumn('orders', 'total_amount')) {
                $table->decimal('total_amount', 10, 2)->default(0)->after('discount_amount');
            }
            if (!Schema::hasColumn('orders', 'customer_address_id')) {
                $table->foreignId('customer_address_id')->nullable()->after('customer_id')->constrained('customer_addresses')->nullOnDelete();
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['customer_id']);
            $table->dropForeign(['customer_address_id']);
            $table->dropColumn(['customer_id', 'customer_address_id', 'subtotal', 'delivery_fee', 'taxes', 'discount_amount', 'total_amount']);
        });

        Schema::table('vendors', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn(['user_id', 'category', 'rating', 'review_count', 'estimated_delivery_time', 'image_url', 'banner_url', 'is_open']);
        });
    }
};
