<?php

declare(strict_types=1);

namespace App\Services\ThirdParty;

use App\Interfaces\Services\StorageServiceInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AwsS3StorageService implements StorageServiceInterface
{
    private string $disk;

    public function __construct()
    {
        $this->disk = config('filesystems.default', 'local');
    }

    public function uploadKycDocument(UploadedFile $file, int $userId, string $documentType): string
    {
        $extension = $file->getClientOriginalExtension() ?: 'jpg';
        $filename = "kyc/{$userId}/{$documentType}_" . Str::random(12) . ".{$extension}";

        Storage::disk($this->disk)->put($filename, file_get_contents($file->getRealPath()));

        return $filename;
    }

    public function uploadProfilePhoto(UploadedFile $file, int $userId): string
    {
        $extension = $file->getClientOriginalExtension() ?: 'jpg';
        $filename = "profiles/{$userId}/avatar_" . Str::random(8) . ".{$extension}";

        Storage::disk($this->disk)->put($filename, file_get_contents($file->getRealPath()));

        return $filename;
    }

    public function uploadProofOfDelivery(UploadedFile $file, int $orderId): string
    {
        $extension = $file->getClientOriginalExtension() ?: 'jpg';
        $filename = "pod/{$orderId}/proof_" . Str::random(8) . ".{$extension}";

        Storage::disk($this->disk)->put($filename, file_get_contents($file->getRealPath()));

        return $filename;
    }

    public function getPreSignedUrl(string $path, int $ttlMinutes = 15): string
    {
        if ($this->disk === 's3') {
            return Storage::disk('s3')->temporaryUrl($path, now()->addMinutes($ttlMinutes));
        }

        // Local storage URL fallback for development
        return Storage::disk($this->disk)->url($path);
    }
}
