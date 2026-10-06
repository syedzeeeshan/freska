<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
                'error_code' => 'ERR_UNAUTHENTICATED'
            ], Response::HTTP_UNAUTHORIZED);
        }

        $userRole = $user->role->value ?? (string) $user->role;

        if (!in_array($userRole, $roles, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden: You do not have permission to access this resource.',
                'error_code' => 'ERR_ROLE_FORBIDDEN'
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
