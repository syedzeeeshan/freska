<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Safety;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ReportIncidentRequest extends FormRequest
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
            'type' => ['required', Rule::in(['sos_panic', 'road_accident', 'vehicle_breakdown', 'customer_harassment', 'dog_bite', 'weather_hazard'])],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'description' => ['nullable', 'string', 'max:2000'],
            'order_id' => ['nullable', 'integer', 'exists:orders,id'],
            'location_address' => ['nullable', 'string', 'max:500'],
            'medical_assistance_needed' => ['nullable', 'boolean'],
            'photos' => ['nullable', 'array', 'max:5'],
            'photos.*' => ['file', 'image', 'mimes:jpeg,png,webp', 'max:5120'],
        ];
    }
}
