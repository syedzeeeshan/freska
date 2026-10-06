<?php

declare(strict_types=1);

namespace App\Interfaces\Services;

interface SmsServiceInterface
{
    /**
     * Dispatch an SMS message to a phone number.
     *
     * @param string $phone International E.164 phone number.
     * @param string $message Text content.
     * @return bool True if successfully dispatched to provider gateway.
     */
    public function sendSms(string $phone, string $message): bool;
}
