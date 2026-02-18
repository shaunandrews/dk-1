# Cross-Repository Integration and Workflows

This skill covers how WordPress ecosystem repositories connect, data flows, shared packages, feature flags, coordinating multi-repo changes, and managing cross-repository features.

## Overview

The WordPress ecosystem consists of multiple repositories that work together to provide a complete platform. Understanding how these repositories connect, share data, and coordinate changes is essential for building features that span multiple codebases.

## Repository Ecosystem Map

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Calypso   │    │  Gutenberg   │    │WordPress    │
│  (React UI) │    │ (Blocks/UI)  │    │    Core     │
│             │    │              │    │   (PHP)     │
└─────┬───────┘    └──────┬───────┘    └─────┬───────┘
      │                   │                  │
      │ REST API          │ npm packages     │ Plugin API
      │                   │                  │
      └─────────┬─────────┼──────────────────┘
                │         │
                │         │ Blocks sync
                │         │
        ┌───────▼─────────▼───┐    ┌─────────────┐
        │    Jetpack          │    │    CIAB     │
        │   (Plugin)          │    │  (Admin)    │
        └─────────────────────┘    └─────────────┘
                │                          │
                │ WordPress.com API        │ REST API
                │                          │
        ┌───────▼──────────────────────────▼───┐
        │              Telex                   │
        │        (Block Generator)             │
        └──────────────────────────────────────┘
```

## Key Integration Points

### 1. Gutenberg → Calypso (npm packages)
Calypso imports WordPress components and utilities:

```javascript
// Calypso imports from Gutenberg packages
import { Button, Card } from '@wordpress/components';
import { useSelect, useDispatch } from '@wordpress/data';
import { __ } from '@wordpress/i18n';
import { Icon, chevronDown } from '@wordpress/icons';

// Usage in Calypso components
const CalypsoSettingsPage = () => {
  return (
    <Card>
      <Button variant="primary">
        <Icon icon={chevronDown} />
        {__('Save Settings', 'calypso')}
      </Button>
    </Card>
  );
};
```

**Key packages used in Calypso:**
- `@wordpress/components` — UI component library
- `@wordpress/icons` — SVG icon set
- `@wordpress/data` — State management utilities
- `@wordpress/i18n` — Internationalization
- `@wordpress/api-fetch` — REST API client

### 2. Calypso → WordPress Core (REST API)
Calypso communicates with WordPress via REST API:

```javascript
import apiFetch from '@wordpress/api-fetch';

// Calypso API service
class WordPressAPI {
  static async getSites() {
    return apiFetch({
      path: '/wp/v2/sites',
      method: 'GET',
    });
  }
  
  static async updateSiteSettings(siteId, settings) {
    return apiFetch({
      path: `/wp/v2/sites/${siteId}/settings`,
      method: 'POST',
      data: settings,
    });
  }
  
  static async getPosts(siteId, params = {}) {
    const query = new URLSearchParams(params).toString();
    return apiFetch({
      path: `/wp/v2/sites/${siteId}/posts?${query}`,
    });
  }
}
```

### 3. Gutenberg → WordPress Core (Block Sync)
Blocks developed in Gutenberg sync to WordPress Core:

```php
// WordPress Core receives Gutenberg blocks
// Located in wp-includes/blocks/

// Example: Core version of a Gutenberg block
function render_block_latest_posts($attributes) {
    $posts = get_posts(array(
        'numberposts' => $attributes['postsToShow'] ?? 5,
        'post_status' => 'publish',
    ));
    
    $output = '<div class="wp-block-latest-posts">';
    foreach ($posts as $post) {
        $output .= sprintf(
            '<a href="%s">%s</a>',
            get_permalink($post),
            get_the_title($post)
        );
    }
    $output .= '</div>';
    
    return $output;
}

register_block_type('core/latest-posts', array(
    'render_callback' => 'render_block_latest_posts',
));
```

### 4. Jetpack → WordPress Core (Plugin Integration)
Jetpack extends WordPress Core functionality:

```php
// Jetpack adds features to WordPress Core
class Jetpack_Feature {
    public function __construct() {
        add_action('init', array($this, 'register_features'));
        add_filter('wp_insert_post_data', array($this, 'modify_post_data'), 10, 2);
        add_action('wp_enqueue_scripts', array($this, 'enqueue_assets'));
    }
    
    public function register_features() {
        // Add custom post types, taxonomies, etc.
        register_post_type('jetpack_portfolio', array(
            'public' => true,
            'show_in_rest' => true,
        ));
    }
    
    public function enqueue_assets() {
        wp_enqueue_script(
            'jetpack-feature',
            plugin_dir_url(__FILE__) . 'assets/feature.js',
            array('wp-element', 'wp-blocks')
        );
    }
}
```

## Shared Package Management

### Version Synchronization
Managing shared packages across repositories:

```json
// Calypso package.json
{
  "dependencies": {
    "@wordpress/components": "^25.0.0",
    "@wordpress/data": "^9.0.0",
    "@wordpress/icons": "^9.0.0"
  }
}

// Jetpack package.json (in js packages)
{
  "dependencies": {
    "@wordpress/components": "^25.0.0",
    "@wordpress/element": "^5.0.0"
  }
}
```

### Package Update Strategy
```bash
# Update WordPress packages across repos
# 1. Gutenberg releases new package versions
# 2. Update Calypso dependencies
cd repos/calypso
yarn add @wordpress/components@latest @wordpress/data@latest

# 3. Update Jetpack dependencies
cd repos/jetpack
pnpm add @wordpress/components@latest

# 4. Test compatibility across all repos
# 5. Coordinate release timing
```

## Feature Flag Coordination

### Cross-Repository Feature Flags
Managing feature rollouts across multiple codebases:

```php
// WordPress Core feature flag
function is_feature_enabled($feature) {
    return get_option("enable_{$feature}", false);
}

// Jetpack checks Core feature flags
if (is_feature_enabled('new_editor_features')) {
    // Enable Jetpack editor enhancements
    add_action('enqueue_block_editor_assets', 'jetpack_editor_features');
}
```

```javascript
// Calypso checks feature flags via API
const useFeatureFlag = (flagName) => {
  return useSelect(select => 
    select('core').getSiteSettings()?.feature_flags?.[flagName]
  );
};

const MyComponent = () => {
  const newFeatureEnabled = useFeatureFlag('new_dashboard_ui');
  
  if (newFeatureEnabled) {
    return <NewDashboardComponent />;
  }
  
  return <LegacyDashboardComponent />;
};
```

## Data Flow Patterns

### User Data Flow
```
User Action (Calypso)
       ↓
REST API Call
       ↓
WordPress Core Processing
       ↓
Database Update
       ↓
Jetpack Plugin Hooks
       ↓
WordPress.com Sync (if connected)
```

### Content Creation Flow
```
Block Created (Gutenberg Editor)
       ↓
Block Data → WordPress Core
       ↓
Post Meta/Content Saved
       ↓
Jetpack Enhancement Processing
       ↓
Calypso UI Updates (via API polling/WebSocket)
```

## Multi-Repository Development Workflows

### 1. Feature Spanning Multiple Repositories

**Example**: Adding a new block type with admin UI

```bash
# Phase 1: Core block development (Gutenberg)
cd repos/gutenberg
git checkout -b add/new-block-type
# Develop block in packages/block-library/

# Phase 2: Server-side support (WordPress Core)
cd repos/wordpress-core  
git checkout -b add/new-block-api-support
# Add REST endpoints, database support

# Phase 3: Admin interface (Calypso)
cd repos/calypso
git checkout -b add/new-block-settings
# Create admin UI for block configuration

# Phase 4: Plugin integration (Jetpack)
cd repos/jetpack
git checkout -b add/new-block-jetpack-features
# Add Jetpack-specific enhancements
```

### 2. Coordinated Release Process

```bash
# 1. Prepare branches in all affected repos
./bin/repos.sh create-branch feature/coordinated-update

# 2. Develop changes in dependency order:
#    a) WordPress Core (foundation)
#    b) Gutenberg (builds on Core)
#    c) Jetpack (uses Core + Gutenberg)
#    d) Calypso (consumes all via API)

# 3. Test integration
./bin/start.sh all  # Start all dev servers
# Run cross-repo integration tests

# 4. Coordinate merge timing
# Merge in reverse dependency order to avoid breakage
```

### 3. Breaking Change Management

When a change in one repo affects others:

```javascript
// Gutenberg: Deprecate component with migration path
import deprecated from '@wordpress/deprecated';

const OldComponent = (props) => {
  deprecated('OldComponent', {
    since: '6.4',
    alternative: 'NewComponent',
    plugin: 'Gutenberg',
  });
  
  return <NewComponent {...migrateProps(props)} />;
};

// Calypso: Update to use new component
import { NewComponent } from '@wordpress/components';

// Before
<OldComponent setting={value} />

// After  
<NewComponent config={{ setting: value }} />
```

## API Versioning and Compatibility

### REST API Versioning
```php
// WordPress Core: Maintain API compatibility
register_rest_route('wp/v2', '/posts', array(
    'methods' => 'GET',
    'callback' => 'get_posts_v2',
));

// New version with enhanced features
register_rest_route('wp/v3', '/posts', array(
    'methods' => 'GET', 
    'callback' => 'get_posts_v3',
));

// Calypso: Graceful API version handling
const apiVersion = supportsV3() ? 'v3' : 'v2';
const posts = await apiFetch({
  path: `/wp/${apiVersion}/posts`,
});
```

## Testing Cross-Repository Changes

### Integration Testing Setup
```bash
# Test setup script
#!/bin/bash
# test-integration.sh

# Start all required services
cd repos/wordpress-core && npm run dev &
CORE_PID=$!

cd repos/calypso && yarn start:debug &
CALYPSO_PID=$!

cd repos/jetpack && pnpm jetpack watch plugins/jetpack &
JETPACK_PID=$!

# Wait for services to be ready
wait_for_service() {
    local url=$1
    local name=$2
    echo "Waiting for $name..."
    
    while ! curl -s "$url" > /dev/null; do
        sleep 2
    done
    echo "$name is ready"
}

wait_for_service "http://localhost:8889" "WordPress Core"
wait_for_service "http://calypso.localhost:3000" "Calypso"

# Run integration tests
npm run test:integration

# Cleanup
kill $CORE_PID $CALYPSO_PID $JETPACK_PID
```

### Cross-Repository Test Cases
```javascript
// Integration test example
describe('Cross-repo block creation', () => {
  test('Block created in Gutenberg works in Calypso', async () => {
    // 1. Create post with custom block via Gutenberg
    const post = await gutenbergAPI.createPost({
      content: '<!-- wp:custom/my-block {"setting": "value"} /-->',
    });
    
    // 2. Verify block renders in WordPress Core
    const coreResponse = await wordpressAPI.getPost(post.id);
    expect(coreResponse.content.rendered).toContain('my-block-output');
    
    // 3. Verify block appears in Calypso editor
    const calypsoEditor = await calypsoAPI.openEditor(post.id);
    expect(calypsoEditor.blocks).toContainBlock('custom/my-block');
  });
});
```

## Configuration Management

### Environment-Specific Settings
```javascript
// Shared configuration patterns
const config = {
  development: {
    wordpress: 'http://localhost:8889',
    calypso: 'http://calypso.localhost:3000',
    api: {
      timeout: 10000,
      retries: 3,
    },
  },
  staging: {
    wordpress: 'https://staging-site.wpcomstaging.com',
    calypso: 'https://calypso-staging.automattic.com',
    api: {
      timeout: 5000,
      retries: 2,
    },
  },
  production: {
    wordpress: 'https://wordpress.com',
    calypso: 'https://wordpress.com/home',
    api: {
      timeout: 3000,
      retries: 1,
    },
  },
};
```

## Monitoring and Debugging

### Cross-Repository Logging
```javascript
// Shared logging utility
class CrossRepoLogger {
  static log(repo, component, message, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      repo,
      component,
      message,
      data,
      correlation_id: this.getCorrelationId(),
    };
    
    // Send to centralized logging
    this.sendToLogger(logEntry);
  }
  
  static getCorrelationId() {
    // Use request ID to trace across repos
    return window.__CORRELATION_ID__ || generateId();
  }
}

// Usage across repositories
// In Calypso:
CrossRepoLogger.log('calypso', 'api', 'Updating site settings', { siteId });

// In WordPress Core:
error_log(json_encode([
  'repo' => 'wordpress-core',
  'component' => 'rest-api',
  'message' => 'Settings updated',
  'correlation_id' => $_SERVER['HTTP_X_CORRELATION_ID'],
]));
```

## Performance Considerations

### Bundle Size Coordination
```javascript
// Shared dependency analysis
const analyzeDependencies = async () => {
  const repos = ['calypso', 'jetpack', 'gutenberg'];
  const analysis = {};
  
  for (const repo of repos) {
    const packageJson = require(`../repos/${repo}/package.json`);
    analysis[repo] = {
      wordpress_packages: Object.keys(packageJson.dependencies)
        .filter(dep => dep.startsWith('@wordpress/')),
      bundle_size: await getBundleSize(repo),
    };
  }
  
  // Identify opportunities for bundle optimization
  return findSharedDependencies(analysis);
};
```

### Caching Strategies
```javascript
// Coordinated caching across repositories
class CrossRepoCaching {
  static cacheKey(repo, resource, id) {
    return `${repo}:${resource}:${id}`;
  }
  
  static async get(repo, resource, id) {
    const key = this.cacheKey(repo, resource, id);
    return await cache.get(key);
  }
  
  static async invalidate(repo, resource, id) {
    const key = this.cacheKey(repo, resource, id);
    await cache.delete(key);
    
    // Invalidate related caches in other repos
    await this.invalidateRelated(repo, resource, id);
  }
}
```

## Documentation and Communication

### Cross-Repository Documentation
```markdown
# Feature: New Block Editor Tool

## Repositories Affected
- **Gutenberg**: Block registration and editor UI
- **WordPress Core**: Server-side block rendering
- **Calypso**: Admin interface for block settings
- **Jetpack**: Enhanced block features for connected sites

## Implementation Timeline
1. Week 1: Gutenberg prototype
2. Week 2: WordPress Core API support
3. Week 3: Calypso admin interface
4. Week 4: Jetpack enhancements
5. Week 5: Integration testing and release

## Breaking Changes
- `BlockAPI.register()` signature changed
- New required field in block attributes
- Updated REST endpoint response format

## Migration Guide
[Detailed migration steps for each repository]
```

## Common Pitfalls and Solutions

### 1. Version Mismatch Issues
**Problem**: Different repos using incompatible package versions
**Solution**: Regular dependency audits and coordinated updates

### 2. API Breaking Changes
**Problem**: Core API changes break Calypso functionality  
**Solution**: API versioning and deprecation notices

### 3. Feature Flag Inconsistency
**Problem**: Feature enabled in one repo but not others
**Solution**: Centralized feature flag management

### 4. Test Environment Drift
**Problem**: Different repos test against different WordPress versions
**Solution**: Shared test environment configuration

## Troubleshooting Guide

### Cross-Repository Issues

**Symptom**: Calypso UI not updating after Core changes
**Diagnosis**: 
1. Check REST API response format
2. Verify Calypso cache invalidation
3. Test API endpoints directly

**Symptom**: Jetpack features not working with new Core version
**Diagnosis**:
1. Check WordPress hook compatibility
2. Verify plugin activation
3. Review deprecation warnings

**Symptom**: Gutenberg blocks not rendering correctly
**Diagnosis**:
1. Check block registration
2. Verify Core block support
3. Test with default theme

## Development Tools

### Cross-Repository Scripts
```bash
# Utility scripts for multi-repo development
./bin/repos.sh status              # Git status all repos
./bin/repos.sh create-branch name  # Create branch in all repos  
./bin/repos.sh test               # Run tests in all repos
./bin/start.sh all               # Start all dev servers
./bin/which-repo.sh              # Show current repo context
```

These scripts help coordinate development across the entire WordPress ecosystem while maintaining awareness of cross-repository dependencies and integration points.