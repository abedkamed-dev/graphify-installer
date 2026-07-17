#!/usr/bin/env bash
#
# Graphify quick installer  ·  https://github.com/abedkamed-dev/graphify-installer
# ---------------------------------------------------------------------------
# One command installs:
#   1. uv .............. Python tool manager (only if missing; brings its own Python)
#   2. graphify ........ the CLI, with SQL-schema parsing
#   3. /graphify ....... the skill for Claude Code (~/.claude/skills/graphify)
#
# Safe to re-run — every step upgrades in place.
#
# Run it:
#   curl -LsSf https://raw.githubusercontent.com/abedkamed-dev/graphify-installer/main/install-graphify.sh | bash
# or, if you have the file:
#   chmod +x install-graphify.sh && ./install-graphify.sh
#
set -euo pipefail

# --- pretty output (colors only on a real terminal) ------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_CYAN=$'\033[1;36m'; C_YEL=$'\033[1;33m'; C_GRN=$'\033[1;32m'; C_RED=$'\033[1;31m'; C_DIM=$'\033[2m'; C_0=$'\033[0m'
else
  C_CYAN=""; C_YEL=""; C_GRN=""; C_RED=""; C_DIM=""; C_0=""
fi
step()  { printf '%s==>%s %s\n' "$C_CYAN" "$C_0" "$1"; }
ok()    { printf '%s✓%s  %s\n'  "$C_GRN"  "$C_0" "$1"; }
warn()  { printf '%s!%s  %s\n'  "$C_YEL"  "$C_0" "$1"; }
die()   { printf '%s✗  %s%s\n'  "$C_RED"  "$1" "$C_0" >&2; exit 1; }

trap 'die "Install failed on line $LINENO. Re-run, or open an issue at https://github.com/abedkamed-dev/graphify-installer/issues"' ERR

printf '\n%s┌─ graphify installer ─────────────────────────────┐%s\n' "$C_DIM" "$C_0"
printf '%s│  code · docs · papers  →  a queryable graph       │%s\n' "$C_DIM" "$C_0"
printf '%s└──────────────────────────────────────────────────┘%s\n\n' "$C_DIM" "$C_0"

# --- 0. sanity: OS + curl --------------------------------------------------
case "$(uname -s)" in
  Darwin|Linux) : ;;
  *) die "Unsupported OS '$(uname -s)'. This installer supports macOS and Linux." ;;
esac
command -v curl >/dev/null 2>&1 || die "curl is required but not found. Install curl and re-run."

# Make a freshly-installed uv/graphify visible within this run.
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env" 2>/dev/null || true

# --- 1. uv -----------------------------------------------------------------
if command -v uv >/dev/null 2>&1; then
  ok "uv already installed ($(uv --version 2>/dev/null | awk '{print $2}'))"
else
  step "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env" 2>/dev/null || true
  command -v uv >/dev/null 2>&1 || die "uv installed but not on PATH. Open a new terminal and re-run."
  ok "uv installed ($(uv --version 2>/dev/null | awk '{print $2}'))"
fi

# --- 2. graphify CLI -------------------------------------------------------
had_graphify=""
command -v graphify >/dev/null 2>&1 && had_graphify="$(graphify --version 2>/dev/null || true)"

step "Installing graphify (with SQL support)..."
if ! uv tool install --upgrade 'graphifyy[sql]' 2>/dev/null; then
  warn "SQL extra unavailable on this platform — installing core graphify instead."
  uv tool install --upgrade graphifyy
fi
command -v graphify >/dev/null 2>&1 || die "graphify installed but not on PATH. Open a new terminal and re-run."

now_graphify="$(graphify --version 2>/dev/null || echo 'ready')"
if [ -n "$had_graphify" ] && [ "$had_graphify" = "$now_graphify" ]; then
  ok "graphify up to date ($now_graphify)"
else
  ok "graphify installed ($now_graphify)"
fi

# --- 3. /graphify skill for Claude Code ------------------------------------
step "Installing the /graphify skill..."
graphify install >/dev/null 2>&1 || graphify install
ok "skill installed → ~/.claude/skills/graphify"

# --- 4. smoke test ---------------------------------------------------------
step "Verifying..."
if graphify --help >/dev/null 2>&1; then
  ok "graphify runs correctly"
else
  warn "graphify installed but 'graphify --help' returned nonzero — try a new terminal."
fi

# --- 5. PATH guidance ------------------------------------------------------
case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *)
    warn "~/.local/bin isn't on your PATH in new shells. Add this to your ~/.zshrc or ~/.bashrc:"
    printf '\n    . "%s/.local/bin/env"\n' "$HOME"
    ;;
esac

# --- done ------------------------------------------------------------------
echo
ok "All set!"
printf '   Open %sClaude Code%s in any project folder and type:  %s/graphify .%s\n' "$C_CYAN" "$C_0" "$C_GRN" "$C_0"
if ! find "$HOME/.claude" -maxdepth 0 >/dev/null 2>&1; then
  printf '   %s(Get Claude Code at https://claude.com/claude-code)%s\n' "$C_DIM" "$C_0"
fi
echo
