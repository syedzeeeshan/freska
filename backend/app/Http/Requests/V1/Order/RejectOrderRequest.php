<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class RejectOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'reason' => ['required', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'reason.required' => 'A rejection reason is required to re-route this delivery offer.',
        ];
    }
}
