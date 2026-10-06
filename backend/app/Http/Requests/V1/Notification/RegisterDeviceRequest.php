<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Notification;

use Illuminate\Foundation\Http\FormRequest;

class RegisterDeviceRequest extends FormRequest
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
            'device_id' => ['required', 'string', 'max:150'],
            'fcm_token' => ['nullable', 'string', 'max:500'],
            'device_model' => ['nullable', 'string', 'max:100'],
            'os_version' => ['nullable', 'string', 'max:50'],
            'app_version' => ['nullable', 'string', 'max:30'],
        ];
    }
}
