# Freska Delivery Partner Platform
# Module 03: Complete REST API Specification

**Document ID**: `FRESKA-DOC-03`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  
**Base URL**: `https://api.freska.app/api/v1` (Production) / `http://localhost:8000/api/v1` (Local)  

---

## 1. Global API Standards & Envelope

### 1.1 Standard Request Headers
```http
Authorization: Bearer <sanctum_token>
Accept: application/json
Content-Type: application/json
X-Device-Id: 9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d
X-App-Version: 1.0.0+14
X-Platform: android
```

### 1.2 Success Response Envelope (HTTP 200 / 201)
```json
{
  "success": true,
  "message": "Operation completed successfully.",
  "data": {},
  "meta": {
    "timestamp": "2026-09-21T02:00:00Z",
    "version": "v1"
  }
}
```

### 1.3 Error Response Envelope (HTTP 4xx / 5xx)
```json
{
  "success": false,
  "message": "Validation failed / Unauthorized / Not found.",
  "error_code": "ERR_VALIDATION_FAILED",
  "errors": {
    "field_name": [
      "The field_name is required."
    ]
  }
}
```

---

## 2. Authentication & Device Binding

### 2.1 Send Mobile OTP
* **URL**: `/auth/otp/send`
* **Method**: `POST`
* **Auth**: Public
* **Validation Rules**:
  * `phone`: `required|string|regex:/^\+[1-9]\d{1,14}$/` (E.164 Format)
* **Request JSON**:
```json
{
  "phone": "+919876543210"
}
```
* **Response (HTTP 200)**:
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
* **Error Response (HTTP 422)**:
```json
{
  "success": false,
  "message": "Invalid phone format.",
  "error_code": "ERR_INVALID_PHONE",
  "errors": {
    "phone": ["Phone must be in E.164 international format."]
  }
}
```

### 2.2 Verify Mobile OTP & Issue Device Session Token
* **URL**: `/auth/otp/verify`
* **Method**: `POST`
* **Auth**: Public
* **Validation Rules**:
  * `phone`: `required|string`
  * `otp`: `required|string|digits:6`
  * `device_id`: `required|string|uuid`
  * `device_model`: `required|string|max:100`
  * `os_version`: `required|string|max:50`
  * `fcm_token`: `nullable|string`
* **Request JSON**:
```json
{
  "phone": "+919876543210",
  "otp": "458921",
  "device_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "device_model": "Pixel 8 Pro",
  "os_version": "Android 14",
  "fcm_token": "fcm_token_string_here"
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Authentication successful.",
  "data": {
    "token": "14|sanctum_token_string_here...",
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

### 2.3 Logout & Invalidate Device Session
* **URL**: `/auth/logout`
* **Method**: `POST`
* **Auth**: Bearer Token
* **Request JSON**: `{}`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Logged out successfully."
}
```

---

## 3. Rider Onboarding & KYC

### 3.1 Upload Rider Profile Selfie
* **URL**: `/rider/profile/photo`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Content-Type**: `multipart/form-data`
* **Validation**: `photo: required|image|mimes:jpeg,png|max:5120`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Profile selfie uploaded.",
  "data": {
    "avatar_url": "https://storage.freska.app/profiles/14_selfie.jpg"
  }
}
```

### 3.2 Submit Full KYC Documents
* **URL**: `/rider/documents`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Content-Type**: `multipart/form-data`
* **Validation Rules**:
  * `vehicle_type`: `required|in:bike,scooter,ev_two_wheeler,bicycle`
  * `vehicle_number`: `required|string|max:30`
  * `license_number`: `required|string|max:50`
  * `license_expiry`: `required|date|after:today`
  * `license_front`: `required|file|mimes:jpeg,png,pdf|max:5120`
  * `license_back`: `required|file|mimes:jpeg,png,pdf|max:5120`
  * `rc_book`: `required|file|mimes:jpeg,png,pdf|max:5120`
  * `id_proof_type`: `required|in:aadhaar,pan,passport,voter_id`
  * `id_proof_number`: `required|string|max:50`
  * `id_proof_document`: `required|file|mimes:jpeg,png,pdf|max:5120`
* **Response (HTTP 201)**:
```json
{
  "success": true,
  "message": "KYC documents submitted for review.",
  "data": {
    "kyc_status": "submitted",
    "submitted_at": "2026-09-21T02:05:00Z"
  }
}
```

### 3.3 Submit Bank & Payout Details
* **URL**: `/rider/bank-details`
* **Method**: `PUT`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `bank_account_holder`: `required|string|max:150`
  * `bank_name`: `required|string|max:100`
  * `bank_account_number`: `required|string|min:9|max:30`
  * `bank_ifsc_code`: `required|string|regex:/^[A-Z]{4}0[A-Z0-9]{6}$/`
  * `bank_upi_id`: `nullable|string|max:100`
* **Request JSON**:
```json
{
  "bank_account_holder": "Arjun Sharma",
  "bank_name": "HDFC Bank",
  "bank_account_number": "50100234918231",
  "bank_ifsc_code": "HDFC0001234",
  "bank_upi_id": "arjun@okhdfcbank"
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Bank details submitted and verified.",
  "data": {
    "bank_verified": true
  }
}
```

---

## 4. Duty Availability & Telemetry Heartbeat

### 4.1 Toggle Online / Offline Duty Status
* **URL**: `/rider/duty/toggle`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `is_online`: `required|boolean`
  * `latitude`: `required_if:is_online,true|numeric|between:-90,90`
  * `longitude`: `required_if:is_online,true|numeric|between:-180,180`
* **Request JSON**:
```json
{
  "is_online": true,
  "latitude": 12.971598,
  "longitude": 77.594562
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Rider status is now Online.",
  "data": {
    "is_online": true,
    "last_location_updated_at": "2026-09-21T02:08:00Z"
  }
}
```

### 4.2 Rider Background Location Heartbeat (Every 15-30s)
* **URL**: `/rider/location`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `latitude`: `required|numeric|between:-90,90`
  * `longitude`: `required|numeric|between:-180,180`
  * `heading`: `nullable|numeric|between:0,360`
  * `speed`: `nullable|numeric|min:0`
  * `battery_percentage`: `nullable|integer|between:0,100`
  * `is_mock`: `required|boolean`
* **Request JSON**:
```json
{
  "latitude": 12.972100,
  "longitude": 77.595100,
  "heading": 85.4,
  "speed": 22.5,
  "battery_percentage": 82,
  "is_mock": false
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Location updated."
}
```

---

## 5. Order Dispatch & Fulfillment Lifecycle

### 5.1 Fetch Current Active Order Assignment
* **URL**: `/rider/orders/active`
* **Method**: `GET`
* **Auth**: Bearer Token (`rider`)
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "data": {
    "has_active_order": true,
    "order": {
      "id": 10842,
      "order_number": "FSK-2026-89421",
      "status": "accepted",
      "vendor": {
        "id": 12,
        "name": "Freska Hub Koramangala",
        "phone": "+918049281200",
        "address": "80 Feet Rd, 4th Block, Koramangala, Bengaluru",
        "latitude": 12.935242,
        "longitude": 77.624466,
        "pickup_instructions": "Enter through Gate 2, dock 4"
      },
      "customer": {
        "name": "Priya V.",
        "phone": "+919988776655",
        "delivery_area": "HSR Layout Sector 1",
        "delivery_address": "Masked until picked up",
        "delivery_latitude": 12.912118,
        "delivery_longitude": 77.644554,
        "delivery_instructions": "Ring bell once, leave at door"
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

### 5.2 Accept Order Assignment Offer (Slide 04)
* **URL**: `/rider/orders/{id}/accept`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
* **Request JSON**:
```json
{
  "latitude": 12.971598,
  "longitude": 77.594562
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Order accepted successfully.",
  "data": {
    "order_id": 10842,
    "status": "accepted",
    "accepted_at": "2026-09-21T02:10:00Z"
  }
}
```

### 5.3 Reject Order Assignment Offer (Slide 04)
* **URL**: `/rider/orders/{id}/reject`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `reason`: `required|string|max:255`
* **Request JSON**:
```json
{
  "reason": "Vehicle puncture / mechanical issue"
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Order declined."
}
```

### 5.4 Mark Arrived at Vendor (Slide 05)
* **URL**: `/rider/orders/{id}/arrive-vendor`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Arrival recorded.",
  "data": {
    "status": "arrived_vendor",
    "arrived_vendor_at": "2026-09-21T02:18:00Z"
  }
}
```

### 5.5 Mark Order Picked Up from Vendor (Slide 05)
* **URL**: `/rider/orders/{id}/pickup`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `package_verified`: `required|boolean|accepted`
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
* **Request JSON**:
```json
{
  "package_verified": true,
  "latitude": 12.935242,
  "longitude": 77.624466
}
```
* **Response (HTTP 200)**: Unmasks full customer street address and contact.
```json
{
  "success": true,
  "message": "Order picked up. Navigating to customer.",
  "data": {
    "status": "picked_up",
    "customer_full_address": "#412, 14th Main, HSR Layout, Sector 1, Bengaluru",
    "customer_phone": "+919988776655"
  }
}
```

### 5.6 Confirm Delivery (Slide 06)
* **URL**: `/rider/orders/{id}/confirm-delivery`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Content-Type**: `multipart/form-data`
* **Validation Rules**:
  * `otp`: `required|string|size:4`
  * `proof_photo`: `nullable|file|mimes:jpeg,png|max:5120`
  * `signature`: `nullable|file|mimes:png|max:2048`
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Delivery completed successfully.",
  "data": {
    "order_id": 10842,
    "status": "delivered",
    "delivered_at": "2026-09-21T02:35:00Z",
    "earnings_credited": 68.00,
    "cod_collected": 420.00
  }
}
```

---

## 6. Financials, Earnings & COD Management

### 6.1 Get Earnings Summary (Slide 07)
* **URL**: `/rider/earnings/summary`
* **Method**: `GET`
* **Auth**: Bearer Token (`rider`)
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "data": {
    "today": {
      "total_earnings": 840.00,
      "deliveries_count": 12,
      "base_pay": 600.00,
      "surge_pay": 140.00,
      "tips": 100.00
    },
    "this_week": {
      "total_earnings": 5120.00,
      "deliveries_count": 78
    },
    "active_incentives": [
      {
        "title": "Evening Rush Bonus",
        "description": "Complete 5 orders between 6PM-9PM",
        "target": 5,
        "current": 3,
        "reward": 150.00
      }
    ]
  }
}
```

### 6.2 Get COD Ledger & Handover Status (Slide 08)
* **URL**: `/rider/cod/summary`
* **Method**: `GET`
* **Auth**: Bearer Token (`rider`)
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "data": {
    "current_cash_in_hand": 1840.00,
    "max_cash_limit": 5000.00,
    "available_limit": 3160.00,
    "pending_reconciliation_orders_count": 3,
    "is_limit_exceeded": false
  }
}
```

### 6.3 Submit COD Cash Handover / Remittance (Slide 08)
* **URL**: `/rider/cod/handover`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Content-Type**: `multipart/form-data`
* **Validation**:
  * `amount`: `required|numeric|min:1`
  * `handover_method`: `required|in:hub_deposit,bank_cdm,upi_clawback`
  * `reference_number`: `required|string|max:100`
  * `receipt_photo`: `nullable|file|mimes:jpeg,png|max:5120`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "COD handover submitted for operations reconciliation.",
  "data": {
    "handover_status": "submitted",
    "amount": 1840.00
  }
}
```

---

## 7. Performance & Safety (SOS)

### 7.1 Trigger Emergency SOS (Slide 10)
* **URL**: `/rider/safety/sos`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Validation**:
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
  * `active_order_id`: `nullable|integer`
* **Request JSON**:
```json
{
  "latitude": 12.935242,
  "longitude": 77.624466,
  "active_order_id": 10842
}
```
* **Response (HTTP 201)**:
```json
{
  "success": true,
  "message": "EMERGENCY SOS RECEIVED. Operations desk dispatched and emergency contacts alerted.",
  "data": {
    "incident_number": "SOS-2026-0048",
    "emergency_helpline": "+918000999112"
  }
}
```

### 7.2 Submit Accident / Incident Report (Slide 10)
* **URL**: `/rider/safety/incident`
* **Method**: `POST`
* **Auth**: Bearer Token (`rider`)
* **Content-Type**: `multipart/form-data`
* **Validation**:
  * `type`: `required|in:road_accident,vehicle_breakdown,customer_harassment,dog_bite,weather_hazard`
  * `latitude`: `required|numeric`
  * `longitude`: `required|numeric`
  * `description`: `required|string|max:1000`
  * `medical_assistance_needed`: `required|boolean`
  * `photos.*`: `nullable|file|mimes:jpeg,png|max:5120`
* **Response (HTTP 201)**:
```json
{
  "success": true,
  "message": "Incident report registered.",
  "data": {
    "incident_number": "INC-2026-0091"
  }
}
```

---

## 8. Management, Operations & Dispatcher APIs (Part 18)

These APIs run on the administrative subsystem and are inaccessible to standard riders:

### 8.1 Dispatcher: Real-Time Fleet Radar Map
* **URL**: `/admin/dispatch/fleet-radar`
* **Method**: `GET`
* **Auth**: Bearer Token (`dispatcher`, `operations_manager`, `super_admin`)
* **Query Params**: `latitude`, `longitude`, `radius_km`
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "data": {
    "riders_online": [
      {
        "rider_id": 14,
        "name": "Arjun Sharma",
        "phone": "+919876543210",
        "latitude": 12.971598,
        "longitude": 77.594562,
        "speed_kmh": 24.2,
        "active_order_id": 10842,
        "battery_level": 82
      }
    ]
  }
}
```

### 8.2 Operations: Approve/Reject KYC Verification
* **URL**: `/admin/riders/{id}/kyc-status`
* **Method**: `PATCH`
* **Auth**: Bearer Token (`operations_manager`, `super_admin`)
* **Request JSON**:
```json
{
  "status": "verified",
  "rejection_reason": null
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "Rider KYC status updated to verified."
}
```

### 8.3 Operations: Verify COD Remittance Handover
* **URL**: `/admin/cod/collections/{id}/reconcile`
* **Method**: `POST`
* **Auth**: Bearer Token (`operations_manager`, `super_admin`)
* **Request JSON**:
```json
{
  "status": "verified_reconciled",
  "notes": "Verified against HDFC Bank CDM deposit slip #984210"
}
```
* **Response (HTTP 200)**:
```json
{
  "success": true,
  "message": "COD collection reconciled and rider cash balance decremented."
}
```
