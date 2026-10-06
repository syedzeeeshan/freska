<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

readonly class UpdateEmergencyContactDTO
{
    public function __construct(
        public int $userId,
        public string $contactName,
        public string $contactPhone,
        public string $contactRelation,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            contactName: trim((string) $request->input('emergency_contact_name')),
            contactPhone: trim((string) $request->input('emergency_contact_phone')),
            contactRelation: trim((string) $request->input('emergency_contact_relation')),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
