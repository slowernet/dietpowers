# Trackers

A tracker is a file on disk that records a review or brainstorm as it goes: each question, the evidence behind it, and the answer. It lets your partner pause with one word and resume later, even in a fresh session with none of this conversation, and it is where the pull request's review record comes from. Write it so that a session reading only the tracker and the repository can carry on.

## Working directory

Trackers live in `.dietpowers/trackers/` at the root of the git work tree, outside `.claude/`, which Claude Code protects from writes without a permission prompt. When you create `.dietpowers/`, also write `.dietpowers/.gitignore` containing the single line `*`, so nothing in it is ever committed; if the directory already exists without that file, write the file.

Keep no tracker, and offer no `pause`, when the directory cannot be written, when the project is not in a git work tree, or when HEAD is detached. Tell your partner which, and carry on without one.

## Tracker format

Path: `.dietpowers/trackers/YYYY-MM-DD-<topic>-<stage>.md`, dated the day you create it.

- `<stage>` is `brainstorm`, `spec-review`, `plan-review` or `code-review`.
- `<topic>` is the topic in the spec's filename (`YYYY-MM-DD-<topic>-spec.md`); for any other filename, its name stem; for a code review with no spec, the branch name with `/` replaced by `-`.
- If the name is taken, append `-2`, `-3` and so on to the topic. Every run of a stage gets a new tracker; never reuse one for a new run.

Record paths relative to the repository root.

Review tracker header:

- `Stage:` and the reviewed document.
- `Branch:`
- The values passed to the first reviewer: the prompt file, and whichever of `SPEC_FILE_PATH`, `PLAN_FILE_PATH`, `SPEC_AND_PLAN_PATHS`, `REQUIREMENTS` (verbatim) and `BASE_SHA` apply. The second pass reuses them.
- `FIX_BASE:` for a code review, once recorded.
- `Second pass:` one of `pending`, `done (N findings)`, `not run (<reason>)`.

Brainstorm tracker header: `Stage: brainstorm`, the request, `Branch:`, `Research:`, left empty until the research step runs and then `skipped, <reason>` if it is skipped, and `Spec:`, left empty until the spec file is saved. A brainstorm tracker has no `Second pass:` line.

Each review item:

- Heading: `### N. [status] <title> (<severity>, review <1|2>)`. Severity is `blocker`, `major` or `minor`.
- **Finding:** the failure scenario and the proposed fix, in enough detail to decide on without the reviewer's report.
- **Verified:** the file and line, or the calculation, that shows whether it holds. An item with no Verified line has not been checked yet.
- **Question:** the question exactly as asked, kept while the item is `open`; `notice only` for a minor finding fixed without asking.
- **Decision:** the choice and its reason, dated.
- **Fix:** what changed, and the commit, or `uncommitted`.

Each brainstorm item has the heading `### N. [open|answered] <title>` and holds the question exactly as asked and the answer. Before asking your partner to approve text, such as the approaches or the design, write that text into the tracker, and have the item point to it.

Review item statuses:

- `open`: awaiting a decision.
- `fix`: decided, awaiting the fix.
- `fixed`, `deferred`, `won't fix`, `rejected`: closed.
- `duplicate of N`: matches item N in this tracker.

Brainstorm item statuses: `open` and `answered`.

Code reviewer severities map to these grades: CRITICAL and HIGH are `blocker`, MEDIUM is `major`, LOW is `minor`.

Example review item:

```markdown
### 4. [open] Retry after timeout double-charges the card (blocker, review 1)
- Finding: `charge()` retries on timeout without an idempotency key, so a slow first attempt that succeeds is followed by a second charge. Fix: send the order ID as the idempotency key on every attempt.
- Verified: `src/billing/charge.ts:88` retries with a fresh request; no key is set anywhere in `src/billing/`.
- Question: A timeout retry can charge a card twice. Fix as proposed (recommended: one header, no schema change), or retry only on connection errors? Reply with **fix**, **retry-only**, or **pause**.
- Decision:
- Fix:
```

## Open items

Open items are later work: something worth doing that the current work does not include, found at any point in the flow. They are queued in `.dietpowers/trackers/open-items.md`, which follows `## Working directory` above. When that directory cannot be written, say the item in one line in the conversation instead. Adding an item asks nothing.

The file starts with the title `# Open items`, then the line `Next: N`, the number the next added item takes. When an add creates the file, it writes the title, then `Next: 2`, then item 1. Each add uses the number and increments it, so numbers are never reused. A merged item keeps the lowest of its numbers.

Each item:

```markdown
### N. [open] <title>
- Found: YYYY-MM-DD, branch <branch>, <skill>
- Why: what to do later and why, with its evidence (paths, links, and any designed text it removes from the spec, word for word)
- Recommendation:
- Question:
- Decision:
```

Statuses: `open` (not yet triaged) and `kept`.

The `dietpowers:triage-open-items` skill works through the file. Its outcomes, one per item: **file new** (open a new item in the backlog), **add to #N** (comment on a matching backlog item, naming it), **keep** (the item stays, status `kept`, and is offered again in the next triage) and **drop**. For a notes-file backlog, **add to #N** is not offered. An item leaves the file once its outcome is carried out: after the new backlog item or comment exists, or at once for **drop**.

## Replies

Offer `pause` only on tracker items: brainstorm's questions, review's finding questions and triage's item questions. The commit, menu and terminal questions do not offer it.

- An option, or your partner's own alternative, is an answer. Record it as the item's Decision and move on; triage records it only once the outcome has succeeded.
- A question, an aside or a complaint is not an answer. Respond to it, then ask the same item again, keeping the problem statement in the question; if you reword it, record the new wording as the item's Question.
- An empty or unclear reply is not an answer either. Ask again.
- `pause` stops the sequence. The item stays `open` with its Question recorded. Say `Paused at item <N>. Say "resume" any time.` and stop.

Nothing but an answer to the current item moves the sequence on, and no reply licenses deciding the remaining items yourself.

## Resuming

Resume only when your partner asks.

1. A review tracker is unfinished while it has an `open` or `fix` item, or `Second pass: pending`. A brainstorm tracker is unfinished while its `Spec:` line is empty.
2. Look only at your own stages: brainstorm resumes `brainstorm` trackers; review resumes `spec-review`, `plan-review` and `code-review` trackers; triage resumes `.dietpowers/trackers/open-items.md`, as described after step 7.
3. Take the most recently modified unfinished tracker whose `Branch:` is the current branch. Say which one, and list any other unfinished ones on this branch, before the lead-in in step 5. If there is none on this branch, say so, change nothing, and give the number of unfinished trackers on other branches.
4. If the tracker cannot be read or is missing a field, say which, and ask whether to continue with what is readable or leave the tracker.
5. Find the first `open` item. In a review tracker, an item with no Verified line was never checked: check it now, as in the first pass (a minor finding with one reasonable fix gets a notice; the rest are asked). Otherwise, say `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.` exactly, with nothing inserted, then give one line of the item's Finding and any text the item points to, and ask its recorded Question verbatim.
6. If the reply describes a change to the design, route it through the `dietpowers:update-spec` skill (in a brainstorm, fold it into the design instead), and set back to `open` any earlier item it affects.
7. Then carry on. In a review: the remaining `open` items, then the `fix` items, then the second pass if it is still `pending`. In a brainstorm: the remaining `open` items; with none open, resume at the earliest unfinished brainstorm step, judged from the tracker: the purpose questions (brainstorm step 3); then research (step 4), not yet run while `Research:` is empty and there is no research proposal item; then the remaining design questions (step 5); then the approaches, the design, its approval, and the spec.

Open items have no `Branch:` line, so triage skips step 3. `open-items.md` is unfinished while an item has a Question and no Decision. Resume at that item: say the lead-in from step 5, give one line of the item's Why in place of a Finding, and ask its recorded Question verbatim. Then re-read the backlog as in triage's step 2, skip triage's steps 3 and 4, and carry on at its step 5 with the items that have a Recommendation and no Decision.
