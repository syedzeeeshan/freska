<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Models\MenuItem;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerVendorController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $lat = (float) $request->query('latitude', 12.971598);
        $lng = (float) $request->query('longitude', 77.594562);
        $category = $request->query('category');

        $query = Vendor::where('is_active', true);

        if ($category) {
            $words = explode(' ', str_replace(['&', '-', '/'], ' ', $category));
            $cleanWords = array_filter(array_map('trim', $words), fn($w) => strlen($w) > 2);
            $query->where(function ($q) use ($category, $cleanWords) {
                $q->where('category', 'like', "%{$category}%");
                foreach ($cleanWords as $word) {
                    $q->orWhere('category', 'like', "%{$word}%");
                }
                $q->orWhereHas('menuItems', function ($itemQ) use ($cleanWords) {
                    $itemQ->where(function ($iq) use ($cleanWords) {
                        foreach ($cleanWords as $w) {
                            $iq->orWhere('name', 'like', "%{$w}%")
                               ->orWhere('description', 'like', "%{$w}%");
                        }
                    });
                });
            });
        }

        $vendors = $query->with(['menuItems' => function ($q) {
            $q->where('is_available', true)->take(6);
        }])->get()->map(function ($vendor) use ($lat, $lng) {
            $distance = $this->calculateDistance($lat, $lng, (float) $vendor->latitude, (float) $vendor->longitude);
            $vendorArray = $vendor->toArray();
            $vendorArray['distance_km'] = round($distance, 1);
            return $vendorArray;
        })->sortBy('distance_km')->values();

        return response()->json([
            'success' => true,
            'message' => 'Vendors retrieved successfully.',
            'data' => $vendors,
            'meta' => [
                'timestamp' => now()->toISOString(),
                'version' => 'v1',
            ],
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $vendor = Vendor::where('is_active', true)
            ->with(['menuItems' => function ($q) {
                $q->with('category')->where('is_available', true);
            }])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Vendor details retrieved.',
            'data' => $vendor,
            'meta' => [
                'timestamp' => now()->toISOString(),
                'version' => 'v1',
            ],
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $q = trim((string) $request->query('q', ''));

        if ($q === '') {
            return response()->json([
                'success' => true,
                'data' => [
                    'vendors' => [],
                    'items' => [],
                ],
            ]);
        }

        $vendors = Vendor::where('is_active', true)
            ->where(function ($query) use ($q) {
                $query->where('name', 'like', "%{$q}%")
                    ->orWhere('category', 'like', "%{$q}%")
                    ->orWhere('address', 'like', "%{$q}%");
            })
            ->take(10)
            ->get();

        $items = MenuItem::where('is_available', true)
            ->where(function ($query) use ($q) {
                $query->where('name', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            })
            ->with(['vendor:id,name,rating,estimated_delivery_time,image_url', 'category:id,name'])
            ->take(20)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Search results retrieved.',
            'data' => [
                'query' => $q,
                'vendors' => $vendors,
                'items' => $items,
            ],
            'meta' => [
                'timestamp' => now()->toISOString(),
                'version' => 'v1',
            ],
        ]);
    }

    private function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371; // km
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}
