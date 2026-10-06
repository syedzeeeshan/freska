<?php

declare(strict_types=1);

namespace App\DTOs\Safety;

use App\Http\Requests\V1\Safety\ReportIncidentRequest;

readonly class ReportIncidentDTO
{
    public function __construct(
        public int $riderId,
        public string $type,
        public float $latitude,
        public float $longitude,
        public ?string $description = null,
        public ?int $orderId = null,
        public ?string $locationAddress = null,
        public bool $medicalAssistanceNeeded = false,
        public array $photoFiles = [],
    ) {}

    public static function fromRequest(ReportIncidentRequest $request): self
    {
        return new self(
            riderId: (int) $request->user()->id,
            type: (string) $request->validated('type'),
            latitude: (float) $request->validated('latitude'),
            longitude: (float) $request->validated('longitude'),
            description: $request->validated('description'),
            orderId: $request->has('order_id') ? (int) $request->validated('order_id') : null,
            locationAddress: $request->validated('location_address'),
            medicalAssistanceNeeded: (bool) $request->validated('medical_assistance_needed', false),
            photoFiles: $request->file('photos', []),
        );
    }
}
