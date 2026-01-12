# Getting Started with Design Kit

Welcome to the Design Kit (dk)! This guide will help you set up your environment and start designing across the WordPress ecosystem.

## What is Design Kit?

Design Kit is a unified workspace that brings together:

- **Calypso** - WordPress.com's dashboard
- **Gutenberg** - The WordPress Block Editor
- **WordPress Core** - The foundation software

Instead of managing three separate repositories, dk lets you work across all of them with AI assistance that understands how everything connects.

## Prerequisites

Before you begin, make sure you have:

- **Git** - Version control
- **Node.js** (v18+) - JavaScript runtime
- **Yarn** - Package manager for Calypso
- **npm** - Package manager for Gutenberg/Core
- **Cursor** - AI-powered editor (recommended)

## Initial Setup

### 1. Clone the Design Kit

```bash
git clone https://github.com/Automattic/dk.git
cd dk
```

### 2. Initialize Submodules

The repositories are included as git submodules. Initialize them:

```bash
git submodule update --init --depth 1
```

This will clone Calypso, Gutenberg, and WordPress Core into the `repos/` directory.

### 3. Open in Cursor

```bash
cursor .
```

The AI will automatically have context about all three repositories thanks to the Cursor rules in `.cursor/rules/`.

## Quick Tour

### Directory Structure

```
dk/
├── .cursor/rules/       # AI context and behavior
├── skills/              # AI skill definitions
├── repos/               # The actual codebases
│   ├── calypso/         # WordPress.com dashboard
│   ├── gutenberg/       # Block editor
│   └── wordpress-core/  # Core software
├── docs/                # Documentation
└── dk.config.json       # Central configuration
```

### Key Files

| File | Purpose |
|------|---------|
| `dk.config.json` | Maps repositories, paths, and connections |
| `.cursor/rules/base.mdc` | Core AI behavior |
| `skills/*.md` | Detailed guides for specific tasks |

## Working with the AI

### Ask Natural Questions

The AI understands design language. Just ask:

- "I need a settings page with a toggle and a save button"
- "Show me all the button variants in Gutenberg"
- "Create a new block that displays a testimonial"
- "Help me commit my changes to both repos"

### The AI Will:

1. Search for existing components before creating new ones
2. Suggest code from the appropriate repository
3. Explain technical concepts in designer-friendly terms
4. Handle git workflows with sensible defaults

## Starting Development Servers

### Calypso

```bash
cd repos/calypso
yarn
yarn start
```

Open http://calypso.localhost:3000

### Gutenberg

```bash
cd repos/gutenberg
npm install
npm run dev
```

Open http://localhost:9999

For component development with Storybook:

```bash
npm run storybook
```

Open http://localhost:50240

### WordPress Core

```bash
cd repos/wordpress-core
npm install
npm run dev
```

Open http://localhost:8889

## First Tasks to Try

### 1. Explore Components

Ask the AI:
> "Show me a Card component with a form inside"

### 2. Find Patterns

Ask the AI:
> "How do settings pages look in Calypso?"

### 3. Create Something

Ask the AI:
> "Create a simple prototype of a notification preferences page"

### 4. Understand Connections

Ask the AI:
> "If I create a new setting in Calypso, what needs to happen in WordPress Core?"

## Getting Help

### Documentation

- Check the `docs/` folder for guides
- Read `skills/*.md` for task-specific help
- Review `dk.config.json` for configuration details

### AI Context

The AI has been given context about:
- Each repository's structure and conventions
- How the repositories connect
- Component libraries and where to find them
- Git workflows for each repo

### Common Questions

**Q: Which component library should I use?**
A: Start with `@wordpress/components` from Gutenberg. It's the standard across the ecosystem.

**Q: Do I need to understand all three repos?**
A: No! The AI will help you navigate. Focus on what you're building, and it will guide you to the right files.

**Q: How do I preview my changes?**
A: Start the dev server for the repo you're working in (see "Starting Development Servers" above).

## Next Steps

1. Read `docs/repo-map.md` to understand how the repos connect
2. Browse `skills/` for detailed guides on specific tasks
3. Start with small prototypes to get familiar with the workflow
4. Ask the AI whenever you're unsure!

---

Happy designing! 🎨
