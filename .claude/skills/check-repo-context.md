---
name: check-repo-context
description: Verify which repository you're working in before creating branches or making commits (critical for multi-repo workspace)
---

# Design Kit: Check Repository Context

This skill helps you verify which Git repository you're currently working in before making changes. This is CRITICAL because Design Kit contains multiple independent Git repositories.

## The Problem

Design Kit has a **two-tier Git structure**:

1. **dk-1** (meta-repository) - Contains config, rules, scripts, docs
2. **Sub-repositories** (`repos/*`) - Each has its own .git, branches, remotes

**Common mistake**: Creating `feature/telex-thinking-mode` in dk-1 when you meant to work on Telex code.

## When to Use This Skill

Invoke this skill BEFORE:
- Creating a new branch
- Making commits
- Creating pull requests
- Any git operations

ESPECIALLY when:
- User mentions a specific repo name (calypso, gutenberg, telex, etc.)
- Working on code changes that will affect a specific project
- User says "create a branch for..."

## Execution Steps

### Step 1: Run the Helper Script

```bash
Bash: ./bin/which-repo.sh
```

This script outputs:
- Which repository you're in (dk-1 or a sub-repo)
- Current branch name
- Git status
- Appropriate commands for that repo

### Step 2: Analyze User Intent

Ask yourself:

**Is the user working on:**
- ✅ **Sub-repo code** (React components, blocks, features) → Should be in `repos/[name]/`
- ✅ **dk-1 meta** (cursor rules, setup scripts, documentation) → Should be in root

**Red flags** indicating wrong repository:
- Branch name contains a repo name (e.g., `feature/telex-*` in dk-1)
- User says "work on Calypso" but you're in dk-1
- Code changes in `repos/` but working in dk-1

### Step 3: Navigate to Correct Repository

If in wrong repo, navigate:

```bash
# To work on sub-repo code
Bash: cd repos/[repo-name]

# To work on dk-1 meta
Bash: cd /Users/shaun/Developer/Projects/dk-1
```

Then verify again with `./bin/which-repo.sh`

### Step 4: Verify Branch Naming Convention

Check that branch name matches the repository:

**For dk-1 (meta-repository):**
- ✅ `update/telex-rules` (updating rules ABOUT Telex)
- ✅ `add/jetpack-docs` (adding docs ABOUT Jetpack)
- ✅ `fix/setup-script` (fixing the setup script)
- ❌ `feature/telex-thinking-mode` (this is Telex CODE, not dk-1 meta)
- ❌ `add/calypso-settings-page` (this is Calypso CODE, not dk-1 meta)

**Rule of thumb**: If the branch name contains a repo name, you're probably in the wrong repository!

**For sub-repositories:**
- Follow each repo's conventions (usually `feature/`, `fix/`, `update/`)
- Branch name describes the CHANGE, not the repo (repo is implicit)
- ✅ `feature/thinking-mode` in repos/telex
- ✅ `fix/settings-page` in repos/calypso

### Step 5: Report to User

Inform the user clearly:

**If in correct repo:**
```
✅ You're in the correct repository: [repo-name]
Current branch: [branch]

Ready to proceed with [action].
```

**If in wrong repo:**
```
⚠️ Repository context check:

You're currently in: [current-repo]
But you want to work on: [target-repo]

Let me switch to the correct repository...
[Navigate to correct repo]

✅ Now in [target-repo]. Ready to proceed.
```

## Common Scenarios

### Scenario 1: Creating a Telex Feature

**User says**: "Create a branch for the new Telex thinking mode feature"

**Your action**:
1. Run `./bin/which-repo.sh`
2. Check current location
3. If in dk-1: `cd repos/telex`
4. Create branch: `git checkout -b feature/thinking-mode`
5. Verify: `./bin/which-repo.sh` again

### Scenario 2: Updating Cursor Rules

**User says**: "Update the Telex rules to include the new feature"

**Your action**:
1. Run `./bin/which-repo.sh`
2. Should be in dk-1 (root)
3. Create branch: `git checkout -b update/telex-rules`
4. Make changes to `.cursor/rules/telex.mdc`

### Scenario 3: User Provides File Path

**User says**: "Make changes to repos/calypso/client/dashboard/settings.tsx"

**Your action**:
1. File is in Calypso repo
2. Navigate: `cd repos/calypso`
3. Verify: `./bin/which-repo.sh`
4. Create branch in Calypso: `git checkout -b update/dashboard-settings`

## Repository Quick Reference

| Repository | Location | Default Branch | Purpose |
|------------|----------|----------------|---------|
| dk-1 | Root | `main` | Meta-config, rules, scripts, docs |
| Calypso | `repos/calypso` | `trunk` | WordPress.com dashboard code |
| Gutenberg | `repos/gutenberg` | `trunk` | Block editor & components code |
| WordPress Core | `repos/wordpress-core` | `trunk` | WordPress core software |
| Jetpack | `repos/jetpack` | `trunk` | Jetpack plugin code |
| CIAB | `repos/ciab` | `trunk` | Commerce admin code |
| Telex | `repos/telex` | `main` | Block authoring tool code |

## Status Check Commands

```bash
# Check current repo context
./bin/which-repo.sh

# Check status of ALL repos
./bin/repos.sh status

# Check detailed status
./bin/status.sh
```

## Error Prevention Checklist

Before ANY git operation, ask:

1. ✅ Am I in the right repository? (run `./bin/which-repo.sh`)
2. ✅ Does the branch name make sense for THIS repo?
3. ✅ Are the files I'm changing in THIS repo's directory?
4. ✅ Does the commit message match THIS repo's changes?

If ANY answer is uncertain, STOP and verify repository context.
