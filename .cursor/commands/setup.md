# Setup

Set up the Design Kit environment. This command initializes git submodules and installs all dependencies.

## When to Use

- First time opening this project
- After cloning the repository
- When the designer says "set up", "initialize", or "install dependencies"

## What This Does

1. **Checks prerequisites** - git, node, yarn, npm, pnpm, composer, docker
2. **Initializes submodules** - Clones Calypso, Gutenberg, WordPress Core, CIAB, and Jetpack
3. **Installs dependencies** - Runs the appropriate package manager for each repo
4. **Reports status** - Tells the designer what's ready and what (if anything) is missing

## AI Execution Steps

### Step 1: Check Prerequisites

Run these checks and report findings to the designer:

```bash
# Required tools
git --version
node --version
yarn --version
npm --version
pnpm --version
composer --version

# Optional (for WP Core/CIAB/Jetpack)
docker --version
```

Tell the designer:
- ✅ Which tools are available
- ⚠️ Which tools are missing (with install instructions)
- Whether Docker is needed for their use case

### Step 2: Check Current State

Determine if this is a fresh clone or partial setup:

```bash
# Check if submodules are initialized
ls repos/calypso
ls repos/gutenberg
ls repos/wordpress-core
ls repos/ciab
ls repos/jetpack

# Check if dependencies are installed
ls repos/calypso/node_modules
ls repos/gutenberg/node_modules
```

### Step 3: Run Setup

Execute the setup script:

```bash
./bin/setup.sh
```

This script will:
1. Initialize git submodules with `git submodule update --init --depth 1`
2. Install Calypso dependencies with `yarn install`
3. Install Gutenberg dependencies with `npm ci`
4. Install WordPress Core dependencies with `npm ci`
5. Install CIAB dependencies with `pnpm install` and `composer install`
6. Install Jetpack dependencies with `pnpm install` and `composer install`
7. Build the Jetpack plugin

**Important**: This takes 5-10 minutes. Keep the designer informed of progress.

### Step 4: Verify and Report

After setup completes, verify each repo:

```bash
./bin/status.sh
```

Tell the designer:
- ✅ What was set up successfully
- ⚠️ Any warnings or issues
- What they can do next (start a dev server, ask questions, etc.)

## Response Pattern

### Starting Setup

```
I'll set up the Design Kit environment for you. This will:
- Clone 5 git submodules (Calypso, Gutenberg, WordPress Core, CIAB, Jetpack)
- Install dependencies for each repository
- Take about 5-10 minutes

Let me check your system first...
```

### Prerequisites Check

```
✅ Git: installed
✅ Node.js: v20.x (meets requirement of v18+)
✅ Yarn: installed
✅ npm: installed
✅ pnpm: installed
✅ Composer: installed
⚠️ Docker: not running (optional - needed for WP Core/CIAB/Jetpack local environments)

All required tools are available. Starting setup...
```

### During Setup

Provide updates as each step completes:

```
📦 Initializing submodules... ✅
📦 Installing Calypso dependencies... ✅
📦 Installing Gutenberg dependencies... ✅
...
```

### Setup Complete

```
🎉 Setup complete! All repositories are ready.

You can now:
• Ask me to start any dev server (e.g., "start Calypso")
• Tell me what you want to work on
• Ask me to find components or patterns

What would you like to do first?
```

### If Setup Fails

```
I encountered an issue: [specific error]

Let me try to fix this...

[Attempt recovery or provide clear instructions]
```

## Common Issues

### Submodule Authentication
If submodules fail to clone, the designer may need to authenticate with GitHub.

### Disk Space
Full setup requires ~10GB. Check with `df -h` if installs fail.

### Network Issues
Large downloads may timeout. Retry usually works.

### Permission Issues
If npm/pnpm fail with EACCES, suggest using a Node version manager (nvm, fnm).

## Manual Alternative

If the script fails, these are the manual steps:

```bash
# 1. Initialize submodules
git submodule update --init --depth 1

# 2. Calypso
cd repos/calypso && yarn install

# 3. Gutenberg
cd repos/gutenberg && npm ci

# 4. WordPress Core
cd repos/wordpress-core && npm ci

# 5. CIAB
cd repos/ciab && pnpm install && composer install

# 6. Jetpack
cd repos/jetpack && pnpm install && composer install
pnpm jetpack build plugins/jetpack --deps
```
