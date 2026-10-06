<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Finance;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SubmitCodHandoverRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:1'],
            'handover_method' => ['required', Rule::in(['hub_deposit', 'bank_cdm', 'upi_clawback'])],
            'handover_reference' => ['nullable', 'string', 'max:100'],
            'receipt_photo' => ['nullable', 'file', 'image', 'mimes:jpeg,png,webp', 'max:5120'],
            'order_id' => ['nullable', 'integer', 'exists:orders,id'],
        ];
    }
}
