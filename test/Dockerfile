# Design Kit Fresh Setup Test Container
#
# This creates a clean environment to test that setup works for new users.
# It includes all prerequisites except Docker (to test the "no Docker" path).
#
# Usage:
#   ./bin/test-fresh.sh
#
# Or manually:
#   docker build -t dk-test -f test/Dockerfile .
#   docker run --rm -v "$(pwd):/repo:ro" dk-test

FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    # Build tools for native npm packages
    build-essential \
    python3 \
    # PHP and Composer for CIAB
    php-cli \
    php-xml \
    php-mbstring \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install pnpm (yarn is already included in node:20-slim)
RUN npm install -g pnpm

# Create a non-root user to simulate a real designer
RUN useradd -m -s /bin/bash designer
USER designer
WORKDIR /home/designer

# Copy the test script
COPY --chown=designer:designer test/test-setup.sh /home/designer/
RUN chmod +x /home/designer/test-setup.sh

ENTRYPOINT ["/home/designer/test-setup.sh"]
