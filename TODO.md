# TODO

## Skills Migration (merged)

- [x] Migrate Cursor rules/commands to skills/ structure
- [x] Remove old Cursor rules, commands, and scripts directories
- [x] Add automated test suite (`tests/run.sh`)
- [x] Merge PR #1 to main
- [ ] Test with Claude Code in a fresh session
- [ ] Test with at least one repo: clone, install deps, start dev server

## Codespaces (merged)

- [x] Create `.devcontainer/devcontainer.json`
- [x] Test in a real Codespace
- [x] Verify port forwarding works (Storybook confirmed working)
- [ ] Fix Docker-in-Docker for wp-env servers (or wait for Docker replacement)
- [ ] Test Claude Code CLI inside Codespace
- [ ] Add "Open in Codespace" button to README
- [ ] Evaluate prebuilds once config is stable

## Future

- [ ] Import design skills from agent-skills repo (design-mockups, wordpress-mockups, design-atelier, design-critique)
- [ ] Add visual guides for remaining repos (Gutenberg, WordPress Core, Jetpack, Telex)
