# Multi-Repository Git Workflows

This skill covers git operations across the WordPress ecosystem, including multi-repo branch conventions, which-repo awareness, PR workflows, and coordinating changes across repositories.

## Overview

Working with the WordPress ecosystem involves managing multiple Git repositories with different branching strategies, release cycles, and integration requirements. This skill provides patterns and workflows for effective multi-repository development.

## Repository Context and Branching

### Repository-Specific Branch Conventions

| Repository | Default Branch | Naming Convention | Release Pattern |
|------------|----------------|-------------------|-----------------|
| **dk-1** | `main` | `update/`, `add/`, `fix/`, `try/` | Rolling updates |
| **Calypso** | `trunk` | `add/`, `update/`, `fix/`, `try/` | Continuous deployment |
| **Gutenberg** | `trunk` | WordPress conventions | 2-week releases |
| **WordPress Core** | `trunk` | WordPress conventions | Major releases |
| **Jetpack** | `trunk` | Automattic conventions | Monthly releases |
| **CIAB** | `trunk` | Automattic conventions | Continuous deployment |
| **Telex** | `main` | `feature/`, `fix/`, `update/` | Sprint-based releases |

### Branch Naming Guidelines

#### dk-1 Repository (Design Kit)
```bash
# Feature additions
git checkout -b add/new-skill-name
git checkout -b add/wordpress-integration

# Updates to existing features
git checkout -b update/skills-migration
git checkout -b update/calypso-skill

# Bug fixes
git checkout -b fix/broken-script
git checkout -b fix/documentation-typos

# Experimental work
git checkout -b try/new-approach
git checkout -b try/performance-optimization
```

#### WordPress Repositories (Calypso, Gutenberg, Core, Jetpack)
```bash
# Feature additions
git checkout -b add/block-editor-feature
git checkout -b add/rest-api-endpoint

# Updates/improvements
git checkout -b update/component-styling
git checkout -b update/build-process

# Bug fixes
git checkout -b fix/navigation-bug
git checkout -b fix/security-issue

# Experimental features
git checkout -b try/new-interaction-pattern
git checkout -b try/performance-optimization
```

## Multi-Repository Workflow Patterns

### 1. Repository-Aware Development

#### Which Repository Am I In?
Always verify your context before making changes:

```bash
# Use the which-repo script
./skills/setup/scripts/which-repo.sh

# Or check manually
pwd
git remote -v
git branch --show-current
```

#### Common Mistakes to Avoid
```bash
# ❌ WRONG: Creating Telex-specific branch in dk-1
cd ~/Developer/Projects/dk-1
git checkout -b feature/telex-thinking-mode  # DON'T DO THIS!

# ✅ CORRECT: Create feature branch in the right repository
cd ~/Developer/Projects/dk-1/repos/telex
git checkout -b feature/thinking-mode

# ❌ WRONG: Using wrong branch naming convention
cd repos/gutenberg
git checkout -b update/gutenberg-new-feature  # Redundant prefix

# ✅ CORRECT: Follow repository conventions
cd repos/gutenberg  
git checkout -b add/new-feature
```

### 2. Cross-Repository Feature Development

#### Coordinated Multi-Repo Changes
When a feature spans multiple repositories:

```bash
# 1. Plan the dependency order
# WordPress Core → Gutenberg → Calypso → Jetpack

# 2. Create feature branches in each repo
cd repos/wordpress-core
git checkout -b add/new-api-endpoint

cd repos/gutenberg
git checkout -b add/api-endpoint-integration

cd repos/calypso
git checkout -b add/new-api-ui

cd repos/jetpack
git checkout -b add/api-endpoint-support

# 3. Develop in dependency order (Core first, others follow)
```

#### Feature Flag Coordination
```bash
# Enable feature flags in the right order
# 1. Core: Add feature flag support
cd repos/wordpress-core
git add wp-includes/class-wp-feature-flags.php
git commit -m "Add feature flag: new_api_endpoint"

# 2. Calypso: Check feature flag before using API
cd repos/calypso
# Add feature flag checks in API calls
git commit -m "Add feature flag support for new API endpoint"

# 3. Coordinate release timing across repositories
```

### 3. Branch Lifecycle Management

#### Creating Feature Branches
```bash
# Start from the latest default branch
cd repos/calypso
git checkout trunk
git pull origin trunk
git checkout -b add/new-dashboard-widget

# Work on feature
git add .
git commit -m "Add new dashboard widget component"
git commit -m "Add widget configuration panel" 
git commit -m "Add widget unit tests"

# Keep feature branch updated
git checkout trunk
git pull origin trunk
git checkout add/new-dashboard-widget
git rebase trunk  # or git merge trunk
```

#### Preparing for Review
```bash
# Clean up commit history before PR
git rebase -i trunk

# Interactive rebase options:
# - squash related commits
# - fix commit messages
# - reorder commits logically

# Example cleanup:
pick abc123 Add new dashboard widget component
squash def456 Fix typo in widget component
squash ghi789 Update widget styling
pick jkl012 Add widget configuration panel
pick mno345 Add widget unit tests

# Result: 3 clean commits instead of 5 messy ones
```

#### Push and PR Creation
```bash
# Push feature branch
git push origin add/new-dashboard-widget

# Create PR (varies by platform)
# GitHub: Use web interface or gh CLI
gh pr create --title "Add new dashboard widget" \
  --body "Implements new dashboard widget with configuration panel"

# Include cross-repo context in PR description
```

## Advanced Git Workflows

### 1. Hotfix Workflows

#### Critical Bug in Production
```bash
# For repositories with release branches
cd repos/jetpack
git checkout trunk
git pull origin trunk
git checkout -b fix/critical-security-bug

# Make minimal fix
git commit -m "Fix critical security vulnerability in module X"

# Push and create urgent PR
git push origin fix/critical-security-bug

# After review and merge, may need to backport to release branches
```

#### Emergency Fixes Across Multiple Repos
```bash
# Scenario: API change in Core breaks Calypso

# 1. Fix Core issue first
cd repos/wordpress-core
git checkout -b fix/api-breaking-change
# Fix the API issue
git commit -m "Fix API response format breaking change"

# 2. Update Calypso to handle both old and new formats
cd repos/calypso
git checkout -b fix/api-compatibility
# Add backward compatibility
git commit -m "Add backward compatibility for Core API changes"

# 3. Coordinate deployment
# Deploy Core fix first, then Calypso update
```

### 2. Release Management

#### Preparing Release Branches
```bash
# For repositories that use release branches
cd repos/jetpack
git checkout trunk
git pull origin trunk

# Create release branch
git checkout -b release/10.5
git push origin release/10.5

# Cherry-pick specific commits for release
git cherry-pick abc123  # Bug fix
git cherry-pick def456  # Feature completion
# Skip xyz789 (not ready for release)

# Tag release
git tag -a v10.5.0 -m "Jetpack 10.5.0 Release"
git push origin v10.5.0
```

#### Coordinated Releases
```bash
# Release sequence for ecosystem updates
# 1. WordPress Core (if needed)
# 2. Gutenberg (syncs to Core)
# 3. Jetpack (uses Core APIs)
# 4. Calypso (uses Jetpack and Core APIs)

# Example coordination script
#!/bin/bash
echo "Starting coordinated release..."

# Check all repos are ready
cd repos/wordpress-core && git status --porcelain
cd repos/gutenberg && git status --porcelain
cd repos/jetpack && git status --porcelain  
cd repos/calypso && git status --porcelain

echo "All repositories are clean ✅"
echo "Proceed with release sequence..."
```

### 3. Conflict Resolution

#### Merge Conflicts in Multi-Repo Changes
```bash
# When rebasing feature branch on updated trunk
git checkout add/cross-repo-feature
git rebase trunk

# Conflict resolution process
git status  # Shows conflicted files
# Edit conflicted files, resolve markers
git add resolved-file.js
git rebase --continue

# If conflicts are complex, consider merge instead
git rebase --abort
git merge trunk  # Creates merge commit but preserves history
```

#### Cross-Repository Conflicts
```bash
# Scenario: Two developers working on related features in different repos

# Developer A: Changes Core API (repos/wordpress-core)
# Developer B: Uses old API format (repos/calypso)

# Resolution approach:
# 1. Communication first - coordinate the changes
# 2. Update dependent repositories after upstream changes
# 3. Use feature flags to enable gradual rollout
```

## Repository Management Scripts

### 1. Multi-Repo Status Check
```bash
#!/bin/bash
# check-all-repos.sh - Check status of all repositories

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

repos=("calypso" "gutenberg" "wordpress-core" "jetpack" "ciab" "telex")

echo "🔍 Multi-Repository Status"
echo "=========================="

for repo in "${repos[@]}"; do
    if [ -d "repos/$repo" ]; then
        echo ""
        echo "=== $repo ==="
        cd "repos/$repo"
        
        # Branch info
        branch=$(git branch --show-current 2>/dev/null || echo "detached")
        echo "Branch: $branch"
        
        # Status info
        status=$(git status --porcelain 2>/dev/null)
        if [ -z "$status" ]; then
            echo "Status: Clean ✅"
        else
            echo "Status: $(echo "$status" | wc -l | tr -d ' ') changes ⚠️"
            echo "$status" | head -3
        fi
        
        # Remote sync status
        if git remote get-url origin > /dev/null 2>&1; then
            git fetch origin 2>/dev/null
            ahead=$(git rev-list --count HEAD ^origin/$branch 2>/dev/null || echo "0")
            behind=$(git rev-list --count origin/$branch ^HEAD 2>/dev/null || echo "0")
            
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
                echo "Sync: ↑$ahead ↓$behind"
            else
                echo "Sync: Up to date ✅"
            fi
        fi
        
        cd "$DK_ROOT"
    else
        echo ""
        echo "=== $repo ==="
        echo "Status: Not cloned ❌"
    fi
done
```

### 2. Synchronized Branch Operations
```bash
#!/bin/bash
# sync-branches.sh - Create same branch across multiple repos

BRANCH_NAME=$1
if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <branch-name>"
    exit 1
fi

DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DK_ROOT"

repos=("calypso" "gutenberg" "wordpress-core" "jetpack")

echo "Creating branch '$BRANCH_NAME' in all repositories..."

for repo in "${repos[@]}"; do
    if [ -d "repos/$repo" ]; then
        echo ""
        echo "=== $repo ==="
        cd "repos/$repo"
        
        # Check if branch already exists
        if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
            echo "Branch already exists ⚠️"
        else
            # Ensure we're on default branch and up to date
            default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
            git checkout $default_branch
            git pull origin $default_branch
            
            # Create new branch
            git checkout -b $BRANCH_NAME
            echo "Branch created ✅"
        fi
        
        cd "$DK_ROOT"
    fi
done

echo ""
echo "Branch creation complete!"
echo "Use './skills/setup/scripts/status.sh' to check status"
```

### 3. Cross-Repo Pull Request Helper
```bash
#!/bin/bash
# create-cross-repo-pr.sh - Helper for creating related PRs

FEATURE_NAME=$1
if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature-name>"
    echo "Example: $0 new-block-editor-feature"
    exit 1
fi

echo "Creating cross-repository PRs for: $FEATURE_NAME"
echo ""

# Template for PR description
PR_TEMPLATE="## Cross-Repository Feature: $FEATURE_NAME

This PR is part of a multi-repository feature implementation.

### Related PRs:
- WordPress Core: [PR Link]
- Gutenberg: [PR Link]  
- Calypso: [PR Link]
- Jetpack: [PR Link]

### Testing:
1. Ensure all related PRs are merged in dependency order
2. Test integration across repositories
3. Verify feature flags are properly coordinated

### Deployment Notes:
- Deploy WordPress Core changes first
- Then deploy Gutenberg/Jetpack changes
- Finally deploy Calypso changes
"

echo "PR Description template:"
echo "------------------------"
echo "$PR_TEMPLATE"
echo ""
echo "Copy this template when creating PRs in each repository"
echo "Update the Related PRs section with actual PR links"
```

## Git Configuration for Multi-Repo Work

### 1. Useful Git Aliases
```bash
# Add to ~/.gitconfig
[alias]
    # Quick status across repos
    st = status --short --branch
    
    # Better log display
    lg = log --oneline --decorate --graph --all -10
    
    # Quick commit with message
    cm = commit -m
    
    # Push current branch to origin
    push-current = !git push -u origin $(git branch --show-current)
    
    # Sync with remote
    sync = !git fetch origin && git rebase origin/$(git branch --show-current)
    
    # Clean merged branches
    clean-merged = !git branch --merged | grep -v '\\*\\|main\\|trunk' | xargs -n 1 git branch -d
```

### 2. Git Hooks for Multi-Repo Work
```bash
#!/bin/sh
# .git/hooks/pre-commit - Verify repository context

# Get current directory
CURRENT_DIR=$(pwd)

# Check if we're in the right repository for the branch name
BRANCH_NAME=$(git branch --show-current)

case "$BRANCH_NAME" in
    *telex*)
        if [[ "$CURRENT_DIR" != *"/telex"* ]]; then
            echo "❌ Branch name suggests Telex work, but you're not in the Telex repository"
            echo "Current directory: $CURRENT_DIR"
            echo "Current branch: $BRANCH_NAME"
            exit 1
        fi
        ;;
    *calypso*)
        if [[ "$CURRENT_DIR" != *"/calypso"* ]]; then
            echo "❌ Branch name suggests Calypso work, but you're not in the Calypso repository"
            exit 1
        fi
        ;;
esac

echo "✅ Repository context verified"
```

## Best Practices for Multi-Repo Git

### 1. Commit Message Conventions
```bash
# Good commit messages with repository context
git commit -m "Add new dashboard widget component

- Implements configurable widget system
- Adds unit tests and Storybook stories  
- Updates TypeScript definitions
- Related to Calypso dashboard redesign"

# Cross-repository commit references
git commit -m "Update API client for new Core endpoints

- Adapts to new REST API format from WordPress/wordpress-develop#1234
- Maintains backward compatibility with older Core versions
- Adds feature flag support"
```

### 2. PR Review Process
```markdown
# PR Review Checklist for Cross-Repo Features

## Code Review
- [ ] Code follows repository conventions
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Breaking changes are documented

## Cross-Repo Impact
- [ ] Dependencies are clearly identified
- [ ] Integration points are tested
- [ ] Feature flags are properly implemented
- [ ] Deployment order is documented

## Integration Testing
- [ ] Local multi-repo testing completed
- [ ] Staging environment testing passed
- [ ] Cross-browser compatibility verified
- [ ] Mobile responsiveness checked
```

### 3. Emergency Response Procedures
```bash
# Emergency rollback across multiple repositories
#!/bin/bash
# emergency-rollback.sh

echo "🚨 Emergency rollback procedure"
echo "This will revert the last deployment across all repositories"

read -p "Are you sure? This will affect production. (type 'EMERGENCY' to continue): " confirm
if [ "$confirm" != "EMERGENCY" ]; then
    echo "Rollback cancelled"
    exit 1
fi

# Rollback sequence (reverse of deployment order)
echo "Rolling back Calypso..."
cd repos/calypso && git checkout production && git reset --hard HEAD~1

echo "Rolling back Jetpack..."  
cd repos/jetpack && git checkout release && git reset --hard HEAD~1

echo "Rolling back WordPress Core..."
cd repos/wordpress-core && git checkout stable && git reset --hard HEAD~1

echo "🚨 Emergency rollback complete"
echo "Notify team and investigate issue"
```

This multi-repository Git workflow ensures coordinated development across the WordPress ecosystem while maintaining repository-specific conventions and avoiding common pitfalls.