<?php

declare(strict_types=1);

namespace App\Http\Requests\V1\Rider;

use Illuminate\Foundation\Http\FormRequest;

class SubmitKycRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role?->value === 'rider' || $this->user()?->role === 'rider';
    }

    public function rules(): array
    {
        return [
            'vehicle_type' => ['required', 'string', 'in:bike,scooter,ev_two_wheeler,bicycle'],
            'vehicle_number' => ['required', 'string', 'max:30'],
            'license_number' => ['required', 'string', 'max:50'],
            'license_expiry' => ['required', 'date', 'after:today'],
            'license_front' => ['required', 'file', 'image', 'mimes:jpeg,png', 'max:5120'],
            'license_back' => ['required', 'file', 'image', 'mimes:jpeg,png', 'max:5120'],
            'rc_book' => ['required', 'file', 'mimes:jpeg,png,pdf', 'max:5120'],
            'id_proof_type' => ['required', 'string', 'in:aadhaar,pan,passport,voter_id'],
            'id_proof_number' => ['required', 'string', 'max:50'],
            'id_proof_document' => ['required', 'file', 'mimes:jpeg,png,pdf', 'max:5120'],
        ];
    }

    public function messages(): array
    {
        return [
            'license_expiry.after' => 'The driving license must not be expired.',
            'license_front.max' => 'The driving license front photo must not exceed 5MB.',
            'license_back.max' => 'The driving license rear photo must not exceed 5MB.',
            'rc_book.max' => 'The RC book document must not exceed 5MB.',
            'id_proof_document.max' => 'The identity proof document must not exceed 5MB.',
        ];
    }
}
