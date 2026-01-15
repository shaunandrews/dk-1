# Design Kit Setup Tests

This directory contains tests to verify that the Design Kit setup process works correctly for new users.

## Quick Start

```bash
./bin/test-fresh.sh
```

This will:
1. Build a Docker container with all prerequisites (Node, Yarn, pnpm, Git, Composer)
2. Clone the repository inside the container (simulating a fresh user)
3. Run `./bin/setup.sh`
4. Verify all dependencies installed correctly
5. Test that the Docker checks work (the container intentionally doesn't have Docker)

## What It Tests

- **Prerequisites detection** - Verifies Node, Yarn, pnpm, Git, Composer are available
- **Repository cloning** - All repos clone correctly
- **Dependency installation** - node_modules exist for all repos
- **Docker check** - The "Docker not installed" message appears for `core` and `ciab`

## Commands

| Command | Description |
|---------|-------------|
| `./bin/test-fresh.sh` | Run the full test suite |
| `./bin/test-fresh.sh --build` | Just build the Docker image |
| `./bin/test-fresh.sh --shell` | Open a shell in the container for debugging |

## Debugging

If a test fails, use `--shell` to explore:

```bash
./bin/test-fresh.sh --shell

# Inside the container:
git clone /repo dk-test
cd dk-test
./bin/setup.sh
# ... investigate issues ...
```

## Notes

- The container runs as a non-root `designer` user to simulate real usage
- Docker is intentionally **not** installed in the container to test the graceful error handling
- The test takes 5-10 minutes depending on network speed (downloading npm packages)
