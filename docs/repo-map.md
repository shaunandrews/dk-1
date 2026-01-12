# Repository Map

This document explains how Calypso, Gutenberg, and WordPress Core connect and work together.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              USERS                                       │
│                     (Designers, Developers, Visitors)                    │
└─────────────────────────────────────┬───────────────────────────────────┘
                                      │
                  ┌───────────────────┼───────────────────┐
                  │                   │                   │
                  ▼                   ▼                   ▼
┌─────────────────────┐   ┌─────────────────┐   ┌─────────────────────────┐
│      CALYPSO        │   │    GUTENBERG    │   │    WORDPRESS CORE       │
│                     │   │                 │   │                         │
│  WordPress.com      │   │  Block Editor   │   │  Server Software        │
│  Dashboard          │   │  & Components   │   │                         │
│                     │   │                 │   │  • REST API             │
│  • Site management  │   │  • @wordpress/  │   │  • Database             │
│  • Settings UI      │   │    components   │   │  • Authentication       │
│  • Media library    │   │  • Block library│   │  • Block rendering      │
│  • Stats & hosting  │   │  • Editor tools │   │  • Plugin/Theme system  │
└──────────┬──────────┘   └────────┬────────┘   └────────────┬────────────┘
           │                       │                         │
           │    npm packages       │      Syncs to Core      │
           │◄──────────────────────┤                         │
           │                       ├────────────────────────►│
           │              REST API                           │
           └────────────────────────────────────────────────►│
```

## The Three Repositories

### Calypso (`repos/calypso`)

**What it is**: The WordPress.com dashboard - a React/TypeScript application.

**What it does**:
- Provides the UI for managing WordPress.com sites
- Handles site settings, media, users, and more
- Embeds Gutenberg for content editing
- Communicates with WordPress via REST API

**Key paths**:
```
client/
├── components/          # Reusable UI components
├── my-sites/            # Site management pages
├── layout/              # App shell
├── state/               # Redux state
└── assets/stylesheets/  # Global styles

packages/                # Shared internal packages
apps/design-system-docs/ # Component documentation
```

**Tech stack**: React, TypeScript, Redux, SCSS

---

### Gutenberg (`repos/gutenberg`)

**What it is**: The WordPress Block Editor and component library.

**What it does**:
- Provides `@wordpress/components` - the canonical UI component library
- Defines the block editor framework
- Contains all core blocks (paragraph, image, etc.)
- Exports shared packages used across the ecosystem

**Key paths**:
```
packages/
├── components/          # @wordpress/components (THE component library)
├── block-library/       # Core blocks
├── block-editor/        # Editor framework
├── icons/               # @wordpress/icons
├── data/                # @wordpress/data (state management)
└── editor/              # Post editor

storybook/               # Component documentation
```

**Tech stack**: React, JavaScript/TypeScript, SCSS

**Shared packages** (used by Calypso and plugins):
- `@wordpress/components` - UI components
- `@wordpress/icons` - Icon library
- `@wordpress/data` - State management
- `@wordpress/api-fetch` - API communication
- `@wordpress/element` - React wrapper
- `@wordpress/i18n` - Internationalization

---

### WordPress Core (`repos/wordpress-core`)

**What it is**: The server-side WordPress software.

**What it does**:
- Provides REST API endpoints
- Stores data in MySQL database
- Handles authentication and permissions
- Renders blocks on the frontend
- Manages plugins and themes

**Key paths**:
```
src/
├── wp-admin/            # Admin dashboard (PHP)
├── wp-includes/
│   ├── rest-api/        # REST API endpoints
│   ├── blocks/          # Core blocks (PHP)
│   └── class-wp-*.php   # Core classes
├── wp-content/
│   ├── themes/          # Bundled themes
│   └── plugins/         # Bundled plugins
└── js/_enqueues/        # JavaScript files
```

**Tech stack**: PHP, MySQL, JavaScript

## How They Connect

### Connection 1: Gutenberg → Calypso (npm packages)

Calypso imports Gutenberg packages via npm:

```json
// repos/calypso/package.json
{
  "dependencies": {
    "@wordpress/components": "^25.0.0",
    "@wordpress/icons": "^9.0.0",
    "@wordpress/data": "^9.0.0"
  }
}
```

Usage in Calypso:
```tsx
import { Button, Card } from '@wordpress/components';
import { Icon, settings } from '@wordpress/icons';
```

### Connection 2: Calypso → WordPress Core (REST API)

Calypso communicates with WordPress sites via the REST API:

```tsx
// In Calypso
import apiFetch from '@wordpress/api-fetch';

// Fetch posts
const posts = await apiFetch({ path: '/wp/v2/posts' });

// Update settings
await apiFetch({
  path: '/wp/v2/settings',
  method: 'POST',
  data: { title: 'New Site Title' }
});
```

**Common endpoints**:
| Endpoint | Purpose |
|----------|---------|
| `/wp/v2/posts` | Posts CRUD |
| `/wp/v2/pages` | Pages CRUD |
| `/wp/v2/media` | Media library |
| `/wp/v2/settings` | Site settings |
| `/wp/v2/users` | User management |
| `/wp/v2/blocks` | Reusable blocks |

### Connection 3: Gutenberg → WordPress Core (Sync)

Gutenberg blocks and packages are synced to WordPress Core during releases:

- Development: `repos/gutenberg/packages/block-library/src/paragraph/`
- In Core: `repos/wordpress-core/src/wp-includes/blocks/paragraph/`

The sync happens through the WordPress release process.

## Feature Flow Examples

### Example: User Changes Site Title

```
1. User opens Settings in Calypso
   └── Calypso loads client/my-sites/settings/

2. User types new title, clicks "Save"
   └── Calypso calls: POST /wp/v2/settings
   
3. Request hits WordPress Core
   └── Core validates, updates wp_options table
   
4. Core responds with success
   └── Calypso shows "Saved" confirmation
```

### Example: User Adds Image Block

```
1. User opens post editor in Calypso
   └── Gutenberg editor loads

2. User clicks "+" and selects Image block
   └── Gutenberg renders packages/block-library/src/image/edit.js

3. User uploads image
   └── Calypso calls: POST /wp/v2/media

4. User publishes post
   └── Block serialized: <!-- wp:image {"id":123} -->
   └── Calypso calls: POST /wp/v2/posts

5. Visitor views post
   └── Core renders block using PHP render callback
```

### Example: Creating a New Feature

If you're building a feature that needs work in multiple repos:

```
1. WordPress Core (if new API needed)
   └── Add REST endpoint in src/wp-includes/rest-api/endpoints/

2. Gutenberg (if new component/block needed)
   └── Create in packages/components/ or packages/block-library/

3. Calypso (UI for the feature)
   └── Create page in client/my-sites/
   └── Use components from @wordpress/components
   └── Call REST API to save/load data
```

## Data Flows

### Read Flow (Getting Data)

```
Calypso UI Component
    ↓
useSelect() or apiFetch()
    ↓
GET /wp/v2/[resource]
    ↓
WordPress Core REST Controller
    ↓
Database Query
    ↓
JSON Response
    ↓
Calypso renders data
```

### Write Flow (Saving Data)

```
User Action (click save)
    ↓
Form handler in Calypso
    ↓
apiFetch({ method: 'POST', data: {...} })
    ↓
WordPress Core REST Controller
    ↓
Validation & Permission Check
    ↓
Database Update
    ↓
Success Response
    ↓
Calypso shows confirmation
```

## Where to Make Changes

| If you need to... | Work in... |
|-------------------|------------|
| Create a new UI page | Calypso (`client/my-sites/`) |
| Use existing components | Import from `@wordpress/components` |
| Create a new component | Gutenberg (`packages/components/`) or Calypso (`client/components/`) |
| Create a new block | Gutenberg (`packages/block-library/`) |
| Add a REST endpoint | WordPress Core (`src/wp-includes/rest-api/`) |
| Store new data | WordPress Core (options, post meta, custom table) |
| Add admin page (PHP) | WordPress Core (`src/wp-admin/`) |

## Quick Reference

### Start Dev Servers

```bash
# Calypso
cd repos/calypso && yarn start
# → http://calypso.localhost:3000

# Gutenberg
cd repos/gutenberg && npm run dev
# → http://localhost:9999

# Gutenberg Storybook (for components)
cd repos/gutenberg && npm run storybook
# → http://localhost:50240

# WordPress Core
cd repos/wordpress-core && npm run dev
# → http://localhost:8889
```

### Find Things

```bash
# Find a component
ls repos/gutenberg/packages/components/src/
ls repos/calypso/client/components/

# Find a block
ls repos/gutenberg/packages/block-library/src/

# Find REST endpoint
grep -r "register_rest_route" repos/wordpress-core/src/wp-includes/rest-api/
```
