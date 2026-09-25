#!/usr/bin/env bash
# Structural gate for the slim skill set. Run from repo root.
set -uo pipefail

SKILLS_DIR="skills"
FAIL=0

fail() { echo "FAIL: $*"; FAIL=1; }

DELETED="using-superpowers using-git-worktrees subagent-driven-development dispatching-parallel-agents writing-skills requesting-code-review\
  adversarial-review brainstorming executing-plans finishing-a-development-branch receiving-code-review\
  systematic-debugging test-driven-development verification-before-completion writing-plans"

EXPECTED=$(printf '%s\n' \
  review brainstorm execute-plan finish-branch \
  handle-feedback find-root-cause \
  tdd prove-done update-spec write-plan \
  | sort | tr '\n' ' ')
# -not -name '.*' — local tooling leaves untracked dirs like skills/.claude behind,
# and the "$SKILLS_DIR"/*/ glob below already skips them.
ACTUAL=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \; \
  | sort | tr '\n' ' ')
[ "$ACTUAL" = "$EXPECTED" ] \
  || fail "skill set mismatch
    expected: $EXPECTED
    actual:   $ACTUAL"

for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  f="${dir}SKILL.md"

  [ -f "$f" ] || { fail "$name: no SKILL.md"; continue; }

  fm=$(awk 'NR==1 && $0=="---" {inside=1; next} inside && $0=="---" {exit} inside' "$f")
  keys=$(printf '%s\n' "$fm" | grep -oE '^[a-z_-]+:' | tr -d ':' | sort | tr '\n' ' ')
  case "$keys" in
    "description name "|"argument-hint description name ") ;;
    *) fail "$name: frontmatter keys are '$keys', expected name, description and optionally argument-hint" ;;
  esac

  fmlen=$(printf '%s' "$fm" | wc -c | tr -d ' ')
  [ "$fmlen" -le 1024 ] || fail "$name: frontmatter is $fmlen chars, limit 1024"

  grep -qE '^[[:space:]]*@[A-Za-z./]' "$f" \
    && fail "$name: contains an @-link, which force-loads the target"

  for d in $DELETED; do
    pat="(^|[^a-z-])$d([^a-z-]|\$)"
    if grep -rqE "$pat" "$dir"; then
      fail "$name: references deleted skill '$d'"
      grep -rnE "$pat" "$dir" | sed 's/^/    /'
    fi
  done
done

[ "$FAIL" -eq 0 ] \
  && echo "PASS: all skills present, valid frontmatter, no @-links, no dangling references"
exit "$FAIL"
