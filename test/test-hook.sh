#!/usr/bin/env bash
# Unit tests for hooks/shaping-ripple.sh — the ripple-check PostToolUse hook.
#
# The hook reads a PostToolUse event as JSON on stdin and inspects
# .tool_input.file_path. It must emit the ripple checklist on stderr and
# exit 2 (blocking) ONLY for .md files that carry `shaping: true` in their
# first 5 lines. Everything else passes through silently with exit 0.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

HOOK="$(cd "$DIR/.." && pwd)/hooks/shaping-ripple.sh"
BASH_BIN="$(command -v bash)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Run the hook with a given file_path JSON value. Captures stderr to $TMP/err
# and leaves the exit code in $RC.
run_hook() {
  printf '{"tool_input":{"file_path":"%s"}}' "$1" | "$BASH_BIN" "$HOOK" 2>"$TMP/err"
  RC=$?
}
err() { cat "$TMP/err"; }

echo "  Hook under test: $HOOK"
check_file "hook script exists" "$HOOK"
check_exec "hook script is executable" "$HOOK"

# 1. A real shaping doc → block (exit 2) + checklist on stderr
SHAPE="$TMP/shape.md"
printf -- '---\nshaping: true\n---\n# A shaped thing\n' >"$SHAPE"
run_hook "$SHAPE"
check        "shaping:true .md blocks (exit 2)"        "$RC" "2"
check_contains "shaping:true .md emits ripple checklist" "$(err)" "Ripple check"

# 2. `shaping: true` past the first 5 lines → not detected (head -5 window)
LATE="$TMP/late.md"
printf -- 'one\ntwo\nthree\nfour\nfive\nshaping: true\n' >"$LATE"
run_hook "$LATE"
check       "shaping flag on line 6 is ignored" "$RC" "0"
check_empty "no output when flag is out of window" "$(err)"

# 3. A plain .md with no shaping flag → silent pass
PLAIN="$TMP/plain.md"
printf -- '# just notes\nno frontmatter here\n' >"$PLAIN"
run_hook "$PLAIN"
check       "plain .md passes (exit 0)"  "$RC" "0"
check_empty "plain .md emits nothing"    "$(err)"

# 4. Extension gate: shaping flag in a non-.md file → ignored
TXT="$TMP/notes.txt"
printf -- 'shaping: true\n' >"$TXT"
run_hook "$TXT"
check "shaping flag in .txt is ignored (extension gate)" "$RC" "0"

# 5. Nonexistent .md path → silent pass (the -f guard)
run_hook "$TMP/does-not-exist.md"
check "nonexistent .md path passes (exit 0)" "$RC" "0"

# 6. Empty file_path (e.g. a tool with no file) → silent pass
run_hook ""
check "empty file_path passes (exit 0)" "$RC" "0"

# 7. jq missing from PATH → graceful no-op (the dependency guard)
EMPTY_BIN="$TMP/empty-bin"
mkdir -p "$EMPTY_BIN"
printf '{"tool_input":{"file_path":"%s"}}' "$SHAPE" | PATH="$EMPTY_BIN" "$BASH_BIN" "$HOOK" 2>/dev/null
check "missing jq degrades to no-op (exit 0)" "$?" "0"

summary
