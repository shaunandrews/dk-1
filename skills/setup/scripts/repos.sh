#!/bin/bash
# Repository management script for WordPress ecosystem

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

case "$1" in
    "clone")
        echo "🔄 Cloning repositories..."
        mkdir -p repos
        cd repos
        
        # Public repositories
        repos=(
            "calypso:https://github.com/Automattic/wp-calypso.git:trunk"
            "gutenberg:https://github.com/WordPress/gutenberg.git:trunk"  
            "wordpress-core:https://github.com/WordPress/wordpress-develop.git:trunk"
            "jetpack:https://github.com/Automattic/jetpack.git:trunk"
        )
        
        for repo_info in "${repos[@]}"; do
            IFS=':' read -r name url branch <<< "$repo_info"
            
            if [ ! -d "$name" ]; then
                echo "Cloning $name..."
                git clone "$url" "$name"
                cd "$name"
                git checkout "$branch"
                cd ..
                echo "✅ $name cloned"
            else
                echo "✅ $name already exists"
            fi
        done
        
        # Private repositories (if requested)
        if [ "$2" = "--include-private" ]; then
            echo "🔒 Cloning private repositories..."
            
            private_repos=(
                "ciab:git@github.com:Automattic/ciab.git:trunk"
                "telex:git@github.com:Automattic/telex.git:main"
            )
            
            for repo_info in "${private_repos[@]}"; do
                IFS=':' read -r name url branch <<< "$repo_info"
                
                if [ ! -d "$name" ]; then
                    echo "Cloning $name..."
                    if git clone "$url" "$name" 2>/dev/null; then
                        cd "$name"
                        git checkout "$branch"
                        cd ..
                        echo "✅ $name cloned"
                    else
                        echo "❌ Failed to clone $name (check SSH access)"
                    fi
                else
                    echo "✅ $name already exists"
                fi
            done
        fi
        
        cd "$DK_ROOT"
        echo "📦 Run ./skills/setup/scripts/setup.sh to install dependencies"
        ;;
        
    "clone-ciab")
        echo "🔒 Cloning CIAB..."
        mkdir -p repos
        cd repos
        
        if [ ! -d "ciab" ]; then
            if git clone git@github.com:Automattic/ciab.git ciab 2>/dev/null; then
                cd ciab && git checkout trunk && cd ..
                echo "✅ CIAB cloned"
            else
                echo "❌ Failed to clone CIAB (check SSH access to Automattic repos)"
            fi
        else
            echo "✅ CIAB already exists"
        fi
        ;;
        
    "clone-telex")
        echo "🔒 Cloning Telex..."
        mkdir -p repos
        cd repos
        
        if [ ! -d "telex" ]; then
            if git clone git@github.com:Automattic/telex.git telex 2>/dev/null; then
                cd telex && git checkout main && cd ..
                echo "✅ Telex cloned"
            else
                echo "❌ Failed to clone Telex (check SSH access to Automattic repos)"
            fi
        else
            echo "✅ Telex already exists"
        fi
        ;;
        
    "update")
        echo "🔄 Updating all repositories..."
        
        for repo_dir in repos/*/; do
            if [ -d "$repo_dir/.git" ]; then
                repo=$(basename "$repo_dir")
                echo "Updating $repo..."
                cd "$repo_dir"
                
                # Stash any local changes
                if [ -n "$(git status --porcelain)" ]; then
                    echo "  Stashing local changes..."
                    git stash
                fi
                
                # Pull latest changes
                git pull
                
                cd "$DK_ROOT"
                echo "✅ $repo updated"
            fi
        done
        
        echo "💡 Run ./skills/setup/scripts/reset.sh to reinstall dependencies"
        ;;
        
    "status")
        bash "$DK_ROOT/skills/setup/scripts/status.sh"
        ;;
        
    *)
        echo "WordPress Ecosystem Repository Manager"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  clone                    Clone public repositories"
        echo "  clone --include-private  Clone public + private repositories"
        echo "  clone-ciab              Clone CIAB only"
        echo "  clone-telex             Clone Telex only"
        echo "  update                  Update all repositories"
        echo "  status                  Show repository status"
        echo ""
        echo "Examples:"
        echo "  $0 clone                # Clone public repos"
        echo "  $0 clone --include-private  # Clone all repos"
        echo "  $0 update               # Update all repos"
        echo "  $0 status               # Check status"
        ;;
esac