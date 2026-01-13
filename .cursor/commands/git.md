# Git

Help the designer manage version control across multiple repositories with minimal friction.

## Quick Reference

| Task | Command |
|------|---------|
| See status | `git status` |
| Stage all changes | `git add .` |
| Commit | `git commit -m "message"` |
| Create branch | `git checkout -b branch-name` |
| Switch branch | `git checkout branch-name` |
| Push branch | `git push -u origin branch-name` |
| Pull latest | `git pull origin trunk` |

## Repository Overview

| Repo | Default Branch | Upstream |
|------|----------------|----------|
| Calypso | `trunk` | `origin` (Automattic/wp-calypso) |
| Gutenberg | `trunk` | `origin` (WordPress/gutenberg) |
| WordPress Core | `trunk` | `origin` (WordPress/wordpress-develop) |
| CIAB | `trunk` | `origin` (Automattic/ciab-admin) |

## Branch Naming Conventions

### Calypso

```
add/feature-name       # New feature
update/feature-name    # Improvement
fix/bug-description    # Bug fix
try/experiment-name    # Experiment
```

### Gutenberg

```
add/feature-name
update/feature-name
fix/issue-number-description
```

### WordPress Core

```
feature/feature-name
fix/trac-ticket-description
```

## Common Workflows

### Starting New Work

```bash
# 1. Make sure you're on the default branch
cd repos/calypso
git checkout trunk

# 2. Pull latest changes
git pull origin trunk

# 3. Create a new branch
git checkout -b add/my-new-feature

# 4. Make your changes...

# 5. Stage and commit
git add .
git commit -m "Add: Initial implementation of my-new-feature"

# 6. Push to remote
git push -u origin add/my-new-feature
```

### Saving Work in Progress

```bash
# Quick save your work (even if not complete)
git add .
git commit -m "WIP: Progress on feature"
git push
```

### Updating Your Branch

```bash
# Get latest from trunk
git fetch origin
git rebase origin/trunk

# If there are conflicts, resolve them, then:
git add .
git rebase --continue
```

## Commit Message Format

### Structure

```
Type: Brief description (50 chars max)

Longer explanation if needed. Wrap at 72 characters.
Explain what and why, not how.

Related: #123 (if applicable)
```

### Types

| Type | When to Use |
|------|-------------|
| `Add:` | New feature or file |
| `Update:` | Improvement to existing feature |
| `Fix:` | Bug fix |
| `Remove:` | Removing code or feature |
| `Refactor:` | Code restructure (no behavior change) |
| `Docs:` | Documentation only |
| `Style:` | Formatting, CSS (no logic change) |

### Examples

```
Add: Dark mode toggle in settings

Adds a toggle switch to the display settings page that allows
users to switch between light and dark mode.

Related: #4567
```

```
Fix: Button alignment on mobile viewport

The primary action button was overflowing on screens under 480px.
Added responsive styles to wrap button text.
```

## Multi-Repo Changes

When a feature requires changes to multiple repos:

### Strategy 1: Sequential (Simpler)

```bash
# 1. Start with the dependency (usually Core/Gutenberg)
cd repos/gutenberg
git checkout -b add/new-api

# Make changes, test, commit, push...

# 2. Move to dependent repo (Calypso)
cd ../calypso
git checkout -b add/use-new-api

# Make changes that use the new API...
```

### Strategy 2: Parallel (For Related Work)

```bash
# Create branches in both repos with related names
cd repos/gutenberg
git checkout -b add/feature-x-components

cd ../calypso
git checkout -b add/feature-x-ui

# Work on both, commit separately
```

## Common Issues & Solutions

### "I made changes to the wrong branch"

```bash
# Stash your changes
git stash

# Switch to correct branch
git checkout correct-branch

# Apply stashed changes
git stash pop
```

### "I need to undo my last commit"

```bash
# Undo commit but keep changes
git reset --soft HEAD~1

# Undo commit and discard changes (careful!)
git reset --hard HEAD~1
```

### "I have merge conflicts"

```bash
# See which files have conflicts
git status

# Open conflicting file, look for:
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> branch-name

# Edit to resolve, then:
git add resolved-file.tsx
git commit -m "Resolve merge conflict"
```

### "I accidentally committed to trunk"

```bash
# Create a branch from current state
git branch my-accidental-work

# Reset trunk to remote state
git reset --hard origin/trunk

# Switch to your new branch
git checkout my-accidental-work
```

## Submodule-Specific Commands

Since dk uses git submodules:

```bash
# Update all submodules to latest
git submodule update --remote

# Pull latest in specific submodule
cd repos/calypso
git pull origin trunk

# Check submodule status from dk root
git submodule status
```

## Response Pattern

When designer needs git help:

1. **Understand the goal** - What are they trying to do?
2. **Check current state** - `git status` first
3. **Provide exact commands** - Copy-paste ready
4. **Explain briefly** - What each command does
5. **Offer to help with conflicts** - If they arise
