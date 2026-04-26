FROM php:8.2-cli

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp/composer

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-install -j"$(nproc)" \
    dom \
    simplexml \
    soap \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /app
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Create a simple web root with index.php
RUN mkdir -p /app/public && \
    echo '<?php \
echo "<h1>NFe SPED Library</h1>"; \
echo "<p>Library loaded successfully!</p>"; \
echo "<pre>"; \
echo "PHP Version: " . phpversion() . "\n"; \
echo "NFePHP SPED-NFe installed\n"; \
require_once "/app/vendor/autoload.php"; \
echo "Autoloader loaded successfully\n"; \
echo "</pre>"; \
?>' > /app/public/index.php

# Run PHP built-in server on port 8080 serving from public directory
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app/public"]
