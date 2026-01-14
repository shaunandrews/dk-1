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
- Calypso uses `yarn start:debug` (not `yarn start`) for development.

### Step 4: Report Status

Tell the designer:
- ✅ The server is starting
- 🌐 The URL to access it
- ⏱️ It may take a moment to compile

## Response Patterns

### Starting Calypso

```
🚀 Starting Calypso development server (debug mode)...

This will be ready at http://calypso.localhost:3000
It takes about 30-60 seconds to compile on first run.
Running with yarn start:debug for development.

I'll let you know when it's ready, or you can check the terminal for progress.
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

### Server Won't Start

```
The server didn't start properly. Let me check a few things:

1. Are dependencies installed? [check node_modules]
2. Any obvious errors? [check terminal output]
3. Is Docker running? [for core/ciab/jetpack]
```
