# Design Kit Rethink Plan

*February 12, 2026 — Prepared by Moneypenny*

## The Problem

Design Kit works well in Cursor, but the knowledge is locked in `.cursor/rules/*.mdc` and `.cursor/commands/*.md` — formats that only Cursor understands. Meanwhile, the `agent-skills` repo has universal skills covering some of the same WordPress territory. The two projects evolved independently, creating duplication and gaps.

**Goal:** Make dk-1's knowledge portable across tools (Cursor, Claude Code, OpenClaw, Codex, etc.) while eliminating duplication with agent-skills.

---

## What dk-1 Contains Today

### Cursor Rules (`.cursor/rules/*.mdc`)

| Rule | Lines | Content Type |
|------|-------|-------------|
| `base.mdc` | ~120 | AI persona + design-first behavior guidelines |
| `calypso.mdc` | ~450 | Calypso architecture, two interfaces, components, dashboard folder, routing, state, styling |
| `gutenberg.mdc` | ~280 | Gutenberg architecture, @wordpress/components, block dev, state management |
| `gutenberg-components.mdc` | ~280 | @wordpress/components development guide (file structure, stories, tests, styling) |
| `wordpress-core.mdc` | ~260 | WP Core architecture, REST API, admin pages, hooks, blocks, security |
| `jetpack.mdc` | ~300 | Jetpack monorepo, modules, blocks, REST API, packages, WP Core integration |
| `ciab.mdc` | ~180 | CIAB architecture, route system, components, state, dev commands |
| `telex.mdc` | ~320 | Telex architecture, artefact system, S3 storage, Playground, setup |
| `cross-repo.mdc` | ~200 | How repos connect, data flows, shared packages, feature flags |
| `setup.mdc` | ~280 | AI-driven setup protocol, Node version management, dependency installation |

### Cursor Commands (`.cursor/commands/*.md`)

| Command | Content |
|---------|---------|
| `build-screen.md` | Templates for creating pages in Calypso, Gutenberg, WP Admin |
| `find-component.md` | Component lookup tables across @wordpress/components and Calypso |
| `prototype.md` | Quick scaffolding templates and tips |
| `cross-repo.md` | Data flow diagrams and connection explanations |
| `setup.md` | Trigger for setup protocol |
| `start.md` | Dev server launcher |
| `git.md` | Git workflow help |

### Universal (already tool-agnostic)

| Asset | Purpose |
|-------|---------|
| `bin/*.sh` | Shell scripts for setup, start, status, reset, repos |
| `dk.config.json` | Central config for all repos |
| `docs/*.md` | Getting started, repo map, visual guides |
| `CLAUDE.md` | Claude Code guidance |
| `README.md` | User-facing overview |

---

## Overlap with Agent Skills

### Already Covered by Agent Skills

These agent-skills already contain equivalent or better knowledge:

| dk-1 Rule | Agent Skill | Notes |
|-----------|-------------|-------|
| `gutenberg.mdc` (block dev section) | `wp-block-development` | Agent skill is more comprehensive |
| `gutenberg.mdc` (state management) | `wp-interactivity-api` | Partial overlap |
| `gutenberg-components.mdc` | `wordpress-mockups` | Agent skill has extracted tokens/icons |
| `wordpress-core.mdc` (REST API) | `wp-rest-api` | Agent skill is more detailed |
| `wordpress-core.mdc` (plugin patterns) | `wp-plugin-development` | Agent skill covers more |
| `wordpress-core.mdc` (admin/hooks) | `wp-wpcli-and-ops` | Partial overlap |
| `base.mdc` (design persona) | `design-critique`, `design-atelier` | Different angle but overlapping goals |
| `prototype.md` command | `design-mockups` | Agent skill has local preview server |
| `find-component.md` command | `wordpress-mockups` | Agent skill has real component data |

### Unique to dk-1 (No Agent Skill Equivalent)

This knowledge exists *only* in dk-1:

| Content | Why It's Unique |
|---------|----------------|
| **Calypso architecture** | Legacy vs Dashboard interfaces, routing, Redux state, i18n-calypso, component locations |
| **Calypso Dashboard folder** | TanStack Query, TanStack Router, entry points, styling conventions — brand new codebase |
| **CIAB architecture** | Route auto-discovery, SPA architecture, @automattic/design-system |
| **Telex architecture** | Artefact system, S3/MinIO storage, WordPress Playground integration, CLI |
| **Jetpack monorepo** | Module system, projects structure, pnpm jetpack CLI, WP Core volume mounting |
| **Cross-repo workflows** | How data flows between repos, feature flag coordination, local linking |
| **Multi-repo setup protocol** | Node version switching, sequential dependency installation, wp-env conflict prevention |
| **dk.config.json** | Central config mapping all repos, ports, connections |
| **build-screen.md templates** | Calypso page templates (basic, settings, list), Gutenberg sidebar/inspector patterns |

---

## The Plan

### Layer 1: Universal Skills (→ agent-skills repo)

Extract dk-1 knowledge that's useful outside the dk-1 workspace into portable skills. These become available to any agent, any tool.

#### New Skills to Create

| Skill Name | Source | Content |
|------------|--------|---------|
| `wp-calypso` | `calypso.mdc` | Calypso architecture, two interfaces, components, dashboard folder, routing, state, styling, dev commands |
| `wp-ciab` | `ciab.mdc` | CIAB architecture, route system, components, state, dev commands |
| `wp-telex` | `telex.mdc` | Telex architecture, artefact system, S3 storage, setup, Playground integration |
| `wp-jetpack` | `jetpack.mdc` | Jetpack monorepo structure, modules, blocks, packages, dev workflow |
| `wp-cross-repo` | `cross-repo.mdc` + `cross-repo.md` | How WordPress ecosystem repos connect, data flows, shared packages |
| `wp-components-dev` | `gutenberg-components.mdc` | Developing @wordpress/components — file structure, stories, tests, styling conventions |

#### Skills to Enhance (already exist)

| Existing Skill | Enhancement Source |
|---------------|-------------------|
| `wordpress-mockups` | `find-component.md` component lookup tables |
| `design-mockups` | `prototype.md` quick scaffolding patterns, `build-screen.md` templates |
| `wp-block-development` | `gutenberg.mdc` block development section |
| `wp-rest-api` | `wordpress-core.mdc` endpoint patterns |

### Layer 2: dk-1 Workspace Orchestration (stays in dk-1)

What stays in dk-1 is what's *specific to the multi-repo workspace*:

| What Stays | Why |
|------------|-----|
| `bin/*.sh` scripts | Multi-repo management is dk-1's core purpose |
| `dk.config.json` | Central config specific to this workspace |
| `docs/` | Workspace-specific docs (getting started, repo map) |
| `CLAUDE.md` | Workspace-level Claude Code guidance |
| `README.md` | Workspace overview |
| `test/` | Workspace test infrastructure |

### Layer 3: Thin Cursor Wrappers (stays in dk-1, simplified)

The `.cursor/rules/*.mdc` files become thin wrappers that:
1. Set the glob pattern (which files activate the rule)
2. Provide workspace-specific context (repo paths, Node versions, dev server URLs)
3. Reference the universal skill for deep knowledge

**Example — new `calypso.mdc`:**

```
---
description: Calypso-specific development context
globs: ["repos/calypso/**/*"]
---

# Calypso in Design Kit

## Workspace Context
- **Path**: repos/calypso
- **Node**: 22 (use `source ~/.nvm/nvm.sh && nvm use`)
- **Dev server**: `./bin/start.sh calypso` → http://calypso.localhost:3000

## Architecture
[Detailed Calypso architecture knowledge lives in the wp-calypso skill]

For Calypso architecture, components, routing, and conventions,
see the wp-calypso reference in skills/ or agent-skills repo.

## dk-1 Specific
- Two interfaces: Legacy (`calypso.localhost:3000`) and Dashboard (`my.localhost:3000`)
- Always use `./bin/start.sh calypso` instead of running yarn directly
- Calypso consumes Gutenberg packages from `repos/gutenberg` via npm
```

Similarly, `.cursor/commands/*.md` become thinner — the templates and component tables move to skills, the commands just trigger the right workflow.

### Layer 4: CLAUDE.md as Universal Entry Point

The `CLAUDE.md` already works with Claude Code. Enhance it to also reference skills:

```markdown
## Skills Reference
For deep knowledge about specific repositories, consult these skills:
- Calypso: wp-calypso skill
- Gutenberg components: wp-components-dev skill
- WordPress Core: wp-plugin-development, wp-rest-api skills
- Jetpack: wp-jetpack skill
- etc.
```

This makes dk-1 work with Claude Code (reads CLAUDE.md), Cursor (reads .cursor/rules/), and OpenClaw (reads skills/) — all from the same knowledge base.

---

## Migration Order

**Phase 1: Create new skills** (no dk-1 changes yet)
1. `wp-calypso` — largest and most unique body of knowledge
2. `wp-jetpack` — second largest unique content
3. `wp-telex` — specialized, no existing equivalent
4. `wp-ciab` — specialized, no existing equivalent
5. `wp-cross-repo` — glue knowledge, valuable standalone
6. `wp-components-dev` — fills a real gap (developing components vs using them)

**Phase 2: Enhance existing skills**
1. Merge `find-component.md` tables into `wordpress-mockups`
2. Merge `prototype.md` templates into `design-mockups`
3. Merge `build-screen.md` templates into `design-mockups`

**Phase 3: Slim down dk-1 Cursor rules**
1. Replace each `.mdc` with thin wrapper referencing the skill
2. Keep workspace-specific context (paths, ports, Node versions)
3. Remove duplicated knowledge

**Phase 4: Update CLAUDE.md**
1. Add skills references
2. Keep workspace-level guidance
3. Test with Claude Code

---

## What This Achieves

| Before | After |
|--------|-------|
| Knowledge locked in Cursor `.mdc` format | Knowledge in universal SKILL.md format |
| Duplication between dk-1 and agent-skills | Single source of truth per topic |
| Only works in Cursor IDE | Works in Cursor, Claude Code, OpenClaw, any SKILL.md-aware tool |
| All knowledge in one repo | Repository knowledge → agent-skills; workspace orchestration → dk-1 |
| Can't share Calypso/CIAB/Telex knowledge independently | Each repo's knowledge is a standalone skill |

## Open Questions

1. **Skill symlinks in dk-1?** Should dk-1 have a `skills/` folder that symlinks to agent-skills, so Cursor users get the skills too? Or is CLAUDE.md reference enough?

2. **Automattic-internal repos:** Calypso, CIAB, Telex, Jetpack are all Automattic repos. Should the skills be public in agent-skills, or should there be a private skills repo for Automattic-specific knowledge?

3. **base.mdc persona:** The design-first AI persona is dk-1's identity. Does it stay as a Cursor rule only, or does it become a skill that any tool can use? (It's more "workspace personality" than "reusable knowledge.")

4. **setup.mdc protocol:** The AI-driven setup protocol is tightly coupled to dk-1's multi-repo structure. It should probably stay as a Cursor rule, but the Node version management patterns could be useful as a general skill.

5. **dk.config.json consumption:** Currently only Cursor rules read this. Should skills learn to read it too, making it the single config source for any tool?
