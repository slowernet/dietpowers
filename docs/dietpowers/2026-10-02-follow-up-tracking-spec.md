# Open items and triage

Source: issue [#24](https://github.com/slowernet/dietpowers/issues/24) and the brainstorm and spec review recorded in `.dietpowers/trackers/2026-10-02-follow-up-tracking-*.md`.

## Goal

Things worth doing later turn up at any point in the flow: a subsystem split off at a scope check, a suggested deep-research, an idea while building, a review finding the partner defers. Today the skills put some of them in the spec's Out of scope section, which mixes later work into the spec, and the rest are lost when the session ends. Where later work belongs (an issue tracker, a notes file) varies by person and project.

Every skill instead adds such an item to one open-items tracker, without asking. A new skill, `dietpowers:triage-open-items`, works through that list with the partner: it groups and de-duplicates the items, checks the project's backlog for matches, and recommends an outcome for each. Items with a final outcome leave the list. `finish-branch` offers triage before integrating. The spec's Out of scope section holds only what the feature excludes.

> **Changed 2026-10-03:** from each skill drafting a follow-up and asking to file it where the project tracks work, to an open-items tracker that a triage skill works through. Why: follow-ups arise anywhere in the flow, and the first design had no place to hold them until they were filed (spec review findings 1-9). Approved by the partner in the spec review.

## Constraints

Later steps copy these values exactly.

- Open-items file: `.dietpowers/trackers/open-items.md`. It follows `## Working directory` in `skills/adversarial-review/trackers.md` (gitignored, outside `.claude/`), and its format is a new `## Open items` section in that file.
- Adding sentence, the same in every `SKILL.md`, after the question paragraph: "When you find something worth doing later that this work does not include, add it as an item to `.dietpowers/trackers/open-items.md`, following `## Open items` in `${CLAUDE_SKILL_DIR}/../adversarial-review/trackers.md`, and say so in one line." Adding asks nothing. In `skills/adversarial-review/SKILL.md` the trackers path is the skill's own `${CLAUDE_SKILL_DIR}/trackers.md`.
- Item format:

  ```markdown
  ### N. [open] <title>
  - Found: YYYY-MM-DD, branch <branch>, <skill>
  - Why: what to do later and why, with its evidence (paths, links, and any designed text it removes from the spec, word for word)
  - Recommendation:
  - Question:
  - Decision:
  ```

  The file's first line after its title is `Next: N`; when an add creates the file, it writes the title, then `Next: 2`, then item 1. `Next: N` is the number the next added item takes; each add uses it and increments it, so numbers are never reused. A merged item keeps the lowest of its numbers. Statuses: `open` (not yet triaged) and `kept`.
- Outcomes, one per item, recommended first in the triage question: `**file new**` (open a new item in the backlog), `**add to #N**` (comment on a matching backlog item, naming it), `**keep**` (stays in the file, status `kept`), `**drop**`. The question ends `Reply with <outcomes in bold>, or **pause**.`
- An item leaves the file once its outcome is carried out: after the new backlog item or comment exists, or at once for `drop`. A `kept` item stays, and is offered again in the next triage.
- For a notes-file backlog, `add to #N` is not offered.
- Backlog location: from the project instructions or memory. If neither names one, triage asks once (for example GitHub issues, another tracker, or a notes file) and offers to save the answer to memory.
- Deferring a review finding: adversarial-review's finding question offers `**add to open items**` (the finding is added as an open item and stays `deferred` in the review tracker) and `**leave here**` (it stays only in the review tracker and the PR description) in place of a single defer.
- Skill name `triage-open-items`, at `skills/triage-open-items/SKILL.md`, invoked as `/dietpowers:triage-open-items`.
- finish-branch question, asked when the file has `open` items, before the integration question, or before the push when the branch already has an open pull request: "There are <N> open items. Triage them now? Reply with **triage** or **later**." On `triage`, invoke `dietpowers:triage-open-items`, which returns to finish-branch.

## Design

### `skills/triage-open-items/SKILL.md` (new)

Anatomy as in AGENTS.md: title; a short opening on why triage matters; the shared question, commit and adding paragraphs; numbered steps; terminal state; `Depth:` line pointing at `../adversarial-review/trackers.md`.

1. Read `.dietpowers/trackers/open-items.md`. If it is missing or has no `open` or `kept` items, say so and stop.
2. Find the backlog location. Read the backlog's open items: `gh issue list --state open` for GitHub issues; for another place, what the partner points to. If it cannot be read, say so; triage still runs, and `file new` and `add to #N` are not offered.
3. Study the list. Group related items, and merge items that describe the same thing into one, keeping all their evidence. Show the groups and merges in one message. This needs no question.
4. Clear the Recommendation, Question and Decision of every item. Then, for each item, compare it with the backlog for duplicates and close matches, and write the Recommendation into the item: the outcome with a one-line reason, and for `file new` or `add to #N`, the draft title and body or comment.
5. Ask about one item at a time, in the order of the groups, recording each Question before asking it. The partner may edit the draft in the reply.
6. Carry out each answer before the next question. Remove the item from the file once its outcome is done. If filing or commenting fails, leave the item `open`, record the error under Recommendation, clear its Question so it does not look paused, leave Decision empty, and say so.
7. Report: what was filed (with links), added to, kept and dropped.

Terminal state: if `dietpowers:finish-branch` invoked you, return to it; otherwise stop.

Pause and resume follow `## Replies` and `## Resuming` in `trackers.md`. The skill's description says it also resumes a paused triage.

### `skills/adversarial-review/trackers.md`

- New `## Open items` section: the file path, the item format, the statuses, the removal rule and the outcomes, as in Constraints.
- `## Replies`: triage's item questions offer `pause`, like brainstorm's and review's.
- `## Resuming` gains an open-items case: `triage-open-items` resumes `open-items.md`; it needs no `Branch:` lookup; the file is unfinished while an item has a Question and no Decision; resuming starts at that item with the usual lead-in and its recorded Question.

### Every `SKILL.md`

The adding sentence from Constraints, after the question paragraph.

### Places that record follow-ups today

- `skills/brainstorm/SKILL.md` step 2: "split it: brainstorm only the first, and add each of the others as an open item, to get its own spec later."
- Step 4: "If the report suggests a deep-research, pass that on and add it as an open item."
- Step 9: the section list reads "Out of scope" instead of "Out of scope, including follow-ups".
- `skills/write-plan/SKILL.md` step 1: "invoke the `dietpowers:update-spec` skill to remove all but one from the spec and add each of the others as an open item whose Why holds its removed sections word for word, then plan the one that remains."
- `skills/update-spec/SKILL.md` step 2: "ask your partner whether to add it as an open item and carry on (recommended), or to pause the current work and start it now with the `dietpowers:brainstorm` skill."

### `skills/finish-branch/SKILL.md`

In step 4, the triage question from Constraints: before the integration question, or before the push when a pull request is already open.

### `skills/adversarial-review/SKILL.md`

- Step 5's options for a finding replace defer with **add to open items** and **leave here**, as in Constraints.
- Step 7's rule for a fix check's `Out of scope` findings changes from "recommend defer unless it is a blocker" to: offer **add to open items** and **leave here** without recommending either, unless the finding is a blocker, which is recommended for fixing.

### Docs and tests

- `tests/skills/check-skills.sh`:
  - the expected skill set adds `triage-open-items`;
  - every `SKILL.md` contains `.dietpowers/trackers/open-items.md`;
  - `trackers.md` contains `## Open items`, `**file new**`, `**add to #N**`, `**keep**` and `**drop**`;
  - `skills/finish-branch/SKILL.md` contains `dietpowers:triage-open-items` and `Triage them now?`;
  - `skills/adversarial-review/SKILL.md` contains `**add to open items**` and `**leave here**`, and no longer contains `recommend defer unless it is a blocker`;
  - `trackers.md` contains `Next: N`;
  - no file under `skills/` contains `in the spec's Out of scope section as follow-ups`, `Out of scope, including follow-ups`, `list it in the spec's Out of scope as a follow-up`, `as a follow-up in the spec's Out of scope section` or `to Out of scope as follow-ups`.
- `AGENTS.md`: "10 skills" becomes "11 skills".
- `README.md`:
  - the flow diagram gains a `triage-open-items` line;
  - "How dietpowers differs" gains a bullet on open items;
  - "What changed in each skill" gains a `triage-open-items` entry and the sentence on adding open items in its intro;
  - the brainstorm, write-plan and update-spec bullets that mention follow-ups in Out of scope (lines 114, 130, 176) say open items;
  - the finish-branch bullets mention the triage question.
- `docs/testing.md`: "exactly the ten expected skills" becomes eleven; the gate list names open items; the manual trial in Success criterion 2.

## Inputs and failure behavior

- **The file cannot be written** (the same cases as a tracker: not writable, not a git work tree, detached HEAD): say the item in one line in the conversation instead.
- **The backlog cannot be read** (no `gh`, not signed in, no remote): triage offers only `keep` and `drop`, and says why.
- **Filing or commenting fails**: the item stays `open`, with the error under Recommendation, its Question cleared and Decision empty.
- **The partner names a notes file as the backlog**: `file new` appends the draft to it. Triage commits nothing; it leaves the edit on disk and says so.

> **Changed 2026-10-03:** triage never commits (from committing a tracked notes file when the partner agrees). Why: that commit had no branch rule and could land on `main` (plan review finding 3). Approved by the partner in the plan review ("never").
- **Several worktrees**: each has its own `open-items.md` at its root; triage works on the current one. Removing a linked worktree loses its file; that is issue [#25](https://github.com/slowernet/dietpowers/issues/25).
- **A triage paused partway**: the file holds the recorded Question; resuming asks it again.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and asserts the strings in Docs and tests, present and absent.
2. Manual trial:
   - During brainstorm on a request with two independent parts, the second part is added to `open-items.md` with a one-line notice and no question.
   - `/dietpowers:triage-open-items` with three items, two of them about the same thing, merges those two.
   - With a GitHub backlog holding a close match, it recommends `add to #N` for that item.
   - After answers of `file new`, `keep` and `drop`, only the kept item remains in the file, and the new issue exists.
   - At `finish-branch` with an open item, the triage question comes before the integration question.
3. `docs/testing.md` describes trial 2.

## Assumptions

- Claude Code loads `CLAUDE.md`, `AGENTS.md` and the memory index into every session, so the backlog location needs no lookup step.
- `gh issue list` and `gh issue create`/`gh issue comment` are the GitHub commands; another backlog is handled through what the partner points to.

## References

- `skills/adversarial-review/trackers.md`: `## Working directory` (gitignored `.dietpowers/`), `## Replies` (`pause`), `## Resuming`.
- The current follow-up text: `skills/brainstorm/SKILL.md` steps 2, 4, 9; `skills/write-plan/SKILL.md` step 1; `skills/update-spec/SKILL.md` step 2; `README.md` lines 114, 130, 176.
- `tests/skills/check-skills.sh` lines 14-26: the expected skill set.
- `AGENTS.md` skill anatomy, and the rule that a skill's description says what it produces and when to use it.

## Out of scope

- Sharing one open-items file across worktrees, and keeping it when a linked worktree is removed (#25).

> **Changed 2026-10-03 (spec review):** a `Next:` counter; deferred findings offer **add to open items** or **leave here**; removed design text is carried in the item; an open-items case in Resuming and Replies; a fresh triage clears old fields; the triage question also on the existing-PR path; `add to #N` not offered for a notes file. Approved by the partner in the spec review.
> **Changed 2026-10-03 (fix check):** the defer options are named **add to open items** and **leave here**; out-of-scope findings get no recommendation between them unless they are blockers; the failure section and template match the earlier fixes; a failed filing clears its Question; a new file starts at `Next: 2`. Approved by the partner in the spec review.
