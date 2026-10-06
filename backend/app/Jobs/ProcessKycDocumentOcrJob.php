<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\RiderProfile;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessKycDocumentOcrJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public readonly RiderProfile $profile,
    ) {}

    public function handle(): void
    {
        Log::info("Processing background OCR validation for Rider #{$this->profile->user_id}", [
            'license_number' => $this->profile->license_number,
            'vehicle_number' => $this->profile->vehicle_number,
            'id_proof_type' => $this->profile->id_proof_type,
        ]);
    }
}
