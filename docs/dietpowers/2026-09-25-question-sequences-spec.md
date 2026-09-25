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
- Tracker path: `.claude/dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`. `<stage>` is one of `brainstorm`, `spec-review`, `plan-review`, `code-review`. `<topic>` is the kebab-case topic of the spec (for a spec or plan review, the `<topic>` in the spec's filename). The date is the day the tracker was created.
- Pause file path: `.claude/dietpowers/trackers/_pause.md`. There is at most one. Files in `trackers/` whose names start with `_` are never trackers.
- Severity grades: `blocker`, `major`, `minor`. Yardstick for specs and plans: "Would the plan or the code go wrong, or have to guess, if this stayed?" Yes means blocker or major; no means minor. Code reviewer mapping: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Review item statuses: `open`, `fix`, `fixed`, `deferred`, `won't fix`, `rejected`, `duplicate of N`, `recheck`. Brainstorm question statuses: `open`, `answered`.
- Full re-review threshold: the fix diff changes more than 10% of the reviewed material. For a spec or plan, (added + deleted lines in the fix diff of that file) / (the file's line count before the fixes). For code, (added + deleted lines in the fix diff) / (added + deleted lines in `git diff <BASE_SHA>` before the fixes). Both counts come from `git diff --numstat`.
- Reviewer dispatches per review run: at most two (the first review, then one fix check or one full re-review).
- The published plugin stays hook-free.

## Design

### Shared detail file: `skills/review/trackers.md`

A new detail file holds the formats and rules shared by review and brainstorm: the working directory and its `.gitignore`, tracker format, statuses, pause handling, `_pause.md` format and resume procedure. `skills/review/SKILL.md` points to it as `${CLAUDE_SKILL_DIR}/trackers.md`. `skills/brainstorm/SKILL.md` points to it as `${CLAUDE_SKILL_DIR}/../review/trackers.md`. The steps that use these rules stay in each SKILL.md; the detail file holds formats, not steps.

**Tracker format.** The header names the stage, the reviewed document (or, for brainstorm, the request), the branch, and the review commits (for a review: the commit reviewed, FIX_BASE, the fix commits). The tracker must stand on its own: a fresh session with no conversation must be able to resume from it and the repo alone. Each review item holds:

- a heading `### N. [status] <title> (<severity>, review <1|2>, issue <k>)`;
- Finding: the failure scenario and the proposed fix, in the reviewer's substance, not a one-line label;
- Verified: file:line, or the calculation;
- Options: the options put to the partner, or `notice only` for a minor finding fixed without asking;
- Decision: the partner's choice and reason, or the model's reason for a minor fix;
- Fix: the section or file changed, and the commit (or `uncommitted`);
- Depends on: other items whose change should reopen this one, if any.

Each brainstorm item holds the question, its options exactly as asked, and the answer.

The model updates the tracker after each answer and after each fix. A re-run of the same stage on the same document reuses the existing tracker (matched by topic and stage, most recent date) instead of creating a new one.

**Answers during a sequence.** A choice of a listed option is an answer. An Other with a usable answer (for example "Zou-He, but only at the outlet") is an answer. The following are pauses: `Pause here`; a rejected question call; Other text that is a complaint, a question back, unclear, or the word `pause`. After a pause from Other or a rejected call, the model asks one question about what the partner meant, whose options include `Pause here`. Nothing short of an answer to the current item moves the sequence on. A pause never licenses deciding the remaining items.

**Pausing** writes `_pause.md` with:

- the tracker path, branch, stage (and the skill and document), date and item;
- the question and its options, exactly as asked;
- the partner's reason, or `none given`;
- the resume instruction: re-ask the question verbatim with the resume lead-in.

It makes no guess about what the aside affects. If `_pause.md` already exists, the new pause overwrites it. The model's message confirming the pause names the pause it replaced (stage and item). The replaced sequence's tracker stays on disk with its open items. After writing the file, the model stops the sequence and tells the partner they can say "resume" at any time.

**Resuming** happens only when the partner asks to resume. No skill checks for `_pause.md` otherwise.

1. If `_pause.md` exists, read it. If its stage belongs to the other skill (brainstorm vs the three review stages), invoke that skill to resume.
2. If the recorded branch is not checked out, ask: check it out (recommended), resume on the current branch, or cancel. If the branch no longer exists, say so, and ask whether to resume on the current branch or drop the pause (delete `_pause.md`, keep the tracker).
3. Re-ask the recorded question verbatim, led by the resume lead-in.
   - A normal answer continues the pass.
   - An Other that describes a change to the design goes through `dietpowers:update-spec` when a spec exists (for brainstorm, it is folded into the design in progress). The earlier items it touches are marked `recheck`, and the paused question is then asked again.
   - `Pause here` pauses again (rewrite `_pause.md`).
4. After an answer, delete `_pause.md` and continue from the first `open` or `recheck` item in the tracker.
5. If `_pause.md` does not exist (a session crashed mid-pass), look for trackers in `trackers/` (skipping `_` files) that have `open` or `recheck` items. With one, resume at its first such item, re-asking from the item's recorded options if present; otherwise ask the item fresh. With several, ask which, most recently modified first (at most three real options plus `Pause here`). With none, say there is nothing to resume.

### Review (`skills/review/SKILL.md`)

Opening paragraph: drop the "One round of fixes and one re-review" rationale sentence and replace it with the exit rule's rationale in one sentence: a review ends when nothing blocking is open, because a reviewer will always find something.

Description: add "or to resume a paused review" to the trigger clause.

Steps, replacing today's steps 4 to 7 (steps 1 to 3 are unchanged except as noted):

- Step 0 (before step 1): if the partner asked to resume, follow the resume procedure in `${CLAUDE_SKILL_DIR}/trackers.md` and skip to where it leads.
- Step 1 adds: the reviewer grades each finding with the severity grades.
- New step after dispatch: create or reuse the tracker, then check each finding against the files. Record each one, with its substance and evidence, as an item.
  - A minor finding that holds and has one reasonable fix is marked `fix`. The partner gets a one-line notice per finding (the finding and why it holds) without waiting.
  - Every blocker and major finding goes to the partner one at a time, most severe first, with the recommendation first. So does any finding the model wants to reject, downgrade, or fix in more than one reasonable way, and any fix that changes the approved spec (in a spec review, the approved design). Options are chosen from fix as proposed, an alternative fix, defer, won't fix and reject, at most three plus `Pause here`.
  - The model may raise a grade on its own. It lowers one only by asking.
- Fixing starts only after every item is out of `open`. Before the first fix, record FIX_BASE: `git rev-parse HEAD` if the tree is clean, else the output of `git stash create`. Fix `fix` items most severe first. Code fixes start with a failing test that reproduces the finding. When a fix to a plan or code would alter behavior the approved spec describes, invoke `dietpowers:update-spec` first. Commit if commits are approved. Mark each item `fixed` with its fix location and commit.
- Second pass, only if anything was fixed.
  - Compute the full re-review threshold. At or below it, dispatch a fix check: the same prompt file with FINDINGS (the fixed items' substance) and FIX_BASE. Above it, dispatch a full review of the whole target with neither.
  - The second reviewer never receives the tracker.
  - Triage its findings into the same tracker as `review 2` items. A finding matching a closed item is marked `duplicate of N` and not asked. It goes to the partner only when it brings evidence the earlier item did not have, and then with the earlier decision and reason shown.
  - In a fix check, a finding outside the fix diff is recorded as out of scope and put to the partner as an ordinary item, with defer recommended unless it is a blocker.
  - Decide and fix these items as in the first pass. Dispatch no further review. A severe problem found in a fix is an item for the partner.
- Report, leading with the outcome: what was fixed, deferred, won't-fixed and rejected, with reasons, and anything open. Nothing is appended to the spec or plan.

Terminal state: review is done when no blocker or major item is `open` or `recheck`. Recommend continuing only when no blocker or major item is `deferred` either. The continue, revise and stop menus are otherwise unchanged. A revise run reuses the same tracker.

### Reviewer prompts

- `spec-reviewer.md` and `plan-reviewer.md` each add a `Severity: [blocker|major|minor]` line to the finding format, with the yardstick sentence and "Name the failure scenario that justifies the grade."
- `code-reviewer.md` keeps its CRITICAL/HIGH/MEDIUM/LOW scale. The mapping to blocker/major/minor is applied by the review skill, and recorded in `trackers.md`.
- In all three, the sentence "If it also supplied FINDINGS, this is a re-review: check only whether each of those findings is fixed, and whether the fixes broke anything." is replaced by a fix-check mode. If FINDINGS and FIX_BASE are supplied, read `git diff [FIX_BASE]` (plus `git status --porcelain` for new files). Check only whether each finding is fixed and whether the diff broke anything it touches. Report anything noticed outside the diff under a separate `Out of scope` heading, not as an ISSUE.

### Brainstorm (`skills/brainstorm/SKILL.md`)

- Description: add "or to resume a paused brainstorm".
- New first step: if the partner asked to resume, follow the resume procedure in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker (stage `brainstorm`, topic chosen now and reused for the spec filename). Every question in the sequence ends with `Pause here`, and pause handling follows `trackers.md`. The tracker records each question, its options and the answer.
- The commit-approval question and the design-approval question also carry `Pause here`.

### Finish branch (`skills/finish-branch/SKILL.md`)

- Step 6's "review findings fixed, and findings rejected with the reason" bullet becomes: from every tracker in `.claude/dietpowers/trackers/` whose header names this branch (skip `_` files), each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- Local merge: the merge commit message stays an ordinary summary. It mentions the review process only when an item took more than one round with the partner (a `recheck`, or a decision changed after a pause).
- Trackers are never deleted by any skill.

### Other files

- `README.md`: update the change notes for review, brainstorm and finish-branch, and note trackers and pausing.
- `tests/skills/check-skills.sh`: add the assertions listed under Success criteria.

## Inputs and failure behavior

- **Partner answers**: a listed option, Other text, or a rejected call. Handled as in "Answers during a sequence". An empty Other is unclear, so it is a pause.
- **`_pause.md` malformed or missing fields**: say which field is missing, then fall back to the crashed-pass lookup in resume step 5.
- **Tracker referenced by `_pause.md` missing**: say so, delete `_pause.md` after the partner confirms, and offer to start the stage fresh.
- **Recorded branch missing or not checked out**: resume step 2. The model never checks out a branch without the partner choosing it.
- **`git stash create` prints nothing** (clean tree): use `git rev-parse HEAD`. It does not capture untracked files, so the fix check also reads `git status --porcelain`.
- **Untracked new files in code fixes**: they don't appear in `git diff --numstat`. For the threshold, count each new file's full line count as added lines.
- **Topic collision** (a tracker for a different feature with the same topic and stage): the date prefix separates different days. On the same day, reuse happens only if the tracker header names the same document; otherwise append `-2` to the topic.
- **Writing `.claude/dietpowers/` fails** (read-only filesystem): report it and continue the sequence without a tracker. Pause then has nowhere to go, so `Pause here` is left off, and the partner is told why.
- **Second reviewer fails or returns nothing usable**: report it. The first-pass decisions stand, and review ends with the second pass recorded as not run.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0.
2. `check-skills.sh` asserts, and passes on the result:
   - `skills/review/SKILL.md`, `skills/brainstorm/SKILL.md` and `skills/review/trackers.md` contain `Pause here`;
   - no file under `skills/` contains `Review notes`;
   - `skills/review/spec-reviewer.md` and `plan-reviewer.md` contain `Severity: [blocker|major|minor]`;
   - `skills/review/trackers.md` exists and contains `_pause.md`, `.gitignore` and `Resuming at`;
   - all three reviewer prompts contain `FIX_BASE` and none contains `this is a re-review`.
3. Manual trial on the cells repo with the dev companion, recorded as problems.md entries or their absence. A spec review with at least one blocker or major finding asks each one before any fix. Choosing `Pause here` writes `_pause.md`. A fresh session asked to "resume" re-asks the question verbatim with the lead-in. The second pass runs only after every item is decided. `.claude/dietpowers/.gitignore` exists and `git status` shows no tracker files.

## Assumptions

- Only brainstorm and review run question sequences. Other skills' one-off questions don't get `Pause here`.
- `${CLAUDE_SKILL_DIR}/../review/trackers.md` resolves in an installed plugin, because skills sit side by side under the plugin's `skills/` directory.
- Severity mapping for code: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Deferring a blocker or major is allowed, but the terminal state then doesn't recommend continuing.
- Fixes for minor findings run with the rest, after every item is decided.
- A fix check dispatches a `general-purpose` subagent on the same model, the same way as the first review.

## References

- `/Users/eliot/code/cells/.claude/dietpowers/problems.md`: the partner's agreed points 1 to 6 (pause option, trackers, gitignore, PR record, self-contained trackers, single `_pause.md`) and the model's re-review proposals.
- `skills/review/SKILL.md` steps 4 to 7 (commit 995ca81): the "notice, not a question" rule, the single re-review with FINDINGS, and the `Review notes` append being replaced.
- `skills/review/spec-reviewer.md`, `plan-reviewer.md`, `code-reviewer.md`: the FINDINGS re-review sentence. `code-reviewer.md` Severity Guide: the CRITICAL/HIGH/MEDIUM/LOW definitions.
- `skills/finish-branch/SKILL.md` step 6: the PR description bullets.
- `AGENTS.md`: detail goes in separate files that SKILL.md points to; `${CLAUDE_SKILL_DIR}` usage; the published plugin has no hook.
- `git stash create` (git-stash(1)): creates a stash commit and prints its name without changing the working tree, index or refs; prints nothing when there are no local changes.
- Self-ignoring directory: a `.gitignore` containing `*` inside the directory, as pytest writes in `.pytest_cache/` and `python -m venv` writes in the venv since Python 3.13.
- Google engineering practices, "The Standard of Code Review": approve once a change definitely improves overall code health, even if it isn't perfect. https://google.github.io/eng-practices/review/reviewer/standard.html
- IEEE 1028 and Fagan inspection: rework is verified by the moderator; re-inspection happens only when rework is large. The 5 to 10% threshold is commonly cited but not from a single primary source.

## Out of scope

- A SessionStart hook in the published plugin.
- Pause support in skills other than brainstorm and review, including handle-feedback's single question.
- Changing the code reviewer's own severity scale.
- Follow-up: a behavioral test harness that can answer AskUserQuestion, so criterion 3 can be automated.
