# TODO

## In Progress (`update/skills-migration` branch)

- [x] Remove old Cursor rules and commands directory
- [x] Remove old scripts directory (migrated to skills/*/scripts/)
- [x] Add automated test suite (`tests/run.sh`)
- [ ] Test with Claude Code in a fresh session
- [ ] Test with at least one repo: clone, install deps, start dev server
- [ ] Merge PR #1 to main

## Codespaces Integration

- [ ] Create `.devcontainer/devcontainer.json` (see `docs/codespaces-plan.md`)
- [ ] Write or adapt postCreateCommand script
- [ ] Test in a real Codespace: full onboarding flow
- [ ] Verify port forwarding works for dev servers (Calypso, Storybook, WordPress)
- [ ] Test Claude Code CLI inside Codespace
- [ ] Add "Open in Codespace" button to README
- [ ] Evaluate prebuilds once config is stable

## Future

- [ ] Import design skills from agent-skills repo (design-mockups, wordpress-mockups, design-atelier, design-critique)
- [ ] Add visual guides for remaining repos (Gutenberg, WordPress Core, Jetpack, Telex)
