<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBankDetailsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'bank_account_holder' => ['required', 'string', 'max:150'],
            'bank_name' => ['required', 'string', 'max:100'],
            'bank_account_number' => ['required', 'string', 'min:9', 'max:30'],
            'bank_ifsc_code' => ['required', 'string', 'regex:/^[A-Z]{4}0[A-Z0-9]{6}$/'],
            'bank_upi_id' => ['nullable', 'string', 'max:100'],
        ];
    }

    public function messages(): array
    {
        return [
            'bank_ifsc_code.regex' => 'Please provide a valid 11-character Indian Financial System Code (IFSC) (e.g. HDFC0001234).',
        ];
    }
}
