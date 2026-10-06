<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\AuditLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuditActionMiddleware
{
    public function handle(Request $request, Closure $next, string $action = 'API_REQUEST'): Response
    {
        $response = $next($request);

        // Only log successful operations
        if ($response->isSuccessful() && $request->user()) {
            AuditLog::create([
                'user_id' => $request->user()->id,
                'action' => $action,
                'latitude' => $request->input('latitude'),
                'longitude' => $request->input('longitude'),
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'metadata' => [
                    'path' => $request->path(),
                    'method' => $request->method(),
                    'status_code' => $response->getStatusCode(),
                ],
            ]);
        }

        return $response;
    }
}
