# Question sequences: plain-text questions, review consultation, pause and resume

Source: first user feedback, `/Users/eliot/code/cells/.claude/dietpowers/problems.md` (three entries dated 2026-09-25, session 7643b94c), and the partner's notes in `tmp/notes.txt` (2026-09-25).

> **Changed 2026-09-25:** simplified after two spec reviews and a plan review had grown the design to 206 lines. Dropped: the `Pause here` option and the question tool, `_pause.md`, git snapshots and the 10% full re-review threshold, cross-tracker duplicate matching, `recheck`, stale-pause and branch checks, and the merge-message rule. Questions become plain text; the tracker is the pause point; the second pass is always a fix check. Why: the partner judged the deferral support overcomplicated and preferred plain-text questions after using them in this session. Approved by the partner ("simplify"). In its review, the partner also chose to have the code steps always commit on the feature branch ("I don't want to maintain my own git status"), which adds the Commits in the code steps section.

## Goal

1. Every skill asks its questions in plain text, so the explanation, asides, clarifying questions and the partner's own alternatives all fit in one exchange.
2. Review puts every blocker and major finding to the partner, one at a time. No reply licenses the model to decide the rest itself.
3. A review or brainstorm can be paused with a one-word reply and resumed later, in a fresh session, from a tracker file on disk.
4. The second review pass runs once, after every first-pass item is decided, and checks only the fixes.
5. Review history goes to the pull request, not into the spec or plan.
6. Code steps always commit on the feature branch, so git, not the model, records what changed; only the spec and plan may be held back.

## Constraints

Later steps copy these values exactly.

- Question ending: every question ends with a line naming its answers. On a tracker item (a brainstorm question or a review finding): `Reply with <a>, <b>, or pause.` On any other question: `Reply with <a> or <b>.` (or `<a>, <b>, or <c>`). Fixed questions get these endings: the commit question `Reply with yes or no.`; finish-branch's menus `Reply with 1, 2, or 3.` (detached HEAD: `Reply with 1 or 2.`) in place of `Which option?`; review's terminal question `Reply with continue, revise, or stop.`; execute-plan's `Reply with yes or no.`; handle-feedback's push question `Reply with yes or no.`
- Resume lead-in: `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.`
- Working directory: `.claude/dietpowers/` at the root of the git work tree. When the model creates it, it writes `.claude/dietpowers/.gitignore` containing the single line `*`, and writes that file if the directory exists without it.
- Tracker path: `.claude/dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`. `<stage>` is `brainstorm`, `spec-review`, `plan-review` or `code-review`. `<topic>` is the topic in the spec's filename (`YYYY-MM-DD-<topic>-spec.md`); for another filename, its name stem; for a code review with no spec, the branch name with `/` replaced by `-`. On a detached HEAD there is no tracker (see Working directory). If the name is taken, append `-2`, `-3` and so on to the topic. Every run of a stage gets a new tracker.
- Severity grades: `blocker`, `major`, `minor`. Yardstick for specs and plans: "Would the plan or the code go wrong, or have to guess, if this stayed?" Yes means blocker or major; no means minor. Code reviewer mapping: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Review item statuses: `open` (awaiting a decision), `fix` (decided, awaiting the fix), `fixed`, `deferred`, `won't fix`, `rejected`, `duplicate of N`. Brainstorm item statuses: `open`, `answered`.
- `Second pass:` values (review trackers only): `pending`, `done (N findings)`, `not run (<reason>)`.
- Reviewer dispatches per review run: at most two (the first review and one fix check).
- The published plugin stays hook-free.

## Design

### Plain-text questions (all skills)

The shared paragraph in every `SKILL.md` ("Ask your partner questions one at a time with the AskUserQuestion tool...") is replaced by one that says: ask one question at a time, in plain text, in a single message. State the problem and why it matters, give the options with the recommended one first and a one-line reason each, and end with the question ending. Do not use the AskUserQuestion tool; some clients show only the question and drop the text around it. The partner may reply with an option, their own alternative, a question, or an aside.

`finish-branch`'s integration menus are printed as written, except that `Which option?` becomes the `Reply with` ending in Constraints; the "Without the question tool" clause goes.

### Commits in the code steps

The code steps always commit on the feature branch: `execute-plan` (one commit per task), `tdd`, `find-root-cause`, `handle-feedback`, and fixes in a code review. They never commit to `main` or `master`. In these skills the shared commit paragraph becomes: if you are on `main`, `master` or the plan's `Base:` branch, ask once to create the feature branch (`I'll create branch <name> for this work. Reply with yes or no.`); otherwise commit as you go. A partner who declines gets no code work until a branch is agreed.

The commit question and held-back mode stay for documents only: `brainstorm`, `write-plan`, `update-spec`, and fixes in a spec or plan review. Whatever the answer, the work moves to the named feature branch; declining holds back commits only. The plan's `Commits:` line now covers the spec and plan only. `prove-done` makes no commits of its own: its commit paragraph and step 3's commit clause are removed, and code it fixes goes through `tdd`. `finish-branch` step 3's commit proposal shrinks to the spec and plan, when they were held back; the per-task patch splitting goes. When document commits are held back, `update-spec` leaves spec and plan edits on disk even though the code change is committed; otherwise it commits them with the code change. `review`'s commit paragraph and its step 2 say: fixes in a code review follow the code-step rule; fixes in a spec or plan review follow the document rule.

> **Changed 2026-09-25:** declining the commit question now still moves the work to the feature branch (from: the answer did not say whether a branch was created). Why: review trackers recorded `main` when documents were held back, so the PR record and resume missed them. Approved by the partner in plan review (finding 7).

### Shared detail file: `skills/review/trackers.md`

Holds the formats shared by review and brainstorm. Review points to it as `${CLAUDE_SKILL_DIR}/trackers.md`; brainstorm as `${CLAUDE_SKILL_DIR}/../review/trackers.md`. Both SKILL.md files end with a `Depth:` line naming it. Sections:

- **Working directory**: the directory and its `.gitignore`. If it cannot be written, or the project is not in a git work tree, or HEAD is detached, report it and carry on without a tracker; pausing is then unavailable, and the partner is told.
- **Tracker format**. The tracker must let a fresh session with no conversation continue the run. Header: stage; the reviewed document (brainstorm: the request, then the spec path once written); branch; every value passed to the first reviewer (prompt file, and whichever of `SPEC_FILE_PATH`, `PLAN_FILE_PATH`, `SPEC_AND_PLAN_PATHS`, `REQUIREMENTS` verbatim, `BASE_SHA` apply); for a code review, `FIX_BASE` once recorded; `Second pass:` (review trackers only). A brainstorm header has `Spec:`, empty until the spec file is saved, instead of `Second pass:`. Paths are relative to the repository root. Each review item: a heading `### N. [status] <title> (<severity>, review <1|2>)`; Finding (the failure scenario and proposed fix, not a label); Verified (file:line or the calculation); Question (the question as asked, kept while the item is `open`; `notice only` for a minor fixed without asking); Decision (the choice and its reason, dated); Fix (what changed, and the commit or `uncommitted`). Each brainstorm item: the question as asked and the answer. Text the partner is asked to approve (approaches, the design) is written into the tracker before the question about it.
- **Replies**. `pause` is offered only on tracker items. An option or the partner's own alternative is an answer. A question, an aside or a complaint is not: respond to it, then ask the same item again. `pause` stops the sequence: the item stays `open` with its Question, the model says `Paused at item <N>. Say "resume" any time.`, and stops. Nothing but an answer to the current item moves the sequence on, and nothing licenses deciding the remaining items.
- **Resuming**, only when the partner asks. A review tracker is unfinished while it has an `open` or `fix` item, or `Second pass: pending`. A brainstorm tracker is unfinished while its `Spec:` line is empty. Each skill resumes only its own stages (brainstorm: `brainstorm`; review: the three review stages). Take the most recently modified unfinished tracker of those stages whose header names the current branch; say which, and list any other unfinished ones on this branch. With none on this branch, say so, change nothing, and give the count of unfinished trackers on other branches. An `open` item with no Verified line is unchecked: check it first, as in the first pass (a minor with one fix gets a notice; the rest are asked). Otherwise show any text the item refers to, then re-ask its recorded Question verbatim after the resume lead-in. If the reply describes a design change, route it through `dietpowers:update-spec` (in brainstorm, fold it into the design) and set back to `open` any earlier item it affects. Then continue: `open` items, then `fix` items, then the second pass if it is still due.

### Review (`skills/review/SKILL.md`)

- Description adds "or to resume a paused review".
- Opening: replace the "One round of fixes and one re-review..." sentence with: review ends when nothing blocking is open, because a reviewer will always find something.
- First step: if the partner asked to resume, follow Resuming in the tracker file.
- Steps 1 to 3 as today; step 1 adds that the reviewer grades each finding.
- After the report: create the tracker with `Second pass: pending` and write every finding into it at once as an unchecked `open` item. Then check each against the files and record the evidence.
  - A minor finding that holds and has one reasonable fix is marked `fix`, with a one-line notice to the partner (the finding and why it holds). No wait.
  - Blocker and major findings, and any finding the model wants to reject, downgrade or fix more than one way, or whose fix changes the approved spec, go to the partner one at a time, most severe first. Options come from fix as proposed, another fix, defer, won't fix and reject. The model may raise a grade on its own and lowers one only by asking.
- Fixing starts when no item is `open`. For code, first record `FIX_BASE` (the current commit) in the tracker. Fix `fix` items most severe first; code fixes start with a failing test and are committed; a fix that alters specified behavior goes through `dietpowers:update-spec` first. Commit if approved. A fix that cannot be made goes back to `open` with the evidence (what was tried, the failing output) and is asked like any item.
- Second pass, if anything was fixed (otherwise `not run (nothing fixed)`): dispatch one fix check the same way as the first review, adding `FINDINGS` (the fixed items' substance) and, for code, `FIX_BASE`. The reviewer never receives the tracker. Write all its findings to the tracker as `open` review-2 items and set `Second pass: done (N findings)` in the same write. Review-2 minors follow the first-pass notice rule. A finding that matches an item in this tracker is marked `duplicate of N` and not asked unless it brings new evidence, and then with the earlier decision shown. Findings outside the fixes come with the reviewer's grade; recommend defer unless it is a blocker. Decide and fix review-2 items as in the first pass. If the fix check fails or returns nothing usable, report it and set `not run (<reason>)`. Never dispatch again.
- Report, leading with the outcome: fixed, deferred, won't fix and rejected, with reasons, and anything open. Nothing is appended to the spec or plan.
- Terminal state: done when no blocker or major item is `open` or `fix`. Recommend continuing only when none is `deferred` either. The question ends `Reply with continue, revise, or stop.`; a revise run is a new run with a new tracker.

### Reviewer prompts

- `spec-reviewer.md` and `plan-reviewer.md` add `Severity: [blocker|major|minor]` after `Check:`, with the yardstick and "Name the failure scenario that justifies the grade."
- All three: the FINDINGS sentence becomes a fix check. Check only whether each finding is fixed and whether its fix broke anything it touches. Report anything else under `Out of scope`, graded like a finding.
- `code-reviewer.md`: in a fix check, the scope in "What to Review" and Process step 1 is replaced by `git diff [FIX_BASE] HEAD` (the committed fixes only); the test suite still runs once, and a failure is a `BUG`. The Severity Guide is unchanged.

### Brainstorm (`skills/brainstorm/SKILL.md`)

- Description adds "or to resume a paused brainstorm".
- First step: if the partner asked to resume, follow Resuming in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker (stage `brainstorm`; the topic chosen now is reused for the spec filename). Record each question and answer, and the approaches and design before asking about them. Replies follow the tracker file. Fill in the header's `Spec:` line when the spec file is saved.

### Finish branch (`skills/finish-branch/SKILL.md`)

- Step 6's review bullet becomes: from the trackers in `.claude/dietpowers/trackers/` whose header names this branch, each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- On a local merge, the final report to the partner lists the deferred, won't-fix and rejected findings from those trackers, one line each.
- No skill deletes a tracker directly. Removing a worktree removes the trackers inside it; that is accepted.

### Other files

- `README.md`: bring every description of the old loop in line (the flow-diagram lines ending `fix; one re-review`, the bullet containing `One re-review checks only the fixes`, the change notes `Runs one scoped re-review, then stops.` and the one beginning `Reports outcome first and appends rejected findings`, including its `(one fresh review of the revision)`; the bullet `Questions come one at a time,` which says multiple choice; the sentence beginning `Every skill that asks you anything gained the same rule`, the sentence beginning `Every skill that commits asks once`, the sentence beginning `Committing needs your approval once per piece of work`, finish-branch's change note `(spec and plan, then one per plan task, splitting shared files by task)`, and its PR-description change note mentioning review findings),

> **Changed 2026-09-25:** three more README passages added (from the earlier list). Why: the commit change makes them false. Approved by the partner in plan review (finding 8). and add change notes for plain-text questions, trackers, pause and resume, the PR record, and commits in the code steps.
- `tests/skills/check-skills.sh`: the assertions under Success criteria.

## Inputs and failure behavior

- **Partner replies**: as in Replies. An empty or unclear reply is not an answer: ask again.
- **Resume with no unfinished tracker on this branch**: no-op with a report, as in Resuming.
- **Tracker unreadable or missing fields**: say which field, and ask whether to continue with what is readable or leave the tracker.
- **Working directory not writable**: as in Working directory.
- **Fix cannot be made**: back to `open` with evidence.
- **Fix check fails**: `Second pass: not run (<reason>)`, first-pass decisions stand.
- **Session dies mid-run**: every finding is in the tracker before it is checked, so the tracker shows the run unfinished and "resume" continues it.
- **On `main` or `master` when a code step starts**: ask once to create the feature branch; no code work until one is agreed.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0, and asserts:
   - no file under `skills/` contains `with the AskUserQuestion tool:` (the old paragraph) or `Review notes`;
   - every `SKILL.md` contains `Reply with`;
   - `skills/review/trackers.md` exists and contains `.gitignore`, `Resuming` and `pause`;
   - `skills/review/SKILL.md` and `skills/brainstorm/SKILL.md` have a `Depth:` line naming `trackers.md`, and the brainstorm path resolves;
   - `spec-reviewer.md` and `plan-reviewer.md` contain `Severity: [blocker|major|minor]`; all three prompts contain `Out of scope`;
   - `README.md` contains none of `one re-review`, `section in the spec or plan`, `multiple choice`;
   - no file under `skills/` contains `Which option?`;
   - `execute-plan`, `tdd`, `find-root-cause`, `handle-feedback` and `prove-done` SKILL.md do not contain `if commits are approved`, `review` SKILL.md contains `code-step rule`, and `finish-branch` SKILL.md does not contain `git apply --cached`.
> **Changed 2026-09-25:** criterion 1 bans the old paragraph's text, not the tool name (from: any mention of `AskUserQuestion`). Why: the new paragraph names the tool it forbids, so the old test could never pass. Approved by the partner in plan review (finding 1).

2. Manual trial on cells with the dev companion, results logged in its problems.md. Precondition: the old 3d-tunnel review is finished, or its old `_pause.md` and tracker are moved into `.claude/dietpowers/trackers/_old/` by hand with the partner's go-ahead. Checks: questions arrive as plain text ending in `Reply with`; each blocker and major is asked before any fix; `pause` stops the sequence; "resume" in a fresh session re-asks the item verbatim with the lead-in; the fix check runs only after every item is decided; afterwards `git check-ignore -v` on a tracker path names `.claude/dietpowers/.gitignore`, and `git status --porcelain --untracked-files=all` lists nothing under `.claude/dietpowers/`.

## Assumptions

- The plain-text rule applies to all ten skills; only review and brainstorm keep trackers and offer `pause`.
- `${CLAUDE_SKILL_DIR}/../review/trackers.md` resolves in an installed plugin: skills sit side by side, and `skills/tdd/SKILL.md` already points to `../find-root-cause/`.
- Deferring a blocker or major is allowed; the terminal state then doesn't recommend continuing.
- A spec or plan fix check needs no diff: the reviewer rereads the one document. Only code fix checks use `FIX_BASE`.

## References

- `/Users/eliot/code/cells/.claude/dietpowers/problems.md`: the partner's points 1 to 6 and the re-review proposals. Points 1 (pause option), 2 and 6 (`_pause.md`) are superseded by this design.
- `tmp/notes.txt`: plain-text questions over the question tool; concern about deferral complexity.
- `skills/review/SKILL.md` at 995ca81: steps 4 to 7 being replaced, including the `Review notes` append.
- Reviewer prompts: the FINDINGS sentence at the top of each; `code-reviewer.md` "What to Review", Process step 1, `### BUG N` format and Severity Guide.
- `skills/finish-branch/SKILL.md` step 3 (commit proposal with `git apply --cached`), step 4 (menu, question-tool clause), step 6 (PR bullets), step 7 (`git worktree remove`).
- The shared commit paragraph ("Before your first commit for this piece of work...") in brainstorm, write-plan, review, execute-plan, tdd, find-root-cause, handle-feedback, update-spec and prove-done; `execute-plan` step 4 ("commit if commits are approved").
- `AGENTS.md`: SKILL.md anatomy including `Depth:`; detail in separate files; `${CLAUDE_SKILL_DIR}`; hook-free published plugin.
- Self-ignoring directory: a `.gitignore` containing `*` inside the directory, as pytest writes in `.pytest_cache/` and `python -m venv` writes since Python 3.13.
- Google engineering practices, "The Standard of Code Review": approve once a change definitely improves overall code health. https://google.github.io/eng-practices/review/reviewer/standard.html

## Out of scope

- A SessionStart hook in the published plugin.
- Follow-ups, each its own spec: rename `review` to `adversarial-review`; a research-and-ground step in brainstorm; an express path for changes small enough to do in one pass; a behavioral test harness for criterion 2.
