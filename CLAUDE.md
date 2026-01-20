# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Design Kit (dk) is a unified workspace for designers at Automattic to work across the WordPress ecosystem with AI assistance. It manages multiple WordPress-related repositories (Calypso, Gutenberg, WordPress Core, Jetpack, CIAB, Telex) in a single development environment.

**Critical concept**: This is NOT a monorepo. It's a meta-repository that orchestrates multiple independent Git repositories under `repos/`. Each sub-repository has its own .git directory, branches, and remotes.

## Repository Architecture

### Two-Tier Git Structure

1. **dk-1 (This Repository)** - Meta-repository for workspace configuration
   - **Purpose**: AI rules, setup scripts, documentation, configuration
   - **Location**: Root directory
   - **Default branch**: `main`
   - **Contains**: `.cursor/rules/`, `bin/`, `docs/`, `dk.config.json`
   - **Branch naming**: `update/feature-name`, `add/feature-name`, `fix/issue-name`
   - **NEVER use sub-repo names in dk-1 branch names** (e.g., ❌ `feature/telex-*`)

2. **Sub-Repositories** - Actual code repositories under `repos/`
   - **calypso** - WordPress.com dashboard (React/TypeScript, Node 22, yarn)
   - **gutenberg** - Block Editor & `@wordpress/components` (Node 20, npm)
   - **wordpress-core** - WordPress Core software (PHP/Node 20, npm)
   - **jetpack** - Jetpack plugin (PHP/TypeScript, Node 22, pnpm)
   - **ciab** - Commerce in a Box admin (React/TypeScript, Node 22, pnpm, requires Automattic access)
   - **telex** - AI block authoring tool (React/PHP, Node 22, pnpm, requires Automattic access)

Each sub-repo has its own `CLAUDE.md` or `AGENTS.md` with repo-specific guidance.

### Critical Git Rule

Before creating branches or committing:
```bash
# Always verify which repository you're in
./bin/which-repo.sh

# Check status of all repositories
./bin/repos.sh status
```

**Common mistake**: Creating `feature/telex-thinking-mode` in dk-1 when you meant to work on Telex code.

## Essential Commands

### Setup and Environment Management

```bash
# Initial setup (clone repos, install dependencies, build)
./bin/setup.sh

# Clone repositories selectively
./bin/repos.sh clone                    # Public repos only
./bin/repos.sh clone --include-private  # Include CIAB + Telex
./bin/repos.sh clone-ciab               # Just CIAB
./bin/repos.sh clone-telex              # Just Telex

# Update all repositories
./bin/repos.sh update

# Check status of all repos
./bin/repos.sh status
./bin/status.sh

# Reset repos to latest
./bin/reset.sh           # Pull latest
./bin/reset.sh --full    # Pull + reinstall dependencies
```

### Development Servers

```bash
# Start development servers
./bin/start.sh calypso     # → http://calypso.localhost:3000
./bin/start.sh gutenberg   # → http://localhost:9999
./bin/start.sh storybook   # → http://localhost:50240 (Gutenberg components)
./bin/start.sh core        # → http://localhost:8889
./bin/start.sh jetpack     # → http://localhost:8889 (runs in WP Core)
./bin/start.sh ciab        # → http://localhost:9001/wp-admin/

# Telex (requires special setup - see repos/telex/CLAUDE.md)
cd repos/telex
pnpm run minio:start  # Required first
pnpm run dev          # → http://localhost:3000
```

### Per-Repository Commands

Before running commands in a sub-repo, **always switch to the correct Node version**:

```bash
# Calypso (Node 22)
cd repos/calypso && source ~/.nvm/nvm.sh && nvm use
yarn install
yarn start:debug

# Gutenberg (Node 20)
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build      # Required before dev/storybook
npm run dev        # Dev site
npm run storybook  # Component library

# WordPress Core (Node 20)
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build
npm run dev

# Jetpack (Node 22)
cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
pnpm jetpack build plugins/jetpack --deps
pnpm jetpack watch plugins/jetpack  # During development

# CIAB (Node 22)
cd repos/ciab && source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
pnpm dev

# Telex (Node 22)
cd repos/telex && source ~/.nvm/nvm.sh && nvm use
pnpm install
# See repos/telex/CLAUDE.md for complete setup
```

## Cross-Repository Workflows

### How Repositories Connect

```
Calypso ←──(npm packages)──── Gutenberg
   │                              │
   │                     (syncs to Core)
   │                              ↓
   └───────(REST API)──────→ WordPress Core
                                  ↑
                              (plugin)
                                  │
                             Jetpack

Telex → generates blocks → WordPress Playground preview
```

**Key integration points**:
- **Gutenberg → Calypso**: npm packages (`@wordpress/components`, `@wordpress/icons`, `@wordpress/data`)
- **Calypso → WordPress Core**: REST API (`/wp/v2/*` endpoints)
- **Gutenberg → WordPress Core**: Blocks sync during release process
- **Jetpack → WordPress Core**: Plugin running in Core environment
- **CIAB → WordPress Core**: React SPA replacement for wp-admin via REST API
- **Telex → Gutenberg**: Generates blocks following Gutenberg block API patterns

### Node Version Management (CRITICAL)

Each repository requires a **different Node version**. The versions are:

| Repository | Node Version | Package Manager |
|------------|--------------|-----------------|
| Calypso | 22.9.0 | yarn |
| Gutenberg | 20 | npm |
| WordPress Core | 20 | npm |
| Jetpack | 22.19.0 | pnpm |
| CIAB | 22 | pnpm |
| Telex | 22 | pnpm |

**Always use nvm** before running commands:
```bash
cd repos/[repo-name]
source ~/.nvm/nvm.sh && nvm use
```

The setup scripts handle this automatically, but manual operations require explicit switching.

### wp-env Conflict Prevention

**CRITICAL**: When both `repos/wordpress-core` and `repos/gutenberg` exist, **ONLY use wordpress-core's wp-env**.

- ✅ `cd repos/wordpress-core && npm run dev`
- ❌ `cd repos/gutenberg && npm run dev` (when wordpress-core exists)
- ✅ `cd repos/gutenberg && npm run storybook` (for components)

Both use the same Docker ports and will conflict if run simultaneously.

## Configuration Files

### dk.config.json
Central configuration defining:
- Repository paths and metadata
- Node versions and package managers
- Dev server commands and ports
- Cross-repo connections
- Component library locations
- Tech stacks for each repo

### .cursor/rules/
AI-specific rules for working in this environment:

- **base.mdc** - Core AI persona (design-first, simplifier, navigator)
- **setup.mdc** - AI-driven setup protocol
- **cross-repo.mdc** - Cross-repository workflows
- **calypso.mdc** - Calypso-specific context (Legacy vs Dashboard interfaces)
- **gutenberg.mdc** - Gutenberg and `@wordpress/components` context
- **wordpress-core.mdc** - WordPress Core structure and PHP conventions
- **jetpack.mdc** - Jetpack monorepo architecture
- **ciab.mdc** - CIAB admin SPA patterns
- **telex.mdc** - Telex AI block authoring architecture

**Important**: Always check relevant rule files when working in specific repos.

## Design Principles

### For AI Assistants Working in This Repo

1. **Design-First Language**: Accept natural descriptions ("a settings page with a toggle") rather than technical specs
2. **Component Reuse**: Always search `@wordpress/components` before creating new UI components
3. **Cross-Repo Awareness**: Features often span multiple repositories (e.g., REST endpoint in Core + UI in Calypso)
4. **Simplify Technical Complexity**: Abstract build systems, state management internals unless explicitly needed
5. **Repository Context Switching**: Always verify which repository you're working in before making changes

### Calypso-Specific Critical Note

Calypso has **TWO separate interfaces** with different codebases:

| Interface | URL | Code Location | Stack |
|-----------|-----|---------------|-------|
| **Legacy Calypso** | `calypso.localhost:3000` | `client/blocks/`, `client/components/`, `client/my-sites/` | Redux, i18n-calypso, SCSS |
| **New Dashboard** | `my.localhost:3000` | `client/dashboard/` | TanStack Query, @wordpress/i18n, minimal CSS |

Changes to one do NOT affect the other. Always clarify which interface when working on Calypso.

## Special Setup Requirements

### Jetpack in WordPress Core

Jetpack runs within WordPress Core via Docker volume mount. The setup script creates a mu-plugin (`src/wp-content/mu-plugins/jetpack-monorepo-fix.php`) to fix `plugins_url()` for Jetpack packages in the monorepo development environment.

### Telex Prerequisites

Telex requires additional setup beyond standard repos:

1. **Docker** - Required for MinIO (S3 storage) and block builds
2. **MinIO** - S3-compatible storage for artefacts
3. **WordPress.com OAuth credentials** - For authentication
4. **Anthropic API key** - For AI block generation

See `repos/telex/CLAUDE.md` for complete setup instructions.

## Repository Branch Conventions

| Repository | Default Branch | Naming Convention |
|------------|----------------|-------------------|
| dk-1 | `main` | `update/`, `add/`, `fix/`, `try/` |
| Calypso | `trunk` | `add/`, `update/`, `fix/`, `try/` |
| Gutenberg | `trunk` | Follow WordPress conventions |
| WordPress Core | `trunk` | Follow WordPress conventions |
| Jetpack | `trunk` | Follow Automattic conventions |
| CIAB | `trunk` | Follow Automattic conventions |
| Telex | `main` | `feature/`, `fix/`, `update/` |

## Common Development Patterns

### Finding Components

1. **First**: Check `@wordpress/components` (Gutenberg) - this is the canonical UI library
2. **Then**: Check repo-specific components (e.g., `calypso/client/components/`)
3. **Finally**: Create new components only if nothing exists

### Working Across Repositories

Example: Adding a settings page in Calypso that saves to WordPress

1. **WordPress Core** (`repos/wordpress-core`):
   - Ensure REST endpoint exists or create custom endpoint
   - Located in `src/wp-includes/rest-api/endpoints/`

2. **Calypso** (`repos/calypso`):
   - Create settings page UI in `client/my-sites/` or `client/dashboard/`
   - Use `@wordpress/components` for form elements
   - Call WordPress REST API to save: `apiFetch({ path: '/wp/v2/settings', method: 'POST', data })`

### Checking Repository Context

```bash
# Get current repository info
./bin/which-repo.sh

# Shows:
# - Which repository you're in (dk-1 or a sub-repo)
# - Current branch
# - Git status
# - Available commands for that repo
```

## Prerequisites for Development

### Required Tools

- **Git** - Version control
- **nvm** - Node version management (CRITICAL - repos need different Node versions)
- **Yarn** - For Calypso
- **npm** - Comes with Node.js
- **pnpm** - For Jetpack, CIAB, Telex (`npm install -g pnpm`)
- **Composer** - For PHP dependencies in CIAB/Jetpack
- **Docker Desktop** - Optional, required for WordPress Core/CIAB/Jetpack/Telex

### Installing nvm

If nvm is not installed:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.nvm/nvm.sh

# Install required Node versions
nvm install 20
nvm install 22
```

## Key Files to Reference

- `README.md` - User-facing overview and quick start
- `dk.config.json` - Central configuration for all repositories
- `docs/repo-map.md` - Detailed visual guide to how repositories connect
- `docs/getting-started.md` - Detailed setup instructions
- `.cursor/rules/*.mdc` - AI-specific guidance for each repository
- `bin/*.sh` - Automation scripts for common tasks

## Troubleshooting

### "nvm not found"
Install nvm (see Prerequisites section). The setup scripts will warn but continue without it.

### "Docker is not installed"
Required for WordPress Core, CIAB, Jetpack, and Telex. Calypso, Gutenberg, and Storybook work without Docker.

### Port Conflicts
Each dev server uses specific ports. If you get "port already in use":
- Stop conflicting servers
- Check which servers are running with `lsof -ti:3000,8889,9999` etc.

### Wrong Node Version
Always run `source ~/.nvm/nvm.sh && nvm use` when switching between repositories.

### wp-env Conflicts
Only run ONE wp-env instance. If both Gutenberg and WordPress Core exist, use WordPress Core's wp-env.

### "Jetpack assets not loading"
Ensure the mu-plugin exists: `repos/wordpress-core/src/wp-content/mu-plugins/jetpack-monorepo-fix.php`
Run `./bin/setup.sh` to create it automatically.

### Repeated SSH Key Requests

If you're getting frequent SSH key request notifications from macOS, it's likely caused by VSCode/Cursor's automatic git repository monitoring.

**Cause**: The `.vscode/settings.json` configures VSCode to scan 6 repositories (`git.scanRepositories`), and periodically checks their remote status. Each check triggers an SSH connection, prompting for your SSH key.

**Solution**: Configure SSH to cache your key in the macOS keychain. Add to `~/.ssh/config`:

```
# Global settings for all hosts - cache SSH keys in macOS keychain
Host *
  AddKeysToAgent yes
  UseKeychain yes
```

This caches your SSH key so you won't be prompted repeatedly. The next time you authenticate via SSH, your key will be added to the keychain automatically.

**Alternative Solutions**:
- Disable auto-fetch in VSCode: Add `"git.autofetch": false` to `.vscode/settings.json`
- Reduce repository scanning: Remove repos from `git.scanRepositories` that don't need monitoring
