# Freska Delivery Partner Platform
# Module 10: Coding Standards & Engineering Conventions

**Document ID**: `FRESKA-DOC-10`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Dart & Flutter Engineering Standards

### 1.1 Static Analysis Configuration (`analysis_options.yaml`)
Every developer environment must enforce `very_good_analysis` rules:
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
    invalid_annotation_target: ignore

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    use_build_context_synchronously: true
    always_declare_return_types: true
```

### 1.2 Immutability & Clean State Flow
1. All Entities, Value Objects, and BLoC States must be `@immutable` or defined using `@freezed`.
2. Avoid passing raw `BuildContext` across asynchronous boundaries without checking `if (!mounted) return;`.
3. Separate widget trees into small, dedicated private widgets instead of multi-hundred line monolithic `build()` methods.

---

## 2. PHP & Laravel Engineering Standards

### 2.1 Strict Types & PSR-12
Every single PHP file must start with `declare(strict_types=1);` without exception:
```php
<?php

declare(strict_types=1);

namespace App\Services\Finance;

final class EarningsCalculatorService
{
    public function calculateNetPayout(float $baseAmount, float $surge, float $tips): float
    {
        return $baseAmount + $surge + $tips;
    }
}
```

### 2.2 Eloquent Query & N+1 Prevention
1. Never query Eloquent models inside loops. Always eager load relationships using `with(['vendor', 'rider.riderProfile'])`.
2. Financial computations must occur within database transactions (`DB::transaction`) to guarantee ACID properties.
3. Repositories must return typed Collections or Models; never return untyped generic arrays to the service layer.

---

## 3. Git & Pull Request Guidelines

### 3.1 Conventional Commits
All commit messages must adhere to the Conventional Commits specification:
```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```
* **Types**:
  * `feat`: A new user-facing feature.
  * `fix`: A bug fix.
  * `refactor`: Code restructuring without functional change.
  * `perf`: Performance improvement.
  * `test`: Adding or correcting tests.
  * `chore`: Build tasks, package updates, CI/CD changes.
* **Examples**:
  * `feat(order): implement 30s countdown timer on assignment modal`
  * `fix(cod): prevent negative balance decrement in remittance service`

### 3.2 Code Review Pull Request Checklist
Before any PR can be merged into `develop` or `main`:
- [ ] Automated CI passes (Tests, Lint, PHPStan Level 8, Flutter Analyze).
- [ ] No hardcoded strings; all user text is in `app_en.arb` localization files.
- [ ] No raw database queries; repository interface used.
- [ ] Zero unmasked PII returned in API responses.
- [ ] Unit or feature test added covering the new functionality.
- [ ] 2 senior peer approvals obtained.
