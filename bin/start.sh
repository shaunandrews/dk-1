#!/bin/bash
#
# Design Kit Dev Server Launcher
# Unified interface for starting development servers
#
# Usage: ./bin/start.sh <repo>
# Examples:
#   ./bin/start.sh calypso
#   ./bin/start.sh gutenberg
#   ./bin/start.sh storybook
#   ./bin/start.sh core
#   ./bin/start.sh ciab
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

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

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed."
        echo ""
        echo "   WordPress Core and CIAB require Docker Desktop to run local environments."
        echo ""
        echo "   Download Docker Desktop:"
        echo "   • Mac: https://docs.docker.com/desktop/setup/install/mac-install/"
        echo "   • Windows: https://docs.docker.com/desktop/setup/install/windows-install/"
        echo "   • Linux: https://docs.docker.com/desktop/setup/install/linux/"
        echo ""
        echo "   Note: Calypso, Gutenberg, and Storybook don't require Docker."
        exit 1
    fi
    
    # Check if Docker daemon is running
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
    echo "  core       - WordPress Core dev site (http://localhost:8889)"
    echo "  ciab       - Commerce in a Box (http://localhost:9001/wp-admin/)"
    echo "  jetpack    - Jetpack plugin dev (runs in WP Core at http://localhost:8889)"
    echo ""
    echo "Examples:"
    echo "  $0 calypso"
    echo "  $0 storybook"
    echo "  $0 jetpack"
    echo ""
}

start_calypso() {
    echo "🚀 Starting Calypso (Node 22)..."
    cd "$ROOT_DIR/repos/calypso"
    switch_node_version "$ROOT_DIR/repos/calypso"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://calypso.localhost:3000"
    export NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--max-old-space-size=8192"
    exec yarn start:debug
}

start_gutenberg() {
    echo "🚀 Starting Gutenberg (Node 20)..."
    cd "$ROOT_DIR/repos/gutenberg"
    switch_node_version "$ROOT_DIR/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9999"
    exec npm run dev
}

start_storybook() {
    echo "🚀 Starting Storybook (Node 20)..."
    cd "$ROOT_DIR/repos/gutenberg"
    switch_node_version "$ROOT_DIR/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:50240"
    exec npm run storybook
}

start_core() {
    check_docker
    echo "🚀 Starting WordPress Core (Node 20)..."
    cd "$ROOT_DIR/repos/wordpress-core"
    switch_node_version "$ROOT_DIR/repos/wordpress-core"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:8889"
    exec npm run dev
}

start_ciab() {
    check_docker
    echo "🚀 Starting CIAB (Node 22)..."
    cd "$ROOT_DIR/repos/ciab"
    switch_node_version "$ROOT_DIR/repos/ciab"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9001/wp-admin/"
    echo "   Note: You may also need to run 'pnpm env:start' in another terminal"
    exec pnpm dev
}

start_jetpack() {
    check_docker
    echo "🚀 Starting Jetpack development environment (Node 22)..."
    
    # Check Jetpack dependencies
    cd "$ROOT_DIR/repos/jetpack"
    switch_node_version "$ROOT_DIR/repos/jetpack"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    
    # Check if Jetpack was built
    if [ ! -d "projects/plugins/jetpack/_inc/build" ]; then
        echo "⚠️  Jetpack not built. Building now..."
        pnpm jetpack build plugins/jetpack --deps
    fi
    
    # Check WordPress Core dependencies (needs Node 20)
    cd "$ROOT_DIR/repos/wordpress-core"
    switch_node_version "$ROOT_DIR/repos/wordpress-core"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  WordPress Core dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    
    # Ensure mu-plugin exists for URL fixes
    if [ ! -f "src/wp-content/mu-plugins/jetpack-monorepo-fix.php" ]; then
        echo "⚠️  Jetpack mu-plugin missing. Run ./bin/setup.sh to create it."
    fi
    
    echo ""
    echo "   Jetpack runs within the WordPress Core environment."
    echo "   Starting WordPress Core Docker containers..."
    echo ""
    
    # Start WordPress Core environment
    npm run env:start
    
    # Create symlink for Jetpack in the container
    # The jetpack/projects folder is mounted at /var/www/jetpack-projects
    # We need to symlink the plugin into wp-content/plugins so WordPress sees it
    echo "   Creating Jetpack symlink in container..."
    docker compose exec -T cli rm -rf /var/www/src/wp-content/plugins/jetpack 2>/dev/null || true
    docker compose exec -T cli ln -s /var/www/jetpack-projects/plugins/jetpack /var/www/src/wp-content/plugins/jetpack
    
    # Activate Jetpack if not already active
    echo "   Activating Jetpack plugin..."
    docker compose exec -T cli wp plugin activate jetpack 2>/dev/null || true
    
    echo ""
    echo "   ✅ WordPress Core is running at http://localhost:8889"
    echo "   ✅ Jetpack is active at http://localhost:8889/wp-admin/admin.php?page=jetpack"
    echo ""
    echo "   To watch for changes during development:"
    echo "   cd repos/jetpack && pnpm jetpack watch plugins/jetpack"
    echo ""
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
