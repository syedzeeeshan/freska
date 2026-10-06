<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Enums\KycStatus;
use App\Enums\OrderStatus;
use App\Enums\OrderType;
use App\Enums\PaymentMode;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Category;
use App\Models\CustomerAddress;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Categories
        $catDairy = Category::updateOrCreate(
            ['slug' => 'dairy-cold-chain'],
            [
                'name' => 'Dairy & Cold Chain',
                'description' => 'Fresh organic farm milk, Greek yogurt, artisanal cheeses and cultured butter.',
                'icon_url' => 'https://images.unsplash.com/photo-1528750997573-59b89d56f4f7?w=200',
                'is_active' => true,
                'sort_order' => 1,
            ]
        );

        $catProduce = Category::updateOrCreate(
            ['slug' => 'farm-fresh-produce'],
            [
                'name' => 'Farm Fresh Produce',
                'description' => 'Hydroponic strawberries, crisp greens, avocados and handpicked organic berries.',
                'icon_url' => 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200',
                'is_active' => true,
                'sort_order' => 2,
            ]
        );

        $catBakery = Category::updateOrCreate(
            ['slug' => 'artisan-bakery'],
            [
                'name' => 'Artisan Bakery',
                'description' => 'Slow-fermented sourdoughs, butter croissants and stone-ground sourdough loaves.',
                'icon_url' => 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
                'is_active' => true,
                'sort_order' => 3,
            ]
        );

        $catBeverages = Category::updateOrCreate(
            ['slug' => 'cold-brews-beverages'],
            [
                'name' => 'Cold Brews & Juices',
                'description' => 'Cold pressed green juices, nitro cold brew coffee and sparkling kombucha.',
                'icon_url' => 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=200',
                'is_active' => true,
                'sort_order' => 4,
            ]
        );

        // 2. Seed Vendor User & Store
        $vendorUser = User::updateOrCreate(
            ['phone' => '+919876500001'],
            [
                'name' => 'Freska Koramangala Store Manager',
                'email' => 'store.koramangala@freska.app',
                'phone_verified_at' => now(),
                'role' => UserRole::VENDOR,
                'status' => UserStatus::ACTIVE,
            ]
        );

        $vendor1 = Vendor::updateOrCreate(
            ['store_code' => 'FSK-BLR-001'],
            [
                'user_id' => $vendorUser->id,
                'name' => 'Freska Hub Koramangala',
                'category' => 'Dairy & Fresh Produce',
                'rating' => 4.92,
                'review_count' => 348,
                'estimated_delivery_time' => '15-25 min',
                'phone' => '+918049281200',
                'email' => 'hub.koramangala@freska.app',
                'address' => '80 Feet Rd, 4th Block, Koramangala, Bengaluru, Karnataka 560034',
                'landmark' => 'Near Sony World Signal',
                'latitude' => 12.935242,
                'longitude' => 77.624466,
                'image_url' => 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
                'banner_url' => 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
                'pickup_instructions' => 'Enter through Gate 2, Delivery Partner Dock 4.',
                'contact_person' => 'Ramesh Kumar (Store Lead)',
                'is_active' => true,
                'is_open' => true,
            ]
        );

        $vendor2 = Vendor::updateOrCreate(
            ['store_code' => 'FSK-BLR-002'],
            [
                'name' => 'Green Earth Organic Market',
                'category' => 'Organic Produce & Greens',
                'rating' => 4.86,
                'review_count' => 215,
                'estimated_delivery_time' => '20-30 min',
                'phone' => '+918049281201',
                'email' => 'green.earth@freska.app',
                'address' => '12th Main Rd, Indiranagar, Bengaluru, Karnataka 560038',
                'landmark' => 'Opposite Metro Station',
                'latitude' => 12.978400,
                'longitude' => 77.640800,
                'image_url' => 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800',
                'banner_url' => 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=1200',
                'pickup_instructions' => 'Rider counter at side entrance.',
                'contact_person' => 'Anita Desai',
                'is_active' => true,
                'is_open' => true,
            ]
        );

        $vendor3 = Vendor::updateOrCreate(
            ['store_code' => 'FSK-BLR-003'],
            [
                'name' => 'Artisan Bakehouse 7',
                'category' => 'Artisan Bakery & Patisserie',
                'rating' => 4.95,
                'review_count' => 420,
                'estimated_delivery_time' => '15-20 min',
                'phone' => '+918049281202',
                'email' => 'bakehouse7@freska.app',
                'address' => '27th Main Rd, HSR Layout, Sector 1, Bengaluru, Karnataka 560102',
                'landmark' => 'Beside Agara Lake Park',
                'latitude' => 12.912500,
                'longitude' => 77.644000,
                'image_url' => 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
                'banner_url' => 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200',
                'pickup_instructions' => 'Collect from dedicated partner dispatch shelf.',
                'contact_person' => 'Chef Vikram Singh',
                'is_active' => true,
                'is_open' => true,
            ]
        );

        // 3. Seed Menu Items for Vendor 1
        $item1 = MenuItem::updateOrCreate(
            ['vendor_id' => $vendor1->id, 'name' => 'Organic A2 Farm Milk (1 Litre)'],
            [
                'category_id' => $catDairy->id,
                'description' => 'Pure unpasteurized cold-chain certified A2 Desi Gir cow whole milk in glass bottle.',
                'price' => 95.00,
                'discount_price' => 85.00,
                'image_url' => 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600',
                'is_available' => true,
                'is_vegetarian' => true,
                'is_cold_chain' => true,
                'is_fragile' => true,
                'rating' => 4.95,
                'preparation_time_mins' => 5,
            ]
        );

        $item2 = MenuItem::updateOrCreate(
            ['vendor_id' => $vendor1->id, 'name' => 'Hydroponic Sweet Strawberries (500g)'],
            [
                'category_id' => $catProduce->id,
                'description' => 'Crisp pesticide-free strawberries cultivated in climate-controlled indoor farm.',
                'price' => 160.00,
                'discount_price' => 140.00,
                'image_url' => 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600',
                'is_available' => true,
                'is_vegetarian' => true,
                'is_cold_chain' => true,
                'is_fragile' => true,
                'rating' => 4.90,
                'preparation_time_mins' => 5,
            ]
        );

        $item3 = MenuItem::updateOrCreate(
            ['vendor_id' => $vendor1->id, 'name' => 'Artisanal Wild Honey Greek Yogurt (200g)'],
            [
                'category_id' => $catDairy->id,
                'description' => 'High-protein strained Greek yogurt infused with Nilgiri forest raw wild honey.',
                'price' => 110.00,
                'discount_price' => 95.00,
                'image_url' => 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600',
                'is_available' => true,
                'is_vegetarian' => true,
                'is_cold_chain' => true,
                'is_fragile' => false,
                'rating' => 4.88,
                'preparation_time_mins' => 5,
            ]
        );

        $item4 = MenuItem::updateOrCreate(
            ['vendor_id' => $vendor1->id, 'name' => 'Stone-Ground Country Sourdough Loaf'],
            [
                'category_id' => $catBakery->id,
                'description' => '36-hour slow fermented sourdough loaf with dark crunchy crust and open crumb.',
                'price' => 140.00,
                'discount_price' => 120.00,
                'image_url' => 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=600',
                'is_available' => true,
                'is_vegetarian' => true,
                'is_cold_chain' => false,
                'is_fragile' => false,
                'rating' => 4.92,
                'preparation_time_mins' => 10,
            ]
        );

        $item5 = MenuItem::updateOrCreate(
            ['vendor_id' => $vendor1->id, 'name' => 'Nitro Cold Brew Black Coffee (300ml)'],
            [
                'category_id' => $catBeverages->id,
                'description' => 'Single-origin Coorg Arabica beans steeped for 24 hours and nitrogen-charged for creamy head.',
                'price' => 130.00,
                'discount_price' => 115.00,
                'image_url' => 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=600',
                'is_available' => true,
                'is_vegetarian' => true,
                'is_cold_chain' => true,
                'is_fragile' => false,
                'rating' => 4.87,
                'preparation_time_mins' => 5,
            ]
        );

        // 4. Seed Demo Customer & Saved Addresses
        $customerUser = User::updateOrCreate(
            ['phone' => '+919988776655'],
            [
                'name' => 'Priya V.',
                'email' => 'priya.customer@freska.app',
                'phone_verified_at' => now(),
                'role' => UserRole::CUSTOMER,
                'status' => UserStatus::ACTIVE,
            ]
        );

        $address1 = CustomerAddress::updateOrCreate(
            ['user_id' => $customerUser->id, 'label' => 'Home'],
            [
                'recipient_name' => 'Priya V.',
                'recipient_phone' => '+919988776655',
                'address_line' => '#412, 14th Main, HSR Layout, Sector 1',
                'area' => 'HSR Layout Sector 1',
                'landmark' => 'Near Agara Lake Gate 3',
                'city' => 'Bengaluru',
                'pincode' => '560102',
                'latitude' => 12.912118,
                'longitude' => 77.644554,
                'is_default' => true,
            ]
        );

        $address2 = CustomerAddress::updateOrCreate(
            ['user_id' => $customerUser->id, 'label' => 'Work'],
            [
                'recipient_name' => 'Priya V.',
                'recipient_phone' => '+919988776655',
                'address_line' => '4th Floor, WeWork Galaxy, 43 Residency Rd, Shanthala Nagar',
                'area' => 'Ashok Nagar',
                'landmark' => 'Next to Ritz Carlton',
                'city' => 'Bengaluru',
                'pincode' => '560025',
                'latitude' => 12.971598,
                'longitude' => 77.594562,
                'is_default' => false,
            ]
        );

        // 5. Seed Demo Rider
        $demoRider = User::updateOrCreate(
            ['phone' => '+919876543210'],
            [
                'name' => 'Arjun Sharma',
                'email' => 'arjun.rider@freska.app',
                'phone_verified_at' => now(),
                'role' => UserRole::RIDER,
                'status' => UserStatus::ACTIVE,
            ]
        );

        RiderProfile::updateOrCreate(
            ['user_id' => $demoRider->id],
            [
                'vehicle_type' => 'bike',
                'vehicle_number' => 'KA01EQ4921',
                'license_number' => 'DL1420110012345',
                'license_expiry' => '2028-12-31',
                'kyc_status' => KycStatus::VERIFIED,
                'is_online' => true,
                'current_latitude' => 12.971598,
                'current_longitude' => 77.594562,
                'bank_account_holder' => 'Arjun Sharma',
                'bank_name' => 'HDFC Bank',
                'bank_account_number' => '50100234918231',
                'bank_ifsc_code' => 'HDFC0001234',
                'bank_upi_id' => 'arjun@okhdfcbank',
                'bank_verified' => true,
                'emergency_contact_name' => 'Sunita Sharma',
                'emergency_contact_phone' => '+919811223344',
                'emergency_contact_relation' => 'Mother',
                'max_cash_limit' => 5000.00,
                'current_cash_in_hand' => 450.00,
                'rating_average' => 4.95,
                'rating_count' => 128,
                'acceptance_rate' => 96.50,
                'on_time_rate' => 98.20,
                'completed_deliveries_count' => 342,
                'tier' => 'gold',
            ]
        );

        // 6. Seed Active Order connecting Customer, Vendor, and Rider
        $activeOrder = Order::updateOrCreate(
            ['order_number' => 'FSK-2026-89421'],
            [
                'customer_id' => $customerUser->id,
                'customer_address_id' => $address1->id,
                'vendor_id' => $vendor1->id,
                'rider_id' => $demoRider->id,
                'customer_name' => 'Priya V.',
                'customer_phone' => '+919988776655',
                'delivery_address' => '#412, 14th Main, HSR Layout, Sector 1, Bengaluru',
                'delivery_area' => 'HSR Layout Sector 1',
                'delivery_latitude' => 12.912118,
                'delivery_longitude' => 77.644554,
                'delivery_instructions' => 'Ring bell once, leave at security desk if unavailable.',
                'order_type' => OrderType::EXPRESS,
                'item_count' => 4,
                'package_details' => [
                    'item_count' => 4,
                    'is_fragile' => true,
                    'is_cold_chain' => true,
                    'items' => [
                        ['name' => 'Organic A2 Farm Milk (1 Litre)', 'quantity' => 2, 'price' => 85.00],
                        ['name' => 'Hydroponic Sweet Strawberries (500g)', 'quantity' => 1, 'price' => 140.00],
                        ['name' => 'Artisanal Wild Honey Greek Yogurt (200g)', 'quantity' => 1, 'price' => 110.00],
                    ],
                ],
                'is_fragile' => true,
                'is_cold_chain' => true,
                'status' => OrderStatus::ACCEPTED,
                'payment_mode' => PaymentMode::COD,
                'subtotal' => 420.00,
                'delivery_fee' => 40.00,
                'taxes' => 0.00,
                'discount_amount' => 40.00,
                'total_amount' => 420.00,
                'cod_amount' => 420.00,
                'is_cod_collected' => false,
                'delivery_otp' => '4821',
                'estimated_distance_km' => 4.8,
                'estimated_duration_mins' => 22,
                'base_payout' => 45.00,
                'distance_payout' => 15.00,
                'surge_payout' => 8.00,
                'tip_amount' => 0.00,
                'total_rider_payout' => 68.00,
                'assignment_offered_at' => now()->subMinutes(8),
                'assignment_accepted_at' => now()->subMinutes(5),
            ]
        );

        // 7. Seed Demo Operations/Admin
        User::updateOrCreate(
            ['phone' => '+919999900000'],
            [
                'name' => 'Freska Operations Lead',
                'email' => 'ops@freska.app',
                'password' => bcrypt('FreskaOps@2026!'),
                'phone_verified_at' => now(),
                'role' => UserRole::OPERATIONS_MANAGER,
                'status' => UserStatus::ACTIVE,
            ]
        );
    }
}
