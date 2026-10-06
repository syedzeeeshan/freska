# Freska Delivery Partner Platform
# Module 06: Authentication & Enterprise Security Architecture

**Document ID**: `FRESKA-DOC-06`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Authentication Architecture (Part 7)

### 1.1 Secure Mobile OTP Authentication Pipeline
The Freska authentication engine avoids vulnerable passwords for riders, employing cryptographic time-bound OTPs via SMS and device binding:

```
+-------------------------------------------------------------------------------+
| OTP Authentication & Device Session Lifecycle                                 |
+-------------------------------------------------------------------------------+
| [ Mobile Client ]                                [ Laravel Sanctum / Redis ]  |
|         |                                                       |             |
|         |--- 1. POST /auth/otp/send (Phone + Device ID) ------->|             |
|         |                                                       |             |
|         |    (Rate check: 3 attempts/min in Redis)              |             |
|         |    (Generate 6-digit cryptographic random OTP)        |             |
|         |    (Store in Redis: otp:{phone} with 5-minute TTL)    |             |
|         |    (Dispatch SMS via Twilio / Exotel gateway)         |             |
|         |<-- 2. 200 OK (resend_in_seconds: 60) -----------------|             |
|         |                                                       |             |
|         |--- 3. POST /auth/otp/verify (Phone + OTP + Device) -->|             |
|         |                                                       |             |
|         |    (Verify OTP hash against Redis)                    |             |
|         |    (Revoke previous tokens for this device)           |             |
|         |    (Issue new Sanctum token: expires in 30 days)      |             |
|         |    (Store device fingerprint in `devices` table)      |             |
|         |<-- 4. 200 OK (Bearer Token + User Profile) -----------|             |
+-------------------------------------------------------------------------------+
```

### 1.2 Device Binding & Single-Active-Session Enforcement
To prevent fraudulent account sharing and concurrent duty logins:
1. Every login request requires a hardware-derived `device_id` (UUID generated on app first-launch and stored in Android Keystore / iOS Keychain).
2. The middleware `EnsureSingleActiveDevice` verifies every incoming API request:
```php
public function handle(Request $request, Closure $next): Response
{
    $deviceId = $request->header('X-Device-Id');
    $user = $request->user();

    if (!$deviceId) {
        return response()->json(['success' => false, 'message' => 'Missing Device ID'], 400);
    }

    $activeDevice = $user->devices()->where('is_active', true)->first();

    if ($activeDevice && $activeDevice->device_id !== $deviceId) {
        // Revoke current token and return session invalid
        $user->currentAccessToken()->delete();
        return response()->json([
            'success' => false,
            'message' => 'Session terminated: Logged in from another device.',
            'error_code' => 'ERR_DEVICE_MISMATCH'
        ], 401);
    }

    return $next($request);
}
```

### 1.3 Role-Based Access Control (RBAC) & Boundary Isolation
* Delivery riders are assigned exclusively the `rider` role.
* Routes under `/api/v1/admin/*` enforce the `CheckAdminRole` middleware (`dispatcher`, `operations_manager`, `super_admin`).
* Any token with `role === 'rider'` attempting to access admin endpoints is immediately rejected with HTTP 403 Forbidden and flagged in `audit_logs`.

### 1.4 Rate Limiting & Brute Force Defense
* **OTP Request**: Maximum 3 requests per phone number per 10 minutes (`throttle:3,10`).
* **OTP Verification**: Maximum 5 failed attempts per phone number per 15 minutes. Upon 5 failures, the phone number is locked out in Redis for 30 minutes to prevent brute-force permutation.
* **Global API**: 120 requests per minute per authenticated rider token.

---

## 2. Comprehensive Security Architecture (Part 8)

### 2.1 OWASP Top 10 Mitigation Matrix

| Threat | Vulnerability Description | Freska Defense Implementation |
| :--- | :--- | :--- |
| **A01: Broken Access Control** | Rider accessing other rider orders or admin routes. | Strict Laravel Policies (`OrderPolicy`), Sanctum scopes, and tenant boundary checks (`order->rider_id === user->id`). |
| **A02: Cryptographic Failures** | Data exposure in transit or rest. | Strict TLS 1.3 with certificate pinning on Flutter client; AES-256-GCM encryption for bank account numbers and KYC documents in S3. |
| **A03: Injection** | SQL / NoSQL / Command Injection. | Eloquent ORM parameterized PDO bindings; zero raw SQL queries with unescaped inputs; strict FormRequest regexes. |
| **A04: Insecure Design** | Rider spoofing GPS to accept distant orders. | Hardware mock location detection on Flutter (`isMockLocation`); speed and distance sanity checks on Laravel backend. |
| **A05: Security Misconfig** | Unnecessary HTTP methods, verbose errors. | Production environments disable debug mode (`APP_DEBUG=false`); custom Exception Handler maps internal errors to generic messages. |
| **A06: Vulnerable Components** | Outdated Composer or pub packages. | Automated GitHub Dependabot alerts and CI security scans with `composer audit` and `dart pub audit`. |
| **A07: Identification & Auth** | Credential stuffing & session hijacking. | Stateless Sanctum tokens bound to device UUID; instant remote session revocation on device change. |
| **A08: Software & Data Integrity** | Tampered APK / altered requests. | Mobile app signing with Google Play App Signing; HTTPS body integrity verification. |
| **A09: Logging & Monitoring Failures** | Undetected financial or order tampering. | Immutable `audit_logs` table tracking every state transition with geocoordinates, IP, and timestamp. |
| **A10: Server-Side Request Forgery** | Attacker manipulating backend network calls. | Strict whitelisting of outbound webhook URLs; disabled curl redirects in microservice HTTP clients. |

---

### 2.2 KYC Document Storage & Encryption-at-Rest
1. Driving licenses, vehicle registration cards, and identity documents are stored in a **Private AWS S3 Bucket** with all public access blocked (`BlockPublicAcls = true`).
2. Documents are uploaded using AWS KMS Server-Side Encryption (`SSE-KMS`).
3. Mobile app access to KYC documents occurs strictly through short-lived, pre-signed S3 URLs (TTL: 10 minutes) generated by `AwsS3StorageService`:
```php
public function getTemporaryDocumentUrl(string $path): string
{
    $client = $this->getS3Client();
    $command = $client->getCommand('GetObject', [
        'Bucket' => config('filesystems.disks.s3.bucket'),
        'Key' => $path,
    ]);

    $request = $client->createPresignedRequest($command, '+10 minutes');
    return (string) $request->getUri();
}
```

---

### 2.3 PII Protection & Customer Phone Masking
* Riders are legally restricted from harvesting customer personal data.
* **Phone Number Masking**: The Flutter client never receives raw customer phone numbers. Tapping "Call Customer" invokes a server-mediated proxy call via Twilio / Exotel Voice Proxy:
```
Rider Mobile -> Dials Virtual Proxy DID -> Twilio Bridges Call -> Customer Mobile
(Neither party's real phone number is revealed)
```
* **Address Obfuscation**: The customer's exact apartment/house number is masked with `[Protected]` until the rider successfully executes `markPickedUp()` within the store geofence.

---

### 2.4 Anti-GPS Spoofing & Geolocation Integrity
To eliminate fake-GPS spoofing apps:
1. **Client-Side Detection**: Flutter uses native Android `Location.isFromMockProvider()` and iOS `location.isSimulatedBySoftware` via `geolocator`:
```dart
bool isMock = position.isMocked;
if (isMock) {
  // Block action and send warning to backend
  throw MockLocationException();
}
```
2. **Server-Side Velocity Checks**: If a rider moves between consecutive pings at an impossible velocity ($> 120 \text{ km/h}$ for two-wheelers in urban traffic), the backend flags the account for review and rejects the geofence arrival event.
3. **Geofence Enforcement**: Actions like "Mark Arrived at Vendor" calculate the Haversine distance between rider coordinates and store coordinates; rejected with HTTP 422 if distance $> 200 \text{ meters}$.

---

### 2.5 Secrets & Environment Variable Management
* Zero credentials, API keys, or database passwords committed to version control (`.gitignore` enforces exclusions).
* Production environments inject secrets at runtime using **AWS Secrets Manager** or **Docker Secret Bindings**.
* In Flutter, Google Maps API keys for Android and iOS are restricted to package bundle identifiers (`com.freska.rider`) and SHA-256 fingerprint certificates in the Google Cloud Console.
