# Freska Delivery Partner Platform
# Module 04: Flutter Application Architecture & Screen Specifications

**Document ID**: `FRESKA-DOC-04`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  
**Target Runtime**: Flutter 3.24+ / Dart 3.5+  
**Design System**: Google Stitch Design Language (Material 3 Dark Elevation, Emerald `#059669` accents)  

---

## 1. State Management Architecture (flutter_bloc)

The mobile client strictly separates Business Logic from UI rendering using `flutter_bloc` and `hydrated_bloc`.

```
+-------------------------------------------------------------------------------+
| State Management Dataflow                                                     |
+-------------------------------------------------------------------------------+
| [ UI View / Widget ] ---> ( Dispatches Event ) ---> [ Feature Bloc / Cubit ]  |
|                                                              |                |
|                                                              v                |
| [ UI Rebuilds via BlocBuilder ] <--- ( Emits State ) <--- [ Domain UseCase ]  |
|                                                              |                |
|                                                              v                |
|                                                     [ Repository Interface ]  |
|                                                              |                |
|                                      +-----------------------+                |
|                                      |                                        |
|                                      v                                        |
|                     [ Remote DataSource (Dio API) ]  [ Local DataSource (Hive)]
+-------------------------------------------------------------------------------+
```

### 1.1 Dependency Injection Configuration (`lib/core/di/injection.dart`)
Dependencies are registered as lazy singletons and factories using `get_it`:

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core Network & Storage
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl(), secureStorage: sl()));
  sl.registerLazySingleton<HiveStorageService>(() => HiveStorageService());

  // Data Sources
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<OrderLocalDataSource>(() => OrderLocalDataSourceImpl(hiveService: sl()));

  // Repositories
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Blocs & Cubits
  sl.registerFactory(() => OrderLifecycleBloc(orderRepository: sl()));
  sl.registerFactory(() => DutyBloc(riderRepository: sl(), locationService: sl()));
}
```

### 1.2 HydratedBloc Offline Persistence Strategy
Critical state (active order progress, duty online state, cached earnings summary) extends `HydratedBloc` to withstand app crashes, OS process terminations, and loss of cellular connectivity:

```dart
class DutyBloc extends HydratedBloc<DutyEvent, DutyState> {
  final RiderRepository riderRepository;

  DutyBloc({required this.riderRepository}) : super(const DutyState.initial()) {
    on<ToggleDutyEvent>(_onToggleDuty);
  }

  @override
  DutyState? fromJson(Map<String, dynamic> json) {
    try {
      return DutyState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DutyState state) {
    return state.toJson();
  }
}
```

---

## 2. Screen Specifications (Screens 01 to 15)

### Screen 01: Phone Login & OTP Screen (Slides 02 & 14)
* **Purpose**: Primary gateway for mobile authentication; sends 6-digit OTP and authenticates rider with device binding.
* **UI Components**:
  * Stitch logo with emerald glow animation.
  * Country code picker with auto-formatting phone input.
  * 6-box PIN code input field (`PinCodeTextField`) with numeric keypad.
  * Resend OTP countdown ticker (60 seconds).
* **Widgets Used**: `Scaffold`, `StitchTextField`, `PinCodeTextField`, `StitchPrimaryButton`, `AnimatedOpacity`.
* **Bloc/Cubit**: `AuthBloc` (Events: `SendOtpEvent`, `VerifyOtpEvent`; States: `AuthInitial`, `OtpSending`, `OtpSent`, `VerifyingOtp`, `Authenticated`, `AuthError`).
* **Repository Calls**: `AuthRepository.sendOtp(phone)`, `AuthRepository.verifyOtp(phone, otp, deviceInfo)`.
* **API Used**: `POST /auth/otp/send`, `POST /auth/otp/verify`.
* **Validation**: E.164 phone regex (`^\+[1-9]\d{1,14}$`), exactly 6 numeric digits for OTP.
* **Navigation**: On success $\rightarrow$ Checks `user.status`. If `'pending_kyc'`, routes to `/onboarding/kyc`; if `'active'`, routes to `/dashboard`.
* **Loading States**: Button shows inline centered circular progress indicator; inputs disabled.
* **Error States**: Shaking animation on OTP input box on failure; custom warning snackbar displaying backend message.
* **Offline Handling**: Disables verification; displays `OfflineIndicatorBanner` at top edge.
* **Accessibility**: `Semantics` tags on OTP fields; high-contrast text ratios exceeding 4.5:1.
* **Animations**: Fade transition on OTP field reveal; smooth progress bar on 60s countdown.
* **Responsive Behavior**: Adjusts keyboard offset dynamically using `SingleChildScrollView` and bottom padding.

---

### Screen 02: Rider KYC & Document Upload Screen (Slide 02)
* **Purpose**: Captures vehicle details, driving license front/back, vehicle RC book, and Aadhaar/PAN cards.
* **UI Components**:
  * Step progress tracker (1: Vehicle, 2: License, 3: ID Proof).
  * Document capture card with camera preview guide and upload checkmark.
  * Expiry date picker modal.
* **Widgets Used**: `Stepper`, `StitchSurfaceCard`, `ImagePicker`, `CustomDropdownButtonFormField`.
* **Bloc/Cubit**: `KycCubit` (Manages file paths, document compression, multi-part upload progress).
* **Repository Calls**: `RiderRepository.uploadKycDocuments(KycDto)`.
* **API Used**: `POST /rider/documents`.
* **Validation**: Files must be JPG/PNG/PDF, size $\le 5$MB; license expiry date must be in future.
* **Navigation**: Routes to Bank Details screen upon completion.
* **Loading States**: Percentage upload indicator on each document card (e.g. `Uploading: 68%`).
* **Error States**: Highlighted red border on rejected file formats; retry tap action.
* **Offline Handling**: Images compressed and queued locally in Hive until network restores.

---

### Screen 03: Rider Home / Dashboard Screen (Slide 03)
* **Purpose**: Central cockpit for the rider; toggles Online/Offline duty, shows today's earnings and delivery counts, sticky active order card, and SOS quick trigger.
* **UI Components**:
  * **Online/Offline Tactile Switch**: Custom animated toggle with emerald green glow for online, slate gray for offline.
  * **Today's Metric Carousel**: Total earnings card, delivered count card, active hours card.
  * **Persistent Active Order Floating Sheet**: Displays active status (`Accepted`, `Picked Up`, `In Transit`) if an order is active.
  * **Floating Support & SOS Action Buttons**: Quick-dial floating triggers.
* **Widgets Used**: `AnimatedContainer`, `DraggableScrollableSheet`, `StitchSurfaceCard`, `GestureDetector`.
* **Bloc/Cubit**: `DutyBloc`, `DashboardSummaryCubit`, `OrderLifecycleBloc`.
* **Repository Calls**: `RiderRepository.toggleDuty(isOnline, lat, lng)`, `RiderRepository.getDashboardSummary()`.
* **API Used**: `POST /rider/duty/toggle`, `GET /rider/dashboard/summary`, `POST /rider/location`.
* **Validation**: Duty toggle blocked if KYC status is not `verified` or if location permission is denied.
* **Navigation**: Tapping sticky order card navigates to active navigation map view.
* **Loading States**: Shimmer effect on metrics cards during pull-to-refresh.
* **Offline Handling**: Shows warning banner: *"GPS active. Reconnecting to Freska dispatch engine..."*
* **Animations**: Pulse animation on Online status badge; smooth height expand on active order banner.

---

### Screen 04: Incoming Order Offer Screen (Slide 04)
* **Purpose**: Full-screen modal alert notifying rider of a new delivery assignment; enforces 30-second decision timer.
* **UI Components**:
  * Circular countdown ring with remaining seconds in tabular figures.
  * High-visibility payout badge: `₹68.00` in gold typography.
  * Distance indicator: Total kilometers and estimated travel duration.
  * Pickup and delivery generalized location labels.
  * **SwipeActionButton**: "Swipe to Accept" horizontal slider.
  * Decline text button opening rejection reason bottom sheet.
* **Widgets Used**: `Dialog`, `CircularProgressIndicator`, `SwipeActionButton`, `SlideTransition`.
* **Bloc/Cubit**: `OrderOfferCubit` (Initializes 30s timer, triggers audio alert loop, handles accept/reject).
* **Repository Calls**: `OrderRepository.acceptOrder(id, lat, lng)`, `OrderRepository.rejectOrder(id, reason)`.
* **API Used**: `POST /rider/orders/{id}/accept`, `POST /rider/orders/{id}/reject`.
* **Validation**: Prevents swipe interaction once timer hits 0.
* **Navigation**: On accept $\rightarrow$ Closes modal and pushes `/orders/vendor-pickup`. On decline $\rightarrow$ Dismisses modal.
* **Loading States**: Swipe slider displays inline progress spinner during API call.
* **Error States**: If order already expired or assigned elsewhere, displays informative dialog: *"Order re-assigned to another partner."*
* **Accessibility**: Screen reader announces: *"New order offer: 68 rupees, 4.8 kilometers."*

---

### Screen 05: Vendor Pickup Screen (Slide 05)
* **Purpose**: Guides rider to merchant store, displays pickup instructions, package item checklist, cold-chain alert, and confirms pickup.
* **UI Components**:
  * Vendor store address card with "Navigate via Google Maps" external intent launcher button.
  * Cold-chain warning banner: *"Contains refrigerated dairy. Place inside insulated thermal bag."*
  * Itemized grocery checklist with checkboxes for each item.
  * Two-stage action controls: "Mark Arrived at Vendor" button $\rightarrow$ transitions to "Swipe to Pick Up" slider.
* **Widgets Used**: `CheckboxListTile`, `SwipeActionButton`, `StitchSurfaceCard`, `OutlinedButton`.
* **Bloc/Cubit**: `OrderLifecycleBloc`.
* **Repository Calls**: `OrderRepository.arriveAtVendor(orderId, lat, lng)`, `OrderRepository.pickupOrder(orderId, checklistVerified)`.
* **API Used**: `POST /rider/orders/{id}/arrive-vendor`, `POST /rider/orders/{id}/pickup`.
* **Validation**: "Swipe to Pick Up" is disabled until all checklist items are ticked.
* **Navigation**: On pickup confirmation $\rightarrow$ Advances state to Customer Navigation view.
* **Offline Handling**: If offline at vendor, allows local checklist verification and queues network sync.

---

### Screen 06: Customer Navigation & Delivery Screen (Slide 06)
* **Purpose**: Provides live turn-by-turn map tracking to customer door, unmasks full customer street address and masked call proxy, displays delivery instructions and COD amount warning.
* **UI Components**:
  * Full-screen Google Map view with dynamic polyline and custom motorbike/customer markers.
  * Recentering FAB and external navigation intent button (launch Google Maps / Waze).
  * Draggable Bottom Sheet with customer name, masked phone button, gate delivery notes.
  * **COD Collection Callout**: Prominent amber warning banner: *"Collect ₹420.00 Cash from Customer"*.
  * "Arrived at Customer" button.
* **Widgets Used**: `GoogleMap`, `DraggableScrollableSheet`, `FloatingActionButton`, `StitchPrimaryButton`.
* **Bloc/Cubit**: `NavigationBloc`, `OrderLifecycleBloc`.
* **Repository Calls**: `OrderRepository.arriveAtCustomer(orderId, lat, lng)`.
* **API Used**: `POST /rider/orders/{id}/arrive-customer`.
* **Navigation**: On arrival $\rightarrow$ Opens Delivery Confirmation Screen.
* **Animations**: Smooth camera animated updates following rider GPS heading and coordinates.

---

### Screen 07: Delivery Confirmation Screen (Slide 06)
* **Purpose**: Completes order fulfillment via 4-digit Customer OTP verification, optional digital signature, and photo proof-of-drop.
* **UI Components**:
  * 4-digit Customer OTP entry boxes.
  * Signature canvas pad (`Signature` widget) with clear/undo buttons.
  * Proof-of-delivery camera button with preview thumbnail.
  * "Swipe to Complete Delivery" slider.
* **Widgets Used**: `PinCodeTextField`, `Signature`, `CameraPreview`, `SwipeActionButton`.
* **Bloc/Cubit**: `OrderLifecycleBloc`.
* **Repository Calls**: `OrderRepository.confirmDelivery(orderId, otp, proofFile, signatureFile, lat, lng)`.
* **API Used**: `POST /rider/orders/{id}/confirm-delivery`.
* **Validation**: OTP must match customer code; proof photo required if contactless delivery.
* **Navigation**: On success $\rightarrow$ Shows full-screen confetti celebration with earned payout, then redirects to `/dashboard`.
* **Error States**: "Invalid OTP" triggers red flash on input; rider asked to re-confirm with customer.

---

### Screen 08: Earnings & Payouts Screen (Slide 07)
* **Purpose**: Transparent ledger displaying today's earnings, weekly earnings chart, surge incentives, tip breakdown, and bank payout history.
* **UI Components**:
  * Week-at-a-glance bar chart (`fl_chart`) with active day highlight.
  * Itemized ledger list: Base Pay, Surge Bonus, Tips, Adjustments.
  * Target streak meter: "Complete 2 more orders today for +₹100 bonus".
  * Past bank settlement list with UTR numbers and PDF download buttons.
* **Widgets Used**: `BarChart`, `ListView.builder`, `LinearProgressIndicator`, `StitchSurfaceCard`.
* **Bloc/Cubit**: `EarningsBloc`.
* **Repository Calls**: `EarningsRepository.getSummary()`, `EarningsRepository.getHistory(page)`.
* **API Used**: `GET /rider/earnings/summary`, `GET /rider/earnings/history`, `GET /rider/payouts`.
* **Offline Handling**: Loads cached ledger from Hive database if offline.

---

### Screen 09: COD Management Screen (Slide 08)
* **Purpose**: Monitors physical cash-in-hand custody, enforces credit limits (e.g. ₹5,000 threshold), and guides remittance handover.
* **UI Components**:
  * Circular progress gauge indicating percentage of allowed cash limit reached.
  * Warning alert when balance exceeds 80% of limit.
  * List of unreconciled COD deliveries.
  * "Submit Cash Handover" button opening deposit slip upload sheet.
* **Widgets Used**: `CircularProgressIndicator`, `StitchSurfaceCard`, `ElevatedButton`.
* **Bloc/Cubit**: `CodBloc`.
* **Repository Calls**: `CodRepository.getCodSummary()`, `CodRepository.submitHandover(amount, method, ref, receipt)`.
* **API Used**: `GET /rider/cod/summary`, `POST /rider/cod/handover`.

---

### Screen 10: Safety, SOS & Incident Reporting Screen (Slide 10)
* **Purpose**: Life-safety module providing instant 3-second hold emergency SOS, 112 police dialer, and accident reporting.
* **UI Components**:
  * Massive circular SOS button with filling circular shader: *"Hold for 3 seconds"*.
  * Audible siren toggle and flashlight strobe option.
  * Direct call tile to Freska 24/7 Operations Safety Desk.
  * Multi-photo accident report submission form.
* **Widgets Used**: `GestureDetector`, `CustomPaint`, `HapticFeedback`, `StitchPrimaryButton`.
* **Bloc/Cubit**: `SafetyBloc`.
* **Repository Calls**: `SafetyRepository.triggerSos(lat, lng, activeOrderId)`, `SafetyRepository.reportIncident(IncidentDto)`.
* **API Used**: `POST /rider/safety/sos`, `POST /rider/safety/incident`.
* **Accessibility**: Instant high-frequency haptic vibrations emitted every 500ms while holding SOS button.
