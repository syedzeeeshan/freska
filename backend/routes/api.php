<?php

use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Auth\DeviceController;
use App\Http\Controllers\Api\V1\Customer\CustomerAddressController;
use App\Http\Controllers\Api\V1\Customer\CustomerCartController;
use App\Http\Controllers\Api\V1\Customer\CustomerCategoryController;
use App\Http\Controllers\Api\V1\Customer\CustomerOrderController;
use App\Http\Controllers\Api\V1\Customer\CustomerVendorController;
use App\Http\Controllers\Api\V1\Order\OrderLifecycleController;
use App\Http\Controllers\Api\V1\Order\OrderOfferController;
use App\Http\Controllers\Api\V1\Rider\DutyController;
use App\Http\Controllers\Api\V1\Rider\KycController;
use App\Http\Controllers\Api\V1\Rider\LocationController;
use App\Http\Controllers\Api\V1\Rider\ProfileController;
use App\Http\Controllers\Api\V1\Vendor\VendorDashboardController;
use App\Http\Controllers\Api\V1\Vendor\VendorEarningsController;
use App\Http\Controllers\Api\V1\Vendor\VendorMenuController;
use App\Http\Controllers\Api\V1\Vendor\VendorOrderController;
use App\Http\Controllers\Api\V1\Vendor\VendorProfileController;
use App\Http\Controllers\Api\V1\Voice\VoiceIntentController;
use App\Http\Middleware\EnsureKycApproved;
use App\Http\Middleware\EnsureSingleActiveDevice;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Freska Delivery Partner & Multi-App Platform
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Public Authentication Endpoints
    Route::prefix('auth')->group(function () {
        Route::post('otp/send', [AuthController::class, 'sendOtp'])->middleware('throttle:5,1');
        Route::post('otp/verify', [AuthController::class, 'verifyOtp'])->middleware('throttle:10,1');
    });

    // Public Discovery Endpoints (Customer / Guest)
    Route::prefix('customer')->group(function () {
        Route::get('categories', [CustomerCategoryController::class, 'index']);
        Route::get('vendors', [CustomerVendorController::class, 'index']);
        Route::get('vendors/{id}', [CustomerVendorController::class, 'show']);
        Route::get('search', [CustomerVendorController::class, 'search']);
    });

    // Unified Voice Intent Processing
    Route::post('voice/intent', [VoiceIntentController::class, 'process']);

    // Authenticated Common Routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('auth')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
            Route::get('devices', [DeviceController::class, 'index']);
            Route::delete('devices/{deviceId}', [DeviceController::class, 'deactivate']);
        });

        // Authenticated Customer Routes
        Route::prefix('customer')->group(function () {
            // Cart Management
            Route::get('cart', [CustomerCartController::class, 'getCart']);
            Route::post('cart/items', [CustomerCartController::class, 'addItem']);
            Route::put('cart/items/{id}', [CustomerCartController::class, 'updateQuantity']);
            Route::delete('cart/items/{id}', [CustomerCartController::class, 'removeItem']);
            Route::delete('cart', [CustomerCartController::class, 'clear']);

            // Orders & Tracking
            Route::post('orders', [CustomerOrderController::class, 'store']);
            Route::get('orders', [CustomerOrderController::class, 'index']);
            Route::get('orders/{id}', [CustomerOrderController::class, 'show']);
            Route::get('orders/{id}/track', [CustomerOrderController::class, 'track']);

            // Saved Addresses
            Route::get('addresses', [CustomerAddressController::class, 'index']);
            Route::post('addresses', [CustomerAddressController::class, 'store']);
            Route::delete('addresses/{id}', [CustomerAddressController::class, 'destroy']);
            Route::patch('addresses/{id}/default', [CustomerAddressController::class, 'setDefault']);
        });

        // Authenticated Vendor Routes
        Route::prefix('vendor')->group(function () {
            Route::get('dashboard', [VendorDashboardController::class, 'summary']);
            Route::get('orders', [VendorOrderController::class, 'index']);
            Route::get('orders/{id}', [VendorOrderController::class, 'show']);
            Route::post('orders/{id}/accept', [VendorOrderController::class, 'accept']);
            Route::post('orders/{id}/ready', [VendorOrderController::class, 'markReady']);
            Route::post('orders/{id}/reject', [VendorOrderController::class, 'reject']);

            // Menu Management
            Route::get('menu', [VendorMenuController::class, 'index']);
            Route::post('menu/items', [VendorMenuController::class, 'store']);
            Route::put('menu/items/{id}', [VendorMenuController::class, 'update']);
            Route::patch('menu/items/{id}/availability', [VendorMenuController::class, 'toggleAvailability']);
            Route::delete('menu/items/{id}', [VendorMenuController::class, 'destroy']);

            // Profile & Settings
            Route::get('profile', [VendorProfileController::class, 'getProfile']);
            Route::put('profile', [VendorProfileController::class, 'updateProfile']);
            Route::post('profile/toggle-status', [VendorProfileController::class, 'toggleStatus']);
            Route::get('earnings', [VendorEarningsController::class, 'summary']);
        });
    });

    // Authenticated Rider Routes
    Route::middleware(['auth:sanctum', 'role:rider', EnsureSingleActiveDevice::class])->group(function () {

        // Rider Profile & Onboarding
        Route::prefix('rider')->group(function () {
            Route::get('profile', [ProfileController::class, 'getProfile']);
            Route::post('profile/photo', [ProfileController::class, 'uploadPhoto']);
            Route::put('bank-details', [ProfileController::class, 'updateBankDetails']);
            Route::put('emergency-contact', [ProfileController::class, 'updateEmergencyContact']);

            // KYC Management
            Route::post('documents', [KycController::class, 'submitKyc']);
            Route::get('documents/status', [KycController::class, 'getStatus']);

            // Dashboard Cockpit & Telemetry
            Route::get('dashboard/summary', [DutyController::class, 'summary']);
            Route::post('location', [LocationController::class, 'heartbeat']);

            // Duty Availability (requires verified KYC)
            Route::post('duty/toggle', [DutyController::class, 'toggle'])->middleware(EnsureKycApproved::class);

            // Active Orders, Dispatch Offers & Fulfillment Lifecycle
            Route::prefix('orders')->group(function () {
                Route::get('active', [OrderOfferController::class, 'active']);
                Route::post('{id}/accept', [OrderOfferController::class, 'accept'])->middleware(EnsureKycApproved::class);
                Route::post('{id}/reject', [OrderOfferController::class, 'reject']);

                Route::post('{id}/arrive-vendor', [OrderLifecycleController::class, 'arriveVendor'])->middleware(EnsureKycApproved::class);
                Route::post('{id}/pickup', [OrderLifecycleController::class, 'pickupOrder'])->middleware(EnsureKycApproved::class);
                Route::post('{id}/arrive-customer', [OrderLifecycleController::class, 'arriveCustomer'])->middleware(EnsureKycApproved::class);
                Route::post('{id}/confirm-delivery', [OrderLifecycleController::class, 'confirmDelivery'])->middleware(EnsureKycApproved::class);
            });

            // Financials & Earnings Ledger
            Route::prefix('earnings')->group(function () {
                Route::get('summary', [\App\Http\Controllers\Api\V1\Finance\EarningsController::class, 'summary']);
                Route::get('history', [\App\Http\Controllers\Api\V1\Finance\EarningsController::class, 'history']);
            });

            // COD Management & Remittance
            Route::prefix('cod')->group(function () {
                Route::get('summary', [\App\Http\Controllers\Api\V1\Finance\CodController::class, 'summary']);
                Route::get('orders', [\App\Http\Controllers\Api\V1\Finance\CodController::class, 'pendingOrders']);
                Route::post('handover', [\App\Http\Controllers\Api\V1\Finance\CodController::class, 'handover']);
            });

            // Payouts & Settlement Statements
            Route::prefix('payouts')->group(function () {
                Route::get('/', [\App\Http\Controllers\Api\V1\Finance\PayoutController::class, 'index']);
                Route::get('{id}', [\App\Http\Controllers\Api\V1\Finance\PayoutController::class, 'show']);
            });

            // Safety, SOS & Incidents
            Route::prefix('safety')->group(function () {
                Route::post('sos', [\App\Http\Controllers\Api\V1\Safety\SosController::class, 'triggerSos']);
                Route::post('incident', [\App\Http\Controllers\Api\V1\Safety\IncidentController::class, 'reportIncident']);
                Route::get('insurance', [\App\Http\Controllers\Api\V1\Safety\SosController::class, 'getInsurance']);
            });

            // Support Hub & Grievance Tickets
            Route::prefix('support')->group(function () {
                Route::get('tickets', [\App\Http\Controllers\Api\V1\Safety\SupportTicketController::class, 'index']);
                Route::post('tickets', [\App\Http\Controllers\Api\V1\Safety\SupportTicketController::class, 'store']);
                Route::get('tickets/{id}', [\App\Http\Controllers\Api\V1\Safety\SupportTicketController::class, 'show']);
            });

            // Performance Metrics & Ratings
            Route::prefix('performance')->group(function () {
                Route::get('/', [\App\Http\Controllers\Api\V1\Rider\PerformanceController::class, 'getMetrics']);
                Route::get('reviews', [\App\Http\Controllers\Api\V1\Rider\PerformanceController::class, 'getReviews']);
            });

            // Notifications Hub & FCM Device Registration
            Route::prefix('notifications')->group(function () {
                Route::get('/', [\App\Http\Controllers\Api\V1\Notification\NotificationController::class, 'index']);
                Route::patch('{id}/read', [\App\Http\Controllers\Api\V1\Notification\NotificationController::class, 'markAsRead']);
                Route::patch('read-all', [\App\Http\Controllers\Api\V1\Notification\NotificationController::class, 'markAllAsRead']);
            });

            Route::post('devices/register', [\App\Http\Controllers\Api\V1\Notification\NotificationController::class, 'registerDevice']);
        });

    });

});
