# Freska Delivery Partner Platform
# Module 05: Laravel 11 Backend Architecture & Clean Design

**Document ID**: `FRESKA-DOC-05`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  
**Framework**: PHP 8.3+ / Laravel 11.x  

---

## 1. Clean Layered Request Lifecycle

The Freska backend strictly follows the **Controller $\rightarrow$ Request Validation $\rightarrow$ DTO $\rightarrow$ Service $\rightarrow$ Repository $\rightarrow$ Model $\rightarrow$ Resource** pipeline.

```
+-------------------------------------------------------------------------------+
| Laravel Request Pipeline Execution Flow                                       |
+-------------------------------------------------------------------------------+
| [ Incoming HTTP Request ]                                                     |
|            |                                                                  |
|            v                                                                  |
| [ Routing & Middleware Pipeline ] (Sanctum, SingleDevice, MockLocationCheck)  |
|            |                                                                  |
|            v                                                                  |
| [ FormRequest Validation ] (Throws 422 JSON on validation failure)            |
|            |                                                                  |
|            v                                                                  |
| [ Controller Action ] (Converts Request to Strongly-Typed DTO)                |
|            |                                                                  |
|            v                                                                  |
| [ Domain Service Layer ] (Executes Business Rules, Transactions, Audits)      |
|            |                                                                  |
|            +---------------------------------+                                |
|            |                                 |                                |
|            v                                 v                                |
| [ Repository Layer ] (Eloquent/Redis)   [ Events & Jobs ] (Async Queues)      |
|            |                                 |                                |
|            v                                 v                                |
| [ Database Tier ] (MySQL 8.0 ACID)      [ Laravel Reverb ] (WebSockets WSS)   |
|            |                                                                  |
|            v                                                                  |
| [ Eloquent Model Loaded ]                                                     |
|            |                                                                  |
|            v                                                                  |
| [ API JsonResource Transformer ] (Data Masking, CamelCase Envelope)           |
|            |                                                                  |
|            v                                                                  |
| [ Outgoing HTTP JSON Response (200/201) ]                                     |
+-------------------------------------------------------------------------------+
```

---

## 2. SOLID Principles Implementation in Laravel 11

### 2.1 Single Responsibility Principle (SRP)
* **Controllers** do not query the database, calculate payouts, or send push notifications. Their sole job is handling HTTP transport.
* **Services** contain domain algorithms (e.g., `OrderLifecycleService` manages order state transitions only).
* **Repositories** contain storage queries only.

### 2.2 Open/Closed Principle (OCP)
* Notification channels and payout payment methods extend abstract drivers. For instance, `PayoutGatewayInterface` allows adding Stripe or Razorpay without modifying the core `PayoutDisbursementService`.

### 2.3 Liskov Substitution Principle (LSP)
* Repositories implement strict interfaces (e.g. `OrderRepositoryInterface`). A mock in-memory repository can replace the Eloquent repository in testing without altering service behavior.

### 2.4 Interface Segregation Principle (ISP)
* Instead of a bloated `RiderRepositoryInterface`, separate interfaces handle distinct needs: `RiderProfileInterface`, `RiderLocationInterface`, `RiderKycInterface`.

### 2.5 Dependency Inversion Principle (DIP)
* High-level modules (Services) depend on abstractions (Interfaces), not low-level implementations (Eloquent classes). Injected via Laravel's Service Container in `AppServiceProvider`:

```php
$this->app->bind(OrderRepositoryInterface::class, OrderRepository::class);
$this->app->bind(SmsServiceInterface::class, TwilioSmsService::class);
$this->app->bind(StorageServiceInterface::class, AwsS3StorageService::class);
```

---

## 3. Production Code Implementations of the Pipeline

### 3.1 Step 1: FormRequest Validation (`app/Http/Requests/V1/Order/ConfirmDeliveryRequest.php`)
```php
<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class ConfirmDeliveryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'otp' => ['required', 'string', 'size:4'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'proof_photo' => ['nullable', 'file', 'image', 'mimes:jpeg,png', 'max:5120'],
            'signature' => ['nullable', 'file', 'image', 'mimes:png', 'max:2048'],
        ];
    }
}
```

### 3.2 Step 2: Strongly-Typed DTO (`app/DTOs/Order/ConfirmDeliveryDTO.php`)
```php
<?php

declare(strict_types=1);

namespace App\DTOs\Order;

use Illuminate\Http\UploadedFile;

readonly class ConfirmDeliveryDTO
{
    public function __construct(
        public int $orderId,
        public int $riderId,
        public string $otp,
        public float $latitude,
        public float $longitude,
        public ?UploadedFile $proofPhoto,
        public ?UploadedFile $signature,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\App\Http\Requests\V1\Order\ConfirmDeliveryRequest $request, int $orderId): self
    {
        return new self(
            orderId: $orderId,
            riderId: (int) $request->user()->id,
            otp: (string) $request->input('otp'),
            latitude: (float) $request->input('latitude'),
            longitude: (float) $request->input('longitude'),
            proofPhoto: $request->file('proof_photo'),
            signature: $request->file('signature'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
```

### 3.3 Step 3: Domain Service Layer (`app/Services/Order/OrderLifecycleService.php`)
```php
<?php

declare(strict_types=1);

namespace App\Services\Order;

use App\DTOs\Order\ConfirmDeliveryDTO;
use App\Events\OrderStatusChanged;
use App\Exceptions\InvalidOrderStateException;
use App\Interfaces\Repositories\AuditLogRepositoryInterface;
use App\Interfaces\Repositories\CodRepositoryInterface;
use App\Interfaces\Repositories\EarningsRepositoryInterface;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\Order;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderLifecycleService
{
    public function __construct(
        private readonly OrderRepositoryInterface $orderRepository,
        private readonly CodRepositoryInterface $codRepository,
        private readonly EarningsRepositoryInterface $earningsRepository,
        private readonly AuditLogRepositoryInterface $auditLogRepository,
        private readonly StorageServiceInterface $storageService,
    ) {}

    public function confirmDelivery(ConfirmDeliveryDTO $dto): Order
    {
        $order = $this->orderRepository->findById($dto->orderId);

        if (!$order || $order->rider_id !== $dto->riderId) {
            throw new InvalidOrderStateException('Order does not belong to the active rider.');
        }

        if ($order->status !== 'picked_up') {
            throw new InvalidOrderStateException("Cannot deliver order with status '{$order->status}'.");
        }

        if ($order->delivery_otp !== $dto->otp) {
            throw ValidationException::withMessages(['otp' => 'Invalid customer delivery verification OTP.']);
        }

        return DB::transaction(function () use ($order, $dto) {
            $proofUrl = null;
            if ($dto->proofPhoto) {
                $proofUrl = $this->storageService->uploadProofOfDelivery($dto->proofPhoto, $order->id);
            }

            // 1. Advance Order State
            $updatedOrder = $this->orderRepository->updateStatus($order->id, 'delivered', [
                'delivered_at' => now(),
                'delivery_proof_photo_url' => $proofUrl,
            ]);

            // 2. Handle COD Collection
            if ($order->payment_mode === 'cod' && $order->cod_amount > 0) {
                $this->codRepository->createCollection([
                    'order_id' => $order->id,
                    'rider_id' => $dto->riderId,
                    'amount' => $order->cod_amount,
                    'collected_at' => now(),
                    'collection_latitude' => $dto->latitude,
                    'collection_longitude' => $dto->longitude,
                    'handover_status' => 'held_in_hand',
                ]);

                $order->rider->riderProfile()->increment('current_cash_in_hand', $order->cod_amount);
            }

            // 3. Post Earnings to Financial Ledger
            $this->earningsRepository->createEarning([
                'rider_id' => $dto->riderId,
                'order_id' => $order->id,
                'earning_type' => 'delivery_fee',
                'amount' => $order->total_rider_payout,
                'description' => "Payout for Order #{$order->order_number}",
                'date' => now()->toDateString(),
                'status' => 'pending',
            ]);

            $order->rider->riderProfile()->increment('completed_deliveries_count');

            // 4. Audit Log
            $this->auditLogRepository->log([
                'user_id' => $dto->riderId,
                'order_id' => $order->id,
                'action' => 'ORDER_DELIVERED',
                'latitude' => $dto->latitude,
                'longitude' => $dto->longitude,
                'ip_address' => $dto->ipAddress,
                'user_agent' => $dto->userAgent,
                'metadata' => ['payout' => $order->total_rider_payout, 'cod' => $order->cod_amount],
            ]);

            event(new OrderStatusChanged($updatedOrder, 'delivered'));

            return $updatedOrder;
        });
    }
}
```

### 3.4 Step 4: Controller Action (`app/Http/Controllers/Api/V1/Order/OrderLifecycleController.php`)
```php
<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Order;

use App\DTOs\Order\ConfirmDeliveryDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Order\ConfirmDeliveryRequest;
use App\Http\Resources\V1\OrderResource;
use App\Services\Order\OrderLifecycleService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;

class OrderLifecycleController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly OrderLifecycleService $lifecycleService
    ) {}

    public function confirmDelivery(ConfirmDeliveryRequest $request, int $id): JsonResponse
    {
        $dto = ConfirmDeliveryDTO::fromRequest($request, $id);
        $order = $this->lifecycleService->confirmDelivery($dto);

        return $this->successResponse(
            data: new OrderResource($order),
            message: 'Delivery completed successfully.'
        );
    }
}
```

---

## 4. Required Laravel Composer Packages (Part 10)

| Package | Version | Purpose | Advantages / Justification |
| :--- | :--- | :--- | :--- |
| `laravel/sanctum` | `^4.0` | API Token Authentication | Lightweight, built-in token expiration, ideal for mobile SPA/native auth with device metadata. |
| `laravel/reverb` | `^1.0` | Real-time WebSockets Server | High-performance async WebSocket server written directly in PHP for Laravel; zero external Pusher dependency. |
| `laravel/horizon` | `^5.24`| Redis Queue Management | Real-time metrics dashboard, auto-balancing workers, tag monitoring for order broadcasts and notifications. |
| `predis/predis` | `^2.2` | Redis Client Library | High-speed cache, pub/sub client, and geospatial (`GEOADD`) querying driver. |
| `league/flysystem-aws-s3-v3`| `^3.0` | S3 Cloud Object Storage | Secure S3 driver for storing rider KYC documents and proof-of-delivery photos with pre-signed URLs. |
| `kreait/laravel-firebase` | `^5.8` | Firebase Cloud Messaging | Sends high-priority push notifications and sound alerts directly to iOS & Android native clients. |
| `spatie/laravel-permission`| `^6.9` | Role-Based Access Control | Strict role separation (`rider`, `dispatcher`, `super_admin`) preventing unauthorized route access. |
| `spatie/laravel-activitylog`| `^4.8` | Audit Logging | Automatically logs model mutations, IP addresses, and state changes for compliance auditability. |
| `intervention/image` | `^3.7` | Image Processing | Compresses and sanitizes proof-of-delivery photos and KYC document uploads before S3 dispatch. |
| `phpstan/phpstan` | `^1.11`| Static Code Analysis | Enforces strict typing, eliminates null pointer exceptions, and ensures production code quality (Level 8). |
