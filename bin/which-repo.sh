#!/bin/bash
#
# Helper script to identify which repository you're currently in
# and provide context-aware git commands
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
REPOS_DIR="$ROOT_DIR/repos"

# Get current directory
CURRENT_DIR=$(pwd)

# Check if we're in dk-1 root
if [ "$CURRENT_DIR" = "$ROOT_DIR" ] || [ "$(basename "$CURRENT_DIR")" = "dk-1" ]; then
    echo "📍 Current repository: dk-1 (Design Kit)"
    echo ""
    echo "   This is the main configuration repository."
    echo "   Branch naming: update/feature-name, add/feature-name, fix/issue-name"
    echo ""
    echo "   Sub-repositories are in: repos/"
    echo ""
    git status --short 2>/dev/null | head -5
    exit 0
fi

# Check if we're in a sub-repo
for repo_dir in "$REPOS_DIR"/*; do
    if [ -d "$repo_dir/.git" ]; then
        repo_name=$(basename "$repo_dir")
        if [[ "$CURRENT_DIR" == "$repo_dir"* ]]; then
            echo "📍 Current repository: $repo_name"
            echo ""
            echo "   Path: $repo_dir"
            echo ""
            
            # Show repo-specific info
            case "$repo_name" in
                calypso)
                    echo "   Default branch: trunk"
                    echo "   Branch prefix: add/, update/, fix/, try/"
                    ;;
                gutenberg)
                    echo "   Default branch: trunk"
                    echo "   Branch prefix: add/, update/, fix/"
                    ;;
                wordpress-core)
                    echo "   Default branch: trunk"
                    echo "   Branch prefix: feature/, fix/"
                    ;;
                jetpack)
                    echo "   Default branch: trunk"
                    echo "   Branch prefix: add/, update/, fix/"
                    ;;
                ciab)
                    echo "   Default branch: trunk"
                    echo "   Branch prefix: add/, update/, fix/"
                    ;;
                telex)
                    echo "   Default branch: main"
                    echo "   Branch prefix: feature/, fix/"
                    ;;
            esac
            
            echo ""
            git status --short 2>/dev/null | head -5
            exit 0
        fi
    fi
done

# Not in a known repo
echo "❓ Unknown repository location: $CURRENT_DIR"
echo ""
echo "   Run this script from:"
echo "   - dk-1 root directory"
echo "   - Any sub-repository in repos/"
