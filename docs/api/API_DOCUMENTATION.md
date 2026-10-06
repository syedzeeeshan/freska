# Freska Delivery Partner Platform — Complete REST API Specification

This document provides the standard REST contract for all API endpoints, including HTTP methods, authentication scopes, request validation schemas, response payloads, and error codes.

---

## 1. Global Standards & Conventions

### Base URLs
- **Production**: `https://api.freska.app/api/v1`
- **Development**: `http://localhost:8000/api/v1`

### Authentication & Headers
- `Authorization: Bearer <Sanctum_Token>`
- `Accept: application/json`
- `Content-Type: application/json`
- `X-App-Version: 1.0.0`
- `X-Device-Id: <UUID>`

### Standard Success Response Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": {},
  "meta": {
    "timestamp": "2026-09-17T14:10:00Z",
    "version": "v1"
  }
}
```

### Standard Error Response Envelope
```json
{
  "success": false,
  "message": "Validation failed / Unauthorized / Resource not found",
  "errors": {
    "field_name": ["Specific validation error message"]
  },
  "error_code": "ERR_VALIDATION_FAILED"
}
```

---

## 2. Authentication & Onboarding Endpoints

### 2.1 Send Mobile OTP
- **Endpoint**: `POST /auth/otp/send`
- **Auth**: Public
- **Request Body**:
```json
{
  "phone": "+919876543210"
}
```
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "OTP sent successfully.",
  "data": {
    "phone": "+919876543210",
    "resend_in_seconds": 60
  }
}
```

### 2.2 Verify Mobile OTP
- **Endpoint**: `POST /auth/otp/verify`
- **Auth**: Public
- **Request Body**:
```json
{
  "phone": "+919876543210",
  "otp": "458921"
}
```
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Authentication successful.",
  "data": {
    "token": "1|sanctum_token_string_here...",
    "user": {
      "id": 14,
      "phone": "+919876543210",
      "name": "Arjun Sharma",
      "role": "rider",
      "status": "pending_kyc",
      "kyc_status": "pending"
    }
  }
}
```

### 2.3 Upload Rider Profile & Photo
- **Endpoint**: `POST /rider/profile/photo`
- **Auth**: Bearer Token (`rider`)
- **Content-Type**: `multipart/form-data`
- **Request Body**: `photo: File (image/jpeg, max 5MB)`
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Profile photo updated.",
  "data": {
    "avatar_url": "https://storage.freska.app/profiles/14_selfie.jpg"
  }
}
```

### 2.4 Submit KYC Documents
- **Endpoint**: `POST /rider/documents`
- **Auth**: Bearer Token (`rider`)
- **Content-Type**: `multipart/form-data`
- **Request**:
  - `license_number`: `string (required)`
  - `license_expiry`: `YYYY-MM-DD (required)`
  - `license_front`: `File (required)`
  - `license_back`: `File (required)`
  - `rc_book`: `File (required)`
  - `id_proof_type`: `aadhaar | pan | passport (required)`
  - `id_proof_number`: `string (required)`
  - `id_proof_document`: `File (required)`
- **Response (201 Created)**:
```json
{
  "success": true,
  "message": "KYC documents submitted for review.",
  "data": {
    "kyc_status": "submitted",
    "submitted_at": "2026-09-17T14:12:00Z"
  }
}
```

### 2.5 Submit Bank & Payout Details
- **Endpoint**: `PUT /rider/bank-details`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "bank_account_holder": "Arjun Sharma",
  "bank_name": "HDFC Bank",
  "bank_account_number": "50100234918231",
  "bank_ifsc_code": "HDFC0001234",
  "bank_upi_id": "arjun@okhdfcbank"
}
```
- **Response (200 OK)**: Returns updated profile with `bank_verified: true`.

### 2.6 Submit Emergency Contact
- **Endpoint**: `PUT /rider/emergency-contact`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "emergency_contact_name": "Sunita Sharma",
  "emergency_contact_phone": "+919811223344",
  "emergency_contact_relation": "Mother"
}
```

---

## 3. Rider Operations & Duty

### 3.1 Toggle Online / Offline Availability
- **Endpoint**: `POST /rider/duty/toggle`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "is_online": true,
  "latitude": 12.971598,
  "longitude": 77.594562
}
```
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Rider status is now Online.",
  "data": {
    "is_online": true,
    "last_location_updated_at": "2026-09-17T14:15:00Z"
  }
}
```

### 3.2 Heartbeat Location Update
- **Endpoint**: `POST /rider/location`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "latitude": 12.972100,
  "longitude": 77.595100,
  "heading": 85.4,
  "speed": 22.5,
  "battery_percentage": 82
}
```

---

## 4. Order Lifecycle & Dispatching

### 4.1 Get Active Order / Current Assignment
- **Endpoint**: `GET /rider/orders/active`
- **Auth**: Bearer Token (`rider`)
- **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "has_active_order": true,
    "order": {
      "id": 10842,
      "order_number": "FSK-2026-89421",
      "status": "in_transit",
      "vendor": {
        "id": 12,
        "name": "Freska Hub Koramangala",
        "phone": "+918049281200",
        "address": "80 Feet Rd, 4th Block, Koramangala, Bengaluru",
        "latitude": 12.935242,
        "longitude": 77.624466,
        "pickup_instructions": "Enter through Gate 2, bay 4"
      },
      "customer": {
        "name": "Priya V.",
        "phone": "+919988776655",
        "delivery_area": "HSR Layout Sector 1",
        "delivery_address": "#412, 14th Main, HSR Layout, Sector 1",
        "delivery_latitude": 12.912118,
        "delivery_longitude": 77.644554,
        "delivery_instructions": "Ring bell once, leave at door if contactless"
      },
      "package_details": {
        "item_count": 4,
        "is_fragile": false,
        "is_cold_chain": true,
        "items": [
          {"name": "Organic Farm Milk 1L", "quantity": 2},
          {"name": "Fresh Strawberries 500g", "quantity": 1},
          {"name": "Greek Yogurt 200g", "quantity": 1}
        ]
      },
      "payment_mode": "cod",
      "cod_amount": 420.00,
      "estimated_distance_km": 4.8,
      "total_rider_payout": 68.00
    }
  }
}
```

### 4.2 Accept Order Assignment
- **Endpoint**: `POST /rider/orders/{id}/accept`
- **Auth**: Bearer Token (`rider`)
- **Request Body**: `{"latitude": 12.935000, "longitude": 77.624000}`
- **Response (200 OK)**: Advances status to `accepted`.

### 4.3 Reject Order Assignment
- **Endpoint**: `POST /rider/orders/{id}/reject`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "reason": "Vehicle puncture / Distance too far / Shift ending"
}
```

### 4.4 Mark Arrived at Vendor
- **Endpoint**: `POST /rider/orders/{id}/arrive-vendor`
- **Auth**: Bearer Token (`rider`)
- **Request Body**: `{"latitude": 12.935240, "longitude": 77.624460}`

### 4.5 Mark Order Picked Up
- **Endpoint**: `POST /rider/orders/{id}/pickup`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "package_verified": true,
  "latitude": 12.935250,
  "longitude": 77.624470
}
```

### 4.6 Confirm Delivery (Order Completion)
- **Endpoint**: `POST /rider/orders/{id}/confirm-delivery`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "delivery_otp": "6194",
  "cash_collected": 420.00,
  "latitude": 12.912120,
  "longitude": 77.644550,
  "proof_photo_url": "https://storage.freska.app/proofs/10842.jpg"
}
```
- **Response (200 OK)**:
```json
{
  "success": true,
  "message": "Delivery completed successfully. Earnings credited.",
  "data": {
    "order_id": 10842,
    "payout_credited": 68.00,
    "today_earnings": 540.00,
    "today_deliveries": 8,
    "cod_held": 420.00
  }
}
```

---

## 5. Financials, COD & Performance

### 5.1 Rider Financial Summary (Today & Weekly)
- **Endpoint**: `GET /rider/financials/summary`
- **Auth**: Bearer Token (`rider`)
- **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "today": {
      "total_earnings": 540.00,
      "completed_deliveries": 8,
      "base_pay": 380.00,
      "distance_pay": 90.00,
      "surge_pay": 40.00,
      "tips": 30.00
    },
    "weekly": {
      "total_earnings": 4120.00,
      "completed_deliveries": 62,
      "days": [
        {"day": "Mon", "amount": 620.00, "deliveries": 9},
        {"day": "Tue", "amount": 710.00, "deliveries": 11},
        {"day": "Wed", "amount": 580.00, "deliveries": 9},
        {"day": "Thu", "amount": 540.00, "deliveries": 8}
      ]
    },
    "active_incentives": [
      {
        "id": 1,
        "title": "Daily Peak Hour Sprint",
        "description": "Complete 10 deliveries today between 5PM-9PM",
        "reward": 150.00,
        "progress": 8,
        "target": 10,
        "is_completed": false
      }
    ]
  }
}
```

### 5.2 COD Management & Handover
- **Endpoint**: `GET /rider/cod/orders`
- **Auth**: Bearer Token (`rider`)
- **Response (200 OK)**: Returns list of COD orders, total cash in hand, and maximum cash threshold limit.

### 5.3 Submit COD Cash Deposit / Handover
- **Endpoint**: `POST /rider/cod/deposit`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "amount": 2400.00,
  "handover_method": "hub_deposit",
  "handover_reference": "HUB-KOR-REC-9082",
  "receipt_url": "https://storage.freska.app/cod_receipts/rec_9082.jpg"
}
```

### 5.4 Performance Metrics & Feedback
- **Endpoint**: `GET /rider/performance`
- **Auth**: Bearer Token (`rider`)
- **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "rating_average": 4.92,
    "rating_count": 314,
    "acceptance_rate": 96.5,
    "on_time_rate": 98.2,
    "completed_deliveries_total": 482,
    "tier": "platinum",
    "customer_feedback": [
      {"badge": "Super Fast Delivery", "count": 142},
      {"badge": "Polite & Professional", "count": 98},
      {"badge": "Careful Handling of Produce", "count": 76}
    ]
  }
}
```

---

## 6. Safety, SOS & Support

### 6.1 Trigger SOS Alert
- **Endpoint**: `POST /rider/safety/sos`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "latitude": 12.934890,
  "longitude": 77.625120,
  "location_address": "80 Feet Rd, 4th Block, Koramangala"
}
```
- **Response (200 OK)**: Instantly logs incident, notifies dispatch operations, and broadcasts emergency alert.

### 6.2 Accident / Incident Report
- **Endpoint**: `POST /rider/safety/incident`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "type": "road_accident",
  "latitude": 12.934890,
  "longitude": 77.625120,
  "description": "Rear-ended by another two-wheeler at junction. Minor damage to bike.",
  "medical_assistance_needed": false,
  "media_urls": ["https://storage.freska.app/incidents/inc_102.jpg"]
}
```

### 6.3 Insurance Details (Page 10 Requirement)
- **Endpoint**: `GET /rider/safety/insurance`
- **Auth**: Bearer Token (`rider`)
- **Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "has_insurance": true,
    "policy_number": "FRESKA-HDFC-ERGO-98124",
    "provider": "HDFC ERGO General Insurance",
    "coverage_amount": 500000.00,
    "valid_until": "2027-03-31",
    "document_url": "https://storage.freska.app/insurance/policy_98124.pdf",
    "cashless_hospitals_url": "https://freska.app/hospitals"
  }
}
```
*(Note: If not formally assigned by FRESKA, `has_insurance` returns `false` and details are null)*.

### 6.4 Create Support Ticket
- **Endpoint**: `POST /rider/support/tickets`
- **Auth**: Bearer Token (`rider`)
- **Request Body**:
```json
{
  "category": "vendor_pickup_issue",
  "order_id": 10842,
  "subject": "Vendor store closed upon arrival",
  "description": "Arrived at 14:05, merchant shutters are down and phone is switched off.",
  "attachment_url": null,
  "priority": "high"
}
```

---

## 7. Private Admin Panel Endpoints (Restricted)

- `GET /admin/dashboard/kpis` — Overall fleet numbers, active orders, today's gross volume.
- `GET /admin/riders` — Rider management list with filters (`status`, `is_online`, `kyc_status`).
- `POST /admin/riders/{id}/kyc-status` — Approve or reject KYC.
- `GET /admin/orders` — Live order dispatch board with map coordinate streaming.
- `GET /admin/cod/reconcile` — Unremitted and pending deposit queue.
- `POST /admin/cod/{id}/reconcile` — One-click verify and reconcile cash deposit.
- `GET /admin/incidents` — SOS alerts and safety incidents triage.
- `GET /admin/audit-logs` — Immutable audit log explorer.
