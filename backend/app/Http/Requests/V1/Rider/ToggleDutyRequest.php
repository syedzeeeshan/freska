<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class ToggleDutyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'is_online' => ['required', 'boolean'],
            'latitude' => ['required_if:is_online,true', 'nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['required_if:is_online,true', 'nullable', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'latitude.required_if' => 'Current GPS coordinates are mandatory before switching duty to Online.',
            'longitude.required_if' => 'Current GPS coordinates are mandatory before switching duty to Online.',
        ];
    }
}
