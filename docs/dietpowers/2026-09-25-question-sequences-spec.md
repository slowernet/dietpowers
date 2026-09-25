# Question sequences: plain-text questions, review consultation, pause and resume

Source: first user feedback, `/Users/eliot/code/cells/.claude/dietpowers/problems.md` (three entries dated 2026-09-25, session 7643b94c), and the partner's notes in `tmp/notes.txt` (2026-09-25).

> **Changed 2026-09-25:** simplified after two spec reviews and a plan review had grown the design to 206 lines. Dropped: the `Pause here` option and the question tool, `_pause.md`, git snapshots and the 10% full re-review threshold, cross-tracker duplicate matching, `recheck`, stale-pause and branch checks, and the merge-message rule. Questions become plain text; the tracker is the pause point; the second pass is always a fix check. Why: the partner judged the deferral support overcomplicated and preferred plain-text questions after using them in this session. Approved by the partner ("simplify").

## Goal

1. Every skill asks its questions in plain text, so the explanation, asides, clarifying questions and the partner's own alternatives all fit in one exchange.
2. Review puts every blocker and major finding to the partner, one at a time. No reply licenses the model to decide the rest itself.
3. A review or brainstorm can be paused with a one-word reply and resumed later, in a fresh session, from a tracker file on disk.
4. The second review pass runs once, after every first-pass item is decided, and checks only the fixes.
5. Review history goes to the pull request, not into the spec or plan.

## Constraints

Later steps copy these values exactly.

- Question ending: every question ends with a line of the form `Reply with <a>, <b>, or pause.` (for skills with no tracker: `Reply with <a> or <b>.`).
- Resume lead-in: `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.`
- Working directory: `.claude/dietpowers/` at the root of the git work tree. When the model creates it, it writes `.claude/dietpowers/.gitignore` containing the single line `*`, and writes that file if the directory exists without it.
- Tracker path: `.claude/dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`. `<stage>` is `brainstorm`, `spec-review`, `plan-review` or `code-review`. `<topic>` is the topic in the spec's filename; for a code review with no spec, the branch name with `/` replaced by `-`. If the name is taken, append `-2`, `-3` and so on to the topic. Every run of a stage gets a new tracker.
- Severity grades: `blocker`, `major`, `minor`. Yardstick for specs and plans: "Would the plan or the code go wrong, or have to guess, if this stayed?" Yes means blocker or major; no means minor. Code reviewer mapping: CRITICAL and HIGH → blocker, MEDIUM → major, LOW → minor.
- Review item statuses: `open` (awaiting a decision), `fix` (decided, awaiting the fix), `fixed`, `deferred`, `won't fix`, `rejected`, `duplicate of N`. Brainstorm item statuses: `open`, `answered`.
- `Second pass:` values: `pending`, `done (N findings)`, `not run (<reason>)`.
- Reviewer dispatches per review run: at most two (the first review and one fix check).
- The published plugin stays hook-free.

## Design

### Plain-text questions (all skills)

The shared paragraph in every `SKILL.md` ("Ask your partner questions one at a time with the AskUserQuestion tool...") is replaced by one that says: ask one question at a time, in plain text, in a single message. State the problem and why it matters, give the options with the recommended one first and a one-line reason each, and end with the question ending. Do not use the AskUserQuestion tool; some clients show only the question and drop the text around it. The partner may reply with an option, their own alternative, a question, or an aside.

`finish-branch`'s integration menu is printed as written (its "Without the question tool" clause goes).

### Shared detail file: `skills/review/trackers.md`

Holds the formats shared by review and brainstorm. Review points to it as `${CLAUDE_SKILL_DIR}/trackers.md`; brainstorm as `${CLAUDE_SKILL_DIR}/../review/trackers.md`. Both SKILL.md files end with a `Depth:` line naming it. Sections:

- **Working directory**: the directory and its `.gitignore`. If it cannot be written, report it and carry on without a tracker; pausing is then unavailable, and the partner is told.
- **Tracker format**. The tracker must let a fresh session with no conversation continue the run. Header: stage; the reviewed document (brainstorm: the request, then the spec path once written); branch; every value passed to the first reviewer (prompt file, and whichever of `SPEC_FILE_PATH`, `PLAN_FILE_PATH`, `SPEC_AND_PLAN_PATHS`, `REQUIREMENTS` verbatim, `BASE_SHA` apply); `Second pass:`. Paths are relative to the repository root. Each review item: a heading `### N. [status] <title> (<severity>, review <1|2>)`; Finding (the failure scenario and proposed fix, not a label); Verified (file:line or the calculation); Question (the question as asked, kept while the item is `open`; `notice only` for a minor fixed without asking); Decision (the choice and its reason, dated); Fix (what changed, and the commit or `uncommitted`). Each brainstorm item: the question as asked and the answer. Text the partner is asked to approve (approaches, the design) is written into the tracker before the question about it.
- **Replies**. An option or the partner's own alternative is an answer. A question, an aside or a complaint is not: respond to it, then ask the same item again. `pause` stops the sequence: the item stays `open` with its Question, the model says `Paused at item <N>. Say "resume" any time.`, and stops. Nothing but an answer to the current item moves the sequence on, and nothing licenses deciding the remaining items.
- **Resuming**, only when the partner asks. A tracker is unfinished while it has an `open` or `fix` item, or `Second pass: pending` with no review-2 item. Take the newest unfinished tracker whose header names the current branch; say which, and list any other unfinished ones on this branch. With none on this branch, say so, change nothing, and give the count of unfinished trackers on other branches. Show any text the item refers to, then re-ask its recorded Question verbatim after the resume lead-in. If the reply describes a design change, route it through `dietpowers:update-spec` (in brainstorm, fold it into the design) and set back to `open` any earlier item it affects. Then continue: `open` items, then `fix` items, then the second pass if it is still due.

### Review (`skills/review/SKILL.md`)

- Description adds "or to resume a paused review".
- Opening: replace the "One round of fixes and one re-review..." sentence with: review ends when nothing blocking is open, because a reviewer will always find something.
- First step: if the partner asked to resume, follow Resuming in the tracker file.
- Steps 1 to 3 as today; step 1 adds that the reviewer grades each finding.
- After the report: create the tracker with `Second pass: pending`, check each finding against the files, and record it.
  - A minor finding that holds and has one reasonable fix is marked `fix`, with a one-line notice to the partner (the finding and why it holds). No wait.
  - Blocker and major findings, and any finding the model wants to reject, downgrade or fix more than one way, or whose fix changes the approved spec, go to the partner one at a time, most severe first. Options come from fix as proposed, another fix, defer, won't fix and reject. The model may raise a grade on its own and lowers one only by asking.
- Fixing starts when no item is `open`. Fix `fix` items most severe first; code fixes start with a failing test; a fix that alters specified behavior goes through `dietpowers:update-spec` first. Commit if approved. A fix that cannot be made goes back to `open` with the evidence (what was tried, the failing output) and is asked like any item.
- Second pass, if anything was fixed (otherwise `not run (nothing fixed)`): dispatch one fix check the same way as the first review, adding `FINDINGS` (the fixed items' substance). The reviewer never receives the tracker. Write its findings to the tracker as `open` review-2 items before setting `Second pass: done (N findings)`. A finding that matches an item in this tracker is marked `duplicate of N` and not asked unless it brings new evidence, and then with the earlier decision shown. Findings outside the fixes come with the reviewer's grade; recommend defer unless it is a blocker. Decide and fix review-2 items as in the first pass. If the fix check fails or returns nothing usable, report it and set `not run (<reason>)`. Never dispatch again.
- Report, leading with the outcome: fixed, deferred, won't fix and rejected, with reasons, and anything open. Nothing is appended to the spec or plan.
- Terminal state: done when no blocker or major item is `open` or `fix`. Recommend continuing only when none is `deferred` either. Menus otherwise unchanged; a revise run is a new run with a new tracker.

### Reviewer prompts

- `spec-reviewer.md` and `plan-reviewer.md` add `Severity: [blocker|major|minor]` after `Check:`, with the yardstick and "Name the failure scenario that justifies the grade."
- All three: the FINDINGS sentence becomes a fix check. Check only whether each finding is fixed and whether its fix broke anything it touches. Report anything else under `Out of scope`, graded like a finding.
- `code-reviewer.md`: in a fix check, the scope in "What to Review" and Process step 1 is replaced by the files the fixes touched; the test suite still runs once, and a failure is a `BUG`. The Severity Guide is unchanged.

### Brainstorm (`skills/brainstorm/SKILL.md`)

- Description adds "or to resume a paused brainstorm".
- First step: if the partner asked to resume, follow Resuming in `${CLAUDE_SKILL_DIR}/../review/trackers.md`.
- Before the first question, create the tracker (stage `brainstorm`; the topic chosen now is reused for the spec filename). Record each question and answer, and the approaches and design before asking about them. Replies follow the tracker file.

### Finish branch (`skills/finish-branch/SKILL.md`)

- Step 6's review bullet becomes: from the trackers in `.claude/dietpowers/trackers/` whose header names this branch, each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason.
- Trackers are never deleted by any skill.

### Other files

- `README.md`: bring every description of the old loop in line (the flow-diagram lines ending `fix; one re-review`, the bullet containing `One re-review checks only the fixes`, the change notes `Runs one scoped re-review, then stops.` and the one beginning `Reports outcome first and appends rejected findings`), and add change notes for plain-text questions, trackers, pause and resume, and the PR record.
- `tests/skills/check-skills.sh`: the assertions under Success criteria.

## Inputs and failure behavior

- **Partner replies**: as in Replies. An empty or unclear reply is not an answer: ask again.
- **Resume with no unfinished tracker on this branch**: no-op with a report, as in Resuming.
- **Tracker unreadable or missing fields**: say which field, and ask whether to continue with what is readable or leave the tracker.
- **Working directory not writable**: as in Working directory.
- **Fix cannot be made**: back to `open` with evidence.
- **Fix check fails**: `Second pass: not run (<reason>)`, first-pass decisions stand.
- **Session dies mid-run**: the tracker shows the run unfinished; "resume" continues it.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0, and asserts:
   - no file under `skills/` contains `AskUserQuestion` or `Review notes`;
   - every `SKILL.md` contains `Reply with`;
   - `skills/review/trackers.md` exists and contains `.gitignore`, `Resuming` and `pause`;
   - `skills/review/SKILL.md` and `skills/brainstorm/SKILL.md` have a `Depth:` line naming `trackers.md`, and the brainstorm path resolves;
   - `spec-reviewer.md` and `plan-reviewer.md` contain `Severity: [blocker|major|minor]`; all three prompts contain `Out of scope`;
   - `README.md` contains neither `one re-review` nor `section in the spec or plan`.
2. Manual trial on cells with the dev companion, results logged in its problems.md. Precondition: the old 3d-tunnel review is finished, or its old `_pause.md` and tracker are moved into `.claude/dietpowers/trackers/_old/` by hand with the partner's go-ahead. Checks: questions arrive as plain text ending in `Reply with`; each blocker and major is asked before any fix; `pause` stops the sequence; "resume" in a fresh session re-asks the item verbatim with the lead-in; the fix check runs only after every item is decided; afterwards `git check-ignore -v` on a tracker path names `.claude/dietpowers/.gitignore`, and `git status --porcelain --untracked-files=all` lists nothing under `.claude/dietpowers/`.

## Assumptions

- The plain-text rule applies to all ten skills; only review and brainstorm keep trackers and offer `pause`.
- `${CLAUDE_SKILL_DIR}/../review/trackers.md` resolves in an installed plugin: skills sit side by side, and `skills/tdd/SKILL.md` already points to `../find-root-cause/`.
- Deferring a blocker or major is allowed; the terminal state then doesn't recommend continuing.
- Held-back commits need nothing special: the fix check reads the files, not a diff.

## References

- `/Users/eliot/code/cells/.claude/dietpowers/problems.md`: the partner's points 1 to 6 and the re-review proposals. Points 1 (pause option), 2 and 6 (`_pause.md`) are superseded by this design.
- `tmp/notes.txt`: plain-text questions over the question tool; concern about deferral complexity.
- `skills/review/SKILL.md` at 995ca81: steps 4 to 7 being replaced, including the `Review notes` append.
- Reviewer prompts: the FINDINGS sentence at the top of each; `code-reviewer.md` "What to Review", Process step 1, `### BUG N` format and Severity Guide.
- `skills/finish-branch/SKILL.md` step 4 (menu, question-tool clause) and step 6 (PR bullets).
- `AGENTS.md`: SKILL.md anatomy including `Depth:`; detail in separate files; `${CLAUDE_SKILL_DIR}`; hook-free published plugin.
- Self-ignoring directory: a `.gitignore` containing `*` inside the directory, as pytest writes in `.pytest_cache/` and `python -m venv` writes since Python 3.13.
- Google engineering practices, "The Standard of Code Review": approve once a change definitely improves overall code health. https://google.github.io/eng-practices/review/reviewer/standard.html

## Out of scope

- A SessionStart hook in the published plugin.
- Follow-ups, each its own spec: rename `review` to `adversarial-review`; a research-and-ground step in brainstorm; an express path for changes small enough to do in one pass; a behavioral test harness for criterion 2.
