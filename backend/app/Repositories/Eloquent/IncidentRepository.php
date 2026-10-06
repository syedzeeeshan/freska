<?php

declare(strict_types=1);

namespace App\Repositories\Eloquent;

use App\Interfaces\Repositories\IncidentRepositoryInterface;
use App\Models\AuditLog;
use App\Models\IncidentAndSos;
use Illuminate\Support\Collection;

class IncidentRepository implements IncidentRepositoryInterface
{
    public function createIncident(array $data): IncidentAndSos
    {
        $incidentNumber = 'INC-' . date('Y') . '-' . strtoupper(bin2hex(random_bytes(3)));

        $incident = IncidentAndSos::create(array_merge($data, [
            'incident_number' => $incidentNumber,
        ]));

        AuditLog::create([
            'user_id' => $incident->rider_id,
            'order_id' => $incident->order_id,
            'action' => 'INCIDENT_RECORDED',
            'latitude' => (float) $incident->latitude,
            'longitude' => (float) $incident->longitude,
            'metadata' => [
                'incident_number' => $incidentNumber,
                'type' => $incident->type->value,
                'medical_assistance' => $incident->medical_assistance_needed,
            ],
        ]);

        return $incident;
    }

    public function getRiderIncidents(int $riderId): Collection
    {
        return IncidentAndSos::query()
            ->where('rider_id', $riderId)
            ->orderByDesc('created_at')
            ->get();
    }
}
