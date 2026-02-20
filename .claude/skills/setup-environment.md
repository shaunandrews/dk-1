---
name: setup-environment
description: Set up the Design Kit environment by cloning repositories and installing dependencies
---

# Design Kit: Setup Environment

This skill handles the initial setup of the Design Kit workspace, including cloning repositories, installing dependencies, and building required packages.

## When to Use

Invoke this skill when:
- First time opening the Design Kit project
- After cloning the repository
- User says "set up", "initialize", or "install dependencies"
- Dependencies are missing or incomplete

## What This Skill Does

1. Checks prerequisites (git, node, yarn, npm, pnpm, composer, docker)
2. Clones repositories (Calypso, Gutenberg, WordPress Core, Jetpack, optionally CIAB/Telex)
3. Installs dependencies for each repository
4. Builds required packages (Gutenberg, Jetpack)
5. Sets up special requirements (Jetpack mu-plugin)
6. Reports status and next steps

## Execution Steps

### Step 1: Check Prerequisites

Run prerequisite checks and report findings:

```bash
# Required tools
Bash: git --version
Bash: node --version
Bash: command -v nvm
Bash: yarn --version
Bash: npm --version
Bash: pnpm --version
Bash: composer --version

# Required for WP Core/CIAB/Jetpack
Bash: npx @wordpress/env --version

# Optional (only for Telex - MinIO)
Bash: docker --version
Bash: docker info
```

**Report to user**:
```
Checking prerequisites...

✅ Git: installed
✅ Node.js: v[version]
✅ nvm: available
✅ Yarn: installed
✅ npm: installed
✅ pnpm: installed
✅ Composer: installed
✅ @wordpress/env: installed (for WP Core/CIAB/Jetpack)
⚠️ Docker: not running (optional - only needed for Telex MinIO)

All required tools are ready. Proceeding with setup...
```

**If missing tools**, provide installation instructions:

```
⚠️ Missing prerequisites:

nvm (Node Version Manager):
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  Then restart terminal and run: nvm install 20 && nvm install 22

pnpm:
  npm install -g pnpm

Composer:
  Mac: brew install composer
  Or visit: https://getcomposer.org/download/

@wordpress/env (for WP Core/CIAB/Jetpack):
  npm -g install @wordpress/env

Docker Desktop (optional - only for Telex MinIO):
  Mac: https://docs.docker.com/desktop/setup/install/mac-install/
```

### Step 2: Check Current State

Determine if this is a fresh setup or partial:

```bash
Bash: ls -la repos/
```

If repos exist, check which need setup:
```bash
Bash: ./bin/repos.sh status
```

### Step 3: Execute Setup

Run the unified setup script:

```bash
Bash: ./bin/setup.sh
run_in_background: false
timeout: 600000
```

**Important**: This takes 5-10 minutes. Monitor progress and keep user informed.

The script will:
1. Clone repositories using `./bin/repos.sh clone`
2. Install Calypso dependencies (Node 22, yarn)
3. Install Gutenberg dependencies (Node 20, npm) + build
4. Install WordPress Core dependencies (Node 20, npm) + build
5. Install Jetpack dependencies (Node 22, pnpm + composer) + build
6. Create Jetpack mu-plugin for URL fixes
7. Optionally install CIAB/Telex (if accessible)

### Step 4: Provide Progress Updates

As each major step completes:

```
📦 Cloning repositories...
✅ Repositories cloned

📦 Setting up Calypso (Node 22)...
✅ Calypso ready

📦 Setting up Gutenberg (Node 20)...
📦 Building Gutenberg...
✅ Gutenberg ready

📦 Setting up WordPress Core (Node 20)...
📦 Building WordPress Core...
✅ WordPress Core ready

📦 Setting up Jetpack (Node 22)...
📦 Building Jetpack plugin...
✅ Jetpack ready
```

### Step 5: Verify Setup

After completion, verify with status check:

```bash
Bash: ./bin/status.sh
```

Check that:
- All repos have `node_modules/` directories
- Gutenberg has `build/` directory
- Jetpack plugin is built
- No obvious errors in output

### Step 6: Report Completion

Tell the user what's ready and next steps:

```
🎉 Design Kit setup complete!

Repositories ready:
✅ Calypso - WordPress.com dashboard
✅ Gutenberg - Block editor & components
✅ WordPress Core - Core WordPress software
✅ Jetpack - Jetpack plugin
[✅ CIAB - Commerce in a Box (if cloned)]
[✅ Telex - Block authoring tool (if cloned)]

Next steps:
• Start a development server: "./bin/start.sh calypso" (or gutenberg, storybook, core, jetpack)
• Browse components: "./bin/start.sh storybook"
• Tell me what you want to work on

What would you like to do?
```

## Handling Errors

### Repository Clone Failures

If a repo fails to clone:
```
⚠️ Failed to clone [repo-name]

This could be due to:
• Network issues - Check your internet connection
• Authentication - For CIAB/Telex, ensure SSH key configured for github.a8c.com
• Disk space - Full setup requires ~10GB

Retry? Or continue without [repo-name]?
```

### Dependency Installation Failures

If npm/yarn/pnpm install fails:
```
⚠️ Failed to install dependencies for [repo-name]

Common issues:
• Network timeout - Retry usually works
• Disk space - Check with: df -h
• Permission issues - Ensure not using sudo/admin npm

Attempting retry...
```

### Build Failures

If build step fails:
```
⚠️ Build failed for [repo-name]

Error: [error message]

This might be:
• TypeScript cache issue - Try: rm -rf [repo]/build
• Missing dependency - Try: cd [repo] && [package-manager] install
• Code error - Check the error message above

Would you like me to try troubleshooting?
```

## Special Cases

### Partial Setup

If some repos are already set up:
```
Detected existing repositories:
✅ Calypso - already set up
✅ Gutenberg - already set up
⚠️ Jetpack - needs dependencies

I'll set up the remaining repositories...
```

### CIAB/Telex (Private Repos)

These require Automattic access:
```
CIAB and Telex are optional and require Automattic internal access.

CIAB - Commerce in a Box admin redesign
Telex - AI-powered block authoring tool

To include them, ensure your SSH key is configured for github.a8c.com:
  ssh -T git@github.a8c.com

Skip for now? [Yes/No]
```

### Docker Not Available

```
⚠️ Docker is not running

Docker is only needed for Telex (MinIO for S3 storage).

WordPress Core, CIAB, and Jetpack use wp-env with Playground runtime — no Docker required.
Calypso, Gutenberg, and Storybook also work without Docker.

Continue setup without Docker? [Yes/No]
```

## Manual Setup Alternative

If automated setup fails, provide manual steps:

```bash
# 1. Clone repositories
./bin/repos.sh clone

# 2. Calypso (Node 22)
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use
yarn install

# 3. Gutenberg (Node 20)
cd ../gutenberg
source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build

# 4. WordPress Core (Node 20)
cd ../wordpress-core
source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build

# 5. Jetpack (Node 22)
cd ../jetpack
source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
pnpm jetpack build plugins/jetpack --deps
```

## Post-Setup Recommendations

After successful setup:

1. **Start Storybook** to browse components:
   ```
   ./bin/start.sh storybook
   ```

2. **Check repository status**:
   ```
   ./bin/repos.sh status
   ```

3. **Read project documentation**:
   - `README.md` - Project overview
   - `CLAUDE.md` - AI guidance
   - `docs/repo-map.md` - How repos connect

## Resources

- **Setup script**: `bin/setup.sh`
- **Repository manager**: `bin/repos.sh`
- **Status check**: `bin/status.sh`
- **Setup docs**: `docs/getting-started.md`
- **Setup rules**: `.cursor/rules/setup.mdc`
