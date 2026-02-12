# Design Kit Rethink Plan

*February 12, 2026 — Prepared by Moneypenny*
*v3 — Skills all the way down. No Cursor rules.*

## The Problem

Design Kit has valuable WordPress ecosystem knowledge locked in Cursor-specific formats (`.cursor/rules/*.mdc`, `.cursor/commands/*.md`). The knowledge is portable — the format isn't.

**Goal:** Restructure dk-1 as a pure skills-based design kit. No tool-specific formats. Works with Cursor, Claude Code, OpenClaw, Codex, or anything that can read a SKILL.md.

---

## The New Structure

Everything is a skill. Shell scripts live inside the skills that use them. The top level is clean.

```
dk-1/
├── skills/
│   │
│   │── calypso/
│   │   └── SKILL.md              # Calypso architecture, two interfaces, components,
│   │                              # dashboard folder, routing, state, styling, dev commands
│   │
│   ├── gutenberg/
│   │   └── SKILL.md              # Gutenberg, @wordpress/components, block dev,
│   │                              # component development (stories, tests, styling)
│   │
│   ├── wordpress-core/
│   │   └── SKILL.md              # WP Core architecture, REST API, admin pages,
│   │                              # hooks, blocks, security
│   │
│   ├── jetpack/
│   │   └── SKILL.md              # Jetpack monorepo, modules, blocks, packages,
│   │                              # WP Core integration
│   │
│   ├── ciab/
│   │   └── SKILL.md              # CIAB admin SPA, route system, components, state
│   │
│   ├── telex/
│   │   └── SKILL.md              # Telex block authoring, artefact system, S3,
│   │                              # WordPress Playground
│   │
│   ├── cross-repo/
│   │   └── SKILL.md              # How repos connect, data flows, shared packages,
│   │                              # feature flags, coordinating changes
│   │
│   ├── setup/
│   │   ├── SKILL.md              # Setup protocol, prerequisites, Node version mgmt
│   │   └── scripts/
│   │       ├── setup.sh          # ← from bin/setup.sh
│   │       ├── repos.sh          # ← from bin/repos.sh
│   │       ├── reset.sh          # ← from bin/reset.sh
│   │       ├── status.sh         # ← from bin/status.sh
│   │       └── which-repo.sh     # ← from bin/which-repo.sh
│   │
│   ├── dev-servers/
│   │   ├── SKILL.md              # Starting/stopping dev servers, ports, URLs
│   │   └── scripts/
│   │       └── start.sh          # ← from bin/start.sh
│   │
│   ├── build-screen/
│   │   └── SKILL.md              # Screen templates: Calypso pages, Gutenberg
│   │                              # sidebars, WP Admin pages
│   │
│   ├── find-component/
│   │   └── SKILL.md              # Component lookup across @wordpress/components,
│   │                              # Calypso, CIAB. Tables, examples, Storybook refs
│   │
│   ├── prototype/
│   │   └── SKILL.md              # Quick scaffolding, Storybook prototyping,
│   │                              # templates for common patterns
│   │
│   ├── git-workflow/
│   │   └── SKILL.md              # Multi-repo git: branch conventions, which-repo
│   │                              # awareness, PR workflows, cross-repo changes
│   │
│   ├── design-mockups/           # ← from agent-skills
│   │   ├── SKILL.md
│   │   └── scripts/
│   │
│   ├── wordpress-mockups/        # ← from agent-skills
│   │   ├── SKILL.md
│   │   └── reference/            # tokens, icons, components data
│   │
│   ├── design-atelier/           # ← from agent-skills
│   │   ├── SKILL.md
│   │   └── docs/
│   │
│   └── design-critique/          # ← from agent-skills
│       └── SKILL.md
│
├── docs/
│   ├── overview.md               # Project overview
│   ├── getting-started.md        # How to use dk-1
│   ├── repo-map.md               # Visual repo connection map
│   ├── rethink-plan.md           # This document
│   └── *-visual-guide.md         # Visual guides
│
├── repos/                        # Cloned repositories (git-ignored)
│
├── dk.config.json                # Central config (repos, ports, connections)
├── CLAUDE.md                     # Points to skills/
├── README.md                     # User-facing overview
├── .gitignore
└── logs/                         # Dev session logs (git-ignored)
```

**What's gone:**
- `.cursor/rules/` — all knowledge moved to skills
- `.cursor/commands/` — all workflows moved to skills
- `bin/` — scripts distributed into `skills/setup/scripts/` and `skills/dev-servers/scripts/`

**What's new:**
- `skills/` — everything is a skill
- `skills/setup/` and `skills/dev-servers/` — workspace operations with their scripts
- `skills/git-workflow/` — multi-repo git knowledge (was split across `base.mdc` and `git.md`)
- Design skills imported from agent-skills

---

## Skill Inventory

### Repository Knowledge Skills

Each skill is the definitive reference for working with that codebase.

| Skill | Source | Key Content |
|-------|--------|-------------|
| `calypso` | `calypso.mdc` | Two interfaces (Legacy vs Dashboard), components, TanStack Query/Router, Redux, styling, i18n, entry points |
| `gutenberg` | `gutenberg.mdc` + `gutenberg-components.mdc` | @wordpress/components, block development, Storybook, component file structure, state management |
| `wordpress-core` | `wordpress-core.mdc` | REST API, admin pages, hooks, blocks, security, database, PHP conventions |
| `jetpack` | `jetpack.mdc` | Monorepo structure, modules, blocks, packages, pnpm jetpack CLI, WP Core mounting |
| `ciab` | `ciab.mdc` | Route auto-discovery, SPA architecture, @automattic/design-system, TanStack Router |
| `telex` | `telex.mdc` | Artefact system, S3/MinIO, WordPress Playground, CLI, setup checklist |
| `cross-repo` | `cross-repo.mdc` + `cross-repo.md` | Data flows, shared packages, feature flags, coordinating multi-repo changes |

### Workflow Skills

| Skill | Source | Key Content |
|-------|--------|-------------|
| `setup` | `setup.mdc` + `bin/setup.sh`, `repos.sh`, `reset.sh`, `status.sh`, `which-repo.sh` | Prerequisites, Node version management, clone/install protocol, scripts |
| `dev-servers` | `start.md` + `bin/start.sh` | Starting servers, ports, URLs, wp-env conflict prevention |
| `build-screen` | `build-screen.md` | Calypso page templates (basic, settings, list), Gutenberg sidebar/inspector, WP Admin pages |
| `find-component` | `find-component.md` | Component lookup tables, priority order, usage examples, Storybook links |
| `prototype` | `prototype.md` | Quick scaffolding, Storybook prototyping, settings/list/modal templates |
| `git-workflow` | `git.md` + git sections from `base.mdc` | Multi-repo branch conventions, which-repo awareness, PR workflows |

### Design Skills (from agent-skills)

| Skill | Content |
|-------|---------|
| `design-mockups` | Build and preview HTML/CSS mockups with local server |
| `wordpress-mockups` | WP/Gutenberg UI mockups with extracted tokens, icons, components |
| `design-atelier` | End-to-end design pipeline, reference gathering, parallel sub-agents |
| `design-critique` | UI/UX audit with Jobs/Ive philosophy |

---

## What Lives Where

### dk-1 Owns (design kit knowledge)

- All WordPress ecosystem skills (Calypso, Gutenberg, WP Core, Jetpack, CIAB, Telex)
- Cross-repo workflow knowledge
- Design skills (mockups, atelier, critique)
- Workspace setup and dev server management
- Screen building, component finding, prototyping

### agent-skills Keeps (general-purpose)

- `blogger` — writing/publishing
- `headless-browser` — general web browsing
- `pressable` — hosting management
- `ddg-search` — web search
- `skill-creator` — meta-skill
- `project-setup`, `project-tracker` — project management
- `wp-block-development`, `wp-plugin-development`, `wp-rest-api`, etc. — implementation-focused WP skills (vs dk-1's design-focused ones)

### The Boundary

**dk-1 skills** = "I'm a designer working in the WordPress ecosystem. Help me build, prototype, find components, understand architecture."

**agent-skills WP skills** = "I'm implementing a WordPress plugin/block/theme. Help me write correct code, follow conventions, run tests."

There's overlap in content (both know about @wordpress/components, both know about REST API) but different audiences and depth. dk-1 is design-first, agent-skills is implementation-first. That's fine — they can coexist.

---

## How Tools Consume dk-1

| Tool | Entry Point | How Skills Load |
|------|-------------|-----------------|
| **Claude Code** | `CLAUDE.md` → lists skills, tells Claude to read relevant `SKILL.md` | On demand per task |
| **OpenClaw** | `skills/` symlinked into workspace, listed in `<available_skills>` | Matched by description, loaded when relevant |
| **Cursor** | Can use CLAUDE.md (Claude Code mode) or skills can be referenced via a thin `.cursorrules` | Same SKILL.md files |
| **Codex / other** | Read `skills/*/SKILL.md` directly | Agent reads what it needs |
| **Humans** | Browse `skills/` as documentation | Just markdown files |

### CLAUDE.md Structure

```markdown
# CLAUDE.md

## Project Overview
Design Kit — a skills-based toolkit for designing across the WordPress ecosystem.

## Skills
The `skills/` directory contains all knowledge. Read the relevant SKILL.md for your task:

### Repository Knowledge
- `skills/calypso/` — Calypso architecture and conventions
- `skills/gutenberg/` — Gutenberg, @wordpress/components, blocks
- `skills/wordpress-core/` — WordPress Core, REST API, PHP
- `skills/jetpack/` — Jetpack monorepo
- `skills/ciab/` — CIAB admin SPA
- `skills/telex/` — Telex block authoring
- `skills/cross-repo/` — How repos connect

### Workflows
- `skills/setup/` — Environment setup (scripts in scripts/)
- `skills/dev-servers/` — Starting dev servers (scripts in scripts/)
- `skills/build-screen/` — Creating new screens/pages
- `skills/find-component/` — Finding existing components
- `skills/prototype/` — Quick prototyping
- `skills/git-workflow/` — Multi-repo git operations

### Design
- `skills/design-mockups/` — HTML/CSS mockup building
- `skills/wordpress-mockups/` — WP admin UI mockups
- `skills/design-atelier/` — Full design pipeline
- `skills/design-critique/` — UI/UX audits

## Configuration
See `dk.config.json` for repository paths, ports, and connections.

## Design Principles
- Design-first language: accept natural descriptions
- Reuse over reinvent: search existing components first
- Cross-repo awareness: features span multiple repos
- Progressive disclosure: start simple, reveal complexity when needed
```

---

## Migration Plan

### Phase 1: Create `skills/` with repo knowledge

Convert each `.mdc` rule to `SKILL.md`:

1. `skills/calypso/SKILL.md` ← `calypso.mdc`
2. `skills/gutenberg/SKILL.md` ← `gutenberg.mdc` + `gutenberg-components.mdc`
3. `skills/wordpress-core/SKILL.md` ← `wordpress-core.mdc`
4. `skills/jetpack/SKILL.md` ← `jetpack.mdc`
5. `skills/ciab/SKILL.md` ← `ciab.mdc`
6. `skills/telex/SKILL.md` ← `telex.mdc`
7. `skills/cross-repo/SKILL.md` ← `cross-repo.mdc` + `cross-repo.md`

### Phase 2: Create workflow skills and move scripts

8. `skills/setup/SKILL.md` ← `setup.mdc`; move `bin/setup.sh`, `bin/repos.sh`, `bin/reset.sh`, `bin/status.sh`, `bin/which-repo.sh` → `skills/setup/scripts/`
9. `skills/dev-servers/SKILL.md` ← `start.md` content; move `bin/start.sh` → `skills/dev-servers/scripts/`
10. `skills/build-screen/SKILL.md` ← `build-screen.md`
11. `skills/find-component/SKILL.md` ← `find-component.md`
12. `skills/prototype/SKILL.md` ← `prototype.md`
13. `skills/git-workflow/SKILL.md` ← `git.md` + git sections from various rules

### Phase 3: Import design skills from agent-skills

14. Copy `design-mockups/` from agent-skills
15. Copy `wordpress-mockups/` from agent-skills
16. Copy `design-atelier/` from agent-skills
17. Copy `design-critique/` from agent-skills

### Phase 4: Update entry points

18. Rewrite `CLAUDE.md` to reference skills/
19. Update `README.md`
20. Update `dk.config.json` if needed

### Phase 5: Remove old structure

21. Delete `.cursor/rules/` directory
22. Delete `.cursor/commands/` directory
23. Delete `bin/` directory (scripts are in skills now)
24. Remove design skills from agent-skills repo
25. Update any symlinks pointing to agent-skills design skills

### Phase 6: Test

26. Test with Claude Code (does CLAUDE.md → skills/ work?)
27. Test with OpenClaw (symlink skills/, verify loading)
28. Verify scripts still work from new locations (update paths in scripts if needed)

---

## Open Questions

1. **Script paths:** Moving scripts from `bin/` to `skills/setup/scripts/` changes the relative paths. Scripts reference `repos/` and `dk.config.json` relative to project root. Options: (a) use `$DK_ROOT` env var, (b) scripts detect their own location and resolve root, (c) keep a thin `bin/` that delegates to skill scripts.

2. **Skill naming:** Short names (`calypso`) or prefixed (`wp-calypso`)? Leaning short — they're inside dk-1 already.

3. **Design persona:** `base.mdc` defines the design-first AI personality. Should this become a skill, or go into CLAUDE.md directly? It's more "kit identity" than "reusable knowledge."

4. **OpenClaw integration:** Best way to make dk-1 skills available? Symlink entire `dk-1/skills/` into workspace? Or individual skill symlinks?

5. **Removing from agent-skills:** Delete the 4 design skills from agent-skills, or leave stubs saying "moved to dk-1"?
