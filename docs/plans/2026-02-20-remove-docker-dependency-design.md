# Remove Docker Dependency — Design Document

**Date:** 2026-02-20
**Status:** Approved
**Approach:** Full migration to `@wordpress/env` + Playground runtime

## Problem

dk requires Docker Desktop for WordPress Core, Jetpack, and CIAB development. This creates three pain points:

1. **Onboarding friction** — Designers must install and configure Docker Desktop before doing any WordPress work
2. **Resource waste** — Docker Desktop consumes 4-8 GB RAM just idling, competing with memory-hungry tools like Calypso
3. **Fragile dependency** — Docker breaks across OS updates, requires its own maintenance, and adds cognitive overhead

## Solution

Replace Docker-based WordPress environments with `@wordpress/env` using the `--runtime=playground` flag. This runs WordPress entirely in WebAssembly via Node.js — no Docker, no MySQL, no containers.

### What the Playground runtime provides

- Full WordPress environment in ~5 seconds (vs ~30s with Docker)
- SQLite database (99% compatible with WordPress unit tests via new MySQL-to-SQLite AST parser)
- Xdebug support
- phpMyAdmin access
- Multisite support
- Plugin/theme mounting
- Custom PHP versions

### What it doesn't provide (and why that's fine for designers)

- `wp-env run` (arbitrary shell commands) — designers don't need this
- SPX profiling — not a design workflow
- MySQL — SQLite handles everything needed for UI/UX work
- SSH access — not needed locally

## Architecture

### WordPress Core

**Before:** Custom `docker-compose.yml` (nginx + PHP-FPM + MySQL) with `npm run env:*` scripts.

**After:** `@wordpress/env` with `.wp-env.json`:

```json
{
  "core": ".",
  "plugins": [],
  "themes": [],
  "port": 8889,
  "testsPort": 8890
}
```

**Command mapping:**

| Old (docker-compose) | New (wp-env) |
|---|---|
| `npm run env:start` | `wp-env start --runtime=playground` |
| `npm run env:stop` | `wp-env stop` |
| `npm run env:restart` | `wp-env stop && wp-env start` |
| `npm run env:clean` | `wp-env destroy` |
| `npm run env:install` | Automatic on start |

### Jetpack

**Before:** Volume mount in `docker-compose.yml` + manual symlink creation via `docker compose exec`.

**After:** Plugin path in `.wp-env.json`:

```json
{
  "core": ".",
  "plugins": [
    "../jetpack/projects/plugins/jetpack"
  ],
  "port": 8889
}
```

No symlinks, no `docker compose exec`. wp-env handles mounting automatically in both runtimes.

### CIAB

Same pattern — migrate to wp-env + Playground. Needs investigation for Automattic-internal specifics.

### Telex (Exception)

Telex uses Docker for MinIO (S3 storage) and block builder containers — unrelated to WordPress. It remains the **only** Docker dependency, documented as opt-in for the few who need it.

### Codespaces / Devcontainer

**Remove:** `docker-in-docker` feature from `.devcontainer/devcontainer.json`

**Add:** `postCreateCommand` to install `@wordpress/env` globally

**Resource reduction:**
- Minimum: 2 CPUs, 8 GB RAM (was 4 CPUs, 16 GB)
- Recommended: 4 CPUs, 16 GB RAM (was 8 CPUs, 32 GB)

## Script Changes

### `skills/dev-servers/scripts/start.sh`

- Replace `check_docker()` with `check_wp_env()` — installs `@wordpress/env` if missing
- `start_core()` — Uses `wp-env start --runtime=playground`
- `start_jetpack()` — Simplified to just ensure wp-env is started with Jetpack in `.wp-env.json`
- `start_ciab()` — Same wp-env pattern
- `check_docker()` — Kept only for `start_telex()`

### `dk.config.json`

- Remove docker-compose volume mount references
- Add wp-env configuration paths
- Keep Docker config only under Telex

## Skill Documentation Updates

| Skill | Changes |
|---|---|
| `skills/wordpress-core/SKILL.md` | Replace `env:*` commands with wp-env. Remove Docker prerequisite. |
| `skills/jetpack/SKILL.md` | Update mounting docs. Remove docker-compose references. |
| `skills/dev-servers/SKILL.md` | Update startup docs. Docker only for Telex. |
| `skills/setup/SKILL.md` | Remove Docker from prerequisites (except Telex). Add `@wordpress/env`. |
| `skills/telex/SKILL.md` | Document as the Docker exception. |

## Escape Hatches

1. **Need MySQL?** → `wp-env start --runtime=docker` (requires Docker)
2. **Need `wp-env run`?** → Switch to Docker runtime
3. **Need Telex?** → Docker required, documented separately
4. **Playground broken?** → `wp-env destroy && wp-env start --runtime=docker`

## What Stays the Same

- Calypso: already Docker-free
- Gutenberg: already Docker-free
- Port assignments in `dk.config.json`
- Two-tier git structure (dk-1 meta-repo + sub-repos)

## Sources

- [wp-env now runs WordPress with Playground runtime](https://make.wordpress.org/playground/2026/02/06/wp-env-now-runs-wordpress-with-playground-runtime/) (Feb 6, 2026)
- [@wordpress/env documentation](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/)
- [New SQLite driver for WordPress](https://make.wordpress.org/playground/2025/06/13/introducing-a-new-sqlite-driver-for-wordpress/) (Jun 13, 2025)
- [WordPress Playground limitations](https://wordpress.github.io/wordpress-playground/developers/limitations/)
