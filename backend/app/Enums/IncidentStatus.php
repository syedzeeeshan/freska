<?php

declare(strict_types=1);

namespace App\Enums;

enum IncidentStatus: string
{
    case TRIGGERED = 'triggered';
    case ACKNOWLEDGED = 'acknowledged';
    case OPS_DISPATCHED = 'ops_dispatched';
    case RESOLVED = 'resolved';
    case FALSE_ALARM = 'false_alarm';
}
