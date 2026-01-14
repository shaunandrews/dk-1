# Getting Started with Design Kit

Welcome to the Design Kit (dk)! This guide will help you set up your environment and start designing across the WordPress ecosystem.

## What is Design Kit?

Design Kit is a unified workspace that brings together:

- **Calypso** - WordPress.com's dashboard
- **Gutenberg** - The WordPress Block Editor
- **WordPress Core** - The foundation software
- **Jetpack** - Security, performance, and marketing tools

Instead of managing these repositories separately, dk lets you work across all of them with AI assistance that understands how everything connects.

## Prerequisites

Before you begin, make sure you have:

- **Git** - Version control
- **Node.js** (v18+) - JavaScript runtime
- **Yarn** - Package manager for Calypso
- **npm** - Package manager for Gutenberg/Core
- **pnpm** - Package manager for CIAB/Jetpack
- **Composer** - PHP package manager for Jetpack
- **Cursor** - AI-powered editor (recommended)

### Optional (for WordPress Core / CIAB / Jetpack development)

- **Docker Desktop** - Required to run local WordPress environments
  - [Download for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
  - [Download for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
  - [Download for Linux](https://docs.docker.com/desktop/setup/install/linux/)

Note: Calypso, Gutenberg, and Storybook work without Docker.

## Initial Setup (AI-Driven)

### The Simple Way

1. **Clone the repository** (or just provide the repo URL to your AI assistant in Cursor)
2. **Open in Cursor**: `cursor .` or just open the folder
3. **Tell the AI to set things up** - use one of these methods:

#### Option A: Use the Setup Command
Type `/setup` in the chat and the AI will run the full setup process.

#### Option B: Just Ask
Tell the AI in natural language:
- "Set up the environment"
- "Initialize everything"
- "Install dependencies"
- "Get this project ready"

The AI will:
- Check for required tools (git, node, yarn, npm, pnpm, composer)
- Clone all repositories (Calypso, Gutenberg, WordPress Core, Jetpack)
- Install dependencies for each repository
- Take about 5-10 minutes depending on your connection
- Keep you updated on progress
- Confirm when everything is ready

Note: CIAB is optional and requires Automattic access. It will be skipped if you don't have access.

**You never need to open a terminal or run commands manually - just tell the AI what you need.**

### What the AI Does During Setup

When you ask the AI to set up the project, it will:
1. Read `README.md` to understand the project
2. Check for required tools (git, node, yarn, npm, pnpm, composer)
3. Clone all repositories using `bin/repos.sh`
4. Install dependencies for all repositories
5. Verify everything is set up correctly
6. Tell you when it's done and what you can do next

## Managing Your Environment

Just tell the AI what you want - it will handle everything:

| What You Want | Say This |
|---------------|----------|
| Initial setup | "Set up the env" or just open the project |
| Pull latest code | "Reset everything" or "pull latest" |
| Full clean install | "Full reset" or "clean install" |
| Check repo status | "Show status" or "what's the state" |
| Start a dev server | "Start Calypso" or "I want to work on Gutenberg" |

The AI will execute all commands automatically. You never need to run terminal commands yourself.

## Quick Tour

### Directory Structure

```
dk/
├── .cursor/rules/       # AI context and behavior
├── .cursor/commands/    # Slash commands for tasks
├── repos/               # The actual codebases
│   ├── calypso/         # WordPress.com dashboard
│   ├── gutenberg/       # Block editor
│   ├── wordpress-core/  # Core software
│   └── jetpack/         # Security & performance plugin
├── docs/                # Documentation
└── dk.config.json       # Central configuration
```

### Key Files

| File | Purpose |
|------|---------|
| `dk.config.json` | Maps repositories, paths, and connections |
| `.cursor/rules/base.mdc` | Core AI behavior |
| `.cursor/commands/*.md` | Slash commands for specific tasks |

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

Just tell the AI what you want to work on, and it will start the server for you.

### Using the Start Command

Type `/start` in the chat to see all available servers and start one.

### Or Just Ask

Tell the AI what you want in natural language:

**"I want to work on Calypso"** or **"Start Calypso"**
- AI starts Calypso dev server
- URL: http://calypso.localhost:3000
- You're ready to work!

**"Start Gutenberg"**
- AI starts Gutenberg dev server  
- AI opens http://localhost:9999 in your browser

**"Show me Storybook"**
- AI starts Storybook
- AI opens http://localhost:50240 in your browser

**"I need WordPress Core running"**
- AI starts WP Core dev server
- AI opens http://localhost:8889 in your browser

**"Start CIAB"**
- AI starts CIAB dev server and WordPress environment
- AI opens http://localhost:9001/wp-admin/ in your browser

**"Start Jetpack"**
- AI starts WordPress Core with Jetpack plugin
- AI opens http://localhost:8889/wp-admin/plugins.php in your browser
- You can activate and develop Jetpack features

The AI handles all the terminal commands, directory navigation, and browser opening. You just tell it what you want to work on.

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
- Use `/` commands in chat for task-specific help
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
2. Try `/prototype` to quickly scaffold an idea
3. Use `/find-component` when looking for existing UI components
4. Ask the AI whenever you're unsure!

---

Happy designing! 🎨
