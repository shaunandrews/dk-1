#!/bin/bash
#
# Design Kit Setup Script
# Run this once after cloning to set up the full environment
#

set -e

DK_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Helper function to switch Node version using nvm
switch_node_version() {
    local repo_dir="$1"
    if [ -f "$repo_dir/.nvmrc" ]; then
        if [ -f "$HOME/.nvm/nvm.sh" ]; then
            # Source nvm and switch to the version specified in .nvmrc
            source "$HOME/.nvm/nvm.sh"
            nvm use 2>/dev/null || nvm install
        else
            echo "⚠️  nvm not found. Install nvm for automatic Node version switching."
            echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
        fi
    fi
}

echo "🎨 Design Kit Setup"
echo "==================="
echo ""

cd "$DK_ROOT"

# Clone repositories
echo "📦 Cloning repositories..."
echo ""
"$DK_ROOT/skills/setup/scripts/repos.sh" clone
echo ""

# Calypso setup (requires Node 22)
echo "📦 Setting up Calypso..."
cd "$DK_ROOT/repos/calypso"
switch_node_version "$DK_ROOT/repos/calypso"
if command -v yarn &> /dev/null; then
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    echo "✅ Calypso dependencies installed"
else
    echo "⚠️  Yarn not found. Install yarn to set up Calypso: npm install -g yarn"
fi
cd "$DK_ROOT"
echo ""

# Gutenberg setup (requires Node 20)
echo "📦 Setting up Gutenberg..."
cd "$DK_ROOT/repos/gutenberg"
switch_node_version "$DK_ROOT/repos/gutenberg"
npm ci 2>/dev/null || npm install
echo "✅ Gutenberg dependencies installed"

# Build Gutenberg (required for dev server and Storybook)
echo "📦 Building Gutenberg..."
npm run build
echo "✅ Gutenberg built"
cd "$DK_ROOT"
echo ""

# WordPress Core setup (requires Node 20)
echo "📦 Setting up WordPress Core..."
cd "$DK_ROOT/repos/wordpress-core"
switch_node_version "$DK_ROOT/repos/wordpress-core"
npm ci 2>/dev/null || npm install
echo "✅ WordPress Core dependencies installed"

# Build WordPress Core (required for dev server)
echo "📦 Building WordPress Core..."
npm run build
echo "✅ WordPress Core built"
cd "$DK_ROOT"
echo ""

# CIAB setup (optional - requires Automattic access, requires Node 22)
if [ -d "$DK_ROOT/repos/ciab" ]; then
    echo "📦 Setting up CIAB..."
    cd "$DK_ROOT/repos/ciab"
    switch_node_version "$DK_ROOT/repos/ciab"
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
    cd "$DK_ROOT"
    echo ""
else
    echo "⏭️  Skipping CIAB setup (not initialized - requires Automattic access)"
    echo ""
fi

# Jetpack setup (requires Node 22)
echo "📦 Setting up Jetpack..."
cd "$DK_ROOT/repos/jetpack"
switch_node_version "$DK_ROOT/repos/jetpack"
if command -v pnpm &> /dev/null; then
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    echo "✅ Jetpack dependencies installed"
    if command -v composer &> /dev/null; then
        composer install
        echo "✅ Jetpack PHP dependencies installed"
    else
        echo "⚠️  Composer not found. Install composer to set up Jetpack PHP dependencies"
    fi

    # Build Jetpack with all dependencies (required for first run)
    echo "📦 Building Jetpack plugin..."
    pnpm jetpack build plugins/jetpack --deps
    echo "✅ Jetpack plugin built"
else
    echo "⚠️  pnpm not found. Install pnpm to set up Jetpack: npm install -g pnpm"
fi
cd "$DK_ROOT"
echo ""

# Ensure Jetpack monorepo fix mu-plugin exists
echo "📦 Setting up Jetpack mu-plugin..."
if [ -f "$DK_ROOT/repos/wordpress-core/src/wp-content/mu-plugins/jetpack-monorepo-fix.php" ]; then
    echo "✅ Jetpack monorepo fix mu-plugin already exists"
else
    echo "⚠️  Creating Jetpack monorepo fix mu-plugin..."
    mkdir -p "$DK_ROOT/repos/wordpress-core/src/wp-content/mu-plugins"
    cat > "$DK_ROOT/repos/wordpress-core/src/wp-content/mu-plugins/jetpack-monorepo-fix.php" << 'MUPLUGIN'
<?php
/**
 * Plugin Name: Jetpack Monorepo Development Fix
 * Description: Fixes plugins_url() for Jetpack packages when running in a monorepo development environment.
 * Version: 1.0.0
 */

add_filter( 'plugins_url', 'dk_fix_jetpack_monorepo_plugins_url', 10, 3 );

function dk_fix_jetpack_monorepo_plugins_url( $url, $path, $plugin ) {
    if ( strpos( $plugin, '/var/www/jetpack-projects/packages/' ) !== false ) {
        if ( preg_match( '#/var/www/jetpack-projects/packages/([^/]+)/(.*)$#', $plugin, $matches ) ) {
            $package_name = $matches[1];
            $file_subpath = $matches[2];
            $file_dir = dirname( $file_subpath );
            $resolved_path = dk_resolve_relative_path( $file_dir, $path );
            $url = content_url( 'plugins/jetpack/jetpack_vendor/automattic/jetpack-' . $package_name . '/' . $resolved_path );
        }
    }
    return $url;
}

function dk_resolve_relative_path( $base_dir, $relative_path ) {
    if ( empty( $base_dir ) || $base_dir === '.' ) {
        $parts = array();
    } else {
        $parts = explode( '/', $base_dir );
    }
    $relative_parts = explode( '/', $relative_path );
    foreach ( $relative_parts as $part ) {
        if ( $part === '..' ) {
            array_pop( $parts );
        } elseif ( $part !== '.' && $part !== '' ) {
            $parts[] = $part;
        }
    }
    return implode( '/', $parts );
}
MUPLUGIN
    echo "✅ Jetpack monorepo fix mu-plugin created"
fi
echo ""

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  • Open in Cursor: cursor ."
echo "  • Start Calypso:     $DK_ROOT/skills/dev-servers/scripts/start.sh calypso"
echo "  • Start Gutenberg:   $DK_ROOT/skills/dev-servers/scripts/start.sh gutenberg"
echo "  • Start Storybook:   $DK_ROOT/skills/dev-servers/scripts/start.sh storybook"
echo "  • Start WP Core:     $DK_ROOT/skills/dev-servers/scripts/start.sh core"
echo "  • Start Jetpack:     $DK_ROOT/skills/dev-servers/scripts/start.sh jetpack"
if [ -d "$DK_ROOT/repos/ciab" ]; then
    echo "  • Start CIAB:        $DK_ROOT/skills/dev-servers/scripts/start.sh ciab"
fi
echo ""
echo "URLs:"
echo "  • Calypso:    http://calypso.localhost:3000"
echo "  • Gutenberg:  http://localhost:9999"
echo "  • Storybook:  http://localhost:50240"
echo "  • WP Core:    http://localhost:8889"
if [ -d "$DK_ROOT/repos/ciab" ]; then
    echo "  • CIAB:       http://localhost:9001"
fi
echo ""
