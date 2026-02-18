#!/bin/bash
# Setup script for WordPress ecosystem development environment

set -e  # Exit on error

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

echo "🚀 WordPress Ecosystem Setup"
echo "=============================="

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check nvm
if ! command -v nvm &> /dev/null; then
    echo "⚠️  nvm not found. Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source ~/.nvm/nvm.sh
    echo "✅ nvm installed"
else
    echo "✅ nvm found"
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker not found. Please install Docker Desktop."
    echo "   macOS/Windows: https://docker.com/products/docker-desktop"
    exit 1
else
    echo "✅ Docker found"
fi

# Install Node versions
echo "📦 Installing Node versions..."
source ~/.nvm/nvm.sh
nvm install 20 || echo "Node 20 already installed"
nvm install 22 || echo "Node 22 already installed"

# Install package managers
echo "📦 Installing package managers..."
nvm use 22
npm install -g pnpm yarn || true

echo "✅ Prerequisites ready"

# Clone repositories
echo "📥 Cloning repositories..."
mkdir -p repos
cd repos

repos=(
    "calypso:https://github.com/Automattic/wp-calypso.git:trunk"
    "gutenberg:https://github.com/WordPress/gutenberg.git:trunk"  
    "wordpress-core:https://github.com/WordPress/wordpress-develop.git:trunk"
    "jetpack:https://github.com/Automattic/jetpack.git:trunk"
)

for repo_info in "${repos[@]}"; do
    IFS=':' read -r name url branch <<< "$repo_info"
    
    if [ ! -d "$name" ]; then
        echo "Cloning $name..."
        git clone "$url" "$name"
        cd "$name"
        git checkout "$branch"
        cd ..
        echo "✅ $name cloned"
    else
        echo "✅ $name already exists"
    fi
done

cd "$DK_ROOT"

# Install dependencies
echo "📦 Installing dependencies..."

repos=("calypso" "gutenberg" "wordpress-core" "jetpack")

for repo in "${repos[@]}"; do
    if [ -d "repos/$repo" ]; then
        echo "Installing dependencies for $repo..."
        cd "repos/$repo"
        
        # Switch to correct Node version
        source ~/.nvm/nvm.sh
        if [ -f ".nvmrc" ]; then
            nvm use
        else
            case "$repo" in
                "calypso"|"jetpack") nvm use 22 ;;
                "gutenberg"|"wordpress-core") nvm use 20 ;;
            esac
        fi
        
        # Install dependencies
        case "$repo" in
            "calypso")
                yarn install
                ;;
            "gutenberg")
                npm ci
                npm run build
                ;;
            "wordpress-core")
                npm ci
                npm run build
                ;;
            "jetpack")
                pnpm install
                if command -v composer &> /dev/null; then
                    composer install
                fi
                pnpm jetpack build plugins/jetpack --deps
                ;;
        esac
        
        cd "$DK_ROOT"
        echo "✅ $repo dependencies installed"
    fi
done

# Setup Jetpack integration  
echo "🔧 Setting up Jetpack integration..."
mkdir -p repos/wordpress-core/src/wp-content/mu-plugins/

cat > repos/wordpress-core/src/wp-content/mu-plugins/jetpack-monorepo-fix.php << 'EOF'
<?php
/**
 * Jetpack Monorepo Development Fix
 * 
 * Fixes plugins_url() for Jetpack packages in monorepo development.
 */

add_filter( 'plugins_url', function( $url, $path, $plugin ) {
    if ( strpos( $plugin, 'jetpack' ) !== false ) {
        // Fix plugin URL for monorepo development
        $url = str_replace( '/plugins/jetpack/projects/plugins/', '/plugins/', $url );
    }
    return $url;
}, 10, 3 );
EOF

echo "✅ Jetpack integration configured"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Start development servers:"
echo "   ./skills/dev-servers/scripts/start.sh [calypso|gutenberg|core|jetpack]"
echo ""
echo "2. Check status:"
echo "   ./skills/setup/scripts/status.sh"
echo ""
echo "3. Repository management:"
echo "   ./skills/setup/scripts/repos.sh [clone|update|status]"
echo ""