# Freska Delivery Partner Platform
# Module 08: CI/CD Automation & Production Deployment Architecture

**Document ID**: `FRESKA-DOC-08`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Git Branching Model & Workflow (GitHub Flow)

Freska adopts a streamlined **GitHub Flow** with environment protection gates:

```
feature/FSK-101-swipe-action  ---> Pull Request ---> develop (Auto-deploys to Staging)
                                                         |
                                                         v
                                                release/v1.0.0 (Tagging & QA)
                                                         |
                                                         v
                                                       main (Auto-deploys to Production)
```

1. **`main`**: Production-ready code. Protected branch requiring 2 peer approvals and passing CI pipeline.
2. **`develop`**: Integration branch for upcoming sprint releases. Deployed continuously to Staging.
3. **`feature/FSK-*`**: Ephemeral branches branched from `develop` for specific Jira/Linear user stories.
4. **`hotfix/FSK-*`**: Emergency branches branched directly from `main` to address critical production issues.

---

## 2. GitHub Actions CI/CD Pipelines

### 2.1 Laravel Backend Test & Deploy Workflow (`.github/workflows/laravel_ci_cd.yml`)
```yaml
name: Laravel Backend CI/CD

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  tests:
    name: Run Tests & Static Analysis
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: freska_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
      redis:
        image: redis:7.2-alpine
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, xml, ctype, iconv, intl, pdo_mysql, redis, bcmath, gd
          coverage: xdebug

      - name: Install Composer Dependencies
        run: composer install --prefer-dist --no-interaction --no-progress

      - name: Run PHPStan Static Analysis
        run: ./vendor/bin/phpstan analyse --memory-limit=2G

      - name: Execute Feature & Unit Tests
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: freska_test
          DB_USERNAME: root
          DB_PASSWORD: root
          REDIS_HOST: 127.0.0.1
        run: php artisan test --parallel

  deploy-staging:
    name: Deploy to Staging (AWS ECS)
    needs: tests
    if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1

      - name: Build & Push Docker Image
        run: |
          aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${{ secrets.ECR_REGISTRY }}
          docker build -t ${{ secrets.ECR_REGISTRY }}/freska-api:${{ github.sha }} -f docker/Dockerfile.prod .
          docker push ${{ secrets.ECR_REGISTRY }}/freska-api:${{ github.sha }}

      - name: Update ECS Service
        run: |
          aws ecs update-service --cluster freska-staging --service api-service --force-new-deployment
```

### 2.2 Flutter Mobile Build Pipeline (`.github/workflows/flutter_build.yml`)
```yaml
name: Flutter Mobile CI/CD

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  analyze_and_test:
    name: Lint & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.x'
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Verify Code Formatting & Lint
        run: |
          dart format --set-exit-if-changed .
          flutter analyze

      - name: Run Unit & Widget Tests
        run: flutter test --coverage

  build-android:
    name: Build Android App Bundle (.aab)
    needs: analyze_and_test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.x'

      - name: Decode Keystore
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

      - name: Build Production AAB
        env:
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: flutter build appbundle --flavor production -t lib/main_production.dart

      - name: Upload to Google Play Internal Track
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_JSON_KEY }}
          packageName: com.freska.rider
          releaseFiles: build/app/outputs/bundle/productionRelease/app-production-release.aab
          track: internal
```

---

## 3. Production Infrastructure Architecture

```
+-------------------------------------------------------------------------------+
| Production High-Availability Infrastructure (AWS Mumbai - ap-south-1)        |
+-------------------------------------------------------------------------------+
| [ AWS Route 53 / Cloudflare DNS ] (DDoS Shield, SSL/TLS Edge Termination)     |
|                                |                                              |
|                                v                                              |
| [ AWS Application Load Balancer (ALB) ]                                       |
|                                |                                              |
|            +-------------------+-------------------+                          |
|            |                                       |                          |
|            v                                       v                          |
| [ ECS Fargate API Service ]           [ ECS Fargate Reverb Service ]          |
| (Nginx 1.25 + PHP-FPM 8.3)             (WebSockets Server Port 8080)          |
|  • Min: 4 tasks, Max: 20 tasks         • Min: 2 tasks, Max: 6 tasks           |
|            |                                       |                          |
|            +-------------------+-------------------+                          |
|                                |                                              |
|                                v                                              |
| [ Internal VPC Subnets ]                                                      |
|   ├── AWS RDS MySQL 8.0 Multi-AZ (1 Primary Writer, 2 Read Replicas)          |
|   ├── AWS ElastiCache Redis 7.2 (Cluster Mode with Auto-Failover)             |
|   └── AWS S3 Bucket (SSE-KMS Private Document Store)                          |
+-------------------------------------------------------------------------------+
```

---

## 4. Production Daemon Management & Background Workers

### 4.1 Supervisor Worker Configuration (`/etc/supervisor/conf.d/freska-worker.conf`)
Ensures Laravel Horizon queue workers and Reverb WebSockets run continuously:

```ini
[program:freska-horizon]
process_name=%(program_name)s
command=php /var/www/freska/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/log/supervisor/freska-horizon.log
stopwaitsecs=3600

[program:freska-reverb]
process_name=%(program_name)s
command=php /var/www/freska/artisan reverb:start --host=0.0.0.0 --port=8080
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/log/supervisor/freska-reverb.log
```

### 4.2 Crontab Scheduled Tasks
```cron
* * * * * cd /var/www/freska && php artisan schedule:run >> /dev/null 2>&1
```

---

## 5. Rollback Strategy & Zero-Downtime Deployment
1. **Blue/Green Deployments via AWS ECS**: New container images are deployed to an alternate target group and pass health checks (`GET /api/health`) before live DNS/ALB traffic shifts.
2. **Database Migrations Backward Compatibility**: Schema changes follow the expand-contract pattern (e.g. adding new columns as nullable first). Destructive drops are never executed in live release migrations.
3. **Instant Reversion**: If application error rates exceed 1% on Sentry / CloudWatch within 5 minutes of release, the ALB immediately rolls back traffic to the previous stable task definition without downtime.
