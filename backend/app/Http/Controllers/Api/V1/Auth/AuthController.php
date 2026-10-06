<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Auth;

use App\DTOs\Auth\SendOtpDTO;
use App\DTOs\Auth\VerifyOtpDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Auth\SendOtpRequest;
use App\Http\Requests\V1\Auth\VerifyOtpRequest;
use App\Http\Resources\V1\UserResource;
use App\Services\Auth\OtpAuthService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly OtpAuthService $otpAuthService,
    ) {}

    /**
     * Send mobile verification OTP.
     */
    public function sendOtp(SendOtpRequest $request): JsonResponse
    {
        $dto = SendOtpDTO::fromRequest($request);
        $result = $this->otpAuthService->sendOtp($dto);

        return $this->successResponse(
            data: $result,
            message: 'OTP sent successfully.'
        );
    }

    /**
     * Verify mobile OTP, bind device session, and return access token.
     */
    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $dto = VerifyOtpDTO::fromRequest($request);
        $result = $this->otpAuthService->verifyOtp($dto);

        return $this->successResponse(
            data: [
                'token' => $result['token'],
                'user' => new UserResource($result['user']),
            ],
            message: 'Authentication successful.'
        );
    }

    /**
     * Terminate active authenticated session.
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        $deviceId = $request->header('X-Device-Id');

        if ($deviceId) {
            $user->devices()->where('device_id', $deviceId)->update(['is_active' => false]);
        }

        $user->currentAccessToken()?->delete();

        return $this->successResponse(
            message: 'Logged out successfully.'
        );
    }

    /**
     * Return authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        return $this->successResponse(
            data: new UserResource($request->user()->load('riderProfile'))
        );
    }
}
