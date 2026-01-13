#!/bin/bash
#
# Design Kit Setup Script
# Run this once after cloning to set up the full environment
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🎨 Design Kit Setup"
echo "==================="
echo ""

cd "$ROOT_DIR"

# Initialize and update submodules
echo "📦 Initializing submodules..."
git submodule update --init --depth 1

# Check if submodules exist
if [ ! -d "repos/calypso" ] || [ ! -d "repos/gutenberg" ] || [ ! -d "repos/wordpress-core" ] || [ ! -d "repos/ciab" ]; then
    echo "❌ Error: Submodules not found. Please check your git configuration."
    exit 1
fi

echo "✅ Submodules initialized"
echo ""

# Calypso setup
echo "📦 Setting up Calypso..."
cd "$ROOT_DIR/repos/calypso"
if command -v yarn &> /dev/null; then
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    echo "✅ Calypso dependencies installed"
else
    echo "⚠️  Yarn not found. Install yarn to set up Calypso: npm install -g yarn"
fi
cd "$ROOT_DIR"
echo ""

# Gutenberg setup
echo "📦 Setting up Gutenberg..."
cd "$ROOT_DIR/repos/gutenberg"
npm ci 2>/dev/null || npm install
echo "✅ Gutenberg dependencies installed"
cd "$ROOT_DIR"
echo ""

# WordPress Core setup
echo "📦 Setting up WordPress Core..."
cd "$ROOT_DIR/repos/wordpress-core"
npm ci 2>/dev/null || npm install
echo "✅ WordPress Core dependencies installed"
cd "$ROOT_DIR"
echo ""

# CIAB setup
echo "📦 Setting up CIAB..."
cd "$ROOT_DIR/repos/ciab"
if command -v pnpm &> /dev/null; then
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    echo "✅ CIAB dependencies installed"
    if command -v composer &> /dev/null; then
        composer install
        echo "✅ CIAB PHP dependencies installed"
    else
        echo "⚠️  Composer not found. Install composer to set up CIAB PHP dependencies"
    fi
else
    echo "⚠️  pnpm not found. Install pnpm to set up CIAB: npm install -g pnpm"
fi
cd "$ROOT_DIR"
echo ""

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  • Open in Cursor: cursor ."
echo "  • Start Calypso:  cd repos/calypso && yarn start"
echo "  • Start Gutenberg: cd repos/gutenberg && npm run dev"
echo "  • Start Storybook: cd repos/gutenberg && npm run storybook"
echo "  • Start WP Core:  cd repos/wordpress-core && npm run dev"
echo "  • Start CIAB:  cd repos/ciab && pnpm dev && pnpm env:start"
echo ""
