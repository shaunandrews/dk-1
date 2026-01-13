#!/bin/bash
#
# Test Fresh Setup
# Builds and runs a Docker container to test that setup works for new users.
#
# Usage:
#   ./bin/test-fresh.sh           # Run full test
#   ./bin/test-fresh.sh --build   # Just build the image
#   ./bin/test-fresh.sh --shell   # Open a shell in the container (for debugging)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="dk-fresh-test"

cd "$ROOT_DIR"

# Check Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required to run this test."
    echo "   Install Docker Desktop: https://docs.docker.com/desktop/install/"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

build_image() {
    echo "🔨 Building test image..."
    docker build -t "$IMAGE_NAME" -f test/Dockerfile .
    echo "✅ Image built: $IMAGE_NAME"
}

run_test() {
    echo ""
    echo "🧪 Running fresh setup test..."
    echo "   This simulates a new user setting up Design Kit."
    echo "   (Docker is intentionally not available inside the container)"
    echo ""
    
    docker run --rm \
        -v "$(pwd):/repo:ro" \
        "$IMAGE_NAME"
}

run_shell() {
    echo "🐚 Opening shell in test container..."
    echo "   The repo is mounted at /repo"
    echo "   Type 'exit' to leave"
    echo ""
    
    docker run --rm -it \
        -v "$(pwd):/repo:ro" \
        --entrypoint /bin/bash \
        "$IMAGE_NAME"
}

# Parse arguments
case "${1:-}" in
    --build)
        build_image
        ;;
    --shell)
        build_image
        run_shell
        ;;
    --help|-h)
        echo "Test Fresh Setup - Verify setup works for new users"
        echo ""
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  (none)    Build image and run full test"
        echo "  --build   Just build the Docker image"
        echo "  --shell   Build and open a shell for debugging"
        echo "  --help    Show this help"
        ;;
    *)
        build_image
        run_test
        ;;
esac
