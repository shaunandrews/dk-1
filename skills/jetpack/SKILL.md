# Jetpack Plugin Development

This skill covers working with Jetpack, including its monorepo architecture, module system, blocks, packages, and integration with WordPress Core.

## Overview

Jetpack is a comprehensive WordPress plugin that provides security, performance, marketing, and design tools. It's built as a monorepo containing multiple packages, modules, and blocks, developed using Node 22, pnpm, and PHP.

## Repository Structure

### Monorepo Architecture
Jetpack uses a monorepo structure with multiple packages and plugins:

```
jetpack/
├── projects/
│   ├── packages/         # Shared PHP/JS packages
│   ├── plugins/          # Individual plugins
│   │   ├── jetpack/      # Main Jetpack plugin
│   │   ├── boost/        # Jetpack Boost
│   │   └── ...
│   └── js-packages/      # JavaScript packages
├── tools/                # Build and development tools
└── docker/               # Development environment
```

### Development Setup

#### Prerequisites
- Node 22.19.0 (use nvm)
- pnpm package manager
- Composer for PHP dependencies
- Docker Desktop (optional, for full development environment)

#### Setup Commands
```bash
cd repos/jetpack
source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
```

#### Building Jetpack
```bash
# Build main Jetpack plugin
pnpm jetpack build plugins/jetpack --deps

# Watch for changes during development
pnpm jetpack watch plugins/jetpack
```

## Jetpack CLI

The monorepo includes a custom CLI tool (`pnpm jetpack`) for common tasks:

```bash
# Build commands
pnpm jetpack build plugins/jetpack    # Build plugin
pnpm jetpack build --deps             # Include dependencies
pnpm jetpack watch plugins/jetpack    # Watch for changes

# Development commands
pnpm jetpack generate                 # Generate boilerplate code
pnpm jetpack test plugins/jetpack     # Run tests
pnpm jetpack lint plugins/jetpack     # Run linting

# Package management
pnpm jetpack cli link                 # Link packages for development
```

## Module System

Jetpack features are organized as modules that can be activated/deactivated:

### Module Structure
```php
// Module definition
class Jetpack_My_Module {
    public static function init() {
        if ( Jetpack::is_module_active( 'my-module' ) ) {
            // Module functionality
        }
    }
}

// Register module
Jetpack::enable_module_configurable( __FILE__ );
```

### Module Configuration
```php
// Module configuration array
return array(
    'name'        => __( 'My Module', 'jetpack' ),
    'description' => __( 'Module description', 'jetpack' ),
    'sort'        => 5,
    'introduced'  => '1.0',
    'changed'     => '',
    'deactivate'  => '',
    'free'        => true,
    'requires_connection' => false,
);
```

### Common Modules
- **Publicize** — Social media sharing
- **Related Posts** — Show related content
- **Contact Form** — Contact form builder
- **Subscriptions** — Email subscriptions
- **Stats** — Site statistics
- **Security** — Brute force protection
- **Performance** — Site optimization

## Package Architecture

### Shared PHP Packages
Located in `projects/packages/`, these provide common functionality:

#### Connection Package
Handles WordPress.com authentication:
```php
use Automattic\Jetpack\Connection\Manager as Connection_Manager;

$connection = new Connection_Manager();
if ( $connection->is_connected() ) {
    // User is connected to WordPress.com
}
```

#### Status Package
Provides site status information:
```php
use Automattic\Jetpack\Status;

$status = new Status();
if ( $status->is_development_mode() ) {
    // Site is in development mode
}
```

#### Assets Package
Manages asset enqueueing:
```php
use Automattic\Jetpack\Assets;

Assets::register_script(
    'my-script',
    'build/my-script.js',
    __FILE__,
    array(
        'dependencies' => array( 'wp-element' ),
        'in_footer' => true,
    )
);
```

### JavaScript Packages
Located in `projects/js-packages/`:

- **connection** — Connection UI components
- **components** — Reusable React components
- **eslint-config-jetpack** — ESLint configuration
- **webpack-config** — Webpack configuration

## Block Development in Jetpack

### Jetpack Block Structure
```javascript
// Block registration
import { registerBlockType } from '@wordpress/blocks';
import { __ } from '@wordpress/i18n';

registerBlockType( 'jetpack/my-block', {
    title: __( 'My Block', 'jetpack' ),
    category: 'jetpack',
    attributes: {
        content: { type: 'string' }
    },
    edit: EditComponent,
    save: SaveComponent,
} );
```

### Block Categories
Jetpack registers its own block category:
```javascript
// Block categories
wp.blocks.getCategories().push( {
    slug: 'jetpack',
    title: __( 'Jetpack', 'jetpack' ),
} );
```

### Common Jetpack Blocks
- **Contact Info** — Business contact information
- **Mailchimp** — Newsletter signup
- **Pinterest** — Pinterest boards
- **Slideshow** — Image carousel
- **Tiled Gallery** — Mosaic image layout
- **Video Press** — Video hosting and playback

## Integration with WordPress Core

### WordPress.com Connection
Jetpack requires connection to WordPress.com for many features:

```php
// Check connection status
if ( Jetpack::is_connection_ready() ) {
    // Connection is established
}

// User connection
if ( Jetpack::is_user_connected() ) {
    // Current user is connected
}
```

### REST API Extensions
Jetpack extends WordPress REST API:
```php
// Register custom endpoint
add_action( 'rest_api_init', function() {
    register_rest_route( 'jetpack/v4', '/my-endpoint', array(
        'methods' => 'GET',
        'callback' => 'my_jetpack_endpoint',
        'permission_callback' => array( 'Jetpack_Connection_Manager', 'check_connection_owner' ),
    ) );
} );
```

### WordPress Core Mounting
For development, Jetpack mounts in WordPress Core using a mu-plugin that fixes `plugins_url()`:

```php
// mu-plugins/jetpack-monorepo-fix.php
add_filter( 'plugins_url', function( $url, $path, $plugin ) {
    if ( strpos( $plugin, 'jetpack' ) !== false ) {
        // Fix plugin URL for monorepo development
        return str_replace( '/plugins/jetpack/projects/plugins/', '/plugins/', $url );
    }
    return $url;
}, 10, 3 );
```

## Development Workflow

### Local Development Setup
1. **WordPress Core setup** with Jetpack mounted via mu-plugin
2. **Jetpack build** using `pnpm jetpack build`
3. **Development watching** with `pnpm jetpack watch`

### Development Server
When developing with WordPress Core:
```bash
# Start WordPress Core with Jetpack
cd repos/wordpress-core
npm run dev  # → http://localhost:8889

# In another terminal, watch Jetpack changes
cd repos/jetpack  
pnpm jetpack watch plugins/jetpack
```

### Testing
```bash
# Run PHP tests
pnpm jetpack test plugins/jetpack

# Run JavaScript tests
pnpm test

# Run specific test suites
pnpm jetpack test plugins/jetpack --testsuite=my-suite
```

## Configuration and Settings

### Jetpack Settings API
```php
// Get Jetpack option
$value = Jetpack_Options::get_option( 'my_option' );

// Set Jetpack option
Jetpack_Options::update_option( 'my_option', $value );

// Delete Jetpack option
Jetpack_Options::delete_option( 'my_option' );
```

### Module Settings
```php
// Module-specific settings
class Jetpack_My_Module_Settings {
    public static function get_settings() {
        return array(
            'setting_1' => array(
                'label' => __( 'Setting 1', 'jetpack' ),
                'type' => 'boolean',
                'default' => false,
            ),
        );
    }
}
```

## Performance and Optimization

### Lazy Loading
Jetpack implements lazy loading for performance:
```php
// Lazy load module
add_action( 'plugins_loaded', array( 'Jetpack_My_Module', 'init' ) );

// Conditional loading
if ( is_admin() ) {
    require_once 'admin-only-code.php';
}
```

### Asset Management
```javascript
// Dynamic imports for code splitting
const loadComponent = () => import( './heavy-component' );

// Conditional loading
if ( condition ) {
    import( './conditional-feature' ).then( module => {
        module.init();
    } );
}
```

### Caching Strategies
```php
// Transient caching
$cache_key = 'jetpack_my_data';
$data = get_transient( $cache_key );

if ( false === $data ) {
    $data = expensive_operation();
    set_transient( $cache_key, $data, HOUR_IN_SECONDS );
}
```

## Security Patterns

### WordPress.com Authentication
```php
// Verify WordPress.com token
$user_token = Jetpack_Data::get_access_token();
if ( $user_token && $user_token->is_valid() ) {
    // Token is valid
}
```

### Nonce and Capability Checks
```php
// Jetpack-specific capability checks
if ( ! current_user_can( 'jetpack_configure_modules' ) ) {
    wp_die( 'Insufficient permissions' );
}

// Module-specific capabilities
if ( ! Jetpack::is_module_active( 'stats' ) ) {
    return;
}
```

## Building and Deployment

### Build Process
```bash
# Full build including dependencies
pnpm jetpack build plugins/jetpack --deps

# Production build
NODE_ENV=production pnpm jetpack build plugins/jetpack
```

### Release Process
1. Version bump in plugin files
2. Build production assets
3. Generate changelog
4. Create release branch
5. Deploy to WordPress.com infrastructure

### WordPress.org Release
Jetpack releases to WordPress.org plugin directory:
- Automated build process
- SVN repository management
- Compatibility testing across WordPress versions

## Debugging and Development Tools

### Debug Mode
```php
// Enable Jetpack debug mode
define( 'JETPACK_DEV_DEBUG', true );

// Log debug information
if ( defined( 'JETPACK_DEV_DEBUG' ) && JETPACK_DEV_DEBUG ) {
    error_log( 'Jetpack debug: ' . $message );
}
```

### Development Constants
```php
// Development mode (no WordPress.com connection required)
define( 'JETPACK_DEV_DEBUG', true );

// Beta features
define( 'JETPACK_BETA_BLOCKS', true );
```

## Common Development Patterns

### React Component Development
```javascript
import { Component } from '@wordpress/element';
import { __ } from '@wordpress/i18n';

class MyJetpackComponent extends Component {
    render() {
        return (
            <div className="jetpack-my-component">
                {__( 'Jetpack Component', 'jetpack' )}
            </div>
        );
    }
}
```

### WordPress Data Integration
```javascript
import { useSelect, useDispatch } from '@wordpress/data';

const MyComponent = () => {
    const { settings } = useSelect( select => ({
        settings: select( 'jetpack' ).getSettings()
    }));
    
    const { updateSettings } = useDispatch( 'jetpack' );
    
    return (
        <div>
            {/* Component using Jetpack data */}
        </div>
    );
};
```

## Troubleshooting

### Node Version Issues
Always ensure Node 22:
```bash
source ~/.nvm/nvm.sh && nvm use
```

### Build Failures
```bash
# Clean and rebuild
pnpm jetpack clean plugins/jetpack
pnpm jetpack build plugins/jetpack --deps
```

### Connection Issues
```bash
# Debug connection status
wp jetpack status

# Reconnect to WordPress.com
wp jetpack disconnect
wp jetpack connect
```

## Key Development Resources

- **Jetpack GitHub**: https://github.com/Automattic/jetpack
- **Jetpack CLI Documentation**: Internal monorepo tools
- **WordPress.com API Documentation**: Integration endpoints
- **Jetpack Beta Plugin**: Testing upcoming features
- **Module Development Guide**: Creating new Jetpack modules