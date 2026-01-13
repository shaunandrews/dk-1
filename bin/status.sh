#!/bin/bash
#
# Design Kit Status Script
# Shows the status of all repos at a glance
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "📊 Design Kit Status"
echo "===================="
echo ""

cd "$ROOT_DIR"

# Function to show repo status
show_status() {
    local name=$1
    local path=$2
    
    echo "📦 $name"
    echo "   Path: $path"
    
    cd "$ROOT_DIR/$path"
    
    # Current branch
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "   Branch: $branch"
    
    # Last commit
    local commit=$(git log -1 --format="%h %s" 2>/dev/null | head -c 60)
    echo "   Last commit: $commit"
    
    # Status
    local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$changes" -gt 0 ]; then
        echo "   Changes: $changes uncommitted files"
    else
        echo "   Changes: Clean"
    fi
    
    # Stashes
    local stashes=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$stashes" -gt 0 ]; then
        echo "   Stashes: $stashes"
    fi
    
    cd "$ROOT_DIR"
    echo ""
}

show_status "Calypso" "repos/calypso"
show_status "Gutenberg" "repos/gutenberg"
show_status "WordPress Core" "repos/wordpress-core"
show_status "CIAB" "repos/ciab"

echo "📁 Design Kit"
echo "   Path: $ROOT_DIR"
dk_changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$dk_changes" -gt 0 ]; then
    echo "   Changes: $dk_changes uncommitted files"
else
    echo "   Changes: Clean"
fi
echo ""
