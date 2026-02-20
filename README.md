# Design Kit (dk)

A unified workspace for designers at Automattic to work across the WordPress ecosystem with AI assistance.

## What is Design Kit?

Design Kit brings together **Calypso**, **Gutenberg**, **WordPress Core**, **Jetpack**, and **Telex** into a single workspace with AI-powered tooling that helps designers:

- **Build screens and flows** without deep technical knowledge
- **Discover and use existing components** across all repositories
- **Navigate cross-repo features** seamlessly
- **Prototype rapidly** using real components
- **Create custom Gutenberg blocks** with AI assistance via Telex

## Getting Started

### Step 1: Set Up the Environment

Open your AI-powered editor (Claude Code, Cursor, or similar) in this directory and ask:

```
Set up the Design Kit workspace. Clone all repositories, install dependencies, and get everything ready for development. Read skills/setup/SKILL.md for the full protocol.
```

The AI will handle cloning repos, installing dependencies, and configuring everything.

### Step 2: Start Building

Once setup is complete, just ask naturally:

**Understanding & Exploring:**
- "Explain how the profile settings screen works"
- "Where does the code for the user dashboard live?"
- "Show me how authentication is handled in Calypso"
- "How does the block editor save content?"

**Finding Code:**
- "Find all button components across the repos"
- "Where is the notification system implemented?"
- "Show me the code for the media library"

**Building & Updating:**
- "I want to update the profile settings screen in the new dashboard"
- "Create a new settings page with a toggle for dark mode"
- "Add a notification center to the header"
- "Build a prototype of a new onboarding flow"

**Working with Components:**
- "Show me all button variants available"
- "What form components can I use?"
- "Create a card component with an image and description"

**Git & Pull Requests:**
- "Checkout PR #12345 in Gutenberg"
- "Create a new branch for my feature"
- "Help me commit these changes with a good message"

**Development Servers:**
- "Start the Calypso dev server"
- "Show me Storybook"
- "Start Gutenberg"
- "I want to work on WordPress Core"

## What's Inside

### Repositories (under `repos/`)

- **Calypso** — WordPress.com dashboard
- **Gutenberg** — Block editor & component library
- **WordPress Core** — Core WordPress software
- **Jetpack** — Security, performance & marketing plugin
- **CIAB** — (Optional) Automattic internal admin tools
- **Telex** — (Optional) AI-powered Gutenberg block authoring tool

### Skills (under `skills/`)

All workspace knowledge lives in `skills/`. Each skill has a `SKILL.md` that any AI tool can read:

**Repository knowledge:** `calypso`, `gutenberg`, `wordpress-core`, `jetpack`, `ciab`, `telex`, `cross-repo`

**Workflows:** `setup`, `dev-servers`, `build-screen`, `find-component`, `prototype`, `git-workflow`

These skills teach the AI about the WordPress ecosystem — where code lives, how repos connect, which components exist, and how to work across projects. They're plain markdown, so they work with any AI tool: Claude Code, Cursor, Codex, or anything else that reads files.

## How It Works

1. **You describe what you want** in natural language
2. **The AI reads the relevant skill** to understand the codebase
3. **It finds existing components** before creating new ones
4. **It writes code** using the right patterns and conventions
5. **It handles git** so you can focus on design

No need to memorize terminal commands, build systems, or repo structure. The AI knows where everything lives.

## Need Help?

Just ask your AI:
- "Show me available skills"
- "How do I start a dev server?"
- "Find components that match this pattern"
- "Reset the environment"
