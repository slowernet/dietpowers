# Question sequences: consultation, pause and resume, second review pass

Source: first user feedback, `/Users/eliot/code/cells/.claude/dietpowers/problems.md` (three entries dated 2026-09-25, session 7643b94c).

## Goal

Make the question sequences in `dietpowers:review` and `dietpowers:brainstorm` safe to step away from and hard to shortcut:

1. Review puts every blocker and major finding to the partner one at a time. A pause, rejection or unclear answer never licenses the model to decide the rest.
2. Every sequence question offers a pause. A paused sequence can be resumed on request, from disk alone, in a fresh session.
3. The second review pass happens only after every first-pass item is decided. It is scoped to the fixes, runs at most once, and review ends when no blocker or major finding is open.
4. Review history leaves the spec and plan and goes to the pull request.

## Constraints

Later steps copy these values exactly.

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

## Design

### Shared detail file: `skills/review/trackers.md`

A new detail file holds the formats and rules shared by review and brainstorm: the working directory and its `.gitignore`, tracker format, statuses, pause handling, `_pause.md` format and resume procedure. `skills/review/SKILL.md` points to it as `${CLAUDE_SKILL_DIR}/trackers.md`. `skills/brainstorm/SKILL.md` points to it as `${CLAUDE_SKILL_DIR}/../review/trackers.md`. The steps that use these rules stay in each SKILL.md; the detail file holds formats, not steps.

**Tracker format.** The tracker must stand on its own: a fresh session with no conversation must be able to resume from it and the repo alone. The header names:

- the stage and the reviewed document (for brainstorm, the request, and the spec path once written);
- the branch, and for a code review the base commit;
- every value passed to the first reviewer: the prompt file, and whichever of `SPEC_FILE_PATH`, `PLAN_FILE_PATH`, `SPEC_AND_PLAN_PATHS`, `REQUIREMENTS` (verbatim) and `BASE_SHA` apply. The second pass reuses them;
- the commit reviewed (or `uncommitted`), FIX_BASE, FIX_HEAD and the fix commits;
- `Second pass:` with one of the second pass header values, updated when it changes.

Each review item holds:

- a heading `### N. [status] <title> (<severity>, review <1|2>, issue <k>)`, where review 1 is the first review of the run and review 2 its second pass;
- Finding: the failure scenario and the proposed fix, in the reviewer's substance, not a one-line label;
- Verified: file:line, or the calculation;
- Options: the options put to the partner, or `notice only` for a minor finding fixed without asking;
- Decision: a dated list, appended to and never overwritten, of each choice with its reason (the partner's, or the model's for a minor fix);
- Fix: the section or file changed, and the commit (or `uncommitted`);
- Depends on: other items whose change should reopen this one, if any.

Each brainstorm item holds the question, its options exactly as asked, and the answer. Before asking a question that refers to text presented to the partner (the approaches and trade-offs, the design for approval), the model writes that text into the tracker as presented, and the item points to it.

The model updates the tracker after each answer and after each fix. A run is unfinished while any item is `open`, `recheck` or `fix`, or while `Second pass:` is `pending` and no review-2 item exists. Every run of a stage, including a rerun on the same document, starts a new tracker; an unfinished run continues only when the partner names it in a resume request.

Duplicates: in both passes, a finding that matches an item in this tracker, or a closed item in any earlier tracker for the same document (for a code review, the same branch), is marked `duplicate of <tracker file>#N` and not asked. It goes to the partner only when it brings evidence the earlier item did not have, and then with the earlier decision and reason shown. Brainstorm has no duplicate matching.

**Answers during a sequence.** Nothing short of an answer to the current item moves the sequence on, and nothing licenses deciding the remaining items.

- A listed option, or an Other with a usable answer (for example "Zou-He, but only at the outlet"), is an answer.
- `Pause here`, or an Other that says `pause`, pauses.
- A rejected question call pauses with reason `rejected`. The model writes `_pause.md` and stops, with no follow-up question.
- An Other that asks a question back (for example "what is this for?") is not a pause. The model answers it, then asks the same item again.
- An Other that is a complaint, unclear or empty gets one clarifying question, which carries `Pause here`. If the reply still does not answer the item, the model writes `_pause.md` and stops.

**Pausing** writes `_pause.md` with:

- the tracker path, branch, stage (and the skill and document), date and item;
- the item's own question and its options, exactly as asked (never a clarifying question);
- the partner's reason, or `none given`;
- the resume instruction: re-ask the question verbatim with the resume lead-in.

It makes no guess about what the aside affects. When a sequence answers the item `_pause.md` points to, by any route, `_pause.md` is deleted. If `_pause.md` already exists, the new pause overwrites it. The model's message confirming the pause names the pause it replaced (stage and item). The replaced sequence's tracker stays on disk with its open items. After writing the file, the model stops the sequence and tells the partner they can say "resume" at any time.

**Resuming** happens only when the partner asks to resume. No skill checks for `_pause.md` otherwise.

1. If `_pause.md` does not exist, change nothing and report that there is no pause point, with a suggestion: list the trackers on the current branch that are unfinished (as defined above), newest first, which the partner can name to resume. Mention unfinished trackers on other branches by count only. A tracker the partner names is resumed from step 5, at its first unfinished item.
2. Read `_pause.md`. If a field is missing or unreadable, say which and treat it as no pause point (step 1). If the tracker it names is missing, say so and ask whether to drop the pause (delete `_pause.md`). If its stage belongs to the other skill (brainstorm vs the three review stages), invoke that skill to resume.
3. Stale check. If the paused item is no longer `open` or `recheck` in its tracker, or a newer tracker exists for the same document, say the pause is stale and why, and ask: resume the old item anyway, or drop the pause.
4. Branch check. If the recorded branch is not checked out, ask: check it out (recommended), resume on the current branch, or cancel. If the branch no longer exists, say so, and ask whether to resume on the current branch or drop the pause. If a checkout fails, report git's message, change nothing, and ask again without the checkout option.
5. If the item points to presented text in a brainstorm tracker, show that text. Re-ask the recorded question verbatim, led by the resume lead-in.
   - A normal answer continues the pass.
   - An Other that describes a change to the design goes through `dietpowers:update-spec` when a spec exists (for brainstorm, it is folded into the design in progress). The earlier items it touches are marked `recheck`, and the paused question is then asked again.
   - Answers otherwise follow "Answers during a sequence"; `Pause here` pauses again (rewrite `_pause.md`).
6. After an answer, delete `_pause.md` and continue the run: first the `open` and `recheck` items, then the `fix` items, then the second pass if `Second pass: pending`.

### Review (`skills/review/SKILL.md`)

Opening paragraph: drop the "One round of fixes and one re-review" rationale sentence and replace it with the exit rule's rationale in one sentence: a review ends when nothing blocking is open, because a reviewer will always find something.

Description: add "or to resume a paused review" to the trigger clause.

Steps, replacing today's steps 4 to 7 (steps 1 to 3 are unchanged except as noted):

- Step 0 (before step 1): if the partner asked to resume, follow the resume procedure in `${CLAUDE_SKILL_DIR}/trackers.md` and skip to where it leads.
- Step 1 adds: the reviewer grades each finding with the severity grades.
- New step after dispatch: create the tracker, set `Second pass: pending`, then check each finding against the files. Record each one, with its substance and evidence, as an item.
  - A minor finding that holds and has one reasonable fix is marked `fix`. The partner gets a one-line notice per finding (the finding and why it holds) without waiting.
  - Every blocker and major finding goes to the partner one at a time, most severe first, with the recommendation first. So does any finding the model wants to reject, downgrade, or fix in more than one reasonable way, and any fix that changes the approved spec (in a spec review, the approved design). Options are chosen from fix as proposed, an alternative fix, defer, won't fix and reject, at most three plus `Pause here`.
  - The model may raise a grade on its own. It lowers one only by asking.
- Fixing starts only when no item is `open` or `recheck`. Before the first fix, take the FIX_BASE snapshot and record it in the tracker. Fix `fix` items most severe first. A `recheck` item that was already fixed and is now decided differently goes back to `fix`; its fix undoes or replaces the earlier change with a new commit on top, never by rewriting history. Code fixes start with a failing test that reproduces the finding. When a fix to a plan or code would alter behavior the approved spec describes, invoke `dietpowers:update-spec` first. Commit if commits are approved. Mark each item `fixed` with its fix location and commit. If a fix cannot be made (for example, its failing test cannot be made to pass), the item goes back to `open` with the evidence (what was tried, the failing output) and is put to the partner like any other item. After the last fix, take the FIX_HEAD snapshot and record it.
- Second pass, only if anything was fixed; otherwise set `Second pass: not run (nothing fixed)`.
  - Compute the full re-review threshold. At or below it, dispatch a fix check: the same prompt file with FINDINGS (the fixed items' substance), FIX_BASE and FIX_HEAD. Above it, dispatch a full review of the whole target with none of these. When the report arrives, first write its findings to the tracker as `open` review-2 items, then update `Second pass:`.
  - The second reviewer never receives the tracker.
  - Triage the review-2 items as in the first pass, duplicates included.
  - In a fix check, a finding outside the fix diff is recorded as out of scope and put to the partner as an ordinary item, with the reviewer's grade, and defer recommended unless it is a blocker.
  - Decide and fix these items as in the first pass. Dispatch no further review. A severe problem found in a fix is an item for the partner.
- Report, leading with the outcome: what was fixed, deferred, won't-fixed and rejected, with reasons, and anything open. Nothing is appended to the spec or plan.

Terminal state: review is done when no blocker or major item is `open`, `recheck` or `fix`. Recommend continuing only when no blocker or major item is `deferred` either. The continue, revise and stop menus are otherwise unchanged. A revise run is a new run with a new tracker.

### Reviewer prompts

- `spec-reviewer.md` and `plan-reviewer.md` each add a `Severity: [blocker|major|minor]` line to the finding format, with the yardstick sentence and "Name the failure scenario that justifies the grade."
- `code-reviewer.md` keeps its CRITICAL/HIGH/MEDIUM/LOW scale. The mapping to blocker/major/minor is applied by the review skill, and recorded in `trackers.md`.
- In all three, the sentence "If it also supplied FINDINGS, this is a re-review: check only whether each of those findings is fixed, and whether the fixes broke anything." is replaced by a fix-check mode. If FINDINGS, FIX_BASE and FIX_HEAD are supplied, read `git diff [FIX_BASE] [FIX_HEAD]`, which includes files that were untracked. Check only whether each finding is fixed and whether the diff broke anything it touches. Report anything noticed outside the diff under a separate `Out of scope` heading, not as an ISSUE, with the same severity line (for code, the same severity scale) as an ISSUE. The code fix check still runs the full test suite once and reports failures as ISSUEs.

### Brainstorm (`skills/brainstorm/SKILL.md`)

- Description: add "or to resume a paused brainstorm".
- New first step: if the partner asked to resume, follow the resume procedure in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker (stage `brainstorm`, topic chosen now and reused for the spec filename). Every question in the sequence ends with `Pause here`, and answers and pauses follow `trackers.md`. The tracker records each question, its options and the answer, and the approaches and the design as presented, before the questions that refer to them.
- The commit-approval question and the design-approval question also carry `Pause here`.
- Both review and brainstorm SKILL.md end with a `Depth:` line naming the tracker file (`trackers.md` in review, `../review/trackers.md` in brainstorm), as `AGENTS.md` requires for detail files.

### Finish branch (`skills/finish-branch/SKILL.md`)

- Step 6's "review findings fixed, and findings rejected with the reason" bullet becomes: from the review trackers in `.claude/dietpowers/trackers/` (skip `_` files) whose header names this branch's spec or plan (from the plan's `Spec:` line and the plan's path), plus code-review trackers that name this branch and its base commit: each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- Local merge: the merge commit message stays an ordinary summary. It mentions the review process only for items whose Decision list has more than one entry.
- Trackers are never deleted by any skill.

### Other files

- `README.md`: update the change notes for review, brainstorm and finish-branch, and note trackers and pausing. Also bring every description of the old loop in line with the second-pass rule: the three flow-diagram lines ending `hostile review; fix; one re-review` (and `hostile review of the branch; fix; one re-review`), the bullet containing `One re-review checks only the fixes`, and the change note `Runs one scoped re-review, then stops.`
- `tests/skills/check-skills.sh`: add the assertions listed under Success criteria.

## Inputs and failure behavior

- **Partner answers**: a listed option, Other text, or a rejected call. Handled as in "Answers during a sequence".
- **Resume with no `_pause.md`, or a malformed one**: resume steps 1 and 2; nothing changes on disk.
- **Tracker referenced by `_pause.md` missing**: resume step 2.
- **Stale pause**: resume step 3.
- **Recorded branch missing, not checked out, or checkout fails**: resume step 4. The model never checks out a branch without the partner choosing it.
- **Untracked files** (commits held back): snapshots include them, so the fix diff and the threshold see them.
- **Snapshot fails or is gone** (no id printed, for example in a repo with no index yet; or pruned by `git gc` before a late resume): report it and dispatch the full re-review, since the fix diff is unknown.
- **Topic collision** (a tracker with the same name for a different document or run): append `-2`, `-3` and so on.
- **Writing `.claude/dietpowers/` fails** (read-only filesystem): report it and continue the sequence without a tracker. Pause then has nowhere to go, so `Pause here` is left off, and the partner is told why.
- **Second reviewer fails or returns nothing usable**: report it. The first-pass decisions stand, and review ends with `Second pass: not run (<reason>)`.
- **Session dies mid-run without a pause**: the tracker shows the run is unfinished; resume step 1 lists it, and naming it in a resume request continues it.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0.
2. `check-skills.sh` asserts, and passes on the result:
   - `skills/review/SKILL.md`, `skills/brainstorm/SKILL.md` and `skills/review/trackers.md` contain `Pause here`;
   - no file under `skills/` contains `Review notes`;
   - `skills/review/spec-reviewer.md` and `plan-reviewer.md` contain `Severity: [blocker|major|minor]`;
   - `skills/review/trackers.md` exists and contains `_pause.md`, `.gitignore` and `Resuming at`;
   - all three reviewer prompts contain `FIX_BASE` and `FIX_HEAD`, and none contains `this is a re-review`;
   - `skills/review/SKILL.md` and `skills/brainstorm/SKILL.md` each have a `Depth:` line naming `trackers.md`.
3. Manual trial on the cells repo with the dev companion, recorded as problems.md entries or their absence.
   - Precondition: the partner has finished the old 3d-tunnel review, or its old-format `_pause.md` and tracker have been moved into `.claude/dietpowers/trackers/_old/` by hand with the partner's go-ahead. No skill does this.
   - A spec review with at least one blocker or major finding asks each one before any fix. Choosing `Pause here` writes `_pause.md`. A fresh session asked to "resume" re-asks the question verbatim with the lead-in. The second pass runs only after every item is decided.
   - Afterwards, `git check-ignore -v` on a tracker path names the rule in `.claude/dietpowers/.gitignore`, and `git status --porcelain --untracked-files=all` lists nothing under `.claude/dietpowers/`. Before the change, both fail in cells.

## Assumptions

- Only brainstorm and review run question sequences. Other skills' one-off questions don't get `Pause here`.
- `${CLAUDE_SKILL_DIR}/../review/trackers.md` resolves in an installed plugin, because skills sit side by side under the plugin's `skills/` directory.
- Severity mapping for code: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Deferring a blocker or major is allowed, but the terminal state then doesn't recommend continuing.
- Resuming from a named tracker without `_pause.md` asks the first unfinished item from its recorded options, or fresh if none were recorded.
- Fixes for minor findings run with the rest, after every item is decided.
- A fix check dispatches a `general-purpose` subagent on the same model, the same way as the first review.

## References

- `/Users/eliot/code/cells/.claude/dietpowers/problems.md`: the partner's agreed points 1 to 6 (pause option, trackers, gitignore, PR record, self-contained trackers, single `_pause.md`) and the model's re-review proposals.
- `skills/review/SKILL.md` steps 4 to 7 (commit 995ca81): the "notice, not a question" rule, the single re-review with FINDINGS, and the `Review notes` append being replaced.
- `skills/review/spec-reviewer.md`, `plan-reviewer.md`, `code-reviewer.md`: the FINDINGS re-review sentence. `code-reviewer.md` Severity Guide: the CRITICAL/HIGH/MEDIUM/LOW definitions.
- `skills/finish-branch/SKILL.md` step 6: the PR description bullets.
- `AGENTS.md`: detail goes in separate files that SKILL.md points to; `${CLAUDE_SKILL_DIR}` usage; the published plugin has no hook.
- git-write-tree(1): writes a tree object from the index named by `GIT_INDEX_FILE`; git(1): `GIT_INDEX_FILE` selects an alternate index file. `git rev-parse --git-path index` gives the real index's path, also in worktrees.
- git-gc(1) and `gc.pruneExpire` (git-config(1)): unreachable objects older than the expiry (default `2.weeks.ago`) are pruned.
- `git stash create` was considered and rejected: it ignores untracked files and prints nothing on a tree whose only changes are untracked.
- Self-ignoring directory: a `.gitignore` containing `*` inside the directory, as pytest writes in `.pytest_cache/` and `python -m venv` writes in the venv since Python 3.13.
- Google engineering practices, "The Standard of Code Review": approve once a change definitely improves overall code health, even if it isn't perfect. https://google.github.io/eng-practices/review/reviewer/standard.html
- IEEE 1028 and Fagan inspection: rework is verified by the moderator; re-inspection happens only when rework is large. The 5 to 10% threshold is commonly cited but not from a single primary source.

## Out of scope

- A SessionStart hook in the published plugin.
- Pause support in skills other than brainstorm and review, including handle-feedback's single question.
- Changing the code reviewer's own severity scale.
- Follow-up: a behavioral test harness that can answer AskUserQuestion, so criterion 3 can be automated.
