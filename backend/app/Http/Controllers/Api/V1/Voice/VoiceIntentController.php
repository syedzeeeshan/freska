<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Voice;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VoiceIntentController extends Controller
{
    public function process(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'query' => 'required|string|max:500',
            'role' => 'required|in:customer,vendor,rider',
        ]);

        $query = strtolower(trim($validated['query']));
        $role = $validated['role'];
        $user = $request->user();

        // Check user role authorization
        if ($user && $user->role && $user->role->value !== $role && !$user->role->isAdministrative()) {
            return response()->json([
                'success' => false,
                'message' => 'Role unauthorized for requested voice intent scope.',
                'error_code' => 'ERR_UNAUTHORIZED_VOICE_ROLE',
            ], 403);
        }

        return match ($role) {
            'customer' => $this->handleCustomerVoice($query, $user),
            'vendor' => $this->handleVendorVoice($query, $user),
            'rider' => $this->handleRiderVoice($query, $user),
        };
    }

    private function handleCustomerVoice(string $q, $user): JsonResponse
    {
        // 1. Search / Find items or food
        if (str_contains($q, 'find') || str_contains($q, 'search') || str_contains($q, 'looking for') || str_contains($q, 'want')) {
            $keyword = preg_replace('/^(find|search for|search|looking for|i want|show me)\s+/i', '', $q);
            $keyword = trim($keyword, " .?!");

            $items = MenuItem::where('is_available', true)
                ->where(function ($query) use ($keyword) {
                    $query->where('name', 'like', "%{$keyword}%")
                        ->orWhere('description', 'like', "%{$keyword}%");
                })->take(5)->get();

            $vendors = Vendor::where('is_active', true)
                ->where('name', 'like', "%{$keyword}%")
                ->take(3)->get();

            $count = $items->count() + $vendors->count();
            $spoken = $count > 0
                ? "Found {$count} items and stores matching '{$keyword}'."
                : "I couldn't find any items matching '{$keyword}'.";

            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'SEARCH_FOOD',
                    'keyword' => $keyword,
                    'spoken_response' => $spoken,
                    'requires_confirmation' => false,
                    'target_route' => '/search?q=' . urlencode($keyword),
                    'results' => [
                        'items' => $items,
                        'vendors' => $vendors,
                    ],
                ],
            ]);
        }

        // 2. Track / Where is my order
        if (str_contains($q, 'track') || str_contains($q, 'where is my') || str_contains($q, 'order status') || str_contains($q, 'rider')) {
            $activeOrder = Order::where('customer_id', $user ? $user->id : 0)
                ->whereNotIn('status', [OrderStatus::DELIVERED, OrderStatus::CANCELLED, OrderStatus::REJECTED])
                ->latest()
                ->first();

            if ($activeOrder) {
                $statusText = $activeOrder->status->label();
                $spoken = "Your order #{$activeOrder->order_number} is currently {$statusText}.";
                return response()->json([
                    'success' => true,
                    'data' => [
                        'intent' => 'TRACK_ORDER',
                        'order_id' => $activeOrder->id,
                        'spoken_response' => $spoken,
                        'requires_confirmation' => false,
                        'target_route' => "/orders/{$activeOrder->id}/track",
                        'order' => $activeOrder,
                    ],
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'TRACK_ORDER',
                    'spoken_response' => "You don't have any active orders right now.",
                    'requires_confirmation' => false,
                    'target_route' => '/orders',
                ],
            ]);
        }

        // 3. Cart commands
        if (str_contains($q, 'cart') || str_contains($q, 'what is in my cart') || str_contains($q, 'basket')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'OPEN_CART',
                    'spoken_response' => "Opening your cart.",
                    'requires_confirmation' => false,
                    'target_route' => '/cart',
                ],
            ]);
        }

        // 4. Order history
        if (str_contains($q, 'recent orders') || str_contains($q, 'order history') || str_contains($q, 'past orders')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'ORDER_HISTORY',
                    'spoken_response' => "Opening your past orders.",
                    'requires_confirmation' => false,
                    'target_route' => '/orders',
                ],
            ]);
        }

        // 5. Saved addresses
        if (str_contains($q, 'address') || str_contains($q, 'saved locations')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'OPEN_ADDRESSES',
                    'spoken_response' => "Showing your saved addresses.",
                    'requires_confirmation' => false,
                    'target_route' => '/addresses',
                ],
            ]);
        }

        // Default fallback
        return response()->json([
            'success' => true,
            'data' => [
                'intent' => 'GENERAL_QUERY',
                'spoken_response' => "You can ask me to search for food, check your cart, or track your order.",
                'requires_confirmation' => false,
            ],
        ]);
    }

    private function handleVendorVoice(string $q, $user): JsonResponse
    {
        $vendor = $user ? (Vendor::where('user_id', $user->id)->first() ?? Vendor::first()) : Vendor::first();

        // 1. Pending / New orders
        if (str_contains($q, 'new order') || str_contains($q, 'pending order') || str_contains($q, 'how many orders') || str_contains($q, 'orders')) {
            $pendingCount = $vendor ? Order::where('vendor_id', $vendor->id)->whereIn('status', [OrderStatus::CREATED, OrderStatus::ACCEPTED])->count() : 0;
            $spoken = "You have {$pendingCount} active orders requiring preparation.";

            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'SHOW_ORDERS',
                    'count' => $pendingCount,
                    'spoken_response' => $spoken,
                    'requires_confirmation' => false,
                    'target_route' => '/vendor/orders',
                ],
            ]);
        }

        // 2. Today's sales / Earnings
        if (str_contains($q, 'sales') || str_contains($q, 'earn') || str_contains($q, 'revenue') || str_contains($q, 'how much')) {
            $todaySales = $vendor ? Order::where('vendor_id', $vendor->id)->whereDate('created_at', now()->today())->where('status', OrderStatus::DELIVERED)->sum('subtotal') : 0;
            $spoken = "Your sales today are ₹" . number_format((float) $todaySales, 2) . ".";

            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'SHOW_SALES',
                    'sales' => $todaySales,
                    'spoken_response' => $spoken,
                    'requires_confirmation' => false,
                    'target_route' => '/vendor/earnings',
                ],
            ]);
        }

        // 3. Mark order ready (High-Risk action requires confirmation)
        if (str_contains($q, 'ready') || str_contains($q, 'mark order')) {
            preg_match('/\d+/', $q, $matches);
            $orderId = !empty($matches[0]) ? (int) $matches[0] : null;

            if ($orderId) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'intent' => 'MARK_ORDER_READY',
                        'order_id' => $orderId,
                        'spoken_response' => "You are about to mark order #{$orderId} as ready for pickup. Please confirm.",
                        'requires_confirmation' => true,
                        'confirmation_prompt' => "Confirm marking order #{$orderId} as ready?",
                    ],
                ]);
            }
        }

        // 4. Business open/close
        if (str_contains($q, 'close business') || str_contains($q, 'close store')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'TOGGLE_STORE_STATUS',
                    'action' => 'close',
                    'spoken_response' => "You are about to close your store and stop accepting new orders. Please confirm.",
                    'requires_confirmation' => true,
                    'confirmation_prompt' => "Close store now?",
                ],
            ]);
        }

        // Fallback
        return response()->json([
            'success' => true,
            'data' => [
                'intent' => 'VENDOR_GENERAL',
                'spoken_response' => "You can ask for new orders, today's sales, or open your menu.",
                'requires_confirmation' => false,
            ],
        ]);
    }

    private function handleRiderVoice(string $q, $user): JsonResponse
    {
        // 1. Duty Online / Offline
        if (str_contains($q, 'go online') || str_contains($q, 'start duty')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'TOGGLE_DUTY_ONLINE',
                    'spoken_response' => "Switching duty status to Online. Searching for delivery orders.",
                    'requires_confirmation' => false,
                    'target_action' => 'GO_ONLINE',
                ],
            ]);
        }

        if (str_contains($q, 'go offline') || str_contains($q, 'stop duty')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'TOGGLE_DUTY_OFFLINE',
                    'spoken_response' => "Switching duty status to Offline.",
                    'requires_confirmation' => false,
                    'target_action' => 'GO_OFFLINE',
                ],
            ]);
        }

        // 2. Current order / Navigation
        if (str_contains($q, 'order') || str_contains($q, 'current') || str_contains($q, 'navigation') || str_contains($q, 'navigate')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'SHOW_CURRENT_ORDER',
                    'spoken_response' => "Opening active order cockpit and navigation.",
                    'requires_confirmation' => false,
                    'target_route' => '/orders/delivery',
                ],
            ]);
        }

        // 3. Earnings
        if (str_contains($q, 'earning') || str_contains($q, 'payout') || str_contains($q, 'how much')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'SHOW_EARNINGS',
                    'spoken_response' => "Opening your earnings ledger.",
                    'requires_confirmation' => false,
                    'target_route' => '/earnings',
                ],
            ]);
        }

        // 4. Repeat instruction
        if (str_contains($q, 'repeat') || str_contains($q, 'again')) {
            return response()->json([
                'success' => true,
                'data' => [
                    'intent' => 'REPEAT_NAVIGATION',
                    'spoken_response' => "Repeating last navigation instruction.",
                    'requires_confirmation' => false,
                    'target_action' => 'REPEAT_TTS',
                ],
            ]);
        }

        // Fallback
        return response()->json([
            'success' => true,
            'data' => [
                'intent' => 'RIDER_GENERAL',
                'spoken_response' => "You can say 'Go online', 'Show current order', or 'Show earnings'.",
                'requires_confirmation' => false,
            ],
        ]);
    }
}
