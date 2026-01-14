# Jetpack Development Guide

A comprehensive guide to developing with Jetpack in the Design Kit environment.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [Development Workflow](#development-workflow)
5. [Monorepo Structure](#monorepo-structure)
6. [Key Concepts](#key-concepts)
7. [Common Tasks](#common-tasks)

---

## Overview

Jetpack is a WordPress plugin that connects self-hosted WordPress sites to WordPress.com services. It provides security, performance, marketing, and design tools.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WordPress.com Cloud                              │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Photon    │  │   Backup    │  │   Search    │  │    Stats    │    │
│  │   (CDN)     │  │  (VaultPress)│  │  (Elastic)  │  │  Analytics  │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │            │
│         └────────────────┴────────────────┴────────────────┘            │
│                                    │                                     │
│                            Jetpack API                                   │
│                          /wp-json/jetpack/v4/                           │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     │ HTTPS
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                       Self-Hosted WordPress Site                         │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                         Jetpack Plugin                              │ │
│  │                                                                     │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │ │
│  │  │  Stats   │ │ Protect  │ │   SSO    │ │  Sharing │ │  Forms   │ │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │ │
│  │                                                                     │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │ │
│  │  │ Markdown │ │ Photon   │ │ Related  │ │ Infinite │ │  Blocks  │ │ │
│  │  │          │ │ (Images) │ │  Posts   │ │  Scroll  │ │          │ │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌─────────────────────────┐      ┌─────────────────────────────────┐  │
│  │     WordPress Core      │      │        Gutenberg Editor         │  │
│  │    (PHP/MySQL/REST)     │◀────▶│       (Block Editor)            │  │
│  └─────────────────────────┘      └─────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

**Key Characteristics:**
- Modular plugin architecture (enable/disable features)
- WordPress.com connection for cloud services
- Extends Gutenberg with custom blocks
- REST API for settings and data

---

## Architecture

### In Design Kit

Jetpack is integrated into the WordPress Core development environment via Docker volume mounts and a symlink created at startup:

```
dk/
├── repos/
│   ├── wordpress-core/           # WordPress development
│   │   ├── docker-compose.yml    # Mounts Jetpack projects folder
│   │   └── src/wp-content/
│   │       ├── plugins/
│   │       │   ├── gutenberg/    # ← Mounted from ../gutenberg
│   │       │   └── jetpack/      # ← Symlink created at startup
│   │       └── mu-plugins/
│   │           └── jetpack-monorepo-fix.php  # URL fix for monorepo
│   ├── gutenberg/                # Block editor
│   └── jetpack/                  # Jetpack monorepo
│       └── projects/
│           ├── plugins/jetpack/  # Main plugin
│           └── packages/         # Shared packages (symlinked in jetpack_vendor)
```

### Volume Mount Configuration

From `repos/wordpress-core/docker-compose.yml`:

```yaml
services:
  wordpress-develop:
    volumes:
      - ../gutenberg:/var/www/src/wp-content/plugins/gutenberg
      # Mount entire projects folder so jetpack_vendor symlinks resolve
      - ../jetpack/projects:/var/www/jetpack-projects
```

**Why mount the entire `projects` folder?**

The Jetpack plugin uses symlinks in `jetpack_vendor/` that point to `../../../../packages/`. These symlinks need access to the `packages/` directory at the correct relative path. By mounting the full `projects` folder, all internal symlinks resolve correctly.

### Symlink Creation

When you run `./bin/start.sh jetpack`, a symlink is automatically created inside the Docker container:

```bash
# Created automatically by start.sh
/var/www/src/wp-content/plugins/jetpack → /var/www/jetpack-projects/plugins/jetpack
```

### MU-Plugin URL Fix

A must-use plugin (`jetpack-monorepo-fix.php`) is required to fix `plugins_url()` calls from Jetpack packages. When PHP resolves `__FILE__` in symlinked packages, it returns paths outside the WordPress plugins directory, causing incorrect asset URLs. The mu-plugin filters these URLs to point to the correct location.

---

## Getting Started

### Prerequisites

- Docker Desktop (for WordPress Core environment)
- pnpm (for Jetpack dependencies)
- Composer (for PHP dependencies)

### Quick Start

```bash
# 1. Set up the environment (installs dependencies)
./bin/setup.sh

# 2. Build Jetpack with all dependencies (required first time)
cd repos/jetpack
pnpm jetpack build plugins/jetpack --deps

# 3. Start WordPress Core with Jetpack
./bin/start.sh jetpack

# 4. Access WordPress admin
open http://localhost:8889/wp-admin/

# 5. Activate Jetpack
# Navigate to Plugins → Activate Jetpack

# 6. (Optional) Start Jetpack watch mode for development
cd repos/jetpack
pnpm jetpack watch plugins/jetpack
```

---

## Development Workflow

### Building Jetpack

```bash
cd repos/jetpack

# Install dependencies (first time)
pnpm install
composer install

# Build Jetpack plugin with all dependencies (REQUIRED for first build)
pnpm jetpack build plugins/jetpack --deps

# Watch mode (rebuilds on changes)
pnpm jetpack watch plugins/jetpack

# Build without dependencies (faster, for subsequent builds)
pnpm jetpack build plugins/jetpack

# Build specific package
pnpm jetpack build packages/connection
```

### Running Tests

```bash
cd repos/jetpack

# All tests
pnpm run test

# PHP tests only
pnpm run test-php

# JavaScript tests only
pnpm run test-js

# E2E tests
pnpm run test-e2e
```

### Using Jetpack CLI

```bash
cd repos/jetpack

# Generate a new package
pnpm jetpack generate package my-package

# Generate a new plugin
pnpm jetpack generate plugin my-plugin

# Changelog management
pnpm jetpack changelog add
```

---

## Monorepo Structure

```
repos/jetpack/
│
├── projects/
│   │
│   ├── plugins/                    # WordPress Plugins
│   │   ├── jetpack/               # Main Jetpack plugin
│   │   ├── backup/                # Jetpack Backup (standalone)
│   │   ├── boost/                 # Jetpack Boost (performance)
│   │   ├── protect/               # Jetpack Protect (security)
│   │   ├── search/                # Jetpack Search
│   │   ├── social/                # Jetpack Social (Publicize)
│   │   ├── videopress/            # VideoPress
│   │   ├── crm/                   # Jetpack CRM
│   │   └── ...
│   │
│   ├── packages/                   # Shared PHP Packages
│   │   ├── connection/            # WordPress.com connection
│   │   ├── sync/                  # Data synchronization
│   │   ├── assets/                # Asset management
│   │   ├── autoloader/            # Classmap autoloader
│   │   ├── backup/                # Backup functionality
│   │   ├── blocks/                # Block registration
│   │   ├── config/                # Configuration
│   │   ├── identity-crisis/       # Site identity
│   │   ├── logo/                  # Jetpack logo
│   │   ├── my-jetpack/            # My Jetpack dashboard
│   │   ├── status/                # Status checks
│   │   └── ...
│   │
│   └── js-packages/                # Shared JavaScript Packages
│       ├── api/                   # REST API client
│       ├── components/            # React components
│       ├── connection/            # Connection UI
│       ├── i18n-loader-webpack-plugin/
│       ├── storybook/             # Storybook config
│       └── ...
│
├── tools/                          # Development Tools
│   ├── cli/                       # Jetpack CLI
│   └── ...
│
└── docs/                           # Documentation
```

---

## Key Concepts

### Modules

Jetpack features are organized as **modules** that can be independently activated:

| Module | Description | File |
|--------|-------------|------|
| Stats | Site analytics | `modules/stats.php` |
| Protect | Brute force protection | `modules/protect.php` |
| Publicize | Social sharing | `modules/publicize.php` |
| Sharing | Share buttons | `modules/sharing.php` |
| Subscriptions | Email subscriptions | `modules/subscriptions.php` |
| Related Posts | Related content | `modules/related-posts.php` |
| Likes | Like buttons | `modules/likes.php` |
| Comments | Enhanced comments | `modules/comments.php` |
| Contact Form | Contact forms | `modules/contact-form.php` |
| Markdown | Markdown support | `modules/markdown.php` |
| Infinite Scroll | Infinite scrolling | `modules/infinite-scroll.php` |
| Photon | Image CDN | `modules/photon.php` |
| SSO | WordPress.com login | `modules/sso.php` |
| Sitemaps | XML sitemaps | `modules/sitemaps.php` |
| Search | Enhanced search | `modules/search.php` |
| VideoPress | Video hosting | `modules/videopress.php` |

### WordPress.com Connection

Jetpack connects sites to WordPress.com for cloud services:

```php
use Automattic\Jetpack\Connection\Manager;

$manager = new Manager( 'jetpack' );

// Check connection status
if ( $manager->is_connected() ) {
    // Site is connected
}

// Check user connection
if ( $manager->is_user_connected() ) {
    // Current user is connected
}
```

### Data Sync

Jetpack syncs WordPress data to WordPress.com:

```php
use Automattic\Jetpack\Sync\Actions;

// Trigger a full sync
Actions::do_full_sync();

// Send specific data
Actions::send_data( $data, 'custom_sync' );
```

---

## Common Tasks

### Adding a Custom Block

1. Create block directory in `extensions/blocks/`:

```
extensions/blocks/my-block/
├── block.json
├── index.js
├── edit.js
├── save.js
├── editor.scss
└── style.scss
```

2. Register in `extensions/blocks/index.json`:

```json
{
  "production": [
    "my-block"
  ]
}
```

3. Create `block.json`:

```json
{
  "apiVersion": 2,
  "name": "jetpack/my-block",
  "title": "My Block",
  "category": "jetpack",
  "icon": "star-filled",
  "attributes": {
    "content": { "type": "string" }
  }
}
```

### Adding a REST Endpoint

```php
// In json-endpoints/ or custom file

add_action( 'rest_api_init', function() {
    register_rest_route( 'jetpack/v4', '/my-endpoint', [
        'methods'             => 'GET',
        'callback'            => 'my_endpoint_handler',
        'permission_callback' => function() {
            return current_user_can( 'manage_options' );
        }
    ]);
});

function my_endpoint_handler( $request ) {
    return rest_ensure_response([
        'success' => true,
        'data'    => 'Hello from Jetpack!'
    ]);
}
```

### Modifying the Admin UI

The Jetpack admin is a React SPA in `_inc/client/`:

```
_inc/client/
├── admin.js              # Entry point
├── components/           # React components
│   ├── dash-item/
│   ├── module-settings/
│   ├── navigation/
│   └── ...
├── state/                # Redux state
│   ├── modules/
│   ├── settings/
│   └── ...
└── lib/                  # Utilities
```

---

## Debugging

### Enable Debug Mode

In `wp-config.php`:

```php
define( 'WP_DEBUG', true );
define( 'JETPACK_DEV_DEBUG', true );
```

### Check Connection Status

```bash
# Via WP-CLI in Docker
cd repos/wordpress-core
npm run env:cli -- jetpack status
```

### View Sync Status

```php
// In PHP
use Automattic\Jetpack\Sync\Health;
$status = Health::get_status();
```

---

## Useful Links

- [Jetpack Developer Documentation](https://developer.jetpack.com/)
- [Jetpack GitHub Repository](https://github.com/Automattic/jetpack)
- [Jetpack Storybook](https://automattic.github.io/jetpack-storybook/)
- [WordPress.com REST API](https://developer.wordpress.com/docs/api/)
