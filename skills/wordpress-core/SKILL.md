# WordPress Core Development

This skill covers working with WordPress Core, including PHP conventions, REST API development, admin pages, hooks system, blocks, security practices, and database interactions.

## Overview

WordPress Core is the foundation software that powers WordPress sites. It's primarily PHP-based with Node.js tooling for asset building. This skill covers development patterns for extending and contributing to WordPress Core.

## Repository Structure

### Core Directories
- **`src/wp-admin/`** — WordPress admin interface
- **`src/wp-includes/`** — Core WordPress functions and classes
- **`src/wp-content/`** — Themes, plugins, and uploads (development)
- **`build/`** — Built JavaScript and CSS assets
- **`tests/`** — PHP and JavaScript test suites

### Development Setup

#### Prerequisites
- Node 20 (use nvm)
- npm package manager
- Docker Desktop (for wp-env)
- PHP 8.0+ and Composer (if running without Docker)

#### Setup Commands
```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build
```

#### Development Server (wp-env)
```bash
npm run dev  # → http://localhost:8889
```

**Important**: When both WordPress Core and Gutenberg exist, always use WordPress Core's wp-env to avoid port conflicts.

## PHP Development Patterns

### WordPress Coding Standards
WordPress follows specific PHP coding standards:

```php
// Function naming: lowercase with underscores
function my_custom_function( $param ) {
    // Code here
}

// Class naming: PascalCase with underscores
class My_Custom_Class {
    // Properties and methods
}

// Constants: UPPERCASE with underscores
define( 'MY_CONSTANT', 'value' );
```

### Hook System

#### Actions
Execute code at specific points:
```php
// Add an action
add_action( 'wp_head', 'my_head_content' );

function my_head_content() {
    echo '<meta name="my-meta" content="value">';
}

// Action with priority and parameters
add_action( 'save_post', 'my_save_function', 10, 2 );

function my_save_function( $post_id, $post ) {
    // Process after post save
}
```

#### Filters
Modify data as it passes through WordPress:
```php
// Add a filter
add_filter( 'the_title', 'modify_title' );

function modify_title( $title ) {
    return strtoupper( $title );
}

// Filter with multiple parameters
add_filter( 'wp_insert_post_data', 'modify_post_data', 10, 2 );

function modify_post_data( $data, $postarr ) {
    // Modify post data before saving
    return $data;
}
```

### Custom Post Types
```php
function register_my_post_type() {
    register_post_type( 'my_type', array(
        'labels' => array(
            'name' => __( 'My Types' ),
            'singular_name' => __( 'My Type' ),
        ),
        'public' => true,
        'has_archive' => true,
        'supports' => array( 'title', 'editor', 'thumbnail' ),
        'show_in_rest' => true, // Enable Gutenberg editor
    ) );
}
add_action( 'init', 'register_my_post_type' );
```

### Custom Taxonomies
```php
function register_my_taxonomy() {
    register_taxonomy( 'my_taxonomy', 'my_post_type', array(
        'labels' => array(
            'name' => __( 'My Taxonomies' ),
            'singular_name' => __( 'My Taxonomy' ),
        ),
        'hierarchical' => true, // Like categories (false = like tags)
        'show_in_rest' => true,
    ) );
}
add_action( 'init', 'register_my_taxonomy' );
```

## REST API Development

### Built-in Endpoints
WordPress provides REST endpoints for core functionality:
- **Posts**: `/wp/v2/posts`
- **Pages**: `/wp/v2/pages`
- **Users**: `/wp/v2/users`
- **Comments**: `/wp/v2/comments`
- **Settings**: `/wp/v2/settings`

### Custom REST Endpoints
```php
function register_custom_endpoint() {
    register_rest_route( 'my-plugin/v1', '/custom', array(
        'methods' => 'GET',
        'callback' => 'my_rest_callback',
        'permission_callback' => 'my_permissions_check',
        'args' => array(
            'param' => array(
                'required' => true,
                'validate_callback' => 'is_string',
                'sanitize_callback' => 'sanitize_text_field',
            ),
        ),
    ) );
}
add_action( 'rest_api_init', 'register_custom_endpoint' );

function my_rest_callback( $request ) {
    $param = $request->get_param( 'param' );
    
    return rest_ensure_response( array(
        'success' => true,
        'data' => $param,
    ) );
}

function my_permissions_check() {
    return current_user_can( 'manage_options' );
}
```

### Custom REST Fields
```php
function add_custom_field_to_api() {
    register_rest_field( 'post', 'my_custom_field', array(
        'get_callback' => 'get_custom_field',
        'update_callback' => 'update_custom_field',
        'schema' => array(
            'description' => 'My custom field',
            'type' => 'string',
        ),
    ) );
}
add_action( 'rest_api_init', 'add_custom_field_to_api' );

function get_custom_field( $post ) {
    return get_post_meta( $post['id'], 'my_custom_field', true );
}

function update_custom_field( $value, $post ) {
    return update_post_meta( $post->ID, 'my_custom_field', $value );
}
```

## Admin Interface Development

### Admin Pages
```php
function add_my_admin_page() {
    add_menu_page(
        'My Plugin',           // Page title
        'My Plugin',           // Menu title
        'manage_options',      // Capability
        'my-plugin',           // Menu slug
        'my_admin_page_html',  // Callback function
        'dashicons-admin-generic', // Icon
        30                     // Position
    );
}
add_action( 'admin_menu', 'add_my_admin_page' );

function my_admin_page_html() {
    if ( ! current_user_can( 'manage_options' ) ) {
        return;
    }
    ?>
    <div class="wrap">
        <h1><?php echo esc_html( get_admin_page_title() ); ?></h1>
        <!-- Admin page content -->
    </div>
    <?php
}
```

### Settings API
```php
function register_my_settings() {
    // Register setting
    register_setting( 'my_options_group', 'my_option', array(
        'sanitize_callback' => 'sanitize_text_field',
    ) );
    
    // Add section
    add_settings_section(
        'my_section',
        __( 'My Settings' ),
        'my_section_callback',
        'my-plugin'
    );
    
    // Add field
    add_settings_field(
        'my_field',
        __( 'My Field' ),
        'my_field_callback',
        'my-plugin',
        'my_section'
    );
}
add_action( 'admin_init', 'register_my_settings' );

function my_field_callback() {
    $value = get_option( 'my_option' );
    printf(
        '<input type="text" name="my_option" value="%s" />',
        esc_attr( $value )
    );
}
```

## Database Interactions

### Using wpdb
```php
global $wpdb;

// Prepare and execute query
$results = $wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE post_status = %s AND post_type = %s",
    'publish',
    'post'
) );

// Insert data
$wpdb->insert(
    $wpdb->prefix . 'my_table',
    array(
        'column1' => $value1,
        'column2' => $value2,
    ),
    array( '%s', '%d' ) // Data format
);
```

### Custom Database Tables
```php
function create_my_table() {
    global $wpdb;
    
    $table_name = $wpdb->prefix . 'my_table';
    
    $charset_collate = $wpdb->get_charset_collate();
    
    $sql = "CREATE TABLE $table_name (
        id mediumint(9) NOT NULL AUTO_INCREMENT,
        name varchar(100) NOT NULL,
        data text,
        created_at datetime DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
    ) $charset_collate;";
    
    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta( $sql );
}

// Run on plugin activation
register_activation_hook( __FILE__, 'create_my_table' );
```

## Block Development (Server-side)

### Dynamic Blocks
```php
function register_my_dynamic_block() {
    register_block_type( 'my-plugin/my-block', array(
        'render_callback' => 'render_my_block',
        'attributes' => array(
            'content' => array(
                'type' => 'string',
                'default' => '',
            ),
        ),
    ) );
}
add_action( 'init', 'register_my_dynamic_block' );

function render_my_block( $attributes, $content ) {
    $content = esc_html( $attributes['content'] );
    return "<div class='my-block'>{$content}</div>";
}
```

### Block Assets
```php
function enqueue_block_assets() {
    wp_register_script(
        'my-block-script',
        plugins_url( 'build/index.js', __FILE__ ),
        array( 'wp-blocks', 'wp-element', 'wp-editor' ),
        filemtime( plugin_dir_path( __FILE__ ) . 'build/index.js' )
    );
    
    wp_register_style(
        'my-block-style',
        plugins_url( 'build/style.css', __FILE__ ),
        array(),
        filemtime( plugin_dir_path( __FILE__ ) . 'build/style.css' )
    );
    
    register_block_type( 'my-plugin/my-block', array(
        'editor_script' => 'my-block-script',
        'style' => 'my-block-style',
    ) );
}
add_action( 'init', 'enqueue_block_assets' );
```

## Security Best Practices

### Data Sanitization and Validation
```php
// Sanitizing input
$safe_text = sanitize_text_field( $_POST['my_field'] );
$safe_email = sanitize_email( $_POST['email'] );
$safe_url = esc_url_raw( $_POST['url'] );

// Validating data
if ( ! is_email( $email ) ) {
    wp_die( 'Invalid email address' );
}

if ( ! wp_verify_nonce( $_POST['nonce'], 'my_action' ) ) {
    wp_die( 'Security check failed' );
}
```

### Escaping Output
```php
// Text output
echo esc_html( $user_input );

// URLs
echo esc_url( $url );

// Attributes
echo '<input value="' . esc_attr( $value ) . '">';

// JavaScript
echo '<script>var myVar = ' . wp_json_encode( $data ) . ';</script>';
```

### Nonces and Permissions
```php
// Create nonce
wp_nonce_field( 'my_action', 'my_nonce' );

// Verify nonce and capability
if ( ! wp_verify_nonce( $_POST['my_nonce'], 'my_action' ) ) {
    wp_die( 'Security check failed' );
}

if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( 'Insufficient permissions' );
}
```

## JavaScript and Asset Management

### Enqueueing Scripts and Styles
```php
function enqueue_my_assets() {
    wp_enqueue_script(
        'my-script',
        plugin_dir_url( __FILE__ ) . 'assets/js/script.js',
        array( 'jquery' ), // Dependencies
        '1.0.0',           // Version
        true               // In footer
    );
    
    wp_enqueue_style(
        'my-style',
        plugin_dir_url( __FILE__ ) . 'assets/css/style.css',
        array(),           // Dependencies
        '1.0.0'            // Version
    );
    
    // Localize script (pass data to JavaScript)
    wp_localize_script( 'my-script', 'myAjax', array(
        'ajaxurl' => admin_url( 'admin-ajax.php' ),
        'nonce' => wp_create_nonce( 'my_ajax_nonce' ),
    ) );
}
add_action( 'wp_enqueue_scripts', 'enqueue_my_assets' );
```

### AJAX Handlers
```php
// For logged-in users
add_action( 'wp_ajax_my_action', 'handle_my_ajax' );

// For non-logged-in users  
add_action( 'wp_ajax_nopriv_my_action', 'handle_my_ajax' );

function handle_my_ajax() {
    // Verify nonce
    if ( ! wp_verify_nonce( $_POST['nonce'], 'my_ajax_nonce' ) ) {
        wp_die( 'Security check failed' );
    }
    
    // Process request
    $response = array( 'success' => true );
    
    wp_send_json( $response );
}
```

## Performance Optimization

### Caching
```php
// Object caching
$cached_data = wp_cache_get( 'my_key', 'my_group' );
if ( false === $cached_data ) {
    $cached_data = expensive_operation();
    wp_cache_set( 'my_key', $cached_data, 'my_group', HOUR_IN_SECONDS );
}

// Transients (persistent caching)
$data = get_transient( 'my_transient' );
if ( false === $data ) {
    $data = expensive_operation();
    set_transient( 'my_transient', $data, HOUR_IN_SECONDS );
}
```

### Database Query Optimization
```php
// Use WP_Query efficiently
$query = new WP_Query( array(
    'post_type' => 'my_type',
    'posts_per_page' => 10,
    'meta_query' => array(
        array(
            'key' => 'my_key',
            'value' => $value,
        ),
    ),
    'no_found_rows' => true, // Skip counting for pagination
    'update_post_meta_cache' => false, // Skip if not needed
) );
```

## Testing and Debugging

### Debug Logging
```php
// Enable debug logging in wp-config.php
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );

// Write to debug log
error_log( 'Debug message' );
write_log( $complex_data ); // Custom function to log arrays/objects
```

### PHPUnit Testing
```php
class My_Test extends WP_UnitTestCase {
    public function test_my_function() {
        $result = my_custom_function( 'test input' );
        $this->assertEquals( 'expected output', $result );
    }
    
    public function test_hook_is_added() {
        $this->assertEquals( 10, has_action( 'init', 'my_init_function' ) );
    }
}
```

## Build Process

### Asset Building
```bash
# Build JavaScript and CSS
npm run build

# Development build (with source maps)
npm run dev

# Watch for changes
npm run start
```

### PHP Development
WordPress Core uses modern PHP practices:
- Namespaces for new code
- Type declarations where appropriate
- PSR-4 autoloading for new classes
- Backward compatibility maintained

## Integration Points

### With Gutenberg
- Blocks sync from Gutenberg to Core
- REST API endpoints support block editor
- Admin styles work with Gutenberg components

### With Calypso
- REST API provides data to Calypso
- Authentication systems integrate
- Shared design patterns where possible

## Key Files and Locations

- **wp-config.php** — WordPress configuration
- **wp-load.php** — WordPress loading process
- **wp-includes/functions.php** — Core functions
- **wp-admin/admin.php** — Admin area entry point
- **wp-includes/rest-api/** — REST API classes
- **wp-includes/blocks/** — Server-side block code