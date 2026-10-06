<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class UpdateEmergencyContactRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'emergency_contact_name' => ['required', 'string', 'max:120'],
            'emergency_contact_phone' => ['required', 'string', 'regex:/^\+[1-9]\d{1,14}$/'],
            'emergency_contact_relation' => ['required', 'string', 'max:50'],
        ];
    }

    public function messages(): array
    {
        return [
            'emergency_contact_phone.regex' => 'Emergency contact phone number must be in E.164 format (e.g. +919876543210).',
        ];
    }
}
