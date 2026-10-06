<?php

declare(strict_types=1);

namespace App\Http\Resources\V1\Safety;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InsuranceCardResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'policy_number' => $this->insurance_policy_number ?? 'FSK-GRP-2026-0982',
            'provider' => $this->insurance_provider ?? 'ICICI Lombard General Insurance',
            'valid_until' => $this->insurance_valid_until?->format('Y-m-d') ?? now()->addMonths(9)->format('Y-m-d'),
            'coverage_amount' => '₹5,00,000 (Group Accidental & Medical)',
            'emergency_helpline' => '1800-2666 / 112',
            'document_url' => $this->insurance_document_url,
        ];
    }
}
