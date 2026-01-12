# Design Kit (dk)

A unified workspace for designers at Automattic to work across the WordPress ecosystem with AI assistance.

## What is Design Kit?

Design Kit brings together **Calypso**, **Gutenberg**, and **WordPress Core** into a single workspace with AI-powered tooling that helps designers:

- **Build screens and flows** without deep technical knowledge
- **Discover and use existing components** across all repositories
- **Navigate cross-repo features** seamlessly
- **Prototype rapidly** using real components
- **Manage git workflows** with simplified commands

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/Automattic/dk.git
cd dk
git submodule update --init --depth 1
```

### 2. Open in Cursor

```bash
cursor .
```

The AI will automatically have context about all three repositories.

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
│   └── cross-repo.mdc   # Cross-repo workflows
│
├── skills/              # AI skill definitions
│   ├── component-discovery.md
│   ├── screen-building.md
│   ├── cross-repo-nav.md
│   ├── prototyping.md
│   └── git-workflows.md
│
├── repos/               # Git submodules
│   ├── calypso/         # WordPress.com dashboard
│   ├── gutenberg/       # Block editor & components
│   └── wordpress-core/  # Core WordPress software
│
├── docs/                # Documentation
│   ├── getting-started.md
│   └── repo-map.md
│
└── dk.config.json       # Central configuration
```

## Development Servers

| Repository | Command | URL |
|------------|---------|-----|
| Calypso | `cd repos/calypso && yarn start` | http://calypso.localhost:3000 |
| Gutenberg | `cd repos/gutenberg && npm run dev` | http://localhost:9999 |
| Storybook | `cd repos/gutenberg && npm run storybook` | http://localhost:50240 |
| WP Core | `cd repos/wordpress-core && npm run dev` | http://localhost:8889 |

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

## Documentation

- **[Getting Started](docs/getting-started.md)** - Complete setup guide
- **[Repository Map](docs/repo-map.md)** - How the repos connect
- **[Skills](skills/)** - Detailed guides for specific tasks

## Configuration

See `dk.config.json` for:

- Repository paths and structure
- Component library locations
- Dev server configurations
- Cross-repo connection mappings

## Contributing

When adding features to dk:

1. Update relevant `.cursor/rules/*.mdc` files for AI context
2. Add or update `skills/*.md` for new capabilities
3. Update `dk.config.json` if paths or structure change
4. Keep documentation in sync

## License

MIT - See individual repository licenses for Calypso, Gutenberg, and WordPress Core.
