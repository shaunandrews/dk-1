---
description: Cross-repository workflows and connections
globs: ["**/*"]
---

# Cross-Repo

Help the designer understand how Calypso, Gutenberg, and WordPress Core connect, and navigate features that span multiple repositories.

## Repository Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                        Calypso                               │
│              (WordPress.com Dashboard)                       │
│                                                              │
│  Uses: @wordpress/components, @wordpress/data, REST API      │
└─────────────────────────────┬───────────────────────────────┘
                              │
                    REST API  │  npm packages
                              │
┌─────────────────────────────┴───────────────────────────────┐
│                       Gutenberg                              │
│           (Block Editor & Component Library)                 │
│                                                              │
│  Exports: @wordpress/components, @wordpress/icons,           │
│           @wordpress/block-editor, @wordpress/data           │
└───────────────────┬─────────────────────┬───────────────────┘
                    │                     │
         Syncs to   │  PHP packages       │  Block API
                    │                     │
┌───────────────────┴─────────────────────┼───────────────────┐
│                    WordPress Core       │                    │
│                (Foundation Software)    │                    │
│                                         │                    │
│  Provides: REST API, Database, Hooks,   │                    │
│            Block infrastructure         │                    │
└───────────────────┬─────────────────────┼───────────────────┘
                    │                     │
           Playground│                    │ Generates blocks
                    │                     │
                    │     ┌───────────────┴───────────────────┐
                    └────►│              Telex                 │
                          │    (AI Block Authoring Tool)       │
                          │                                    │
                          │  Uses: @wordpress/blocks,          │
                          │        WordPress Playground        │
                          │  Outputs: Block plugins (.zip)     │
                          └────────────────────────────────────┘
```

## The Big Picture

```
┌──────────────────────────────────────────────────────────────────┐
│                         USER'S BROWSER                           │
└──────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────────┐
│                           CALYPSO                                │
│                   (WordPress.com Dashboard)                      │
│                                                                  │
│  • Site management UI                                            │
│  • Settings pages                                                │
│  • Media library                                                 │
│  • Stats & analytics                                             │
│  • Embeds Gutenberg for editing                                  │
└────────────────────────────┬─────────────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
┌─────────────────────────┐   ┌─────────────────────────────────────┐
│       GUTENBERG         │   │           REST API                  │
│    (Block Editor)       │   │    (WordPress Core)                 │
│                         │   │                                     │
│ • @wordpress/components │   │  /wp-json/wp/v2/posts              │
│ • Block library         │   │  /wp-json/wp/v2/pages              │
│ • Editor framework      │   │  /wp-json/wp/v2/settings           │
└───────────┬─────────────┘   └───────────────┬─────────────────────┘
            │                                 │
            └─────────────┬───────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                      WORDPRESS CORE                              │
│                   (Server & Database)                            │
│                                                                  │
│  • Data storage (MySQL)                                          │
│  • REST API endpoints                                            │
│  • Authentication                                                │
│  • Hooks & filters                                               │
│  • Block rendering                                               │
└──────────────────────────────────────────────────────────────────┘
```

## Development Environment (wp-env)

**CRITICAL:** When both `repos/wordpress-core` and `repos/gutenberg` exist, ONLY use the wordpress-core wp-env. NEVER start gutenberg's wp-env when wordpress-core is present.

Before starting any wp-env:
1. Check if `repos/wordpress-core` exists
2. If yes, use `repos/wordpress-core` for `npm run dev`
3. If only gutenberg exists, then gutenberg's `npm run dev` is acceptable

For gutenberg component work when wordpress-core exists, use `npm run storybook` instead of `npm run dev`.

## Connection Points

### 1. Calypso ↔ Gutenberg (npm packages)

**How they connect**: Calypso imports Gutenberg packages via npm.

**Shared packages**:
- `@wordpress/components` - UI components
- `@wordpress/icons` - Icon library
- `@wordpress/data` - State management
- `@wordpress/api-fetch` - API calls
- `@wordpress/element` - React wrapper
- `@wordpress/i18n` - Internationalization

**Example**:
```tsx
// In Calypso, using Gutenberg components
import { Button, Card, TextControl } from '@wordpress/components';
import { Icon, settings } from '@wordpress/icons';
```

### 2. Calypso ↔ WordPress Core (REST API)

**How they connect**: Calypso calls WordPress REST API endpoints.

**Common endpoints used by Calypso**:

| Endpoint | Purpose |
|----------|---------|
| `GET /wp/v2/posts` | List posts |
| `POST /wp/v2/posts` | Create post |
| `GET /wp/v2/settings` | Get site settings |
| `POST /wp/v2/settings` | Update settings |
| `GET /wp/v2/users/me` | Current user info |
| `GET /wp/v2/media` | Media library |

**Example**:
```tsx
// In Calypso
import apiFetch from '@wordpress/api-fetch';

// Fetch posts
const posts = await apiFetch({ path: '/wp/v2/posts' });

// Update a setting
await apiFetch({
  path: '/wp/v2/settings',
  method: 'POST',
  data: { title: 'New Site Title' }
});
```

### 3. Gutenberg ↔ WordPress Core (PHP + Sync)

**How they connect**:
- Gutenberg packages are synced to Core during releases
- Blocks are registered in both PHP and JS
- Block rendering can happen server-side

**Where blocks live**:
- Development: `repos/gutenberg/packages/block-library/src/`
- In Core: `repos/wordpress-core/src/wp-includes/blocks/`

## Shared Packages Reference

| Package | Source | Used In |
|---------|--------|---------|
| `@wordpress/components` | Gutenberg | Calypso, Gutenberg, Plugins, Telex |
| `@wordpress/icons` | Gutenberg | Calypso, Gutenberg, Plugins, Telex |
| `@wordpress/data` | Gutenberg | Calypso, Gutenberg |
| `@wordpress/api-fetch` | Gutenberg | Calypso, Gutenberg |
| `@wordpress/element` | Gutenberg | Calypso, Gutenberg |
| `@wordpress/i18n` | Gutenberg | All |
| `@wordpress/blocks` | Gutenberg | Gutenberg, Telex (generated) |
| `@wordpress/block-editor` | Gutenberg | Gutenberg, Telex (generated) |
| `@wp-playground/client` | WordPress | Telex |

## API Boundaries

### Calypso → WordPress (REST API)

```
Base: https://public-api.wordpress.com/wp/v2/sites/{site_id}/

Common endpoints:
  GET  /posts                    # List posts
  POST /posts                    # Create post
  GET  /posts/{id}               # Get post
  PUT  /posts/{id}               # Update post
  GET  /settings                 # Site settings
  POST /settings                 # Update settings
  GET  /users/me                 # Current user
```

### Gutenberg → WordPress Core

Gutenberg blocks communicate with Core via:
- Block attributes (saved to post content)
- `@wordpress/core-data` for entity operations
- ServerSideRender for PHP-rendered blocks

---

## Common Cross-Repo Scenarios

### Scenario 1: Add a Settings Page in Calypso that Saves to WordPress

**Flow**: Calypso UI → REST API → WordPress Core

1. **Calypso** (`repos/calypso`):
   - Create the settings page UI in `client/my-sites/`
   - Use `@wordpress/components` for form elements
   - Call WordPress REST API to save

2. **WordPress Core** (`repos/wordpress-core`):
   - Ensure REST endpoint exists (usually `/wp-json/wp/v2/settings`)
   - Or create custom endpoint if needed

```typescript
// Calypso: Call WP REST API
import apiFetch from '@wordpress/api-fetch';

const saveSettings = async (settings) => {
  await apiFetch({
    path: '/wp/v2/settings',
    method: 'POST',
    data: settings,
  });
};
```

### Scenario 2: Create a New Block with Calypso Integration

**Flow**: Gutenberg Block → WordPress Core → Calypso Editor

1. **Gutenberg** (`repos/gutenberg`):
   - Create block in `packages/block-library/src/`
   - Define attributes, edit, and save components

2. **WordPress Core**:
   - Block syncs to Core via release process
   - Available in `src/wp-includes/blocks/`

3. **Calypso**:
   - Block automatically available in Calypso's editor
   - Custom Calypso blocks go in `client/blocks/`

### Scenario 3: Use @wordpress/components in Calypso

**Flow**: Gutenberg packages → npm → Calypso

Calypso consumes Gutenberg packages via npm:

```typescript
// In Calypso
import { Button, Card, TextControl } from '@wordpress/components';
import { Icon, settings } from '@wordpress/icons';
```

These packages are:
- Developed in `repos/gutenberg/packages/`
- Published to npm as `@wordpress/*`
- Consumed by `repos/calypso/package.json`

### Scenario 4: Add REST API Endpoint Called by Calypso

**Flow**: WordPress Core API → Calypso fetch

1. **WordPress Core** (`repos/wordpress-core`):

```php
// src/wp-includes/rest-api/endpoints/class-wp-rest-my-controller.php
register_rest_route('wp/v2', '/my-custom-data', [
    'methods'  => 'GET',
    'callback' => function($request) {
        return rest_ensure_response(['data' => 'value']);
    },
    'permission_callback' => function() {
        return current_user_can('read');
    },
]);
```

2. **Calypso** (`repos/calypso`):

```typescript
import apiFetch from '@wordpress/api-fetch';

const fetchMyData = async (siteId) => {
  const response = await apiFetch({
    path: `/wp/v2/my-custom-data`,
    apiNamespace: 'wp/v2',
  });
  return response;
};
```

### Scenario 5: Generate a Block with Telex and Test in WordPress

**Flow**: Telex AI → Block Plugin → WordPress Playground → (Optional) WordPress Core

Telex generates blocks from natural language prompts:

1. **Telex** (`repos/telex`):
   - User describes block in natural language
   - AI generates block code as an artefact (XML)
   - Block is built and previewed in WordPress Playground

2. **Testing**:
   - Preview immediately in Telex's embedded WordPress Playground
   - Export as `.zip` plugin for installation elsewhere

3. **Integration** (if contributing to ecosystem):
   - Refine block code to match Gutenberg patterns
   - Consider contributing to `repos/gutenberg/packages/block-library/`
   - Or create as a standalone plugin

```typescript
// Telex artefact workflow
// 1. User prompt → AI generates artefact XML
// 2. Artefact extracted to block files
// 3. Block built with @wordpress/scripts
// 4. Preview in WordPress Playground
// 5. Export as installable plugin
```

### Scenario 6: Improve Telex's Block Generation

**Flow**: Gutenberg patterns → Telex AI context → Better blocks

When improving Telex's block output quality:

1. **Gutenberg** (`repos/gutenberg`):
   - Study patterns in `packages/block-library/src/`
   - Understand best practices from core blocks

2. **Telex** (`repos/telex`):
   - Update AI prompts in `spec/prompts/`
   - Improve artefact schema in `spec/artefact.xsd`
   - Update validation in `client/packages/artefact-utils/`

### Telex Storage Architecture

Telex differs from other repos in how it persists data. While Calypso, Gutenberg, and Core use MySQL databases (via the WordPress REST API), Telex uses **S3-compatible object storage** (MinIO locally, S3 in production) as its source of truth for all persistent data:

- **Artefacts** (XML project files), **versions**, **chat history**, and **project state** are stored as objects in S3 buckets
- Local disk is only used as scratch space for block builds
- This means Telex has no traditional database — everything is keyed by project/user IDs in S3 paths

In local development, MinIO provides the S3-compatible storage (started via `pnpm run minio:start` in the Telex repo).

---

## Feature Flow Examples

### Example 1: User Updates Site Title

```
1. User clicks "Settings" in Calypso
   └─► Calypso renders settings page (client/my-sites/site-settings/)

2. User types new title, clicks "Save"
   └─► Calypso calls: POST /wp/v2/settings { title: "New Title" }

3. WordPress Core receives request
   └─► Validates & saves to wp_options table

4. Core returns success response
   └─► Calypso updates UI to show saved state
```

**Files involved**:
- `repos/calypso/client/my-sites/site-settings/...`
- `repos/wordpress-core/src/wp-includes/rest-api/endpoints/class-wp-rest-settings-controller.php`

### Example 2: User Creates a New Block

```
1. User opens post editor in Calypso
   └─► Calypso loads Gutenberg editor

2. User clicks "+" to add block, selects "Quote"
   └─► Gutenberg's Quote block edit component renders

3. User types quote text, clicks "Publish"
   └─► Block content serialized: <!-- wp:quote --><blockquote>...</blockquote><!-- /wp:quote -->
   └─► Calypso calls: POST /wp/v2/posts { content: "..." }

4. WordPress Core saves post
   └─► Block stored in post_content column

5. Visitor views post on frontend
   └─► Core renders block using render callback
```

**Files involved**:
- `repos/calypso/client/` (editor shell)
- `repos/gutenberg/packages/block-library/src/quote/`
- `repos/wordpress-core/src/wp-includes/blocks/quote/`

## Data Flow Patterns

### Read Pattern (GET)

```
Calypso Component
    │
    └─► useSelect() or apiFetch()
           │
           └─► GET /wp/v2/[resource]
                  │
                  └─► WordPress Core
                         │
                         └─► Database Query
                                │
                                └─► JSON Response
```

### Write Pattern (POST/PUT)

```
User Action in Calypso
    │
    └─► Form Submit Handler
           │
           └─► apiFetch({ method: 'POST', data: {...} })
                  │
                  └─► WordPress Core
                         │
                         ├─► Validation
                         ├─► Permission Check
                         └─► Database Update
                                │
                                └─► Success/Error Response
```

---

## Finding Related Code

### "Where is X handled?"

| Question | Where to Look |
|----------|---------------|
| Where is this setting saved? | Core: `src/wp-includes/option.php` |
| Where is this API called? | Calypso: grep for `apiFetch` or `wp/v2` |
| Where is this component defined? | Gutenberg: `packages/components/src/` |
| Where is this block defined? | Gutenberg: `packages/block-library/src/` |
| Where is this REST endpoint? | Core: `src/wp-includes/rest-api/endpoints/` |

## Common Cross-Repo Tasks

### Task: Add a new site setting

1. **Core** - Register setting:
   ```php
   register_setting('general', 'my_new_setting');
   ```

2. **Core** - Expose via REST:
   ```php
   register_rest_field('settings', 'my_new_setting', [...]);
   ```

3. **Calypso** - Create UI:
   ```tsx
   // New page in client/my-sites/site-settings/
   ```

### Task: Create a custom block

1. **Gutenberg** - Create block:
   ```
   packages/block-library/src/my-block/
   ```

2. **Core** - Block syncs automatically on release

3. **Calypso** - Block available in editor automatically

## Feature Flag Coordination

When building features across repos, you may need feature flags in multiple places:

### Calypso Feature Flags

```typescript
// config/development.json
{
  "features": {
    "my-feature": true
  }
}

// Usage
import config from '@automattic/calypso-config';
if (config.isEnabled('my-feature')) {
  // Feature code
}
```

### Gutenberg Experiments

```javascript
// Check for experimental features
import { __experimentalFeature } from '@wordpress/experiments';
```

### WordPress Core Feature Flags

```php
// Via constants in wp-config.php
if (defined('MY_FEATURE_FLAG') && MY_FEATURE_FLAG) {
    // Feature code
}

// Or via options
if (get_option('my_feature_enabled')) {
    // Feature code
}
```

## Coordinating Changes

When a feature requires changes to multiple repos:

1. **Plan the sequence**: Usually Core API → Gutenberg → Calypso
2. **Use feature flags**: Ship disabled, enable when all pieces are ready
3. **Version dependencies**: Calypso may need to wait for npm publish
4. **Test integration**: Use local linking for development

### Local Development Linking

```bash
# Link Gutenberg packages to Calypso for testing
cd repos/gutenberg
npm link ./packages/components

cd repos/calypso
npm link @wordpress/components
```

## When Things Connect

| User Action | Calypso | Gutenberg | Core | Telex |
|-------------|---------|-----------|------|-------|
| Edit post | Router, shell | Block editor | REST API, storage | - |
| Change setting | Settings UI | - | Options API | - |
| Upload media | Media library | Media blocks | REST API, files | - |
| Install plugin | Plugin UI | - | Plugins API | - |
| View stats | Stats pages | - | Jetpack/API | - |
| Create block | - | Block patterns | Block registration | AI generation, Playground preview |
| Test block | - | Storybook | wp-env | WordPress Playground |

---

## Response Pattern

When designer asks about cross-repo connections:

1. **Identify the repos involved** - Which parts touch which repo?
2. **Explain the connection type** - npm package, REST API, or sync?
3. **Show the data flow** - How does info move between repos?
4. **Point to specific files** - Where to look in each repo
5. **Suggest approach** - Which repo to start with
