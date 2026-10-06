<?php

declare(strict_types=1);

namespace App\DTOs\Rider;

readonly class UpdateBankDetailsDTO
{
    public function __construct(
        public int $userId,
        public string $bankAccountHolder,
        public string $bankName,
        public string $bankAccountNumber,
        public string $bankIfscCode,
        public ?string $bankUpiId,
        public string $ipAddress,
        public string $userAgent,
    ) {}

    public static function fromRequest(\Illuminate\Http\Request $request): self
    {
        return new self(
            userId: (int) $request->user()->id,
            bankAccountHolder: trim((string) $request->input('bank_account_holder')),
            bankName: trim((string) $request->input('bank_name')),
            bankAccountNumber: trim((string) $request->input('bank_account_number')),
            bankIfscCode: strtoupper(trim((string) $request->input('bank_ifsc_code'))),
            bankUpiId: $request->input('bank_upi_id') ? trim((string) $request->input('bank_upi_id')) : null,
            ipAddress: (string) $request->ip(),
            userAgent: (string) $request->userAgent(),
        );
    }
}
