# Freska Delivery Partner Platform
# Module 11: Google Stitch UI Guidelines & Flutter Package Manifest

**Document ID**: `FRESKA-DOC-11`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Google Stitch UI Design System

The Freska Delivery Partner App adheres to Google's **Stitch** design principles, emphasizing clarity under direct outdoor sunlight, high-contrast elevated cards, tactile touch targets, and fluid animated feedback.

### 1.1 Stitch Color Architecture
```
Primary Fresh:   #059669 (Light: #10B981) -> Brand Identity, Online Duty, Primary Actions
Background Base: #0F172A                  -> Dark Slate OLED Battery Saving Canvas
Card Surface:    #1E293B                  -> Elevated Card Fill (16dp Radius, 1dp Border #283548)
Surge / Gold:    #F59E0B                  -> Financials, Payouts, Streak Badges
Danger / SOS:    #EF4444                  -> Life Safety, Emergency Alerts, Declines
Text Primary:    #F8FAFC                  -> High Legibility Headings & Tabular Digits
Text Secondary:  #94A3B8                  -> Subtitles, Order Numbers, Timestamps
```

### 1.2 Typography & Tabular Figures
1. All monetary figures (`₹420.00`), countdown timers (`28s`), and distances (`4.8 km`) must enforce tabular numbers to prevent text vibration during real-time re-renders:
```dart
TextStyle(
  fontFamily: 'GoogleSans',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  fontFeatures: const [FontFeature.tabularFigures()],
)
```
2. Minimum touch target height for mobile controls is **54dp** (tested for usability when rider wears motorcycle gloves).

---

## 2. Required Flutter Packages Manifest (Part 9)

| Package Name | Purpose | Advantages | Configuration | Alternatives |
| :--- | :--- | :--- | :--- | :--- |
| `flutter_bloc` `^8.1.6` | Core State Management | Predictable event-driven state transitions; separates presentation from business logic; built-in testability. | Register via `BlocProvider` in feature widget subtrees. | `Riverpod`, `MobX` |
| `hydrated_bloc` `^9.1.5` | Automatic State Persistence | Caches bloc state across app restarts, ensuring offline persistence for active deliveries. | Initialize `HydratedBloc.storage` in `main.dart` using Hive storage. | Manual SQLite caching |
| `dio` `^5.7.0` | HTTP Client | Powerful interceptors for auth tokens, request logging, automatic retry with exponential backoff, and certificate pinning. | Configured in `ApiClient` with `AuthInterceptor` and `RetryInterceptor`. | `http`, `chopper` |
| `flutter_secure_storage` `^9.2.2` | Encrypted Token Storage | Stores Sanctum bearer tokens and hardware device IDs in Android Keystore / iOS Keychain. | Instantiate with `AndroidOptions(encryptedSharedPreferences: true)`. | `shared_preferences` |
| `hive_flutter` `^1.1.0` | Offline NoSQL Database | Fast key-value store; zero native dependencies; optimal for caching order checklists and offline queue. | `await Hive.initFlutter();` Register TypeAdapters during initialization. | `isar`, `sqflite` |
| `google_maps_flutter` `^2.9.0` | Live Route Map Tracking | Official Google Maps SDK integration with custom vector markers, traffic layers, and camera tracking. | Add Google Maps API Key to `AndroidManifest.xml` and `AppDelegate.swift`. | `flutter_map` (OSM), `mapbox_maps_flutter` |
| `geolocator` `^13.0.1` | Location & Spoof Detection | High-accuracy GPS positioning; exposes `position.isMocked` to detect fake GPS location apps. | Request `ACCESS_FINE_LOCATION` and `ACCESS_BACKGROUND_LOCATION`. | `location` |
| `firebase_messaging` `^15.1.3` | Push Notifications | Direct Google FCM integration for high-priority order dispatch alerts and background wake-up triggers. | Setup `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). | `onesignal_flutter` |
| `audioplayers` `^6.1.0` | Order Alert Chimes | Plays looping loud alert tones when new order assignments arrive. | Store MP3 in `assets/sounds/` and load via `AudioPlayer().play(AssetSource(...))`. | `just_audio` |
| `vibration` `^2.0.1` | Haptic Touch Alerts | Custom haptic pulse patterns on SOS button hold and swipe-to-accept triggers. | Call `Vibration.vibrate(pattern: [0, 500, 200, 500])`. | `haptic_feedback` |
| `fl_chart` `^0.69.0` | Earnings Visualizations | High-performance interactive charts for weekly earnings and daily delivery performance. | Use `BarChart` with custom Stitch theme gradients and tooltips. | `syncfusion_flutter_charts` |
| `wolt_modal_sheet` `^0.6.0` | Multi-Page Bottom Sheets | Dynamic bottom sheets supporting smooth pagination from order details $\rightarrow$ checklist $\rightarrow$ swipe actions. | Wrap modals using `WoltModalSheet.show`. | Standard `showModalBottomSheet` |
| `pin_code_fields` `^8.0.1` | 6-Digit OTP Input | Custom animated PIN boxes with auto-focus and clipboard paste for SMS OTPs. | Configure `PinTheme` with Stitch emerald borders and dark surface fill. | `pinput` |
| `signature` `^5.5.0` | Digital Signature Pad | Captures customer signature on delivery confirmation; exports PNG for S3 upload. | Bind to `SignatureController(penStrokeWidth: 3, penColor: Colors.white)`. | Custom `CustomPainter` |
