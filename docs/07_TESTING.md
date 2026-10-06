# Freska Delivery Partner Platform
# Module 07: Comprehensive Testing Strategy & Quality Engineering

**Document ID**: `FRESKA-DOC-07`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Testing Pyramid & Quality Gates

The platform enforces the standard testing pyramid with continuous quality gates in CI/CD:

```
                  / \
                 /   \
                / E2E \       <-- Integration Tests (Patrol / Flutter Driver)
               /-------\
              / Service \     <-- Feature & API Tests (PHPUnit / Pest)
             / & Widget  \    <-- Flutter Widget & Golden Tests
            /-------------\
           /   Unit Tests  \  <-- Dart Bloc/UseCase & PHP Unit Tests (80%+ Coverage)
          +-----------------+
```

---

## 2. Flutter Testing Strategy

### 2.1 Unit Tests (Blocs, UseCases, Repositories)
* Validates state transitions, error handling, and business use cases in isolation using `bloc_test` and `mocktail`.
* **Example Bloc Unit Test (`test/unit/order_offer_cubit_test.dart`)**:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/features/order_dispatch/presentation/blocs/order_offer_cubit.dart';
import 'package:freska_rider/features/order_dispatch/domain/repositories/order_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockOrderRepository;
  late OrderOfferCubit orderOfferCubit;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    orderOfferCubit = OrderOfferCubit(orderRepository: mockOrderRepository);
  });

  tearDown(() => orderOfferCubit.close());

  group('OrderOfferCubit Tests', () {
    const tOrderId = 10842;

    blocTest<OrderOfferCubit, OrderOfferState>(
      'emits [Accepting, Accepted] when acceptOrder succeeds',
      build: () {
        when(() => mockOrderRepository.acceptOrder(any(), any(), any()))
            .thenAnswer((_) async => Future.value());
        return orderOfferCubit;
      },
      act: (cubit) => cubit.acceptOffer(tOrderId, 12.971598, 77.594562),
      expect: () => [
        const OrderOfferState.accepting(),
        const OrderOfferState.accepted(),
      ],
    );
  });
}
```

### 2.2 Widget Tests (Component & Interaction Testing)
* Verifies individual widgets render accurately across multiple screen sizes and handle touch gestures properly.
* **Example Widget Test (`test/widget/swipe_action_button_test.dart`)**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/shared/widgets/buttons/swipe_action_button.dart';

void main() {
  testWidgets('SwipeActionButton triggers onSwipeComplete after threshold drag', (tester) async {
    bool swiped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SwipeActionButton(
              text: 'Swipe to Accept',
              icon: Icons.arrow_forward,
              onSwipeComplete: () async => swiped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Swipe to Accept'), findsOneWidget);

    // Perform horizontal drag gesture across the button
    final sliderFinder = find.byType(GestureDetector).first;
    await tester.drag(sliderFinder, const Offset(300.0, 0.0));
    await tester.pumpAndSettle();

    expect(swiped, isTrue);
  });
}
```

### 2.3 Golden Tests (Pixel-Perfect Google Stitch UI Consistency)
* Golden toolkit tests compare rasterized UI snapshots against approved reference images on CI to prevent visual regressions in dark and light Stitch themes.
* Flags any unexpected font wrapping, contrast errors, or layout shifts across Android and iOS render trees.

### 2.4 Mobile Integration Tests (End-to-End Delivery Flow)
* Uses `patrol` to execute end-to-end user journeys against real OS emulators:
  1. Login with OTP.
  2. Toggle Duty Online.
  3. Receive incoming order offer $\rightarrow$ Swipe to accept.
  4. Advance to vendor $\rightarrow$ Verify checklist items $\rightarrow$ Swipe to pickup.
  5. Advance to customer $\rightarrow$ Input OTP $\rightarrow$ Complete delivery.

---

## 3. Laravel Testing Strategy

### 3.1 Feature & API Tests (`tests/Feature/OrderLifecycleTest.php`)
* Validates full HTTP request-response cycles, database state mutations, authentication, and validation errors using an isolated testing MySQL/SQLite database in memory.

```php
<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderLifecycleTest extends TestCase
{
    use RefreshDatabase;

    private User $rider;
    private Vendor $vendor;
    private Order $order;

    protected function setUp(): void
    {
        parent::setUp();

        $this->rider = User::factory()->create(['role' => 'rider', 'status' => 'active']);
        $this->rider->riderProfile()->create([
            'is_online' => true,
            'kyc_status' => 'verified',
            'current_cash_in_hand' => 0.00,
        ]);

        $this->vendor = Vendor::factory()->create();
        $this->order = Order::factory()->create([
            'vendor_id' => $this->vendor->id,
            'status' => 'offered',
            'delivery_otp' => '4921',
            'cod_amount' => 350.00,
            'payment_mode' => 'cod',
            'total_rider_payout' => 55.00,
        ]);
    }

    public function test_rider_can_accept_offered_order(): void
    {
        $response = $this->actingAs($this->rider, 'sanctum')
            ->postJson("/api/v1/rider/orders/{$this->order->id}/accept", [
                'latitude' => 12.971598,
                'longitude' => 77.594562,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'accepted');

        $this->assertDatabaseHas('orders', [
            'id' => $this->order->id,
            'rider_id' => $this->rider->id,
            'status' => 'accepted',
        ]);

        $this->assertDatabaseHas('audit_logs', [
            'order_id' => $this->order->id,
            'action' => 'ORDER_ACCEPTED',
        ]);
    }

    public function test_delivery_fails_with_invalid_customer_otp(): void
    {
        $this->order->update([
            'rider_id' => $this->rider->id,
            'status' => 'picked_up',
        ]);

        $response = $this->actingAs($this->rider, 'sanctum')
            ->postJson("/api/v1/rider/orders/{$this->order->id}/confirm-delivery", [
                'otp' => '0000', // Invalid OTP
                'latitude' => 12.912118,
                'longitude' => 77.644554,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['otp']);
    }

    public function test_successful_delivery_updates_cod_and_earnings_ledger(): void
    {
        $this->order->update([
            'rider_id' => $this->rider->id,
            'status' => 'picked_up',
        ]);

        $response = $this->actingAs($this->rider, 'sanctum')
            ->postJson("/api/v1/rider/orders/{$this->order->id}/confirm-delivery", [
                'otp' => '4921',
                'latitude' => 12.912118,
                'longitude' => 77.644554,
            ]);

        $response->assertStatus(200);

        // Verify COD collection recorded
        $this->assertDatabaseHas('cod_collections', [
            'order_id' => $this->order->id,
            'rider_id' => $this->rider->id,
            'amount' => 350.00,
            'handover_status' => 'held_in_hand',
        ]);

        // Verify Earnings ledger credited
        $this->assertDatabaseHas('rider_earnings', [
            'order_id' => $this->order->id,
            'rider_id' => $this->rider->id,
            'amount' => 55.00,
            'status' => 'pending',
        ]);
    }
}
```

### 3.2 Load & Concurrency Testing (k6)
* Load tests execute against staging to simulate peak dispatch surges:
  * **Target**: 5,000 concurrent riders broadcasting GPS heartbeats every 15s.
  * **Target**: 500 orders offered concurrently per minute.
  * **SLA**: 99% of requests respond in $< 200\text{ms}$ with zero deadlocks on database transactions.

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 1000 },
    { duration: '5m', target: 5000 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  const payload = JSON.stringify({
    latitude: 12.971598,
    longitude: 77.594562,
    heading: 90,
    speed: 25,
    is_mock: false,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${__ENV.SANCTUM_TOKEN}`,
      'X-Device-Id': 'test-uuid',
    },
  };

  const res = http.post('https://staging-api.freska.app/api/v1/rider/location', payload, params);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(15);
}
```
