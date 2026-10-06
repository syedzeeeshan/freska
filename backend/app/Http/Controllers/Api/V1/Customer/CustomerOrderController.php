<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Enums\OrderStatus;
use App\Enums\OrderType;
use App\Enums\PaymentMode;
use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CustomerAddress;
use App\Models\Order;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CustomerOrderController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'address_id' => 'required|exists:customer_addresses,id',
            'payment_mode' => 'required|in:cod,online,upi,wallet',
            'delivery_instructions' => 'nullable|string|max:500',
        ]);

        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)
            ->with(['items.menuItem', 'vendor'])
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Your cart is empty. Please add items before checking out.',
                'error_code' => 'ERR_CART_EMPTY',
            ], 422);
        }

        $address = CustomerAddress::where('user_id', $user->id)
            ->where('id', $validated['address_id'])
            ->firstOrFail();

        $subtotal = 0.00;
        $itemsList = [];
        $isColdChain = false;
        $isFragile = false;

        foreach ($cart->items as $item) {
            $itemSubtotal = (float) $item->unit_price * $item->quantity;
            $subtotal += $itemSubtotal;

            $itemsList[] = [
                'menu_item_id' => $item->menu_item_id,
                'name' => $item->menuItem->name,
                'quantity' => $item->quantity,
                'price' => (float) $item->unit_price,
                'subtotal' => $itemSubtotal,
            ];

            if ($item->menuItem && $item->menuItem->is_cold_chain) {
                $isColdChain = true;
            }
            if ($item->menuItem && $item->menuItem->is_fragile) {
                $isFragile = true;
            }
        }

        $deliveryFee = $subtotal >= 500 ? 0.00 : 40.00;
        $taxes = round($subtotal * 0.05, 2);
        $discount = (float) $cart->discount_amount;
        $totalAmount = max(0.00, round($subtotal + $deliveryFee + $taxes - $discount, 2));

        $orderNumber = 'FSK-' . date('Y') . '-' . strtoupper(Str::random(6));
        $deliveryOtp = str_pad((string) random_int(1000, 9999), 4, '0', STR_PAD_LEFT);

        $order = Order::create([
            'order_number' => $orderNumber,
            'customer_id' => $user->id,
            'customer_address_id' => $address->id,
            'vendor_id' => $cart->vendor_id,
            'customer_name' => $address->recipient_name ?: $user->name ?: 'Freska Customer',
            'customer_phone' => $address->recipient_phone ?: $user->phone,
            'delivery_address' => $address->address_line . ', ' . $address->area . ', ' . $address->city . ' ' . $address->pincode,
            'delivery_area' => $address->area,
            'delivery_latitude' => $address->latitude,
            'delivery_longitude' => $address->longitude,
            'delivery_instructions' => $validated['delivery_instructions'] ?? 'Leave at door',
            'order_type' => $isColdChain ? OrderType::DAIRY_COLD_CHAIN : OrderType::EXPRESS,
            'item_count' => count($itemsList),
            'package_details' => [
                'item_count' => count($itemsList),
                'is_fragile' => $isFragile,
                'is_cold_chain' => $isColdChain,
                'items' => $itemsList,
            ],
            'is_fragile' => $isFragile,
            'is_cold_chain' => $isColdChain,
            'status' => OrderStatus::CREATED,
            'payment_mode' => $validated['payment_mode'] === 'cod' ? PaymentMode::COD : PaymentMode::PREPAID,
            'cod_amount' => $validated['payment_mode'] === 'cod' ? $totalAmount : 0.00,
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'taxes' => $taxes,
            'discount_amount' => $discount,
            'total_amount' => $totalAmount,
            'delivery_otp' => $deliveryOtp,
            'estimated_distance_km' => 3.5,
            'estimated_duration_mins' => 25,
            'base_payout' => 45.00,
            'distance_payout' => 15.00,
            'surge_payout' => 0.00,
            'total_rider_payout' => 60.00,
        ]);

        // Empty customer cart
        $cart->items()->delete();
        $cart->delete();

        return response()->json([
            'success' => true,
            'message' => 'Order placed successfully.',
            'data' => $order->load(['vendor', 'customer']),
            'meta' => [
                'timestamp' => now()->toISOString(),
                'version' => 'v1',
            ],
        ], 201);
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $orders = Order::where('customer_id', $user->id)
            ->with(['vendor:id,name,category,image_url,address', 'rider:id,name,phone'])
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully.',
            'data' => $orders->items(),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::where('customer_id', $user->id)
            ->with(['vendor', 'rider:id,name,phone,avatar_url', 'rider.riderProfile'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Order details retrieved.',
            'data' => $order,
        ]);
    }

    public function track(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::where('customer_id', $user->id)
            ->with(['vendor:id,name,phone,address,latitude,longitude', 'rider:id,name,phone', 'rider.riderProfile'])
            ->findOrFail($id);

        $riderTelemetry = null;
        if ($order->rider && $order->rider->riderProfile) {
            $riderTelemetry = [
                'rider_id' => $order->rider->id,
                'name' => $order->rider->name,
                'phone' => $order->rider->phone,
                'vehicle_number' => $order->rider->riderProfile->vehicle_number,
                'current_latitude' => $order->rider->riderProfile->current_latitude,
                'current_longitude' => $order->rider->riderProfile->current_longitude,
                'rating' => $order->rider->riderProfile->rating_average,
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Order tracking data retrieved.',
            'data' => [
                'order' => $order,
                'status' => $order->status->value,
                'status_label' => $order->status->label(),
                'is_active' => $order->status->isActive() || $order->status === OrderStatus::CREATED || $order->status === OrderStatus::DISPATCHED,
                'delivery_otp' => $order->delivery_otp,
                'rider' => $riderTelemetry,
                'vendor' => $order->vendor,
            ],
        ]);
    }
}
