<?php

declare(strict_types=1);

namespace App\DTOs\Auth;

readonly class SendOtpDTO
{
    public function __construct(
        public string $phone,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            phone: (string) $request->input('phone'),
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
