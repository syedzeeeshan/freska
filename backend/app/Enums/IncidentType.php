<?php

declare(strict_types=1);

namespace App\Enums;

enum IncidentType: string
{
    case SOS_PANIC = 'sos_panic';
    case ROAD_ACCIDENT = 'road_accident';
    case VEHICLE_BREAKDOWN = 'vehicle_breakdown';
    case CUSTOMER_HARASSMENT = 'customer_harassment';
    case DOG_BITE = 'dog_bite';
    case WEATHER_HAZARD = 'weather_hazard';
}
