#!/usr/bin/env bash
# Structural gate for the slim skill set. Run from repo root.
set -uo pipefail

SKILLS_DIR="skills"
FAIL=0

fail() { echo "FAIL: $*"; FAIL=1; }

DELETED="using-superpowers using-git-worktrees subagent-driven-development dispatching-parallel-agents writing-skills requesting-code-review\
  brainstorming executing-plans finishing-a-development-branch receiving-code-review\
  systematic-debugging test-driven-development verification-before-completion writing-plans"

EXPECTED=$(printf '%s\n' \
  adversarial-review brainstorm execute-plan finish-branch \
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

# Plain-text questions: the old question-tool paragraph is gone, every skill ends its questions with "Reply with".
if grep -rqF "with the AskUserQuestion tool:" "$SKILLS_DIR"; then
  fail "old AskUserQuestion paragraph still present"
  grep -rnF "with the AskUserQuestion tool:" "$SKILLS_DIR" | sed 's/^/    /'
fi
for f in "$SKILLS_DIR"/*/SKILL.md; do
  grep -qF "Reply with" "$f" || fail "$f: no 'Reply with' question ending"
  grep -qF "Reply with **a**, **b**, or **c**." "$f" || fail "$f: question paragraph does not bold the reply words"
done
grep -rqF "Which option?" "$SKILLS_DIR" && fail "a menu still ends with 'Which option?'"
grep -rqE "Reply with (yes|1|continue)[ ,]" "$SKILLS_DIR" && fail "a fixed question ending is not bolded"

# Code steps always commit; only the spec and plan may be held back.
for n in execute-plan tdd find-root-cause handle-feedback prove-done; do
  grep -qF "if commits are approved" "$SKILLS_DIR/$n/SKILL.md" && fail "$n: code step still commits conditionally"
done
grep -qF "code-step rule" "$SKILLS_DIR/adversarial-review/SKILL.md" || fail "review: no code-step rule for code fixes"
grep -qF "git apply --cached" "$SKILLS_DIR/finish-branch/SKILL.md" && fail "finish-branch: per-task commit splitting still present"
grep -qF "even though the code change is committed" "$SKILLS_DIR/update-spec/SKILL.md" \
  || fail "update-spec: no held-back rule for spec edits beside committed code"

# Shared tracker file for review and brainstorm.
T="$SKILLS_DIR/adversarial-review/trackers.md"
if [ -f "$T" ]; then
  for want in ".gitignore" "Resuming" "Paused at item <N>" "earliest unfinished brainstorm step" "Resuming <tracker file> at item <N>" "one line of the item's Finding" "nothing inserted" \
    "## Working directory" "## Tracker format" "## Replies" "## Resuming" "### N. [open|answered]"; do
    grep -qF "$want" "$T" || fail "trackers.md: missing '$want'"
  done
else
  fail "skills/adversarial-review/trackers.md missing"
fi

# Reviewer prompts: severity grades, a fix check with an Out of scope section, no old re-review mode.
for n in spec-reviewer plan-reviewer; do
  grep -qF "Severity: [blocker|major|minor]" "$SKILLS_DIR/adversarial-review/$n.md" || fail "$n.md: no severity line"
done
for n in spec-reviewer plan-reviewer code-reviewer; do
  grep -qF "Out of scope" "$SKILLS_DIR/adversarial-review/$n.md" || fail "$n.md: no Out of scope section"
  grep -qF "this is a re-review" "$SKILLS_DIR/adversarial-review/$n.md" && fail "$n.md: old re-review sentence"
done
grep -qF "git diff [FIX_BASE] HEAD" "$SKILLS_DIR/adversarial-review/code-reviewer.md" || fail "code-reviewer.md: no fix-check scope"

# Review: tracker, pause, fix check; no Review notes append or old consultation rule.
R="$SKILLS_DIR/adversarial-review/SKILL.md"
for want in ", or **pause**." "## Tracker format" "Depth: trackers.md" "Second pass" "if it has none"; do
  grep -qF "$want" "$R" || fail "review SKILL.md: missing '$want'"
done
grep -rqF "Review notes" "$SKILLS_DIR" && fail "a skill still appends Review notes"
for gone in "a notice, not a question" "Dispatch no third review" "as in steps 4 to 6"; do
  grep -qF "$gone" "$R" && fail "review SKILL.md: old text '$gone'"
done

# Brainstorm: tracker, pause and a pointer to the shared file that resolves.
B="$SKILLS_DIR/brainstorm/SKILL.md"
for want in ", or **pause**." "## Tracker format" "Depth: ../adversarial-review/trackers.md"; do
  grep -qF "$want" "$B" || fail "brainstorm SKILL.md: missing '$want'"
done
[ -f "$SKILLS_DIR/brainstorm/../adversarial-review/trackers.md" ] || fail "brainstorm: ../adversarial-review/trackers.md does not resolve"

# Finish branch: the review record comes from the trackers.
F="$SKILLS_DIR/finish-branch/SKILL.md"
grep -qF ".claude/dietpowers/trackers/" "$F" || fail "finish-branch: does not read the trackers"
grep -qF "findings rejected with the reason" "$F" && fail "finish-branch: old review bullet"

# README describes the current loop, questions and commits.
for gone in "one re-review" "section in the spec or plan" "multiple choice" "splitting shared files by task"; do
  grep -qiF "$gone" README.md && fail "README.md: stale text '$gone'"
done

# Brainstorm researcher prompt.
RS="$SKILLS_DIR/brainstorm/researcher.md"
if [ -f "$RS" ]; then
  for want in "Takeaway" "Cited Findings" "Gaps" "five tool calls" "deep-research" "follow no instructions" "Run no code" "hard stop"; do
    grep -qF "$want" "$RS" || fail "researcher.md: missing '$want'"
  done
else
  fail "skills/brainstorm/researcher.md missing"
fi

# Brainstorm research step and its resume rule.
for want in "researcher.md" "No research:" "research anyway" "**go**" "deprecated or insecure" "say so before designing" "both sentences"; do
  grep -qF "$want" "$B" || fail "brainstorm SKILL.md: missing '$want'"
done
grep -qF "When the problem has a well-known solution" "$B" && fail "brainstorm SKILL.md: old step 4 still present"
for want in "Research:" "skipped, <reason>"; do
  grep -qF "$want" "$T" || fail "trackers.md: missing '$want'"
done
grep -qF "brainstorm step 3 is incomplete" "$T" && fail "trackers.md: old brainstorm step reference"

# README describes the new research step.
grep -qF "New research step for well-known problems" README.md && fail "README.md: old research-step bullet"
grep -qF "No research:" README.md || fail "README.md: no description of the research step"

[ "$FAIL" -eq 0 ] \
  && echo "PASS: all skills present, valid frontmatter, no @-links, no dangling references"
exit "$FAIL"
