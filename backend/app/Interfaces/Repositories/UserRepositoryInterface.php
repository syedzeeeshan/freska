<?php

declare(strict_types=1);

namespace App\Interfaces\Repositories;

use App\Models\User;

interface UserRepositoryInterface
{
    public function findById(int $id): ?User;

    public function findByPhone(string $phone): ?User;

    public function createRider(string $phone): User;

    public function markPhoneVerified(User $user): bool;

    public function updateProfile(User $user, array $attributes): bool;
}
