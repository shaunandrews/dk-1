---
name: cross-repo-workflow
description: Understand and navigate features that span multiple Design Kit repositories (Calypso, Gutenberg, WordPress Core, Jetpack, CIAB, Telex)
---

# Design Kit: Cross-Repository Workflow

This skill helps you understand how features flow across multiple repositories in the WordPress ecosystem and identify which repos need changes for a given feature.

## The Connection Map

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

CIAB ────(REST API)─────→ WordPress Core

Telex → generates blocks → WordPress Playground preview
```

## Key Integration Points

### 1. Gutenberg → Calypso (npm packages)

**Connection**: Calypso imports Gutenberg packages via npm

**Shared packages**:
- `@wordpress/components` - UI components
- `@wordpress/icons` - Icon library
- `@wordpress/data` - State management
- `@wordpress/api-fetch` - API calls

**Usage**:
```tsx
// In Calypso
import { Button, Card } from '@wordpress/components';
import { Icon, settings } from '@wordpress/icons';
```

### 2. Calypso/CIAB → WordPress Core (REST API)

**Connection**: HTTP requests to WordPress REST API

**Common endpoints**:
- `GET /wp/v2/posts` - List posts
- `POST /wp/v2/posts` - Create post
- `GET /wp/v2/settings` - Get site settings
- `POST /wp/v2/settings` - Update settings
- `GET /wp/v2/users/me` - Current user
- `GET /wp/v2/media` - Media library

**Usage**:
```tsx
// In Calypso or CIAB
import apiFetch from '@wordpress/api-fetch';

const posts = await apiFetch({ path: '/wp/v2/posts' });
```

### 3. Gutenberg → WordPress Core (Sync during release)

**Connection**: Gutenberg blocks/packages are synced to Core

**Flow**:
- Development: `repos/gutenberg/packages/block-library/src/paragraph/`
- In Core: `repos/wordpress-core/src/wp-includes/blocks/paragraph/`

### 4. Jetpack → WordPress Core (Plugin)

**Connection**: Jetpack runs as a plugin within WordPress Core via Docker volume mount

**Integration**: Symlinked in Docker environment, mu-plugin fixes `plugins_url()`

## Common Cross-Repo Scenarios

### Scenario 1: Add a Settings Page in Calypso

**Repos involved**: Calypso + WordPress Core

**Steps**:
1. **WordPress Core** (`repos/wordpress-core`):
   - Check if REST endpoint exists: `/wp/v2/settings`
   - If custom data needed, create custom endpoint in `src/wp-includes/rest-api/endpoints/`

2. **Calypso** (`repos/calypso`):
   - Create settings page UI in `client/my-sites/settings/` or `client/dashboard/`
   - Use `@wordpress/components` for form elements
   - Call REST API: `apiFetch({ path: '/wp/v2/settings', method: 'POST', data })`

**Files to check**:
- Core: `src/wp-includes/rest-api/endpoints/class-wp-rest-settings-controller.php`
- Calypso: `client/my-sites/settings/`

### Scenario 2: Create a Custom Block

**Repos involved**: Gutenberg (→ Core) + Calypso

**Steps**:
1. **Gutenberg** (`repos/gutenberg`):
   - Create block in `packages/block-library/src/my-block/`
   - Define `block.json`, `edit.js`, `save.js`

2. **WordPress Core**:
   - Block syncs automatically during WordPress release
   - Available in `src/wp-includes/blocks/my-block/`

3. **Calypso**:
   - Block automatically available in Calypso's editor
   - No changes needed (uses embedded Gutenberg)

### Scenario 3: Add REST API Endpoint Called by Calypso

**Repos involved**: WordPress Core + Calypso

**Steps**:
1. **WordPress Core** (`repos/wordpress-core`):
   ```php
   // src/wp-includes/rest-api/endpoints/class-wp-rest-my-controller.php
   register_rest_route('wp/v2', '/my-endpoint', [
       'methods'  => 'GET',
       'callback' => 'my_callback_function',
       'permission_callback' => 'my_permission_check',
   ]);
   ```

2. **Calypso** (`repos/calypso`):
   ```tsx
   const data = await apiFetch({ path: '/wp/v2/my-endpoint' });
   ```

## Quick Decision Tree

**User wants to**:
- **Add a setting** → Core (register setting) + Calypso (UI)
- **Create a block** → Gutenberg (block definition) → syncs to Core
- **Show data** → Core (REST endpoint) + Calypso (fetch & display)
- **Add Jetpack feature** → Jetpack (module) + Core (runs as plugin) + Calypso (UI)
- **Modernize admin** → CIAB (route + components) + Core (existing REST)
- **Prototype block** → Telex (AI generation) → WordPress Playground

## Resources

- **Cross-repo docs**: `docs/repo-map.md`
- **Config**: `dk.config.json` → `.connections` section
- **Rules**: `.cursor/rules/cross-repo.mdc`
