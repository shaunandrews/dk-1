# Skill: Cross-Repo Navigation

**Purpose**: Help designers understand how Calypso, Gutenberg, and WordPress Core connect, and navigate features that span multiple repositories.

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

**Example flow**:
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

**Example flow**:
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

**Example block registration**:
```php
// In WordPress Core (PHP)
register_block_type('core/paragraph', [
    'render_callback' => 'render_block_core_paragraph'
]);
```

```js
// In Gutenberg (JS)
registerBlockType('core/paragraph', {
    edit: Edit,
    save: Save,
});
```

## Feature Flow Examples

### Example 1: User Updates Site Title

```
1. User clicks "Settings" in Calypso
   └─► Calypso renders settings page (client/my-sites/settings/)

2. User types new title, clicks "Save"
   └─► Calypso calls: POST /wp/v2/settings { title: "New Title" }

3. WordPress Core receives request
   └─► Validates & saves to wp_options table

4. Core returns success response
   └─► Calypso updates UI to show saved state
```

**Files involved**:
- `repos/calypso/client/my-sites/settings/...`
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

### Example 3: New Admin Setting Across All Three Repos

When you need a new setting that touches everything:

```
1. WordPress Core: Create REST endpoint
   └─► repos/wordpress-core/src/wp-includes/rest-api/endpoints/

2. WordPress Core: Create option storage
   └─► register_setting() in appropriate hook

3. Gutenberg: (if editor integration needed)
   └─► Add to relevant store or settings panel

4. Calypso: Create settings UI
   └─► repos/calypso/client/my-sites/settings/
```

## Finding Related Code

### "Where is X handled?"

| Question | Where to Look |
|----------|---------------|
| Where is this setting saved? | Core: `src/wp-includes/option.php` |
| Where is this API called? | Calypso: grep for `apiFetch` or `wp/v2` |
| Where is this component defined? | Gutenberg: `packages/components/src/` |
| Where is this block defined? | Gutenberg: `packages/block-library/src/` |
| Where is this REST endpoint? | Core: `src/wp-includes/rest-api/endpoints/` |

### Quick Search Commands

```bash
# Find API endpoint in Core
grep -r "register_rest_route.*my-endpoint" repos/wordpress-core/

# Find API call in Calypso
grep -r "/wp/v2/my-endpoint" repos/calypso/client/

# Find component usage across repos
grep -r "import.*MyComponent" repos/calypso repos/gutenberg
```

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
   // New page in client/my-sites/settings/
   ```

### Task: Create a custom block

1. **Gutenberg** - Create block:
   ```
   packages/block-library/src/my-block/
   ```

2. **Core** - Block syncs automatically on release

3. **Calypso** - Block available in editor automatically

## Debugging Connections

### API Issues
```bash
# Watch network calls in Calypso
# Browser DevTools → Network tab → filter "wp/v2"

# Test endpoint directly
curl -X GET "http://localhost:8889/wp-json/wp/v2/posts"
```

### Component Issues
```bash
# Check package version in Calypso
cat repos/calypso/package.json | grep "@wordpress/components"

# Compare with Gutenberg
cat repos/gutenberg/packages/components/package.json | grep "version"
```
