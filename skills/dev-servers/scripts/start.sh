#!/bin/bash
#
# Design Kit Dev Server Launcher
# Unified interface for starting development servers
#
# Usage: start.sh <repo>
# Examples:
#   start.sh calypso
#   start.sh gutenberg
#   start.sh storybook
#   start.sh core
#   start.sh ciab
#

set -e

DK_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Helper function to switch Node version using nvm
switch_node_version() {
    local repo_dir="$1"
    if [ -f "$repo_dir/.nvmrc" ]; then
        if [ -f "$HOME/.nvm/nvm.sh" ]; then
            source "$HOME/.nvm/nvm.sh"
            nvm use 2>/dev/null || nvm install
        else
            echo "⚠️  nvm not found. Install nvm for automatic Node version switching."
            echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
            echo ""
        fi
    fi
}

check_wp_env() {
    if ! command -v wp-env &> /dev/null; then
        echo "⚠️  wp-env not found. Installing @wordpress/env..."
        npm install -g @wordpress/env
        if ! command -v wp-env &> /dev/null; then
            echo "❌ Failed to install @wordpress/env."
            echo ""
            echo "   Install it manually:"
            echo "   npm install -g @wordpress/env"
            exit 1
        fi
        echo "   ✅ @wordpress/env installed."
    fi
}

check_docker() {
    # Only used for Telex now
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed."
        echo ""
        echo "   Telex requires Docker Desktop for MinIO and block builder."
        echo ""
        echo "   Download Docker Desktop:"
        echo "   • Mac: https://docs.docker.com/desktop/setup/install/mac-install/"
        echo "   • Windows: https://docs.docker.com/desktop/setup/install/windows-install/"
        echo "   • Linux: https://docs.docker.com/desktop/setup/install/linux/"
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo "❌ Docker is installed but not running."
        echo ""
        echo "   Please start Docker Desktop and try again."
        exit 1
    fi
}

show_help() {
    echo "🚀 Design Kit Dev Server Launcher"
    echo ""
    echo "Usage: $0 <repo>"
    echo ""
    echo "Available repos:"
    echo "  calypso    - WordPress.com dashboard (http://calypso.localhost:3000)"
    echo "  gutenberg  - Block Editor dev site (http://localhost:9999)"
    echo "  storybook  - Gutenberg component library (http://localhost:50240)"
    echo "  core       - WordPress Core dev site (http://localhost:8889) [no Docker]"
    echo "  ciab       - Commerce in a Box (http://localhost:9001/wp-admin/) [no Docker]"
    echo "  jetpack    - Jetpack plugin dev (runs in WP Core at http://localhost:8889) [no Docker]"
    echo ""
    echo "Examples:"
    echo "  $0 calypso"
    echo "  $0 storybook"
    echo "  $0 jetpack"
    echo ""
}

start_calypso() {
    echo "🚀 Starting Calypso (Node 22)..."
    cd "$DK_ROOT/repos/calypso"
    switch_node_version "$DK_ROOT/repos/calypso"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://calypso.localhost:3000"
    # Use our heap size; start:debug hardcodes 6144 and overrides NODE_OPTIONS, so we run start with debug env instead
    export NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--max-old-space-size=8192"
    export SOURCEMAP="eval-source-map"
    exec yarn start
}

start_gutenberg() {
    echo "🚀 Starting Gutenberg (Node 20)..."
    cd "$DK_ROOT/repos/gutenberg"
    switch_node_version "$DK_ROOT/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9999"
    exec npm run dev
}

start_storybook() {
    echo "🚀 Starting Storybook (Node 20)..."
    cd "$DK_ROOT/repos/gutenberg"
    switch_node_version "$DK_ROOT/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:50240"
    exec npm run storybook
}

start_core() {
    check_wp_env
    echo "🚀 Starting WordPress Core (Playground runtime)..."
    cd "$DK_ROOT/repos/wordpress-core"
    switch_node_version "$DK_ROOT/repos/wordpress-core"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    # Ensure .wp-env.json exists (may not after fresh clone since repos/ is gitignored)
    if [ ! -f ".wp-env.json" ]; then
        cp "$DK_ROOT/configs/wp-env-core.json" ".wp-env.json"
    fi
    echo "   URL: http://localhost:8889"
    echo "   Runtime: WordPress Playground (no Docker required)"
    echo "   Database: SQLite"
    exec wp-env start --runtime=playground
}

start_ciab() {
    check_wp_env
    echo "🚀 Starting CIAB (Node 22)..."
    cd "$DK_ROOT/repos/ciab"
    switch_node_version "$DK_ROOT/repos/ciab"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9001/wp-admin/"
    echo "   Runtime: WordPress Playground (no Docker required)"
    exec pnpm dev
}

start_jetpack() {
    check_wp_env
    echo "🚀 Starting Jetpack development environment..."

    # Check Jetpack dependencies
    cd "$DK_ROOT/repos/jetpack"
    switch_node_version "$DK_ROOT/repos/jetpack"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi

    # Check if Jetpack was built
    if [ ! -d "projects/plugins/jetpack/_inc/build" ]; then
        echo "⚠️  Jetpack not built. Building now..."
        pnpm jetpack build plugins/jetpack --deps
    fi

    # Use the dk root wp-env config that includes Jetpack
    cd "$DK_ROOT"

    # Copy Jetpack wp-env config to root (wp-env reads .wp-env.json from cwd)
    cp "$DK_ROOT/configs/wp-env-jetpack.json" "$DK_ROOT/.wp-env.json"

    echo ""
    echo "   Jetpack runs within the WordPress Core environment."
    echo "   Starting via wp-env with Playground runtime..."
    echo ""
    echo "   URL: http://localhost:8889"
    echo "   Jetpack admin: http://localhost:8889/wp-admin/admin.php?page=jetpack"
    echo "   Runtime: WordPress Playground (no Docker required)"
    echo ""
    echo "   To watch for changes during development:"
    echo "   cd repos/jetpack && pnpm jetpack watch plugins/jetpack"
    echo ""
    exec wp-env start --runtime=playground
}

# Main
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

case "$1" in
    calypso)
        start_calypso
        ;;
    gutenberg)
        start_gutenberg
        ;;
    storybook)
        start_storybook
        ;;
    core|wordpress-core|wp-core)
        start_core
        ;;
    ciab)
        start_ciab
        ;;
    jetpack)
        start_jetpack
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        echo "❌ Unknown repo: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
