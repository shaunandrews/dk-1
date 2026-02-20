---
description: Telex-specific development context
globs: ["repos/telex/**/*"]
---

# Telex Development Context

Telex is an AI-powered WordPress Gutenberg block authoring environment. It enables users to create custom blocks through natural language prompts, with live preview via WordPress Playground.

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/telex` |
| **Node Version** | 22 |
| **Package Manager** | pnpm |
| **Client Language** | TypeScript |
| **Server Language** | PHP 8.0+ |
| **Client Framework** | React 19 (Vite) |
| **Styling** | Tailwind CSS |
| **State Management** | Zustand |
| **Routing** | TanStack Router |
| **Dev Server** | `pnpm run dev` |
| **Client Port** | 3000 |
| **Server Port** | 8000 |
| **Admin Port** | 4000 |

## Project Structure

```
repos/telex/
├── client/              # React SPA (Vite, TanStack Router, Tailwind)
│   ├── src/
│   │   ├── components/  # UI components
│   │   ├── routes/      # TanStack Router file-based routes
│   │   ├── hooks/       # Custom React hooks
│   │   ├── contexts/    # React context providers
│   │   ├── stores/      # Zustand stores
│   │   └── lib/         # Utility functions
│   └── packages/        # Internal packages (artefact-utils)
├── server/              # PHP API
│   ├── src/             # PHP source code
│   ├── public/          # Public entry points
│   └── config/          # Configuration templates
├── cli/                 # Node.js CLI tool (Ink for terminal UI)
├── admin/               # WordPress admin plugin
├── spec/                # Artefact specification and schema
├── docker/              # Docker configuration
└── docs/                # Documentation
```

## Core Concepts

### The Artefact System

The **artefact** is central to Telex - it's an XML file containing all block files and assets as a single source of truth:

- **Schema**: Defined in `spec/artefact.xsd`
- **Processing**: JavaScript (`packages/artefact-utils`) and PHP classes
- **Workflow**: Artefact → Extract files → Build → Deploy to WordPress Playground

```
projects/
  $uid/
    $project-slug/
      artefact.xml        # Current version
      versions/           # Version history
      src/                # Extracted files
      build/              # Compiled output
```

### Artefact Types

Telex supports three artefact types, each with its own spec in `spec/`:

- **Block** (`spec/artefact-block.md`) — WordPress Gutenberg block plugin. Contains `src/` with `index.js`, `edit.js`, `block.json`, styles, `save.js`, `render.php`, plus a root plugin file and `package.json`.
- **Plugin** (`spec/artefact-plugin.md`) — Standard WordPress plugin. Contains `includes/`, `admin/`, `public/`, and `assets/` directories following typical plugin conventions.
- **Theme** (`spec/artefact-theme.md`) — WordPress block theme (Full Site Editing). Contains `templates/`, `parts/`, `patterns/`, `styles/`, plus `style.css` and `theme.json`.

The artefact XSD schema (`spec/artefact.xsd`) validates all three types.

### S3-First Storage

Telex uses S3 as the source of truth for all artefacts:

- **S3**: All `artefact.xml` files, versions, and state
- **Local**: Only build artifacts (`src/`, `build/`, logs)
- **MinIO**: Local S3-compatible storage for development

## Development Setup (COMPLETE CHECKLIST)

### Prerequisites

- Docker Desktop (required for MinIO and block builds)
- Composer (required for PHP dependencies)
- pnpm (required for all JS operations)
- WordPress.com OAuth app credentials (for authentication)
- Anthropic API key (for AI block generation)

### Setup Wizard

The interactive setup wizard handles everything automatically:

```bash
pnpm dev:setup
```

This runs `cli/setup.js` which:
1. Checks prerequisites (Node, pnpm, Composer)
2. Runs `pnpm install`
3. Creates `.env` files from templates
4. Prompts for API keys (Anthropic, Google Vertex, WPCOM OAuth)
5. Auto-generates secrets (JWT, APP_SECRET, SHARE_SECRET)
6. Runs `composer install` for server dependencies

For worktrees, use the fast non-interactive mode:

```bash
pnpm dev:setup --worktree --port-offset=100
```

### First-Time Setup (All Steps Required)

Run these commands IN ORDER from `repos/telex`:

```bash
cd repos/telex

# 1. Install all dependencies
pnpm install

# 2. Set up environment files
cp client/.env.example client/.env
cp server/.env.sample server/.env

# 3. Generate secure secrets (JWT, APP_SECRET, SHARE_SECRET)
pnpm secrets:update

# 4. Add your API keys to server/.env:
#    - WPCOM_CLIENT_ID=<your-wpcom-client-id>
#    - WPCOM_CLIENT_SECRET=<your-wpcom-client-secret>
#    - ANTHROPIC_API_KEY=<your-anthropic-api-key>

# 5. Generate server configuration
pnpm run config:dev

# 6. Install PHP dependencies
cd server && composer install && cd ..

# 7. Start MinIO (S3 storage) - REQUIRED
pnpm run minio:start

# 8. Create the S3 bucket (CRITICAL - builds will fail without this!)
docker run --rm --network host --entrypoint sh minio/mc -c \
  "mc alias set m http://localhost:11111 minioadmin minioadmin && mc mb m/w0-blocks --ignore-existing"

# 9. Set up block build workspace (CRITICAL - wp-scripts won't work without this!)
node cli/setup-workspace.js

# 10. Start development servers
pnpm run dev
```

### MinIO Setup Details

MinIO provides S3-compatible storage for local development:

```bash
pnpm run minio:start      # Start MinIO in background
pnpm run minio:stop       # Stop MinIO
pnpm run minio:status     # Check status
pnpm run minio:logs       # View logs
```

- **S3 API**: http://localhost:11111
- **Web Console**: http://localhost:11112
- **Credentials**: `minioadmin` / `minioadmin`
- **Bucket**: `w0-blocks` (must exist for builds to work)

### Create Bucket (if missing)

If builds fail with "NoSuchBucket" error:

```bash
docker run --rm --network host --entrypoint sh minio/mc -c \
  "mc alias set m http://localhost:11111 minioadmin minioadmin && mc mb m/w0-blocks --ignore-existing"
```

### Setup Block Build Workspace (if wp-scripts not found)

If builds fail with "Command wp-scripts not found":

```bash
node cli/setup-workspace.js
```

This installs `@wordpress/scripts` and block dependencies to `/tmp/projects/`.

### Non-Docker Development

If you don't want to run the full Docker stack, use the local dev script:

```bash
pnpm dev:no-docker    # Starts PHP server + Vite + Admin panel + Queue worker locally
```

This runs `cli/dev.js`, which spawns:
- **PHP server** on `localhost:8000` (4 workers)
- **Vite dev server** on `localhost:3000`
- **Admin panel** (PHP) on `localhost:4000`
- **Queue worker** (if using container builder) polling every 2 seconds

All output is combined in a single terminal with color-coded labels (`[PHP]`, `[VITE]`, `[ADMIN]`, `[QUEUE]`).

Still requires MinIO to be running separately (`pnpm run minio:start`).

## Development Commands

### Root Commands

```bash
pnpm run dev              # Start Docker environment (HMR, MinIO, all services)
pnpm dev:no-docker        # Start locally without Docker (PHP + Vite + Admin)
pnpm run client:dev       # Start only Vite dev server
pnpm run client:build     # Build client for production
pnpm run client:lint      # Run Biome linter
pnpm run client:format    # Format code with Biome
```

### Docker Flags

```bash
pnpm dev                  # Default: smart rebuild detection
pnpm dev --build-only     # Only build the Docker image
pnpm dev --run-only       # Start without rebuilding (fast restart)
pnpm dev --no-mounts      # Production-like mode: no volume mounts, pre-built client
```

The `--no-mounts` flag runs the app without Docker bind mounts, so code is baked into the image at build time. Useful for testing production-like behavior locally.

### Testing

**Vitest (unit tests)** -- configured in client, uses React Testing Library:

```bash
# From root or client directory
pnpm run test             # Run Vitest unit tests (single run)
pnpm run test:watch       # Watch mode (re-runs on file changes)
pnpm run test:ui          # Vitest browser UI
```

**Playwright (E2E tests)** -- configured at `client/playwright.config.ts`:

```bash
pnpm run test:e2e         # Run all E2E tests
pnpm run test:e2e:ui      # Playwright UI mode
pnpm run test:e2e:headed  # Run with visible browser (single worker)
pnpm run test:e2e:debug   # Run with Playwright inspector
pnpm run test:e2e:refresh # Force-refresh shared test project
pnpm run test:e2e:clear-cache  # Clear cached test data
```

Playwright has multiple test projects: `setup` (auth), `shared-project`, `login`, `showcase`, `authenticated`, and `logout`. Tests auto-start the dev server if not running.

**Server tests** -- PHP test suite (requires PHP 8.0+):

```bash
cd server && ./test/run_all_tests.sh
```

**All tests** at once:

```bash
cd client && pnpm run test:all   # Vitest + Playwright
```

### Server Commands

```bash
cd server
composer install          # Install PHP dependencies
php -S localhost:8000 -t public/  # Start PHP server manually
```

## Client Architecture

### Routing (TanStack Router)

File-based routing in `client/src/routes/`:

```
routes/
├── __root.tsx              # Root layout
├── index.tsx               # Home page (/)
├── changelog.tsx           # Changelog (/changelog)
├── faq.tsx                 # FAQ (/faq)
├── projects.$publicId.tsx  # Project view (/projects/:publicId)
├── projects.new.tsx        # New project (/projects/new)
├── protected-layout.tsx    # Auth-protected layout
└── settings.tsx            # Settings (/settings)
```

### State Management

- **Zustand**: `client/src/stores/` - Client-side state
- **Contexts**: `client/src/contexts/` - Auth, Project, AppEnv providers

### Key Hooks

```typescript
// API hooks
import { useArtefact } from '@/hooks/artefact';
import { useProject } from '@/hooks/project';

// Playground persistence
import { usePlaygroundPersistence } from '@/hooks/usePlaygroundPersistence';
import { useOPFSStorage } from '@/hooks/useOPFSStorage';

// Chat/messaging
import { useMessages } from '@/hooks/useMessages';
import { useStream } from '@/hooks/useStream';
```

### Environment Variables

Client uses Vite environment variables (prefix with `VITE_`):

```bash
# client/.env
VITE_W0_BA_TOOLKIT_URL=http://localhost:8000
```

Access via:

```typescript
import { useAppEnv } from '@/contexts/AppEnvContext';
const { apiUrl } = useAppEnv();
```

## Code Style

- **Linting/Formatting**: Biome
- **TypeScript**: Strict mode enabled
- **React**: Functional components with hooks
- **CSS**: Tailwind CSS with component-based approach
- **PHP**: PSR-4 autoloading, PHP 8.0+ features

### Running Checks

```bash
pnpm run client:check     # Run Biome check (format + lint)
pnpm run client:lint      # Lint only
pnpm run client:format    # Format only
```

## CLI Tools

All CLI tools live in `cli/` and are invoked via pnpm scripts:

| Script | CLI File | Purpose |
|--------|----------|---------|
| `pnpm dev:setup` | `cli/setup.js` | Interactive first-time setup wizard |
| `pnpm dev` | `cli/docker.js` | Docker-based dev environment |
| `pnpm dev:no-docker` | `cli/dev.js` | Local dev without Docker |
| `pnpm clean` | `cli/clean.js` | Remove all Telex Docker resources (containers, volumes, images) |
| `pnpm clean:setup` | `cli/clean-setup.js` | Remove setup artifacts (node_modules, vendor, configs, .env files) |
| `pnpm config:dev` | `cli/config.js` | Generate development `server/config.json` |
| `pnpm config:staging` | `cli/config.js` | Generate staging config (requires all args) |
| `pnpm config:prod` | `cli/config.js` | Generate production config (requires all args) |
| `pnpm secrets:generate` | `cli/generate-secrets.js` | Generate secure secrets |
| `pnpm secrets:update` | `cli/generate-secrets.js` | Generate and write secrets to `.env` |
| `pnpm worktree:add` | `cli/worktree.js` | Create a new git worktree with auto-configured ports |
| `pnpm worktree:start` | `cli/worktree.js` | Start dev server in a worktree |
| `pnpm worktree:remove` | `cli/worktree.js` | Remove a worktree |

Additional utilities:
- `cli/setup-workspace.js` -- Sets up the block build workspace at `/tmp/projects/`
- `cli/minio.js` -- MinIO management helpers

## Two-Tier Configuration

Telex separates **secrets** (`.env` files) from **configuration** (`config.json`).

**Secrets** (never committed):
- `server/.env` -- API keys, JWT secret, app secret, share secret, AWS credentials, Langfuse keys
- `client/.env` -- API URL, PostHog key, CSP settings
- `admin/.env` -- Admin-specific settings

**Configuration** (generated, not committed):
- `server/config.json` -- App URL, storage driver, S3 settings, queue driver, builder type, PostHog/Langfuse/Linear config
- `admin/config.json` -- Auto-copied from server config

Generate config per environment:

```bash
pnpm config:dev                           # Development defaults
pnpm config:staging -- --url=https://...  # Staging (all args required)
pnpm config:prod -- --url=https://...     # Production (all args required)
pnpm config:dev -- --dry-run              # Preview without writing
```

The config generator supports many overrides (`--url`, `--builder`, `--s3-endpoint`, etc.). Run `node cli/config.js --help` for the full list.

## Admin Panel

The admin panel (`admin/`) is a PHP application accessible only to Automatticians via AutoProxy. It provides a full overview of all Telex projects.

- **Port**: 4000
- **Structure**: `admin/src/` (Controllers, Router, Services, Views, Middleware)
- **Entry point**: `admin/public/index.php`
- Started automatically by both `pnpm dev` (Docker) and `pnpm dev:no-docker` (local)

## Xdebug (Docker Only)

Xdebug is pre-installed in the Docker dev image but disabled by default:

```bash
pnpm dev:xdebug-on    # Enable Xdebug, reload PHP-FPM
pnpm dev:xdebug-off   # Disable Xdebug, reload PHP-FPM
```

These toggle Xdebug on a running container -- no restart needed. When disabled, there is zero performance impact.

**IDE setup**: The project includes `.vscode/launch.json` for VS Code. For PhpStorm, configure Xdebug port 9003 and set path mappings (`server` -> `/app/server`, `admin` -> `/app/admin`). See `docs/local-dev.md` for full IDE instructions.

## i18n Commands

Telex has built-in AI-powered translation via `server/bin/console.php`:

```bash
pnpm i18n:translate          # Translate ALL keys to all languages
pnpm i18n:translate-one      # Translate a single key (pass --key <key>)
pnpm i18n:translate-server   # Translate server-side strings
pnpm i18n:validate           # Validate translation files
```

Requires `ANTHROPIC_API_KEY` in `server/.env`. Client strings go in `client/public/locales/en.json`, server strings in `server/locales/en.json`.

## Queue Worker

When using the `container` builder, a queue worker processes block builds:

```bash
php server/bin/console.php queue:process
```

In local dev (`pnpm dev:no-docker`), the queue worker runs automatically every 2 seconds if `config.json` has `app.builder` set to `container`. In Docker, it runs via cron. The queue driver is configurable (`file` or `sqlite`) via `config.json`.

## API Routes Generation

The Vite proxy needs to know which URL prefixes belong to the PHP API. This is auto-generated:

```bash
php server/bin/generate-api-prefixes.php > client/api-routes.json
```

The script reads `server/src/Router/routes.php`, extracts first-level path prefixes (e.g., `/auth`, `/projects`), and outputs a JSON array. In Docker, this runs automatically via `entrypoint-dev.sh`. For local dev, regenerate manually if you add new API routes.

## Worktree Port Offsets

Each git worktree gets a unique port offset to avoid conflicts. Offsets increment by 100:

| Worktree | Client | Admin | Server |
|----------|--------|-------|--------|
| Main | 3000 | 4000 | 8000 |
| 1st worktree | 3100 | 4100 | 8100 |
| 2nd worktree | 3200 | 4200 | 8200 |

Port offsets are auto-assigned by `pnpm worktree:add` and stored in the worktree's root `.env` file. The client `.env` is also updated with the correct API URL.

## PostHog Analytics

Client-side analytics via PostHog. Configure in `client/.env`:

```bash
VITE_PUBLIC_POSTHOG_KEY=your-posthog-project-key
VITE_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

Server-side PostHog config goes in `server/config.json` (generated by `pnpm config:*`). The PostHog API key is `null` by default in development.

## WordPress Playground Integration

Telex uses WordPress Playground for live block preview:

- **Package**: `@wp-playground/client`
- **Persistence**: OPFS (Origin Private File System) for browser-side storage
- **Features**: Native OPFS mounting, auto-save, compression, storage quota management

```typescript
// Using Playground persistence
import { usePlaygroundPersistence } from '@/hooks/usePlaygroundPersistence';

const { saveState, loadState, isReady } = usePlaygroundPersistence();
```

## Git Workflow (CRITICAL)

**Before making any code changes in this repo, ALWAYS:**

1. **Checkout main and pull latest:**
   ```bash
   cd repos/telex
   git checkout main
   git pull origin main
   ```

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/descriptive-name
   ```

3. **Install dependencies if needed:**
   ```bash
   pnpm install
   ```

4. **Then make your changes**

Never work directly on main. Always create a feature branch first.

## Troubleshooting

### "Failed to store public ID" / "NoSuchBucket" Error

The MinIO bucket doesn't exist. Create it:

```bash
docker run --rm --network host --entrypoint sh minio/mc -c \
  "mc alias set m http://localhost:11111 minioadmin minioadmin && mc mb m/w0-blocks --ignore-existing"
```

### "Command wp-scripts not found" / "ERR_PNPM_RECURSIVE_EXEC_FIRST_FAIL"

The block build workspace isn't set up. Run:

```bash
node cli/setup-workspace.js
```

### "process is not defined" Error

Vite uses `import.meta.env` not `process.env`:

```typescript
// Wrong
process.env.API_URL

// Correct
import.meta.env.VITE_W0_BA_TOOLKIT_URL
```

### MinIO Connection Issues

1. Check MinIO is running: `pnpm run minio:status`
2. Verify console access: http://localhost:11112
3. Check bucket exists (see NoSuchBucket fix above)
4. Check `.env` credentials match MinIO defaults (`minioadmin`/`minioadmin`)

### Build Failures on Docker

Clear the projects folder if switching between Docker and local:

```bash
rm -rf /tmp/projects/*
```

pnpm symlinks are OS-specific and won't work across environments.

### OAuth "Unknown client_id" Error

Your WordPress.com OAuth credentials aren't configured. Add to `server/.env`:

```bash
WPCOM_CLIENT_ID=<your-client-id>
WPCOM_CLIENT_SECRET=<your-client-secret>
```

Get credentials at https://developer.wordpress.com/apps/

### Ports Already in Use

Kill existing processes:

```bash
lsof -ti:3000,4000,8000 | xargs kill -9 2>/dev/null
```

## AI Context Files

Read `CLAUDE.md` in the repo root for additional AI-specific guidance. It contains detailed architecture documentation and development patterns.
