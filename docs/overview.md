# Design Kit (dk-1) — Overview

## What Is This?

Design Kit is a meta-repository that orchestrates the major WordPress ecosystem codebases — Calypso, Gutenberg, WordPress Core, Jetpack, CIAB, and Telex — into a single AI-assisted workspace for designers at Automattic.

It's not a monorepo. It doesn't contain application code. Instead, it provides the scaffolding: shell scripts for cloning/managing repos, AI rules that teach coding assistants about the ecosystem, slash commands for common design tasks, and documentation that maps how the six repositories connect.

The original design was Cursor-centric — `.cursor/rules/*.mdc` files and `.cursor/commands/*.md` — but the underlying knowledge (component libraries, cross-repo data flows, dev server configs, git conventions) is valuable to any AI-assisted workflow. The next evolution is making this knowledge portable across tools.

## Architecture

```
dk-1/
├── .cursor/rules/       # AI rules (Cursor .mdc format)
├── .cursor/commands/     # Slash commands (Cursor-specific)
├── bin/                  # Shell scripts (universal)
│   ├── setup.sh          # Clone repos + install deps
│   ├── repos.sh          # Multi-repo management
│   ├── start.sh          # Dev server launcher
│   ├── status.sh         # Environment status
│   ├── reset.sh          # Pull latest / clean install
│   └── which-repo.sh     # Context detection
├── docs/                 # Documentation (universal)
├── dk.config.json        # Central config for all repos
├── repos/                # Cloned repositories (git-ignored)
│   ├── calypso/
│   ├── gutenberg/
│   ├── wordpress-core/
│   ├── jetpack/
│   ├── telex/
│   └── (ciab/)
├── CLAUDE.md             # Claude Code guidance
└── README.md             # User-facing overview
```

**Two tiers of content:**
1. **Universal** — bin/ scripts, docs/, dk.config.json, CLAUDE.md. Works with any AI tool or manual workflow.
2. **Cursor-specific** — .cursor/rules/ and .cursor/commands/. Only useful inside Cursor IDE.

## Overlap with Agent Skills

The `agent-skills` repo (`~/Developer/Projects/agent-skills/`) contains OpenClaw skills that cover similar WordPress territory:

| dk-1 Cursor Rule | Agent Skill Equivalent |
|-------------------|----------------------|
| `gutenberg.mdc` | `wp-block-development`, `wp-interactivity-api` |
| `gutenberg-components.mdc` | `wordpress-mockups`, `design-mockups` |
| `wordpress-core.mdc` | `wp-plugin-development`, `wp-rest-api`, `wp-wpcli-and-ops` |
| `jetpack.mdc` | `wp-plugin-development` (partial) |
| `setup.mdc` | `wp-playground` |
| `cross-repo.mdc` | No direct equivalent |
| `base.mdc` (design persona) | `design-critique`, `design-atelier` |
| `calypso.mdc` | No direct equivalent |
| `ciab.mdc` | No direct equivalent |
| `telex.mdc` | No direct equivalent |

**Unique to dk-1:** Calypso, CIAB, and Telex knowledge; cross-repo workflow understanding; the meta-repo orchestration scripts.

**Unique to agent-skills:** PHPStan, WP-CLI ops, performance profiling, Pressable hosting, blog publishing, headless browser.

**Opportunity:** Extract the universal knowledge from dk-1's Cursor rules into portable skill format that works with OpenClaw, Claude Code, or any agent — while keeping the Cursor-specific wrappers thin.

## Links

- **Repo:** `~/Developer/Projects/dk-1/`
- **Remote:** https://github.com/shaunandrews/dk-1
- **Agent Skills:** `~/Developer/Projects/agent-skills/`

## Key People

- **Shaun Andrews** — Creator, Design Engineer at Automattic

## What's Next

- Rethink the Cursor-specific rules as universal skills
- Identify what stays dk-1-only vs. what migrates to agent-skills
- Make the design kit work across Cursor, Claude Code, OpenClaw, and other AI tools
- Reduce duplication between dk-1 and agent-skills
