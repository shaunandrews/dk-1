---
name: start-server
description: Start Design Kit development servers with proper environment checks and Node version management
---

# Design Kit: Start Development Server

This skill helps you start development servers for any Design Kit repository with proper prerequisite checks and environment setup.

## Available Servers

| Repo | Command | URL | Node Version | Requires Docker |
|------|---------|-----|--------------|-----------------|
| Calypso | `./bin/start.sh calypso` | http://calypso.localhost:3000 | 22 | No |
| Gutenberg | `./bin/start.sh gutenberg` | http://localhost:9999 | 20 | No |
| Storybook | `./bin/start.sh storybook` | http://localhost:50240 | 20 | No |
| WordPress Core | `./bin/start.sh core` | http://localhost:8889 | 20 | No (wp-env Playground) |
| CIAB | `./bin/start.sh ciab` | http://localhost:9001/wp-admin/ | 22 | No (wp-env Playground) |
| Jetpack | `./bin/start.sh jetpack` | http://localhost:8889 | 22 | No (wp-env Playground) |
| Telex | See special setup | http://localhost:3000 | 22 | Yes (MinIO) |

## Execution Steps

### Step 1: Identify the Target

Map user intent to repository:

- "Start Calypso" / "Work on dashboard" → calypso
- "Start Gutenberg" / "Work on blocks" → gutenberg
- "Show components" / "Component library" → storybook
- "Start WordPress" / "Need WordPress" → core
- "Work on Jetpack" → jetpack
- "Commerce admin" → ciab
- "Block authoring" / "Telex" → telex

### Step 2: Check Prerequisites

Run these checks IN ORDER:

**2.1 Check if dependencies are installed:**
```bash
Bash: ls -la repos/[repo-name]/node_modules
```

If missing:
```
The dependencies for [repo] aren't installed yet. Let me run setup first...
[Execute ./bin/setup.sh or suggest running it]
```

**2.2 For wp-env repos (core, ciab, jetpack), check @wordpress/env:**
```bash
Bash: npx @wordpress/env --version
```

If @wordpress/env isn't available:
```
[Repo] requires @wordpress/env to be installed.

Ensure @wordpress/env is installed:
  npm -g install @wordpress/env

wp-env uses Playground runtime by default — no Docker needed.
```

### Step 3: Start the Server

Use the unified start script:

```bash
Bash: ./bin/start.sh [repo-name]
run_in_background: true
```

**Important timing expectations:**
- **Calypso**: 30-60 seconds for initial compile (debug mode)
- **Gutenberg**: ~30 seconds
- **Storybook**: ~45 seconds
- **WordPress Core**: 5-10 seconds (Playground runtime)
- **Jetpack**: 10-15 seconds (includes Core + plugin setup)

### Step 4: Communicate Status

Tell the user:

```
🚀 Starting [Repo Name] development server...

• URL: [url]
• Initial startup: ~[time] seconds
[Additional repo-specific notes]

I'll let you know when it's ready, or you can open the URL now and wait for it to load.
```

**Repo-specific notes:**

**Calypso:**
```
Running with yarn start:debug for development mode.
This provides better error messages and debugging capabilities.
```

**Storybook:**
```
You'll be able to browse all @wordpress/components with live examples and documentation.
```

**WordPress Core:**
```
Default credentials:
• Username: admin
• Password: password
```

**Jetpack:**
```
Jetpack runs within the WordPress Core environment.
I'm also setting up the Jetpack symlink so your code changes will be reflected live.

To watch for changes during development:
  cd repos/jetpack && pnpm jetpack watch plugins/jetpack
```

**Telex (Special):**
```
Telex requires additional setup beyond ./bin/start.sh.

First, ensure MinIO is running:
  cd repos/telex && pnpm run minio:start

Then start Telex:
  pnpm run dev

See repos/telex/CLAUDE.md for complete setup instructions.
```

## Special Cases

### Multiple Servers

Users can run multiple servers simultaneously:

✅ **Compatible combinations:**
- Calypso + Storybook (common - reference components while building)
- Gutenberg + Storybook
- Any non-Docker + any other non-Docker

❌ **Conflicts:**
- Gutenberg + WordPress Core (both use wp-env on same ports)
- Use WordPress Core's wp-env when both exist

### wp-env Conflict Prevention

**CRITICAL**: When both `repos/wordpress-core` and `repos/gutenberg` exist:

- ✅ ONLY use `repos/wordpress-core` for wp-env
- ❌ NEVER start `repos/gutenberg` wp-env when wordpress-core exists
- ✅ Use `./bin/start.sh storybook` for Gutenberg components

## Troubleshooting

### Port Already in Use

If you get "port already in use" errors:

```bash
# Check what's using the port
Bash: lsof -ti:[port-number]
```

Inform the user about the conflict and suggest stopping the existing process.

### Build Errors During Startup

If the server shows compilation errors:

1. Read the error message
2. Check if it's a dependency issue (`npm ci` / `yarn install`)
3. Check if it's a code error (fix the code)
4. Provide clear guidance based on the error

## Quick Reference

### Manual Start Commands (if ./bin/start.sh fails)

```bash
# Calypso
cd repos/calypso && source ~/.nvm/nvm.sh && nvm use && yarn start:debug

# Gutenberg
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm run dev

# Storybook
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm run storybook

# WordPress Core
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && npm run dev

# Jetpack
cd repos/wordpress-core && source ~/.nvm/nvm.sh && nvm use && wp-env start --runtime=playground
```
