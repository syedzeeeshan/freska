<?php

declare(strict_types=1);

namespace App\Interfaces\Services;

use Illuminate\Http\UploadedFile;

interface StorageServiceInterface
{
    /**
     * Store a KYC verification document in secure storage.
     */
    public function uploadKycDocument(UploadedFile $file, int $userId, string $documentType): string;

    /**
     * Store a rider profile selfie.
     */
    public function uploadProfilePhoto(UploadedFile $file, int $userId): string;

    /**
     * Store proof of delivery photo or signature.
     */
    public function uploadProofOfDelivery(UploadedFile $file, int $orderId): string;

    /**
     * Generate a secure, time-bound pre-signed URL for document access.
     */
    public function getPreSignedUrl(string $path, int $ttlMinutes = 15): string;
}
