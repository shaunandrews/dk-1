# Development Server Management

This skill covers starting, stopping, and managing development servers across the WordPress ecosystem, including port management, URL configuration, and conflict prevention.

## Overview

The WordPress ecosystem requires multiple development servers running simultaneously, each with specific ports, URLs, and startup procedures. This skill provides the knowledge and tools to manage these servers effectively.

## Server Configuration

### Development Server Mapping

| Repository | Server Type | Port | URL | Command |
|------------|-------------|------|-----|---------|
| **Calypso** | webpack-dev-server | 3000 | http://calypso.localhost:3000<br>http://my.localhost:3000 | `yarn start:debug` |
| **Gutenberg** | WordPress dev | 9999 | http://localhost:9999 | `npm run dev` |
| **Gutenberg** | Storybook | 50240 | http://localhost:50240 | `npm run storybook` |
| **WordPress Core** | wp-env | 8889 | http://localhost:8889 | `npm run dev` |
| **Jetpack** | (runs in Core) | - | Uses Core's wp-env | `pnpm jetpack watch` |
| **CIAB** | webpack + wp-env | 9001 | http://localhost:9001/wp-admin/ | `pnpm dev` |
| **Telex** | vite + MinIO | 3000 | http://localhost:3000 | `pnpm run dev` |
| **MinIO** | S3 storage | 9000/9001 | http://localhost:9001 (admin) | `pnpm run minio:start` |

## Server Management Patterns

### 1. Single Server Startup

#### Calypso Development Server
```bash
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
yarn start:debug

# Two interfaces available:
# • Legacy Interface: http://calypso.localhost:3000
# • New Dashboard: http://my.localhost:3000
```

**Features:**
- Hot module replacement
- Live reloading
- Redux DevTools integration
- i18n hot loading
- SCSS compilation

#### Gutenberg Development
```bash
cd repos/gutenberg  
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 20
npm run build  # Required first time
npm run dev     # → http://localhost:9999

# Separate terminal for Storybook
npm run storybook  # → http://localhost:50240
```

**Features:**
- WordPress Playground integration
- Block editor testing environment
- Component library with Storybook
- Hot reloading for blocks

#### WordPress Core Development
```bash
cd repos/wordpress-core
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 20
npm run dev  # → http://localhost:8889

# Admin: http://localhost:8889/wp-admin/
# Username: admin
# Password: password
```

**Features:**
- wp-env Docker environment
- Database persistence
- PHP debugging support
- WordPress multisite support

#### Jetpack Development
```bash
# Jetpack requires WordPress Core to be running first
cd repos/wordpress-core && npm run dev  # Terminal 1

# In second terminal:
cd repos/jetpack
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
pnpm jetpack watch plugins/jetpack

# Access via Core: http://localhost:8889/wp-admin/
```

**Features:**
- Real-time asset compilation
- Plugin development in WordPress context
- Module system testing
- WordPress.com connection simulation

#### CIAB Development  
```bash
cd repos/ciab
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22
pnpm dev  # → http://localhost:9001/wp-admin/

# CIAB replaces WordPress admin interface
```

**Features:**
- React SPA development
- WordPress admin replacement
- TanStack Router hot reload
- Component library integration

#### Telex Development
```bash
cd repos/telex
source ~/.nvm/nvm.sh && nvm use  # Switch to Node 22

# Start MinIO first (required!)
pnpm run minio:start

# Start development server
pnpm run dev  # → http://localhost:3000

# MinIO admin: http://localhost:9001
```

**Features:**
- AI block generation
- S3/MinIO integration
- WordPress Playground embedding
- Real-time preview updates

### 2. Multi-Server Startup

Start multiple servers for cross-repository development:

```bash
# Terminal 1: WordPress Core (foundation)
cd repos/wordpress-core && npm run dev

# Terminal 2: Calypso (frontend)
cd repos/calypso && yarn start:debug  

# Terminal 3: Jetpack (plugin development)
cd repos/jetpack && pnpm jetpack watch plugins/jetpack

# Terminal 4: Gutenberg Storybook (components)
cd repos/gutenberg && npm run storybook
```

## Port Conflict Management

### Port Usage Strategy
- **3000**: Calypso and Telex (different hosts: `calypso.localhost` vs `localhost`)
- **8889**: WordPress Core (Docker)
- **9999**: Gutenberg development environment
- **50240**: Gutenberg Storybook
- **9001**: CIAB and MinIO admin (different contexts)

### Conflict Resolution
```bash
# Check what's using a port
lsof -ti:3000

# Kill process on port
kill $(lsof -ti:3000)

# Find all WordPress development processes
lsof -ti:3000,8889,9999,50240,9001
```

### wp-env Conflict Prevention
**Critical Rule**: Only run ONE wp-env instance at a time.

```bash
# ✅ Correct: Use WordPress Core when both exist
cd repos/wordpress-core && npm run dev

# ❌ Wrong: Don't run Gutenberg wp-env when Core exists
# cd repos/gutenberg && npm run dev  # CONFLICTS!

# ✅ Correct: Use Gutenberg Storybook separately
cd repos/gutenberg && npm run storybook
```

## Environment Configuration

### Host Configuration

#### Calypso Hosts
Add to `/etc/hosts` (macOS/Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
```
127.0.0.1 calypso.localhost
127.0.0.1 my.localhost
```

#### SSL Configuration
Some servers may require SSL certificates for full functionality:

```bash
# Install local CA (if needed)
brew install mkcert  # macOS
mkcert -install

# Generate certificates for Calypso
cd repos/calypso
mkcert calypso.localhost my.localhost
```

### Environment Variables
Each repository may require specific environment variables:

#### Calypso
```bash
# Optional: API endpoints
export CALYPSO_ENV=development
export API_HOST=public-api.wordpress.com
```

#### WordPress Core
```bash
# wp-env configuration
export WP_ENV_PORT=8889
export WP_ENV_MYSQL_PORT=8890
```

#### Telex
```bash
# Required for AI integration
export ANTHROPIC_API_KEY=your_api_key
export WPCOM_CLIENT_ID=your_client_id
export WPCOM_CLIENT_SECRET=your_client_secret
```

## Development Workflows

### Cross-Repository Development

#### Workflow 1: Block Development with Testing
```bash
# 1. Start WordPress Core for testing
cd repos/wordpress-core && npm run dev

# 2. Start Gutenberg for block development
cd repos/gutenberg && npm run storybook  # Components only

# 3. Start Calypso for admin interface
cd repos/calypso && yarn start:debug

# Test flow:
# Develop block → Test in Core → Manage in Calypso
```

#### Workflow 2: Plugin Development with Jetpack
```bash
# 1. Start WordPress Core
cd repos/wordpress-core && npm run dev

# 2. Watch Jetpack changes
cd repos/jetpack && pnpm jetpack watch plugins/jetpack

# 3. Start Calypso for WordPress.com integration
cd repos/calypso && yarn start:debug

# Test flow:
# Develop plugin → Test in Core → Integrate with Calypso
```

#### Workflow 3: Full Stack Development
```bash
# All servers for complete development environment
# Terminal 1
cd repos/wordpress-core && npm run dev

# Terminal 2  
cd repos/calypso && yarn start:debug

# Terminal 3
cd repos/jetpack && pnpm jetpack watch plugins/jetpack

# Terminal 4
cd repos/gutenberg && npm run storybook

# Terminal 5 (if needed)
cd repos/telex && pnpm run minio:start && pnpm run dev
```

## Server Status and Health Checks

### Health Check Commands
```bash
# Check if servers are responding
curl -s http://localhost:8889 > /dev/null && echo "WordPress Core: ✅" || echo "WordPress Core: ❌"
curl -s http://calypso.localhost:3000 > /dev/null && echo "Calypso: ✅" || echo "Calypso: ❌" 
curl -s http://localhost:9999 > /dev/null && echo "Gutenberg: ✅" || echo "Gutenberg: ❌"
curl -s http://localhost:50240 > /dev/null && echo "Storybook: ✅" || echo "Storybook: ❌"
```

### Server Logs
Monitor server logs for debugging:

```bash
# Calypso logs (in the terminal running yarn start:debug)
# Look for compilation errors, API call failures

# WordPress Core logs
cd repos/wordpress-core
npm run env logs

# Jetpack logs  
cd repos/jetpack
pnpm jetpack build plugins/jetpack --verbose
```

## Performance Optimization

### Development Server Performance

#### Calypso Optimization
```bash
# Use debug mode for faster compilation
yarn start:debug

# Skip type checking for faster builds (if needed)
SKIP_TYPE_CHECK=true yarn start:debug

# Optimize memory usage
export NODE_OPTIONS="--max-old-space-size=4096"
```

#### Gutenberg Optimization
```bash
# Skip build for just Storybook
npm run storybook  # Doesn't require full build

# Faster builds during development
npm run dev:build-packages-watch  # Watch mode for packages
```

#### WordPress Core Optimization
```bash
# Allocate more resources to Docker
export WP_ENV_CORE=WordPress/WordPress@main
export WP_ENV_PHP_VERSION=8.0

# Skip plugin installation for faster startup
npm run env:start -- --skip-plugins
```

## Debugging and Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Identify conflicting process
lsof -ti:3000
lsof -P -i :3000

# Kill specific process
kill -9 $(lsof -ti:3000)
```

#### Node Version Mismatch
```bash
# Always check Node version first
node --version

# Switch to correct version
cd repos/[repo-name]
source ~/.nvm/nvm.sh && nvm use
```

#### Docker Issues (wp-env)
```bash
# Check Docker status
docker ps
docker system df  # Check disk usage

# Clean up Docker resources
docker system prune
npm run env clean  # WordPress Core specific
```

#### Build Failures
```bash
# Clear caches and reinstall
# Calypso
yarn cache clean && rm -rf node_modules && yarn install

# Gutenberg/WordPress Core
npm cache clean --force && rm -rf node_modules && npm ci

# Jetpack/CIAB/Telex
pnpm store prune && rm -rf node_modules && pnpm install
```

### Performance Issues
- **High CPU usage**: Check for infinite rebuild loops
- **High memory usage**: Restart servers periodically
- **Slow startup**: Clear caches and update dependencies
- **Hot reload not working**: Check file watchers and port conflicts

## Advanced Server Management

### Custom Development Scripts

#### Multi-Server Control Script
Located in `skills/dev-servers/scripts/start.sh`:

```bash
#!/bin/bash
# Start development servers with proper configuration

case "$1" in
    "calypso")
        cd repos/calypso
        source ~/.nvm/nvm.sh && nvm use
        yarn start:debug
        ;;
    "all")
        # Start all servers in background
        # Implementation in skills/dev-servers/scripts/start.sh
        ;;
esac
```

#### Server Status Dashboard
```bash
# skills/dev-servers/scripts/status.sh
# Shows status of all development servers with URLs
```

### Containerized Development (Advanced)

For complex setups, consider Docker Compose:

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  wordpress-core:
    build: ./repos/wordpress-core
    ports:
      - "8889:80"
  
  calypso:
    build: ./repos/calypso  
    ports:
      - "3000:3000"
    
  minio:
    image: minio/minio
    ports:
      - "9000:9000" 
      - "9001:9001"
```

This development server management approach ensures reliable, conflict-free development across the entire WordPress ecosystem.