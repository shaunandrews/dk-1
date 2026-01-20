# Git

Help the designer manage version control across multiple repositories with minimal friction.

## ⚠️ CRITICAL: Know Which Repository You're In

**This workspace contains multiple Git repositories. Always verify which repo you're working in before creating branches or committing changes.**

### The Two Types of Repositories

1. **dk-1 (Main Repository)** - The Design Kit configuration repository
   - Location: Root directory (`/Users/shaun/Developer/Projects/dk-1`)
   - Contains: `.cursor/rules/`, `bin/`, `docs/`, `dk.config.json`
   - Default branch: `main`
   - Branch naming: `update/feature-name`, `add/feature-name`, `fix/issue-name`
   - **NEVER use sub-repo names in branch names** (e.g., ❌ `feature/telex-thinking-mode`)

2. **Sub-Repositories** - The actual code repositories
   - Location: `repos/calypso`, `repos/gutenberg`, `repos/telex`, etc.
   - Contains: Application code, components, features
   - Default branches: `trunk` (most) or `main` (telex)
   - Branch naming: Follow each repo's conventions (see below)

### Helper Commands

```bash
# Check which repository you're currently in
./bin/which-repo.sh

# See status of all repositories
./bin/repos.sh status
```

### Common Mistake: Branch Name Confusion

❌ **WRONG**: Creating `feature/telex-thinking-mode` in dk-1 when you meant to work on Telex code
✅ **CORRECT**: 
- For Telex code: `cd repos/telex && git checkout -b feature/thinking-mode`
- For dk-1 rules about Telex: `cd . && git checkout -b update/telex-rules`

**Rule of thumb**: If your branch name contains a repo name (calypso, gutenberg, telex, etc.), you're probably in the wrong repository!

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

### dk-1 (Main Configuration Repository)

| Aspect | Details |
|--------|---------|
| Default Branch | `main` |
| Branch Naming | `update/feature-name`, `add/feature-name`, `fix/issue-name` |
| Purpose | Configuration, rules, documentation, scripts |
| **Never use sub-repo names in branch names** | ❌ `feature/telex-*`, ❌ `add/calypso-*` |

### Sub-Repositories

| Repo | Default Branch | Upstream | Location |
|------|----------------|----------|----------|
| Calypso | `trunk` | `origin` (Automattic/wp-calypso) | `repos/calypso` |
| Gutenberg | `trunk` | `origin` (WordPress/gutenberg) | `repos/gutenberg` |
| WordPress Core | `trunk` | `origin` (WordPress/wordpress-develop) | `repos/wordpress-core` |
| Jetpack | `trunk` | `origin` (Automattic/jetpack) | `repos/jetpack` |
| CIAB | `trunk` | `origin` (Automattic/ciab-admin) | `repos/ciab` |
| Telex | `main` | `origin` (Automattic/w0-block-authoring) | `repos/telex` |

## Branch Naming Conventions

### dk-1 (Main Repository)

**For dk-1 configuration, rules, and documentation changes:**

```
update/feature-name       # Update existing feature/config
add/feature-name          # Add new feature/config
fix/issue-name           # Fix bug in dk-1 itself
```

**Examples:**
- ✅ `update/telex-rules` - Update Telex rules in dk-1
- ✅ `add/gutenberg-context` - Add Gutenberg context to dk-1
- ✅ `fix/vscode-settings` - Fix VS Code settings in dk-1
- ❌ `feature/telex-thinking-mode` - Too confusing (sounds like Telex code)
- ❌ `add/calypso-component` - Should be in `repos/calypso` instead

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

### Telex

```
feature/feature-name
fix/bug-description
```

**Note**: Telex uses `main` as default branch (not `trunk`)

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

### "I created a branch in the wrong repository"

```bash
# If you created a branch in dk-1 but meant to work in a sub-repo:

# 1. Stash or commit your changes in dk-1
cd /Users/shaun/Developer/Projects/dk-1
git stash  # or git commit

# 2. Switch to the correct sub-repo
cd repos/telex  # (or calypso, gutenberg, etc.)

# 3. Create the branch there
git checkout -b feature/correct-branch-name

# 4. If you had changes, you may need to manually move them
# (they're in dk-1, so you'll need to copy files or redo the work)
```

### "I'm not sure which repository I'm in"

```bash
# Use the helper script
./bin/which-repo.sh

# Or check manually
pwd
git remote -v
```

## Browsing Code on GitHub

For public repos, you can view code without checking out branches by constructing GitHub URLs:

### URL Pattern

```
https://github.com/{owner}/{repo}/blob/{branch}/{path}
```

### Repository URLs

| Repo | GitHub URL |
|------|------------|
| Calypso | `https://github.com/Automattic/wp-calypso/blob/{branch}/{path}` |
| Gutenberg | `https://github.com/WordPress/gutenberg/blob/{branch}/{path}` |
| WordPress Core | `https://github.com/WordPress/wordpress-develop/blob/{branch}/{path}` |

### Examples

```bash
# View a file on a specific branch
https://github.com/Automattic/wp-calypso/blob/add/developer-mode-toggle/client/dashboard/me/developer-mode/index.tsx

# View file at a specific commit
https://github.com/Automattic/wp-calypso/blob/abc1234/client/dashboard/me/profile/index.tsx

# View a PR's changes
https://github.com/Automattic/wp-calypso/pull/12345/files
```

### When to Use

- **Viewing code on remote branches** without checking them out locally
- **Referencing existing implementations** for patterns to follow
- **Reviewing PRs** to understand what changes were made

## Repository Management Commands

Since dk uses cloned repositories (not submodules):

```bash
# Update all repositories to latest
./bin/repos.sh update

# Check repository status
./bin/repos.sh status

# Clone CIAB (Automattic only)
./bin/repos.sh clone-ciab

# Pull latest in specific repository
cd repos/calypso
git pull origin trunk
```

## Response Pattern

When designer needs git help:

1. **Understand the goal** - What are they trying to do?
2. **Check current state** - `git status` first
3. **Provide exact commands** - Copy-paste ready
4. **Explain briefly** - What each command does
5. **Offer to help with conflicts** - If they arise
