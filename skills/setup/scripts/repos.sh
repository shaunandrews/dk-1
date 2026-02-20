#!/bin/bash
#
# Design Kit Repository Manager
# Manages cloning and updating of all Design Kit repositories
#

set -e

DK_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
REPOS_DIR="$DK_ROOT/repos"

# Repository definitions
# Format: "name|url"
PUBLIC_REPOS=(
    "calypso|https://github.com/Automattic/wp-calypso"
    "gutenberg|https://github.com/WordPress/gutenberg"
    "wordpress-core|https://github.com/WordPress/wordpress-develop"
    "jetpack|https://github.com/Automattic/jetpack"
)

PRIVATE_REPOS=(
    "ciab|git@github.a8c.com:Automattic/ciab-admin.git"
    "telex|git@github.a8c.com:Automattic/w0-block-authoring.git"
)

# Clone a single repository
clone_repo() {
    local name=$1
    local url=$2
    local dir="$REPOS_DIR/$name"

    if [ -d "$dir/.git" ]; then
        echo "  ✅ $name already cloned"
        return 0
    fi

    echo "  📦 Cloning $name..."
    if git clone --depth 1 "$url" "$dir" 2>/dev/null; then
        echo "  ✅ $name cloned successfully"
        return 0
    else
        echo "  ❌ Failed to clone $name"
        return 1
    fi
}

# Update a single repository
update_repo() {
    local name=$1
    local dir="$REPOS_DIR/$name"

    if [ ! -d "$dir/.git" ]; then
        echo "  ⚠️  $name not cloned, skipping"
        return 1
    fi

    echo "  🔄 Updating $name..."
    if git -C "$dir" pull --ff-only 2>/dev/null; then
        echo "  ✅ $name updated"
        return 0
    else
        echo "  ⚠️  $name has local changes or conflicts, skipping"
        return 1
    fi
}

# Get status of a repository
repo_status() {
    local name=$1
    local dir="$REPOS_DIR/$name"

    if [ ! -d "$dir/.git" ]; then
        printf "  %-20s %s\n" "$name:" "Not cloned"
        return 1
    fi

    local branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local commit=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    local status=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    if [ "$status" -gt 0 ]; then
        printf "  %-20s %s (%s) - %s uncommitted changes\n" "$name:" "$branch" "$commit" "$status"
    else
        printf "  %-20s %s (%s)\n" "$name:" "$branch" "$commit"
    fi
}

# Clone all public repositories
clone_all_public() {
    echo "📦 Cloning public repositories..."
    echo ""

    local failed=0
    for repo_def in "${PUBLIC_REPOS[@]}"; do
        IFS='|' read -r name url <<< "$repo_def"
        if ! clone_repo "$name" "$url"; then
            failed=$((failed + 1))
        fi
    done

    echo ""
    if [ $failed -eq 0 ]; then
        echo "✅ All public repositories cloned"
    else
        echo "⚠️  Some repositories failed to clone"
        return 1
    fi
}

# Clone CIAB (private, requires Automattic access)
clone_ciab() {
    echo "📦 Cloning CIAB (requires Automattic access)..."
    echo ""

    local ciab_def="${PRIVATE_REPOS[0]}"
    IFS='|' read -r name url <<< "$ciab_def"

    if clone_repo "$name" "$url"; then
        echo ""
        echo "✅ CIAB cloned successfully"
        return 0
    else
        echo ""
        echo "❌ Failed to clone CIAB"
        echo "   This requires Automattic internal access and SSH key configured for github.a8c.com"
        return 1
    fi
}

# Clone Telex (private, requires Automattic access)
clone_telex() {
    echo "📦 Cloning Telex (requires Automattic access)..."
    echo ""

    local telex_def="${PRIVATE_REPOS[1]}"
    IFS='|' read -r name url <<< "$telex_def"

    if clone_repo "$name" "$url"; then
        echo ""
        echo "✅ Telex cloned successfully"
        return 0
    else
        echo ""
        echo "❌ Failed to clone Telex"
        echo "   This requires Automattic internal access and SSH key configured for github.a8c.com"
        return 1
    fi
}

# Clone all repositories (public + private repos if requested)
clone_all() {
    local include_ciab=false
    local include_telex=false
    local include_private=false

    # Check for flags
    for arg in "$@"; do
        case "$arg" in
            --include-ciab) include_ciab=true ;;
            --include-telex) include_telex=true ;;
            --include-private) include_private=true ;;
        esac
    done

    clone_all_public

    if [ "$include_private" = true ]; then
        echo ""
        clone_ciab
        echo ""
        clone_telex
    else
        if [ "$include_ciab" = true ]; then
            echo ""
            clone_ciab
        fi
        if [ "$include_telex" = true ]; then
            echo ""
            clone_telex
        fi
    fi

    if [ "$include_ciab" = false ] && [ "$include_telex" = false ] && [ "$include_private" = false ]; then
        echo ""
        echo "💡 Tip: To include private repos, run: $0 clone --include-private"
        echo "   Or separately: $0 clone-ciab, $0 clone-telex"
    fi
}

# Update all cloned repositories
update_all() {
    echo "🔄 Updating all cloned repositories..."
    echo ""

    local updated=0
    local skipped=0

    # Update public repos
    for repo_def in "${PUBLIC_REPOS[@]}"; do
        IFS='|' read -r name url <<< "$repo_def"
        if update_repo "$name"; then
            updated=$((updated + 1))
        else
            skipped=$((skipped + 1))
        fi
    done

    # Update CIAB if it exists
    if [ -d "$REPOS_DIR/ciab/.git" ]; then
        if update_repo "ciab"; then
            updated=$((updated + 1))
        else
            skipped=$((skipped + 1))
        fi
    fi

    # Update Telex if it exists
    if [ -d "$REPOS_DIR/telex/.git" ]; then
        if update_repo "telex"; then
            updated=$((updated + 1))
        else
            skipped=$((skipped + 1))
        fi
    fi

    echo ""
    echo "✅ Updated: $updated, Skipped: $skipped"
}

# Show status of all repositories
show_status() {
    echo "📊 Repository Status"
    echo "==================="
    echo ""

    # Status of public repos
    for repo_def in "${PUBLIC_REPOS[@]}"; do
        IFS='|' read -r name url <<< "$repo_def"
        repo_status "$name"
    done

    # Status of CIAB if it exists
    if [ -d "$REPOS_DIR/ciab" ]; then
        repo_status "ciab"
    fi

    # Status of Telex if it exists
    if [ -d "$REPOS_DIR/telex" ]; then
        repo_status "telex"
    fi

    echo ""
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
  clone [options]            Clone all public repositories
    --include-ciab           Also clone CIAB (Automattic access required)
    --include-telex          Also clone Telex (Automattic access required)
    --include-private        Clone all private repos (CIAB + Telex)
  clone-ciab                 Clone CIAB repository (Automattic access required)
  clone-telex                Clone Telex repository (Automattic access required)
  update                     Update all cloned repositories
  status                     Show status of all repositories

Examples:
  $0 clone                   # Clone only public repos
  $0 clone --include-private # Clone all repos including CIAB and Telex
  $0 clone --include-ciab    # Clone public repos + CIAB
  $0 clone --include-telex   # Clone public repos + Telex
  $0 clone-ciab              # Clone just CIAB
  $0 clone-telex             # Clone just Telex
  $0 update                  # Update all cloned repos
  $0 status                  # Show status

EOF
}

# Main command dispatcher
main() {
    # Ensure repos directory exists
    mkdir -p "$REPOS_DIR"

    case "${1:-}" in
        clone)
            clone_all "$@"
            ;;
        clone-ciab)
            clone_ciab
            ;;
        clone-telex)
            clone_telex
            ;;
        update)
            update_all
            ;;
        status)
            show_status
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
