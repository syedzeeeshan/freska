<?php

declare(strict_types=1);

namespace App\Services\Auth;

use App\DTOs\Auth\SendOtpDTO;
use App\DTOs\Auth\VerifyOtpDTO;
use App\Interfaces\Repositories\UserRepositoryInterface;
use App\Interfaces\Services\SmsServiceInterface;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class OtpAuthService
{
    private const OTP_TTL_SECONDS = 300; // 5 minutes
    private const RESEND_COOLDOWN_SECONDS = 60; // 60 seconds
    private const MAX_VERIFY_ATTEMPTS = 5;

    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
        private readonly SmsServiceInterface $smsService,
        private readonly DeviceSessionService $deviceSessionService,
    ) {}

    /**
     * Generate and dispatch a 6-digit OTP via SMS.
     *
     * @return array{phone: string, resend_in_seconds: int}
     */
    public function sendOtp(SendOtpDTO $dto): array
    {
        $cooldownKey = "otp_cooldown:{$dto->phone}";
        if (Cache::has($cooldownKey)) {
            $ttl = (int) Cache::get($cooldownKey);
            throw ValidationException::withMessages([
                'phone' => ["Please wait {$ttl} seconds before requesting another verification code."]
            ]);
        }

        // Generate 6-digit cryptographically secure numeric OTP
        $otp = (string) random_int(100000, 999999);

        // Fixed demo code in local testing environment
        if (config('app.env') === 'local' && $dto->phone === '+919876543210') {
            $otp = '458921';
        }

        $otpKey = "otp_code:{$dto->phone}";
        $attemptsKey = "otp_attempts:{$dto->phone}";

        Cache::put($otpKey, $otp, self::OTP_TTL_SECONDS);
        Cache::put($attemptsKey, 0, self::OTP_TTL_SECONDS);
        Cache::put($cooldownKey, self::RESEND_COOLDOWN_SECONDS, self::RESEND_COOLDOWN_SECONDS);

        $message = "Your Freska Delivery verification code is: {$otp}. Valid for 5 minutes. Do not share this code.";
        $this->smsService->sendSms($dto->phone, $message);

        return [
            'phone' => $dto->phone,
            'resend_in_seconds' => self::RESEND_COOLDOWN_SECONDS,
        ];
    }

    /**
     * Verify OTP, bind hardware device, and issue Sanctum token.
     *
     * @return array{token: string, user: User}
     */
    public function verifyOtp(VerifyOtpDTO $dto): array
    {
        $otpKey = "otp_code:{$dto->phone}";
        $attemptsKey = "otp_attempts:{$dto->phone}";

        $attempts = (int) Cache::get($attemptsKey, 0);
        if ($attempts >= self::MAX_VERIFY_ATTEMPTS) {
            throw ValidationException::withMessages([
                'otp' => ['Maximum verification attempts exceeded. Please request a new OTP.']
            ]);
        }

        $cachedOtp = Cache::get($otpKey);

        if (!$cachedOtp || $cachedOtp !== $dto->otp) {
            Cache::increment($attemptsKey);
            throw ValidationException::withMessages([
                'otp' => ['The verification code entered is invalid or has expired.']
            ]);
        }

        // OTP is valid - consume it
        Cache::forget($otpKey);
        Cache::forget($attemptsKey);

        // Retrieve existing user or onboard new rider
        $user = $this->userRepository->findByPhone($dto->phone);

        if (!$user) {
            $user = $this->userRepository->createRider($dto->phone);
        }

        if ($user->phone_verified_at === null) {
            $this->userRepository->markPhoneVerified($user);
        }

        // Bind single device session
        $this->deviceSessionService->bindDeviceSession(
            user: $user,
            deviceId: $dto->deviceId,
            deviceModel: $dto->deviceModel,
            osVersion: $dto->osVersion,
            appVersion: $dto->appVersion,
            fcmToken: $dto->fcmToken,
        );

        // Issue Sanctum Personal Access Token
        $token = $user->createToken(
            name: "mobile_rider_{$dto->deviceId}",
            abilities: ['rider:access'],
            expiresAt: now()->addDays(30)
        )->plainTextToken;

        // Compliance audit log
        AuditLog::create([
            'user_id' => $user->id,
            'action' => 'AUTH_LOGIN_OTP_SUCCESS',
            'ip_address' => $dto->ipAddress,
            'user_agent' => $dto->userAgent,
            'metadata' => [
                'device_id' => $dto->deviceId,
                'device_model' => $dto->deviceModel,
            ],
        ]);

        return [
            'token' => $token,
            'user' => $user->load('riderProfile'),
        ];
    }
}
