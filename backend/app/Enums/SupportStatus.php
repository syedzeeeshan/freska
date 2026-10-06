<?php

declare(strict_types=1);

namespace App\Enums;

enum SupportStatus: string
{
    case OPEN = 'open';
    case IN_PROGRESS = 'in_progress';
    case RESOLVED = 'resolved';
    case CLOSED = 'closed';
}
