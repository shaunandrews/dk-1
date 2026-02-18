#!/bin/bash
# Determine which repository you're currently in and provide context

# Get current directory
CURRENT_DIR=$(pwd)

# Get dk-1 root directory
DK_ROOT=""

# Find dk-1 root by looking for dk.config.json or skills/ directory
search_dir="$CURRENT_DIR"
while [ "$search_dir" != "/" ]; do
    if [ -f "$search_dir/dk.config.json" ] || [ -d "$search_dir/skills" ]; then
        DK_ROOT="$search_dir"
        break
    fi
    search_dir="$(dirname "$search_dir")"
done

if [ -z "$DK_ROOT" ]; then
    echo "❌ Not in a dk-1 workspace"
    echo "💡 Navigate to your dk-1 directory first"
    exit 1
fi

# Determine current repository context
REPO_CONTEXT="dk-1"
REPO_PATH=""

if [[ "$CURRENT_DIR" == "$DK_ROOT/repos/"* ]]; then
    # We're in a sub-repository
    REPO_PATH="${CURRENT_DIR#$DK_ROOT/repos/}"
    REPO_CONTEXT=$(echo "$REPO_PATH" | cut -d'/' -f1)
fi

echo "📍 Repository Context"
echo "===================="
echo "Location: $REPO_CONTEXT"

case "$REPO_CONTEXT" in
    "dk-1")
        echo "Description: Design Kit workspace"
        echo "Purpose: AI rules, setup scripts, documentation, configuration"
        echo ""
        echo "🔧 Available commands:"
        echo "  ./skills/setup/scripts/setup.sh           # Initial setup"
        echo "  ./skills/setup/scripts/repos.sh clone     # Clone repositories" 
        echo "  ./skills/setup/scripts/status.sh          # Check status"
        echo "  ./skills/dev-servers/scripts/start.sh     # Start dev servers"
        echo ""
        echo "📁 Key directories:"
        echo "  skills/          # AI skills for each repository"
        echo "  repos/           # Cloned WordPress repositories"
        echo "  docs/            # Documentation"
        ;;
        
    "calypso")
        cd "$DK_ROOT/repos/calypso" 2>/dev/null || exit 1
        
        echo "Description: WordPress.com dashboard (React/TypeScript)"
        echo "Node Version: 22.9.0"
        echo "Package Manager: yarn"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use    # Switch to correct Node version"
        echo "  yarn install                       # Install dependencies"
        echo "  yarn start:debug                   # Start development server"
        echo "  # → http://calypso.localhost:3000 (Legacy)"
        echo "  # → http://my.localhost:3000 (New Dashboard)"
        echo ""
        echo "🏗️ Architecture:"
        echo "  Two separate interfaces with different stacks:"
        echo "  • Legacy: client/blocks/, client/components/ (Redux + SCSS)"
        echo "  • Dashboard: client/dashboard/ (TanStack Query + minimal CSS)"
        ;;
        
    "gutenberg")
        cd "$DK_ROOT/repos/gutenberg" 2>/dev/null || exit 1
        
        echo "Description: Block editor & component library"
        echo "Node Version: 20"
        echo "Package Manager: npm"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use    # Switch to Node 20"
        echo "  npm ci                             # Install dependencies"
        echo "  npm run build                      # Build (required first)"
        echo "  npm run dev                        # → http://localhost:9999"
        echo "  npm run storybook                  # → http://localhost:50240"
        echo ""
        echo "⚠️  wp-env conflict: Use WordPress Core's wp-env when both exist"
        ;;
        
    "wordpress-core")
        cd "$DK_ROOT/repos/wordpress-core" 2>/dev/null || exit 1
        
        echo "Description: WordPress Core software (PHP/Node)"
        echo "Node Version: 20"
        echo "Package Manager: npm"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use    # Switch to Node 20"
        echo "  npm ci                             # Install dependencies"
        echo "  npm run build                      # Build assets"
        echo "  npm run dev                        # → http://localhost:8889"
        echo ""
        echo "🔌 Jetpack integration:"
        if [ -f "src/wp-content/mu-plugins/jetpack-monorepo-fix.php" ]; then
            echo "  Jetpack mu-plugin: Configured ✅"
        else
            echo "  Jetpack mu-plugin: Missing ⚠️"
        fi
        ;;
        
    "jetpack")
        cd "$DK_ROOT/repos/jetpack" 2>/dev/null || exit 1
        
        echo "Description: Jetpack plugin (PHP/TypeScript monorepo)"
        echo "Node Version: 22.19.0"
        echo "Package Manager: pnpm"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use         # Switch to Node 22"
        echo "  pnpm install                            # Install JS dependencies"
        echo "  composer install                        # Install PHP dependencies"
        echo "  pnpm jetpack build plugins/jetpack --deps  # Build plugin"
        echo "  pnpm jetpack watch plugins/jetpack     # Watch for changes"
        echo ""
        echo "🏃 Run in WordPress Core environment"
        echo "💡 Start Core wp-env first, then watch Jetpack changes"
        ;;
        
    "ciab")
        cd "$DK_ROOT/repos/ciab" 2>/dev/null || exit 1
        
        echo "Description: Commerce in a Box admin SPA (private)"
        echo "Node Version: 22"
        echo "Package Manager: pnpm"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use    # Switch to Node 22"
        echo "  pnpm install                       # Install JS dependencies"
        echo "  composer install                   # Install PHP dependencies"
        echo "  pnpm dev                           # → http://localhost:9001/wp-admin/"
        echo ""
        echo "🏗️ Architecture: React SPA replacing WordPress admin"
        echo "🔒 Requires: Automattic access"
        ;;
        
    "telex")
        cd "$DK_ROOT/repos/telex" 2>/dev/null || exit 1
        
        echo "Description: AI block authoring tool (private)"
        echo "Node Version: 22"
        echo "Package Manager: pnpm"
        echo ""
        
        if [ -d ".git" ]; then
            echo "🔍 Git Status:"
            echo "Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
            uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$uncommitted" -eq 0 ]; then
                echo "Status: Clean working directory ✅"
            else
                echo "Status: $uncommitted uncommitted changes ⚠️"
            fi
        fi
        
        echo ""
        echo "🔧 Development commands:"
        echo "  source ~/.nvm/nvm.sh && nvm use    # Switch to Node 22"
        echo "  pnpm install                       # Install dependencies"
        echo "  pnpm run minio:start               # Start MinIO (required first!)"
        echo "  pnpm run dev                       # → http://localhost:3000"
        echo ""
        echo "⚙️  Special requirements:"
        echo "  • Docker (for MinIO S3 storage)"
        echo "  • WordPress.com OAuth credentials"
        echo "  • Anthropic API key"
        echo "🔒 Requires: Automattic access"
        ;;
        
    *)
        echo "Description: Unknown repository"
        echo "Path: $REPO_PATH"
        ;;
esac

# Show current Node version if available
if command -v node &> /dev/null; then
    current_node=$(node --version | sed 's/v//')
    echo ""
    echo "🔧 Current Node version: $current_node"
fi

# Git branch shortcuts
if [ "$REPO_CONTEXT" != "dk-1" ]; then
    echo ""
    echo "💡 Git shortcuts:"
    echo "  ../../../skills/setup/scripts/status.sh     # Check all repos"
    echo "  ../../../skills/setup/scripts/which-repo.sh # This script"
fi