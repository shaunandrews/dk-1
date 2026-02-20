# GitHub Codespaces Integration Plan

*February 18, 2026*

## Goal

Let designers click one button and get a fully working dk-1 environment — all repos cloned, dependencies installed, dev servers ready to start. No local setup required.

## How Codespaces Works for dk-1

GitHub Codespaces runs a Docker container configured via `.devcontainer/devcontainer.json`. When someone opens the repo in a Codespace, they get:

- A full Linux environment with VS Code in-browser
- All tools pre-installed (Node, nvm, yarn, pnpm, Composer, Docker)
- dk-1 cloned and ready
- Port forwarding so dev servers (Calypso, Storybook, WordPress, etc.) open in their real browser

### Port Forwarding

Codespaces automatically detects listening ports and creates authenticated URLs. A dev server on port 3000 inside the container becomes accessible at `https://<codespace-name>-3000.app.github.dev`. No tunneling or headless workarounds needed — real Chrome, real rendering.

## Devcontainer Configuration

### Structure

```
.devcontainer/
  devcontainer.json
```

### What Goes in devcontainer.json

**Features** (official dev container building blocks):
- `ghcr.io/devcontainers/features/node:1` — Node.js + nvm (install both Node 20 and 22)
- `ghcr.io/devcontainers/features/docker-in-docker:2` — Docker for wp-env (WordPress Core, Jetpack, CIAB)
- `ghcr.io/devcontainers/features/php:1` — PHP + Composer (for Jetpack, CIAB)
- `ghcr.io/devcontainers/features/git:1` — Git (likely already in base image, but explicit)

**Port forwarding:**
```json
"forwardPorts": [3000, 8889, 9999, 9001, 50240],
"portsAttributes": {
  "3000": { "label": "Calypso / Telex", "onAutoForward": "notify" },
  "8889": { "label": "WordPress Core / Jetpack", "onAutoForward": "notify" },
  "9999": { "label": "Gutenberg Dev", "onAutoForward": "notify" },
  "9001": { "label": "CIAB", "onAutoForward": "notify" },
  "50240": { "label": "Storybook", "onAutoForward": "notify" }
}
```

**Post-create setup:**
A `postCreateCommand` runs after the container is built. This should:
1. Install Node 20 and 22 via nvm
2. Install global tools (pnpm, yarn)
3. Optionally clone repos and install deps (or leave for the user/AI to do)

**Machine type:**
- Minimum: 4-core / 16 GB RAM (Calypso is a memory hog)
- Recommended: 8-core / 32 GB for working with multiple repos simultaneously

### Claude Code CLI

Users bring their own Anthropic API key, stored as a Codespace secret (`ANTHROPIC_API_KEY`). The postCreateCommand installs Claude Code CLI via npm. On first launch, Claude reads CLAUDE.md and has full context.

## Open Questions

1. **How much to pre-build?** Options:
   - *Minimal:* Just tools. User (or AI) runs setup to clone repos. Faster container start, but longer time-to-productive.
   - *Full:* Clone public repos and install deps during build. Slower container creation but instant productivity. Could use Codespace prebuilds to offset.
   - *Recommendation:* Start minimal. Add prebuilds later if the setup time is painful.

2. **Private repos (CIAB, Telex):** These need Automattic access. The devcontainer should handle the public repos gracefully and skip private ones without erroring. The setup script already does this.

3. **Machine size and cost:** 4-core machines use the free quota at 2x rate (60 effective hours/month). 8-core at 4x (30 hours). For Automattic designers, org-funded Codespaces would remove this concern.

4. **Prebuilds:** GitHub can pre-build the container on pushes to main, so users get a ready-to-go environment in ~30 seconds instead of waiting 5-10 minutes. Uses Actions minutes. Worth adding once the config is stable.

## Implementation Steps

1. Create `.devcontainer/devcontainer.json` with features, ports, and postCreateCommand
2. Write a `postCreateCommand.sh` script (or reuse `skills/setup/scripts/setup.sh`)
3. Test by opening the repo in a Codespace
4. Verify: repos clone, deps install, dev servers start, ports forward to browser
5. Iterate on machine size and timing
6. Document in README ("Open in Codespace" button)
7. Consider prebuilds once stable

## Cost (Personal Accounts)

| Plan | Free Compute | Free Storage |
|------|-------------|-------------|
| GitHub Free | 120 hrs/month | 15 GB |
| GitHub Pro | 180 hrs/month | 20 GB |

Compute is multiplied by core count: a 4-core machine uses 2x, 8-core uses 4x. Storage includes the container image + cloned repos.

For Automattic, org-level Codespaces billing can cover designer usage.
