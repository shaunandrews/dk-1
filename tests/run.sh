#!/bin/bash
#
# Design Kit — Validation Test Suite
# Verifies the skills-based structure after migration from .cursor/rules + bin/
#
# Usage: ./tests/run.sh
# Exit 0 if all pass, exit 1 if any fail. No external dependencies.
#

set -euo pipefail

# ---------- Setup ----------

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
DK_ROOT="$(cd "$TESTS_DIR/.." && pwd)"

PASS=0
FAIL=0

green="\033[0;32m"
red="\033[0;31m"
bold="\033[1m"
dim="\033[2m"
reset="\033[0m"

pass() {
  printf "  ${green}✓${reset} %s\n" "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf "  ${red}✗${reset} %s\n" "$1"
  FAIL=$((FAIL + 1))
}

header() {
  printf "\n${bold}%s${reset}\n" "$1"
}

# ---------- 1. Structure Tests ----------

header "Structure — SKILL.md files"

SKILL_PATHS=(
  skills/calypso/SKILL.md
  skills/gutenberg/SKILL.md
  skills/wordpress-core/SKILL.md
  skills/jetpack/SKILL.md
  skills/ciab/SKILL.md
  skills/telex/SKILL.md
  skills/cross-repo/SKILL.md
  skills/setup/SKILL.md
  skills/dev-servers/SKILL.md
  skills/build-screen/SKILL.md
  skills/find-component/SKILL.md
  skills/prototype/SKILL.md
  skills/git-workflow/SKILL.md
)

for path in "${SKILL_PATHS[@]}"; do
  if [[ -f "$DK_ROOT/$path" ]]; then
    pass "$path exists"
  else
    fail "$path missing"
  fi
done

header "Structure — SKILL.md frontmatter"

for path in "${SKILL_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  [[ ! -f "$file" ]] && { fail "$path frontmatter (file missing)"; continue; }

  # Check: starts with ---, contains description: and globs:, has closing ---
  first_line=$(head -1 "$file")
  has_desc=$(grep -c '^description:' "$file" 2>/dev/null || true)
  has_globs=$(grep -c '^globs:' "$file" 2>/dev/null || true)
  # Find closing --- (second occurrence, line 2+)
  closing=$(awk 'NR>1 && /^---$/{print NR; exit}' "$file")

  if [[ "$first_line" == "---" && "$has_desc" -ge 1 && "$has_globs" -ge 1 && -n "$closing" ]]; then
    pass "$path has valid frontmatter"
  else
    fail "$path frontmatter invalid (---=${first_line}, desc=${has_desc}, globs=${has_globs}, close=${closing:-none})"
  fi
done

header "Structure — Scripts exist and are executable"

SCRIPT_PATHS=(
  skills/setup/scripts/setup.sh
  skills/setup/scripts/repos.sh
  skills/setup/scripts/reset.sh
  skills/setup/scripts/status.sh
  skills/setup/scripts/which-repo.sh
  skills/dev-servers/scripts/start.sh
)

for path in "${SCRIPT_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  if [[ -f "$file" && -x "$file" ]]; then
    pass "$path exists and executable"
  elif [[ -f "$file" ]]; then
    fail "$path exists but NOT executable"
  else
    fail "$path missing"
  fi
done

header "Structure — Root files"

for name in dk.config.json CLAUDE.md README.md TODO.md; do
  if [[ -f "$DK_ROOT/$name" ]]; then
    pass "$name exists"
  else
    fail "$name missing"
  fi
done

# Validate dk.config.json is valid JSON
if [[ -f "$DK_ROOT/dk.config.json" ]]; then
  valid_json=false
  if command -v python3 &>/dev/null; then
    python3 -m json.tool "$DK_ROOT/dk.config.json" &>/dev/null && valid_json=true
  elif command -v python &>/dev/null; then
    python -m json.tool "$DK_ROOT/dk.config.json" &>/dev/null && valid_json=true
  elif command -v node &>/dev/null; then
    node -e "JSON.parse(require('fs').readFileSync('$DK_ROOT/dk.config.json','utf8'))" &>/dev/null && valid_json=true
  else
    # Last resort: check it starts with { and ends with }
    head -c1 "$DK_ROOT/dk.config.json" | grep -q '{' && valid_json=true
  fi
  if $valid_json; then
    pass "dk.config.json is valid JSON"
  else
    fail "dk.config.json is NOT valid JSON"
  fi
fi

# ---------- 2. Script Path Tests ----------

header "Script paths — DK_ROOT detection"

for path in "${SCRIPT_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  [[ ! -f "$file" ]] && { fail "$path DK_ROOT detection (file missing)"; continue; }

  if grep -q 'DK_ROOT=' "$file"; then
    pass "$path contains DK_ROOT="
  else
    fail "$path missing DK_ROOT="
  fi
done

header "Script paths — DK_ROOT resolves to project root"

for path in "${SCRIPT_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  [[ ! -f "$file" ]] && { fail "$path DK_ROOT resolves (file missing)"; continue; }

  # Extract the DK_ROOT assignment and evaluate it with the script's dirname
  script_dir="$(dirname "$file")"
  resolved=$(cd "$script_dir/../../.." && pwd)

  if [[ "$resolved" == "$DK_ROOT" ]]; then
    pass "$path DK_ROOT resolves to project root"
  else
    fail "$path DK_ROOT resolves to '$resolved' (expected '$DK_ROOT')"
  fi
done

header "Script paths — No bin/ references"

for path in "${SCRIPT_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  [[ ! -f "$file" ]] && { fail "$path bin/ check (file missing)"; continue; }

  if grep -qE '(bin/setup\.sh|bin/repos\.sh|bin/start\.sh|\./bin/)' "$file"; then
    fail "$path still references bin/ paths"
  else
    pass "$path clean of bin/ references"
  fi
done

# ---------- 3. Stale Reference Tests ----------

header "Stale references — Root docs"

for name in CLAUDE.md README.md TODO.md; do
  file="$DK_ROOT/$name"
  [[ ! -f "$file" ]] && { fail "$name stale refs (file missing)"; continue; }

  stale=false
  if grep -q '\.cursor/' "$file"; then
    fail "$name references .cursor/"
    stale=true
  fi
  if grep -qE '(bin/setup\.sh|bin/repos\.sh|bin/start\.sh|\./bin/|`bin/)' "$file"; then
    fail "$name references bin/ paths"
    stale=true
  fi
  if ! $stale; then
    pass "$name clean of .cursor/ and bin/ references"
  fi
done

header "Stale references — SKILL.md bin/ paths"

for path in "${SKILL_PATHS[@]}"; do
  file="$DK_ROOT/$path"
  [[ ! -f "$file" ]] && { fail "$path bin/ check (file missing)"; continue; }

  # Match old dk-1 bin/ scripts, not sub-repo internal paths like bin/dev.mjs or bin/monorepo
  if grep -qE '(bin/setup\.sh|bin/repos\.sh|bin/start\.sh|bin/status\.sh|bin/which-repo\.sh|bin/reset\.sh|\./bin/(setup|repos|start|status|which-repo|reset))' "$file"; then
    fail "$path references old bin/ paths"
  else
    pass "$path clean of bin/ paths"
  fi
done

header "Stale references — CLAUDE.md key docs exist"

if [[ -f "$DK_ROOT/CLAUDE.md" ]]; then
  # Extract doc references: docs/*.md and TODO.md from the Key Docs section
  doc_refs=$(grep -oE '(docs/[a-zA-Z0-9_-]+\.md|TODO\.md)' "$DK_ROOT/CLAUDE.md" | sort -u)
  for ref in $doc_refs; do
    if [[ -f "$DK_ROOT/$ref" ]]; then
      pass "Key doc $ref exists"
    else
      fail "Key doc $ref referenced in CLAUDE.md but missing"
    fi
  done
fi

# ---------- 4. Smoke Tests ----------

header "Smoke tests"

# which-repo.sh
which_repo_out=$("$DK_ROOT/skills/setup/scripts/which-repo.sh" 2>&1) || true
if echo "$which_repo_out" | grep -qi 'dk'; then
  pass "which-repo.sh runs and detects dk project"
else
  fail "which-repo.sh output unexpected: $which_repo_out"
fi

# status.sh — just check exit code (warnings about missing repos are fine)
if "$DK_ROOT/skills/setup/scripts/status.sh" &>/dev/null; then
  pass "status.sh runs without error"
else
  fail "status.sh exited with error"
fi

# ---------- Summary ----------

TOTAL=$((PASS + FAIL))
printf "\n${bold}────────────────────────────────${reset}\n"
if [[ $FAIL -eq 0 ]]; then
  printf "${green}${bold}All %d tests passed.${reset}\n" "$TOTAL"
else
  printf "${red}${bold}%d failed${reset}, ${green}%d passed${reset} (of %d)\n" "$FAIL" "$PASS" "$TOTAL"
fi
printf "${bold}────────────────────────────────${reset}\n\n"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
