# TODO

## Skills Migration (`update/skills-migration` branch)

- [ ] Re-run skills migration (sub-agent created files but failed to commit)
  - Convert `.cursor/rules/*.mdc` → `skills/*/SKILL.md`
  - Convert `.cursor/commands/*.md` → workflow skills
  - Copy scripts from `bin/` to `skills/*/scripts/` with self-detecting paths
  - Rewrite CLAUDE.md and README.md
- [ ] Review converted skills for accuracy and completeness
- [ ] Test with Claude Code in a fresh session (point it at the branch, run through onboarding)
- [ ] Test setup scripts work from new `skills/*/scripts/` locations
- [ ] Test with at least one repo: clone, install deps, start dev server
- [ ] Merge to main once validated

## Codespaces Integration

- [ ] Create `.devcontainer/devcontainer.json` (see `docs/codespaces-plan.md`)
- [ ] Write or adapt postCreateCommand script
- [ ] Test in a real Codespace: full onboarding flow
- [ ] Verify port forwarding works for dev servers (Calypso, Storybook, WordPress)
- [ ] Test Claude Code CLI inside Codespace
- [ ] Add "Open in Codespace" button to README
- [ ] Evaluate prebuilds once config is stable

## Cleanup (after skills migration is validated)

- [ ] Remove `.cursor/rules/` directory
- [ ] Remove `.cursor/commands/` directory
- [ ] Remove `bin/` directory (scripts live in skills now)
- [ ] Update `.gitignore` if needed

## Documentation

- [ ] Update `docs/getting-started.md` for skills-based structure
- [ ] Update `docs/overview.md` to reflect new architecture
- [ ] Archive `docs/rethink-plan.md` (completed)
