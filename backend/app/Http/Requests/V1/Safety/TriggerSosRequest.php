<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Safety;

use Illuminate\Foundation\Http\FormRequest;

class TriggerSosRequest extends FormRequest
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
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'order_id' => ['nullable', 'integer', 'exists:orders,id'],
            'location_address' => ['nullable', 'string', 'max:500'],
            'medical_assistance_needed' => ['nullable', 'boolean'],
        ];
    }
}
