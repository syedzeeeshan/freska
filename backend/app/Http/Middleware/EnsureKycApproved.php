<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Enums\KycStatus;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureKycApproved
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
                'error_code' => 'ERR_UNAUTHENTICATED'
            ], Response::HTTP_UNAUTHORIZED);
        }

        $profile = $user->riderProfile;

        if (!$profile || $profile->kyc_status !== KycStatus::VERIFIED) {
            return response()->json([
                'success' => false,
                'message' => 'Duty availability and order dispatch are blocked until your KYC documents are verified and approved by Freska operations.',
                'error_code' => 'ERR_KYC_NOT_VERIFIED',
                'current_kyc_status' => $profile?->kyc_status?->value ?? 'not_submitted',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
