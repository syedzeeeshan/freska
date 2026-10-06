# Freska Delivery Partner Platform — Database Schema Specification

This document defines the relational database design for MySQL 8.0 / PostgreSQL, normalized to 3NF, with optimized indexing for high-concurrency dispatching, geo-location queries, and financial auditability.

---

## 1. Table Architecture & Definitions

### 1.1 `users`
Core user identity for both delivery partners (riders) and management/admin staff.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `name`: `VARCHAR(120) NULL`
- `phone`: `VARCHAR(20) UNIQUE NOT NULL` (E.164 format, e.g., `+919876543210`)
- `phone_verified_at`: `TIMESTAMP NULL`
- `email`: `VARCHAR(150) UNIQUE NULL`
- `email_verified_at`: `TIMESTAMP NULL`
- `password`: `VARCHAR(255) NULL` (Required for Web Admin, optional for OTP-only riders)
- `avatar_url`: `VARCHAR(500) NULL`
- `role`: `ENUM('rider', 'dispatcher', 'support_agent', 'operations_manager', 'super_admin') DEFAULT 'rider'`
- `status`: `ENUM('active', 'suspended', 'inactive', 'pending_kyc') DEFAULT 'pending_kyc'`
- `remember_token`: `VARCHAR(100) NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- `deleted_at`: `TIMESTAMP NULL` (Soft Delete)
- **Indexes**: `INDEX idx_users_phone (phone)`, `INDEX idx_users_role_status (role, status)`

---

### 1.2 `rider_profiles`
Detailed profile, vehicle credentials, bank accounts, and onboarding data.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `user_id`: `BIGINT UNSIGNED NOT NULL UNIQUE` (FK -> `users.id` ON DELETE CASCADE)
- `date_of_birth`: `DATE NULL`
- `gender`: `ENUM('male', 'female', 'other') NULL`
- `blood_group`: `VARCHAR(10) NULL`
- `vehicle_type`: `ENUM('bike', 'scooter', 'ev_two_wheeler', 'bicycle') DEFAULT 'bike'`
- `vehicle_number`: `VARCHAR(30) NULL`
- `license_number`: `VARCHAR(50) NULL`
- `license_expiry`: `DATE NULL`
- `license_front_url`: `VARCHAR(500) NULL`
- `license_back_url`: `VARCHAR(500) NULL`
- `rc_book_url`: `VARCHAR(500) NULL`
- `id_proof_type`: `ENUM('aadhaar', 'pan', 'passport', 'voter_id') DEFAULT 'aadhaar'`
- `id_proof_number`: `VARCHAR(50) NULL`
- `id_proof_url`: `VARCHAR(500) NULL`
- `kyc_status`: `ENUM('pending', 'submitted', 'verified', 'rejected') DEFAULT 'pending'`
- `kyc_rejection_reason`: `TEXT NULL`
- `kyc_reviewed_at`: `TIMESTAMP NULL`
- `kyc_reviewed_by`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `bank_account_holder`: `VARCHAR(150) NULL`
- `bank_name`: `VARCHAR(100) NULL`
- `bank_account_number`: `VARCHAR(50) NULL`
- `bank_ifsc_code`: `VARCHAR(20) NULL`
- `bank_upi_id`: `VARCHAR(100) NULL`
- `bank_verified`: `BOOLEAN DEFAULT FALSE`
- `emergency_contact_name`: `VARCHAR(120) NULL`
- `emergency_contact_phone`: `VARCHAR(20) NULL`
- `emergency_contact_relation`: `VARCHAR(50) NULL`
- `is_online`: `BOOLEAN DEFAULT FALSE`
- `current_latitude`: `DECIMAL(10, 8) NULL`
- `current_longitude`: `DECIMAL(11, 8) NULL`
- `last_location_updated_at`: `TIMESTAMP NULL`
- `max_cash_limit`: `DECIMAL(10, 2) DEFAULT 5000.00`
- `current_cash_in_hand`: `DECIMAL(10, 2) DEFAULT 0.00`
- `rating_average`: `DECIMAL(3, 2) DEFAULT 5.00`
- `rating_count`: `INT UNSIGNED DEFAULT 0`
- `acceptance_rate`: `DECIMAL(5, 2) DEFAULT 100.00` (Percentage)
- `on_time_rate`: `DECIMAL(5, 2) DEFAULT 100.00` (Percentage)
- `completed_deliveries_count`: `INT UNSIGNED DEFAULT 0`
- `tier`: `ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze'`
- `insurance_policy_number`: `VARCHAR(100) NULL`
- `insurance_provider`: `VARCHAR(150) NULL`
- `insurance_valid_until`: `DATE NULL`
- `insurance_document_url`: `VARCHAR(500) NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_riders_online_location (is_online, current_latitude, current_longitude)`, `INDEX idx_riders_kyc_status (kyc_status)`

---

### 1.3 `vendors`
Merchant/partner stores where riders pick up fresh goods.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `name`: `VARCHAR(150) NOT NULL`
- `store_code`: `VARCHAR(50) UNIQUE NOT NULL`
- `phone`: `VARCHAR(20) NOT NULL`
- `email`: `VARCHAR(150) NULL`
- `address`: `TEXT NOT NULL`
- `landmark`: `VARCHAR(150) NULL`
- `latitude`: `DECIMAL(10, 8) NOT NULL`
- `longitude`: `DECIMAL(11, 8) NOT NULL`
- `pickup_instructions`: `TEXT NULL`
- `contact_person`: `VARCHAR(100) NULL`
- `is_active`: `BOOLEAN DEFAULT TRUE`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_vendors_geo (latitude, longitude)`

---

### 1.4 `orders`
Core delivery order tracking lifecycle.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `order_number`: `VARCHAR(50) UNIQUE NOT NULL` (e.g., `FSK-2026-89421`)
- `vendor_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `vendors.id`)
- `rider_id`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `customer_name`: `VARCHAR(120) NOT NULL`
- `customer_phone`: `VARCHAR(20) NOT NULL`
- `delivery_address`: `TEXT NOT NULL`
- `delivery_area`: `VARCHAR(150) NOT NULL` (Sub-locality displayed before pickup)
- `delivery_latitude`: `DECIMAL(10, 8) NOT NULL`
- `delivery_longitude`: `DECIMAL(11, 8) NOT NULL`
- `delivery_instructions`: `TEXT NULL`
- `order_type`: `ENUM('fresh_produce', 'dairy_cold_chain', 'grocery', 'bakery', 'express') DEFAULT 'grocery'`
- `item_count`: `INT UNSIGNED DEFAULT 1`
- `package_details`: `JSON NULL` (Item list, fragile flags, temperature requirements)
- `is_fragile`: `BOOLEAN DEFAULT FALSE`
- `is_cold_chain`: `BOOLEAN DEFAULT FALSE`
- `status`: `ENUM('created', 'dispatched', 'offered', 'accepted', 'arrived_vendor', 'picked_up', 'in_transit', 'arrived_customer', 'delivered', 'cancelled', 'rejected', 'failed') DEFAULT 'created'`
- `payment_mode`: `ENUM('prepaid', 'cod') DEFAULT 'prepaid'`
- `cod_amount`: `DECIMAL(10, 2) DEFAULT 0.00`
- `is_cod_collected`: `BOOLEAN DEFAULT FALSE`
- `cod_collected_at`: `TIMESTAMP NULL`
- `delivery_otp`: `VARCHAR(6) NULL`
- `delivery_signature_url`: `VARCHAR(500) NULL`
- `delivery_proof_photo_url`: `VARCHAR(500) NULL`
- `estimated_distance_km`: `DECIMAL(6, 2) NOT NULL`
- `estimated_duration_mins`: `INT UNSIGNED NOT NULL`
- `base_payout`: `DECIMAL(8, 2) NOT NULL`
- `distance_payout`: `DECIMAL(8, 2) DEFAULT 0.00`
- `surge_payout`: `DECIMAL(8, 2) DEFAULT 0.00`
- `tip_amount`: `DECIMAL(8, 2) DEFAULT 0.00`
- `total_rider_payout`: `DECIMAL(8, 2) NOT NULL`
- `assignment_offered_at`: `TIMESTAMP NULL`
- `assignment_accepted_at`: `TIMESTAMP NULL`
- `arrived_vendor_at`: `TIMESTAMP NULL`
- `picked_up_at`: `TIMESTAMP NULL`
- `delivered_at`: `TIMESTAMP NULL`
- `cancelled_at`: `TIMESTAMP NULL`
- `cancellation_reason`: `TEXT NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_orders_status (status)`, `INDEX idx_orders_rider_status (rider_id, status)`, `INDEX idx_orders_vendor (vendor_id)`

---

### 1.5 `order_assignment_offers`
Tracks assignments offered to riders with countdown timer and responses for auditability.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `order_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `orders.id` ON DELETE CASCADE)
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id` ON DELETE CASCADE)
- `offered_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `expires_at`: `TIMESTAMP NOT NULL`
- `status`: `ENUM('offered', 'accepted', 'rejected', 'expired') DEFAULT 'offered'`
- `rejection_reason`: `VARCHAR(255) NULL`
- `response_timestamp`: `TIMESTAMP NULL`
- **Indexes**: `INDEX idx_assignment_order_rider (order_id, rider_id, status)`

---

### 1.6 `cod_collections`
Tracks cash-on-delivery collections and remittance to Freska.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `order_id`: `BIGINT UNSIGNED NOT NULL UNIQUE` (FK -> `orders.id`)
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `amount`: `DECIMAL(10, 2) NOT NULL`
- `collected_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `collection_latitude`: `DECIMAL(10, 8) NULL`
- `collection_longitude`: `DECIMAL(11, 8) NULL`
- `handover_status`: `ENUM('held_in_hand', 'submitted', 'verified_reconciled', 'disputed') DEFAULT 'held_in_hand'`
- `handover_method`: `ENUM('hub_deposit', 'bank_cdm', 'upi_clawback') NULL`
- `handover_reference`: `VARCHAR(100) NULL`
- `handover_receipt_url`: `VARCHAR(500) NULL`
- `submitted_at`: `TIMESTAMP NULL`
- `reconciled_at`: `TIMESTAMP NULL`
- `reconciled_by`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `reconciliation_notes`: `TEXT NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_cod_rider_status (rider_id, handover_status)`

---

### 1.7 `rider_earnings`
Itemized ledger for every completed delivery, tip, and incentive milestone.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `order_id`: `BIGINT UNSIGNED NULL` (FK -> `orders.id` ON DELETE SET NULL)
- `earning_type`: `ENUM('delivery_fee', 'distance_bonus', 'surge_bonus', 'customer_tip', 'daily_incentive', 'weekly_milestone', 'deduction') NOT NULL`
- `amount`: `DECIMAL(8, 2) NOT NULL`
- `description`: `VARCHAR(255) NOT NULL`
- `date`: `DATE NOT NULL`
- `payout_id`: `BIGINT UNSIGNED NULL` (FK -> `payouts.id`)
- `status`: `ENUM('pending', 'processed', 'paid') DEFAULT 'pending'`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_earnings_rider_date (rider_id, date)`, `INDEX idx_earnings_payout (payout_id)`

---

### 1.8 `payouts`
Periodic batch or manual payouts disbursed to rider bank accounts.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `payout_number`: `VARCHAR(50) UNIQUE NOT NULL`
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `period_start`: `DATE NOT NULL`
- `period_end`: `DATE NOT NULL`
- `deliveries_count`: `INT UNSIGNED NOT NULL`
- `base_amount`: `DECIMAL(10, 2) NOT NULL`
- `incentives_amount`: `DECIMAL(10, 2) DEFAULT 0.00`
- `tips_amount`: `DECIMAL(10, 2) DEFAULT 0.00`
- `deductions_amount`: `DECIMAL(10, 2) DEFAULT 0.00`
- `net_payout_amount`: `DECIMAL(10, 2) NOT NULL`
- `bank_reference_number`: `VARCHAR(100) NULL`
- `payment_method`: `ENUM('bank_transfer', 'upi_payout', 'instant_transfer') DEFAULT 'bank_transfer'`
- `status`: `ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending'`
- `processed_at`: `TIMESTAMP NULL`
- `failure_reason`: `TEXT NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_payouts_rider (rider_id, status)`

---

### 1.9 `support_tickets`
Help and support tickets submitted by delivery partners.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `ticket_number`: `VARCHAR(50) UNIQUE NOT NULL`
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `order_id`: `BIGINT UNSIGNED NULL` (FK -> `orders.id`)
- `category`: `ENUM('customer_issue', 'vendor_pickup_issue', 'payment_payout_issue', 'emergency_support', 'app_technical_issue', 'other') NOT NULL`
- `subject`: `VARCHAR(200) NOT NULL`
- `description`: `TEXT NOT NULL`
- `attachment_url`: `VARCHAR(500) NULL`
- `priority`: `ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium'`
- `status`: `ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open'`
- `assigned_to`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `resolution_notes`: `TEXT NULL`
- `resolved_at`: `TIMESTAMP NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_tickets_rider (rider_id, status)`, `INDEX idx_tickets_status (status, priority)`

---

### 1.10 `incidents_and_sos`
Tracks safety alerts, SOS triggers, and accident reporting.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `incident_number`: `VARCHAR(50) UNIQUE NOT NULL`
- `rider_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `order_id`: `BIGINT UNSIGNED NULL` (FK -> `orders.id`)
- `type`: `ENUM('sos_panic', 'road_accident', 'vehicle_breakdown', 'customer_harassment', 'dog_bite', 'weather_hazard') NOT NULL`
- `latitude`: `DECIMAL(10, 8) NOT NULL`
- `longitude`: `DECIMAL(11, 8) NOT NULL`
- `location_address`: `TEXT NULL`
- `description`: `TEXT NULL`
- `media_urls`: `JSON NULL`
- `medical_assistance_needed`: `BOOLEAN DEFAULT FALSE`
- `status`: `ENUM('triggered', 'acknowledged', 'ops_dispatched', 'resolved', 'false_alarm') DEFAULT 'triggered'`
- `acknowledged_at`: `TIMESTAMP NULL`
- `acknowledged_by`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `resolution_report`: `TEXT NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- `updated_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_incidents_type_status (type, status)`

---

### 1.11 `audit_logs`
Immutable compliance audit log strictly recording state changes (Page 14).
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `user_id`: `BIGINT UNSIGNED NULL` (FK -> `users.id`)
- `order_id`: `BIGINT UNSIGNED NULL` (FK -> `orders.id`)
- `action`: `VARCHAR(100) NOT NULL`
- `latitude`: `DECIMAL(10, 8) NULL`
- `longitude`: `DECIMAL(11, 8) NULL`
- `ip_address`: `VARCHAR(45) NULL`
- `user_agent`: `VARCHAR(255) NULL`
- `metadata`: `JSON NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_audit_order (order_id)`, `INDEX idx_audit_user (user_id)`, `INDEX idx_audit_action (action)`

---

### 1.12 `notifications`
Push & in-app notifications generated for riders.
- `id`: `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`
- `user_id`: `BIGINT UNSIGNED NOT NULL` (FK -> `users.id`)
- `title`: `VARCHAR(150) NOT NULL`
- `body`: `TEXT NOT NULL`
- `type`: `ENUM('order_assignment', 'pickup_reminder', 'delivery_update', 'payout_credited', 'announcement', 'security_alert') NOT NULL`
- `data`: `JSON NULL`
- `is_read`: `BOOLEAN DEFAULT FALSE`
- `read_at`: `TIMESTAMP NULL`
- `created_at`: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- **Indexes**: `INDEX idx_notifications_user_read (user_id, is_read)`
