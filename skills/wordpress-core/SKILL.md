---
description: WordPress Core development context
globs: ["repos/wordpress-core/**/*"]
---

# WordPress Core Development Context

WordPress Core is the foundational software that powers WordPress sites. This is the development repository (`wordpress-develop`).

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/wordpress-core` |
| **Node Version** | 20 (see .nvmrc) |
| **Package Manager** | npm |
| **Language** | PHP (backend), JS (admin) |
| **Database** | SQLite (via Playground runtime) |
| **Dev Server** | `wp-env start --runtime=playground` → http://localhost:8889 |

## Node Version (CRITICAL)

WordPress Core requires **Node 20**. Before running ANY npm command:

```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use
```

This reads the `.nvmrc` file and switches to the correct version. Always include this in your commands:

```bash
# Installing dependencies
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm ci

# Starting dev server
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm run dev

# Running tests
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm run test-php
```

## Building the Project (REQUIRED)

WordPress Core must be built before running the development environment. The initial setup script handles this, but if you've freshly cloned or are having issues:

```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use

# Full build (required after fresh clone or major changes)
npm run build

# Then start development environment
npm run dev
```

**When to rebuild:**
- After fresh clone or pulling major changes
- After switching branches with significant changes
- If the development environment shows errors or missing assets
- If admin styles or scripts aren't loading correctly

The build compiles JavaScript, SCSS, and prepares assets for the development server.

## Key Directories

```
repos/wordpress-core/
├── src/
│   ├── wp-admin/           # Admin dashboard
│   │   ├── css/            # Admin styles
│   │   ├── js/             # Admin scripts
│   │   └── includes/       # Admin PHP
│   ├── wp-includes/        # Core library
│   │   ├── rest-api/       # REST API
│   │   ├── blocks/         # Core blocks
│   │   ├── class-wp-*.php  # Core classes
│   │   └── js/             # Core scripts
│   ├── wp-content/
│   │   ├── themes/         # Bundled themes
│   │   └── plugins/        # Bundled plugins
│   └── js/_enqueues/       # Modern JS entry points
└── tests/                  # Test suites
```

## REST API

The REST API is how external applications (like Calypso) communicate with WordPress.

### Endpoint Structure

```
/wp-json/wp/v2/posts        # Posts
/wp-json/wp/v2/pages        # Pages
/wp-json/wp/v2/users        # Users
/wp-json/wp/v2/settings     # Site settings
/wp-json/wp/v2/blocks       # Reusable blocks
```

### Creating Custom Endpoints

```php
// src/wp-includes/rest-api/endpoints/class-wp-rest-my-controller.php

class WP_REST_My_Controller extends WP_REST_Controller {

    public function register_routes() {
        register_rest_route('wp/v2', '/my-endpoint', [
            'methods'  => 'GET',
            'callback' => [$this, 'get_items'],
            'permission_callback' => [$this, 'get_items_permissions_check'],
        ]);
    }

    public function get_items($request) {
        return rest_ensure_response(['data' => 'value']);
    }

    public function get_items_permissions_check($request) {
        return current_user_can('edit_posts');
    }
}
```

### Registering Endpoints

```php
// In a plugin or theme functions.php
add_action('rest_api_init', function() {
    $controller = new WP_REST_My_Controller();
    $controller->register_routes();
});
```

## Admin Pages

### Adding Admin Pages

```php
// Add a top-level menu page
add_action('admin_menu', function() {
    add_menu_page(
        'My Page Title',           // Page title
        'My Menu',                 // Menu title
        'manage_options',          // Capability
        'my-page-slug',            // Menu slug
        'my_page_render_callback', // Render function
        'dashicons-admin-generic', // Icon
        20                         // Position
    );
});

function my_page_render_callback() {
    ?>
    <div class="wrap">
        <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
        <!-- Page content -->
    </div>
    <?php
}
```

### Adding Settings

```php
add_action('admin_init', function() {
    // Register setting
    register_setting('my_settings_group', 'my_option');

    // Add settings section
    add_settings_section(
        'my_section',
        'My Settings Section',
        'my_section_callback',
        'my-page-slug'
    );

    // Add settings field
    add_settings_field(
        'my_field',
        'My Field',
        'my_field_callback',
        'my-page-slug',
        'my_section'
    );
});
```

## Hooks System

WordPress uses hooks (actions and filters) for extensibility.

### Actions

```php
// Register a callback
add_action('init', 'my_init_function');
add_action('wp_enqueue_scripts', 'my_enqueue_function');
add_action('save_post', 'my_save_function', 10, 3);

// Trigger an action
do_action('my_custom_action', $arg1, $arg2);
```

### Filters

```php
// Modify data
add_filter('the_content', 'my_content_filter');
add_filter('wp_title', 'my_title_filter', 10, 2);

// Apply a filter
$value = apply_filters('my_custom_filter', $default_value);
```

### Common Hooks

| Hook | When |
|------|------|
| `init` | WordPress initialized |
| `admin_init` | Admin area initialized |
| `wp_enqueue_scripts` | Enqueue frontend assets |
| `admin_enqueue_scripts` | Enqueue admin assets |
| `save_post` | Post is saved |
| `rest_api_init` | REST API initialized |

## Blocks in Core

Core blocks are synced from Gutenberg:

```
src/wp-includes/blocks/
├── paragraph/
│   ├── block.json
│   ├── style.css
│   └── editor.css
├── image/
├── heading/
└── ...
```

## Database

### Direct Queries (when necessary)

```php
global $wpdb;

// Select
$results = $wpdb->get_results(
    $wpdb->prepare("SELECT * FROM {$wpdb->posts} WHERE post_type = %s", 'page')
);

// Insert
$wpdb->insert($wpdb->posts, [
    'post_title' => 'My Post',
    'post_status' => 'publish'
]);

// Update
$wpdb->update(
    $wpdb->posts,
    ['post_title' => 'Updated Title'],
    ['ID' => 123]
);
```

### Preferred: WP_Query

```php
$query = new WP_Query([
    'post_type' => 'post',
    'posts_per_page' => 10,
    'meta_query' => [
        ['key' => 'featured', 'value' => '1']
    ]
]);

while ($query->have_posts()) {
    $query->the_post();
    the_title();
}
wp_reset_postdata();
```

## Asset Enqueuing

```php
add_action('wp_enqueue_scripts', function() {
    // Styles
    wp_enqueue_style(
        'my-style',
        get_stylesheet_uri(),
        [],
        '1.0.0'
    );

    // Scripts
    wp_enqueue_script(
        'my-script',
        get_template_directory_uri() . '/js/script.js',
        ['jquery'],
        '1.0.0',
        true // In footer
    );

    // Pass data to JS
    wp_localize_script('my-script', 'myData', [
        'ajaxUrl' => admin_url('admin-ajax.php'),
        'nonce' => wp_create_nonce('my_nonce')
    ]);
});
```

## Dev Commands

**This is the PRIMARY wp-env.** When both wordpress-core and gutenberg repos exist, always use this environment. Never start gutenberg's wp-env simultaneously.

```bash
cd repos/wordpress-core

# Start development environment (no Docker required)
wp-env start --runtime=playground

# Stop environment
wp-env stop

# Destroy and start fresh
wp-env destroy

# Build
npm run build

# Run PHP tests
npm run test-php

# Run JS tests (QUnit via Grunt)
npm run test
```

**Escape hatch:** If you need MySQL or `wp-env run` for advanced work:
```bash
wp-env start --runtime=docker  # Requires Docker Desktop
```

## Environment Commands

The local dev environment runs via wp-env with WordPress Playground (no Docker required):

```bash
cd repos/wordpress-core

wp-env start --runtime=playground   # Start WordPress (SQLite, no Docker)
wp-env stop                         # Stop the environment
wp-env destroy                      # Remove environment completely
```

The old Docker-based `npm run env:*` commands still exist in the repo but are no longer used by dk. Use `wp-env` commands instead.

### Environment Configuration (.wp-env.json)

The environment is configured via `.wp-env.json` (created automatically by the start script from `configs/wp-env-core.json`):

```json
{
	"core": ".",
	"plugins": [],
	"themes": [],
	"port": 8889,
	"testsPort": 8890,
	"config": {
		"WP_DEBUG": true,
		"SCRIPT_DEBUG": true
	}
}
```

To customize, edit `configs/wp-env-core.json`. See [@wordpress/env docs](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) for all options.

**Escape hatch for Docker runtime:** Some old `.env` options (like `LOCAL_PHP`, `LOCAL_DB_TYPE`) only apply to the Docker runtime. If you need them, use `wp-env start --runtime=docker`.

## Build System

`src/` is the development directory. `build/` is the compiled output. Grunt is the task runner, Webpack handles JS bundling.

```bash
npm run build           # Full production build (Grunt)
npm run build:dev       # Development build (unminified)
npm run dev             # Watch mode — rebuilds on file changes
```

- Webpack configs live in `tools/webpack/`
- Grunt tasks are defined in `Gruntfile.js`
- With Docker runtime (`--runtime=docker`), set `LOCAL_DIR=build` in `.env` to serve compiled output instead of `src/`

## Testing

### All Test Scripts

```bash
# Meta
npm run test              # Grunt test suite (JS linting + QUnit)

# PHP
npm run test:php          # PHPUnit (requires Docker runtime or local PHP)
npm run test:coverage     # PHPUnit with HTML + PHP + text coverage reports

# E2E / Visual / Performance (Playwright)
npm run test:e2e          # End-to-end tests (tests/e2e/)
npm run test:visual       # Visual regression tests (tests/visual-regression/)
npm run test:performance  # Performance tests (tests/performance/)
```

### Test Directories

```
tests/
├── phpunit/         # PHP unit tests
├── qunit/           # JavaScript unit tests (QUnit)
├── e2e/             # End-to-end tests (Playwright)
├── visual-regression/ # Visual regression tests (Playwright)
├── performance/     # Performance tests (Playwright)
└── gutenberg/       # Gutenberg-specific tests
```

### Composer Scripts (PHP tooling)

```bash
npm run env:composer -- lint        # PHPCS linting
npm run env:composer -- format      # PHPCBF auto-fix
npm run env:composer -- compat      # PHP compatibility check
npm run env:composer -- lint:errors  # Lint errors only (no warnings)
```

## Gutenberg Integration

WordPress Core syncs packages and blocks from the Gutenberg repo. The `gutenberg/` subdirectory contains a checkout of the Gutenberg repository. Scripts in `tools/gutenberg/` manage the sync.

```bash
# Sync workflow
npm run gutenberg:sync       # Sync Gutenberg packages (runs on postinstall)
npm run gutenberg:checkout   # Checkout Gutenberg at the pinned ref
npm run gutenberg:build      # Build the Gutenberg checkout
npm run gutenberg:copy       # Copy built Gutenberg packages into Core

# The pinned Gutenberg commit is in package.json under "gutenberg.ref"
```

The `sync-gutenberg-packages` and `postsync-gutenberg-packages` scripts handle syncing stable block packages and rebuilding.

## Modern WordPress APIs

### HTML API (`src/wp-includes/html-api/`)

A proper HTML parser for WordPress. Use instead of regex for HTML manipulation.

- **`WP_HTML_Tag_Processor`** — Low-level tag-by-tag HTML traversal and modification. Find tags, read/set attributes, add/remove classes.
- **`WP_HTML_Processor`** — Full HTML parser (extends Tag Processor). Understands nesting, semantic structure, and DOM hierarchy.
- **`WP_HTML_Decoder`** — Decodes HTML character references.

### Interactivity API (`src/wp-includes/interactivity-api/`)

Server-side processing for the WordPress Interactivity API (declarative client-side interactivity for blocks).

- **`WP_Interactivity_API`** — Main class. Manages stores, state, and directive processing.
- **`WP_Interactivity_API_Directives_Processor`** — Processes `data-wp-*` directives in HTML (extends `WP_HTML_Tag_Processor`).

### Style Engine (`src/wp-includes/style-engine/`)

Generates and manages CSS from block style definitions. Handles deduplication, rule storage, and output.

- **`WP_Style_Engine`** — Main class. Converts style arrays to CSS declarations.
- **`WP_Style_Engine_CSS_Declarations`** — A set of CSS property/value pairs.
- **`WP_Style_Engine_CSS_Rule`** — A CSS rule (selector + declarations).
- **`WP_Style_Engine_CSS_Rules_Store`** — Named store for collecting rules.
- **`WP_Style_Engine_Processor`** — Compiles stored rules into output CSS.

### Block Supports (`src/wp-includes/block-supports/`)

Each file adds a category of design controls to blocks via `block.json` supports:

| File | Support |
|------|---------|
| `align.php` | Block alignment (wide, full, etc.) |
| `anchor.php` | HTML anchor/ID |
| `aria-label.php` | Accessibility label |
| `background.php` | Background image/color |
| `block-style-variations.php` | Style variations |
| `block-visibility.php` | Conditional visibility |
| `border.php` | Border width, radius, color |
| `colors.php` | Text, background, link colors |
| `custom-classname.php` | Custom CSS class |
| `dimensions.php` | Min height, aspect ratio |
| `duotone.php` | Duotone image filter |
| `elements.php` | Inner element styling (links, headings) |
| `generated-classname.php` | Auto-generated CSS class |
| `layout.php` | Flex, grid, flow layout |
| `position.php` | Sticky, fixed positioning |
| `shadow.php` | Box shadow |
| `spacing.php` | Margin, padding |
| `typography.php` | Font size, family, weight, line height |

### Block Bindings (`src/wp-includes/block-bindings/`)

Connect block attributes to dynamic data sources.

- **`WP_Block_Bindings_Registry`** (`class-wp-block-bindings-registry.php` in wp-includes) — Register and manage binding sources.
- **`WP_Block_Bindings_Source`** (`class-wp-block-bindings-source.php` in wp-includes) — Represents a single binding source.
- Built-in sources: `pattern-overrides.php`, `post-data.php`, `post-meta.php`, `term-data.php`

## Block Patterns & Templates

- **`block-patterns.php`** — Registers core block patterns (pre-built block layouts).
- **`block-template-utils.php`** — Utilities for block templates and template parts (FSE).
- **`WP_Block_Patterns_Registry`** — Manages registered patterns (`class-wp-block-patterns-registry.php`).

## Sitemaps (`src/wp-includes/sitemaps/`)

Built-in XML sitemap support (since WP 5.5).

- **`WP_Sitemaps`** — Main class, registers and serves sitemaps.
- **`WP_Sitemaps_Registry`** — Provider registry.
- **`WP_Sitemaps_Renderer`** — Renders XML output.
- **`WP_Sitemaps_Stylesheet`** — XSL stylesheet for human-readable sitemaps.
- Providers: `WP_Sitemaps_Posts`, `WP_Sitemaps_Taxonomies`, `WP_Sitemaps_Users`

## PHP/MySQL Version Support

Version support matrices are tracked in the repo root:

- `.version-support-php.json` — WordPress 7.0 supports PHP 7.4 through 8.5
- `.version-support-mysql.json` — WordPress 7.0 supports MySQL 5.5 through 9.5

The `composer.json` minimum is `"php": ">=7.4"`.

## Code Style

Linting and formatting configs in the repo root:

- `.prettierrc.js` — Prettier config (uses `wp-prettier`)
- `.eslintrc-jsdoc.js` — ESLint for JSDoc validation
- `.jshintrc` — JSHint config for legacy JS

```bash
npm run lint:jsdoc       # Lint JS with ESLint (JSDoc rules)
npm run lint:jsdoc:fix   # Auto-fix ESLint issues
```

## Security Practices

Always sanitize, escape, and validate:

```php
// Sanitize input
$clean = sanitize_text_field($_POST['field']);
$clean_email = sanitize_email($_POST['email']);

// Escape output
echo esc_html($text);
echo esc_attr($attribute);
echo esc_url($url);

// Verify nonces
if (!wp_verify_nonce($_POST['_wpnonce'], 'my_action')) {
    die('Security check failed');
}

// Check capabilities
if (!current_user_can('edit_posts')) {
    wp_die('Unauthorized');
}
```
