<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\DTOs\Auth\SendOtpDTO;
use App\Interfaces\Repositories\UserRepositoryInterface;
use App\Interfaces\Services\SmsServiceInterface;
use App\Services\Auth\DeviceSessionService;
use App\Services\Auth\OtpAuthService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;
use Mockery;
use Tests\TestCase;

class OtpAuthServiceTest extends TestCase
{
    private UserRepositoryInterface $userRepo;
    private SmsServiceInterface $smsService;
    private DeviceSessionService $deviceSessionService;
    private OtpAuthService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->userRepo = Mockery::mock(UserRepositoryInterface::class);
        $this->smsService = Mockery::mock(SmsServiceInterface::class);
        $this->deviceSessionService = Mockery::mock(DeviceSessionService::class);

        $this->service = new OtpAuthService(
            $this->userRepo,
            $this->smsService,
            $this->deviceSessionService
        );
    }

    public function test_send_otp_caches_code_and_calls_sms_service(): void
    {
        Cache::shouldReceive('has')->with('otp_cooldown:+919876543210')->andReturn(false);
        Cache::shouldReceive('put')->times(3);

        $this->smsService->shouldReceive('sendSms')
            ->once()
            ->with('+919876543210', Mockery::pattern('/Your Freska Delivery verification code is: \d{6}/'))
            ->andReturn(true);

        $dto = new SendOtpDTO('+919876543210', '127.0.0.1', 'Mozilla/5.0');
        $result = $this->service->sendOtp($dto);

        $this->assertEquals('+919876543210', $result['phone']);
        $this->assertEquals(60, $result['resend_in_seconds']);
    }

    public function test_send_otp_blocks_during_active_cooldown(): void
    {
        Cache::shouldReceive('has')->with('otp_cooldown:+919876543210')->andReturn(true);
        Cache::shouldReceive('get')->with('otp_cooldown:+919876543210')->andReturn(45);

        $this->expectException(ValidationException::class);

        $dto = new SendOtpDTO('+919876543210', '127.0.0.1', 'Mozilla/5.0');
        $this->service->sendOtp($dto);
    }
}
