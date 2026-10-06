<?php

declare(strict_types=1);

namespace App\DTOs\Safety;

use App\Http\Requests\V1\Safety\TriggerSosRequest;

readonly class TriggerSosDTO
{
    public function __construct(
        public int $riderId,
        public float $latitude,
        public float $longitude,
        public ?int $orderId = null,
        public ?string $locationAddress = null,
        public bool $medicalAssistanceNeeded = false,
    ) {}

    public static function fromRequest(TriggerSosRequest $request): self
    {
        return new self(
            riderId: (int) $request->user()->id,
            latitude: (float) $request->validated('latitude'),
            longitude: (float) $request->validated('longitude'),
            orderId: $request->has('order_id') ? (int) $request->validated('order_id') : null,
            locationAddress: $request->validated('location_address'),
            medicalAssistanceNeeded: (bool) $request->validated('medical_assistance_needed', false),
        );
    }
}
