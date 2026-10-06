<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Safety;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateSupportTicketRequest extends FormRequest
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
            'category' => ['required', Rule::in(['customer_issue', 'vendor_pickup_issue', 'payment_payout_issue', 'emergency_support', 'app_technical_issue', 'other'])],
            'subject' => ['required', 'string', 'max:200'],
            'description' => ['required', 'string', 'max:3000'],
            'priority' => ['nullable', Rule::in(['low', 'medium', 'high', 'critical'])],
            'order_id' => ['nullable', 'integer', 'exists:orders,id'],
            'attachment' => ['nullable', 'file', 'image', 'mimes:jpeg,png,webp', 'max:5120'],
        ];
    }
}
