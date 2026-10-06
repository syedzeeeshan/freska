<?php

declare(strict_types=1);

namespace App\Providers;

use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Interfaces\Repositories\UserRepositoryInterface;
use App\Interfaces\Services\SmsServiceInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Repositories\Eloquent\OrderRepository;
use App\Repositories\Eloquent\RiderProfileRepository;
use App\Repositories\Eloquent\UserRepository;
use App\Services\Order\OrderLifecycleService;
use App\Services\ThirdParty\AwsS3StorageService;
use App\Services\ThirdParty\TwilioSmsService;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->bind(RiderProfileRepositoryInterface::class, RiderProfileRepository::class);
        $this->app->bind(OrderRepositoryInterface::class, OrderRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\DeviceRepositoryInterface::class, \App\Repositories\Eloquent\DeviceRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\CodRepositoryInterface::class, \App\Repositories\Eloquent\CodRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\EarningsRepositoryInterface::class, \App\Repositories\Eloquent\EarningsRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\IncidentRepositoryInterface::class, \App\Repositories\Eloquent\IncidentRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\SupportTicketRepositoryInterface::class, \App\Repositories\Eloquent\SupportTicketRepository::class);
        $this->app->bind(\App\Interfaces\Repositories\NotificationRepositoryInterface::class, \App\Repositories\Eloquent\NotificationRepository::class);
        $this->app->bind(SmsServiceInterface::class, TwilioSmsService::class);
        $this->app->bind(StorageServiceInterface::class, AwsS3StorageService::class);
        $this->app->singleton(OrderLifecycleService::class);
    }

    public function boot(): void
    {
        //
    }
}
