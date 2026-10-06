<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\DTOs\Rider\SubmitKycDTO;
use App\Enums\KycStatus;
use App\Interfaces\Repositories\RiderProfileRepositoryInterface;
use App\Interfaces\Services\StorageServiceInterface;
use App\Models\RiderProfile;
use App\Services\Rider\KycService;
use Illuminate\Http\UploadedFile;
use Mockery;
use Tests\TestCase;

class KycServiceTest extends TestCase
{
    private RiderProfileRepositoryInterface $profileRepo;
    private StorageServiceInterface $storageService;
    private KycService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->profileRepo = Mockery::mock(RiderProfileRepositoryInterface::class);
        $this->storageService = Mockery::mock(StorageServiceInterface::class);

        $this->service = new KycService($this->profileRepo, $this->storageService);
    }

    public function test_get_kyc_status_returns_status_array(): void
    {
        $profile = new RiderProfile([
            'kyc_status' => KycStatus::SUBMITTED,
            'vehicle_number' => 'KA01AB1234',
            'license_number' => 'DL1420110012345',
        ]);

        $this->profileRepo->shouldReceive('findByUserId')
            ->once()
            ->with(14)
            ->andReturn($profile);

        $result = $this->service->getKycStatus(14);

        $this->assertEquals('submitted', $result['kyc_status']);
        $this->assertEquals('KA01AB1234', $result['vehicle_number']);
    }
}
