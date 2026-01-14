# Design Kit (dk)

A unified workspace for designers at Automattic to work across the WordPress ecosystem with AI assistance.

## What is Design Kit?

Design Kit brings together **Calypso**, **Gutenberg**, **WordPress Core**, and **Jetpack** into a single workspace with AI-powered tooling that helps designers:

- **Build screens and flows** without deep technical knowledge
- **Discover and use existing components** across all repositories
- **Navigate cross-repo features** seamlessly
- **Prototype rapidly** using real components
- **Manage git workflows** with simplified commands

## Quick Start (AI-Driven)

### For Designers

1. **Clone the repository** (or provide the repo URL to AI in Cursor)
2. **Open in Cursor**: `cursor .`
3. **Tell the AI to set things up** using one of these methods:

   **Option A: Use the `/setup` command**
   Type `/setup` in the chat to run the full setup process.

   **Option B: Just ask naturally**
   - "Set up the environment"
   - "Initialize everything"
   - "Get this project ready"

The AI will initialize all git submodules, install dependencies, and get everything ready for you. You never need to open a terminal or run commands manually!

### For AI Assistants

When a designer asks to set up this project, follow the protocol in `.cursor/rules/setup.mdc` and the `/setup` command in `.cursor/commands/setup.md`.

### 3. Start Building

Ask the AI naturally:

> "I need a settings page with a toggle for dark mode"

> "Show me all button variants available"

> "Create a prototype of a notification center"

## Repository Structure

```
dk/
├── .cursor/rules/       # AI context and behavior rules
│   ├── base.mdc         # Core AI behavior
│   ├── calypso.mdc      # Calypso-specific context
│   ├── gutenberg.mdc    # Gutenberg-specific context
│   ├── wordpress-core.mdc
│   ├── jetpack.mdc      # Jetpack-specific context
│   └── cross-repo.mdc   # Cross-repo workflows
│
├── .cursor/commands/    # Slash commands for common tasks
│   ├── setup.md         # Environment setup
│   ├── start.md         # Start dev servers
│   ├── find-component.md
│   ├── build-screen.md
│   ├── prototype.md
│   ├── git.md
│   └── cross-repo.md
│
├── repos/               # Git submodules
│   ├── calypso/         # WordPress.com dashboard
│   ├── gutenberg/       # Block editor & components
│   ├── wordpress-core/  # Core WordPress software
│   └── jetpack/         # Security, performance & marketing plugin
│
├── docs/                # Documentation
│   ├── getting-started.md
│   └── repo-map.md
│
└── dk.config.json       # Central configuration
```

## Environment Management

Just tell the AI what you need:

| You Say | What Happens |
|---------|--------------|
| "Set up the env" | Runs `./bin/setup.sh` - initializes submodules, installs deps |
| "Reset everything" | Runs `./bin/reset.sh` - pulls latest from all repos |
| "Full reset" | Runs `./bin/reset.sh --full` - reset + reinstall all deps |
| "Show status" | Runs `./bin/status.sh` - shows state of all repos |

Or run directly:

```bash
./bin/setup.sh          # Initial setup
./bin/reset.sh          # Pull latest from all repos
./bin/reset.sh --full   # Pull latest + reinstall dependencies
./bin/status.sh         # Check status of all repos
```

## Development Servers

Use the `/start` command or just tell the AI what you want to work on:

- `/start` - shows available servers and starts one
- "Start Calypso" or "I want to work on Calypso"
- "Show me Storybook"
- "Start Gutenberg"

| Server | URL | Requires Docker |
|--------|-----|-----------------|
| Calypso | http://calypso.localhost:3000 | No |
| Gutenberg | http://localhost:9999 | No |
| Storybook | http://localhost:50240 | No |
| WordPress Core | http://localhost:8889 | Yes |
| CIAB | http://localhost:9001/wp-admin/ | Yes |
| Jetpack | http://localhost:8889 | Yes |

Or run directly:

```bash
./bin/start.sh calypso    # http://calypso.localhost:3000
./bin/start.sh gutenberg  # http://localhost:9999
./bin/start.sh storybook  # http://localhost:50240
./bin/start.sh core       # http://localhost:8889
./bin/start.sh ciab       # http://localhost:9001/wp-admin/
./bin/start.sh jetpack    # Runs in WP Core at http://localhost:8889
```

## Key Concepts

### Component Library

The primary component library is **`@wordpress/components`** from Gutenberg. Use it across all projects:

```tsx
import { Button, Card, TextControl, ToggleControl } from '@wordpress/components';
```

### Cross-Repo Features

Many features touch multiple repositories:

- **UI** lives in Calypso or Gutenberg
- **Data** flows through the REST API
- **Storage** happens in WordPress Core

The AI understands these connections and can guide you through cross-repo work.

### AI-First Workflow

The `.cursor/rules/` directory contains context that helps the AI:

- Understand each repository's structure
- Know where components and patterns live
- Suggest existing solutions before creating new ones
- Handle git workflows appropriately

## Troubleshooting

**Submodules not initializing:**
- Try `git submodule update --init --recursive --depth 1`

**Dependencies failing:**
- Check Node.js version (must be v18+)
- Clear cache: `yarn cache clean` or `npm cache clean --force`

**Port conflicts:**
- Check if ports are in use: `lsof -i :3000`

**Docker not installed (for WordPress Core / CIAB):**
- Download Docker Desktop: https://docs.docker.com/desktop/install/
- Only needed if you want to run local WordPress environments
- Calypso, Gutenberg, and Storybook work without Docker

## Documentation

- **[Getting Started](docs/getting-started.md)** - Complete setup guide
- **[Repository Map](docs/repo-map.md)** - How the repos connect
- **[Jetpack Guide](docs/jetpack-guide.md)** - Jetpack development guide

## Commands

Type `/` in chat to access these commands:

| Command | Purpose |
|---------|---------|
| `/setup` | Set up the environment (submodules + dependencies) |
| `/start` | Start a development server |
| `/find-component` | Find existing UI components |
| `/build-screen` | Create new pages/views |
| `/prototype` | Quick mockups |
| `/git` | Version control help |
| `/cross-repo` | Navigate between repos |

## Configuration

See `dk.config.json` for:

- Repository paths and structure
- Component library locations
- Dev server configurations
- Cross-repo connection mappings

## Contributing

When adding features to dk:

1. Update relevant `.cursor/rules/*.mdc` files for AI context
2. Add or update `.cursor/commands/*.md` for new workflows
3. Update `dk.config.json` if paths or structure change
4. Keep documentation in sync

## License

MIT - See individual repository licenses for Calypso, Gutenberg, and WordPress Core.
