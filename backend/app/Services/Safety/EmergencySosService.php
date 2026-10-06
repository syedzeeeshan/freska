<?php

declare(strict_types=1);

namespace App\Services\Safety;

use App\DTOs\Safety\ReportIncidentDTO;
use App\DTOs\Safety\TriggerSosDTO;
use App\Enums\IncidentStatus;
use App\Enums\IncidentType;
use App\Interfaces\Repositories\IncidentRepositoryInterface;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Interfaces\Services\SmsServiceInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\IncidentAndSos;
use Illuminate\Support\Facades\DB;

class EmergencySosService
{
    public function __construct(
        private readonly IncidentRepositoryInterface $incidentRepository,
        private readonly RiderProfileRepositoryInterface $profileRepository,
        private readonly SmsServiceInterface $smsService,
        private readonly StorageServiceInterface $storageService,
    ) {}

    public function triggerSos(TriggerSosDTO $dto): IncidentAndSos
    {
        return DB::transaction(function () use ($dto) {
            $incident = $this->incidentRepository->createIncident([
                'rider_id' => $dto->riderId,
                'order_id' => $dto->orderId,
                'type' => IncidentType::SOS_PANIC,
                'latitude' => $dto->latitude,
                'longitude' => $dto->longitude,
                'location_address' => $dto->locationAddress,
                'medical_assistance_needed' => $dto->medicalAssistanceNeeded,
                'status' => IncidentStatus::TRIGGERED,
            ]);

            // Dispatch SMS alert to Next-of-Kin Emergency Contact
            $profile = $this->profileRepository->findByUserId($dto->riderId);
            if ($profile && $profile->emergency_contact_phone) {
                $riderName = $profile->user->name ?? 'Your family member (Freska Delivery Partner)';
                $mapsLink = "https://maps.google.com/?q={$dto->latitude},{$dto->longitude}";
                $smsText = "EMERGENCY ALERT: {$riderName} has triggered an SOS panic alert on duty at Freska. Location: {$mapsLink}. Emergency desk alerted.";

                $this->smsService->sendSms($profile->emergency_contact_phone, $smsText);
            }

            return $incident;
        });
    }

    public function reportIncident(ReportIncidentDTO $dto): IncidentAndSos
    {
        return DB::transaction(function () use ($dto) {
            $mediaUrls = [];
            foreach ($dto->photoFiles as $photo) {
                $mediaUrls[] = $this->storageService->uploadKycDocument(
                    $photo,
                    $dto->riderId,
                    'incident_' . time() . '_' . uniqid()
                );
            }

            return $this->incidentRepository->createIncident([
                'rider_id' => $dto->riderId,
                'order_id' => $dto->orderId,
                'type' => IncidentType::from($dto->type),
                'latitude' => $dto->latitude,
                'longitude' => $dto->longitude,
                'description' => $dto->description,
                'location_address' => $dto->locationAddress,
                'medical_assistance_needed' => $dto->medicalAssistanceNeeded,
                'media_urls' => $mediaUrls,
                'status' => IncidentStatus::TRIGGERED,
            ]);
        });
    }
}
