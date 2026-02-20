---
description: CIAB (Commerce in a Box) development context
globs: ["repos/ciab/**/*"]
---

# CIAB Development Context

> **Access Required:** CIAB is an Automattic-internal project. The upstream repository lives on `github.a8c.com` (not public GitHub). You need Automattic VPN/network access to clone and contribute. See `dk.config.json` for the upstream URL.

CIAB (Commerce in a Box) is a monorepo containing WordPress plugins that provide a modern, modular redesign of the WordPress admin interface. It's built as a Single Page Application (SPA) using React and TypeScript.

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/ciab` |
| **Node Version** | 22 (see .nvmrc, requires >=22.18.0) |
| **Package Manager** | pnpm |
| **Language** | TypeScript |
| **Framework** | React |
| **Styling** | SCSS (minimize CSS, prefer @wordpress/components) |
| **State** | @wordpress/core-data, @wordpress/data |
| **Routing** | TanStack Router |
| **Dev Server** | `pnpm dev` → http://localhost:9001/wp-admin/ |

## Node Version (CRITICAL)

CIAB requires **Node 22** (specifically >=22.18.0). Before running ANY pnpm command:

```bash
cd repos/ciab
source ~/.nvm/nvm.sh && nvm use
```

This reads the `.nvmrc` file and switches to the correct version. Always include this in your commands:

```bash
# Installing dependencies
cd repos/ciab && source ~/.nvm/nvm.sh && nvm use && pnpm install

# Starting dev server
cd repos/ciab && source ~/.nvm/nvm.sh && nvm use && pnpm dev

# Starting WordPress environment
cd repos/ciab && source ~/.nvm/nvm.sh && nvm use && pnpm env:start
```

## Repository Structure

```
repos/ciab/
├── wordpress/plugins/     # WordPress plugins (main codebase)
│   ├── ciab-admin/       # Main admin plugin (START HERE)
│   │   ├── routes/       # Route modules (TanStack Router)
│   │   ├── packages/     # Internal packages
│   │   ├── fields/       # Field definitions
│   │   └── dashboard-widgets/
│   ├── ciab-next/        # Next-gen CIAB features
│   ├── woocommerce-next/ # WooCommerce integration
│   └── ...               # Other plugins
├── docs/                 # Architecture documentation
├── tests/                # E2E tests (Playwright)
└── tools/                # Build tools and scripts
```

## pnpm Workspace & Plugin Architecture

CIAB is a **pnpm workspace monorepo** containing multiple WordPress plugins under `wordpress/plugins/`. Each plugin is its own workspace package.

### Plugins

| Plugin | Role |
|--------|------|
| **`ciab-admin`** | Core plugin. The main admin SPA, route system, and shared packages. **Start here.** |
| **`ciab-next`** | Next-generation CIAB features (experimental/upcoming) |
| **`woocommerce-next`** | WooCommerce integration layer |
| **`mailpoet-next`** | MailPoet integration layer |

The `ciab-admin` plugin is the heart of the project. It contains the route system, internal packages (`packages/`), field definitions (`fields/`), and dashboard widgets. Other plugins extend or integrate with it.

Use `pnpm --filter=<plugin-name>` to target a specific plugin:

```bash
pnpm --filter=ciab-admin build
pnpm --filter=ciab-admin dev
```

## @automattic/design-system

CIAB has its own design system package at `wordpress/plugins/ciab-admin/packages/design-system/`. The `@automattic/design-system` is the **preferred component library** for CIAB after `@wordpress/components`.

The component selection priority is:

1. **High-level patterns** (lists, data views) -- use `@ciab/dataviews` or `@automattic/views`
2. **Design system components** -- use `@automattic/design-system`
3. **Standard WordPress components** -- fall back to `@wordpress/components`
4. **None of the above** -- reassess the design or discuss in `#next-admin`

```typescript
// @automattic/design-system import
import { Button } from '@automattic/design-system';

// @wordpress/components fallback
import { Card, TextControl } from '@wordpress/components';
```

## DataViews

DataViews is a standardized component for rendering list/table views of entity data. It lives at `wordpress/plugins/ciab-admin/packages/dataviews/`.

**When to use it:** Any time you need a list or table of records (posts, users, pages, etc.). DataViews provides sorting, filtering, pagination, layout switching (table/grid), and view persistence out of the box.

```typescript
// Typical DataViews usage in a stage component
export default function PostList() {
  const posts = useSelect(
    (select) => select(coreStore).getEntityRecords('postType', 'post'),
    []
  );

  return <DataViews data={posts} />;
}
```

See `docs/dataviews-consistency.md` in the CIAB repo for detailed guidelines.

## Key Principles

1. **Separate backend and frontend**: Backend is REST API, frontend is SPA. Avoid inline scripts.
2. **Component-based**: Use `@wordpress/components` and `@automattic/design-system`. Minimize custom CSS.
3. **Data layer**: Use `@wordpress/core-data` and global `@wordpress/data` store.
4. **Routing**: TanStack Router with loaders, preloading, and view transitions.
5. **TypeScript**: Prefer simple, concrete types.
6. **i18n**: Use `@wordpress/i18n` package for translation.

## Route Architecture

Routes are auto-discovered from the file system. Each route folder should have:

```
routes/my-route/
├── package.json      # Route configuration (path, etc.)
├── stage.tsx         # Main content component (optional)
├── route.tsx         # Route functions (loader, canvas, inspector) (optional)
└── inspector.tsx     # Inspector surface component (optional)
```

### Route Registration

Routes are automatically discovered and registered via `build/index.php`. The `package.json` in each route folder defines the route:

```json
{
  "route": {
    "path": "/settings/general"
  }
}
```

### Route Module Structure

**route.tsx** (route module - loaded synchronously):
- Exports: `loader`, `beforeLoad`, `canvas`, `inspector` functions
- Contains route configuration and data-loading logic

**stage.tsx** (content module - lazy loaded):
- Exports: `stage` component
- Contains the main UI component

See `docs/routes-architecture.md` for complete details.

## Component Patterns

### Finding Components

1. **First**: Check `@wordpress/components` for standard components
2. **Then**: Check `@automattic/design-system` for Automattic components
3. **Finally**: Check `wordpress/plugins/ciab-admin/packages/` for CIAB-specific packages

### Using @wordpress/components

```typescript
import { Button, Card, TextControl, ToggleControl } from '@wordpress/components';
```

### Using @automattic/design-system

```typescript
import { Button } from '@automattic/design-system';
```

## State Management

### Using @wordpress/core-data

```typescript
import { useSelect, useDispatch } from '@wordpress/data';
import { store as coreDataStore } from '@wordpress/core-data';

function MyComponent() {
  const posts = useSelect(
    (select) => select(coreDataStore).getEntityRecords('postType', 'post'),
    []
  );

  const { saveEntityRecord } = useDispatch(coreDataStore);

  const handleSave = () => {
    saveEntityRecord('postType', 'post', { title: 'New Post' });
  };
}
```

## Internationalization

Always wrap user-facing strings:

```typescript
import { __ } from '@wordpress/i18n';

function MyComponent() {
  return <h1>{__('Settings', 'ciab-admin')}</h1>;
}
```

## Development Commands

```bash
cd repos/ciab

# Install dependencies
pnpm install
composer install

# Build all plugins
pnpm build:all

# Build specific plugin
pnpm --filter=ciab-admin build

# Development mode (watch)
pnpm dev
# or for specific plugin
pnpm --filter=ciab-admin dev

# Start WordPress environment
pnpm env:start
# or auto (finds available ports)
pnpm env:start:auto

# Run tests
pnpm test:unit          # Unit tests
pnpm test:e2e           # E2E tests (Playwright)
pnpm test:perf          # Performance tests

# Linting
pnpm lint:js            # JavaScript/TypeScript
pnpm lint:css           # CSS/SCSS
pnpm lint:php           # PHP
pnpm lint:format        # Prettier

# Type checking
pnpm typecheck          # Standard
pnpm typecheck-strict   # Strict mode
```

## WordPress Environment (wp-env)

`pnpm env:start` runs a **wp-env Playground runtime** using [`@wordpress/env` (wp-env)](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/). This means:

- **wp-env must be installed** (`npm install -g @wordpress/env`) before you start the environment
- wp-env runs WordPress using Playground runtime (WebAssembly + SQLite) -- no Docker required
- The CIAB plugins are mounted into the environment
- Changes to plugin files are reflected immediately (with `pnpm dev` running for JS rebuilds)
- `pnpm env:start:auto` finds available ports if 9001 is taken

### PHP Dependencies (Composer)

CIAB has PHP dependencies managed by Composer. Run `composer install` alongside `pnpm install` when setting up:

```bash
cd repos/ciab && source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
```

If you skip `composer install`, PHP autoloading will fail and the plugin will not activate properly.

Default login:
- URL: http://localhost:9001/wp-login.php
- Username: `admin`
- Password: `password`
- Admin: http://localhost:9001/wp-admin/

Access CIAB Admin via the "CIAB Admin" menu item in WordPress admin.

## Testing

### E2E Tests (Playwright)

Tests are in `tests/e2e/`. Run with:
```bash
pnpm test:e2e
```

### Unit Tests

```bash
pnpm test:unit
```

## Documentation

Key architecture docs in `docs/`:
- `routes-architecture.md` - Route system details
- `monorepo-build-commands.md` - Build commands guide
- `ui-components.md` - Component selection guide
- `dataviews-consistency.md` - DataViews guidelines
- `custom-post-types.md` - Custom Post Types API

## View Persistence (@automattic/views)

CIAB uses `@automattic/views` (located at `wordpress/plugins/ciab-admin/packages/views/`) to persist user preferences for list views.

View state is split into two categories:

- **URL-based (temporary):** Page number, search query. Lost on navigation.
- **Preferences-based (persistent):** Layout mode (table/grid), filters, sorting, column visibility. Stored in WordPress user meta and persists across sessions.

Route loaders typically call `ensureView()` to load the user's saved view before fetching data:

```typescript
loader: async ({ params }) => {
  const view = await ensureView(params.type, params.slug);
  await resolveSelect(coreStore).getEntityRecords(
    'postType',
    params.type,
    viewToQuery(view)
  );
}
```

## dk.config.json Note

The `dk.config.json` file lists `"stateManagement": "Redux"` for CIAB. This is **incorrect**. CIAB uses `@wordpress/core-data` and `@wordpress/data` for state management -- not Redux directly. The Quick Reference table at the top of this file has the correct information.

## Troubleshooting

### Environment Issues
- **wp-env fails to start** -- Ensure wp-env is installed (`npm install -g @wordpress/env`) and Node is the correct version.
- **Port 9001 already in use** -- Use `pnpm env:start:auto` to find an available port, or stop whatever is using 9001.

### Build Failures
- **Node version mismatch** -- CIAB requires Node >=22.18.0. Always run `nvm use` in the repo root first.
- **Missing dependencies** -- Run both `pnpm install` and `composer install`. Missing either will cause failures.
- **pnpm lockfile conflict** -- Run `pnpm install --no-frozen-lockfile` if you get lockfile errors after switching branches.

### Plugin Not Appearing
- Make sure `pnpm build:all` (or `pnpm dev` for watch mode) has completed successfully.
- Check that the WordPress environment is running (`pnpm env:start`).
- Look for PHP errors in the wp-env logs: `npx wp-env logs`.

### TypeScript Errors
- Run `pnpm typecheck` to see all type errors.
- Use `pnpm typecheck-strict` for strict mode (more errors, higher confidence).

## Cross-Repo Context

CIAB shares the `@wordpress/components`, `@wordpress/data`, and `@wordpress/core-data` packages with Gutenberg, Calypso, and other WordPress ecosystem projects. For details on how CIAB fits into the broader ecosystem, see `skills/cross-repo/SKILL.md`.

Key connections:
- **@wordpress/components** -- Same component library used by Gutenberg and Calypso
- **@wordpress/core-data** -- Same data layer that powers the Gutenberg editor
- **REST API** -- CIAB's SPA talks to WordPress Core via the same REST endpoints used across the ecosystem

## Git & Branch Workflows

When checking out a branch (especially for PRs):

1. **Don't assume a branch doesn't exist** if `git fetch origin branch_name` fails
2. **Search for PRs first** to confirm the branch exists:
   ```bash
   gh pr list --search "keyword" --state open
   ```
3. **Fetch remote branches properly** using this syntax:
   ```bash
   git fetch origin branch-name:branch-name && git checkout branch-name
   ```
4. **Never create a new branch** if the user says one already exists - find it first

## Project Management

Uses Linear for project management. Configuration in `.linear.json` at the root.
