<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

use Illuminate\Http\UploadedFile;

readonly class SubmitKycDTO
{
    public function __construct(
        public int $userId,
        public string $vehicleType,
        public string $vehicleNumber,
        public string $licenseNumber,
        public string $licenseExpiry,
        public UploadedFile $licenseFront,
        public UploadedFile $licenseBack,
        public UploadedFile $rcBook,
        public string $idProofType,
        public string $idProofNumber,
        public UploadedFile $idProofDocument,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            vehicleType: (string) $request->input('vehicle_type'),
            vehicleNumber: strtoupper(trim((string) $request->input('vehicle_number'))),
            licenseNumber: strtoupper(trim((string) $request->input('license_number'))),
            licenseExpiry: (string) $request->input('license_expiry'),
            licenseFront: $request->file('license_front'),
            licenseBack: $request->file('license_back'),
            rcBook: $request->file('rc_book'),
            idProofType: (string) $request->input('id_proof_type'),
            idProofNumber: strtoupper(trim((string) $request->input('id_proof_number'))),
            idProofDocument: $request->file('id_proof_document'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
