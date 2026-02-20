# Start

Start a development server for one of the Design Kit repositories.

## When to Use

- Designer wants to preview their work
- Designer says "start", "run", "launch", or "I want to work on [repo]"
- Designer needs a dev environment running

## Available Servers

| Repo | Command | URL | Requires Docker |
|------|---------|-----|-----------------|
| Calypso | `./bin/start.sh calypso` | http://calypso.localhost:3000 | No |
| Gutenberg | `./bin/start.sh gutenberg` | http://localhost:9999 | No |
| Storybook | `./bin/start.sh storybook` | http://localhost:50240 | No |
| WordPress Core | `./bin/start.sh core` | http://localhost:8889 | Yes |
| CIAB | `./bin/start.sh ciab` | http://localhost:9001/wp-admin/ | Yes |
| Jetpack | `./bin/start.sh jetpack` | http://localhost:8889 | Yes |

## AI Execution Steps

### Step 1: Identify the Target

Understand what the designer wants:
- "Start Calypso" → calypso
- "I want to work on blocks" → gutenberg or storybook
- "Show me the component library" → storybook
- "I need WordPress running" → core
- "Start the commerce thing" → ciab
- "Work on Jetpack" → jetpack

### Step 2: Check Prerequisites

Before starting, verify dependencies are installed:

```bash
# Check if the repo has node_modules
ls repos/[repo]/node_modules
```

If missing, offer to run setup first:
```
The dependencies for [repo] aren't installed yet. Let me run the setup first...
```

**If the designer just pulled latest:** recommend running install in that repo first to avoid build failures from new dependencies (e.g. `yarn install` in calypso, `pnpm install` in ciab/jetpack):
```
Looks like you just pulled — I'll run [yarn/pnpm] install first so new dependencies don't cause the build to fail.
```

For Docker-dependent repos (core, ciab, jetpack), check Docker:
```bash
docker info
```

If Docker isn't running:
```
WordPress Core/CIAB/Jetpack requires Docker Desktop to be running.
Please start Docker Desktop and let me know when it's ready.
```

### Step 3: Start the Server

Run the appropriate command in a **background terminal** so it keeps running:

```bash
./bin/start.sh [repo]
```

**Important**:
- This should run in the background. Tell the designer the server is starting.
- The script sets `NODE_OPTIONS=--max-old-space-size=8192` for Calypso (no need to pass extra memory manually).

### Step 4: Verify Startup and Handle Failures

After starting in the background, **check that the server didn’t fail** during the first compile:

1. **Wait briefly** (e.g. 15–25 seconds for Calypso/Gutenberg/Storybook) so the first build can run.
2. **Read the terminal output** for that background command (e.g. the terminal file for the shell that ran `./bin/start.sh [repo]`).
3. **Look for failure signals:**
   - `webpack compiled with 1 error` (or more)
   - `Module not found: Error: Can't resolve '...'`
   - `exit_code: 1` or process ended
   - Other clear build/runtime errors in the log

**If the process exited or the log shows a build error:**

- **Dependency / module not found:** Run the repo’s install command from the project root, then restart the server.
  - Calypso: `cd repos/calypso && yarn install` then `./bin/start.sh calypso` again.
  - Gutenberg: `cd repos/gutenberg && npm install` then restart.
  - CIAB / Jetpack: `pnpm install` in that repo then restart.
- **Other errors:** Read the full error, explain it in plain language, and suggest a fix (or run the fix if obvious, e.g. install deps).

Tell the designer what you did (e.g. “Install was missing a new dependency; I ran `yarn install` and restarted the server.”).

**If the server is still running and there’s no error in the log:** report success.

### Step 5: Report Status

Tell the designer:
- ✅ The server is starting (or that you fixed a failure and restarted)
- 🌐 The URL to access it
- ⏱️ It may take a moment to compile (for first run)

## Response Patterns

### Starting Calypso

```
🚀 Starting Calypso development server...

This will be ready at http://calypso.localhost:3000
It takes about 30-60 seconds to compile on first run.
I'll check the build output and tell you if anything fails (e.g. missing deps after a pull).
```

### Starting Storybook

```
🚀 Starting Gutenberg Storybook...

This will be ready at http://localhost:50240
You'll be able to browse all @wordpress/components with live examples.
```

### Starting WordPress Core

```
🚀 Starting WordPress Core development environment...

This uses Docker to run a full WordPress installation.
It will be ready at http://localhost:8889

Default credentials:
- Username: admin
- Password: password
```

### Starting Jetpack

```
🚀 Starting Jetpack development environment...

This runs WordPress Core with the Jetpack plugin activated.
It will be ready at http://localhost:8889

I'm also setting up the Jetpack symlink so your changes will be reflected live.
```

### Docker Not Running

```
⚠️ WordPress Core/CIAB/Jetpack requires Docker Desktop to be running.

Please:
1. Open Docker Desktop
2. Wait for it to start (the whale icon should stop animating)
3. Tell me when it's ready

If you don't have Docker installed:
- Mac: https://docs.docker.com/desktop/setup/install/mac-install/
- Windows: https://docs.docker.com/desktop/setup/install/windows-install/

Note: Calypso, Gutenberg, and Storybook don't need Docker!
```

### Dependencies Not Installed

```
⚠️ Dependencies for [repo] aren't installed yet.

Let me set that up for you first...

[Run setup]
```

## Multiple Servers

Designers can run multiple servers simultaneously:
- Calypso + Storybook is common (design in Calypso, reference components in Storybook)
- Gutenberg + Storybook works well together
- Core + Jetpack are the same server (Jetpack runs inside Core)

If the designer asks to start a second server:
```
I'll start [second repo] as well. Note that you'll have both servers running:
- [first repo] at [url1]
- [second repo] at [url2]
```

## Stopping Servers

If the designer wants to stop a server:
- Find the terminal running the server
- Send Ctrl+C to stop it
- Or close the terminal

```
To stop the server, I can close the terminal that's running it.
Want me to do that?
```

## Troubleshooting

### Port Already in Use

```
⚠️ Port [port] is already in use.

This usually means:
1. The server is already running (check other terminals)
2. Another application is using this port

Options:
- Let me check if it's already running
- I can stop the existing process
```

### Compilation Errors

If the server shows errors:
```
There's an error in the build. Let me check what's happening...

[Read the error, provide guidance]
```

### Dependency / Build Failure (e.g. After Pull)

When the process exits with `webpack compiled with 1 error` or `Module not found: Error: Can't resolve '...'`:

1. **Read the terminal output** to confirm it's a missing module or dependency.
2. **Run install in that repo** (from project root: `cd repos/[repo]` then `yarn install` / `npm install` / `pnpm install` as appropriate).
3. **Restart the server** with `./bin/start.sh [repo]` in the background.
4. **Re-run Step 4** (verify startup) and report back.

```
The build failed because a dependency wasn't installed (common after pulling). I've run [yarn/pnpm] install and restarted the server. It should be compiling now — try [URL] in a moment.
```

### Server Won't Start

```
The server didn't start properly. Let me check a few things:

1. Are dependencies installed? [check node_modules]
2. Any obvious errors? [check terminal output — e.g. Module not found → run install]
3. Is Docker running? [for core/ciab/jetpack]
```
