# Freska Delivery Partner Platform
# Module 09: DevOps, Containerization & Infrastructure-as-Code

**Document ID**: `FRESKA-DOC-09`  
**Classification**: Engineering Specification  
**Version**: 1.0.0 (Production-Ready)  

---

## 1. Production Dockerfiles

### 1.1 Laravel 11 Backend Dockerfile (`docker/Dockerfile.prod`)
Multi-stage build compiling PHP 8.3 FPM with optimized OPcache and production extensions:

```dockerfile
# Stage 1: Build Dependencies via Composer
FROM composer:2.7 AS composer_build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY . .
RUN composer dump-autoload --optimize --no-dev

# Stage 2: Production Runtime Environment
FROM php:8.3-fpm-alpine

# Install System Dependencies & PHP Extensions
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        bcmath \
        gd \
        zip \
        intl \
        mbstring \
        opcache \
        pcntl

# Install Redis PHP Extension
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Configure OPcache for Maximum Performance
RUN { \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.revalidate_freq=0'; \
    echo 'opcache.validate_timestamps=0'; \
    echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html

# Copy Project Files from Builder Stage
COPY --from=composer_build --chown=www-data:www-data /app /var/www/html

# Copy Server Configurations
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

EXPOSE 80 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

### 1.2 Flutter Web & Test Runner Dockerfile (`docker/Dockerfile.flutter`)
```dockerfile
FROM ghcr.io/cirruslabs/flutter:3.24.0

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter analyze
RUN flutter test
```

---

## 2. Server Configuration Files

### 2.1 Nginx Reverse Proxy Configuration (`docker/nginx.conf`)
```nginx
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 2048;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 20M;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    server {
        listen 80;
        server_name _;
        root /var/www/html/public;
        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        # WebSocket Reverse Proxy for Laravel Reverb
        location /app {
            proxy_pass http://127.0.0.1:8080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_buffer_size 128k;
            fastcgi_buffers 4 256k;
            fastcgi_busy_buffers_size 256k;
        }

        location ~ /\.(?!well-known).* {
            deny all;
        }
    }
}
```

---

## 3. Local Development `docker-compose.yml`

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile.dev
    container_name: freska_api
    restart: unless-stopped
    ports:
      - "8000:80"
      - "8080:8080" # Reverb WebSockets
    volumes:
      - .:/var/www/html
    environment:
      - APP_ENV=local
      - APP_DEBUG=true
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_DATABASE=freska
      - DB_USERNAME=freska_user
      - DB_PASSWORD=freska_secret
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - freska_network

  mysql:
    image: mysql:8.0
    container_name: freska_mysql
    restart: unless-stopped
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: freska
      MYSQL_USER: freska_user
      MYSQL_PASSWORD: freska_secret
      MYSQL_ROOT_PASSWORD: root_secret
    volumes:
      - freska_mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - freska_network

  redis:
    image: redis:7.2-alpine
    container_name: freska_redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass redis_secret
    ports:
      - "6379:6379"
    volumes:
      - freska_redis_data:/data
    networks:
      - freska_network

  mailpit:
    image: axllent/mailpit:latest
    container_name: freska_mailpit
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - freska_network

networks:
  freska_network:
    driver: bridge

volumes:
  freska_mysql_data:
  freska_redis_data:
```

---

## 4. Production `.env.example` Master Template

```ini
APP_NAME=Freska
APP_ENV=production
APP_KEY=base64:YOUR_32_CHAR_GENERATED_KEY_HERE
APP_DEBUG=false
APP_URL=https://api.freska.app

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=freska-cluster.cluster-xyz.ap-south-1.rds.amazonaws.com
DB_PORT=3306
DB_DATABASE=freska_prod
DB_USERNAME=freska_admin
DB_PASSWORD=REPLACE_WITH_KMS_ROTATED_SECRET

BROADCAST_CONNECTION=reverb
FILESYSTEM_DISK=s3
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
CACHE_STORE=redis

REDIS_CLIENT=predis
REDIS_HOST=freska-redis.xyz.cache.amazonaws.com
REDIS_PASSWORD=REPLACE_WITH_REDIS_AUTH_STRING
REDIS_PORT=6379

REVERB_APP_ID=freska_reverb
REVERB_APP_KEY=freska_reverb_key_xyz
REVERB_APP_SECRET=freska_reverb_secret_abc
REVERB_HOST=api.freska.app
REVERB_PORT=443
REVERB_SCHEME=https

AWS_ACCESS_KEY_ID=AKIA_REPLACE_WITH_IAM_KEY
AWS_SECRET_ACCESS_KEY=REPLACE_WITH_IAM_SECRET
AWS_DEFAULT_REGION=ap-south-1
AWS_BUCKET=freska-documents-prod
AWS_USE_PATH_STYLE_ENDPOINT=false

TWILIO_SID=AC_REPLACE_WITH_TWILIO_SID
TWILIO_AUTH_TOKEN=REPLACE_WITH_TWILIO_AUTH_TOKEN
TWILIO_PHONE_NUMBER=+1234567890

FIREBASE_CREDENTIALS=/var/www/html/storage/app/firebase_credentials.json

SANCTUM_EXPIRATION=43200
```
