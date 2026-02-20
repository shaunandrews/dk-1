# Remove Docker Dependency Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace Docker-based WordPress environments with `@wordpress/env --runtime=playground` so designers only need Node.js installed.

**Architecture:** Migrate WordPress Core from its custom docker-compose setup to `@wordpress/env`. Default to `--runtime=playground` (WebAssembly, SQLite, no Docker). Jetpack plugin mounting moves to `.wp-env.json` config. Telex remains the sole Docker exception.

**Tech Stack:** `@wordpress/env`, WordPress Playground runtime, Node.js, bash

---

### Task 1: Install `@wordpress/env` and create `.wp-env.json` for WordPress Core

**Files:**
- Create: `repos/wordpress-core/.wp-env.json`

**Step 1: Install `@wordpress/env` globally**

```bash
npm install -g @wordpress/env
```

Verify:
```bash
wp-env --version
```
Expected: Version number printed (e.g., `10.x.x`)

**Step 2: Create `.wp-env.json` in WordPress Core**

Create `repos/wordpress-core/.wp-env.json`:
```json
{
	"core": ".",
	"plugins": [],
	"themes": [],
	"port": 8889,
	"testsPort": 8890,
	"config": {
		"WP_DEBUG": true,
		"SCRIPT_DEBUG": true
	}
}
```

**Step 3: Test that wp-env starts with Playground runtime**

```bash
cd repos/wordpress-core
wp-env start --runtime=playground
```

Expected: WordPress starts at http://localhost:8889. Verify by curling:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8889
```
Expected: `200` or `302` (redirect to install/login)

**Step 4: Stop the environment**

```bash
cd repos/wordpress-core
wp-env stop
```

**Step 5: Commit**

```bash
git -C repos/wordpress-core add .wp-env.json
git -C repos/wordpress-core commit -m "Add .wp-env.json for Playground runtime support"
```

---

### Task 2: Create `.wp-env.json` for Jetpack (WordPress Core + Jetpack plugin)

**Files:**
- Create: `configs/wp-env-jetpack.json`

This is a separate wp-env config that includes Jetpack as a mounted plugin. It lives in dk-1 (not in the sub-repos) because it references paths across repos.

**Step 1: Create the Jetpack wp-env config**

Create `configs/wp-env-jetpack.json`:
```json
{
	"core": "./repos/wordpress-core",
	"plugins": [
		"./repos/jetpack/projects/plugins/jetpack"
	],
	"themes": [],
	"port": 8889,
	"testsPort": 8890,
	"config": {
		"WP_DEBUG": true,
		"SCRIPT_DEBUG": true
	}
}
```

**Step 2: Test Jetpack mounting with wp-env**

```bash
cd /Users/shaun/Developer/Projects/dk-1
WP_ENV_HOME=. wp-env start --config configs/wp-env-jetpack.json --runtime=playground
```

If `--config` flag is not supported, use the `WP_ENV_CONFIG` environment variable or symlink approach. Alternative: create a temporary `.wp-env.json` at dk-1 root:

```bash
cd /Users/shaun/Developer/Projects/dk-1
# Test with a temporary .wp-env.json at root
cat > .wp-env.json << 'EOF'
{
	"core": "./repos/wordpress-core",
	"plugins": [
		"./repos/jetpack/projects/plugins/jetpack"
	],
	"port": 8889,
	"config": {
		"WP_DEBUG": true,
		"SCRIPT_DEBUG": true
	}
}
EOF
wp-env start --runtime=playground
```

Verify Jetpack appears in the plugin list by visiting http://localhost:8889/wp-admin/plugins.php

**Step 3: Clean up and stop**

```bash
wp-env stop
```

**Step 4: Commit**

```bash
mkdir -p configs
git add configs/wp-env-jetpack.json
git commit -m "Add wp-env config for Jetpack development"
```

---

### Task 3: Rewrite `start.sh` — replace Docker with wp-env

**Files:**
- Modify: `skills/dev-servers/scripts/start.sh`

**Step 1: Replace `check_docker()` with `check_wp_env()`**

Replace lines 34-56 of `skills/dev-servers/scripts/start.sh`:

Old:
```bash
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed."
        ...
    fi
    if ! docker info &> /dev/null; then
        echo "❌ Docker is installed but not running."
        ...
    fi
}
```

New:
```bash
check_wp_env() {
    if ! command -v wp-env &> /dev/null; then
        echo "⚠️  wp-env not found. Installing @wordpress/env..."
        npm install -g @wordpress/env
        if ! command -v wp-env &> /dev/null; then
            echo "❌ Failed to install @wordpress/env."
            echo ""
            echo "   Install it manually:"
            echo "   npm install -g @wordpress/env"
            exit 1
        fi
        echo "   ✅ @wordpress/env installed."
    fi
}

check_docker() {
    # Only used for Telex now
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed."
        echo ""
        echo "   Telex requires Docker Desktop for MinIO and block builder."
        echo ""
        echo "   Download Docker Desktop:"
        echo "   • Mac: https://docs.docker.com/desktop/setup/install/mac-install/"
        echo "   • Windows: https://docs.docker.com/desktop/setup/install/windows-install/"
        echo "   • Linux: https://docs.docker.com/desktop/setup/install/linux/"
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo "❌ Docker is installed but not running."
        echo ""
        echo "   Please start Docker Desktop and try again."
        exit 1
    fi
}
```

**Step 2: Rewrite `start_core()`**

Replace lines 117-128:

```bash
start_core() {
    check_wp_env
    echo "🚀 Starting WordPress Core (Playground runtime)..."
    cd "$DK_ROOT/repos/wordpress-core"
    switch_node_version "$DK_ROOT/repos/wordpress-core"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:8889"
    echo "   Runtime: WordPress Playground (no Docker required)"
    echo "   Database: SQLite"
    exec wp-env start --runtime=playground
}
```

**Step 3: Rewrite `start_jetpack()`**

Replace lines 144-201. The new version is much simpler — no symlinks, no `docker compose exec`:

```bash
start_jetpack() {
    check_wp_env
    echo "🚀 Starting Jetpack development environment..."

    # Check Jetpack dependencies
    cd "$DK_ROOT/repos/jetpack"
    switch_node_version "$DK_ROOT/repos/jetpack"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi

    # Check if Jetpack was built
    if [ ! -d "projects/plugins/jetpack/_inc/build" ]; then
        echo "⚠️  Jetpack not built. Building now..."
        pnpm jetpack build plugins/jetpack --deps
    fi

    # Use the dk-1 root wp-env config that includes Jetpack
    cd "$DK_ROOT"

    echo ""
    echo "   Jetpack runs within the WordPress Core environment."
    echo "   Starting via wp-env with Playground runtime..."
    echo ""
    echo "   URL: http://localhost:8889"
    echo "   Runtime: WordPress Playground (no Docker required)"
    echo ""

    # Copy the Jetpack wp-env config to root (wp-env reads .wp-env.json from cwd)
    cp "$DK_ROOT/configs/wp-env-jetpack.json" "$DK_ROOT/.wp-env.json"
    exec wp-env start --runtime=playground
}
```

**Step 4: Update `start_ciab()`**

Replace lines 130-142. CIAB follows the same pattern:

```bash
start_ciab() {
    check_wp_env
    echo "🚀 Starting CIAB (Node 22)..."
    cd "$DK_ROOT/repos/ciab"
    switch_node_version "$DK_ROOT/repos/ciab"
    if [ ! -d "node_modules" ]; then
        echo "⚠️  Dependencies not installed. Run $DK_ROOT/skills/setup/scripts/setup.sh first."
        exit 1
    fi
    echo "   URL: http://localhost:9001/wp-admin/"
    echo "   Runtime: WordPress Playground (no Docker required)"
    exec pnpm dev
}
```

Note: CIAB's `pnpm dev` may internally use its own wp-env or Docker setup. This needs investigation during implementation. If CIAB manages its own environment, we may need to configure it separately.

**Step 5: Update `show_help()`**

Update the help text to remove Docker references. Change:
```
  core       - WordPress Core dev site (http://localhost:8889)
```
To:
```
  core       - WordPress Core dev site (http://localhost:8889) [no Docker needed]
```

And similarly for jetpack.

**Step 6: Test each start command**

```bash
./skills/dev-servers/scripts/start.sh core
# Verify: WordPress starts at http://localhost:8889 without Docker

./skills/dev-servers/scripts/start.sh jetpack
# Verify: WordPress starts with Jetpack plugin visible at http://localhost:8889/wp-admin/plugins.php
```

**Step 7: Commit**

```bash
git add skills/dev-servers/scripts/start.sh
git commit -m "Replace Docker with wp-env Playground runtime in start scripts"
```

---

### Task 4: Update `dk.config.json`

**Files:**
- Modify: `dk.config.json`

**Step 1: Update wordpress-core stack info**

Change line 88 from:
```json
"database": "MySQL"
```
To:
```json
"database": "SQLite (Playground runtime)"
```

**Step 2: Update jetpack-core connection**

Change lines 231-232 from:
```json
"integration": "Symlinked into wp-content/plugins via docker-compose volume mount",
"mountPath": "../jetpack/projects/plugins/jetpack:/var/www/src/wp-content/plugins/jetpack"
```
To:
```json
"integration": "Mounted via .wp-env.json plugin path (no Docker required)",
"wpEnvConfig": "configs/wp-env-jetpack.json"
```

**Step 3: Commit**

```bash
git add dk.config.json
git commit -m "Update config to reflect wp-env Playground migration"
```

---

### Task 5: Update `skills/setup/SKILL.md` — remove Docker prerequisite

**Files:**
- Modify: `skills/setup/SKILL.md`

**Step 1: Update prerequisites list (line 52)**

Change:
```
- **Docker** - Optional, required for WordPress Core/CIAB/Jetpack environments (check with `docker --version`)
```
To:
```
- **@wordpress/env** - Required for WordPress Core/Jetpack environments (install with `npm install -g @wordpress/env`)
- **Docker** - Optional, only required for Telex (MinIO/block builder) (check with `docker --version`)
```

**Step 2: Update prerequisites check commands (lines 63-67)**

Change:
```bash
# Optional (for WP Core/CIAB/Jetpack)
docker --version
```
To:
```bash
# Required (for WP Core/Jetpack)
wp-env --version

# Optional (for Telex only)
docker --version
```

**Step 3: Update Docker-missing messaging (lines 121-124)**

Change:
```
If Docker is missing, inform the designer that Calypso, Gutenberg, and Storybook will work fine, but WordPress Core, CIAB, and Jetpack local environments require Docker Desktop to be installed.
```
To:
```
If Docker is missing, inform the designer that all repos work without Docker except Telex (which needs Docker for MinIO and block builder). WordPress Core, Jetpack, and CIAB use wp-env with Playground runtime — no Docker needed.
```

**Step 4: Commit**

```bash
git add skills/setup/SKILL.md
git commit -m "Update setup skill: wp-env replaces Docker for WP environments"
```

---

### Task 6: Update `skills/dev-servers/SKILL.md`

**Files:**
- Modify: `skills/dev-servers/SKILL.md`

**Step 1: Update the server table (lines 18-27)**

Change the "Requires Docker" column:

| Repo | Command | URL | Requires Docker |
|------|---------|-----|-----------------|
| Calypso | `./skills/dev-servers/scripts/start.sh calypso` | http://calypso.localhost:3000 | No |
| Gutenberg | `./skills/dev-servers/scripts/start.sh gutenberg` | http://localhost:9999 | No |
| Storybook | `./skills/dev-servers/scripts/start.sh storybook` | http://localhost:50240 | No |
| WordPress Core | `./skills/dev-servers/scripts/start.sh core` | http://localhost:8889 | **No** (uses wp-env Playground) |
| CIAB | `./skills/dev-servers/scripts/start.sh ciab` | http://localhost:9001/wp-admin/ | **No** (uses wp-env Playground) |
| Jetpack | `./skills/dev-servers/scripts/start.sh jetpack` | http://localhost:8889 | **No** (uses wp-env Playground) |
| Telex | `cd repos/telex && pnpm dev` | http://localhost:3000 (app), :8000 (API), :4000 (admin) | **Yes** |

**Step 2: Update Docker prerequisite check (lines 60-69)**

Replace the Docker check section with wp-env check:

```
For WordPress-powered repos (core, jetpack), check wp-env:
```bash
wp-env --version
```

If wp-env isn't installed:
```
@wordpress/env is not installed. Installing now...
npm install -g @wordpress/env
```

For Telex only, check Docker:
```bash
docker info
```
```

**Step 3: Update "Starting WordPress Core" response pattern (lines 139-150)**

Change:
```
🚀 Starting WordPress Core development environment...

This uses Docker to run a full WordPress installation.
It will be ready at http://localhost:8889
```

To:
```
🚀 Starting WordPress Core development environment...

This uses wp-env with WordPress Playground (no Docker required).
It will be ready at http://localhost:8889

Default credentials:
- Username: admin
- Password: password
```

**Step 4: Update "Starting Jetpack" response pattern (lines 153-161)**

Change:
```
🚀 Starting Jetpack development environment...

This runs WordPress Core with the Jetpack plugin activated.
It will be ready at http://localhost:8889

I'm also setting up the Jetpack symlink so your changes will be reflected live.
```

To:
```
🚀 Starting Jetpack development environment...

This runs WordPress Core with Jetpack mounted via wp-env (no Docker, no symlinks).
It will be ready at http://localhost:8889

Jetpack is automatically mounted as a plugin — no manual setup needed.
```

**Step 5: Replace "Docker Not Running" section (lines 202-216)**

Change to cover both wp-env and Docker (Telex only):

```
### wp-env Not Installed

```
⚠️ @wordpress/env is not installed.

Let me install it for you...
npm install -g @wordpress/env
```

### Docker Not Running (Telex Only)

```
⚠️ Telex requires Docker Desktop for MinIO (S3 storage) and the block builder.

Please:
1. Open Docker Desktop
2. Wait for it to start
3. Tell me when it's ready

Note: All other repos (Calypso, Gutenberg, WP Core, Jetpack) work without Docker!
```
```

**Step 6: Commit**

```bash
git add skills/dev-servers/SKILL.md
git commit -m "Update dev-servers skill: Docker no longer required for WP environments"
```

---

### Task 7: Update `skills/wordpress-core/SKILL.md`

**Files:**
- Modify: `skills/wordpress-core/SKILL.md`

**Step 1: Update Quick Reference table (line 18)**

Change:
```
| **Database** | MySQL |
| **Dev Server** | `npm run dev` → http://localhost:8889 |
```
To:
```
| **Database** | SQLite (via Playground runtime) |
| **Dev Server** | `wp-env start --runtime=playground` → http://localhost:8889 |
```

**Step 2: Update "Dev Commands" section (lines 316-334)**

Change:
```
**This is the PRIMARY wp-env.** When both wordpress-core and gutenberg repos exist, always use this environment. Never start gutenberg's wp-env simultaneously.

```bash
cd repos/wordpress-core

# Start development environment
npm run dev
```
```

To:
```
**This is the PRIMARY wp-env.** When both wordpress-core and gutenberg repos exist, always use this environment. Never start gutenberg's wp-env simultaneously.

```bash
cd repos/wordpress-core

# Start development environment (no Docker required)
wp-env start --runtime=playground

# Stop environment
wp-env stop

# Destroy and start fresh
wp-env destroy
```

**Escape hatch:** If you need MySQL or `wp-env run` for advanced work:
```bash
wp-env start --runtime=docker  # Requires Docker Desktop
```
```

**Step 3: Replace "Environment Commands" section (lines 336-356)**

Change:
```
The local dev environment runs via Docker. All `env:*` scripts are in `package.json`:

```bash
npm run env:start       # Start Docker containers + composer update
npm run env:stop        # Stop containers
...
```
```

To:
```
The local dev environment runs via wp-env with WordPress Playground (no Docker required):

```bash
cd repos/wordpress-core

wp-env start --runtime=playground   # Start WordPress (SQLite, no Docker)
wp-env stop                         # Stop the environment
wp-env destroy                      # Remove environment completely
```

The old Docker-based `npm run env:*` commands still exist in the repo but are no longer used by dk. Use `wp-env` commands instead.
```

**Step 4: Update "Environment Configuration" section (lines 358-374)**

Replace the `.env` table with wp-env config reference:

```
### Environment Configuration (.wp-env.json)

The environment is configured via `.wp-env.json` at the repo root:

```json
{
	"core": ".",
	"plugins": [],
	"themes": [],
	"port": 8889,
	"testsPort": 8890,
	"config": {
		"WP_DEBUG": true,
		"SCRIPT_DEBUG": true
	}
}
```

To customize, edit `.wp-env.json`. See [@wordpress/env docs](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) for all options.

**Escape hatch for Docker runtime:** Some old `.env` options (like `LOCAL_PHP`, `LOCAL_DB_TYPE`) only apply to the Docker runtime. If you need them, use `wp-env start --runtime=docker`.
```

**Step 5: Commit**

```bash
git add skills/wordpress-core/SKILL.md
git commit -m "Update wordpress-core skill: wp-env Playground replaces Docker"
```

---

### Task 8: Update `skills/jetpack/SKILL.md` — remove Docker references

**Files:**
- Modify: `skills/jetpack/SKILL.md`

**Step 1: Find and update Docker-related sections**

Search for all references to `docker`, `symlink`, `docker-compose`, and `volume mount` in the Jetpack skill file. Replace with wp-env equivalents.

Key changes:
- Any reference to "Jetpack runs inside WordPress Core Docker environment" → "Jetpack is mounted as a plugin via wp-env"
- Any `docker compose exec` commands → removed (wp-env handles mounting automatically)
- Symlink creation instructions → removed (wp-env handles this via `.wp-env.json`)

**Step 2: Commit**

```bash
git add skills/jetpack/SKILL.md
git commit -m "Update jetpack skill: wp-env replaces Docker volume mounts"
```

---

### Task 9: Update `.devcontainer/devcontainer.json` — remove Docker-in-Docker

**Files:**
- Modify: `.devcontainer/devcontainer.json`

**Step 1: Remove Docker-in-Docker feature**

Remove this line:
```json
"ghcr.io/devcontainers/features/docker-in-docker:2": {},
```

**Step 2: Add `@wordpress/env` to postCreateCommand**

Add `@wordpress/env` to the global npm install in the existing `postCreateCommand`. Change:
```json
"postCreateCommand": "bash -c '...npm install -g pnpm yarn @anthropic-ai/claude-code'"
```
To:
```json
"postCreateCommand": "bash -c '...npm install -g pnpm yarn @wordpress/env @anthropic-ai/claude-code'"
```

**Step 3: Reduce resource requirements**

Change:
```json
"hostRequirements": {
    "cpus": 4,
    "memory": "16gb"
}
```
To:
```json
"hostRequirements": {
    "cpus": 2,
    "memory": "8gb"
}
```

**Step 4: Commit**

```bash
git add .devcontainer/devcontainer.json
git commit -m "Remove Docker-in-Docker from devcontainer, add wp-env"
```

---

### Task 10: Add `.wp-env.json` to dk-1 `.gitignore`

**Files:**
- Modify: `.gitignore`

Since the Jetpack start script copies `configs/wp-env-jetpack.json` to `.wp-env.json` at the dk-1 root, we should gitignore the root `.wp-env.json` (it's a runtime artifact, not a committed config).

**Step 1: Add to `.gitignore`**

Add this line:
```
# wp-env runtime config (copied from configs/ by start scripts)
.wp-env.json
```

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "Gitignore root .wp-env.json (runtime artifact from start scripts)"
```

---

### Task 11: End-to-end verification

**Files:** None (testing only)

**Step 1: Verify WordPress Core starts without Docker**

```bash
# Make sure Docker is NOT running (to prove we don't need it)
# On Mac: Quit Docker Desktop

cd repos/wordpress-core
wp-env start --runtime=playground
```

Visit http://localhost:8889 — should see WordPress.

```bash
wp-env stop
```

**Step 2: Verify Jetpack starts without Docker**

```bash
cd /Users/shaun/Developer/Projects/dk-1
cp configs/wp-env-jetpack.json .wp-env.json
wp-env start --runtime=playground
```

Visit http://localhost:8889/wp-admin/plugins.php — Jetpack should appear.

```bash
wp-env stop
```

**Step 3: Verify start.sh works**

```bash
./skills/dev-servers/scripts/start.sh core
# Should start without Docker

./skills/dev-servers/scripts/start.sh jetpack
# Should start with Jetpack mounted, no Docker
```

**Step 4: Verify Calypso/Gutenberg still work (regression check)**

```bash
./skills/dev-servers/scripts/start.sh calypso
# Should be unaffected

./skills/dev-servers/scripts/start.sh gutenberg
# Should be unaffected
```

**Step 5: Final commit (if any fixes needed)**

```bash
git add -A
git commit -m "Fix issues found during end-to-end verification"
```

---

## Summary of All Changes

| File | Action | Purpose |
|------|--------|---------|
| `repos/wordpress-core/.wp-env.json` | Create | wp-env config for WP Core |
| `configs/wp-env-jetpack.json` | Create | wp-env config with Jetpack plugin |
| `skills/dev-servers/scripts/start.sh` | Modify | Replace Docker with wp-env |
| `dk.config.json` | Modify | Update stack/connection info |
| `skills/setup/SKILL.md` | Modify | Remove Docker prerequisite |
| `skills/dev-servers/SKILL.md` | Modify | Update server docs |
| `skills/wordpress-core/SKILL.md` | Modify | Replace env:* with wp-env |
| `skills/jetpack/SKILL.md` | Modify | Remove Docker references |
| `.devcontainer/devcontainer.json` | Modify | Remove Docker-in-Docker |
| `.gitignore` | Modify | Ignore runtime .wp-env.json |
