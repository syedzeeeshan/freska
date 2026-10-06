<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Auth;

use Illuminate\Foundation\Http\FormRequest;

class VerifyOtpRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'regex:/^\+[1-9]\d{1,14}$/'],
            'otp' => ['required', 'string', 'digits:6'],
            'device_id' => ['required', 'string', 'max:150'],
            'device_model' => ['nullable', 'string', 'max:100'],
            'os_version' => ['nullable', 'string', 'max:50'],
            'app_version' => ['nullable', 'string', 'max:30'],
            'fcm_token' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.required' => 'A valid mobile phone number is required.',
            'otp.required' => 'The 6-digit verification code is required.',
            'otp.digits' => 'Verification code must be exactly 6 digits.',
            'device_id.required' => 'Device hardware identifier is required for session security.',
        ];
    }
}
