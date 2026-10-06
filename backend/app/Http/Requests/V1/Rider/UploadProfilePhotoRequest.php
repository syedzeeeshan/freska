<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class UploadProfilePhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'photo' => ['required', 'file', 'image', 'mimes:jpeg,png', 'max:5120'],
        ];
    }

    public function messages(): array
    {
        return [
            'photo.required' => 'A profile photo selfie is required.',
            'photo.image' => 'The file must be a valid image (JPEG or PNG).',
            'photo.max' => 'Profile photo must not exceed 5MB.',
        ];
    }
}
