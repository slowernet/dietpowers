# Question sequences: implementation plan

Spec: docs/dietpowers/2026-09-25-question-sequences-spec.md @ 12f54ee
Base: main
Commits: approved

Goal: plain-text questions in every skill; review asks about every blocker and major finding and records a pausable, resumable tracker; one fix check after all decisions; review history to the PR; code steps always commit on the feature branch.

Architecture: text changes to the ten `SKILL.md` files, the three reviewer prompts and `README.md`, plus one new detail file, `skills/review/trackers.md`, which review and brainstorm point to. `tests/skills/check-skills.sh` is the test: each task adds its assertions there first, sees them fail, then makes the change.

## Global Constraints

Copied verbatim from the spec.

- Question ending: every question ends with a line naming its answers. On a tracker item (a brainstorm question or a review finding): `Reply with <a>, <b>, or pause.` On any other question: `Reply with <a> or <b>.` (or `<a>, <b>, or <c>`). Fixed questions get these endings: the commit question `Reply with yes or no.`; finish-branch's menus `Reply with 1, 2, or 3.` (detached HEAD: `Reply with 1 or 2.`) in place of `Which option?`; review's terminal question `Reply with continue, revise, or stop.`; execute-plan's `Reply with yes or no.`; handle-feedback's push question `Reply with yes or no.`
- Resume lead-in: `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.`
- Working directory: `.claude/dietpowers/` at the root of the git work tree. When the model creates it, it writes `.claude/dietpowers/.gitignore` containing the single line `*`, and writes that file if the directory exists without it.
- Tracker path: `.claude/dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`. `<stage>` is `brainstorm`, `spec-review`, `plan-review` or `code-review`. `<topic>` is the topic in the spec's filename (`YYYY-MM-DD-<topic>-spec.md`); for another filename, its name stem; for a code review with no spec, the branch name with `/` replaced by `-`. On a detached HEAD there is no tracker (see Working directory). If the name is taken, append `-2`, `-3` and so on to the topic. Every run of a stage gets a new tracker.
- Severity grades: `blocker`, `major`, `minor`. Yardstick for specs and plans: "Would the plan or the code go wrong, or have to guess, if this stayed?" Yes means blocker or major; no means minor. Code reviewer mapping: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Review item statuses: `open` (awaiting a decision), `fix` (decided, awaiting the fix), `fixed`, `deferred`, `won't fix`, `rejected`, `duplicate of N`. Brainstorm item statuses: `open`, `answered`.
- `Second pass:` values (review trackers only): `pending`, `done (N findings)`, `not run (<reason>)`.
- Reviewer dispatches per review run: at most two (the first review and one fix check).
- The published plugin stays hook-free.

## References

- The spec is the source for wording; each task names the spec sections it implements, and restates only what an executor could get wrong.
- `AGENTS.md`: SKILL.md anatomy (title; optional opening; numbered steps, optionally under headings; terminal-state line; `Depth:` line where detail files exist); detail in separate files; `dietpowers:<name>` for other skills; `${CLAUDE_SKILL_DIR}/<file>` for own files; skill and reviewer prompts follow the Opus 5.5 prompting guide (https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), not AGENTS.md's report-style rules; a `description` says what the skill produces and when, never a summary of its steps.
- `skills/tdd/SKILL.md:29`: `Depth: writing-good-tests.md, ../find-root-cause/condition-based-waiting.md`, the precedent for `Depth:` and for a `../` sibling path.
- `tests/skills/check-skills.sh`: `fail()` prints `FAIL: ...` and sets `FAIL=1`; the script ends with `[ "$FAIL" -eq 0 ] && echo "PASS: ..."; exit "$FAIL"`. New assertions go before that block. Run: `bash tests/skills/check-skills.sh`.
- The shared question paragraph, identical in all ten SKILL.md files: "Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it."
- The shared commit paragraph, in brainstorm, write-plan, review, execute-plan, tdd, find-root-cause, handle-feedback, update-spec and prove-done: "Before your first commit for this piece of work, check the plan's `Commits:` line or your partner's earlier answer. If neither settles it, ask once: "I'll work on branch `<name>`. May I commit to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, commits are held back: ..." finish-branch has no commit paragraph.
- Fixed questions today: review terminal "Continue with write-plan?", "Continue with execute-plan?", "Continue to finishing?" (`skills/review/SKILL.md:24-26`); execute-plan "Continue with code review?" (line 24); handle-feedback "Push the fixes and post these replies?" (step 11); finish-branch menus ending `Which option?` (lines 35, 46).
- Commit clauses today: execute-plan step 4 "commit if commits are approved"; tdd, find-root-cause terminal states "commit the change and its tests if commits are approved"; handle-feedback step 9 "Commit each fix with its test if commits are approved"; prove-done step 3; review steps 2 and 5; update-spec step 6; finish-branch step 3 (proposal with `git apply --cached`).
- Reviewer prompts: each opens with "The agent that sent you supplies the values ... If it also supplied FINDINGS, this is a re-review: check only whether each of those findings is fixed, and whether the fixes broke anything." `spec-reviewer.md` findings have `Section:` and `Check:` lines; `plan-reviewer.md` has `Task:` and `Check:`; `code-reviewer.md` reports `### BUG N` with CRITICAL/HIGH/MEDIUM/LOW (Severity Guide), and its "What to Review" and Process step 1 scope the review to every change since `BASE_SHA` and run the test suite once.

## Tasks

### - [x] Task 1: Plain-text questions in every skill

Files: modify all ten `skills/*/SKILL.md`; modify `tests/skills/check-skills.sh`.

Context: spec "Plain-text questions (all skills)"; Global Constraints (question ending); References (shared question paragraph, fixed questions).

Behavior:
- Replace the shared question paragraph in every SKILL.md with one paragraph, identical in all ten, saying: ask one question at a time, in plain text, in a single message; state the problem and why it matters; give the options, recommended first, each with a one-line reason; end with a line `Reply with ...` naming the answers; do not use the AskUserQuestion tool, because some clients show only the question and drop the text around it; the partner may answer with an option, their own alternative, a question or an aside; put the question last in the message, after any tool use.
- Give each fixed question its ending from Global Constraints: review's terminal question (one question with `Reply with continue, revise, or stop.`), execute-plan's, handle-feedback's, and the commit question (`Reply with yes or no.`). finish-branch's two menus end `Reply with 1, 2, or 3.` and `Reply with 1 or 2.` in place of `Which option?`; drop step 4's "Without the question tool, print it exactly as written" clause and say the menu is printed as written.
- `pause` appears only where Tasks 5 and 6 add it; this task adds no `pause`.

Tests (new block in check-skills.sh):
- `no file under skills/ contains "with the AskUserQuestion tool:"` (the old paragraph's text; the new paragraph may name the tool) — fails if any skill keeps the old paragraph.
- `every SKILL.md contains Reply with` — fails if a skill is missed.
- `no file under skills/ contains Which option?` — fails if a finish-branch menu keeps the old ending.

### - [x] Task 2: Commits in the code steps

Files: modify `skills/execute-plan/SKILL.md`, `skills/tdd/SKILL.md`, `skills/find-root-cause/SKILL.md`, `skills/handle-feedback/SKILL.md`, `skills/prove-done/SKILL.md`, `skills/review/SKILL.md`, `skills/update-spec/SKILL.md`, `skills/write-plan/SKILL.md`, `skills/finish-branch/SKILL.md`; modify `tests/skills/check-skills.sh`.

Context: spec "Commits in the code steps" (including its Changed note); References (shared commit paragraph, commit clauses).

Behavior:
- execute-plan, tdd, find-root-cause, handle-feedback: replace the commit paragraph with the code-step rule, worded identically in all four: commit on the feature branch as you go, never on `main`, `master` or the plan's `Base:` branch; if you are on one of those, ask once `I'll create branch <name> for this work. Reply with yes or no.`; if your partner declines, do no code work until a branch is agreed. Their commit clauses become unconditional ("commit ...").
- prove-done: remove the commit paragraph and step 3's commit clause; code it fixes goes through `dietpowers:tdd`.
- review: its commit paragraph states both rules, using the phrase `code-step rule`: fixes in a code review follow the code-step rule; fixes in a spec or plan review follow the document rule (the existing commit question and held-back mode). Step 2 splits the same way.
- brainstorm, write-plan, update-spec and review's document rule: keep the document commit paragraph, adding that whatever the answer, the work moves to the named feature branch and declining holds back commits only. write-plan's header description says `Commits:` covers the spec and plan only.
- update-spec: step 6 says that when document commits are held back, spec and plan edits stay on disk even though the code change is committed; otherwise they are committed with the code change.
- finish-branch step 3: the proposal covers only a held-back spec and plan (spec first, then plan); remove the per-task commits and the `git apply --cached` splitting.
- Keep Task 1's `Reply with yes or no.` on every remaining commit question.

Tests (new block):
- `execute-plan, tdd, find-root-cause, handle-feedback and prove-done SKILL.md do not contain "if commits are approved"` — fails if a code step keeps the conditional.
- `review SKILL.md contains code-step rule` — fails if review keeps a single rule.
- `finish-branch SKILL.md does not contain git apply --cached` — fails if the per-task split survives.
- `update-spec SKILL.md contains "even though the code change is committed"` — fails if the new held-back rule for spec edits is dropped (the phrase is absent today).

### - [x] Task 3: Shared detail file `skills/review/trackers.md`

Files: create `skills/review/trackers.md` (imitate `skills/find-root-cause/root-cause-tracing.md`: a detail file with headings, no frontmatter); modify `tests/skills/check-skills.sh`.

Interfaces: produces the headings `## Working directory`, `## Tracker format`, `## Replies`, `## Resuming`, which Tasks 5 and 6 name when they point in.

Context: spec "Shared detail file" and "Inputs and failure behavior"; Global Constraints (working directory, tracker path, statuses, `Second pass:` values, resume lead-in).

Behavior:
- `## Working directory`: `.claude/dietpowers/` and its `.gitignore` (`*`); no tracker, and no pause, when it can't be written, outside a git work tree, or on a detached HEAD, and the partner is told.
- `## Tracker format`: the path rule with its topic fallbacks and `-2` suffix; review header fields (stage, document, branch, first-reviewer values with `REQUIREMENTS` verbatim, `FIX_BASE` for code, `Second pass:`); brainstorm header (`Spec:` empty until the spec is saved, no `Second pass:`); repo-relative paths; the review item fields and brainstorm item fields as in the spec; statuses; approval text written before its question; one filled example review item.
- `## Replies`: `pause` only on tracker items; answers, non-answers (respond, then ask the same item again), `pause` (item stays `open`, say `Paused at item <N>. Say "resume" any time.`, stop); an empty or unclear reply is not an answer, so ask again; nothing but an answer moves on, nothing licenses deciding the rest.
- `## Resuming`: the rules in the spec's Resuming bullet, in its order, with the lead-in copied exactly; plus, for an unreadable tracker or one with missing fields, say which field and ask whether to continue with what is readable or leave the tracker.

Tests (new block):
- `trackers.md exists and contains .gitignore, Resuming, pause, Resuming <tracker file> at item <N>` — fails if the file is missing or the lead-in is reworded.
- `trackers.md contains the four headings` — fails if a heading Tasks 5 and 6 point to is renamed.

### - [x] Task 4: Reviewer prompts

Files: modify `skills/review/spec-reviewer.md`, `skills/review/plan-reviewer.md`, `skills/review/code-reviewer.md`; modify `tests/skills/check-skills.sh`.

Interfaces: consumes `FINDINGS` and, for code, `FIX_BASE` (a commit), supplied by Task 5.

Context: spec "Reviewer prompts"; Global Constraints (severity grades).

Behavior:
- All three: replace the "If it also supplied FINDINGS, this is a re-review ..." sentence with the fix check: check only whether each finding is fixed and whether its fix broke anything it touches; report anything else under an `Out of scope` heading, graded like a finding.
- spec and plan prompts: add `Severity: [blocker|major|minor]` after `Check:` in the finding format, with the yardstick and "Name the failure scenario that justifies the grade."
- code prompt: in a fix check, the scope in "What to Review" and Process step 1 becomes `git diff [FIX_BASE] HEAD`; the test suite still runs once and a failure is a `BUG`; `Out of scope` entries use the CRITICAL/HIGH/MEDIUM/LOW scale; the Severity Guide is unchanged.

Tests (new block):
- `spec-reviewer.md and plan-reviewer.md contain Severity: [blocker|major|minor]`.
- `all three prompts contain Out of scope and none contains "this is a re-review"`.
- `code-reviewer.md contains git diff [FIX_BASE] HEAD` — fails if the fix-check scope is missing.

### - [x] Task 5: Review skill steps

Files: modify `skills/review/SKILL.md`; modify `tests/skills/check-skills.sh`.

Interfaces: consumes `${CLAUDE_SKILL_DIR}/trackers.md` headings (Task 3) and the prompt placeholders (Task 4); keeps Task 1's paragraph and endings and Task 2's commit paragraph.

Context: spec "Review", "Inputs and failure behavior"; Global Constraints.

Behavior:
- Description adds "or to resume a paused review"; frontmatter stays under 1024 characters.
- Opening: the "One round of fixes and one re-review ..." sentence becomes: review ends when nothing blocking is open, because a reviewer will always find something.
- Steps, in order: resume (follow `## Resuming` in `${CLAUDE_SKILL_DIR}/trackers.md`); steps 1 to 3 as today, step 1 adding that the reviewer grades each finding; write the tracker, following `## Working directory` and `## Tracker format` in `${CLAUDE_SKILL_DIR}/trackers.md`, with every finding as an unchecked `open` item and `Second pass: pending`; check each and record the evidence; minor with one fix → `fix` plus a one-line notice; blockers, majors and the other asked cases → one at a time, most severe first, each ending `Reply with <options>, or pause.`, replies per `## Replies`; fixing when nothing is `open`, recording `FIX_BASE` first for code, failed fix back to `open` with evidence; the fix check (or `not run (nothing fixed)`), review-2 items and `Second pass: done (N findings)` in one write, review-2 minors by the notice rule, `duplicate of N`, out-of-scope items with defer recommended unless a blocker, `not run (<reason>)` on failure, never dispatch again; report leading with the outcome, nothing appended to the spec or plan.
- Terminal state: done when no blocker or major is `open` or `fix`; recommend continuing only when none is `deferred`; `Reply with continue, revise, or stop.`; a revise run gets a new tracker.
- End with `Depth: trackers.md`.

Tests (new block):
- `review SKILL.md contains pause, ## Tracker format and Depth: trackers.md`.
- `no file under skills/ contains Review notes`.
- `review SKILL.md contains Second pass and does not contain "a notice, not a question" or "Dispatch no third review"` — fails if old steps 4 or 6 survive.

### - [x] Task 6: Brainstorm skill

Files: modify `skills/brainstorm/SKILL.md`; modify `tests/skills/check-skills.sh`.

Interfaces: consumes `${CLAUDE_SKILL_DIR}/../review/trackers.md` headings (Task 3).

Context: spec "Brainstorm"; References (`skills/tdd/SKILL.md:29`).

Behavior:
- Description adds "or to resume a paused brainstorm".
- First step: if the partner asked to resume, follow `## Resuming` in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker following `## Working directory` and `## Tracker format` in `${CLAUDE_SKILL_DIR}/../review/trackers.md` (stage `brainstorm`, topic reused for the spec filename). Each design question ends `Reply with <options>, or pause.` Record each question and answer, and the approaches and design before asking about them. Fill in the `Spec:` line when the spec is saved.
- End with `Depth: ../review/trackers.md`.

Tests (new block):
- `brainstorm SKILL.md contains pause, ## Tracker format and a Depth: line naming ../review/trackers.md`.
- `[ -f skills/brainstorm/../review/trackers.md ]` — fails if the pointer target moves.

### - [x] Task 7: Finish branch: review record

Files: modify `skills/finish-branch/SKILL.md`; modify `tests/skills/check-skills.sh`.

Context: spec "Finish branch".

Behavior:
- Step 6's review bullet: from the trackers in `.claude/dietpowers/trackers/` whose header names this branch, each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- Local merge (step 5): before its `cd`, read this branch's trackers from `$WORKTREE_PATH/.claude/dietpowers/trackers/` (captured in step 2) and keep the deferred, won't-fix and rejected findings; the final report lists them, one line each, after cleanup.
- State that no skill deletes a tracker directly, and that removing a worktree removes its trackers.

Tests (new block):
- `finish-branch SKILL.md contains .claude/dietpowers/trackers/`.
- `finish-branch SKILL.md does not contain "findings rejected with the reason"` — fails if the old bullet survives.

### - [ ] Task 8: README

Files: modify `README.md`; modify `tests/skills/check-skills.sh`.

Context: spec "Other files".

Behavior:
- Bring in line every passage the spec lists: the flow-diagram lines ending `fix; one re-review`; the bullet containing `One re-review checks only the fixes`; `Runs one scoped re-review, then stops.`; the change note beginning `Reports outcome first and appends rejected findings`, including `(one fresh review of the revision)`; the bullet `Questions come one at a time,`; the sentences beginning `Every skill that asks you anything gained the same rule`, `Every skill that commits asks once` and `Committing needs your approval once per piece of work`; finish-branch's change notes `(spec and plan, then one per plan task, splitting shared files by task)` and the PR-description note mentioning review findings.
- Add change notes: plain-text questions, trackers (`.claude/dietpowers/`, self-ignoring), pause and resume, the PR record, commits in the code steps.
- New wording must avoid the three strings the test bans.

Tests (new block):
- `README.md contains none of "one re-review", "section in the spec or plan", "multiple choice", "splitting shared files by task"`.

### - [ ] Task 9: Manual trial on cells

Files: none in this repo; results go to `/Users/eliot/code/cells/.claude/dietpowers/problems.md`, or their absence is noted on this task.

Context: spec "Success criteria" 2; `AGENTS.md` (load with `--plugin-dir /path/to/dietpowers --plugin-dir /path/to/dietpowers/dev`).

Behavior:
- Precondition, with the partner's go-ahead before touching cells files: finish the old 3d-tunnel review, or move its `_pause.md` and `2026-09-25-3d-tunnel-spec-review.md` into `/Users/eliot/code/cells/.claude/dietpowers/trackers/_old/`.
- The partner runs a spec review in cells. Check each item in success criterion 2.
- Afterwards in cells: `git check-ignore -v .claude/dietpowers/trackers/<a tracker>` names `.claude/dietpowers/.gitignore`; `git status --porcelain --untracked-files=all | grep dietpowers` prints nothing. Before this change both fail (checked 2026-09-25).

Tests: the checks above; no automated test (spec Out of scope).
