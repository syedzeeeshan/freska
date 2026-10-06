<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class ConfirmDeliveryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'otp' => ['required', 'string', 'size:4', 'regex:/^[0-9]{4}$/'],
            'proof_photo' => ['nullable', 'file', 'mimes:jpeg,png,jpg', 'max:5120'],
            'signature' => ['nullable', 'file', 'mimes:png', 'max:2048'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'otp.required' => 'A 4-digit customer OTP is required to confirm delivery.',
            'otp.size' => 'The OTP must be exactly 4 digits.',
            'otp.regex' => 'The OTP must contain only numeric digits.',
            'proof_photo.mimes' => 'Proof photo must be a JPEG or PNG image.',
            'proof_photo.max' => 'Proof photo may not exceed 5MB.',
        ];
    }
}
