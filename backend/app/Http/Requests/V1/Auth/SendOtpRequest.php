<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Auth;

use Illuminate\Foundation\Http\FormRequest;

class SendOtpRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'regex:/^\+[1-9]\d{1,14}$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.required' => 'A valid mobile phone number is required.',
            'phone.regex' => 'Phone number must be provided in international E.164 format (e.g. +919876543210).',
        ];
    }
}
