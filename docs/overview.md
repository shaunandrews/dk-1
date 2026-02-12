# Design Kit (dk-1) — Overview

## What Is This?

Design Kit is a skills-based toolkit for designers working across the WordPress ecosystem at Automattic. It brings together knowledge about Calypso, Gutenberg, WordPress Core, Jetpack, CIAB, and Telex — plus design workflow tools — as portable skills that work with any AI-assisted tool.

It's not a monorepo. It doesn't contain application code. It's a collection of skills (SKILL.md files), scripts, and documentation that help AI agents understand and navigate the WordPress ecosystem from a design perspective.

**Tool-agnostic by design.** Skills work with Claude Code, OpenClaw, Cursor, Codex, or anything that can read markdown. No tool-specific formats.

## Architecture

```
dk-1/
├── skills/                      # Everything is a skill
│   ├── calypso/SKILL.md         # Calypso architecture & conventions
│   ├── gutenberg/SKILL.md       # Gutenberg, @wordpress/components, blocks
│   ├── wordpress-core/SKILL.md  # WP Core, REST API, PHP
│   ├── jetpack/SKILL.md         # Jetpack monorepo
│   ├── ciab/SKILL.md            # CIAB admin SPA
│   ├── telex/SKILL.md           # Telex block authoring
│   ├── cross-repo/SKILL.md      # How repos connect
│   ├── setup/                   # Environment setup + scripts
│   ├── dev-servers/             # Dev server management + scripts
│   ├── build-screen/SKILL.md    # Screen/page templates
│   ├── find-component/SKILL.md  # Component lookup
│   ├── prototype/SKILL.md       # Quick scaffolding
│   ├── git-workflow/SKILL.md    # Multi-repo git
│   ├── design-mockups/          # HTML/CSS mockup building
│   ├── wordpress-mockups/       # WP admin UI mockups
│   ├── design-atelier/          # Full design pipeline
│   └── design-critique/         # UI/UX audits
├── docs/                        # Project documentation
├── repos/                       # Cloned repositories (git-ignored)
├── dk.config.json               # Central config (repos, ports, connections)
├── CLAUDE.md                    # Entry point for Claude Code
└── README.md                    # User-facing overview
```

**Three categories of skills:**
1. **Repository knowledge** (7) — Architecture and conventions for each codebase
2. **Workflow** (6) — Setup, dev servers, screen building, component finding, prototyping, git
3. **Design** (4) — Mockups, UI audits, design pipeline (imported from agent-skills)

## Relationship with Agent Skills

dk-1 and agent-skills serve different audiences:

- **dk-1** = Design-focused. "I'm designing across the WordPress ecosystem."
- **agent-skills** = Implementation-focused. "I'm building a WordPress plugin/block/theme."

Design skills (mockups, atelier, critique) live here in dk-1. General-purpose skills (blogging, hosting, search, WP-CLI) stay in agent-skills.

## Links

- **Repo:** `~/Developer/Projects/dk-1/`
- **Remote:** https://github.com/shaunandrews/dk-1
- **Agent Skills:** `~/Developer/Projects/agent-skills/`
- **Rethink Plan:** [docs/rethink-plan.md](rethink-plan.md)

## Key People

- **Shaun Andrews** — Creator, Design Engineer at Automattic

## What's Next

- Convert Cursor rules and commands to skills (Phase 1-2 of rethink plan)
- Import design skills from agent-skills (Phase 3)
- Update CLAUDE.md and README.md as entry points (Phase 4)
- Remove old Cursor-specific structure (Phase 5)
