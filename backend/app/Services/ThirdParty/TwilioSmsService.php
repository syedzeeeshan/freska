<?php

declare(strict_types=1);

namespace App\Services\ThirdParty;

use App\Interfaces\Services\SmsServiceInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TwilioSmsService implements SmsServiceInterface
{
    public function __construct(
        private readonly ?string $sid = null,
        private readonly ?string $token = null,
        private readonly ?string $from = null,
    ) {}

    public function sendSms(string $phone, string $message): bool
    {
        $sid = $this->sid ?: config('services.twilio.sid');
        $token = $this->token ?: config('services.twilio.token');
        $from = $this->from ?: config('services.twilio.from');

        // Sandbox / Development fallback
        if (empty($sid) || empty($token) || config('app.env') === 'local') {
            Log::channel('single')->info("[SMS SANDBOX DISPATCH] To: {$phone} | Message: {$message}");
            return true;
        }

        try {
            $response = Http::withBasicAuth($sid, $token)
                ->asForm()
                ->post("https://api.twilio.com/2010-04-01/Accounts/{$sid}/Messages.json", [
                    'From' => $from,
                    'To' => $phone,
                    'Body' => $message,
                ]);

            if ($response->successful()) {
                return true;
            }

            Log::error('[TWILIO SMS FAILURE] Response: ' . $response->body());
            return false;
        } catch (\Throwable $e) {
            Log::error('[TWILIO SMS EXCEPTION] Error: ' . $e->getMessage());
            return false;
        }
    }
}
