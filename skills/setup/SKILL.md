---
description: "Design Kit setup protocol — read this when running or modifying setup.sh, cloning repos (repos.sh clone), first-time setup, installing dependencies, or starting dev servers. AI must execute setup; never ask the user to run terminal commands."
globs: ["**/*"]
---

# Setup

Environment setup protocol for Design Kit — cloning repositories, installing dependencies, and starting development servers.

**Read this rule when:** the user (or context) involves setup, first-time install, `./skills/setup/scripts/setup.sh`, `./skills/setup/scripts/repos.sh` clone/update, installing dependencies in any repo, starting a dev server for the first time, or troubleshooting "not set up" / clone / install issues. For those tasks, follow this protocol instead of guessing.

## When to Use

- First time opening this project
- After cloning the repository
- When the designer says "set up", "initialize", or "install dependencies"
- Running or modifying `setup.sh`, cloning repos (`repos.sh clone`), first-time setup
- Installing dependencies in any repo
- Starting dev servers for the first time
- Troubleshooting "not set up" / clone / install issues

## What This Does

1. **Checks prerequisites** - git, node, yarn, npm, pnpm, composer, @wordpress/env (docker optional for Telex)
2. **Clones repositories** - Uses `skills/setup/scripts/repos.sh` to clone Calypso, Gutenberg, WordPress Core, and Jetpack (CIAB is optional)
3. **Installs dependencies** - Runs the appropriate package manager for each repo
4. **Reports status** - Tells the designer what's ready and what (if anything) is missing

## AI Setup Protocol

When a designer opens this project in Cursor for the first time, you MUST automatically handle the entire setup process. The designer should never need to open a terminal or run commands manually.

### Step 1: Initial Discovery

When the workspace is opened, immediately:
1. Check if this is a fresh clone (no `repos/` subdirectories exist)
2. Read `README.md` to understand the project structure
3. Read `dk.config.json` to understand repository configuration
4. Read `skills/setup/scripts/setup.sh` to understand setup steps
5. Read `.gitmodules` to see which repos need to be cloned

### Step 2: Prerequisites Check

Before proceeding, check for required tools:
- **Git** - Must be installed (check with `git --version`)
- **nvm** - REQUIRED for Node version management (check with `command -v nvm`)
- **Node.js** - Multiple versions needed via nvm (see Node Version Requirements below)
- **Yarn** - Required for Calypso (check with `yarn --version`)
- **npm** - Required for Gutenberg/WP Core (comes with Node.js)
- **pnpm** - Required for CIAB and Jetpack (check with `pnpm --version`)
- **Composer** - Required for CIAB and Jetpack PHP deps (check with `composer --version`)
- **@wordpress/env** - Required for WordPress Core/Jetpack environments (install with `npm install -g @wordpress/env`)
- **Docker** - Optional, only required for Telex (MinIO/block builder) (check with `docker --version`)

Run these checks and report findings to the designer:

```bash
# Required tools
git --version
node --version
yarn --version
npm --version
pnpm --version
composer --version

# Required (for WP Core/Jetpack)
wp-env --version

# Optional (for Telex only)
docker --version
```

Tell the designer:
- ✅ Which tools are available
- ⚠️ Which tools are missing (with install instructions)
- Whether Docker is needed for their use case

If any required tools are missing, inform the designer and offer to help install them, or proceed with what's available.

#### Node Version Requirements (CRITICAL)

Each repository requires a DIFFERENT Node version. You MUST switch versions when working across repos:

| Repo | Node Version | Package Manager | Switch Command |
|------|-------------|-----------------|----------------|
| Calypso | 22 | yarn | `nvm use` (reads .nvmrc) |
| Gutenberg | 20 | npm | `nvm use` (reads .nvmrc) |
| WordPress Core | 20 | npm | `nvm use` (reads .nvmrc) |
| Jetpack | 22 | pnpm | `nvm use` (reads .nvmrc) |
| CIAB | 22 | pnpm | `nvm use` (reads .nvmrc) |
| Telex | 22 | pnpm | `nvm use 22` (no .nvmrc) |

**AI Behavior for Node Versions:**
1. Before running ANY npm/yarn/pnpm command in a repo, ALWAYS switch to the correct Node version
2. Use `source ~/.nvm/nvm.sh && nvm use` inside each repo directory (reads .nvmrc)
3. If nvm is not installed, inform the user and provide installation instructions
4. When installing dependencies or starting servers, include the nvm switch in the command

**Example commands:**
```bash
# Calypso (Node 22)
cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn install

# Gutenberg (Node 20)
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm ci

# Jetpack (Node 22)
cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm install
```

**Installing nvm:**
If nvm is not installed, provide these instructions:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Then restart terminal or run:
source ~/.nvm/nvm.sh
```

Then install required Node versions:
```bash
nvm install 20
nvm install 22
```

If Docker is missing, inform the designer that all repos work without Docker except Telex (which needs Docker for MinIO and block builder). WordPress Core, Jetpack, and CIAB use wp-env with Playground runtime — no Docker needed.

If Telex is needed and Docker is missing, provide download links:
- Mac: https://docs.docker.com/desktop/setup/install/mac-install/
- Windows: https://docs.docker.com/desktop/setup/install/windows-install/
- Linux: https://docs.docker.com/desktop/setup/install/linux/

### Step 3: Check Current State

Determine if this is a fresh clone or partial setup:

```bash
# Check if repositories are cloned
ls repos/calypso
ls repos/gutenberg
ls repos/wordpress-core
ls repos/jetpack
ls repos/ciab 2>/dev/null || echo "CIAB not cloned (optional)"

# Check if dependencies are installed
ls repos/calypso/node_modules
ls repos/gutenberg/node_modules
```

### Step 4: Automatic Setup Execution

Execute these steps automatically (using terminal commands via run_terminal_cmd):

1. **Initialize Git Submodules**
   ```bash
   git submodule update --init --depth 1
   ```

2. **Install Dependencies** (switch Node version for each repo)
   - Calypso: `cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn install --frozen-lockfile`
   - Gutenberg: `cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm ci`
   - WordPress Core: `cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm ci`
   - CIAB: `cd repos/ciab && source ~/.nvm/nvm.sh && nvm use && pnpm install --frozen-lockfile && composer install`
   - Jetpack: `cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm install && composer install`
   - Telex: See **Telex Setup** section below (requires additional steps)

   **Note:** Cannot run in parallel because each repo needs different Node versions

   Alternatively, execute the setup script which handles all of the above:

   ```bash
   ./skills/setup/scripts/setup.sh
   ```

   This script will:
   1. Clone all public repositories using `skills/setup/scripts/repos.sh clone`
   2. Install Calypso dependencies with `yarn install`
   3. Install Gutenberg dependencies with `npm ci`
   4. Install WordPress Core dependencies with `npm ci`
   5. Install CIAB dependencies (if cloned) with `pnpm install` and `composer install`
   6. Install Jetpack dependencies with `pnpm install` and `composer install`
   7. Build the Jetpack plugin

   **Important**: This takes 5-10 minutes. Keep the designer informed of progress.

3. **Telex Setup** (if repos/telex exists - requires Docker)
   Telex has additional setup requirements beyond just `pnpm install`.

   **Recommended: Use the setup wizard** which handles env files, secrets, config, and MinIO automatically:

   ```bash
   cd repos/telex
   pnpm install
   pnpm dev:setup
   ```

   The wizard will walk through each step interactively: creating env files, generating secrets, building server config, starting MinIO, creating the S3 bucket, and setting up the block build workspace.

   **IMPORTANT**: After the wizard, the user must add their own API keys to `server/.env`:
   - `WPCOM_CLIENT_ID` (from developer.wordpress.com/apps)
   - `WPCOM_CLIENT_SECRET`
   - `ANTHROPIC_API_KEY`

   Also install PHP dependencies separately:
   ```bash
   cd server && composer install && cd ..
   ```

   **Manual alternative** (if the wizard fails or you need to run individual steps):

   ```bash
   cd repos/telex

   # Install dependencies
   pnpm install

   # Copy environment files
   cp client/.env.example client/.env
   cp server/.env.sample server/.env

   # Generate secrets
   pnpm secrets:update

   # Generate server config
   pnpm run config:dev

   # Install PHP dependencies
   cd server && composer install && cd ..

   # Start MinIO (S3 storage)
   pnpm run minio:start

   # Create S3 bucket (CRITICAL!)
   docker run --rm --network host --entrypoint sh minio/mc -c \
     "mc alias set m http://localhost:11111 minioadmin minioadmin && mc mb m/w0-blocks --ignore-existing"

   # Setup block build workspace (CRITICAL!)
   node cli/setup-workspace.js
   ```

   **Note:** Telex requires Docker for MinIO and block builds. Inform user if Docker is not running.

4. **Verify Setup**
   - Check that all `node_modules` directories exist
   - Check that submodules are initialized
   - Report any errors clearly

   ```bash
   ./skills/setup/scripts/status.sh
   ```

### Step 5: Post-Setup Communication

After setup completes, tell the designer:
- ✅ What was set up successfully
- ✅ What repositories are available
- ✅ How to start development servers (you'll handle this too)
- ⚠️ Any warnings or issues encountered

---

## Starting Development Servers (AI Must Handle)

When the designer wants to work on a specific repo, you should:

1. **Detect Intent**: Understand which repo they want to work on
2. **Check Status**: Verify dependencies are installed
3. **Start Server**: Run `./skills/dev-servers/scripts/start.sh [repo]` in the background
4. **Open Browser**: Automatically open the development URL
5. **Monitor**: Keep track of running processes

### Server Commands:
```bash
./skills/dev-servers/scripts/start.sh calypso    # → http://calypso.localhost:3000
./skills/dev-servers/scripts/start.sh gutenberg  # → http://localhost:9999
./skills/dev-servers/scripts/start.sh storybook  # → http://localhost:50240
./skills/dev-servers/scripts/start.sh core       # → http://localhost:8889
./skills/dev-servers/scripts/start.sh ciab       # → http://localhost:9001/wp-admin/
```

### Telex Server (Special - requires manual start):
Telex has its own dev command with an interactive CLI:
```bash
cd repos/telex

# Ensure MinIO is running first
pnpm run minio:status  # Check status
pnpm run minio:start   # Start if needed

# Start Telex (client + server + admin)
pnpm run dev
# → Client: http://localhost:3000
# → API: http://localhost:8000
# → Admin: http://localhost:4000
```

---

## Designer Interaction Patterns

### When Designer Opens Project
```
You: "I see you've opened the Design Kit project. Let me set everything up for you automatically. This will take a few minutes..."

[Execute setup automatically]

You: "✅ Setup complete! I've initialized all repositories and installed dependencies. You can now ask me to start any development server, or just tell me what you want to work on."
```

### When Designer Asks to Work on Something
```
Designer: "I want to work on Calypso"

You: "Starting Calypso development server for you..."

[Run ./skills/dev-servers/scripts/start.sh calypso in background, open browser]

You: "✅ Calypso is running at http://calypso.localhost:3000 (I've opened it in your browser)"
```

### When Setup Fails
```
You: "I encountered an issue during setup: [specific error]. Let me try to fix this..."

[Attempt automatic recovery]

You: "✅ Fixed! Setup is now complete."
```

---

## Response Pattern

### Starting Setup

```
I'll set up the Design Kit environment for you. This will:
- Clone all repositories (Calypso, Gutenberg, WordPress Core, Jetpack)
- Install dependencies for each repository
- Take about 5-10 minutes

Note: CIAB is optional and requires Automattic access. It will be skipped if you don't have access.

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
✅ @wordpress/env: installed
⚠️ Docker: not running (optional - only needed for Telex)

All required tools are available. Starting setup...
```

### During Setup

Provide updates as each step completes:

```
📦 Cloning repositories... ✅
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

---

## Common Issues

### Repository Authentication
If repositories fail to clone, check your network connection and GitHub access. For CIAB, ensure your SSH key is configured for github.a8c.com.

### Disk Space
Full setup requires ~10GB. Check with `df -h` if installs fail.

### Network Issues
Large downloads may timeout. Retry usually works.

### Permission Issues
If npm/pnpm fail with EACCES, suggest using a Node version manager (nvm, fnm).

---

## Manual Alternative

If the script fails, these are the manual steps:

```bash
# 1. Clone repositories
./skills/setup/scripts/repos.sh clone

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

---

## Key Files to Read for Context

1. **`README.md`** - Project overview and quick start
2. **`dk.config.json`** - Repository configuration and dev server info
3. **`skills/setup/scripts/setup.sh`** - Setup script logic
4. **`skills/dev-servers/scripts/start.sh`** - Dev server launcher
5. **`.gitmodules`** - Submodule definitions

## Important Rules

1. **Never ask the designer to run terminal commands** - You execute everything
2. **Always check before acting** - Verify current state before making changes
3. **Provide clear feedback** - Tell the designer what you're doing and why
4. **Handle errors gracefully** - Attempt recovery, explain issues clearly
5. **Be proactive** - Don't wait for the designer to ask, set up automatically on first open

---

## Example: Complete First-Time Setup

```
[Designer opens project in Cursor]

AI: "Welcome to Design Kit! I can see this is a fresh project. Let me set everything up for you automatically. This will:
- Clone 4 git submodules (Calypso, Gutenberg, WordPress Core, CIAB)
- Install dependencies for each repository
- Take about 5-10 minutes

I'll keep you updated as I go..."

[AI executes git submodule update --init --depth 1]

AI: "✅ Submodules initialized"

[AI executes yarn install in repos/calypso]

AI: "✅ Calypso dependencies installed"

[AI executes npm ci in repos/gutenberg]

AI: "✅ Gutenberg dependencies installed"

[AI executes npm ci in repos/wordpress-core]

AI: "✅ WordPress Core dependencies installed"

[AI executes pnpm install and composer install in repos/ciab]

AI: "✅ CIAB dependencies installed"

AI: "🎉 Setup complete! All repositories are ready. You can now:
- Ask me to start any development server
- Tell me what you want to work on
- Ask me to show you the project structure

What would you like to do first?"
```
