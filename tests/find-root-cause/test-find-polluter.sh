#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/skills/find-root-cause/find-polluter.sh"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
  echo "  [PASS] $1"
}

fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"

  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    pass "$description"
  else
    fail "$description (expected output to contain: $needle)"
  fi
}

# Toy project: one top-level test, one nested test. A stubbed `npm` on PATH
# creates the pollution marker whenever any test runs, so the first test file
# executed is always identified as the polluter.
setup_project() {
  PROJECT="$TEST_ROOT/project"
  rm -rf "$PROJECT"
  mkdir -p "$PROJECT/src/feature" "$PROJECT/bin"
  echo "test('top')" > "$PROJECT/src/top.test.ts"
  echo "test('nested')" > "$PROJECT/src/feature/nested.test.ts"
  cat > "$PROJECT/bin/npm" <<'EOF'
#!/usr/bin/env bash
touch pollution.marker
EOF
  chmod +x "$PROJECT/bin/npm"
}

# run_polluter <pattern> — runs the script in the toy project with the stub
# npm first on PATH; captures combined output, never aborts on exit code.
run_polluter() {
  local pattern="$1"
  rm -f "$PROJECT/pollution.marker"
  (
    cd "$PROJECT"
    PATH="$PROJECT/bin:$PATH" "$SCRIPT_UNDER_TEST" 'pollution.marker' "$pattern" 2>&1
  ) || true
}

echo "Test: documented pattern finds nested test files (issue #2008)"
setup_project
OUTPUT="$(run_polluter 'src/**/*.test.ts')"
assert_contains "$OUTPUT" "FOUND POLLUTER" "documented pattern runs tests and detects pollution"

echo "Test: documented pattern also finds top-level test files"
setup_project
OUTPUT="$(run_polluter 'src/**/*.test.ts')"
assert_contains "$OUTPUT" "Found 2 test files" "src/**/*.test.ts matches src/top.test.ts and src/feature/nested.test.ts"

echo "Test: ./-prefixed pattern matches the same files"
setup_project
OUTPUT="$(run_polluter './src/**/*.test.ts')"
assert_contains "$OUTPUT" "Found 2 test files" "leading ./ on the pattern is accepted"

echo "Test: pre-existing pollution is an error, not a clean result"
setup_project
OUTPUT="$(
  cd "$PROJECT" && touch pollution.marker &&
  PATH="$PROJECT/bin:$PATH" "$SCRIPT_UNDER_TEST" 'pollution.marker' 'src/**/*.test.ts' 2>&1; echo "exit=$?"
)"
assert_contains "$OUTPUT" "already exists before any test ran" "reports the pre-existing file"
assert_contains "$OUTPUT" "exit=2" "exits with status 2"
if printf '%s' "$OUTPUT" | grep -Fq "all tests clean"; then fail "does not claim all tests clean"; else pass "does not claim all tests clean"; fi

echo "Test: a test path containing a space is run as one file"
setup_project
mkdir -p "$PROJECT/src/my feature"
echo "test('spaced')" > "$PROJECT/src/my feature/spaced.test.ts"
cat > "$PROJECT/bin/npm" <<'EOF2'
#!/usr/bin/env bash
case "$2" in *"my feature/spaced.test.ts") touch pollution.marker ;; esac
EOF2
chmod +x "$PROJECT/bin/npm"
OUTPUT="$(run_polluter 'src/**/*.test.ts')"
assert_contains "$OUTPUT" "Found 3 test files" "counts the spaced path as one file"
assert_contains "$OUTPUT" "Test: ./src/my feature/spaced.test.ts" "identifies the spaced file as the polluter"

echo "Test: non-matching pattern reports an honest zero"
setup_project
OUTPUT="$(run_polluter 'nomatch/**/*.test.ts')"
assert_contains "$OUTPUT" "Found 0 test files" "empty result counts as 0, not 1"
assert_contains "$OUTPUT" "No polluter found" "empty result exits via the clean path"

echo ""
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
fi
echo "All tests passed"
