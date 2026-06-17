#!/usr/bin/env bash
# Structure, manifest, and skill-frontmatter checks for the shape-up plugin.
# Deterministic and fast — catches the mechanical breakages a future edit could
# introduce: malformed JSON, a renamed/lowercase SKILL.md, a name/dir mismatch,
# missing frontmatter, or a hardcoded path sneaking into the hook config.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"
ROOT="$(cd "$DIR/.." && pwd)"

if ! command -v jq >/dev/null 2>&1; then
  echo "  ⚠ jq not found — JSON validity checks need jq. Install it to run the full suite." >&2
  exit 1
fi

valid_json() { jq -e . "$1" >/dev/null 2>&1 && echo ok || echo bad; }

# --- plugin.json ---
PJ="$ROOT/.claude-plugin/plugin.json"
check_file "plugin.json exists"        "$PJ"
check      "plugin.json is valid JSON" "$(valid_json "$PJ")" "ok"
PNAME="$(jq -r '.name // empty' "$PJ")"
check      "plugin.json name is kebab-case and set" "$PNAME" "shape-up"
check_nonempty "plugin.json has a description" "$(jq -r '.description // empty' "$PJ")"
check_nonempty "plugin.json has a version"     "$(jq -r '.version // empty' "$PJ")"

# --- marketplace.json ---
MJ="$ROOT/.claude-plugin/marketplace.json"
check_file "marketplace.json exists"        "$MJ"
check      "marketplace.json is valid JSON" "$(valid_json "$MJ")" "ok"
check      "marketplace plugin name matches manifest" "$(jq -r '.plugins[0].name // empty' "$MJ")" "$PNAME"
check      "marketplace source points at plugin root" "$(jq -r '.plugins[0].source // empty' "$MJ")" "./"

# --- hooks.json ---
HJ="$ROOT/hooks/hooks.json"
check_file "hooks.json exists"        "$HJ"
check      "hooks.json is valid JSON" "$(valid_json "$HJ")" "ok"
check      "hooks.json registers a PostToolUse hook" "$(jq -r '.PostToolUse[0].matcher // empty' "$HJ")" "Write|Edit"
grep -q 'CLAUDE_PLUGIN_ROOT' "$HJ" && r=ok || r=missing
check      "hooks.json uses \${CLAUDE_PLUGIN_ROOT} for portability" "$r" "ok"
check      "hooks.json has no hardcoded /Users/ paths" "$(grep -c '/Users/' "$HJ" || true)" "0"

# --- hook script ---
check_exec "hook script is executable" "$ROOT/hooks/shaping-ripple.sh"

# --- skills: structure + frontmatter ---
EXPECTED_SKILLS=6
found=0
for d in "$ROOT"/skills/*/; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  found=$((found + 1))
  skill="$d/SKILL.md"

  # Exact-case SKILL.md (matters on case-sensitive filesystems)
  check "skills/$name uses exact-case SKILL.md" "$([[ -f "$skill" ]] && echo ok || echo missing)" "ok"
  [[ -f "$skill" ]] || continue

  # Frontmatter must open on line 1
  check "skills/$name frontmatter opens with ---" "$(head -1 "$skill")" "---"

  # name: must equal the directory name
  fm_name="$(awk -F': *' '/^name:/{print $2; exit}' "$skill" | tr -d '\r')"
  check "skills/$name frontmatter name matches directory" "$fm_name" "$name"

  # description: must be present and non-empty
  desc="$(awk -F'description: *' '/^description:/{print $2; exit}' "$skill" | tr -d '\r')"
  check_nonempty "skills/$name has a non-empty description" "$desc"
done
check "found the expected number of skills" "$found" "$EXPECTED_SKILLS"

summary
