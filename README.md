# Design Kit (dk)

A unified workspace for designers at Automattic to work across the WordPress ecosystem with AI assistance.

## What is Design Kit?

Design Kit brings together **Calypso**, **Gutenberg**, **WordPress Core**, and **Jetpack** into a single workspace with AI-powered tooling that helps designers:

- **Build screens and flows** without deep technical knowledge
- **Discover and use existing components** across all repositories
- **Navigate cross-repo features** seamlessly
- **Prototype rapidly** using real components

## Getting Started

### Step 1: Ask Your AI to Set It Up

Open Cursor (or your AI-powered editor) and use this prompt:

```
Clone https://github.com/shaunandrews/dk-1 and set up the Design Kit workspace. Clone all repositories, install dependencies, and get everything ready for development. Follow the setup protocol in .cursor/rules/setup.mdc.
```

That's it! The AI will handle everything—no terminal commands needed.

### Step 2: Start Building

Once setup is complete, just ask naturally. Here are examples of what you can ask:

**Understanding & Exploring:**
- "Explain how the profile settings screen works"
- "Where does the code for the user dashboard live?"
- "Show me how authentication is handled in Calypso"
- "How does the block editor save content?"
- "Where is the settings API defined in WordPress Core?"
- "Explain the component structure in Gutenberg"

**Finding Code:**
- "Find all button components across the repos"
- "Where is the notification system implemented?"
- "Show me the code for the media library"
- "Find where user preferences are stored"
- "Locate the API endpoints for site settings"

**Building & Updating:**
- "I want to update the profile settings screen in the new dashboard"
- "Create a new settings page with a toggle for dark mode"
- "Add a notification center to the header"
- "Build a prototype of a new onboarding flow"
- "Update the color scheme in the theme customizer"
- "I want to make a new plugin for WordPress"

**Working with Components:**
- "Show me all button variants available"
- "What form components can I use?"
- "Create a card component with an image and description"
- "Find components that match this design pattern"
- "What's the best component for a data table?"

**Git & Pull Requests:**
- "Checkout PR #12345 in Gutenberg"
- "Show me the changes in Calypso PR #9876"
- "Create a new branch for my feature"
- "What files changed in the latest commit?"
- "Help me commit these changes with a good message"

**Development Servers:**
- "Start the Calypso dev server"
- "Show me Storybook"
- "Start Gutenberg"
- "I want to work on WordPress Core"
- "Run Jetpack locally"

**Cross-Repo Work:**
- "How does Calypso communicate with WordPress Core?"
- "Where is the REST API endpoint for posts defined?"
- "Show me how to add a new block that works in both Gutenberg and Calypso"
- "Explain the data flow between repositories"

## What's Inside

- **Calypso** - WordPress.com dashboard
- **Gutenberg** - Block editor & component library
- **WordPress Core** - Core WordPress software
- **Jetpack** - Security, performance & marketing plugin
- **CIAB** - (Optional) Automattic internal admin tools

All repositories are managed automatically. The AI knows where everything lives and how to work across them.

## Need Help?

Just ask your AI:
- "Show me available commands"
- "How do I start a dev server?"
- "Find components that match this pattern"
- "Reset the environment"

The AI has full context about this workspace and can guide you through any task.
