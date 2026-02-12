# Design Kit Rethink Plan

*February 12, 2026 — Prepared by Moneypenny*
*Updated: February 12, 2026 — Skills stay in dk-1*

## The Problem

Design Kit works well in Cursor, but the knowledge is locked in `.cursor/rules/*.mdc` and `.cursor/commands/*.md` — formats that only Cursor understands. The knowledge itself is valuable and portable — it just needs to be in a universal format.

**Goal:** Restructure dk-1 as a skills-based design kit that works across tools (Cursor, Claude Code, OpenClaw, Codex, etc.). Skills live *here*, not in agent-skills. Some design-relevant agent-skills may migrate *into* dk-1.

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

## Relationship with Agent Skills

The `agent-skills` repo has some WordPress skills that overlap with dk-1. But the two projects have different purposes:

- **dk-1** = Design Kit for the WordPress ecosystem. Design-focused. Knows about Calypso, Gutenberg, WP Core, Jetpack, CIAB, Telex, and how they connect.
- **agent-skills** = General-purpose agent skills. Broader scope (blogging, hosting, search, etc.).

### Skills That Should Move INTO dk-1

These agent-skills are design-focused and belong in the design kit:

| Agent Skill | Why It Belongs in dk-1 |
|-------------|----------------------|
| `design-mockups` | Building and previewing design mockups — core design kit activity |
| `wordpress-mockups` | WP/Gutenberg UI mockups with tokens, icons, components — directly relevant |
| `design-atelier` | End-to-end design pipeline — design kit workflow |
| `design-critique` | UI/UX audit — design kit capability |

### Skills That Stay in Agent Skills

These are general-purpose and don't belong in a WordPress design kit:

| Agent Skill | Why It Stays |
|-------------|-------------|
| `blogger` | Writing/publishing — not design-specific |
| `headless-browser` | General web tool |
| `pressable` | Hosting management |
| `ddg-search` | General search |
| `skill-creator` | Meta-skill |
| `project-setup`, `project-tracker` | Project management |

### Skills That Overlap (deduplicate)

| dk-1 Knowledge | Agent Skill | Resolution |
|----------------|-------------|-----------|
| `gutenberg.mdc` block dev | `wp-block-development` | dk-1 skill gets the design-focused version; agent-skill keeps the implementation-focused version |
| `wordpress-core.mdc` REST API | `wp-rest-api` | Agent-skill is more detailed for backend work; dk-1 skill covers the design-relevant surface |
| `gutenberg-components.mdc` | `wordpress-mockups` | Merge — dk-1 skill covers both using and developing components |
| `find-component.md` tables | `wordpress-mockups` | Merge into dk-1's component skill |

---

## The New Structure

### dk-1 becomes skills-based:

```
dk-1/
├── skills/                      # ← NEW: Universal skills (SKILL.md format)
│   ├── calypso/
│   │   └── SKILL.md             # Calypso architecture & conventions
│   ├── gutenberg/
│   │   └── SKILL.md             # Gutenberg, @wordpress/components
│   ├── wordpress-core/
│   │   └── SKILL.md             # WP Core architecture
│   ├── jetpack/
│   │   └── SKILL.md             # Jetpack monorepo
│   ├── ciab/
│   │   └── SKILL.md             # CIAB admin SPA
│   ├── telex/
│   │   └── SKILL.md             # Telex block authoring
│   ├── cross-repo/
│   │   └── SKILL.md             # How repos connect
│   ├── design-mockups/          # ← FROM agent-skills
│   │   └── SKILL.md
│   ├── wordpress-mockups/       # ← FROM agent-skills
│   │   └── SKILL.md
│   ├── design-atelier/          # ← FROM agent-skills
│   │   └── SKILL.md
│   ├── design-critique/         # ← FROM agent-skills
│   │   └── SKILL.md
│   ├── build-screen/            # ← FROM .cursor/commands/
│   │   └── SKILL.md             # Screen templates for Calypso, Gutenberg, WP Admin
│   ├── find-component/          # ← FROM .cursor/commands/
│   │   └── SKILL.md             # Component lookup across repos
│   └── prototype/               # ← FROM .cursor/commands/
│       └── SKILL.md             # Quick scaffolding patterns
│
├── .cursor/rules/               # Thin Cursor wrappers (reference skills)
│   ├── base.mdc                 # Design persona (stays here — it's the DK identity)
│   ├── setup.mdc                # Setup protocol (workspace-specific, stays)
│   ├── calypso.mdc              # Glob + paths + "see skills/calypso"
│   ├── gutenberg.mdc            # Glob + paths + "see skills/gutenberg"
│   ├── wordpress-core.mdc       # Glob + paths + "see skills/wordpress-core"
│   ├── jetpack.mdc              # Glob + paths + "see skills/jetpack"
│   ├── ciab.mdc                 # Glob + paths + "see skills/ciab"
│   ├── telex.mdc                # Glob + paths + "see skills/telex"
│   └── cross-repo.mdc           # Glob + "see skills/cross-repo"
│
├── .cursor/commands/            # Thin command triggers (reference skills)
│   ├── build-screen.md          # → skills/build-screen
│   ├── find-component.md        # → skills/find-component
│   ├── prototype.md             # → skills/prototype
│   ├── setup.md                 # → .cursor/rules/setup.mdc
│   ├── start.md                 # Stays (workspace-specific)
│   ├── git.md                   # Stays (workspace-specific)
│   └── cross-repo.md            # → skills/cross-repo
│
├── bin/                         # Shell scripts (unchanged)
├── docs/                        # Workspace docs (unchanged)
├── repos/                       # Cloned repositories (git-ignored)
├── dk.config.json               # Central config (unchanged)
├── CLAUDE.md                    # Updated to reference skills/
└── README.md                    # Updated to mention skills
```

### How It Works Across Tools

| Tool | How It Consumes dk-1 |
|------|---------------------|
| **Cursor** | `.cursor/rules/*.mdc` activate per glob → reference `skills/` for deep knowledge |
| **Claude Code** | `CLAUDE.md` → references `skills/` directory |
| **OpenClaw** | Skills symlinked into agent workspace, loaded via `<available_skills>` |
| **Other agents** | Read `skills/*/SKILL.md` directly |
| **Humans** | Read `skills/*/SKILL.md` as documentation |

---

## Migration Plan

### Phase 1: Create skills/ directory

Convert each `.mdc` rule into a `skills/*/SKILL.md`:

1. `calypso.mdc` → `skills/calypso/SKILL.md`
2. `gutenberg.mdc` + `gutenberg-components.mdc` → `skills/gutenberg/SKILL.md`
3. `wordpress-core.mdc` → `skills/wordpress-core/SKILL.md`
4. `jetpack.mdc` → `skills/jetpack/SKILL.md`
5. `ciab.mdc` → `skills/ciab/SKILL.md`
6. `telex.mdc` → `skills/telex/SKILL.md`
7. `cross-repo.mdc` → `skills/cross-repo/SKILL.md`

Convert commands into skills:

8. `build-screen.md` → `skills/build-screen/SKILL.md`
9. `find-component.md` → `skills/find-component/SKILL.md`
10. `prototype.md` → `skills/prototype/SKILL.md`

### Phase 2: Import design skills from agent-skills

Copy (not symlink — dk-1 owns these now) into `skills/`:

11. `design-mockups/` — with preview server scripts
12. `wordpress-mockups/` — with tokens, icons, components data
13. `design-atelier/` — with reference gathering system
14. `design-critique/` — with audit framework

Merge `find-component.md` lookup tables into `wordpress-mockups` or `find-component` skill.

### Phase 3: Slim Cursor rules to wrappers

Replace each `.mdc` with a thin version:
- Keep the YAML frontmatter (description, globs)
- Keep workspace-specific context (paths, Node versions, dev server URLs, port numbers)
- Remove the deep knowledge (it's in the skill now)
- Add a reference: "For detailed architecture, see `skills/{name}/SKILL.md`"

`base.mdc` and `setup.mdc` stay mostly unchanged — they're workspace identity and workflow, not portable knowledge.

### Phase 4: Update entry points

- Update `CLAUDE.md` to reference `skills/` directory
- Update `README.md` to mention skills
- Update `dk.config.json` if skills need to be registered there

### Phase 5: Clean up agent-skills

- Remove the 4 design skills from agent-skills (they live in dk-1 now)
- Update agent-skills README
- Update any symlinks in agent workspaces to point to dk-1/skills/ instead

---

## What This Achieves

| Before | After |
|--------|-------|
| Knowledge locked in Cursor `.mdc` format | Knowledge in universal SKILL.md format |
| Design skills scattered across two repos | Design skills consolidated in dk-1 |
| Only works in Cursor IDE | Works in Cursor, Claude Code, OpenClaw, any tool |
| Cursor rules are 200-450 lines each | Cursor rules are ~30 lines (wrappers) |
| Duplicated knowledge between dk-1 and agent-skills | Single source of truth in dk-1 for design; agent-skills for general |

## Open Questions

1. **Skill naming:** Should the repo-specific skills be `calypso` or `wp-calypso`? Shorter is better within dk-1, but `wp-` prefix helps if they're ever referenced from outside.

2. **base.mdc:** The design-first AI persona is dk-1's identity. Should it also become a skill (so non-Cursor tools get the persona), or stay Cursor-only? Leaning toward making it a skill — it's the kit's voice.

3. **setup.mdc:** Tightly coupled to dk-1's multi-repo structure. Stays as Cursor rule. But should there also be a `skills/setup/SKILL.md` for Claude Code users?

4. **OpenClaw integration:** How should dk-1 skills be made available to OpenClaw agents? Symlink `dk-1/skills/` into the workspace? Or register dk-1 as a skills source?

5. **Removing from agent-skills:** When the design skills move to dk-1, do we just delete them from agent-skills, or leave stubs pointing here?
