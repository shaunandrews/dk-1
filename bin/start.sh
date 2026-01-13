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
    echo ""
    echo "Examples:"
    echo "  $0 calypso"
    echo "  $0 storybook"
    echo ""
}

start_calypso() {
    echo "🚀 Starting Calypso..."
    cd "$ROOT_DIR/repos/calypso"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://calypso.localhost:3000"
    exec yarn start
}

start_gutenberg() {
    echo "🚀 Starting Gutenberg..."
    cd "$ROOT_DIR/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9999"
    exec npm run dev
}

start_storybook() {
    echo "🚀 Starting Storybook..."
    cd "$ROOT_DIR/repos/gutenberg"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:50240"
    exec npm run storybook
}

start_core() {
    check_docker
    echo "🚀 Starting WordPress Core..."
    cd "$ROOT_DIR/repos/wordpress-core"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:8889"
    exec npm run dev
}

start_ciab() {
    check_docker
    echo "🚀 Starting CIAB..."
    cd "$ROOT_DIR/repos/ciab"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run ./bin/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9001/wp-admin/"
    echo "   Note: You may also need to run 'pnpm env:start' in another terminal"
    exec pnpm dev
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
