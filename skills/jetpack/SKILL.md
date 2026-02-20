---
description: Jetpack plugin development context
globs: ["repos/jetpack/**/*"]
---

# Jetpack Development Context

Jetpack is a WordPress plugin providing security, performance, marketing, and design tools. This is a monorepo containing the main Jetpack plugin plus many related packages and plugins.

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/jetpack` |
| **Node Version** | 22 (see .nvmrc) |
| **Package Manager** | pnpm |
| **Language** | PHP, JavaScript/TypeScript |
| **PHP Dependencies** | Composer |
| **Default Branch** | trunk |
| **Main Plugin** | `projects/plugins/jetpack` |

## Node Version (CRITICAL)

Jetpack requires **Node 22**. Before running ANY pnpm command:

```bash
cd repos/jetpack
source ~/.nvm/nvm.sh && nvm use
```

This reads the `.nvmrc` file and switches to the correct version. Always include this in your commands:

```bash
# Installing dependencies
cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm install

# Building Jetpack
cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm jetpack build plugins/jetpack --deps

# Watching for changes
cd repos/jetpack && source ~/.nvm/nvm.sh && nvm use && pnpm jetpack watch plugins/jetpack
```

## Key Directories

```
repos/jetpack/
├── projects/
│   ├── plugins/               # WordPress plugins
│   │   ├── jetpack/           # Main Jetpack plugin
│   │   ├── backup/            # Jetpack Backup
│   │   ├── boost/             # Jetpack Boost
│   │   ├── protect/           # Jetpack Protect
│   │   ├── search/            # Jetpack Search
│   │   ├── social/            # Jetpack Social
│   │   ├── videopress/        # VideoPress
│   │   └── ...                # Other standalone plugins
│   ├── packages/              # Shared PHP/Composer packages
│   │   ├── connection/        # WordPress.com connection
│   │   ├── sync/              # Data sync
│   │   ├── assets/            # Asset handling
│   │   └── ...
│   ├── js-packages/           # Shared JS/npm packages
│   │   ├── components/        # React components
│   │   ├── api/               # API clients
│   │   └── ...
│   └── github-actions/        # GitHub Actions (third project type)
│       ├── push-to-mirrors/
│       ├── repo-gardening/
│       ├── required-review/
│       ├── test-results-to-slack/
│       └── pr-is-up-to-date/
├── tools/                     # Development tooling
│   ├── cli/                   # Monorepo `jetpack` CLI (see CLI section)
│   ├── e2e-commons/           # Shared E2E test utilities (Playwright)
│   ├── js-tools/              # ESLint configs, Prettier, semver, git hooks
│   ├── performance/           # Performance testing scripts
│   └── php-test-env/          # PHP test environment (PHPUnit bootstrap)
└── docs/                      # Documentation
```

## pnpm Workspace Structure

The monorepo uses pnpm workspaces. See `pnpm-workspace.yaml` for the full config:

```yaml
packages:
  - projects/*/*              # All projects (plugins, packages, js-packages, github-actions)
  - '!projects/js-packages/jetpack-cli'  # Excluded — published separately
  - projects/plugins/*/tests/e2e         # E2E test packages
  - tools/cli                 # Monorepo CLI
  - tools/e2e-commons
  - tools/js-tools
  - tools/performance
  - .github/files/coverage-munger
```

Key settings: strict peer deps, no hoisting (`hoistPattern: []`), workspace cycles ignored, 1-day minimum release age for dependency updates.

## CLI: `jetpack` (Monorepo Dev CLI)

- **Location:** `tools/cli/` (package name: `jetpack-cli`, private)
- **How to run:** `pnpm jetpack <command>` from the monorepo root
- **What it is:** The primary monorepo development CLI. Handles builds, tests, watching, changelogs, releases, and project generation.
- **Commands:** `build`, `watch`, `test`, `changelog`, `clean`, `generate`, `install`, `dependencies`, `cli`, `phan`, `release`, `draft`, `rsync`, `docs`
- **Global access:** Run `pnpm jetpack cli link` to make `jetpack` available globally (creates a pnpm global link of `tools/cli`). Check status with `pnpm jetpack cli status`.

**In dk**, we use `pnpm jetpack` since we manage Node versions directly via nvm.

### CLI Link (Optional)

After `pnpm install`, you can optionally run `pnpm jetpack cli link` to make the `jetpack` command available globally. This is NOT required — `pnpm jetpack` works from the monorepo root without linking. Linking is a convenience for running `jetpack build ...` instead of `pnpm jetpack build ...`.

## Development Workflow

### Running Jetpack in WordPress Core

Jetpack is mounted as a plugin via wp-env. The `configs/wp-env-jetpack.json` configuration mounts the Jetpack plugin from the monorepo into the WordPress environment. The full `projects` folder is mounted so that internal symlinks in `jetpack_vendor` resolve correctly. Plugin activation is handled automatically by wp-env.

### Start Development

```bash
# Start WordPress Core with Jetpack (recommended)
./skills/dev-servers/scripts/start.sh jetpack

# This internally runs wp-env with the Jetpack config:
# wp-env start --runtime=playground (using configs/wp-env-jetpack.json)

# Jetpack admin:
# http://localhost:8889/wp-admin/admin.php?page=jetpack
```

### Build Commands

```bash
cd repos/jetpack

# Install dependencies
pnpm install
composer install

# Build Jetpack plugin with all dependencies (REQUIRED)
pnpm jetpack build plugins/jetpack --deps

# Watch for changes (development)
pnpm jetpack watch plugins/jetpack

# Build without dependencies (faster, for subsequent builds)
pnpm jetpack build plugins/jetpack

# Run tests
pnpm jetpack test plugins/jetpack
```

### Build Output Locations

Build artifacts for the main Jetpack plugin go to these directories (all gitignored):

| Output Directory | Contents |
|-----------------|----------|
| `_inc/build/` | Compiled JS/CSS for the admin UI (`admin.js`, `admin.css`, etc.) and module assets |
| `_inc/blocks/` | Compiled Gutenberg block assets (fonts, block JS/CSS bundles) |
| `css/` | Compiled standalone CSS (`cleanslate.css`, `dashboard-widget.css`, etc.) |
| `modules/**/` | Per-module compiled assets (`block.js`, `*.min.css`, `*-rtl.css`) |

These are relative to `projects/plugins/jetpack/`. A build (`pnpm jetpack build plugins/jetpack`) must run before Jetpack will function in WordPress.

### Watch Mode

For active development, use watch mode to automatically rebuild on file changes:

```bash
pnpm jetpack watch plugins/jetpack
```

This watches the project and its dependencies. You can also watch all projects with `pnpm jetpack watch --all` (beta).

## Main Jetpack Plugin Structure

```
projects/plugins/jetpack/
├── _inc/
│   ├── client/               # React admin UI
│   │   ├── components/       # UI components
│   │   ├── state/            # Redux state
│   │   └── ...
│   └── lib/                  # PHP libraries
├── class.jetpack.php         # Main plugin class
├── class.jetpack-client.php  # API client
├── modules/                  # Feature modules
│   ├── comments.php
│   ├── contact-form.php
│   ├── custom-css.php
│   ├── infinite-scroll.php
│   ├── likes.php
│   ├── markdown.php
│   ├── photon.php
│   ├── protect.php
│   ├── publicize.php
│   ├── related-posts.php
│   ├── search.php
│   ├── seo-tools.php
│   ├── sharing.php
│   ├── shortcodes/
│   ├── sitemaps.php
│   ├── stats.php
│   ├── subscriptions.php
│   ├── tiled-gallery.php
│   ├── videopress.php
│   ├── widget-visibility.php
│   ├── widgets/
│   └── ...
├── extensions/               # Block editor extensions
│   └── blocks/               # Gutenberg blocks
├── json-endpoints/           # REST API endpoints
├── jetpack_vendor/           # Symlinked Composer packages (see below)
│   └── automattic/           # Autoloaded Jetpack packages
└── views/                    # PHP templates
```

### jetpack_vendor Directory

`jetpack_vendor/` contains symlinks to Composer packages from the monorepo (`projects/packages/`). In production builds, these are real copies; in development, they're symlinks managed by Composer. This is why the wp-env config mounts the entire `projects/` folder — the symlinks need to resolve. The `i18n-map.php` file maps package text domains for translations.

## Jetpack Modules

Jetpack features are organized as modules that can be activated/deactivated:

| Module | Purpose |
|--------|---------|
| `stats` | Site statistics |
| `publicize` | Social sharing |
| `sharing` | Share buttons |
| `subscriptions` | Email subscriptions |
| `related-posts` | Related content |
| `likes` | Like buttons |
| `comments` | Enhanced comments |
| `contact-form` | Contact forms |
| `markdown` | Markdown support |
| `infinite-scroll` | Infinite scrolling |
| `photon` | Image CDN |
| `protect` | Brute force protection |
| `sso` | WordPress.com SSO |
| `sitemaps` | XML sitemaps |
| `search` | Enhanced search |
| `videopress` | Video hosting |

## Jetpack Blocks

Jetpack provides Gutenberg blocks in `extensions/blocks/`:

```javascript
// Common Jetpack blocks
import {
  ContactFormBlock,
  SubscriptionsBlock,
  RelatedPostsBlock,
  TiledGalleryBlock,
  SlideshowBlock,
  PaymentsBlock,
  GifBlock
} from '@automattic/jetpack-blocks';
```

## REST API Endpoints

Jetpack extends WordPress REST API:

```
/wp-json/jetpack/v4/
├── connection/            # WordPress.com connection
├── module/                # Module management
├── settings/              # Jetpack settings
├── site/                  # Site information
├── sync/                  # Data sync status
└── ...
```

### API Usage

```php
// Register custom Jetpack endpoint
add_action( 'rest_api_init', function() {
    register_rest_route( 'jetpack/v4', '/my-endpoint', [
        'methods'  => 'GET',
        'callback' => 'my_endpoint_callback',
        'permission_callback' => function() {
            return current_user_can( 'manage_options' );
        }
    ]);
});
```

## Shared Packages

### PHP Packages (projects/packages/)

```php
// Connection package - WordPress.com connection
use Automattic\Jetpack\Connection\Manager;

$manager = new Manager( 'jetpack' );
if ( $manager->is_connected() ) {
    // Site is connected to WordPress.com
}

// Sync package - Data synchronization
use Automattic\Jetpack\Sync\Actions;

Actions::send_data( $data, 'full_sync' );

// Assets package - Asset enqueuing
use Automattic\Jetpack\Assets;

Assets::register_script( 'my-script', 'path/to/script.js', __FILE__ );
```

### JS Packages (projects/js-packages/)

```javascript
// API package
import { jetpackApi } from '@automattic/jetpack-api';

const settings = await jetpackApi.fetchModuleSettings( 'stats' );

// Components package
import { JetpackLogo, AdminPage } from '@automattic/jetpack-components';
```

## Testing

The `pnpm jetpack test` command is the standard way to run tests. It accepts a test type and a project path:

```bash
cd repos/jetpack

# PHP tests (PHPUnit)
pnpm jetpack test php plugins/jetpack

# JavaScript tests (Jest)
pnpm jetpack test js plugins/jetpack

# Test coverage
pnpm jetpack test coverage plugins/jetpack

# TypeScript type checking
pnpm jetpack test typecheck plugins/jetpack

# Run tests for a specific package
pnpm jetpack test php packages/connection

# Run all tests across all projects
pnpm jetpack test php --all
```

Available test types depend on the project. Common types: `php`, `js`, `coverage`, `typecheck`.

### Multisite Testing

The main Jetpack plugin has PHPUnit configs for multisite testing at `tests/php.multisite.*.xml`. These set `WP_TESTS_MULTISITE=1`.

### E2E Testing

E2E tests live at `projects/plugins/jetpack/tests/e2e/` and use Playwright. Shared E2E utilities are in `tools/e2e-commons/`. E2E test packages for each plugin are included in the pnpm workspace separately (`projects/plugins/*/tests/e2e`).

### Build Scripts (composer.json)

Projects define their test/build scripts in `composer.json` under `.scripts`:
- `build-production` — Production build (sets `NODE_ENV=production`)
- `build-development` — Development build
- `test-php` — PHP tests
- `test-js` — JavaScript tests
- `test-coverage` — Coverage reports

## Connection to WordPress.com

Jetpack connects self-hosted WordPress sites to WordPress.com services:

```
┌─────────────────────┐     ┌─────────────────────┐
│   Self-hosted WP    │────▶│   WordPress.com     │
│   with Jetpack      │     │   Services          │
│                     │◀────│                     │
│   • Stats           │     │   • CDN (Photon)    │
│   • Protect         │     │   • Backup          │
│   • SSO             │     │   • Search          │
└─────────────────────┘     └─────────────────────┘
```

## Changelog Entries (Required for PRs)

Every PR that touches files under `projects/` needs a changelog entry in the affected project's `changelog/` directory. Changes outside `projects/` (e.g., `tools/`, `docs/`, `.github/`) do NOT need changelog entries.

### Adding a Changelog Entry

```bash
# Interactive mode (prompts for all fields)
pnpm jetpack changelog add

# Non-interactive mode
pnpm jetpack changelog add <project> -s <significance> -t <type> -e "<entry>"
```

**Parameters:**
- `-s, --significance`: `patch` | `minor` | `major`
- `-t, --type`: `security` | `added` | `changed` | `deprecated` | `removed` | `fixed`
- `-e, --entry`: Entry text (format: "Component: description starting with verb.")
- `-f, --filename`: Filename (defaults to git branch name)
- `-c, --comment`: For trivial changes with empty entry, explain why no entry is needed

### Changelog File Format

Files are plain text in the project's `changelog/` directory:

```
Significance: patch
Type: fixed

Connection: fix issue with site registration.
```

### Jetpack Plugin Custom Types

The main Jetpack plugin (`plugins/jetpack`) uses custom changelog types defined in its `composer.json` under `.extra.changelogger.types`:

| Type | Label |
|------|-------|
| `major` | Major Enhancements |
| `enhancement` | Enhancements |
| `compat` | Improved compatibility |
| `bugfix` | Bug fixes |
| `other` | Other changes (non-user-facing) |

Use these types instead of the standard ones when adding entries for `plugins/jetpack`.

## Installation Scripts

The monorepo includes setup scripts in `tools/`:

```bash
# Full monorepo setup (installs Node, pnpm, Composer, etc.)
tools/install-monorepo.sh

# Verify your dev environment has all required tools and versions
tools/check-development-environment.sh
```

`install-monorepo.sh` handles macOS (Homebrew) and Linux (apt) environments. `check-development-environment.sh` validates Node, pnpm, PHP, Composer versions against `.github/versions.sh`.

## AI Context Files

Read `AGENTS.md` in the Jetpack repo for additional AI-specific guidance.

## Common Development Tasks

### Adding a New Module

1. Create module file in `modules/`
2. Register in `class.jetpack.php`
3. Add settings UI in `_inc/client/`
4. Write tests

### Adding a New Block

1. Create block in `extensions/blocks/`
2. Register with `Jetpack_Gutenberg`
3. Add block.json metadata
4. Implement edit.js and save.js

### Modifying Settings UI

1. React components in `_inc/client/`
2. Redux state in `_inc/client/state/`
3. REST endpoints in `json-endpoints/`

## Useful Links

- [Jetpack Developer Docs](https://developer.jetpack.com/)
- [GitHub Repository](https://github.com/Automattic/jetpack)
- [Jetpack Storybook](https://automattic.github.io/jetpack-storybook/)
