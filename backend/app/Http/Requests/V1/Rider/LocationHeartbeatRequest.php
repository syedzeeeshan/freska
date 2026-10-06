<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class LocationHeartbeatRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'heading' => ['nullable', 'numeric', 'between:0,360'],
            'speed' => ['nullable', 'numeric', 'min:0'],
            'battery_percentage' => ['nullable', 'integer', 'between:0,100'],
            'is_mock' => ['required', 'boolean'],
        ];
    }
}
