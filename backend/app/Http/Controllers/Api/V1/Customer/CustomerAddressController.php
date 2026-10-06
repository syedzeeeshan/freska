<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Models\CustomerAddress;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerAddressController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $addresses = CustomerAddress::where('user_id', $user->id)
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Addresses retrieved successfully.',
            'data' => $addresses,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'label' => 'required|string|max:50',
            'recipient_name' => 'nullable|string|max:100',
            'recipient_phone' => 'nullable|string|max:20',
            'address_line' => 'required|string|max:500',
            'area' => 'required|string|max:100',
            'landmark' => 'nullable|string|max:150',
            'city' => 'nullable|string|max:100',
            'pincode' => 'nullable|string|max:20',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'is_default' => 'nullable|boolean',
        ]);

        $user = $request->user();

        if (!empty($validated['is_default'])) {
            CustomerAddress::where('user_id', $user->id)->update(['is_default' => false]);
        }

        $address = CustomerAddress::create([
            'user_id' => $user->id,
            'label' => $validated['label'],
            'recipient_name' => $validated['recipient_name'] ?? $user->name,
            'recipient_phone' => $validated['recipient_phone'] ?? $user->phone,
            'address_line' => $validated['address_line'],
            'area' => $validated['area'],
            'landmark' => $validated['landmark'] ?? null,
            'city' => $validated['city'] ?? 'Bengaluru',
            'pincode' => $validated['pincode'] ?? '560034',
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'is_default' => $validated['is_default'] ?? false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Address saved successfully.',
            'data' => $address,
        ], 201);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        $address = CustomerAddress::where('user_id', $user->id)->where('id', $id)->firstOrFail();
        $address->delete();

        return response()->json([
            'success' => true,
            'message' => 'Address deleted successfully.',
        ]);
    }

    public function setDefault(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        CustomerAddress::where('user_id', $user->id)->update(['is_default' => false]);
        $address = CustomerAddress::where('user_id', $user->id)->where('id', $id)->firstOrFail();
        $address->is_default = true;
        $address->save();

        return response()->json([
            'success' => true,
            'message' => 'Default address updated.',
            'data' => $address,
        ]);
    }
}
