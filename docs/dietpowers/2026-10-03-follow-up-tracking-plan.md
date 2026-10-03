# Plan: open items and triage

Spec: docs/dietpowers/2026-10-02-follow-up-tracking-spec.md @ 687020a (one Changed note added 2026-10-03: triage never commits)
Base: main
Commits: approved

**Goal:** every skill queues later work in `.dietpowers/trackers/open-items.md` without asking, a new `triage-open-items` skill works through that queue with the partner, and finish-branch offers triage.

**Architecture:** the queue's format lives in one new `## Open items` section of the shared `skills/adversarial-review/trackers.md`, which every skill points to with one copied sentence. The triage skill is a standalone `SKILL.md` built like the other skills. The review's single defer splits in two so a deferred finding can join the queue.

## Global Constraints

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
- finish-branch question, asked when the file has `open` items, before the integration question, or before the push when the branch already has an open pull request, unless `dietpowers:handle-feedback` invoked finish-branch; handle-feedback then asks the same question after posting its replies: "There are <N> open items. Triage them now? Reply with **triage** or **later**." On `triage`, invoke `dietpowers:triage-open-items`, which returns to finish-branch when finish-branch invoked it, and otherwise stops.

## References

- `skills/adversarial-review/trackers.md`: `## Working directory` (`.dietpowers/` at the work-tree root, self-ignoring; no tracker when not writable, not a git work tree, or detached HEAD), `## Tracker format`, `## Replies` ("Offer `pause` only on tracker items: brainstorm's questions and review's finding questions."), `## Resuming` steps 1-7 (unfinished rules, `Branch:` lookup, the exact lead-in `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.`).
- Shared paragraphs: the question paragraph ("Ask your partner one question at a time ...") is line 10 or 11 of every `SKILL.md`; the commit paragraphs follow it (brainstorm, write-plan and update-spec use "Before your first commit of the spec or plan ..."; code skills use "Commit your work on the feature branch ..."; adversarial-review uses "Commits follow two rules.").
- Current follow-up text to replace:
  - `skills/brainstorm/SKILL.md` step 2: "split it: brainstorm only the first, and list the others in the spec's Out of scope section as follow-ups, each to get its own spec later."
  - step 4: "If the report suggests a deep-research, pass that on and list it in the spec's Out of scope as a follow-up."
  - step 9: "...; Out of scope, including follow-ups."
  - `skills/write-plan/SKILL.md` step 1: "invoke the `dietpowers:update-spec` skill to move all but one to Out of scope as follow-ups, then plan the one that remains."
  - `skills/update-spec/SKILL.md` step 2: "ask your partner whether to record it as a follow-up in the spec's Out of scope section and carry on (recommended), ..."
- `skills/adversarial-review/SKILL.md` step 5 (the finding question offers "fix as proposed, another fix, defer, won't fix and reject") and step 7 ("for a finding under `Out of scope`, recommend defer unless it is a blocker").
- `skills/finish-branch/SKILL.md` step 4: the open-PR path ("If the branch already has an open pull request, skip the menu. Push the new commits once your partner has approved the push ...") and the integration question.
- `tests/skills/check-skills.sh`: the expected skill set at lines 14-18; rules applied to every `SKILL.md` at lines 61-64 (`Reply with`, `short bold label in words`) and near the end (`say in one line what you are about to do`); the trackers block at lines 77-86.
- `README.md`: flow diagram at line 22 onward; "How dietpowers differs" at line 54; "What changed in each skill" intro at line 102; brainstorm, write-plan and update-spec follow-up lines 114, 130, 176; adversarial-review entry at line 117; finish-branch entry at line 156.
- AGENTS.md: skill anatomy (title; optional opening; numbered steps; terminal-state line; `Depth:` line), a description says what the skill produces and when to use it and must not summarise the steps, other skills named in full as `dietpowers:<name>`, own files as `${CLAUDE_SKILL_DIR}/<file>`.

## Tasks

### - [x] Task 1: The open-items queue

**Files**
- Modify `skills/adversarial-review/trackers.md`.
- Modify every existing `skills/*/SKILL.md` (ten files).
- Modify `skills/brainstorm/SKILL.md`, `skills/write-plan/SKILL.md`, `skills/update-spec/SKILL.md` (follow-up text).
- Modify `tests/skills/check-skills.sh`, `README.md`, `docs/testing.md`.

**Interfaces**
Produces the `## Open items` section and the adding sentence that Tasks 2 and 3 rely on.

**Context**
Global Constraints; References (trackers.md, shared paragraphs, current follow-up text, README lines).

**Behavior**
- `trackers.md` gains `## Open items` after `## Tracker format`, stating: the path; that it follows `## Working directory`; the item format block exactly as in Global Constraints; the `Next: N` rule; the statuses `open` and `kept`; the four outcomes with their meanings; the removal rule; that `add to #N` is not offered for a notes-file backlog; and that when the file cannot be written, the item is said in one line in the conversation instead.
- Every existing `SKILL.md` gains the adding sentence, exactly as in Global Constraints, as its own paragraph immediately after the question paragraph. In `skills/adversarial-review/SKILL.md` the path is `${CLAUDE_SKILL_DIR}/trackers.md`.
- The five follow-up passages are replaced with the Design wording from the spec: brainstorm step 2 "split it: brainstorm only the first, and add each of the others as an open item, to get its own spec later."; step 4 "If the report suggests a deep-research, pass that on and add it as an open item."; step 9's section list ends "Out of scope." (dropping ", including follow-ups"); write-plan step 1 "invoke the `dietpowers:update-spec` skill to remove all but one from the spec and add each of the others as an open item whose Why holds its removed sections word for word, then plan the one that remains."; update-spec step 2 "ask your partner whether to add it as an open item and carry on (recommended), or to pause the current work and start it now with the `dietpowers:brainstorm` skill."
- `check-skills.sh` gains: every `SKILL.md` contains `.dietpowers/trackers/open-items.md`; `trackers.md` contains `## Open items`, `Next: N`, `**file new**`, `**add to #N**`, `**keep**`, `**drop**`; and no file under `skills/` contains any of `in the spec's Out of scope section as follow-ups`, `Out of scope, including follow-ups`, `list it in the spec's Out of scope as a follow-up`, `as a follow-up in the spec's Out of scope section`, `to Out of scope as follow-ups`.
- README: the "What changed in each skill" intro gains one sentence: every skill adds later work to an open-items list in `.dietpowers/trackers/open-items.md` without asking; lines 114, 130 and 176 say open items instead of Out of scope follow-ups; "How dietpowers differs" gains a bullet: later work found anywhere in the flow goes to one open-items list, which a triage skill works through.
- `docs/testing.md`: the structural gate list names the open-items sentence and format.

**Tests**
- "every SKILL.md contains open-items path": fails if any skill lacks the adding sentence.
- "trackers.md Open items strings": fails if the section or an outcome label is missing.
- "old follow-up text gone": fails if any of the five old phrases remains.
- Add the assertions first and run the script: it must print a FAIL for each skill and each missing string, and for each old phrase still present. Then make the edits and confirm it passes.

Command: `bash tests/skills/check-skills.sh`

### - [x] Task 2: The triage-open-items skill and finish-branch's question

**Files**
- Create `skills/triage-open-items/SKILL.md`, imitating the anatomy of `skills/update-spec/SKILL.md`.
- Modify `skills/adversarial-review/trackers.md` (`## Replies`, `## Resuming`).
- Modify `skills/finish-branch/SKILL.md` (step 4).
- Modify `tests/skills/check-skills.sh`, `AGENTS.md`, `README.md`, `docs/testing.md`.

**Interfaces**
Consumes the `## Open items` section from Task 1. Produces the skill `dietpowers:triage-open-items`, invoked by the partner or by finish-branch, returning to finish-branch when it invoked it.

**Context**
Global Constraints; the spec's Design section `skills/triage-open-items/SKILL.md (new)` (steps 1-7, terminal state, pause and resume), copied as the skill's steps; References (trackers.md Replies and Resuming, finish-branch step 4, AGENTS.md anatomy, check-skills rules for every SKILL.md).

**Behavior**
- `skills/triage-open-items/SKILL.md`:
  - Frontmatter: `name: triage-open-items`; a description saying what it produces and when to use it, without summarising the steps, for example "Works through the open-items list with you and files, keeps or drops each item with your approval. Use when open items have piled up, when finish-branch offers triage, or to resume a paused triage."
  - Title and a short opening on why triage matters (later work found mid-flow is kept, matched against the backlog, and decided one item at a time).
  - The question paragraph copied verbatim from `skills/update-spec/SKILL.md`, then the adding sentence, then a commit sentence: triage commits nothing; a notes-file backlog edit is left on disk, and triage says so.
  - A sentence pointing to `## Open items`, `## Replies` and `## Resuming` in `${CLAUDE_SKILL_DIR}/../adversarial-review/trackers.md`.
  - Steps 0 (resume, as in the other skills) and 1-7 as in the spec's Design, including the outcome question's ending from Global Constraints. Step 6 records an item's Decision only after its outcome succeeds; on failure it clears the item's Decision and Question, with the error under Recommendation.
  - If finish-branch invoked triage and the partner replies `pause`, triage also says to resume the triage first and then run `/dietpowers:finish-branch` again to integrate.
  - Terminal state: "if the `dietpowers:finish-branch` skill invoked you, return to it; otherwise stop."
  - `Depth: ../adversarial-review/trackers.md`.
- `trackers.md`:
  - `## Replies` first sentence includes triage's item questions among those that offer `pause`, and the bullet on answers adds that triage records the Decision only after the outcome succeeds.
  - `## Resuming` gains an open-items case: `triage-open-items` resumes `.dietpowers/trackers/open-items.md`; no `Branch:` lookup; the file is unfinished while an item has a Question and no Decision; resume at that item with the lead-in, one line of the item's Why (in place of a Finding), and its recorded Question. Then triage re-reads the backlog as in its step 2, skips its steps 3 and 4, and carries on at step 5 with the items that have a Recommendation and no Decision. Step 2's list of own stages adds it.
- `finish-branch` step 4: before the integration question, and on the open-PR path before the push, if the open-items file has `open` items, ask "There are <N> open items. Triage them now? Reply with **triage** or **later**." On `triage`, invoke the `dietpowers:triage-open-items` skill, then continue.
- `check-skills.sh`: the expected skill set adds `triage-open-items`; `skills/finish-branch/SKILL.md` contains `dietpowers:triage-open-items` and `Triage them now?`; `trackers.md` contains `Question and no Decision`.
- `AGENTS.md` line 3: "10 skills" becomes "11 skills".
- README: the flow diagram gains `triage-open-items          open items: group, match the backlog, file, keep or drop` in the lower group; "What changed in each skill" gains a `triage-open-items` (new) entry; the finish-branch entry gains a line on the triage question.
- `docs/testing.md`: "exactly the ten expected skills" becomes "exactly the eleven expected skills"; add the manual trial from the spec's Success criterion 2 to the "Manual trials" section.

**Tests**
- "skill set mismatch": the expected list includes `triage-open-items`; fails until the directory exists.
- Per-skill rules (`Reply with`, `short bold label in words`, `say in one line what you are about to do`, the open-items path) now also check the new skill; fails if its question paragraph or adding sentence is missing.
- "finish-branch triage question": fails if `dietpowers:triage-open-items` or `Triage them now?` is missing.
- "trackers.md resume rule for open items": asserts `Question and no Decision`; fails if the Resuming open-items case is missing.
- Add the assertions first and run the script: it must FAIL on the skill set and the finish-branch strings. Then build and confirm it passes.

Command: `bash tests/skills/check-skills.sh`

Departure: the triage question sits at the start of finish-branch step 4, so it precedes both the menu and the open-PR push with one sentence. `docs/testing.md`'s "Manual trials of pause and resume" heading became "Manual trials" (nothing links to it).

### - [x] Task 3: Review deferrals can join the queue

**Files**
- Modify `skills/adversarial-review/SKILL.md` (steps 5 and 7).
- Modify `tests/skills/check-skills.sh`, `README.md`.

**Interfaces**
Consumes the adding sentence and `## Open items` from Task 1.

**Context**
Global Constraints (deferring a review finding); References (adversarial-review steps 5 and 7).

**Behavior**
- Step 5: the options offered for a finding become "fix as proposed, another fix, **add to open items**, **leave here**, won't fix and reject". Both new options set the item's status to `deferred`; **add to open items** also adds the finding as an open item. Add one sentence: review findings reach open items only through the **add to open items** answer; the adding sentence covers other later work noticed during a review.
- Step 7: "for a finding under `Out of scope`, recommend defer unless it is a blocker" becomes: for a finding under `Out of scope`, offer **add to open items** and **leave here** without recommending either, unless it is a blocker, which is recommended for fixing.
- `check-skills.sh`: `skills/adversarial-review/SKILL.md` contains `**add to open items**`, `**leave here**` and `only through the **add to open items** answer`, and does not contain `recommend defer unless it is a blocker`.
- README adversarial-review entry: a line saying a deferred finding can be added to open items or left in the tracker.

**Tests**
- "review defer options": fails if either label is missing.
- "old defer recommendation gone": fails if `recommend defer unless it is a blocker` remains.
- "review findings only by answer": asserts `only through the **add to open items** answer`; fails if the sentence is missing.
- Add the assertions first, see them FAIL, then edit and confirm the script passes.

Command: `bash tests/skills/check-skills.sh`

> **Changed 2026-10-03:** see the code-review note at the end of the spec.
