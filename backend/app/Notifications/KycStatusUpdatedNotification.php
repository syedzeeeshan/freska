<?php

declare(strict_types=1);

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class KycStatusUpdatedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public readonly string $status,
        public readonly ?string $reason = null,
    ) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => 'KYC Status Update',
            'body' => $this->status === 'verified'
                ? 'Congratulations! Your KYC documents have been verified. You can now go online to receive orders.'
                : ($this->status === 'rejected'
                    ? "Your KYC documents were rejected: {$this->reason}"
                    : "Your KYC status is now {$this->status}."),
            'type' => 'security_alert',
            'status' => $this->status,
            'reason' => $this->reason,
        ];
    }
}
