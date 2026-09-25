# Question sequences: implementation plan

Spec: docs/dietpowers/2026-09-25-question-sequences-spec.md @ f32f90f
Base: main
Commits: approved

Goal: make review and brainstorm question sequences consult the partner on every blocker and major finding, pause and resume from disk, run one scoped second pass, and send review history to the pull request.

Architecture: one new detail file, `skills/review/trackers.md`, holds the shared formats (working directory, tracker, statuses, answers, pause file, resume procedure). `skills/review/SKILL.md` and `skills/brainstorm/SKILL.md` keep their steps and point to it; the three reviewer prompts gain severity grades and a fix-check mode; `finish-branch` copies trackers into the PR. `tests/skills/check-skills.sh` gains one assertion block per task, which is the test cycle for these text changes.

Working-tree note: `README.md` and `skills/review/code-reviewer.md` carry the partner's own uncommitted edits (a seam-check sentence in code-reviewer.md "What to Review", and README lines around the code-reviewer change note). Keep them on disk untouched. When committing a task that edits either file, stage only that task's hunks (`git add -p`, or write the task's part as a patch and `git apply --cached`), never the partner's.

## Global Constraints

Copied verbatim from the spec.

- Pause option label: `Pause here`. Its description: `You can resume any time.` It is always the last option.
- When a question needs four real options, `Pause here` is dropped, and the question text ends with ` (type pause in Other to step out)`.
- Resume lead-in: `Resuming at <item>. If anything changed while you were away, say so in Other.`
- Working directory: `.claude/dietpowers/` at the project root (the root of the git work tree). When the model creates it, it also writes `.claude/dietpowers/.gitignore` containing the single line `*`. If the directory already exists without that file, the model writes the file.
- Tracker path: `.claude/dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`. `<stage>` is one of `brainstorm`, `spec-review`, `plan-review`, `code-review`. `<topic>` is the kebab-case topic of the spec (for a spec or plan review, the `<topic>` in the spec's filename; for a code review with no spec, the current branch name with `/` replaced by `-`). The date is the day the tracker was created. Each review run gets its own tracker; when the name is taken, append `-2`, `-3` and so on to the topic.
- Pause file path: `.claude/dietpowers/trackers/_pause.md`. There is at most one. Files in `trackers/` whose names start with `_` are never trackers.
- Severity grades: `blocker`, `major`, `minor`. Yardstick for specs and plans: "Would the plan or the code go wrong, or have to guess, if this stayed?" Yes means blocker or major; no means minor. Code reviewer mapping: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Review item statuses: `open`, `fix`, `fixed`, `deferred`, `won't fix`, `rejected`, `duplicate of <tracker file>#N`, `recheck`. `open` and `recheck` await a decision; `fix` is decided and awaits fixing. Brainstorm question statuses: `open`, `answered`.
- Second pass header values: `pending`, `fix check done (N findings)`, `full re-review done (N findings)`, `not run (<reason>)`.
- Snapshot: a git tree object of the work tree, tracked and untracked files alike (ignored files excluded), made without touching HEAD, refs, the index or the working tree:
  ```bash
  tmp=$(mktemp) && cp "$(git rev-parse --git-path index)" "$tmp" \
    && GIT_INDEX_FILE="$tmp" git add -A && GIT_INDEX_FILE="$tmp" git write-tree; rm -f "$tmp"
  ```
  It prints the tree id. If it prints no id, or a recorded snapshot later cannot be read (`git cat-file -e <id>` fails), the fix diff is unknown and the second pass is the full re-review. FIX_BASE is a snapshot taken just before the first fix; FIX_HEAD is one taken just after the last fix of the pass. Snapshots need no cleanup: nothing references them, so `git gc` prunes them once they are older than `gc.pruneExpire` (two weeks by default).
- Full re-review threshold: the fix diff changes more than 10% of the reviewed material. All counts come from `git diff --numstat`. For a spec or plan: (added + deleted lines in `git diff --numstat FIX_BASE FIX_HEAD -- <file>`) / (the file's line count in FIX_BASE, from `git show FIX_BASE:<file> | wc -l`). For code: (added + deleted lines in `git diff --numstat FIX_BASE FIX_HEAD`) / (added + deleted lines in `git diff --numstat <BASE_SHA> FIX_BASE`).
- Reviewer dispatches per review run: at most two (the first review, then one fix check or one full re-review).
- The published plugin stays hook-free.

## References

- Spec sections each task implements are named in the task's Context. The spec is the source for wording; tasks restate only what an executor could get wrong.
- `AGENTS.md`: SKILL.md anatomy (title; optional opening; numbered steps, optionally under headings; terminal-state line; `Depth:` line where detail files exist). Detail belongs in separate files that SKILL.md points to. Name other skills as `dietpowers:<name>`. Refer to own-directory files as `${CLAUDE_SKILL_DIR}/<file>`. Skill and reviewer prompts follow the Opus 5.5 prompting guide (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), not AGENTS.md's report-style rules. A `description` says what the skill produces and when to use it, never a summary of its steps.
- `skills/tdd/SKILL.md:29`: `Depth: writing-good-tests.md, ../find-root-cause/condition-based-waiting.md`, the precedent for a `Depth:` line and for a sibling-skill path with `../`. Installed plugins keep `skills/<name>/` side by side under the plugin version directory (seen in `~/.claude/plugins/cache/*/*/<version>/skills/`).
- `tests/skills/check-skills.sh`: structural gate. Uses a `fail()` helper that prints `FAIL: ...` and sets `FAIL=1`; ends with `[ "$FAIL" -eq 0 ] && echo "PASS: ..."; exit "$FAIL"`. New assertions go before that final block and use `fail()`. Run: `bash tests/skills/check-skills.sh`.
- `skills/review/SKILL.md` (at 995ca81): steps 1 to 3 (prompt files, save, dispatch) stay; steps 4 to 7 and the opening rationale sentence "One round of fixes and one re-review..." are replaced; step 7's `Review notes` append is removed.
- Reviewer prompts: all three open with "The agent that sent you supplies the values for the upper-case bracketed placeholders below... If it also supplied FINDINGS, this is a re-review: check only whether each of those findings is fixed, and whether the fixes broke anything." `spec-reviewer.md` finding format has `Section:` and `Check: [1-9 ...]` lines; `plan-reviewer.md` has `Task:` and `Check: [1-8 ...]`; `code-reviewer.md` has a findings table with a Severity column (CRITICAL/HIGH/MEDIUM/LOW, defined in its "Severity Guide") and runs the test suite once in "What to Review".
- `skills/finish-branch/SKILL.md` step 6: PR description bullets, including "review findings fixed, and findings rejected with the reason"; step 5: local merge.
- Snapshot command verified on 2026-09-25 in a scratch repo: an edit to an untracked file after snapshot B shows as `1 0 u.md` in `git diff --numstat B A`, and `git status --porcelain` is unchanged (`?? u.md`).

## Tasks

### - [ ] Task 1: Shared detail file `skills/review/trackers.md`

Files:
- Create `skills/review/trackers.md`. Imitate the tone and structure of `skills/find-root-cause/root-cause-tracing.md` (a detail file with headings, no frontmatter).
- Modify `tests/skills/check-skills.sh`.

Interfaces:
- Produces the file path `${CLAUDE_SKILL_DIR}/trackers.md` (from review) and `${CLAUDE_SKILL_DIR}/../review/trackers.md` (from brainstorm), consumed by Tasks 3 and 4. It must hold these headings, which Tasks 3 and 4 name when they point in: `## Working directory`, `## Tracker format`, `## Answers during a sequence`, `## Pausing`, `## Resuming`.

Context: spec "Shared detail file", "Tracker format", "Answers during a sequence", "Pausing", "Resuming"; Global Constraints (all values the file states are copied from there exactly).

Behavior:
- `## Working directory`: `.claude/dietpowers/` at the git work-tree root; write `.claude/dietpowers/.gitignore` containing `*` when creating the directory, or when it exists without that file; if writing fails, report it, continue without a tracker, and leave `Pause here` off with the reason told to the partner.
- `## Tracker format`: the path rule, the header fields (stage and document, with every file path recorded relative to the repository root so `git show FIX_BASE:<file>` works; branch and code-review base commit; every first-dispatch value including `REQUIREMENTS` verbatim; commit reviewed, FIX_BASE, FIX_HEAD, fix commits; `Second pass:`), the review item fields (heading `### N. [status] <title> (<severity>, review <1|2>, issue <k>)`; Finding; Verified; Options, or `notice only`; Decision as a dated append-only list; Fix; Depends on), brainstorm items (question, options, answer; presented text written before the questions that refer to it), statuses and their meaning, `Second pass:` values, the code severity mapping, the definition of an unfinished run, "every run starts a new tracker", and the duplicates rule with `duplicate of <tracker file>#N` (code reviews match on branch; brainstorm has none). Include the snapshot command, its failure rule and the no-cleanup note, and the threshold formulas. Include one filled example review item.
- `## Answers during a sequence`: the five cases from the spec, in the spec's order, with the rule that nothing short of an answer moves the sequence on and nothing licenses deciding the rest. The `Pause here` option and the four-real-options fallback text.
- `## Pausing`: `_pause.md` fields (the item's own question and options, never a clarifying question; reason or `none given`; resume instruction), the delete-on-answer rule, overwrite and "name the pause it replaced", stop and tell the partner they can say "resume". Include one filled example `_pause.md`.
- `## Resuming`: the six numbered resume steps from the spec, with the lead-in text exactly as in Global Constraints.

Tests (add to `check-skills.sh`, one block for this task):
- `trackers.md exists` — fails if the file is deleted or renamed.
- `trackers.md contains Pause here, _pause.md, .gitignore, Resuming at` — each a separate `grep -qF`; fails if any of those strings is dropped or reworded (for example `Resuming at` changed to `Resume at`).
- `trackers.md contains the five section headings` — fails if a heading Tasks 3 and 4 point to is renamed.
- `trackers.md contains duplicate of <tracker file>#N and git write-tree` — fails if the duplicate form reverts to `duplicate of N` or the snapshot command is dropped.
Run `bash tests/skills/check-skills.sh`; see the new block fail before creating the file, pass after.

### - [ ] Task 2: Reviewer prompts: severity and fix-check mode

Files:
- Modify `skills/review/spec-reviewer.md`, `skills/review/plan-reviewer.md`, `skills/review/code-reviewer.md` (partner's uncommitted hunk in code-reviewer.md stays unstaged; see Working-tree note).
- Modify `tests/skills/check-skills.sh`.

Interfaces:
- Consumes placeholders `FINDINGS`, `FIX_BASE`, `FIX_HEAD` (tree ids), supplied by review in Task 3.
- Produces: spec and plan findings with a line `Severity: [blocker|major|minor]`; code findings keep CRITICAL/HIGH/MEDIUM/LOW; an `Out of scope` heading in fix-check reports whose entries carry the same severity line (code: same scale).

Context: spec "Reviewer prompts"; Global Constraints (severity grades, yardstick); References (reviewer prompts).

Behavior:
- In all three, replace the "If it also supplied FINDINGS, this is a re-review..." sentence with fix-check mode: if FINDINGS, FIX_BASE and FIX_HEAD are supplied, read `git diff [FIX_BASE] [FIX_HEAD]` (it includes files that were untracked); check only whether each finding is fixed and whether the diff broke anything it touches; report anything outside the diff under `Out of scope`, graded like an ISSUE, not as an ISSUE. Without them, review in full as today.
- `spec-reviewer.md` and `plan-reviewer.md`: add `Severity: [blocker|major|minor]` to the finding format after `Check:`, and one sentence with the yardstick and "Name the failure scenario that justifies the grade."
- `code-reviewer.md`: fix-check mode overrides the scope in "What to Review" and Process step 1 (every change since the base, full-file reads); only the single test-suite run is kept, and its failures are reported as findings. This file's findings are `### BUG N` blocks, so its fix-check text says BUG wherever the other two prompts say ISSUE. The Severity Guide is unchanged.

Tests (one block):
- `spec and plan prompts contain Severity: [blocker|major|minor]` — fails if either prompt loses the line.
- `all three prompts contain FIX_BASE and FIX_HEAD` — fails if any prompt keeps the old re-review mode.
- `no prompt contains "this is a re-review"` — fails if the old sentence survives in any of the three.
- `code-reviewer.md fix-check text mentions the test suite` — `grep -F` for a phrase the executor writes (for example `still runs the full test suite`), recorded here after writing; fails if the suite instruction is dropped from fix-check mode.
Run `bash tests/skills/check-skills.sh`.

### - [ ] Task 3: Review skill steps

Files:
- Modify `skills/review/SKILL.md`.
- Modify `tests/skills/check-skills.sh`.

Interfaces:
- Consumes `${CLAUDE_SKILL_DIR}/trackers.md` headings (Task 1) and the prompt placeholders (Task 2).
- Produces: dispatch of the fix check with `FINDINGS`, `FIX_BASE`, `FIX_HEAD`; full re-review with none of these.

Context: spec "Review (`skills/review/SKILL.md`)" and "Inputs and failure behavior"; Global Constraints (threshold, dispatch cap, snapshot); References (`AGENTS.md` anatomy, review SKILL.md at 995ca81).

Behavior:
- Description adds "or to resume a paused review" to the trigger clause; frontmatter stays under 1024 characters.
- Opening: replace the "One round of fixes..." sentence with one sentence: a review ends when nothing blocking is open, because a reviewer will always find something.
- Step order: resume check (follow `## Resuming` in trackers.md); steps 1 to 3 as today, step 1 adding that the reviewer grades each finding; create the tracker and set `Second pass: pending`; check and record each finding; minor with one reasonable fix → `fix` plus a one-line notice; blocker, major, and any finding to reject, downgrade, fix more than one way, or whose fix changes the approved spec → asked one at a time, most severe first, options from fix as proposed / alternative fix / defer / won't fix / reject (at most three plus `Pause here`); raise grades freely, lower only by asking; answers and pauses per `## Answers during a sequence`; fixing only when no item is `open` or `recheck`, FIX_BASE snapshot first, `recheck`-then-changed items back to `fix` and undone or replaced by a new commit, code fixes test first, `dietpowers:update-spec` before a fix that alters specified behavior, failed fix → `open` with evidence, FIX_HEAD snapshot after the last fix; second pass only if anything was fixed (else `not run (nothing fixed)`), threshold chooses fix check or full re-review, snapshot missing or unreadable → full re-review, second reviewer never gets the tracker; if the second reviewer fails or returns nothing usable, report it, keep the first-pass decisions, set `Second pass: not run (<reason>)` and do not dispatch again; write review-2 items as `open` before updating `Second pass:`, triage as the first pass including duplicates, out-of-scope items with the reviewer's grade and defer recommended unless blocker, no further dispatch; report leading with the outcome, nothing appended to the spec or plan.
- Terminal state: done when no blocker or major item is `open`, `recheck` or `fix`; recommend continuing only when none is `deferred` either; menus as today; a revise run is a new run with a new tracker.
- End with `Depth: trackers.md`.

Tests (one block):
- `review SKILL.md contains Pause here and Depth: trackers.md` — fails if either is dropped.
- `no file under skills/ contains Review notes` — fails if the step 7 append survives anywhere.
- `review SKILL.md contains FIX_HEAD and Second pass` — fails if the dispatch or the ordering rule is lost.
- `review SKILL.md does not contain "Dispatch no third review"` nor `a notice, not a question` — fails if old step 4 or 6 text survives.
Run `bash tests/skills/check-skills.sh`. Then read the finished SKILL.md once against spec "Review" item by item and list any spec sentence with no counterpart in the Task's `Departure:` line.

### - [ ] Task 4: Brainstorm skill

Files:
- Modify `skills/brainstorm/SKILL.md`.
- Modify `tests/skills/check-skills.sh`.

Interfaces: consumes `${CLAUDE_SKILL_DIR}/../review/trackers.md` headings (Task 1).

Context: spec "Brainstorm (`skills/brainstorm/SKILL.md`)"; References (`AGENTS.md`, `skills/tdd/SKILL.md:29`).

Behavior:
- Description adds "or to resume a paused brainstorm"; frontmatter under 1024 characters.
- New first step: if the partner asked to resume, follow `## Resuming` in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker (stage `brainstorm`; topic chosen now and reused for the spec filename). Every sequence question ends with `Pause here`; answers and pauses follow the file. The tracker records each question, its options and answer, and the approaches and design as presented, written before the questions that refer to them. The commit-approval and design-approval questions also carry `Pause here`.
- End with `Depth: ../review/trackers.md`.

Tests (one block):
- `brainstorm SKILL.md contains Pause here` — fails if dropped.
- `brainstorm SKILL.md has a Depth: line naming ../review/trackers.md` — fails if the pointer is dropped or points at a wrong path.
- `the Depth path resolves` — `[ -f skills/brainstorm/../review/trackers.md ]`; fails if trackers.md moves.
Run `bash tests/skills/check-skills.sh`.

### - [ ] Task 5: Finish branch copies trackers into the PR

Files:
- Modify `skills/finish-branch/SKILL.md`.
- Modify `tests/skills/check-skills.sh`.

Context: spec "Finish branch"; References (finish-branch steps 5 and 6).

Behavior:
- Step 6's review bullet becomes: from review trackers in `.claude/dietpowers/trackers/` (skip `_` files) whose header names this branch's spec or plan (from the plan's `Spec:` line and the plan's path), plus code-review trackers naming this branch: each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- Step 5 (local merge): the merge commit message is an ordinary summary; it mentions the review process only for items whose Decision list has more than one entry.
- State that trackers are never deleted.

Tests (one block):
- `finish-branch SKILL.md contains .claude/dietpowers/trackers/` — fails if the PR bullet reverts.
- `finish-branch SKILL.md does not contain "findings rejected with the reason"` — fails if the old bullet survives.
Run `bash tests/skills/check-skills.sh`.

### - [ ] Task 6: README

Files: modify `README.md` (partner's uncommitted hunks stay unstaged; see Working-tree note). Modify `tests/skills/check-skills.sh`.

Context: spec "Other files".

Behavior:
- Replace the three flow-diagram lines ending `hostile review; fix; one re-review` / `hostile review of the branch; fix; one re-review` with a description of the new loop (for example `hostile review; you decide blockers and majors; fix; one scoped check`), keeping the diagram's column alignment.
- Rewrite the bullet containing `One re-review checks only the fixes`, the change note `Runs one scoped re-review, then stops.`, and the change note beginning `Reports outcome first and appends rejected findings with their reasons to a \`Review notes\` section` to the second-pass rule and the PR record. That last line sits two lines from the partner's uncommitted hunk; stage only this task's lines.
- Change notes: review (severity grades, per-finding questions for blockers and majors, pause and resume, trackers, second pass, no `Review notes`), brainstorm (pause, tracker, resume), finish-branch (trackers into the PR). Mention `.claude/dietpowers/.gitignore`.

Tests (one block):
- `README.md does not contain "one re-review" (case-insensitive)` — fails if any old line survives.
- `README.md contains _pause.md` — fails if the pause/resume note is missing.
- `README.md does not contain "Review notes" section in the spec or plan` (the old append sentence) — fails if line 116's old wording survives.
Run `bash tests/skills/check-skills.sh`.

### - [ ] Task 7: Manual trial on cells (spec success criterion 3)

Files: none in this repo. Record results as entries in `/Users/eliot/code/cells/.claude/dietpowers/problems.md`, or note their absence in this task's line.

Context: spec "Success criteria" item 3; `AGENTS.md` "Working on the skills" (load with `--plugin-dir /path/to/dietpowers --plugin-dir /path/to/dietpowers/dev`).

Behavior:
- Precondition, with the partner's go-ahead before touching cells files: the partner finishes the old 3d-tunnel review, or its old `_pause.md` and `2026-09-25-3d-tunnel-spec-review.md` are moved into `/Users/eliot/code/cells/.claude/dietpowers/trackers/_old/`.
- The partner runs a spec review in cells with the dev companion. Check: each blocker or major is asked before any fix; `Pause here` writes `_pause.md`; a fresh session told "resume" re-asks the question verbatim with the lead-in; the second pass runs only after every item is decided.
- Afterwards, in cells: `git check-ignore -v .claude/dietpowers/trackers/<a tracker file>` names the rule in `.claude/dietpowers/.gitignore`, and `git status --porcelain --untracked-files=all | grep dietpowers` prints nothing. Before this change both fail (verified 2026-09-25: check-ignore exits 1; porcelain lists three files).

Tests: the checks above; this task has no automated test (spec Out of scope: a harness that answers AskUserQuestion).
