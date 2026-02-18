#!/bin/bash
# Status checker for WordPress ecosystem repositories

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

echo "📊 WordPress Ecosystem Status"
echo "=============================="

repos=("calypso" "gutenberg" "wordpress-core" "jetpack" "ciab" "telex")
node_versions=("22.9.0" "20" "20" "22.19.0" "22" "22")
package_managers=("yarn" "npm" "npm" "pnpm" "pnpm" "pnpm")

for i in "${!repos[@]}"; do
    repo="${repos[$i]}"
    expected_node="${node_versions[$i]}"
    pkg_manager="${package_managers[$i]}"
    
    echo ""
    echo "=== $repo ==="
    
    if [ -d "repos/$repo" ]; then
        cd "repos/$repo"
        
        # Git status
        current_branch=$(git branch --show-current 2>/dev/null || echo "detached")
        echo "📁 Branch: $current_branch"
        
        # Count changes
        changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$changes" -eq 0 ]; then
            echo "✅ Git: Clean working directory"
        else
            echo "⚠️  Git: $changes uncommitted changes"
            git status --porcelain | head -3
        fi
        
        # Node version check
        if [ -f ".nvmrc" ]; then
            expected_node=$(cat .nvmrc)
        fi
        
        if command -v node &> /dev/null; then
            current_node=$(node --version | sed 's/v//')
            if [[ "$current_node" == "$expected_node"* ]]; then
                echo "✅ Node: $current_node (correct)"
            else
                echo "⚠️  Node: $current_node (expected $expected_node)"
            fi
        else
            echo "❌ Node: Not available"
        fi
        
        # Dependencies status
        case "$pkg_manager" in
            "yarn")
                if [ -f "node_modules/.yarn-integrity" ]; then
                    echo "✅ Dependencies: yarn installed"
                else
                    echo "❌ Dependencies: Run 'yarn install'"
                fi
                ;;
            "npm")
                if [ -f "node_modules/.package-lock.json" ] || [ -d "node_modules" ]; then
                    echo "✅ Dependencies: npm installed"
                else
                    echo "❌ Dependencies: Run 'npm ci'"
                fi
                ;;
            "pnpm")
                if [ -f "node_modules/.pnpm/registry.npmjs.org" ] || [ -d "node_modules" ]; then
                    echo "✅ Dependencies: pnpm installed"
                else
                    echo "❌ Dependencies: Run 'pnpm install'"
                fi
                ;;
        esac
        
        # Build status (for repos that require building)
        case "$repo" in
            "gutenberg")
                if [ -d "build" ] && [ -n "$(ls -A build 2>/dev/null)" ]; then
                    echo "✅ Build: Assets built"
                else
                    echo "❌ Build: Run 'npm run build'"
                fi
                ;;
            "wordpress-core")
                if [ -d "build" ] && [ -n "$(ls -A build 2>/dev/null)" ]; then
                    echo "✅ Build: Assets built"
                else
                    echo "❌ Build: Run 'npm run build'"
                fi
                ;;
            "jetpack")
                if [ -d "projects/plugins/jetpack/_inc/build" ]; then
                    echo "✅ Build: Jetpack assets built"
                else
                    echo "❌ Build: Run 'pnpm jetpack build plugins/jetpack --deps'"
                fi
                ;;
        esac
        
        # Special checks
        case "$repo" in
            "jetpack")
                if [ -d "vendor" ]; then
                    echo "✅ PHP: Composer dependencies installed"
                else
                    echo "❌ PHP: Run 'composer install'"
                fi
                ;;
            "ciab")
                if [ -d "vendor" ]; then
                    echo "✅ PHP: Composer dependencies installed"
                else
                    echo "❌ PHP: Run 'composer install'"
                fi
                ;;
            "telex")
                if docker ps | grep -q telex-minio; then
                    echo "✅ MinIO: Running"
                else
                    echo "❌ MinIO: Run 'pnpm run minio:start'"
                fi
                ;;
        esac
        
        cd "$DK_ROOT"
    else
        echo "❌ Repository: Not cloned"
        echo "💡 Run: ./skills/setup/scripts/repos.sh clone"
        
        # Check if it's a private repo
        if [ "$repo" = "ciab" ] || [ "$repo" = "telex" ]; then
            echo "🔒 Note: $repo requires Automattic access"
        fi
    fi
done

echo ""
echo "=== Development Servers ==="

# Check if any dev servers are running
ports=(3000 8889 9999 50240 9001)
port_names=("Calypso" "WordPress Core" "Gutenberg Dev" "Storybook" "CIAB")

for i in "${!ports[@]}"; do
    port="${ports[$i]}"
    name="${port_names[$i]}"
    
    if lsof -ti:$port > /dev/null 2>&1; then
        echo "🟢 $name: Running on port $port"
    else
        echo "⚪ $name: Not running"
    fi
done

echo ""
echo "=== System Requirements ==="

# Check prerequisites
if command -v git &> /dev/null; then
    git_version=$(git --version | cut -d' ' -f3)
    echo "✅ Git: $git_version"
else
    echo "❌ Git: Not installed"
fi

if command -v nvm &> /dev/null; then
    echo "✅ nvm: Available"
else
    echo "❌ nvm: Not installed"
fi

if command -v docker &> /dev/null; then
    if docker ps > /dev/null 2>&1; then
        echo "✅ Docker: Running"
    else
        echo "⚠️  Docker: Installed but not running"
    fi
else
    echo "❌ Docker: Not installed"
fi

if command -v composer &> /dev/null; then
    composer_version=$(composer --version | cut -d' ' -f3)
    echo "✅ Composer: $composer_version"
else
    echo "⚠️  Composer: Not installed (needed for Jetpack/CIAB)"
fi

echo ""
echo "💡 Tips:"
echo "  • Use './skills/setup/scripts/reset.sh' to reinstall dependencies"
echo "  • Use './skills/dev-servers/scripts/start.sh' to start servers"
echo "  • Use './skills/setup/scripts/which-repo.sh' to check current location"