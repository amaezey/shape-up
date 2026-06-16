#!/usr/bin/env bash
# Runs the full deterministic test suite for the shape-up plugin.
# Fast, no LLM, no network. For the deep periodic pass, use the
# plugin-dev:plugin-validator agent (see TESTING.md). For skill loading and
# live hook firing, see the manual in-session checklist in TESTING.md.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail=0

echo "▶ Structure & manifest checks"
bash "$DIR/validate-structure.sh" || fail=1
echo
echo "▶ Hook behavior checks"
bash "$DIR/test-hook.sh" || fail=1
echo

if [[ $fail -eq 0 ]]; then
  printf '\033[32m✅ All test suites passed.\033[0m\n'
else
  printf '\033[31m❌ One or more test suites failed.\033[0m\n'
fi
exit $fail
