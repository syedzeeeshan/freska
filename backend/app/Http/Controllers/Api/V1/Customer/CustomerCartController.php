<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\MenuItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerCartController extends Controller
{
    public function getCart(Request $request): JsonResponse
    {
        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)
            ->with(['vendor:id,name,address,estimated_delivery_time,image_url', 'items.menuItem'])
            ->first();

        if (!$cart) {
            return response()->json([
                'success' => true,
                'data' => [
                    'items' => [],
                    'item_count' => 0,
                    'subtotal' => 0.00,
                    'delivery_fee' => 0.00,
                    'taxes' => 0.00,
                    'discount_amount' => 0.00,
                    'total_amount' => 0.00,
                    'vendor' => null,
                ],
            ]);
        }

        $subtotal = 0.00;
        $itemCount = 0;
        $isColdChain = false;
        $isFragile = false;

        foreach ($cart->items as $item) {
            $subtotal += (float) $item->unit_price * $item->quantity;
            $itemCount += $item->quantity;
            if ($item->menuItem && $item->menuItem->is_cold_chain) {
                $isColdChain = true;
            }
            if ($item->menuItem && $item->menuItem->is_fragile) {
                $isFragile = true;
            }
        }

        $deliveryFee = $subtotal > 0 ? ($subtotal >= 500 ? 0.00 : 40.00) : 0.00;
        $taxes = round($subtotal * 0.05, 2); // 5% GST
        $discount = (float) $cart->discount_amount;
        $total = max(0.00, round($subtotal + $deliveryFee + $taxes - $discount, 2));

        return response()->json([
            'success' => true,
            'message' => 'Cart retrieved successfully.',
            'data' => [
                'id' => $cart->id,
                'vendor' => $cart->vendor,
                'items' => $cart->items,
                'item_count' => $itemCount,
                'subtotal' => round($subtotal, 2),
                'delivery_fee' => $deliveryFee,
                'taxes' => $taxes,
                'discount_amount' => $discount,
                'total_amount' => $total,
                'is_cold_chain' => $isColdChain,
                'is_fragile' => $isFragile,
                'coupon_code' => $cart->coupon_code,
            ],
            'meta' => [
                'timestamp' => now()->toISOString(),
                'version' => 'v1',
            ],
        ]);
    }

    public function addItem(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'menu_item_id' => 'required|exists:menu_items,id',
            'quantity' => 'nullable|integer|min:1',
            'selected_variants' => 'nullable|array',
            'selected_addons' => 'nullable|array',
            'special_instructions' => 'nullable|string|max:255',
        ]);

        $user = $request->user();
        $menuItem = MenuItem::findOrFail($validated['menu_item_id']);
        $quantity = $validated['quantity'] ?? 1;

        $cart = Cart::firstOrCreate(
            ['user_id' => $user->id],
            ['vendor_id' => $menuItem->vendor_id]
        );

        // If cart has items from another vendor, clear it or update vendor
        if ($cart->vendor_id !== $menuItem->vendor_id) {
            $cart->items()->delete();
            $cart->vendor_id = $menuItem->vendor_id;
            $cart->save();
        }

        $existingItem = CartItem::where('cart_id', $cart->id)
            ->where('menu_item_id', $menuItem->id)
            ->first();

        $effectivePrice = $menuItem->discount_price ?? $menuItem->price;

        if ($existingItem) {
            $existingItem->quantity += $quantity;
            $existingItem->save();
        } else {
            CartItem::create([
                'cart_id' => $cart->id,
                'menu_item_id' => $menuItem->id,
                'quantity' => $quantity,
                'unit_price' => $effectivePrice,
                'selected_variants' => $validated['selected_variants'] ?? null,
                'selected_addons' => $validated['selected_addons'] ?? null,
                'special_instructions' => $validated['special_instructions'] ?? null,
            ]);
        }

        return $this->getCart($request);
    }

    public function updateQuantity(Request $request, int $itemId): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|min:0',
        ]);

        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)->firstOrFail();
        $item = CartItem::where('cart_id', $cart->id)->where('id', $itemId)->firstOrFail();

        if ($validated['quantity'] <= 0) {
            $item->delete();
        } else {
            $item->quantity = $validated['quantity'];
            $item->save();
        }

        return $this->getCart($request);
    }

    public function removeItem(Request $request, int $itemId): JsonResponse
    {
        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)->firstOrFail();
        CartItem::where('cart_id', $cart->id)->where('id', $itemId)->delete();

        return $this->getCart($request);
    }

    public function clear(Request $request): JsonResponse
    {
        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)->first();
        if ($cart) {
            $cart->items()->delete();
            $cart->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Cart cleared.',
            'data' => [
                'items' => [],
                'item_count' => 0,
                'subtotal' => 0.00,
                'delivery_fee' => 0.00,
                'taxes' => 0.00,
                'discount_amount' => 0.00,
                'total_amount' => 0.00,
                'vendor' => null,
            ],
        ]);
    }
}
