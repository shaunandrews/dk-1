#!/bin/bash
#
# Design Kit Reset Script
# Pulls latest from all repos and optionally reinstalls dependencies
#

set -e

DK_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Parse arguments
FULL_RESET=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --full) FULL_RESET=true ;;
        --help|-h)
            echo "Usage: reset.sh [options]"
            echo ""
            echo "Options:"
            echo "  --full    Also clean and reinstall all dependencies"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "🔄 Design Kit Reset"
echo "==================="
echo ""

cd "$DK_ROOT"

# Function to reset a repo
reset_repo() {
    local name=$1
    local path=$2
    local branch=${3:-trunk}

    echo "📦 Resetting $name..."
    cd "$DK_ROOT/$path"

    # Stash any local changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "   Stashing local changes..."
        git stash push -m "dk-reset-$(date +%Y%m%d-%H%M%S)"
    fi

    # Fetch and reset to latest
    git fetch origin "$branch" --depth 1
    git checkout "$branch"
    git reset --hard "origin/$branch"

    echo "✅ $name reset to latest $branch"
    cd "$DK_ROOT"
}

# Reset all repos
reset_repo "Calypso" "repos/calypso" "trunk"
reset_repo "Gutenberg" "repos/gutenberg" "trunk"
reset_repo "WordPress Core" "repos/wordpress-core" "trunk"
reset_repo "CIAB" "repos/ciab" "trunk"

echo ""

# Full reset: clean and reinstall dependencies
if [ "$FULL_RESET" = true ]; then
    echo "🧹 Full reset: cleaning and reinstalling dependencies..."
    echo ""

    # Calypso
    echo "📦 Reinstalling Calypso dependencies..."
    cd "$DK_ROOT/repos/calypso"
    rm -rf node_modules
    if command -v yarn &> /dev/null; then
        yarn install
    fi
    cd "$DK_ROOT"

    # Gutenberg
    echo "📦 Reinstalling Gutenberg dependencies..."
    cd "$DK_ROOT/repos/gutenberg"
    rm -rf node_modules
    npm install
    cd "$DK_ROOT"

    # WordPress Core
    echo "📦 Reinstalling WordPress Core dependencies..."
    cd "$DK_ROOT/repos/wordpress-core"
    rm -rf node_modules
    npm install
    cd "$DK_ROOT"

    # CIAB
    echo "📦 Reinstalling CIAB dependencies..."
    cd "$DK_ROOT/repos/ciab"
    rm -rf node_modules
    if command -v pnpm &> /dev/null; then
        pnpm install
    fi
    if command -v composer &> /dev/null; then
        composer install
    fi
    cd "$DK_ROOT"

    echo ""
    echo "✅ All dependencies reinstalled"
fi

echo ""
echo "🎉 Reset complete!"
echo ""
echo "Your stashed changes (if any) can be recovered with:"
echo "  cd repos/[repo] && git stash list"
echo "  git stash pop"
echo ""
