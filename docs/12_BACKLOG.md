# Freska Delivery Partner Platform
# Module 12: Offline Architecture, Notifications, Performance & Agile Sprint Backlog

**Document ID**: `FRESKA-DOC-12`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Offline Resilience & Sync Architecture (Part 14)

Riders operate in basements, elevators, and cellular dead zones. The Freska mobile client implements a local-first offline architecture:

```
+-------------------------------------------------------------------------------+
| Offline Mutation & Sync Queue Architecture                                    |
+-------------------------------------------------------------------------------+
| [ Rider Action in App ]                                                       |
|            |                                                                  |
|            v                                                                  |
| [ Connectivity Check (connectivity_plus) ]                                    |
|            |                                                                  |
|      +-----+--------------------------------+                                 |
|      | Online                               | Offline / Timeout               |
|      v                                      v                                 |
| [ Execute Dio HTTP API ]        [ Persist to Hive Pending Sync Queue ]        |
|      |                                      |                                 |
|      |                                      v                                 |
|      |                              [ Update Local UI Optimistically ]        |
|      |                                      |                                 |
|      |                                      v                                 |
|      |                              [ Listen for Network Connectivity Restored|
|      |                                      |                                 |
|      |                                      v                                 |
|      |                              [ Process Queue with Exponential Backoff ]|
|      |                                      |                                 |
|      +--------------------------------------+                                 |
|            |                                                                  |
|            v                                                                  |
| [ Server Verifies Timestamp & Version (Last-Write-Wins Conflict Resolution) ] |
+-------------------------------------------------------------------------------+
```

### 1.1 Local Hive Storage Architecture
1. **`orders_box`**: Caches active order details, package checklist, customer notes, and vendor location.
2. **`pending_actions_box`**: Queue containing serialized mutations (`action: 'ARRIVED_VENDOR'`, `timestamp`, `lat`, `lng`).
3. **`offline_images_box`**: File paths to captured proof photos queued for background S3 multi-part upload.

### 1.2 Retry Policy & Conflict Resolution
* Retries execute with exponential backoff and jitter: $T_{\text{wait}} = 2^{\text{attempt}} \times 1000\text{ms} + \text{rand}(0, 500)\text{ms}$, capping at 5 attempts before notifying rider.
* Conflict resolution employs server-side state machines; an offline delivery confirmation submitted for an order that was canceled by customer is gracefully caught and prompts the rider to contact support.

---

## 2. Notification System Architecture (Part 15)

The notification pipeline leverages **Firebase Cloud Messaging (FCM)** with high-priority Android notification channels and Apple APNs VoIP/Alert pushes:

| Notification Type | Trigger Event | Priority | Payload / Channel | Sound & Vibration |
| :--- | :--- | :--- | :--- | :--- |
| **Order Assignment** | New order offered to rider | High (Data Message) | `freska_order_channel` (Bypasses Do Not Disturb) | Custom looping chime (`order_alert.mp3`), heavy haptic pattern. |
| **Pickup Reminder** | Order packed by vendor / 5 mins elapsed | Normal | `freska_updates_channel` | Standard notification chime. |
| **Order Cancellation** | Customer / Dispatcher cancels order | High | `freska_alerts_channel` | Distinct double-beep alert. |
| **Payout Credited** | Batch bank settlement completed | Normal | `freska_finance_channel` | Gentle bell sound. |
| **Emergency SOS Broadcast**| Rider triggers SOS | Critical | Ops Desk WebSocket + SMS to Emergency Contact | Siren tone, immediate dispatch. |

---

## 3. Full-Stack Performance Engineering (Part 16)

### 3.1 Flutter Performance
* **60 / 120 FPS Rendering**: Map views, countdown rings, and swipe sliders are wrapped in `RepaintBoundary` widgets to isolate canvas invalidations from rebuilding the rest of the widget tree.
* **Image Compression**: Photos captured for KYC or Proof of Delivery are compressed client-side to maximum dimensions $1920 \times 1080$ at $80\%$ JPEG quality before upload, reducing payloads from 8MB to $< 400$KB.

### 3.2 Backend & Database Performance
* **Redis Spatial Fleet Index**: Active rider positions are stored in Redis using `GEOADD riders:online {lng} {lat} {rider_id}` with a 60-second TTL. Dispatcher radius queries (`GEORADIUS`) execute in $< 2\text{ms}$, avoiding heavy geospatial table scans in MySQL.
* **Database Connection Pooling & Read Replicas**: Write queries target the MySQL Primary; reporting and dashboard summary queries target Read Replicas via Laravel database configuration:
```php
'mysql' => [
    'read' => ['host' => [env('DB_READ_HOST_1'), env('DB_READ_HOST_2')]],
    'write' => ['host' => [env('DB_HOST')]],
    // ...
],
```

---

## 4. Complete Agile Sprint Backlog & Roadmap (Part 19)

### 4.1 Sprint Overview
* **Methodology**: 2-Week Scrum Sprints (6 Sprints total = 12 Weeks to Production Launch).
* **Team Composition**:
  * 1 Principal Architect / Tech Lead (TL)
  * 2 Senior Flutter Mobile Engineers (FL1, FL2)
  * 2 Senior Laravel Backend Engineers (BE1, BE2)
  * 1 QA Automation & Security Engineer (QA)
  * 1 DevOps / SRE Engineer (DO)

---

### 4.2 Sprint Breakdown & User Story Backlog

#### Sprint 1 (Weeks 1 – 2): Foundation, Authentication & Design System
* **Sprint Goal**: Setup core architecture, database migrations, Sanctum auth with OTP pipeline, and Google Stitch Flutter theme.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-101** | Setup Laravel 11 project, Docker dev environment, MySQL & Redis. | BE1, DO | 5 | None | Docker compose boots app, DB, Redis, Reverb, and tests pass. |
| **FSK-102** | Implement database migrations: `users`, `rider_profiles`, `devices`. | BE1 | 5 | FSK-101 | Migrations run with foreign keys and strict indexes. |
| **FSK-103** | Build OTP generation and verification endpoints with Sanctum tokens. | BE2 | 5 | FSK-102 | Twilio SMS sends OTP; verify issues Sanctum token and binds device UUID. |
| **FSK-104** | Setup Flutter clean architecture skeleton & Google Stitch design theme. | FL1 | 5 | None | Stitch dark theme, emerald color tokens, Google Sans typography configured. |
| **FSK-105** | Build Phone Number Login & 6-digit OTP verification screens. | FL2 | 5 | FSK-103, 104 | Auto-advances on 6 digits, resend timer ticker, persists token in secure storage. |
| **FSK-106** | Implement Multi-document KYC upload UI and S3 private bucket API. | FL1, BE2 | 8 | FSK-105 | Camera capture works, S3 pre-signed upload works, creates KYC record. |

*Total Sprint 1 Points*: **33**

---

#### Sprint 2 (Weeks 3 – 4): Duty Availability, Background GPS & Real-time Dispatch
* **Sprint Goal**: Enable riders to toggle online duty, stream background location heartbeats, and receive incoming order offers.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-201** | Setup Laravel Reverb WebSocket server and broadcast channels. | BE1 | 5 | FSK-101 | Reverb handles secure private channel auth for riders. |
| **FSK-202** | Implement Redis Geospatial fleet location tracking endpoint (`/rider/location`).| BE2 | 5 | FSK-102 | 15s heartbeats saved to Redis `GEOADD`; mock GPS pings rejected. |
| **FSK-203** | Build Rider Dashboard screen with Online/Offline duty toggle switch. | FL1 | 5 | FSK-105 | Tactile switch validates KYC and location permissions before going online. |
| **FSK-204** | Implement background geolocation service in Flutter. | FL2 | 8 | FSK-203 | Emits coordinates in background every 15s with battery optimization. |
| **FSK-205** | Build order assignment broadcast engine with 30s auto-expiry worker. | BE1 | 8 | FSK-201, 202 | Pushes offer to nearest available rider via Reverb and FCM high-priority push. |
| **FSK-206** | Build Full-Screen Incoming Order Offer Modal with 30s countdown ring. | FL2 | 8 | FSK-205 | Audio alert loops, circular progress counts down, swipe-to-accept works. |

*Total Sprint 2 Points*: **39**

---

#### Sprint 3 (Weeks 5 – 6): Complete Order Fulfillment Lifecycle (FSM)
* **Sprint Goal**: Deliver end-to-end delivery journey from vendor pickup to customer handoff with Customer OTP verification.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-301** | Implement Order State Machine transitions and compliance audit logger. | BE1 | 8 | FSK-205 | `accepted` $\rightarrow$ `arrived_vendor` $\rightarrow$ `picked_up` $\rightarrow$ `delivered` with audit logs. |
| **FSK-302** | Build Vendor Pickup Screen with grocery checklist and cold-chain warnings. | FL1 | 8 | FSK-301 | Checklist items must be checked before "Swipe to Pick Up" unlocks. |
| **FSK-303** | Integrate Google Maps SDK with live routing polyline and navigation intent. | FL2 | 8 | FSK-302 | Camera tracks rider; opens Google Maps/Waze external intent on tap. |
| **FSK-304** | Build Customer Delivery Screen with COD warning and delivery instructions. | FL1 | 5 | FSK-303 | Unmasks customer address upon pickup; displays prominent COD badge. |
| **FSK-305** | Build Delivery Confirmation Screen with Customer OTP, signature, and photo POD. | FL2, BE2 | 8 | FSK-304 | Verifies 4-digit OTP; stores signature and proof photo in S3. |

*Total Sprint 3 Points*: **37**

---

#### Sprint 4 (Weeks 7 – 8): Financials, COD Custody & Earnings Ledger
* **Sprint Goal**: Build immutable earnings ledger, cash-on-delivery tracking, credit limit enforcement, and remittance.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-401** | Build automated earnings ledger service posting credits upon delivery completion. | BE2 | 5 | FSK-305 | Credits base pay, distance bonus, surge pay, and tips to `rider_earnings`. |
| **FSK-402** | Build Earnings & Payouts screen with FlChart weekly bar graphs. | FL1 | 8 | FSK-401 | Displays daily earnings, weekly charts, and payout statement history. |
| **FSK-403** | Implement COD collections tracking and cash-in-hand limit lockouts. | BE1 | 8 | FSK-305 | Increments cash in hand; blocks order offers if balance $> ₹5,000$. |
| **FSK-404** | Build COD Management screen with threshold gauge and remittance upload. | FL2 | 5 | FSK-403 | Progress bar shows cash limit status; allows submitting deposit slip. |
| **FSK-405** | Build Operations Admin API for COD reconciliation and batch bank payouts. | BE2 | 5 | FSK-404 | Ops team can reconcile bank CDM slips and clear rider cash balance. |

*Total Sprint 4 Points*: **31**

---

#### Sprint 5 (Weeks 9 – 10): Safety, SOS Panic, Support & Offline Sync
* **Sprint Goal**: Implement 3-second hold SOS emergency panic button, incident reports, in-app support ticketing, and Hive offline queue.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-501** | Implement 3-second hold SOS Panic button with haptic feedback and siren. | FL1 | 8 | FSK-104 | 3-second continuous hold fires API, sounds local alarm, and opens 112 dialer. |
| **FSK-502** | Build Emergency SOS webhook alerting 24/7 Ops Desk & SMS to Next-of-Kin. | BE1 | 5 | FSK-501 | Twilio sends immediate SMS to emergency contact with live GPS link. |
| **FSK-503** | Build Accident & Incident Reporting Screen with multi-photo uploads. | FL2 | 5 | FSK-502 | Allows reporting breakdown or accident with location and damage photos. |
| **FSK-504** | Build In-App Help & Support ticketing system. | FL1, BE2 | 8 | FSK-104 | Categorized issue filing; real-time ticket status updates. |
| **FSK-505** | Implement Hive offline sync queue and network reconnect listeners. | FL2 | 8 | FSK-305 | Queues checklist updates and status transitions offline; syncs when back online. |

*Total Sprint 5 Points*: **34**

---

#### Sprint 6 (Weeks 11 – 12): Security Auditing, Performance Load Testing & Store Deployment
* **Sprint Goal**: Zero-vulnerability security hardening, 5,000-rider k6 load tests, and production release to Google Play & TestFlight.

| Ticket ID | Story Description | Assignee | Story Points | Dependencies | Acceptance Criteria |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **FSK-601** | Security audit: customer phone proxy verification & RBAC boundary test. | QA, BE1 | 5 | All | Confirmed: Riders cannot view raw phone numbers or access admin routes. |
| **FSK-602** | Execute k6 load tests: 5,000 concurrent riders streaming GPS pings. | QA, BE2 | 5 | FSK-202 | 99th percentile response time $< 200\text{ms}$; zero DB deadlocks. |
| **FSK-603** | Configure AWS Production ECS Fargate clusters, RDS Multi-AZ, and ALB. | DO | 8 | All | Automated blue/green zero-downtime deployment pipelines verified. |
| **FSK-604** | Google Play Console internal track deployment & Apple TestFlight release. | FL1, FL2 | 8 | All | Signed production AAB and IPA successfully uploaded and tested on physical devices. |
| **FSK-605** | End-to-end user acceptance testing (UAT) with operations team. | All | 5 | FSK-604 | 20 test deliveries completed across 5 physical rider devices with 100% audit pass. |

*Total Sprint 6 Points*: **31**

---

### 4.3 Total Project Velocity & Summary
* **Total User Stories**: 32 Enterprise Tickets.
* **Total Story Points**: **205 Story Points**.
* **Total Timeline**: 12 Weeks (6 Sprints of 2 weeks each).
* **Target Delivery Date**: Week 12 Production Launch with 100% test coverage and full compliance auditing.
