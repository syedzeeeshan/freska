<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Enums\KycStatus;
use App\Interfaces\Repositories\OrderRepositoryInterface;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Models\RiderProfile;
use App\Services\Dispatch\RiderMatchingService;
use Mockery;
use Tests\TestCase;

class RiderMatchingServiceTest extends TestCase
{
    private RiderProfileRepositoryInterface $profileRepo;
    private OrderRepositoryInterface $orderRepo;
    private RiderMatchingService $matchingService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->profileRepo = Mockery::mock(RiderProfileRepositoryInterface::class);
        $this->orderRepo = Mockery::mock(OrderRepositoryInterface::class);

        $this->matchingService = new RiderMatchingService(
            $this->orderRepo,
            $this->profileRepo,
        );
    }

    public function test_rider_is_ineligible_when_profile_not_found(): void
    {
        $this->profileRepo->shouldReceive('findByUserId')
            ->once()
            ->with(999)
            ->andReturn(null);

        $this->assertFalse($this->matchingService->isRiderEligibleForDispatch(999));
    }

    public function test_rider_is_ineligible_when_offline(): void
    {
        $profile = new RiderProfile([
            'is_online' => false,
            'kyc_status' => KycStatus::VERIFIED,
            'current_cash_in_hand' => 500.0,
            'max_cash_limit' => 5000.0,
        ]);

        $this->profileRepo->shouldReceive('findByUserId')
            ->once()
            ->with(1)
            ->andReturn($profile);

        $this->assertFalse($this->matchingService->isRiderEligibleForDispatch(1));
    }

    public function test_rider_is_ineligible_when_kyc_not_verified(): void
    {
        $profile = new RiderProfile([
            'is_online' => true,
            'kyc_status' => KycStatus::SUBMITTED,
            'current_cash_in_hand' => 500.0,
            'max_cash_limit' => 5000.0,
        ]);

        $this->profileRepo->shouldReceive('findByUserId')
            ->once()
            ->with(1)
            ->andReturn($profile);

        $this->assertFalse($this->matchingService->isRiderEligibleForDispatch(1));
    }

    public function test_rider_is_eligible_when_online_verified_and_within_cash_limit(): void
    {
        $profile = new RiderProfile([
            'is_online' => true,
            'kyc_status' => KycStatus::VERIFIED,
            'current_cash_in_hand' => 500.0,
            'max_cash_limit' => 5000.0,
        ]);

        $this->profileRepo->shouldReceive('findByUserId')
            ->once()
            ->with(1)
            ->andReturn($profile);

        $this->orderRepo->shouldReceive('getActiveOrderForRider')
            ->once()
            ->with(1)
            ->andReturn(null);

        $this->orderRepo->shouldReceive('getPendingOfferForRider')
            ->once()
            ->with(1)
            ->andReturn(null);

        $this->assertTrue($this->matchingService->isRiderEligibleForDispatch(1));
    }
}
