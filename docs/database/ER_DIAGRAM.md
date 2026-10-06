# Freska Delivery Partner Platform — Entity Relationship (ER) Diagram

This document models the core domain entities, relational integrity constraints, and cardinality rules for the Freska Delivery Partner Platform.

---

## 1. Visual Entity-Relationship Diagram

```mermaid
erDiagram
    USERS ||--|| RIDER_PROFILES : "has profile (1:1)"
    USERS ||--o{ ORDERS : "delivers (1:N)"
    USERS ||--o{ ORDER_ASSIGNMENT_OFFERS : "offered to (1:N)"
    USERS ||--o{ COD_COLLECTIONS : "collects & remits (1:N)"
    USERS ||--o{ RIDER_EARNINGS : "earns (1:N)"
    USERS ||--o{ PAYOUTS : "receives (1:N)"
    USERS ||--o{ SUPPORT_TICKETS : "submits (1:N)"
    USERS ||--o{ INCIDENTS_AND_SOS : "reports (1:N)"
    USERS ||--o{ NOTIFICATIONS : "receives (1:N)"
    USERS ||--o{ AUDIT_LOGS : "triggers (1:N)"

    VENDORS ||--o{ ORDERS : "fulfills (1:N)"

    ORDERS ||--o{ ORDER_ASSIGNMENT_OFFERS : "dispatched as (1:N)"
    ORDERS ||--o| COD_COLLECTIONS : "generates (1:1)"
    ORDERS ||--o{ RIDER_EARNINGS : "yields (1:N)"
    ORDERS ||--o{ SUPPORT_TICKETS : "associated with (0..N)"
    ORDERS ||--o{ INCIDENTS_AND_SOS : "associated with (0..N)"
    ORDERS ||--o{ AUDIT_LOGS : "audited under (1:N)"

    PAYOUTS ||--o{ RIDER_EARNINGS : "settles (1:N)"

    USERS {
        bigint id PK
        string phone UK
        string email UK
        string name
        string role
        string status
        timestamp created_at
    }

    RIDER_PROFILES {
        bigint id PK
        bigint user_id FK,UK
        string vehicle_type
        string vehicle_number
        string license_number
        string kyc_status
        string bank_account_number
        string bank_ifsc_code
        string emergency_contact_phone
        boolean is_online
        decimal current_latitude
        decimal current_longitude
        decimal current_cash_in_hand
        decimal acceptance_rate
        decimal on_time_rate
        string tier
        string insurance_policy_number
    }

    VENDORS {
        bigint id PK
        string store_code UK
        string name
        string phone
        text address
        decimal latitude
        decimal longitude
        text pickup_instructions
    }

    ORDERS {
        bigint id PK
        string order_number UK
        bigint vendor_id FK
        bigint rider_id FK
        string customer_name
        string customer_phone
        text delivery_address
        string delivery_area
        decimal delivery_latitude
        decimal delivery_longitude
        string status
        string payment_mode
        decimal cod_amount
        string delivery_otp
        decimal total_rider_payout
        timestamp assignment_accepted_at
        timestamp picked_up_at
        timestamp delivered_at
    }

    ORDER_ASSIGNMENT_OFFERS {
        bigint id PK
        bigint order_id FK
        bigint rider_id FK
        timestamp offered_at
        timestamp expires_at
        string status
        string rejection_reason
    }

    COD_COLLECTIONS {
        bigint id PK
        bigint order_id FK,UK
        bigint rider_id FK
        decimal amount
        string handover_status
        string handover_method
        string handover_reference
        timestamp collected_at
        timestamp reconciled_at
    }

    RIDER_EARNINGS {
        bigint id PK
        bigint rider_id FK
        bigint order_id FK
        string earning_type
        decimal amount
        date date
        bigint payout_id FK
        string status
    }

    PAYOUTS {
        bigint id PK
        string payout_number UK
        bigint rider_id FK
        date period_start
        date period_end
        decimal net_payout_amount
        string status
        string bank_reference_number
    }

    SUPPORT_TICKETS {
        bigint id PK
        string ticket_number UK
        bigint rider_id FK
        bigint order_id FK
        string category
        string subject
        string priority
        string status
    }

    INCIDENTS_AND_SOS {
        bigint id PK
        string incident_number UK
        bigint rider_id FK
        bigint order_id FK
        string type
        decimal latitude
        decimal longitude
        string status
        boolean medical_assistance_needed
    }

    AUDIT_LOGS {
        bigint id PK
        bigint user_id FK
        bigint order_id FK
        string action
        decimal latitude
        decimal longitude
        string ip_address
        json metadata
        timestamp created_at
    }

    NOTIFICATIONS {
        bigint id PK
        bigint user_id FK
        string title
        text body
        string type
        boolean is_read
        timestamp created_at
    }
```

---

## 2. Relational Cardinality & Referential Integrity

1. **User to Rider Profile (`1:1`)**:
   - `rider_profiles.user_id` is unique and references `users.id` with `ON DELETE CASCADE`.
2. **Vendor to Orders (`1:N`)**:
   - `orders.vendor_id` references `vendors.id` with `ON DELETE RESTRICT`. A vendor cannot be deleted if active or historical orders exist.
3. **Rider to Orders (`1:N`)**:
   - `orders.rider_id` references `users.id` with `ON DELETE SET NULL`.
4. **Order to COD Collection (`1:1`)**:
   - `cod_collections.order_id` is unique and references `orders.id` with `ON DELETE RESTRICT`.
5. **Payout to Rider Earnings (`1:N`)**:
   - `rider_earnings.payout_id` references `payouts.id` with `ON DELETE SET NULL`. Individual line items remain immutable even if a payout record is modified.
6. **Audit Trail Immutability**:
   - `audit_logs` has no update or cascade delete triggers; append-only schema for SOC2 and regulatory compliance.
