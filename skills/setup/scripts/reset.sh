#!/bin/bash
# Reset and update development environment

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

echo "🔄 Resetting WordPress Development Environment"
echo "==============================================" 

# Parse options
FULL_RESET=false
if [ "$1" = "--full" ]; then
    FULL_RESET=true
    echo "🗑️  Full reset mode: Will reinstall all dependencies"
fi

repos=("calypso" "gutenberg" "wordpress-core" "jetpack" "ciab" "telex")

for repo in "${repos[@]}"; do
    if [ -d "repos/$repo" ]; then
        echo ""
        echo "=== Resetting $repo ==="
        cd "repos/$repo"
        
        # Stash any uncommitted changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo "💾 Stashing uncommitted changes..."
            git stash push -m "Auto-stash before reset $(date)"
        fi
        
        # Pull latest changes
        echo "📥 Pulling latest changes..."
        git pull || echo "⚠️  Pull failed - check connectivity"
        
        # Switch to correct Node version
        source ~/.nvm/nvm.sh 2>/dev/null || true
        
        if [ -f ".nvmrc" ]; then
            echo "🔧 Switching to Node version from .nvmrc..."
            nvm use 2>/dev/null || echo "⚠️  Could not switch Node version"
        else
            case "$repo" in
                "calypso"|"jetpack"|"ciab"|"telex")
                    echo "🔧 Switching to Node 22..."
                    nvm use 22 2>/dev/null || echo "⚠️  Node 22 not available"
                    ;;
                "gutenberg"|"wordpress-core")
                    echo "🔧 Switching to Node 20..."
                    nvm use 20 2>/dev/null || echo "⚠️  Node 20 not available"
                    ;;
            esac
        fi
        
        # Clean and reinstall dependencies
        case "$repo" in
            "calypso")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning yarn cache and node_modules..."
                    yarn cache clean 2>/dev/null || true
                    rm -rf node_modules
                fi
                echo "📦 Installing dependencies with yarn..."
                yarn install
                ;;
                
            "gutenberg")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning npm cache and node_modules..."
                    npm cache clean --force 2>/dev/null || true
                    rm -rf node_modules
                fi
                echo "📦 Installing dependencies with npm..."
                npm ci
                echo "🔨 Building Gutenberg..."
                npm run build
                ;;
                
            "wordpress-core")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning npm cache and node_modules..."
                    npm cache clean --force 2>/dev/null || true
                    rm -rf node_modules
                fi
                echo "📦 Installing dependencies with npm..."
                npm ci
                echo "🔨 Building WordPress Core..."
                npm run build
                ;;
                
            "jetpack")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning pnpm cache and dependencies..."
                    pnpm store prune 2>/dev/null || true
                    rm -rf node_modules
                    rm -rf vendor
                fi
                echo "📦 Installing JS dependencies with pnpm..."
                pnpm install
                
                if command -v composer &> /dev/null; then
                    echo "📦 Installing PHP dependencies with composer..."
                    composer install
                else
                    echo "⚠️  Composer not found - skipping PHP dependencies"
                fi
                
                echo "🔨 Building Jetpack..."
                pnpm jetpack build plugins/jetpack --deps
                ;;
                
            "ciab")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning pnpm cache and dependencies..."
                    pnpm store prune 2>/dev/null || true
                    rm -rf node_modules
                    rm -rf vendor
                fi
                echo "📦 Installing JS dependencies with pnpm..."
                pnpm install
                
                if command -v composer &> /dev/null; then
                    echo "📦 Installing PHP dependencies with composer..."
                    composer install
                else
                    echo "⚠️  Composer not found - skipping PHP dependencies"
                fi
                
                echo "🔨 Building CIAB..."
                pnpm build 2>/dev/null || echo "⚠️  Build failed or not available"
                ;;
                
            "telex")
                if [ "$FULL_RESET" = true ]; then
                    echo "🧹 Cleaning pnpm cache and node_modules..."
                    pnpm store prune 2>/dev/null || true
                    rm -rf node_modules
                fi
                echo "📦 Installing dependencies with pnpm..."
                pnpm install
                
                # Check MinIO
                if docker ps | grep -q telex-minio; then
                    echo "✅ MinIO already running"
                else
                    echo "⚠️  MinIO not running - start with 'pnpm run minio:start'"
                fi
                ;;
        esac
        
        cd "$DK_ROOT"
        echo "✅ $repo reset complete"
        
    else
        echo "⚠️  $repo not found - skipping"
    fi
done

# Re-create Jetpack integration fix
echo ""
echo "🔧 Updating Jetpack integration..."
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

echo "✅ Jetpack integration updated"

echo ""
echo "🎉 Reset Complete!"
echo "=================="
echo ""
echo "Summary:"
if [ "$FULL_RESET" = true ]; then
    echo "• Full reset performed (dependencies reinstalled)"
else
    echo "• Light reset performed (dependencies updated)"
    echo "• Use --full flag for complete reinstallation"
fi
echo "• All repositories updated to latest"
echo "• Dependencies installed/updated"
echo "• Build assets generated where needed"
echo ""
echo "Next steps:"
echo "• Check status: ./skills/setup/scripts/status.sh"
echo "• Start servers: ./skills/dev-servers/scripts/start.sh [service]"
echo ""