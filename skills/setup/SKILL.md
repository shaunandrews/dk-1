# Environment Setup and Repository Management

This skill covers the complete setup protocol for the WordPress ecosystem development environment, including prerequisites, Node version management, repository cloning and installation, and workspace initialization.

## Overview

Setting up the WordPress ecosystem development environment involves managing multiple repositories with different Node versions, package managers, and dependencies. This skill provides the complete protocol for getting a development environment up and running.

## Prerequisites

### Required Tools

#### Essential Tools
- **Git** — Version control
- **nvm** — Node version management (CRITICAL for multi-repo development)
- **Docker Desktop** — For wp-env (WordPress Core, CIAB, Jetpack, Telex)
- **Composer** — PHP dependency management (CIAB, Jetpack)

#### Package Managers
- **yarn** — For Calypso
- **npm** — Comes with Node.js (Gutenberg, WordPress Core)
- **pnpm** — For Jetpack, CIAB, Telex

### Installing Prerequisites

#### Install nvm (Node Version Manager)
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Reload shell
source ~/.nvm/nvm.sh

# Install required Node versions
nvm install 20    # For Gutenberg, WordPress Core
nvm install 22    # For Calypso, Jetpack, CIAB, Telex
```

#### Install Package Managers
```bash
# pnpm (for Jetpack, CIAB, Telex)
npm install -g pnpm

# yarn comes with Node, but ensure latest
npm install -g yarn@latest
```

#### Install Docker Desktop
- **macOS**: Download from https://docker.com/products/docker-desktop
- **Windows**: Download from https://docker.com/products/docker-desktop  
- **Linux**: Follow distribution-specific instructions

#### Install Composer (PHP)
```bash
# macOS (using Homebrew)
brew install composer

# Or download directly
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

## Repository Configuration

### Node Version Requirements

Each repository requires a specific Node version:

| Repository | Node Version | Package Manager | Docker Required |
|------------|--------------|-----------------|-----------------|
| **Calypso** | 22.9.0 | yarn | No |
| **Gutenberg** | 20 | npm | No |
| **WordPress Core** | 20 | npm | Yes (wp-env) |
| **Jetpack** | 22.19.0 | pnpm | Yes (development) |
| **CIAB** | 22 | pnpm | Yes |
| **Telex** | 22 | pnpm | Yes (MinIO) |

### Repository Locations
```
dk-1/
├── repos/                    # All cloned repositories
│   ├── calypso/             # WordPress.com dashboard
│   ├── gutenberg/           # Block editor + components  
│   ├── wordpress-core/      # WordPress Core software
│   ├── jetpack/             # Jetpack plugin
│   ├── ciab/               # Commerce in a Box (private)
│   └── telex/              # AI block authoring (private)
└── skills/                  # This skills directory
```

## Setup Protocol

### Phase 1: Repository Cloning

#### Public Repositories
```bash
# Clone public WordPress repositories
cd repos/

# Calypso
git clone https://github.com/Automattic/wp-calypso.git calypso
cd calypso && git checkout trunk && cd ..

# Gutenberg
git clone https://github.com/WordPress/gutenberg.git gutenberg
cd gutenberg && git checkout trunk && cd ..

# WordPress Core
git clone https://github.com/WordPress/wordpress-develop.git wordpress-core
cd wordpress-core && git checkout trunk && cd ..

# Jetpack
git clone https://github.com/Automattic/jetpack.git jetpack
cd jetpack && git checkout trunk && cd ..
```

#### Private Repositories (Requires Automattic Access)
```bash
# CIAB (requires Automattic access)
git clone git@github.com:Automattic/ciab.git ciab
cd ciab && git checkout trunk && cd ..

# Telex (requires Automattic access)  
git clone git@github.com:Automattic/telex.git telex
cd telex && git checkout main && cd ..
```

### Phase 2: Dependency Installation

#### Calypso Setup
```bash
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
yarn install                     # Install dependencies
# Initial build happens on first start
```

#### Gutenberg Setup
```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 20
npm ci                           # Clean install
npm run build                    # Required before dev/storybook
```

#### WordPress Core Setup
```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 20
npm ci                           # Install dependencies
npm run build                    # Build assets
```

#### Jetpack Setup
```bash
cd repos/jetpack
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
pnpm install                     # Install JavaScript dependencies
composer install                # Install PHP dependencies

# Build main Jetpack plugin
pnpm jetpack build plugins/jetpack --deps
```

#### CIAB Setup (if accessible)
```bash
cd repos/ciab
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
pnpm install                     # JavaScript dependencies
composer install                # PHP dependencies
pnpm build                       # Build assets
```

#### Telex Setup (if accessible)
```bash
cd repos/telex
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
pnpm install                     # Install dependencies

# Telex requires additional setup (MinIO, API keys)
# See telex/README.md for complete setup instructions
```

### Phase 3: Integration Configuration

#### Jetpack in WordPress Core Integration
Create mu-plugin to fix Jetpack URLs in development:

```bash
# Create mu-plugins directory
mkdir -p repos/wordpress-core/src/wp-content/mu-plugins/

# Create Jetpack integration fix
cat > repos/wordpress-core/src/wp-content/mu-plugins/jetpack-monorepo-fix.php << 'EOF'
<?php
/**
 * Jetpack Monorepo Development Fix
 * 
 * Fixes plugins_url() for Jetpack packages in monorepo development.
 */

add_filter( 'plugins_url', function( $url, $path, $plugin ) {
    if ( strpos( $plugin, 'jetpack' ) !== false ) {
        // Fix plugin URL for monorepo development
        $url = str_replace( '/plugins/jetpack/projects/plugins/', '/plugins/', $url );
    }
    return $url;
}, 10, 3 );
EOF
```

## Development Server Management

### Starting Development Servers

#### Calypso
```bash
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use
yarn start:debug
# → http://calypso.localhost:3000 (Legacy)
# → http://my.localhost:3000 (New Dashboard)
```

#### Gutenberg  
```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use
npm run dev        # → http://localhost:9999
npm run storybook  # → http://localhost:50240 (Components)
```

#### WordPress Core
```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use
npm run dev        # → http://localhost:8889
```

#### Jetpack (runs in WordPress Core)
```bash
# Start WordPress Core first
cd repos/wordpress-core && npm run dev

# In another terminal, watch Jetpack changes
cd repos/jetpack
source ~/.nvm/nvm.sh && nvm use
pnpm jetpack watch plugins/jetpack
```

#### CIAB
```bash
cd repos/ciab
source ~/.nvm/nvm.sh && nvm use
pnpm dev          # → http://localhost:9001/wp-admin/
```

#### Telex
```bash
cd repos/telex
source ~/.nvm/nvm.sh && nvm use

# Start MinIO first (required)
pnpm run minio:start

# Start development server
pnpm run dev      # → http://localhost:3000
```

### Port Management

Default development ports:

| Service | Port | URL |
|---------|------|-----|
| Calypso Legacy | 3000 | http://calypso.localhost:3000 |
| Calypso Dashboard | 3000 | http://my.localhost:3000 |
| WordPress Core | 8889 | http://localhost:8889 |
| Gutenberg Dev | 9999 | http://localhost:9999 |
| Gutenberg Storybook | 50240 | http://localhost:50240 |
| CIAB | 9001 | http://localhost:9001 |
| Telex | 3000 | http://localhost:3000 |
| MinIO (Telex) | 9000/9001 | http://localhost:9001 (admin) |

## Workspace Management Scripts

### Repository Status Checking
```bash
#!/bin/bash
# scripts/status.sh - Check status of all repositories

repos=("calypso" "gutenberg" "wordpress-core" "jetpack" "ciab" "telex")

for repo in "${repos[@]}"; do
    if [ -d "repos/$repo" ]; then
        echo "=== $repo ==="
        cd "repos/$repo"
        echo "Branch: $(git branch --show-current)"
        echo "Status: $(git status --porcelain | wc -l) changes"
        git status --porcelain | head -3
        cd - > /dev/null
        echo
    else
        echo "=== $repo === (not cloned)"
        echo
    fi
done
```

### Repository Updating
```bash
#!/bin/bash
# scripts/repos.sh - Manage multiple repositories

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

case "$1" in
    "clone")
        echo "Cloning public repositories..."
        mkdir -p repos
        cd repos
        
        # Public repos
        [ ! -d "calypso" ] && git clone https://github.com/Automattic/wp-calypso.git calypso
        [ ! -d "gutenberg" ] && git clone https://github.com/WordPress/gutenberg.git gutenberg  
        [ ! -d "wordpress-core" ] && git clone https://github.com/WordPress/wordpress-develop.git wordpress-core
        [ ! -d "jetpack" ] && git clone https://github.com/Automattic/jetpack.git jetpack
        
        if [ "$2" = "--include-private" ]; then
            echo "Cloning private repositories..."
            [ ! -d "ciab" ] && git clone git@github.com:Automattic/ciab.git ciab
            [ ! -d "telex" ] && git clone git@github.com:Automattic/telex.git telex
        fi
        ;;
        
    "update")
        echo "Updating all repositories..."
        for repo in repos/*/; do
            if [ -d "$repo/.git" ]; then
                echo "Updating $(basename "$repo")..."
                cd "$repo"
                git pull
                cd "$DK_ROOT"
            fi
        done
        ;;
        
    "status")
        bash "$DK_ROOT/skills/setup/scripts/status.sh"
        ;;
        
    *)
        echo "Usage: $0 {clone|clone --include-private|update|status}"
        ;;
esac
```

### Environment Reset
```bash
#!/bin/bash  
# scripts/reset.sh - Reset development environment

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Resetting development environment..."

repos=("calypso" "gutenberg" "wordpress-core" "jetpack" "ciab" "telex")

for repo in "${repos[@]}"; do
    if [ -d "$DK_ROOT/repos/$repo" ]; then
        echo "Resetting $repo..."
        cd "$DK_ROOT/repos/$repo"
        
        # Pull latest
        git pull
        
        # Switch to correct Node version and install
        if [ -f ".nvmrc" ]; then
            source ~/.nvm/nvm.sh && nvm use
        fi
        
        case "$repo" in
            "calypso")
                yarn install
                ;;
            "gutenberg"|"wordpress-core")
                npm ci
                [ "$repo" = "gutenberg" ] && npm run build
                ;;
            "jetpack"|"ciab"|"telex")  
                pnpm install
                [ "$repo" = "jetpack" ] && composer install
                [ "$repo" = "ciab" ] && composer install
                ;;
        esac
        
        cd "$DK_ROOT"
    fi
done

echo "Reset complete!"
```

## Troubleshooting Common Issues

### Node Version Problems
**Symptom**: Build errors, dependency conflicts
**Solution**: Always use correct Node version
```bash
cd repos/[repo-name]
source ~/.nvm/nvm.sh && nvm use
```

### Port Conflicts  
**Symptom**: "Port already in use" errors
**Solution**: Check and kill conflicting processes
```bash
# Find process using port
lsof -ti:3000

# Kill process
kill $(lsof -ti:3000)
```

### wp-env Conflicts
**Symptom**: Docker errors when running multiple wp-env instances
**Solution**: Only run ONE wp-env at a time
```bash
# ✅ Use WordPress Core wp-env when both exist
cd repos/wordpress-core && npm run dev

# ❌ Don't run Gutenberg wp-env when Core exists  
# cd repos/gutenberg && npm run dev
```

### SSH Key Requests (macOS)
**Symptom**: Frequent SSH key prompts from VSCode/Cursor
**Solution**: Cache SSH keys in macOS keychain
```bash
# Add to ~/.ssh/config
Host *
  AddKeysToAgent yes  
  UseKeychain yes
```

### Permission Issues
**Symptom**: Cannot clone private repositories
**Solution**: Ensure SSH keys are set up for GitHub access
```bash
# Test SSH access
ssh -T git@github.com

# Should show: "Hi username! You've successfully authenticated..."
```

### Docker Issues
**Symptom**: wp-env fails to start
**Solution**: Ensure Docker Desktop is running and has sufficient resources
```bash
# Check Docker status
docker --version
docker ps

# Restart Docker Desktop if needed
```

## Verification Checklist

After running setup, verify everything is working:

### ✅ Prerequisites Installed
- [ ] Git installed and configured
- [ ] nvm installed with Node 20 and 22  
- [ ] Docker Desktop running
- [ ] Package managers installed (yarn, pnpm)
- [ ] Composer installed (for PHP repos)

### ✅ Repositories Cloned
- [ ] Calypso cloned and on `trunk` branch
- [ ] Gutenberg cloned and on `trunk` branch  
- [ ] WordPress Core cloned and on `trunk` branch
- [ ] Jetpack cloned and on `trunk` branch
- [ ] CIAB cloned (if accessible)
- [ ] Telex cloned (if accessible)

### ✅ Dependencies Installed
- [ ] Calypso: `yarn install` completed
- [ ] Gutenberg: `npm ci && npm run build` completed
- [ ] WordPress Core: `npm ci && npm run build` completed
- [ ] Jetpack: `pnpm install && composer install` completed
- [ ] CIAB: Dependencies installed (if accessible)
- [ ] Telex: Dependencies installed (if accessible)

### ✅ Development Servers Start
- [ ] Calypso starts on port 3000
- [ ] Gutenberg dev starts on port 9999
- [ ] Gutenberg Storybook starts on port 50240
- [ ] WordPress Core starts on port 8889
- [ ] Jetpack builds and watches correctly
- [ ] CIAB starts (if accessible)
- [ ] Telex starts with MinIO (if accessible)

## Maintenance and Updates

### Regular Maintenance Tasks

#### Weekly Repository Updates
```bash
# Update all repositories
./skills/setup/scripts/repos.sh update

# Reinstall dependencies (as needed)
./skills/setup/scripts/reset.sh
```

#### Monthly Dependency Updates
```bash
# Update WordPress packages across repos
cd repos/calypso && yarn upgrade @wordpress/components @wordpress/data
cd repos/jetpack && pnpm update @wordpress/components
# Test for compatibility issues
```

#### Docker Maintenance
```bash
# Clean up Docker resources periodically
docker system prune

# Update WordPress Docker images
cd repos/wordpress-core && npm run env clean
```

This setup protocol ensures a consistent, working development environment across all WordPress ecosystem repositories with proper Node version management and dependency installation.