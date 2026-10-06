<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

use Illuminate\Http\UploadedFile;

readonly class UploadProfilePhotoDTO
{
    public function __construct(
        public int $userId,
        public UploadedFile $photo,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            photo: $request->file('photo'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
