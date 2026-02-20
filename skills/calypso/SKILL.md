---
description: Calypso-specific development context
globs: ["repos/calypso/**/*"]
---

# Calypso Development Context

Calypso is WordPress.com's custom dashboard, built with React and TypeScript.

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/calypso` |
| **Node Version** | 22 (see .nvmrc) |
| **Package Manager** | yarn |
| **Language** | TypeScript |
| **Framework** | React |
| **Styling** | SCSS with CSS custom properties |
| **State** | Redux + @wordpress/data |
| **Dev Server** | `yarn start:debug` (takes 5+ minutes for initial build) |

## Node Version (CRITICAL)

Calypso requires **Node 22**. Before running ANY yarn/npm command:

```bash
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use
```

This reads the `.nvmrc` file and switches to the correct version. Always include this in your commands:

```bash
# Installing dependencies
cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn install

# Starting dev server
cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn start:debug
```

## CRITICAL: Two Interfaces (Legacy vs Dashboard)

Calypso has **two separate interfaces** with different codebases. Always clarify which one the user is working in:

| Interface | URL | Code Location | Stack |
|-----------|-----|---------------|-------|
| **Legacy Calypso** | `calypso.localhost:3000` | `client/blocks/`, `client/components/`, `client/my-sites/`, `client/me/` | Redux, i18n-calypso, SCSS |
| **New Dashboard** | `my.localhost:3000` | `client/dashboard/` | TanStack Query, @wordpress/i18n, minimal CSS |

**When making changes:**
1. **ASK which interface** if not obvious from the file path
2. Components with the same name may exist in BOTH places (e.g., `edit-gravatar` exists in both `client/blocks/` and `client/dashboard/me/`)
3. Changes to one do NOT affect the other
4. The Dashboard has its own components, routing, and state management - see the "Dashboard Folder" section below

**Quick check:** Look at the URL or file path:
- `my.localhost` or `client/dashboard/` → New Dashboard
- `calypso.localhost` or `client/blocks/`, `client/me/` → Legacy Calypso

## Key Directories

```
repos/calypso/
├── client/
│   ├── components/      # Reusable UI components (START HERE)
│   ├── dashboard/       # NEW: Redesigned Hosting Dashboard (see Dashboard section)
│   │   ├── app/         # Dashboard app entry point
│   │   ├── components/  # Dashboard-specific components
│   │   ├── docs/        # Dashboard design documentation
│   │   ├── sites/       # Sites management pages
│   │   ├── domains/     # Domains pages
│   │   └── me/          # User profile pages
│   ├── my-sites/        # Site management pages (legacy)
│   ├── layout/          # App shell and layouts
│   ├── blocks/          # Gutenberg blocks for Calypso
│   ├── state/           # Redux state management
│   ├── lib/             # Utilities and helpers
│   └── assets/stylesheets/  # Global styles
├── packages/            # Internal shared packages
├── apps/
│   └── design-system-docs/  # Component documentation
└── static/images/       # Static assets
```

## Component Patterns

### Finding Components

**For traditional Calypso pages:**
1. **First**: Check `client/components/` for Calypso-specific components
2. **Then**: Check if `@wordpress/components` has what you need
3. **Finally**: Create new in `client/components/[component-name]/`

**For dashboard folder (`/client/dashboard`):**
1. **First**: Check `@wordpress/components` - this is the primary UI library
2. **Then**: Check `client/dashboard/components/` for dashboard-specific components
3. **Finally**: Create new in `client/dashboard/components/[component-name]/`
4. **Never**: Import from `calypso/components` or use Calypso CSS/state

### Component Structure

Each component should have its own folder [[memory:5415837]]:

```
client/components/my-component/
├── index.tsx           # Main component export
├── style.scss          # Component styles
├── types.ts            # TypeScript types (if complex)
└── test/
    └── index.tsx       # Tests
```

### Styling Approach

Use the codebase's color variables [[memory:5415477]]:

```scss
// Import the color variables
@import 'calypso/assets/stylesheets/shared/colors';

.my-component {
  color: var(--color-text);
  background: var(--color-surface);
  border: 1px solid var(--color-border-subtle);
}
```

Common color tokens:
- `--color-primary` - Primary brand color
- `--color-text` - Main text color
- `--color-text-subtle` - Secondary text
- `--color-surface` - Background surfaces
- `--color-border-subtle` - Light borders
- `--color-success`, `--color-warning`, `--color-error` - Status colors

## Page/Route Patterns

### Creating a New Page

Pages live in `client/my-sites/` or similar route directories:

```typescript
// client/my-sites/settings/new-setting/index.tsx
import { useTranslate } from 'i18n-calypso';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';

export default function NewSettingPage() {
  const translate = useTranslate();

  return (
    <Main>
      <NavigationHeader title={translate('New Setting')} />
      {/* Page content */}
    </Main>
  );
}
```

### Registering Routes

Routes are defined in section configurations. Look for patterns in existing sections.

## State Management

### Using Redux State

```typescript
import { useSelector, useDispatch } from 'calypso/state';
import { getSiteOption } from 'calypso/state/sites/selectors';
import { updateSiteSettings } from 'calypso/state/site-settings/actions';

function MyComponent({ siteId }) {
  const siteName = useSelector(state => getSiteOption(state, siteId, 'blogname'));
  const dispatch = useDispatch();

  const handleUpdate = () => {
    dispatch(updateSiteSettings(siteId, { blogname: 'New Name' }));
  };
}
```

### Using @wordpress/data

For newer features, prefer `@wordpress/data`:

```typescript
import { useSelect, useDispatch } from '@wordpress/data';
```

## Common UI Components

### From Calypso

```typescript
import Button from 'calypso/components/button';
import Card from 'calypso/components/card';
import FormLabel from 'calypso/components/forms/form-label';
import FormTextInput from 'calypso/components/forms/form-text-input';
import FormToggle from 'calypso/components/forms/form-toggle';
import Notice from 'calypso/components/notice';
import SectionHeader from 'calypso/components/section-header';
```

### From @wordpress/components

```typescript
import { Button, Card, TextControl, ToggleControl } from '@wordpress/components';
```

## Internationalization

Always wrap user-facing strings:

```typescript
import { useTranslate } from 'i18n-calypso';

function MyComponent() {
  const translate = useTranslate();
  return <h1>{translate('Settings')}</h1>;
}
```

## Dashboard Folder (`/client/dashboard`)

The `/client/dashboard` folder is a **redesign of Calypso** with its own architecture, design system, and development guidelines. It's a new Hosting Dashboard for WordPress.com built with modern design principles and a different tech stack than traditional Calypso.

### Key Differences from Traditional Calypso

| Aspect | Traditional Calypso | Dashboard Folder |
|--------|-------------------|------------------|
| **Components** | `calypso/components` | `@wordpress/components` first |
| **State** | Redux + `calypso/state` | TanStack Query (no Redux) |
| **Routing** | Calypso router | `@tanstack/react-router` |
| **Styling** | SCSS with Calypso variables | Minimal CSS, component-based |
| **i18n** | `i18n-calypso` | `@wordpress/i18n` + `@automattic/i18n-utils` |
| **API** | Redux actions/thunks | `lib/wp` REST API calls |

### Core Principles

1. **WordPress Components First**: Use `@wordpress/components` as the primary UI library
2. **Minimal CSS**: Avoid custom CSS as much as possible, preferring component composition
3. **No Redux**: Use TanStack Query for server state management
4. **Explicit Dependencies**: Be very explicit about what dependencies are included
5. **TypeScript**: Use TypeScript with simple, concrete types
6. **Performance**: Use loaders for data prefetching, placeholders instead of spinners

### Design System

The dashboard follows a component-based architecture with strong focus on the WordPress design system.

#### Layout Components

- **VStack/HStack**: Prefer these over Flex components for layout
- **Page Layout**: Main container for every dashboard page (`client/dashboard/components/page-layout`)
- **Header Bar**: Reusable header bar component (`client/dashboard/components/header-bar`)
- **Menu/Responsive Menu**: Mobile-friendly navigation menus (`client/dashboard/components/menu`, `client/dashboard/components/responsive-menu`)

#### Data Display Components

- **DataViews**: Core component for displaying lists in tabular, grid, or list format with sorting, filtering, and pagination. Part of the design system - check with design team before making changes.
- **DataForm**: Component for creating and editing data with form-based interface
- **Card Components**: Use `client/dashboard/components/card` (custom wrapper around WordPress Card) instead of importing directly from `@wordpress/components`

#### Other Key Components

Available in `client/dashboard/components/`:
- `callout`, `callout-skeleton`, `callout-overlay` - Callout components
- `text-skeleton`, `text-blur` - Placeholder components (use instead of spinners)
- `overview-card` - Standard card for data display
- `dataviews-card` - Card component for displaying data views
- `section-header` - Section headers
- `notice` - Notice components
- `stat` - Stat display components
- `summary-button`, `summary-button-list` - Summary button components

### Routing (`@tanstack/react-router`)

Routes use loaders to prefetch data before rendering:

```typescript
import { createRoute, createLazyRoute } from '@tanstack/react-router';

const myRoute = createRoute({
  getParentRoute: () => parentRoute,
  path: 'my-path',
  loader: async ({ params }) => {
    // Prefetch data using TanStack Query
    await queryClient.ensureQueryData(myQuery(params.id));
  },
}).lazy(() =>
  import('./my-component').then((d) =>
    createLazyRoute('my-route')({
      component: () => <d.default />,
    })
  )
);
```

**Key Points:**
- Routes are configuration-based and lazy-loaded
- Use `loader` functions to prefetch data
- Loaders use TanStack Query's `queryClient.ensureQueryData` for caching
- Components can use `useQuery` or `useSuspenseQuery` to access loader data

### Data Fetching (TanStack Query)

The dashboard uses TanStack Query for all data fetching:

```typescript
import { useQuery, useSuspenseQuery } from '@tanstack/react-query';
import { siteBySlugQuery } from '@automattic/api-queries';

// In component
const { data: site } = useSuspenseQuery(siteBySlugQuery(siteSlug));

// For dynamic/conditional queries
const { data, isLoading } = useQuery({
  ...myQuery(id),
  enabled: someCondition,
});
```

**Key Points:**
- Use queries from `@automattic/api-queries` package
- Route loaders and components share the same `queryClient` cache
- Prefer `useSuspenseQuery` when data is guaranteed (from loader)
- Use `useQuery` for conditional or dynamic data fetching

### Styling Guidelines

1. **Minimal CSS**: Avoid custom CSS, prefer component composition
2. **CSS Logical Properties**: Use logical properties for RTL support (e.g., `padding-inline` instead of `padding-left/right`)
3. **No AutoRTL**: Dashboard doesn't use Calypso's autortl processing - all languages use the same CSS
4. **Card Component**: Always use `client/dashboard/components/card` instead of `@wordpress/components` Card directly

### CSS Custom Properties (Dashboard)

The dashboard uses WordPress admin CSS custom properties. Key tokens:

```scss
// Theme/accent color (for focus rings, selections, primary actions)
var(--wp-admin-theme-color)

// Focus ring standard pattern
outline: 2px solid var(--wp-admin-theme-color);
outline-offset: 2px;

// Gray scale (from @wordpress/base-styles)
$gray-100  // Lightest
$gray-200
$gray-300
$gray-400
$gray-600
$gray-700
$gray-800
$gray-900  // Darkest

// Example usage
.my-component {
  &:focus {
    outline: 2px solid var(--wp-admin-theme-color);
    outline-offset: 2px;
  }

  input[type="radio"] {
    accent-color: var(--wp-admin-theme-color);
  }
}
```

**Note**: Do NOT use `--wp-components-color-accent` - it doesn't exist in the dashboard context. Always use `--wp-admin-theme-color` for accent/theme colors.

### Typography and Copy Guidelines

- **Sentence Case**: Use sentence case for almost everything (buttons, modal titles, form labels, DataViews field labels)
- **Punctuation**: End sentences with periods (except button/form labels and headings)
- **Quotes**: Use curly quotes and apostrophes ("like this" not "like this")
- **Snackbars**:
  - Toggles: "{Setting name} enabled." / "{Setting name} disabled."
  - Non-toggles: "{Setting name} saved."
  - Deletions: "{Setting name} deleted."
  - Errors: "Failed to {action} {setting name}."

### Internationalization

Use `@wordpress/i18n` and `@automattic/i18n-utils`:

```typescript
import { __ } from '@wordpress/i18n';
import { createInterpolateElement } from '@wordpress/element';

// Simple translation
__( 'Settings' )

// With interpolation (preferred approach)
createInterpolateElement(
  __( 'Invitation sent to <newOwnerEmail />' ),
  {
    newOwnerEmail: <strong>{ newOwnerEmail }</strong>,
  }
)
```

**Key Points:**
- Avoid `@automattic/i18n-calypso` (to be deprecated)
- Keep translations simple - avoid complex HTML tags or placeholders
- Apply formatting in code, not in translation strings

### Entry Points

The dashboard supports multiple entry points (WordPress.com, CIAB, etc.) with:
- Custom branding (logo, colors via CSS variables)
- Different feature sets via `supports` configuration
- Shared core functionality

Entry points are defined in `client/dashboard/app-*/` directories.

### Testing

- **E2E Testing**: Uses Calypso's existing infrastructure
  - Tests: `test/e2e/specs/dashboard/`
  - Page objects: `packages/calypso-e2e/src/lib/pages/dashboard-page.ts`
- **Performance Testing**: Key focus area
- Consider lighter testing approach without page objects for future

### Documentation

Comprehensive documentation is available in `client/dashboard/docs/`:
- `README.md` - Overview and principles
- `router.md` - Routing system documentation
- `data-library.md` - Data fetching and state management
- `ui-components.md` - Component architecture
- `typography-and-copy.md` - Typography and copy guidelines
- `testing.md` - Testing strategy
- `entry-points.md` - Entry point configuration
- `i18n.md` - Internationalization practices

### Important Notes

- **Avoid Calypso Dependencies**: Don't import Calypso's components, CSS, or state
- **Avoid CSS Overrides**: Don't rely on CSS overrides and hacks - work with design system
- **Document Hacks**: If hacks are necessary, document them in README with long-term solution
- **Check Design Team**: Before modifying DataViews or core design system components, check with design team

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

## Dev Commands

```bash
cd repos/calypso

# Start development server (takes 5+ minutes for initial build)
yarn start

# Start with debug mode (more memory, sourcemaps)
yarn start:debug

# Run tests
yarn test-client

# Type checking
yarn tsc

# Lint
yarn eslint
```

**Note on building:** Unlike Gutenberg and WordPress Core, Calypso's dev server (`yarn start`) handles building automatically. The initial build takes 5+ minutes, but subsequent starts are faster due to caching. No separate build step is required before running the dev server.

## Yarn Version (Important)

Calypso uses **Yarn 4.0.2** (Berry), NOT Yarn Classic (1.x). This matters because:
- The binary lives at `.yarn/releases/yarn-4.0.2.cjs` (set in `.yarnrc.yml`)
- `packageManager` in `package.json` is `yarn@4.0.2`
- PnP is NOT enabled — it uses `nodeLinker: node-modules`, so `node_modules/` still exists
- Some Yarn Classic commands behave differently (e.g., `yarn add` flags, workspace resolution)

## Entry Points Architecture

The dashboard supports multiple branded entry points, each defined in its own `app-*/` directory under `client/dashboard/`. They share a common boot sequence (`app/boot.tsx`) but configure different features, branding, and hostnames.

### How it works

Each entry point calls `boot()` with an `AppConfig` object that controls:
- **`name`** — Display name (e.g., `'WordPress.com'`, `'CIAB'`)
- **`basePath`** — URL base path
- **`Logo`** — Logo component (or `null`)
- **`supports`** — Feature flags toggling sites, domains, emails, themes, reader, plugins, etc.
- **`components`** — Lazy-loaded site list and switcher implementations
- **`queries`** — Configured TanStack Query functions for fetching sites

### Current entry points

| Entry Point | Directory | Dev URL | Production URL | Section Name |
|-------------|-----------|---------|----------------|--------------|
| **WordPress.com** | `client/dashboard/app-dotcom/` | `http://my.localhost:3000` | `https://my.wordpress.com` | `dashboard-dotcom` |
| **CIAB** | `client/dashboard/app-ciab/` | `http://my.woo.localhost:3000` | `https://my.woo.ai` | `dashboard-ciab` |

### Key files per entry point

```
client/dashboard/app-dotcom/     (or app-ciab/)
├── index.tsx       # Calls boot() with AppConfig — the main entry
├── routing.ts      # Hostname validation, link builders
├── section.ts      # Section definition (name + module path)
├── style.scss      # Entry-point-specific CSS
└── logo.tsx        # Logo component (dotcom only)
```

### Shared boot sequence (`app/boot.tsx`)

`boot()` initializes Sentry, support sessions, dev helpers, snackbar limits, then renders the `<Layout>` component inside a `persistQueryClient` wrapper. The `AppConfig` is passed through React context (`AppProvider`) so any component can read feature flags via `useAppContext()`.

### DashboardType

The system resolves which dashboard is active based on hostname: `'dotcom' | 'ciab'`. See `app/routing.ts` for `getCurrentDashboard()` and `buildDashboardLink()`.

## `@automattic/api-queries` Package

The dashboard's data layer. Lives at `packages/api-queries/` and provides ~119 query/mutation definition files.

### Pattern

Each file exports functions that return TanStack Query `queryOptions()` or `mutationOptions()` objects:

```typescript
import { queryOptions } from '@tanstack/react-query';
import { fetchSite } from '@automattic/api-core';

// Returns a queryOptions config — NOT a hook
export function siteBySlugQuery( siteSlug: string ) {
  return queryOptions( {
    queryKey: [ 'site-by-slug', siteSlug ],
    queryFn: () => fetchSite( siteSlug ),
  } );
}
```

### Usage in components

```typescript
import { useSuspenseQuery } from '@tanstack/react-query';
import { siteBySlugQuery } from '@automattic/api-queries';

const { data: site } = useSuspenseQuery( siteBySlugQuery( siteSlug ) );
```

### Usage in route loaders

```typescript
import { queryClient } from '@automattic/api-queries';

loader: async ( { params } ) => {
  await queryClient.ensureQueryData( siteBySlugQuery( params.siteSlug ) );
},
```

### Adding a new query

1. Create a file in `packages/api-queries/src/` (e.g., `my-feature.ts`)
2. Import the fetch function from `@automattic/api-core`
3. Export a function returning `queryOptions()` (or `mutationOptions()` for mutations)
4. Re-export from `packages/api-queries/src/index.ts`

The `@automattic/api-core` package handles the actual REST API calls; `api-queries` is the TanStack Query convenience layer on top.

## Testing

### Unit / Integration Tests

Run with:

```bash
# Run all client tests
yarn test-client

# Run a specific test file
yarn test-client client/dashboard/sites/test/index.test.tsx

# Find and run tests related to a source file
yarn test-client --findRelatedTests client/dashboard/sites/overview/index.tsx
```

Tests use **Jest** + **React Testing Library** with `userEvent`. For dashboard components, use the custom `render()` from `client/dashboard/test-utils.tsx` — it wraps components with all required providers (QueryClient, TanStack Router, Auth, Analytics contexts).

### API Mocking

Mock network requests at the boundary using **nock** to intercept REST API calls to `https://public-api.wordpress.com`. Do NOT mock React components, hooks, modules, or TanStack queries directly.

```typescript
import nock from 'nock';

nock( 'https://public-api.wordpress.com' )
  .get( '/rest/v1.1/sites/123' )
  .reply( 200, { ID: 123, name: 'Test Site' } );
```

### E2E Tests

End-to-end tests live in `test/e2e/` using Playwright:
- **Specs**: `test/e2e/specs/dashboard/` (e.g., `dashboard__authentication.spec.ts`, `dashboard__basic-and-routing.spec.ts`)
- **Page objects**: `packages/calypso-e2e/src/lib/pages/dashboard-page.ts`
- **Config**: `test/e2e/jest.config.js` and `test/e2e/playwright.config.ts`

### Testing Guidelines

The repo has detailed testing rules at `.claude/rules/dashboard-testing.md`:
- Test user-visible behavior, not implementation details
- Query by accessible role (`getByRole`, `findByRole`), never by test ID or CSS class
- If an element isn't reachable by role, fix the component's accessibility
- Keep test data minimal — use `as Type` for partial objects

## Dashboard Components (Full List)

`client/dashboard/components/` contains **70 components**. Beyond the ones already documented above, notable additions:

| Component | Purpose |
|-----------|---------|
| `action-list` | Action list display |
| `clipboard-input-control` | Copy-to-clipboard input |
| `code-highlighter` | Syntax highlighting |
| `collapsible-card` | Expandable card |
| `confirm-modal` | Confirmation dialogs |
| `date-range-picker` | Date range selection |
| `domain-contact-details-form` | Domain contact form |
| `empty-state` | Empty state placeholders |
| `flash-message` | Temporary flash messages |
| `full-screen-overlay` | Full-screen modal overlay |
| `guided-tour` | Step-by-step guided tours |
| `icon-list` | Icon list display |
| `inline-support-link` | Inline help/support links |
| `input-control` | Form input wrapper |
| `loading-line` | Thin loading progress line |
| `logs-activity` | Activity log display |
| `metadata-list` | Key-value metadata display |
| `offer-card` | Promotional offer cards |
| `page-header` | Page header (separate from `header-bar`) |
| `phone-number-input` | Phone number input with country codes |
| `price-display` | Price formatting |
| `purchase-dialogs` | Purchase-related dialogs |
| `router-link-button` | Button that navigates via TanStack Router |
| `segmented-bar` | Segmented progress/stat bar |
| `site-environment-badge` | Staging/production badge |
| `site-icon` | Site favicon display |
| `site-preview-link` | Link to site preview |
| `switcher` | Generic switcher component |
| `truncate` | Text truncation |
| `upsell-cta-button` | Upsell call-to-action |

## Dev Server Performance

### Initial build is slow

Calypso's webpack build compiles ALL entry points by default. The initial `yarn start` takes **5+ minutes**. Subsequent starts are faster because webpack caches the build.

### Limiting entry points with `ENTRY_LIMIT`

To speed up dev server startup, use `ENTRY_LIMIT` to build only the entry points you need:

```bash
# Dashboard only (what yarn start-dashboard does internally)
ENTRY_LIMIT=entry-dashboard-dotcom,entry-dashboard-ciab yarn start

# Or use the convenience script
yarn start-dashboard
```

The `yarn start-dashboard` command sets `CALYPSO_ENV=dashboard-development` and `ENTRY_LIMIT=entry-dashboard-dotcom,entry-dashboard-ciab` automatically. This is significantly faster than a full build.

`ENTRY_LIMIT` accepts a comma-separated list of entry point names. The webpack config in `client/webpack.config.js` filters the entry points based on this value.

## TanStack Router Patterns (Dashboard)

Route files live in `client/dashboard/app/router/` with one file per top-level section:

```
app/router/
├── index.tsx      # Router creation, root provider
├── root.tsx       # Root route with beforeLoad auth check
├── sites.tsx      # Sites and per-site routes
├── domains.ts     # Domain management routes
├── emails.tsx     # Email routes
├── me.tsx         # User profile routes
├── plugins.tsx    # Plugin routes
```

### `beforeLoad` hooks

Used for auth checks, performance tracking, and data validation before the route renders:

```typescript
export const siteRoute = createRoute( {
  getParentRoute: () => rootRoute,
  path: 'sites/$siteSlug',
  beforeLoad: async ( { cause, params: { siteSlug }, location } ) => {
    if ( cause === 'preload' ) {
      return;  // Skip for prefetch
    }
    // Validate site exists, check permissions, redirect if needed
    const site = await queryClient.ensureQueryData( siteBySlugQuery( siteSlug ) );
  },
  loader: async ( { context } ) => {
    // Prefetch data for rendering
    await Promise.all( [
      queryClient.ensureQueryData( siteSettingsQuery( siteId ) ),
      queryClient.ensureQueryData( siteDomainsQuery( siteId ) ),
    ] );
  },
} );
```

### Lazy loading

Routes use `createLazyRoute` and `lazyRouteComponent` to code-split page components:

```typescript
const myRoute = createRoute( { /* config */ } )
  .lazy( () =>
    import( './my-page' ).then( ( d ) =>
      createLazyRoute( 'my-route' )( {
        component: () => <d.default />,
      } )
    )
  );
```

## Legacy Routing (`client/sections.js`)

Traditional Calypso routes are registered in `client/sections.js` (~934 lines). Each section is an object with:

```javascript
{
  name: 'account',           // Section identifier
  paths: [ '/me/account' ],  // URL paths that trigger this section
  module: 'calypso/me/account',  // Module to load
  group: 'me',               // Navigation group
  enableLoggedOut: true,      // Optional: allow unauthenticated access
}
```

Webpack uses this file to create code-split chunks — each section becomes its own bundle. The dashboard entry points (`dashboard-dotcom`, `dashboard-ciab`) are registered separately via their `section.ts` files, not in `sections.js`.

## `wpcomLink()` Utility

Used in the dashboard to generate correct links to WordPress.com/Calypso pages across environments:

```typescript
import { wpcomLink } from '@automattic/dashboard/utils/link';

// Dev: returns http://calypso.localhost:3000/me/security
// Prod: returns https://wordpress.com/me/security
<a href={ wpcomLink( '/me/security' ) }>Security Settings</a>
```

The actual import path in the codebase is relative: `../../utils/link` (from within `client/dashboard/`). The file lives at `client/dashboard/utils/link.ts`. It reads the `wpcom_url` config key to determine the hostname.

**Always use `wpcomLink()` for links to old Calypso/WordPress.com pages.** Never hardcode `https://wordpress.com` or use bare relative paths.

Also in `utils/link.ts`:
- `dashboardLink()` — link back to the current dashboard
- `a4aLink()` — link to Automattic for Agencies
- `reauthRequiredLink()` — link to re-authentication page

## Code Review & AI Guidelines

Calypso has AI-specific guidance files in the repo:
- **`CLAUDE.md`** — Points to `AGENTS.md`
- **`AGENTS.md`** — Repository layout, client descriptions, dev commands
- **`client/AGENTS.md`** — React/TypeScript code style, testing, WordPress component preferences
- **`client/dashboard/AGENTS.md`** — Dashboard-specific review guidelines (external link handling, mutation callbacks, typography compliance)
- **`.claude/rules/pr.md`** — PR creation rules (draft PRs, branch naming, description guidelines)
- **`.claude/rules/dashboard-testing.md`** — Dashboard testing rules (behavior-driven, nock mocking, role-based queries)

## CSS Logical Properties (Dashboard)

The dashboard uses CSS logical properties for RTL language support. There is no AutoRTL processing — all languages share the same CSS. Use logical properties instead of physical ones:

| Physical (avoid) | Logical (use) |
|-------------------|---------------|
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `padding-left` | `padding-inline-start` |
| `padding-right` | `padding-inline-end` |
| `text-align: left` | `text-align: start` |
| `border-left` | `border-inline-start` |

## AI Context Files

Read these for additional context:
- `CLAUDE.md` - AI-specific guidance
- `AGENTS.md` - Agent behavior rules
