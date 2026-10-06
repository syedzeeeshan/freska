<?php

declare(strict_types=1);

namespace App\Traits;

use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

trait ApiResponseTrait
{
    /**
     * Standard success JSON response envelope.
     */
    protected function successResponse(
        mixed $data = null,
        string $message = 'Operation completed successfully.',
        int $statusCode = Response::HTTP_OK,
        array $meta = []
    ): JsonResponse {
        $response = [
            'success' => true,
            'message' => $message,
            'data' => $data,
            'meta' => array_merge([
                'timestamp' => now()->toIso8601String(),
                'version' => 'v1',
            ], $meta),
        ];

        return response()->json($response, $statusCode);
    }

    /**
     * Standard error JSON response envelope.
     */
    protected function errorResponse(
        string $message = 'An error occurred.',
        string $errorCode = 'ERR_SERVER_ERROR',
        array $errors = [],
        int $statusCode = Response::HTTP_BAD_REQUEST
    ): JsonResponse {
        $response = [
            'success' => false,
            'message' => $message,
            'error_code' => $errorCode,
            'errors' => $errors,
        ];

        return response()->json($response, $statusCode);
    }
}
