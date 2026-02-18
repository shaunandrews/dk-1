# Skills Migration Plan — For Claude Code

*Branch: `update/skills-migration`*

## What This Is

We're converting dk-1 from Cursor-specific formats (`.cursor/rules/*.mdc` and `.cursor/commands/*.md`) to a universal `skills/` structure. Each skill gets a `SKILL.md` that any AI tool can read.

## Critical Rule

**This is a format conversion, not a rewrite.** Every fact, code example, path, command, and detail in the source files must be preserved in the output. Change the structure from .mdc frontmatter to clean markdown, but do NOT summarize, paraphrase, or "improve" the content. Do NOT add knowledge that isn't in the source. If the source has a code block, the skill has that code block. If the source lists specific CSS variables, the skill lists those same CSS variables.

## Target Structure

```
skills/
├── calypso/SKILL.md
├── gutenberg/SKILL.md
├── wordpress-core/SKILL.md
├── jetpack/SKILL.md
├── ciab/SKILL.md
├── telex/SKILL.md
├── cross-repo/SKILL.md
├── setup/
│   ├── SKILL.md
│   └── scripts/        ← COPIED from bin/ (bin/ stays intact)
│       ├── setup.sh
│       ├── repos.sh
│       ├── reset.sh
│       ├── status.sh
│       └── which-repo.sh
├── dev-servers/
│   ├── SKILL.md
│   └── scripts/        ← COPIED from bin/
│       └── start.sh
├── build-screen/SKILL.md
├── find-component/SKILL.md
├── prototype/SKILL.md
└── git-workflow/SKILL.md
```

## Conversion Steps

### Repository Knowledge Skills

For each, strip the .mdc frontmatter (the `---` block with globs/description/alwaysApply) and convert to clean markdown. Keep ALL content.

| # | Output | Source(s) | Notes |
|---|--------|-----------|-------|
| 1 | `skills/calypso/SKILL.md` | `.cursor/rules/calypso.mdc` | Large file (489 lines). Has two-interface architecture, CSS custom properties, typography guidelines, i18n patterns. Keep everything. |
| 2 | `skills/gutenberg/SKILL.md` | `.cursor/rules/gutenberg.mdc` + `.cursor/rules/gutenberg-components.mdc` | Merge both files. Gutenberg-components has detailed component file structure, Storybook patterns, testing patterns. |
| 3 | `skills/wordpress-core/SKILL.md` | `.cursor/rules/wordpress-core.mdc` | REST API patterns, hook system, asset enqueuing, security. Do NOT pad with generic WP knowledge. |
| 4 | `skills/jetpack/SKILL.md` | `.cursor/rules/jetpack.mdc` | Monorepo structure, pnpm jetpack CLI, module system. |
| 5 | `skills/ciab/SKILL.md` | `.cursor/rules/ciab.mdc` | Route auto-discovery, SPA architecture, design system. |
| 6 | `skills/telex/SKILL.md` | `.cursor/rules/telex.mdc` | Artefact system, S3/MinIO, WordPress Playground, setup checklist. |
| 7 | `skills/cross-repo/SKILL.md` | `.cursor/rules/cross-repo.mdc` + `.cursor/commands/cross-repo.md` | Merge both. The .mdc has the architecture, the command has workflow instructions. |

### Workflow Skills

| # | Output | Source(s) | Notes |
|---|--------|-----------|-------|
| 8 | `skills/setup/SKILL.md` | `.cursor/rules/setup.mdc` + `.cursor/commands/setup.md` | Merge both. The .mdc has the AI-driven setup protocol, the command has user-facing instructions. |
| 9 | `skills/dev-servers/SKILL.md` | `.cursor/commands/start.md` | Dev server startup, ports, URLs. |
| 10 | `skills/build-screen/SKILL.md` | `.cursor/commands/build-screen.md` | Screen templates for Calypso, Gutenberg, WP Admin. |
| 11 | `skills/find-component/SKILL.md` | `.cursor/commands/find-component.md` | Component lookup tables, priority order, examples. |
| 12 | `skills/prototype/SKILL.md` | `.cursor/commands/prototype.md` | Quick scaffolding, Storybook prototyping, templates. |
| 13 | `skills/git-workflow/SKILL.md` | `.cursor/commands/git.md` + git sections from `.cursor/rules/base.mdc` | Merge. The command has detailed git workflow, base.mdc has branch conventions and the "Git & Branch Workflows" section. |

### Scripts

Copy (not move) these from `bin/` to `skills/*/scripts/`. In each copied script, add path self-detection near the top:

```bash
DK_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
```

The `../..` goes: `scripts/` → skill dir → `skills/` → project root. Then replace any relative path references (like `./repos/` or `./dk.config.json`) with `$DK_ROOT/repos/` and `$DK_ROOT/dk.config.json`.

| Script | From | To |
|--------|------|----|
| `setup.sh` | `bin/setup.sh` | `skills/setup/scripts/setup.sh` |
| `repos.sh` | `bin/repos.sh` | `skills/setup/scripts/repos.sh` |
| `reset.sh` | `bin/reset.sh` | `skills/setup/scripts/reset.sh` |
| `status.sh` | `bin/status.sh` | `skills/setup/scripts/status.sh` |
| `which-repo.sh` | `bin/which-repo.sh` | `skills/setup/scripts/which-repo.sh` |
| `start.sh` | `bin/start.sh` | `skills/dev-servers/scripts/start.sh` |

Make all scripts executable (`chmod +x`).

### SKILL.md Format

Each SKILL.md should start with a brief one-line description, then the content:

```markdown
# Skill Name

Brief description of what this skill covers.

## Section from source...
```

No frontmatter. No globs. No `alwaysApply`. Just clean markdown.

### What NOT to Do

- Do NOT summarize or condense content
- Do NOT add knowledge not in the source files
- Do NOT reorganize sections beyond removing frontmatter
- Do NOT delete `.cursor/` or `bin/` directories
- Do NOT modify `dk.config.json`
- Do NOT touch `repos/`

### When Merging Two Sources

When a skill pulls from two files (e.g., cross-repo from both .mdc and .md), combine them logically. If both have overlapping sections, keep the more detailed version. Add a `---` separator between the two source contributions if it helps readability.

## After Conversion

Commit with: `"Migrate .cursor rules and commands to skills/ structure"`

## Verification

After committing, run this sanity check:
```bash
# Every source should have a corresponding skill
echo "Source .mdc files:"; ls .cursor/rules/*.mdc | wc -l
echo "Source .md commands:"; ls .cursor/commands/*.md | wc -l  
echo "Output skills:"; ls skills/*/SKILL.md | wc -l
echo "Should be 13 skills total"

# Line count comparison — skills should be CLOSE to source line counts
for skill in calypso gutenberg wordpress-core jetpack ciab telex; do
  src=$(wc -l < .cursor/rules/$skill.mdc)
  dst=$(wc -l < skills/$skill/SKILL.md)
  echo "$skill: source=$src converted=$dst"
done
```

Skills should be roughly the same length as their sources (minus frontmatter lines). A skill that's significantly shorter than its source has lost content.
