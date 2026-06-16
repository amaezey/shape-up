# shellcheck shell=bash
# Minimal, dependency-free assertion helpers for the shape-up test suite.
# Each test file sources this, runs checks, then calls `summary` and exits with its status.

TESTS_RUN=0
TESTS_FAILED=0

_pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; printf '      %s\n' "$2"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

# check "desc" "$actual" "$expected"  — string equality
check() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$2" == "$3" ]]; then _pass "$1"; else _fail "$1" "expected [$3], got [$2]"; fi
}

# check_contains "desc" "$haystack" "$needle"
check_contains() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$2" == *"$3"* ]]; then _pass "$1"; else _fail "$1" "expected to contain [$3], got [$2]"; fi
}

# check_empty "desc" "$value"
check_empty() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -z "$2" ]]; then _pass "$1"; else _fail "$1" "expected empty, got [$2]"; fi
}

# check_nonempty "desc" "$value"
check_nonempty() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -n "$2" ]]; then _pass "$1"; else _fail "$1" "expected non-empty value"; fi
}

# check_file "desc" "$path"
check_file() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$2" ]]; then _pass "$1"; else _fail "$1" "no such file: $2"; fi
}

# check_exec "desc" "$path"
check_exec() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -x "$2" ]]; then _pass "$1"; else _fail "$1" "not executable: $2"; fi
}

summary() {
  echo
  if [[ $TESTS_FAILED -eq 0 ]]; then
    printf '\033[32m  All %d checks passed.\033[0m\n' "$TESTS_RUN"
    return 0
  fi
  printf '\033[31m  %d of %d checks failed.\033[0m\n' "$TESTS_FAILED" "$TESTS_RUN"
  return 1
}
