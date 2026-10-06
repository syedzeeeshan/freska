# Freska Delivery Partner Platform
# Module 01: Project Structure & Architectural Organization

**Document ID**: `FRESKA-DOC-01`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  
**Target Runtimes**: Flutter 3.x (Dart 3.x), PHP 8.3+ / Laravel 11.x  

---

## 1. Executive Architectural Overview

The Freska platform follows strict **Clean Architecture** principles across both the mobile client and backend API. The architecture decouples the core business logic from external frameworks, user interfaces, device drivers, and storage engines.

```
+-------------------------------------------------------------------------+
| Clean Architecture Layer Separation                                     |
+-------------------------------------------------------------------------+
| [ Presentation / UI ] <--> [ Application / Bloc / Service ]             |
|                                     |                                   |
|                                     v                                   |
|                      [ Domain / Entities / Interfaces ]                 |
|                                     ^                                   |
|                                     |                                   |
|               [ Infrastructure / Repositories / Data Sources ]          |
+-------------------------------------------------------------------------+
```

---

## 2. Flutter Mobile Application Structure

### 2.1 Complete Directory Layout
```
freska_rider/
├── .github/
│   └── workflows/
│       ├── flutter_ci.yml
│       └── flutter_release.yml
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle
│   └── key.properties.example
├── ios/
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   └── Podfile
├── assets/
│   ├── fonts/
│   │   ├── GoogleSans-Regular.ttf
│   │   ├── GoogleSans-Medium.ttf
│   │   ├── GoogleSans-Bold.ttf
│   │   └── GoogleSans-Italic.ttf
│   ├── icons/
│   │   ├── app_icon.png
│   │   ├── sos_shield.svg
│   │   ├── cold_chain.svg
│   │   └── bike_marker.png
│   ├── images/
│   │   ├── onboarding_rider.png
│   │   ├── kyc_illustration.png
│   │   └── logo_freska_stitch.png
│   ├── sounds/
│   │   ├── order_alert.mp3
│   │   └── sos_siren.mp3
│   └── map_styles/
│       ├── stitch_dark_map.json
│       └── stitch_light_map.json
├── lib/
│   ├── main.dart
│   ├── main_development.dart
│   ├── main_staging.dart
│   ├── main_production.dart
│   │
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── environment.dart
│   │   ├── flavour_config.dart
│   │   └── network_constants.dart
│   │
│   ├── core/
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_handler.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_endpoints.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   └── network_info.dart
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   ├── hive_storage_service.dart
│   │   │   └── storage_keys.dart
│   │   ├── theme/
│   │   │   ├── stitch_colors.dart
│   │   │   ├── stitch_typography.dart
│   │   │   ├── stitch_elevation.dart
│   │   │   ├── stitch_spacing.dart
│   │   │   └── stitch_theme.dart
│   │   ├── utils/
│   │   │   ├── date_time_formatter.dart
│   │   │   ├── currency_formatter.dart
│   │   │   ├── distance_calculator.dart
│   │   │   ├── geofence_validator.dart
│   │   │   ├── input_validators.dart
│   │   │   ├── haptic_service.dart
│   │   │   └── logger.dart
│   │   └── constants/
│   │       ├── asset_constants.dart
│   │       ├── storage_constants.dart
│   │       └── ui_constants.dart
│   │
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── l10n/
│   │   │   ├── app_en.arb
│   │   │   ├── app_hi.arb
│   │   │   └── app_kn.arb
│   │   └── l10n.dart
│   │
│   ├── routing/
│   │   ├── app_router.dart
│   │   ├── route_guards.dart
│   │   └── route_names.dart
│   │
│   ├── services/
│   │   ├── location/
│   │   │   ├── background_geolocation_service.dart
│   │   │   ├── location_permission_handler.dart
│   │   │   └── mock_location_detector.dart
│   │   ├── push_notification/
│   │   │   ├── fcm_service.dart
│   │   │   ├── local_notification_service.dart
│   │   │   └── notification_payload_parser.dart
│   │   ├── socket/
│   │   │   ├── reverb_socket_service.dart
│   │   │   └── socket_events.dart
│   │   ├── audio/
│   │   │   └── audio_alert_service.dart
│   │   └── device/
│   │       ├── device_info_service.dart
│   │       └── battery_service.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── buttons/
│   │   │   │   ├── stitch_primary_button.dart
│   │   │   │   ├── stitch_secondary_button.dart
│   │   │   │   └── swipe_action_button.dart
│   │   │   ├── cards/
│   │   │   │   ├── stitch_surface_card.dart
│   │   │   │   └── metric_highlight_card.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirmation_dialog.dart
│   │   │   │   ├── reject_order_dialog.dart
│   │   │   │   └── error_dialog.dart
│   │   │   ├── inputs/
│   │   │   │   ├── stitch_text_field.dart
│   │   │   │   └── stitch_pin_code_field.dart
│   │   │   ├── feedback/
│   │   │   │   ├── custom_snackbar.dart
│   │   │   │   ├── offline_indicator_banner.dart
│   │   │   │   └── shimmer_loading.dart
│   │   │   └── modals/
│   │   │       ├── wolt_modal_sheet_wrapper.dart
│   │   │       └── draggable_delivery_sheet.dart
│   │   └── models/
│   │       ├── base_response_model.dart
│   │       └── pagination_model.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── auth_remote_datasource.dart
│       │   │   │   └── auth_local_datasource.dart
│       │   │   ├── models/
│       │   │   │   ├── user_model.dart
│       │   │   │   ├── token_model.dart
│       │   │   │   └── otp_response_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── user_entity.dart
│       │   │   │   └── session_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── send_otp_usecase.dart
│       │   │       ├── verify_otp_usecase.dart
│       │   │       └── logout_usecase.dart
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   ├── auth_bloc.dart
│       │       │   ├── auth_event.dart
│       │       │   └── auth_state.dart
│       │       └── screens/
│       │           ├── phone_login_screen.dart
│       │           ├── otp_verification_screen.dart
│       │           └── splash_screen.dart
│       │
│       ├── onboarding/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── kyc_cubit.dart
│       │       └── screens/
│       │           ├── profile_setup_screen.dart
│       │           ├── kyc_document_upload_screen.dart
│       │           ├── bank_details_screen.dart
│       │           ├── emergency_contact_screen.dart
│       │           └── onboarding_status_screen.dart
│       │
│       ├── dashboard/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   ├── duty_bloc.dart
│       │       │   └── dashboard_summary_cubit.dart
│       │       └── screens/
│       │           └── rider_dashboard_screen.dart
│       │
│       ├── order_dispatch/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   ├── order_offer_cubit.dart
│       │       │   └── order_lifecycle_bloc.dart
│       │       ├── screens/
│       │       │   ├── order_offer_overlay_modal.dart
│       │       │   ├── vendor_pickup_screen.dart
│       │       │   ├── navigation_active_screen.dart
│       │       │   └── delivery_confirmation_screen.dart
│       │       └── widgets/
│       │           ├── package_checklist_widget.dart
│       │           ├── countdown_timer_ring.dart
│       │           └── cod_amount_alert_card.dart
│       │
│       ├── earnings/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── earnings_bloc.dart
│       │       └── screens/
│       │           ├── earnings_overview_screen.dart
│       │           ├── weekly_breakdown_screen.dart
│       │           └── payout_history_screen.dart
│       │
│       ├── cod/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── cod_bloc.dart
│       │       └── screens/
│       │           ├── cod_management_screen.dart
│       │           └── cod_remittance_handover_screen.dart
│       │
│       ├── performance/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── performance_cubit.dart
│       │       └── screens/
│       │           └── performance_metrics_screen.dart
│       │
│       ├── safety/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── safety_bloc.dart
│       │       └── screens/
│       │           ├── sos_panic_screen.dart
│       │           ├── incident_reporting_screen.dart
│       │           └── insurance_card_screen.dart
│       │
│       ├── notifications/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── blocs/
│       │       │   └── notification_bloc.dart
│       │       └── screens/
│       │           └── notification_inbox_screen.dart
│       │
│       └── support/
│           ├── data/
│           ├── domain/
│           └── presentation/
│               ├── blocs/
│               │   └── support_ticket_bloc.dart
│               └── screens/
│                   ├── support_hub_screen.dart
│                   ├── create_ticket_screen.dart
│                   └── ticket_detail_screen.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   ├── golden/
│   └── integration/
├── pubspec.yaml
└── analysis_options.yaml
```

### 2.2 Detailed Explanation of Flutter Directories
* **`config/`**: Contains runtime environment bindings (`development`, `staging`, `production`), base URLs, and flag controls. No business logic permitted here.
* **`core/`**: Shared infrastructure code required across multiple feature domains:
  * `errors/`: Custom `Failure` and `Exception` classes matching Clean Architecture.
  * `network/`: Dio HTTP client wrappers, certificate pinning, token refresh handlers, and header injectors.
  * `storage/`: Abstract wrappers over `flutter_secure_storage` and `hive_flutter`.
  * `theme/`: Implementation of Google Stitch design system (emerald green, slate surfaces, Google Sans fonts).
  * `utils/`: Pure utility functions (distance haversine formula, currency formatting, geofencing).
* **`localization/`**: Multi-language support (`arb` files for English, Hindi, Kannada) compiled into type-safe Dart classes.
* **`routing/`**: GoRouter configuration with declarative routes, query parameter parsers, and authentication redirect guards.
* **`services/`**: Low-level hardware, OS, and platform communication services:
  * `background_geolocation_service.dart`: Keeps alive continuous 15s rider location streams in background tasks.
  * `mock_location_detector.dart`: Verifies hardware GPS authenticity to prevent location spoofing.
  * `fcm_service.dart`: Handles background and foreground push payloads with high priority notification channels.
  * `reverb_socket_service.dart`: Manages WebSocket connections to Laravel Reverb for real-time order offers.
* **`shared/`**: Common UI components that conform strictly to Google Stitch:
  * `swipe_action_button.dart`: Horizontal thumb-slide action for rider safety while driving.
  * `wolt_modal_sheet_wrapper.dart`: Multi-page dynamic bottom sheet modals.
* **`features/`**: Feature-first domain partitioning. Each feature module is self-contained with:
  * `data/`: DTOs, API deserialization models, local and remote data sources, repository implementations.
  * `domain/`: Business entities, repository contracts, and use cases (pure Dart, zero Flutter dependencies).
  * `presentation/`: BLoCs/Cubits, events, states, screens, and feature-specific widgets.

---

## 3. Laravel 11 Backend Structure

### 3.1 Complete Directory Layout
```
freska_backend/
├── app/
│   ├── Console/
│   │   └── Commands/
│   │       ├── AutoExpireOrderOffers.php
│   │       ├── CalculateDailyRiderMetrics.php
│   │       ├── ReconcileCodBalances.php
│   │       └── ProcessScheduledPayouts.php
│   │
│   ├── DTOs/
│   │   ├── Auth/
│   │   │   ├── SendOtpDTO.php
│   │   │   └── VerifyOtpDTO.php
│   │   ├── Order/
│   │   │   ├── AcceptOrderDTO.php
│   │   │   ├── ConfirmDeliveryDTO.php
│   │   │   └── RejectOrderDTO.php
│   │   ├── Rider/
│   │   │   ├── LocationHeartbeatDTO.php
│   │   │   ├── KycSubmissionDTO.php
│   │   │   └── BankDetailsDTO.php
│   │   └── Cod/
│   │       └── CodHandoverDTO.php
│   │
│   ├── Events/
│   │   ├── OrderOfferedToRider.php
│   │   ├── OrderStatusChanged.php
│   │   ├── RiderLocationUpdated.php
│   │   ├── CodCollected.php
│   │   └── SosIncidentTriggered.php
│   │
│   ├── Exceptions/
│   │   ├── Handler.php
│   │   ├── InvalidOrderStateException.php
│   │   ├── GeofenceValidationException.php
│   │   └── KycPendingException.php
│   │
│   ├── Helpers/
│   │   ├── GeoHelper.php
│   │   ├── CurrencyHelper.php
│   │   └── MaskingHelper.php
│   │
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── V1/
│   │   │           ├── Auth/
│   │   │           │   ├── AuthController.php
│   │   │           │   └── DeviceController.php
│   │   │           ├── Rider/
│   │   │           │   ├── ProfileController.php
│   │   │           │   ├── KycController.php
│   │   │           │   ├── DutyController.php
│   │   │           │   └── LocationController.php
│   │   │           ├── Order/
│   │   │           │   ├── OrderOfferController.php
│   │   │           │   └── OrderLifecycleController.php
│   │   │           ├── Finance/
│   │   │           │   ├── EarningsController.php
│   │   │           │   ├── CodController.php
│   │   │           │   └── PayoutController.php
│   │   │           ├── Safety/
│   │   │           │   ├── SosController.php
│   │   │           │   └── IncidentController.php
│   │   │           ├── Support/
│   │   │           │   └── SupportTicketController.php
│   │   │           ├── Notification/
│   │   │           │   └── NotificationController.php
│   │   │           └── Admin/
│   │   │               ├── DispatcherController.php
│   │   │               ├── RiderVerificationController.php
│   │   │               └── AnalyticsController.php
│   │   │
│   │   ├── Middleware/
│   │   │   ├── CheckRiderRole.php
│   │   │   ├── EnsureSingleActiveDevice.php
│   │   │   ├── EnsureKycApproved.php
│   │   │   ├── AuditLogMiddleware.php
│   │   │   └── MockLocationBlocker.php
│   │   │
│   │   ├── Requests/
│   │   │   └── V1/
│   │   │       ├── Auth/
│   │   │       │   ├── SendOtpRequest.php
│   │   │       │   └── VerifyOtpRequest.php
│   │   │       ├── Rider/
│   │   │       │   ├── SubmitKycRequest.php
│   │   │       │   ├── UpdateBankDetailsRequest.php
│   │   │       │   ├── LocationHeartbeatRequest.php
│   │   │       │   └── ToggleDutyRequest.php
│   │   │       ├── Order/
│   │   │       │   ├── AcceptOrderRequest.php
│   │   │       │   ├── RejectOrderRequest.php
│   │   │       │   ├── MarkPickupRequest.php
│   │   │       │   └── ConfirmDeliveryRequest.php
│   │   │       ├── Cod/
│   │   │       │   └── SubmitCodHandoverRequest.php
│   │   │       └── Safety/
│   │   │           ├── TriggerSosRequest.php
│   │   │           └── ReportIncidentRequest.php
│   │   │
│   │   └── Resources/
│   │       └── V1/
│   │           ├── UserResource.php
│   │           ├── RiderProfileResource.php
│   │           ├── OrderResource.php
│   │           ├── OrderOfferResource.php
│   │           ├── EarningsSummaryResource.php
│   │           ├── CodSummaryResource.php
│   │           ├── PerformanceResource.php
│   │           ├── NotificationResource.php
│   │           └── SupportTicketResource.php
│   │
│   ├── Interfaces/
│   │   ├── Repositories/
│   │   │   ├── UserRepositoryInterface.php
│   │   │   ├── RiderProfileRepositoryInterface.php
│   │   │   ├── OrderRepositoryInterface.php
│   │   │   ├── CodRepositoryInterface.php
│   │   │   ├── EarningsRepositoryInterface.php
│   │   │   └── AuditLogRepositoryInterface.php
│   │   └── Services/
│   │       ├── SmsServiceInterface.php
│   │       ├── GeolocationServiceInterface.php
│   │       ├── PushNotificationServiceInterface.php
│   │       └── StorageServiceInterface.php
│   │
│   ├── Jobs/
│   │   ├── BroadcastOrderOfferJob.php
│   │   ├── SendFcmPushNotificationJob.php
│   │   ├── SendEmergencySmsJob.php
│   │   ├── ProcessDeliveryAuditLogJob.php
│   │   ├── CalculateRiderDailyEarningsJob.php
│   │   └── ProcessKycDocumentOcrJob.php
│   │
│   ├── Listeners/
│   │   ├── PushOrderOfferToReverb.php
│   │   ├── NotifyCustomerOnStatusChange.php
│   │   ├── LogOrderStatusAuditTrail.php
│   │   ├── PostDeliveryEarningsToLedger.php
│   │   └── EscalateSosToOperationsDesk.php
│   │
│   ├── Models/
│   │   ├── User.php
│   │   ├── RiderProfile.php
│   │   ├── Vendor.php
│   │   ├── Order.php
│   │   ├── OrderAssignmentOffer.php
│   │   ├── CodCollection.php
│   │   ├── RiderEarning.php
│   │   ├── Payout.php
│   │   ├── SupportTicket.php
│   │   ├── IncidentAndSos.php
│   │   ├── AuditLog.php
│   │   ├── Notification.php
│   │   └── Device.php
│   │
│   ├── Notifications/
│   │   ├── NewOrderAssignedNotification.php
│   │   ├── PayoutProcessedNotification.php
│   │   └── KycStatusUpdatedNotification.php
│   │
│   ├── Policies/
│   │   ├── OrderPolicy.php
│   │   └── SupportTicketPolicy.php
│   │
│   ├── Repositories/
│   │   ├── Eloquent/
│   │   │   ├── BaseRepository.php
│   │   │   ├── UserRepository.php
│   │   │   ├── RiderProfileRepository.php
│   │   │   ├── OrderRepository.php
│   │   │   ├── CodRepository.php
│   │   │   ├── EarningsRepository.php
│   │   │   └── AuditLogRepository.php
│   │   └── Redis/
│   │       └── RedisRiderLocationRepository.php
│   │
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── OtpAuthService.php
│   │   │   └── DeviceSessionService.php
│   │   ├── Dispatch/
│   │   │   ├── RiderMatchingService.php
│   │   │   └── OfferBroadcastService.php
│   │   ├── Order/
│   │   │   ├── OrderLifecycleService.php
│   │   │   └── GeofenceService.php
│   │   ├── Finance/
│   │   │   ├── EarningsLedgerService.php
│   │   │   ├── CodReconciliationService.php
│   │   │   └── PayoutDisbursementService.php
│   │   ├── Safety/
│   │   │   └── EmergencySosService.php
│   │   └── ThirdParty/
│   │       ├── TwilioSmsService.php
│   │       ├── FirebaseNotificationService.php
│   │       ├── AwsS3StorageService.php
│   │       └── GoogleMapsRoutingService.php
│   │
│   └── Traits/
│       ├── ApiResponseTrait.php
│       ├── HasAuditLogs.php
│       └── ValidatesGeocoordinates.php
│
├── bootstrap/
│   ├── app.php
│   └── providers.php
├── config/
│   ├── auth.php
│   ├── broadcasting.php
│   ├── cors.php
│   ├── database.php
│   ├── filesystems.php
│   ├── horizon.php
│   ├── reverb.php
│   └── sanctum.php
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   ├── channels.php
│   └── console.php
├── tests/
│   ├── Feature/
│   └── Unit/
├── composer.json
└── phpstan.neon
```

### 3.2 Detailed Explanation of Laravel Directories
* **`DTOs/`**: Strongly-typed Data Transfer Objects carrying verified data between Controllers and Services. Prevents raw arrays from flowing through internal layers.
* **`Events/` & `Listeners/`**: Asynchronous, event-driven decoupling. When an order changes state (`OrderStatusChanged`), listeners trigger audit logs, Reverb WebSockets, SMS, and financial ledger writes independently without blocking HTTP execution.
* **`Http/Controllers/Api/V1/`**: Thin HTTP coordinators. They inject FormRequests, map requests to DTOs, invoke Domain Services, and return API Resources. No direct database queries or business algorithms permitted.
* **`Http/Middleware/`**: Security and policy gates:
  * `CheckRiderRole`: Rejects any user lacking the `rider` role.
  * `EnsureSingleActiveDevice`: Validates incoming `X-Device-Id` against the user's active session token, rejecting duplicate logins immediately.
  * `EnsureKycApproved`: Blocks offline/online toggle if `kyc_status != 'verified'`.
  * `MockLocationBlocker`: Validates mock GPS flags reported from device headers.
* **`Http/Requests/V1/`**: Strict FormRequest validation rules containing input constraints, regexes, and custom error messages.
* **`Http/Resources/V1/`**: JsonResource transformers ensuring consistent response envelopes, data masking, and removal of internal DB keys.
* **`Interfaces/`**: Contracts defining repositories and third-party services. Allows swapping implementations (e.g. Twilio $\rightarrow$ AWS SNS) without touching business logic.
* **`Jobs/`**: Serialized asynchronous tasks processed via Redis and Laravel Horizon (e.g., dispatch offer broadcasting, OCR processing, financial reconciliations).
* **`Repositories/Eloquent/`**: Encapsulates all database interactions, queries, eager loads, and transactions.
* **`Repositories/Redis/`**: High-speed memory storage managing spatial sets (`GEOADD`, `GEODIST`, `GEORADIUS`) for live fleet positioning.
* **`Services/`**: The core domain engine containing all business rules:
  * `OrderLifecycleService`: Validates state machine preconditions, verifies customer OTP, and coordinates ledger writes.
  * `RiderMatchingService`: Calculates closest available riders within a 5km radius based on Redis geo-queries.
  * `CodReconciliationService`: Enforces rider cash thresholds and remittance tracking.
* **`Traits/ApiResponseTrait.php`**: Standardizes all JSON responses across every controller to guarantee consistent schema structures.
