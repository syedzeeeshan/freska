<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Order;

use Illuminate\Foundation\Http\FormRequest;

class PickupOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'package_verified' => ['required', 'boolean', 'accepted'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'package_verified.accepted' => 'You must verify the complete package checklist before pickup can be confirmed.',
        ];
    }
}
