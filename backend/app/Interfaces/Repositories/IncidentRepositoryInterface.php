<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\IncidentAndSos;
use Illuminate\Support\Collection;

interface IncidentRepositoryInterface
{
    /**
     * @param array<string, mixed> $data
     */
    public function createIncident(array $data): IncidentAndSos;

    /**
     * @return Collection<int, IncidentAndSos>
     */
    public function getRiderIncidents(int $riderId): Collection;
}
