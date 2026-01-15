#!/bin/bash
#
# Test script that runs inside the Docker container
# Simulates a fresh user setting up Design Kit
#

set -e

echo "========================================"
echo "🧪 Design Kit Fresh Setup Test"
echo "========================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo "   Yarn: $(yarn --version)"
echo "   pnpm: $(pnpm --version)"
echo "   Git: $(git --version | cut -d' ' -f3)"
echo "   Composer: $(composer --version 2>/dev/null | head -1 | cut -d' ' -f3 || echo 'not installed')"

# Check Docker (should NOT be available in this container)
if command -v docker &> /dev/null; then
    echo "   Docker: $(docker --version | cut -d' ' -f3)"
else
    echo "   Docker: not installed (expected - testing no-Docker path)"
fi
echo ""

# Clone from the mounted repo
echo "📦 Cloning repository..."
if [ -d "/repo/.git" ]; then
    git clone /repo dk-test
else
    echo "❌ Error: No repository mounted at /repo"
    echo "   Run with: docker run --rm -v \"\$(pwd):/repo:ro\" dk-test"
    exit 1
fi
cd dk-test
echo "✅ Repository cloned"
echo ""

# Clone repositories using the repos script
echo "🔧 Cloning repositories..."
echo "   Note: CIAB is an internal Automattic repo and may not be accessible."
echo ""

./bin/repos.sh clone

echo ""
echo "🔧 Installing dependencies..."

# Calypso
if [ -d "repos/calypso" ]; then
    echo "   Installing Calypso dependencies..."
    cd repos/calypso
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    cd ../..
    echo "   ✅ Calypso dependencies installed"
fi

# Gutenberg  
if [ -d "repos/gutenberg" ]; then
    echo "   Installing Gutenberg dependencies..."
    cd repos/gutenberg
    npm ci 2>/dev/null || npm install
    cd ../..
    echo "   ✅ Gutenberg dependencies installed"
fi

# WordPress Core
if [ -d "repos/wordpress-core" ]; then
    echo "   Installing WordPress Core dependencies..."
    cd repos/wordpress-core
    npm ci 2>/dev/null || npm install
    cd ../..
    echo "   ✅ WordPress Core dependencies installed"
fi

# Jetpack
if [ -d "repos/jetpack" ]; then
    echo "   Installing Jetpack dependencies..."
    cd repos/jetpack
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    cd ../..
    echo "   ✅ Jetpack dependencies installed"
fi

# CIAB (skip if not available - check for package.json since git creates empty dirs)
if [ -f "repos/ciab/package.json" ]; then
    echo "   Installing CIAB dependencies..."
    cd repos/ciab
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    composer install 2>/dev/null || true
    cd ../..
    echo "   ✅ CIAB dependencies installed"
else
    echo "   ⏭️  Skipping CIAB (not available)"
fi

echo ""

# Verify setup
echo "🔍 Verifying setup..."
ERRORS=0

check_required() {
    if [ -d "$1" ]; then
        echo "   ✅ $2"
    else
        echo "   ❌ $2 - missing: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

check_optional() {
    if [ -d "$1" ]; then
        echo "   ✅ $2"
    else
        echo "   ⏭️  $2 (optional, skipped)"
    fi
}

# Required repos (public)
check_required "repos/calypso" "Calypso repository"
check_required "repos/calypso/node_modules" "Calypso dependencies"
check_required "repos/gutenberg" "Gutenberg repository"
check_required "repos/gutenberg/node_modules" "Gutenberg dependencies"
check_required "repos/wordpress-core" "WordPress Core repository"
check_required "repos/wordpress-core/node_modules" "WordPress Core dependencies"
check_required "repos/jetpack" "Jetpack repository"
check_required "repos/jetpack/node_modules" "Jetpack dependencies"

# Optional repos (internal) - check for package.json since git creates empty dirs
if [ -f "repos/ciab/package.json" ]; then
    check_optional "repos/ciab" "CIAB repository"
    check_optional "repos/ciab/node_modules" "CIAB dependencies"
else
    echo "   ⏭️  CIAB repository (optional, not cloned)"
    echo "   ⏭️  CIAB dependencies (optional, skipped)"
fi
echo ""

# Test start scripts (non-Docker repos only)
echo "🚀 Testing start scripts..."

# Test that help works
./bin/start.sh --help > /dev/null && echo "   ✅ start.sh --help works"

# Test Docker check for core (should fail gracefully)
echo "   Testing Docker check for 'core'..."
if ./bin/start.sh core 2>&1 | grep -q "Docker is not installed"; then
    echo "   ✅ Docker check works correctly (shows install instructions)"
else
    echo "   ❌ Docker check didn't trigger as expected"
    ERRORS=$((ERRORS + 1))
fi

# Test Docker check for ciab (only if ciab exists)
if [ -f "repos/ciab/package.json" ]; then
    echo "   Testing Docker check for 'ciab'..."
    if ./bin/start.sh ciab 2>&1 | grep -q "Docker is not installed"; then
        echo "   ✅ Docker check works correctly for CIAB"
    else
        echo "   ❌ Docker check didn't trigger as expected for CIAB"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ⏭️  Skipping CIAB Docker check (repo not available)"
fi
echo ""

# Summary
echo "========================================"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All tests passed!"
    echo "========================================"
    exit 0
else
    echo "❌ $ERRORS test(s) failed"
    echo "========================================"
    exit 1
fi
