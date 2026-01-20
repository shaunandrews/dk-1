# Design Kit Skills

This directory contains Claude Code skills for working with the Design Kit workspace. These skills provide reusable workflows adapted from the Cursor commands in `.cursor/commands/`.

## Available Skills

### Core Workflow Skills

- **`find-component`** - Find existing UI components from `@wordpress/components` or Calypso before creating new ones
- **`start-server`** - Start development servers with proper environment checks and Node version management
- **`check-repo-context`** - Verify which Git repository you're in before branching/committing (critical for multi-repo workspace)
- **`cross-repo-workflow`** - Understand features that span multiple repositories and identify which repos need changes
- **`setup-environment`** - Set up the Design Kit workspace by cloning repos and installing dependencies

## How to Use Skills

In Claude Code, skills are invoked using the `Skill` tool:

```
Skill: find-component
```

Skills can also be invoked automatically when Claude detects relevant tasks. For example, if you mention wanting to add a button, Claude may automatically invoke `dk:find-component` to suggest existing components.

## Skill vs Cursor Command

**Cursor Commands** (`.cursor/commands/`) are slash commands like `/find-component` that users invoke directly in Cursor IDE.

**Claude Skills** (`.claude/skills/`) are AI-driven workflows that Claude Code can invoke programmatically to handle complex multi-step tasks.

Think of skills as "the AI's internal procedures" while commands are "user-facing shortcuts."

## Creating New Skills

Skills use YAML frontmatter with markdown content:

```markdown
---
name: skill-name
description: Brief description of what this skill does
---

# Skill Title

Content explaining the workflow...

## Execution Steps

Step-by-step instructions for Claude to follow...
```

### Skill Naming Convention

Skills are simple, descriptive names without prefixes (since they're already in the Design Kit context):
- ✅ `find-component`
- ✅ `start-server`
- ✅ `check-repo-context`

## Sharing Skills

These skills are version controlled in the dk-1 repository, so any improvements benefit the whole team. When you update a skill:

1. Test it with Claude Code
2. Commit the changes to git
3. Share context about what improved

## Related Documentation

- **Cursor Rules**: `.cursor/rules/` - AI behavior and context for Cursor IDE
- **Cursor Commands**: `.cursor/commands/` - User-invokable slash commands
- **CLAUDE.md**: Root-level AI guidance for this repository
- **dk.config.json**: Repository configuration and metadata
