# Freska — Delivery Partner Platform
## Comprehensive Development Plan & Technical Implementation Guide

**Author**: Senior Full-Stack Developer & Technical Lead  
**Target Applications**: Freska Mobile App (Flutter) & Freska Backend API (PHP Laravel 11)  
**Design Reference**: Google Stitch Design Language (Clean Material 3, Dark Elevation, High-Contrast Status Accents, Fluid Overlays)  
**Version**: 1.0.0 (Production Blueprint)

---

## 1. Project Overview & Executive Summary

The **Freska Delivery Partner App** is an enterprise-grade mobile logistics operating system tailored for fast-turnaround fresh grocery, cold-chain, and farm-to-table deliveries. It orchestrates the end-to-end rider journey:
- **Onboarding & Verification**: Mobile OTP authentication, KYC credentialing, vehicle profiles, and bank account registration.
- **Real-Time Fleet Dispatching**: Geofenced availability (Online/Offline), background GPS telemetry, algorithmic order offering with instant countdowns.
- **Fulfillment Lifecycle (FSM)**: Guided navigation to vendors, package itemization checklists, turn-by-turn customer routing, delivery confirmation via OTP and photo proof.
- **Financial Integrity & COD**: Running "Cash in Hand" ledger, automated settlement thresholds, COD reconciliation, and transparent earnings breakdowns (base, surge, distance, tips).
- **Driver Safety & Welfare**: One-touch SOS emergency panic button, 24/7 incident reporting, and real-time support dispatch.
- **Airtight Security & RBAC**: Strict segregation of rider privileges from internal management panels, data minimization (customer phone and address masking), and immutable audit trails for every order transition.

---

## 2. Google Stitch UI/UX Design System Specification

The UI/UX adheres strictly to the **Google Stitch Design Language**, balancing utility under outdoor direct-sunlight conditions with sleek modern aesthetics:

### 2.1 Color Palette & Tokens
| Token Name | Hex Code | Purpose / Usage |
| :--- | :--- | :--- |
| `primaryFresh` | `#059669` (Dark: `#10B981`) | Brand emerald green; online status, primary call-to-actions, accepted states. |
| `surfaceBackground` | `#0F172A` (Dark) / `#F8FAFC` (Light) | Base scaffold background; high contrast against cards. |
| `surfaceElevated` | `#1E293B` (Dark) / `#FFFFFF` (Light) | Card surfaces, bottom sheets, order info overlays (16dp rounded radius). |
| `accentGold` | `#F59E0B` | Earnings, incentives, pending states, surge badges. |
| `dangerSOS` | `#EF4444` | Emergency SOS trigger, rejection buttons, safety alerts. |
| `textPrimary` | `#F8FAFC` (Dark) / `#0F172A` (Light) | Primary text with Google Sans / Inter font families. |
| `textSecondary` | `#94A3B8` | Subtitles, package details, timestamps, distance indicators. |

### 2.2 Key UX Paradigms
1. **Swipe-to-Action Controls**: To prevent accidental button clicks while riding a two-wheeler with gloves, critical actions (Accept Order, Picked Up, Confirm Delivery) utilize smooth horizontal slider gestures (`SwipeActionButton`) with haptic feedback.
2. **Draggable Modal Bottom Sheets**: The live map occupies the full viewport background, while order details, pickup instructions, and customer addresses float in interactive sheets (`WoltModalSheet` / `DraggableScrollableSheet`).
3. **Tabular Numerals**: Financial figures, countdown timers, and distances utilize monospaced tabular numbers (`FontFeatures.tabularFigures()`) to prevent jitter during real-time updates.
4. **Day/Night Auto-Switching**: Automatically switches map styles (Google Maps JSON styles) and app brightness based on ambient light sensors and local sunset timings.

---

## 3. End-to-End System Architecture

```
+-----------------------------------------------------------------------------------+
|                            FRESKA MOBILE APP (FLUTTER)                            |
|  +--------------------+  +----------------------+  +----------------------------+ |
|  | Presentation (UI)  |  | State (BLoC / Cubit) |  | Services (GPS, Audio, PNs) | |
|  | Stitch Design Comp |  | Duty, Order, Earnings|  | Background Geo, FCM, Maps  | |
|  +---------+----------+  +----------+-----------+  +-------------+--------------+ |
|            |                        |                            |                |
|            +------------------------+----------------------------+                |
|                                     | Dio HTTP / WSS                              |
+-------------------------------------v---------------------------------------------+
                                      |
                                      v
+-----------------------------------------------------------------------------------+
|                        LARAVEL 11 API GATEWAY & SERVICES                          |
|  +--------------------+  +----------------------+  +----------------------------+ |
|  | REST API / Sanctum |  | Event Broadcast Engine| | Dispatch & Lifecycle Engine| |
|  | Auth, KYC, Orders  |  | Laravel Reverb (WSS) |  | FSM Transitions, Audits    | |
|  +---------+----------+  +----------+-----------+  +-------------+--------------+ |
+------------|------------------------|----------------------------|----------------+
             |                        |                            |
+------------v------------------------v----------------------------v----------------+
|                        INFRASTRUCTURE & DATA PERSISTENCE                          |
|  +-----------------------+  +-----------------------+  +------------------------+ |
|  | MySQL 8.0 (Spatial)   |  | Redis 7.2 (Queues)    |  | S3 / Cloud Storage     | |
|  | ACID Orders, Ledger   |  | Jobs, Location GeoSet |  | KYC Docs, POD Photos   | |
|  +-----------------------+  +-----------------------+  +------------------------+ |
+-----------------------------------------------------------------------------------+
```

---

## 4. Feature Breakdown & Technical Specifications

### Feature 1: Login & Onboarding (Slides 02 & 14)
- **Feature Scope**: Mobile OTP authentication, rider profile creation, multi-document KYC submission (driving license, vehicle RC, ID proof), bank account verification, emergency contact.
- **Flutter Layer**:
  - *Widgets*: `PinCodeTextField`, `CameraCaptureWidget` with face-oval guide, `DocumentUploadTile`, `CustomDropdown` (vehicle types).
  - *State Management*: `AuthBloc` (Unauthenticated, OtpSent, Authenticated, KycPending, Active).
- **Backend API (Laravel)**:
  - `POST /api/v1/auth/otp/send` — Triggers 6-digit OTP via SMS gateway (rate-limited: 3 req/min).
  - `POST /api/v1/auth/otp/verify` — Validates OTP, issues Sanctum personal access token with device binding (`device_id`).
  - `POST /api/v1/rider/profile/photo` — Stores profile avatar in cloud storage.
  - `POST /api/v1/rider/documents` — Accepts multi-part KYC documents (`license_front`, `license_back`, `rc_book`, `id_proof`).
  - `PUT /api/v1/rider/bank-details` — Registers bank IFSC, account number, and UPI ID.
  - `PUT /api/v1/rider/emergency-contact` — Stores primary next-of-kin emergency contact.
- **Database Tables**: `users`, `rider_profiles`.
- **Third-Party Integrations**: Firebase Phone Auth / SMS Gateway (Twilio/AWS SNS/Exotel), AWS S3 or Cloud Storage for document buckets.

---

### Feature 2: Rider Home / Dashboard & Duty Management (Slide 03)
- **Feature Scope**: Online/Offline status switch, today's summary metrics (deliveries count, total earnings), persistent floating card for active order, instant access to rider support.
- **Flutter Layer**:
  - *Widgets*: `DutyToggleSwitch` (animated custom switch), `MetricSummaryCard`, `ActiveOrderCard` (sticky persistent card), `QuickSupportFAB`.
  - *State Management*: `DutyBloc` (toggles duty status, validates active GPS permission and verified KYC).
- **Backend API (Laravel)**:
  - `POST /api/v1/rider/duty/toggle` — Updates `is_online` status; triggers socket broadcast to operations dashboard.
  - `POST /api/v1/rider/location` — Ingests rider heartbeat coordinates (`lat`, `lng`, `heading`, `speed`, `battery_percentage`) every 15-30 seconds into Redis Geospatial Index (`GEOADD riders:online`).
  - `GET /api/v1/rider/dashboard/summary` — Returns today's metrics and pending/active order payload.
- **Database Tables**: `rider_profiles`, `orders`.

---

### Feature 3: New Order Assignment (Slide 04)
- **Feature Scope**: High-priority full-screen incoming assignment modal; displays Order ID, vendor name/location, customer area, distance in km, expected payout; 30-second countdown timer; Accept/Reject actions.
- **Flutter Layer**:
  - *Widgets*: `OrderOfferModal` (non-dismissible modal sheet), `CircularCountdownProgress`, `PayoutBadge`, `SlideAction` (swipe to accept), `RejectReasonDialog`.
  - *State Management*: `OrderOfferCubit` (manages 30s local ticker, sound player loop, rejection submission).
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/orders/active` — Fetches current active assignment if reconnected.
  - `POST /api/v1/rider/orders/{id}/accept` — Validates assignment offer has not expired; updates status to `accepted`; logs audit record; stops offer broadcast to other riders.
  - `POST /api/v1/rider/orders/{id}/reject` — Rejection recorded with reason; marks offer as `rejected`; triggers re-dispatch algorithm to next nearest rider.
- **Database Tables**: `orders`, `order_assignment_offers`, `audit_logs`.
- **Third-Party Integrations**: Firebase Cloud Messaging (FCM High Priority Data Message), Pushy / Laravel Reverb for real-time WebSocket signaling, local audio tone generator.

---

### Feature 4: Vendor Pickup (Slide 05)
- **Feature Scope**: Detailed vendor information (address, landmark, pickup instructions, masked phone), package checklist (item names, quantities, cold-chain/fragile warnings), "Mark Arrived at Vendor" and "Mark Order Picked Up" actions.
- **Flutter Layer**:
  - *Widgets*: `VendorHeaderCard`, `PackageChecklistList`, `ColdChainPill`, `SwipeActionButton` ("Swipe to Confirm Pickup").
  - *State Management*: `OrderBloc` (handles transition from `accepted` -> `arrived_vendor` -> `picked_up`).
- **Backend API (Laravel)**:
  - `POST /api/v1/rider/orders/{id}/arrive-vendor` — Verifies rider coordinates against vendor geofence (radius <= 200m); logs `arrived_vendor_at`.
  - `POST /api/v1/rider/orders/{id}/pickup` — Validates package verification checklist; advances order status to `picked_up`; notifies customer.
- **Database Tables**: `orders`, `vendors`, `audit_logs`.

---

### Feature 5: Navigation & Customer Delivery (Slide 06)
- **Feature Scope**: Dynamic polyline routing on Google Maps, estimated time of arrival (ETA), customer delivery instructions (gate codes, contactless instructions), COD collection notice, delivery confirmation via Customer OTP, digital signature, and proof photo.
- **Flutter Layer**:
  - *Widgets*: `GoogleMap` view with custom rider & customer markers, `DeliverySheet` (draggable), `OtpVerificationModal`, `SignaturePadWidget`, `CameraProofWidget`.
  - *State Management*: `NavigationBloc` & `OrderBloc`.
- **Backend API (Laravel)**:
  - `POST /api/v1/rider/orders/{id}/arrive-customer` — Marks arrival at customer destination.
  - `POST /api/v1/rider/orders/{id}/confirm-delivery` — Validates 4 or 6-digit Customer OTP; processes proof uploads (`signature`, `photo`); updates status to `delivered`; creates ledger earnings transaction.
- **Database Tables**: `orders`, `cod_collections`, `rider_earnings`, `audit_logs`.
- **Third-Party Integrations**: Google Maps SDK / Mapbox SDK, Google Directions API, Cloud Storage for proof photos.

---

### Feature 6: Earnings & Payouts (Slide 07)
- **Feature Scope**: Detailed earnings dashboard (today, this week), delivery counts, itemized bonus incentives (surge bonuses, distance allowance, milestone streaks), past payout history with bank transfer reference numbers.
- **Flutter Layer**:
  - *Widgets*: `EarningsChartWidget` (FlChart bar charts), `EarningsLedgerTile`, `IncentiveProgressMeter`, `PayoutStatementSheet`.
  - *State Management*: `EarningsBloc`.
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/earnings/summary` — Returns today, weekly, and incentive milestones.
  - `GET /api/v1/rider/earnings/history` — Paginated list of daily earnings and tips.
  - `GET /api/v1/rider/payouts` — Past batch payout records with status (`completed`, `processing`) and bank transaction UTR.
- **Database Tables**: `rider_earnings`, `payouts`.

---

### Feature 7: COD Management (Slide 08)
- **Feature Scope**: Cash-On-Delivery ledger; tracks pending cash collected from customers, running "Cash in Hand" balance against maximum allowed limit (e.g. ₹5,000), cash deposit/handover status (hub deposit or UPI clawback).
- **Flutter Layer**:
  - *Widgets*: `CashInHandMeter` (progress gauge towards credit limit), `CodOrderTile`, `RemittanceActionSheet`.
  - *State Management*: `CodBloc`.
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/cod/summary` — Returns total collected, pending reconciliation, and credit limit headroom.
  - `GET /api/v1/rider/cod/orders` — List of all completed COD orders pending settlement.
  - `POST /api/v1/rider/cod/handover` — Submits cash remittance request with deposit reference or payment receipt.
- **Database Tables**: `cod_collections`, `rider_profiles`.

---

### Feature 8: Performance Metrics (Slide 09)
- **Feature Scope**: Completed deliveries count, acceptance rate (%), on-time delivery rate (%), customer rating (1 to 5 stars), compliments badges, overall performance summary & tier progress (Bronze, Silver, Gold, Platinum).
- **Flutter Layer**:
  - *Widgets*: `CircularScoreGauge`, `RatingStarRow`, `BadgeGridWidget`, `TierProgressCard`.
  - *State Management*: `PerformanceCubit`.
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/performance` — Returns calculated metrics (acceptance rate, on-time percentage, rating breakdown).
- **Database Tables**: `rider_profiles`, `orders`.

---

### Feature 9: Safety & Rider Welfare (Slide 10)
- **Feature Scope**: One-touch SOS button (requires 3-second hold to prevent false triggers; sounds loud local siren, alerts 24/7 Operations Desk with live telemetry, dispatches emergency SMS to next-of-kin, offers 112 emergency dialer), incident & accident reporting with photo evidence, insurance policy lookup.
- **Flutter Layer**:
  - *Widgets*: `HoldToTriggerSosButton` (animated circular filling shader), `IncidentReportForm`, `InsuranceCardWidget`.
  - *State Management*: `SafetyBloc`.
- **Backend API (Laravel)**:
  - `POST /api/v1/rider/safety/sos` — Creates priority incident in `incidents_and_sos`; triggers immediate Webhook & SMS to emergency contacts.
  - `POST /api/v1/rider/safety/incident` — Submits road accident or breakdown report with photo attachments.
  - `GET /api/v1/rider/safety/insurance` — Returns rider policy details and insurance helpline.
- **Database Tables**: `incidents_and_sos`, `rider_profiles`.

---

### Feature 10: Notifications (Slide 11)
- **Feature Scope**: Push notifications and in-app notifications hub for new assignments, pickup reminders, customer cancellations, payout credits, and Freska operational announcements.
- **Flutter Layer**:
  - *Widgets*: `NotificationListTile`, `BadgeIcon`, `AnnouncementDetailDialog`.
  - *State Management*: `NotificationBloc`.
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/notifications` — List of recent notifications with unread count.
  - `PATCH /api/v1/rider/notifications/{id}/read` — Marks notification as read.
  - `POST /api/v1/rider/devices/register` — Registers FCM token and device OS version.
- **Database Tables**: `notifications`, `users`.

---

### Feature 11: Help & Support (Slide 12)
- **Feature Scope**: Categorized help center (Customer issue, Vendor pickup delay, Payment/Payout issue, Emergency support); ticket submission with photo attachments; real-time ticket status tracking.
- **Flutter Layer**:
  - *Widgets*: `SupportCategoryGrid`, `NewTicketForm`, `TicketHistoryTile`, `TicketChatView`.
  - *State Management*: `SupportBloc`.
- **Backend API (Laravel)**:
  - `GET /api/v1/rider/support/tickets` — List of user tickets.
  - `POST /api/v1/rider/support/tickets` — Creates new support ticket.
  - `GET /api/v1/rider/support/tickets/{id}` — Fetches ticket resolution notes and status.
- **Database Tables**: `support_tickets`.

---

### Feature 12: App Access & Security Compliance (Slide 14)
- **Feature Scope**:
  1. *Role-Based Access Control (RBAC)*: Rider token cannot access any admin panel or management routes.
  2. *Data Minimization*: Customer phone numbers are masked or connected via proxy dialer; full customer address is hidden until the order is picked up from the vendor.
  3. *Auditability*: Every key lifecycle action (`accepted`, `arrived_vendor`, `picked_up`, `delivered`, `cod_collected`) logs an immutable record with GPS coordinates, IP, and timestamp.
  4. *Single Device Session*: Enforces one active device per rider account to prevent account sharing.

---

## 5. Prioritized Development Roadmap

```
+-----------------------------------------------------------------------------------------+
|                               FRESKA DEVELOPMENT ROADMAP                                |
+-------------------+---------------------------------------------------------------------+
| Phase 1 (Weeks 1-2)| Foundation, Auth & Onboarding (Sanctum, OTP, KYC, Stitch Theme)   |
+-------------------+---------------------------------------------------------------------+
| Phase 2 (Weeks 3-4)| Duty Management, GPS Heartbeat & Real-Time Dispatch Engine         |
+-------------------+---------------------------------------------------------------------+
| Phase 3 (Weeks 5-6)| Complete Order Fulfillment Flow (Vendor Pickup, Google Maps, POD)   |
+-------------------+---------------------------------------------------------------------+
| Phase 4 (Weeks 7-8)| Financials & COD Engine (Cash in Hand, Remittance, Earnings Ledger)|
+-------------------+---------------------------------------------------------------------+
| Phase 5 (Week 9)  | Safety & Welfare (SOS Panic, Accident Report, Support Desk)         |
+-------------------+---------------------------------------------------------------------+
| Phase 6 (Week 10) | Hardening, Performance Tuning, Security Audit, Store Deployment     |
+-------------------+---------------------------------------------------------------------+
```

### Phase 1: MVP Core Foundations (Weeks 1 - 2)
- **Backend**:
  - Setup Laravel 11 project, configure MySQL 8.0, Redis, and Sanctum.
  - Implement migrations: `users`, `rider_profiles`, `vendors`.
  - Build OTP verification pipeline with SMS Gateway fallback.
  - Build KYC document upload endpoints to secure S3 storage.
- **Frontend (Flutter)**:
  - Initialize Flutter project with Stitch design tokens and theme configuration.
  - Implement mobile phone input + OTP verification screens.
  - Build multi-step rider profile and KYC document submission flow.
  - Setup `flutter_secure_storage` and Dio HTTP client with auth token interceptors.

### Phase 2: Availability & Real-Time Dispatch (Weeks 3 - 4)
- **Backend**:
  - Implement `orders` and `order_assignment_offers` database tables.
  - Integrate Laravel Reverb (WebSockets) and Redis Geospatial commands for rider dispatch.
  - Implement assignment offer broadcast with 30s automatic expiration worker.
- **Frontend (Flutter)**:
  - Build Home / Dashboard screen with Online/Offline duty toggle switch.
  - Setup background geolocation stream emitting heartbeats to backend.
  - Implement high-priority full-screen incoming assignment modal with countdown ring, sound player, and swipe-to-accept.

### Phase 3: Fulfillment & Delivery Lifecycle (Weeks 5 - 6)
- **Backend**:
  - Implement state machine transitions: `accepted` -> `arrived_vendor` -> `picked_up` -> `arrived_customer` -> `delivered`.
  - Geofence verification logic (validating coordinates within 200m of vendor/customer).
  - Delivery OTP verification and proof-of-delivery upload endpoints.
  - Audit logging middleware recording latitude, longitude, and timestamps.
- **Frontend (Flutter)**:
  - Integrate `google_maps_flutter` with custom markers and live routing polylines.
  - Build Vendor Pickup screen with checklist and "Swipe to Pick Up" slider.
  - Build Customer Navigation & Delivery screen with COD indicator and customer delivery instructions.
  - Implement Delivery Confirmation Sheet with Customer OTP input and camera proof-of-delivery capture.

### Phase 4: Financials & COD Management (Weeks 7 - 8)
- **Backend**:
  - Implement `rider_earnings` ledger with automatic transaction posting upon delivery.
  - Implement `cod_collections` and `payouts` calculation engine.
  - Build COD limit enforcement (blocks new order assignments if cash in hand exceeds threshold).
- **Frontend (Flutter)**:
  - Build Earnings & Payouts screen with daily/weekly bar charts and incentive streak trackers.
  - Build COD Management screen with cash-in-hand limit meter and remittance submission.

### Phase 5: Safety, Performance & Support (Week 9)
- **Backend**:
  - Implement `incidents_and_sos` and `support_tickets` API endpoints.
  - Build instant SOS webhook alerting operations dispatch desk and sending SMS to emergency contact.
  - Calculate rider performance scores (acceptance rate, on-time percentage, average rating).
- **Frontend (Flutter)**:
  - Build 3-second hold-to-activate SOS Panic Button with visual shader and haptic vibration.
  - Build Accident/Incident reporting flow with photo capture.
  - Build Performance & Ratings dashboard.
  - Build Support Ticket center.

### Phase 6: Hardening, Security, QA & Deployment (Week 10)
- End-to-end integration testing, network interruption & offline sync recovery testing.
- Security audit: Verify customer phone number masking, check RBAC barrier preventing admin access.
- Deploy Laravel backend to AWS ECS / DigitalOcean with Redis & Managed MySQL.
- Deploy Flutter app to Google Play Console Internal Testing and Apple TestFlight.

---

## 6. Production-Ready Code Examples

### 6.1 Backend: Laravel Order State Machine & Audit Logger

#### `app/Services/OrderLifecycleService.php`
```php
<?php

namespace App\Services;

use App\Models\Order;
use App\Models\AuditLog;
use App\Models\RiderEarning;
use App\Models\CodCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderLifecycleService
{
    /**
     * Accept an order assignment offer.
     */
    public function acceptOrder(Order $order, int $riderId, float $lat, float $lng, string $ip): Order
    {
        return DB::transaction(function () use ($order, $riderId, $lat, $lng, $ip) {
            if ($order->status !== 'offered') {
                throw ValidationException::withMessages(['order' => 'Order is no longer available.']);
            }

            $order->update([
                'rider_id' => $riderId,
                'status' => 'accepted',
                'assignment_accepted_at' => now(),
            ]);

            // Record compliance audit
            AuditLog::create([
                'user_id' => $riderId,
                'order_id' => $order->id,
                'action' => 'ORDER_ACCEPTED',
                'latitude' => $lat,
                'longitude' => $lng,
                'ip_address' => $ip,
                'metadata' => ['timestamp' => now()->toIso8601String()]
            ]);

            return $order->fresh();
        });
    }

    /**
     * Mark Order Picked Up from Vendor.
     */
    public function markPickedUp(Order $order, int $riderId, float $lat, float $lng, string $ip): Order
    {
        return DB::transaction(function () use ($order, $riderId, $lat, $lng, $ip) {
            if ($order->rider_id !== $riderId || !in_array($order->status, ['accepted', 'arrived_vendor'])) {
                throw ValidationException::withMessages(['order' => 'Invalid order state for pickup.']);
            }

            $order->update([
                'status' => 'picked_up',
                'picked_up_at' => now(),
            ]);

            AuditLog::create([
                'user_id' => $riderId,
                'order_id' => $order->id,
                'action' => 'ORDER_PICKED_UP',
                'latitude' => $lat,
                'longitude' => $lng,
                'ip_address' => $ip,
            ]);

            return $order->fresh();
        });
    }

    /**
     * Complete Order Delivery with OTP and proof.
     */
    public function confirmDelivery(
        Order $order,
        int $riderId,
        string $otp,
        ?string $proofPhotoUrl,
        float $lat,
        float $lng,
        string $ip
    ): Order {
        return DB::transaction(function () use ($order, $riderId, $otp, $proofPhotoUrl, $lat, $lng, $ip) {
            if ($order->rider_id !== $riderId || $order->status !== 'picked_up') {
                throw ValidationException::withMessages(['order' => 'Order is not in transitable state.']);
            }

            if ($order->delivery_otp !== $otp) {
                throw ValidationException::withMessages(['otp' => 'Invalid customer delivery verification OTP.']);
            }

            $order->update([
                'status' => 'delivered',
                'delivered_at' => now(),
                'delivery_proof_photo_url' => $proofPhotoUrl,
            ]);

            // Handle COD collection record if applicable
            if ($order->payment_mode === 'cod' && $order->cod_amount > 0) {
                CodCollection::create([
                    'order_id' => $order->id,
                    'rider_id' => $riderId,
                    'amount' => $order->cod_amount,
                    'collected_at' => now(),
                    'collection_latitude' => $lat,
                    'collection_longitude' => $lng,
                    'handover_status' => 'held_in_hand',
                ]);

                // Increment rider cash in hand
                $order->rider->riderProfile()->increment('current_cash_in_hand', $order->cod_amount);
            }

            // Credit Rider Earnings Ledger
            RiderEarning::create([
                'rider_id' => $riderId,
                'order_id' => $order->id,
                'earning_type' => 'delivery_fee',
                'amount' => $order->total_rider_payout,
                'description' => "Payout for delivery #{$order->order_number}",
                'date' => now()->toDateString(),
                'status' => 'pending',
            ]);

            $order->rider->riderProfile()->increment('completed_deliveries_count');

            AuditLog::create([
                'user_id' => $riderId,
                'order_id' => $order->id,
                'action' => 'ORDER_DELIVERED',
                'latitude' => $lat,
                'longitude' => $lng,
                'ip_address' => $ip,
                'metadata' => [
                    'payment_mode' => $order->payment_mode,
                    'payout' => $order->total_rider_payout
                ]
            ]);

            return $order->fresh();
        });
    }
}
```

---

### 6.2 Frontend: Google Stitch Design Tokens & Theme

#### `lib/core/theme/stitch_theme.dart`
```dart
import 'package:flutter/material.dart';

class StitchColors {
  // Primary brand palette (Fresh Emerald)
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);

  // Neutral dark mode canvas
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceElevated = Color(0xFF334155);

  // Status and utility accents
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF0EA5E9);

  // Typography shades
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class StitchTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StitchColors.background,
      fontFamily: 'GoogleSans',
      colorScheme: const ColorScheme.dark(
        primary: StitchColors.primary,
        secondary: StitchColors.accentGold,
        surface: StitchColors.surface,
        error: StitchColors.danger,
        onPrimary: Colors.white,
        onSurface: StitchColors.textPrimary,
      ),
      cardTheme: CardTheme(
        color: StitchColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF283548), width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: StitchColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StitchColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
```

---

### 6.3 Frontend: Swipe-to-Action Component (Prevent Accidental Taps)

#### `lib/presentation/widgets/swipe_action_button.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/stitch_theme.dart';

class SwipeActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Future<void> Function() onSwipeComplete;
  final Color backgroundColor;
  final Color sliderColor;

  const SwipeActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onSwipeComplete,
    this.backgroundColor = const Color(0xFF1E293B),
    this.sliderColor = StitchColors.primary,
  }) : super(key: key);

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton> {
  double _dragPosition = 0.0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 60.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - buttonHeight;

        return Container(
          height: buttonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  _isLoading ? 'Processing...' : widget.text,
                  style: const TextStyle(
                    color: StitchColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isLoading) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx)
                          .clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    if (_isLoading) return;
                    if (_dragPosition >= maxDrag * 0.85) {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _dragPosition = maxDrag;
                        _isLoading = true;
                      });
                      try {
                        await widget.onSwipeComplete();
                      } finally {
                        if (mounted) {
                          setState(() {
                            _dragPosition = 0.0;
                            _isLoading = false;
                          });
                        }
                      }
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    height: buttonHeight,
                    width: buttonHeight,
                    decoration: BoxDecoration(
                      color: widget.sliderColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.sliderColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(widget.icon, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

### 6.4 Frontend: Order Offer Screen with Real-Time Countdown (Slide 04)

#### `lib/presentation/screens/order_offer_dialog.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/stitch_theme.dart';
import '../widgets/swipe_action_button.dart';

class OrderOfferDialog extends StatefulWidget {
  final Map<String, dynamic> offer;
  final Future<void> Function() onAccept;
  final VoidCallback onReject;

  const OrderOfferDialog({
    Key? key,
    required this.offer,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  State<OrderOfferDialog> createState() => _OrderOfferDialogState();
}

class _OrderOfferDialogState extends State<OrderOfferDialog> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 30;
    _startTimer();
    HapticFeedback.vibrate();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        widget.onReject(); // Auto-expire assignment
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _remainingSeconds / 30.0;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: StitchColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW ORDER OFFER',
                        style: TextStyle(
                          color: StitchColors.primaryLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${widget.offer['order_number']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: StitchColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        color: progress > 0.3 ? StitchColors.accentGold : StitchColors.danger,
                        backgroundColor: const Color(0xFF334155),
                      ),
                      Text(
                        '$_remainingSeconds',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Payout Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StitchColors.accentGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guaranteed Payout',
                            style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                        Text('Includes surge & distance',
                            style: TextStyle(color: StitchColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    Text(
                      '₹${widget.offer['payout']}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: StitchColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pickup & Delivery Locations
              _buildLocationRow(
                icon: Icons.storefront_rounded,
                iconColor: StitchColors.primaryLight,
                title: widget.offer['vendor_name'] ?? 'Vendor Hub',
                subtitle: widget.offer['pickup_area'] ?? 'Pickup location',
                distanceBadge: '${widget.offer['distance_km']} km total',
              ),
              const Padding(
                padding: EdgeInsets.only(left: 19),
                child: SizedBox(
                  height: 16,
                  child: VerticalDivider(color: Color(0xFF334155), thickness: 2),
                ),
              ),
              _buildLocationRow(
                icon: Icons.location_on_rounded,
                iconColor: StitchColors.accentGold,
                title: 'Deliver to Customer',
                subtitle: widget.offer['delivery_area'] ?? 'Customer area',
              ),
              const SizedBox(height: 24),

              // Swipe to Accept
              SwipeActionButton(
                text: 'Swipe to Accept Order',
                icon: Icons.arrow_forward_rounded,
                onSwipeComplete: widget.onAccept,
              ),
              const SizedBox(height: 10),

              // Reject Button
              TextButton(
                onPressed: widget.onReject,
                child: const Text(
                  'Decline Assignment',
                  style: TextStyle(color: StitchColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? distanceBadge,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(color: StitchColors.textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (distanceBadge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              distanceBadge,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}
```

---

## 7. Quality Assurance, Security Auditing & Deployment Pipeline

### 7.1 Security Enforcement & Data Minimization
1. **Virtual Phone Proxy**: Deliveries integrate Twilio Voice / Exotel click-to-call proxy masking, preventing riders from viewing raw customer phone numbers.
2. **Address Obfuscation**: The customer's exact house/apartment number is withheld until the rider triggers `markPickedUp()` at the merchant location; only the general delivery sector/sub-locality is presented during the assignment offer.
3. **Tamper-Proof Financial Ledgers**: Earnings and COD records are insert-only transactions. Reconciliations cannot alter original amounts without dedicated adjustment ledger rows.
4. **Anti-GPS Spoofing**: Flutter mobile client checks for mock locations (`isMockLocation` flag from `geolocator`); rejected server-side if mock flags are detected.

### 7.2 CI/CD Deployment Architecture
- **Backend**:
  - Multi-stage Dockerfile running PHP 8.3 FPM + Nginx.
  - Automated GitHub Actions running `php artisan test --parallel` and PHPStan Level 8.
  - Blue/Green deployments on AWS ECS or Kubernetes with zero downtime.
- **Frontend**:
  - Fastlane automation pipeline for Android (`.aab`) and iOS (`.ipa`).
  - Automated build variant distribution to Firebase App Distribution for QA staging.
  - Google Play Console internal track and Apple TestFlight automation.
