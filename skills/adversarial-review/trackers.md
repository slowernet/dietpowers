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

## Replies

Offer `pause` only on tracker items: brainstorm's questions and review's finding questions. The commit, menu and terminal questions do not offer it.

- An option, or your partner's own alternative, is an answer. Record it as the item's Decision and move on.
- A question, an aside or a complaint is not an answer. Respond to it, then ask the same item again, keeping the problem statement in the question; if you reword it, record the new wording as the item's Question.
- An empty or unclear reply is not an answer either. Ask again.
- `pause` stops the sequence. The item stays `open` with its Question recorded. Say `Paused at item <N>. Say "resume" any time.` and stop.

Nothing but an answer to the current item moves the sequence on, and no reply licenses deciding the remaining items yourself.

## Resuming

Resume only when your partner asks.

1. A review tracker is unfinished while it has an `open` or `fix` item, or `Second pass: pending`. A brainstorm tracker is unfinished while its `Spec:` line is empty.
2. Look only at your own stages: brainstorm resumes `brainstorm` trackers; review resumes `spec-review`, `plan-review` and `code-review` trackers.
3. Take the most recently modified unfinished tracker whose `Branch:` is the current branch. Say which one, and list any other unfinished ones on this branch, before the lead-in in step 5. If there is none on this branch, say so, change nothing, and give the number of unfinished trackers on other branches.
4. If the tracker cannot be read or is missing a field, say which, and ask whether to continue with what is readable or leave the tracker.
5. Find the first `open` item. In a review tracker, an item with no Verified line was never checked: check it now, as in the first pass (a minor finding with one reasonable fix gets a notice; the rest are asked). Otherwise, say `Resuming <tracker file> at item <N>. If anything changed while you were away, say so.` exactly, with nothing inserted, then give one line of the item's Finding and any text the item points to, and ask its recorded Question verbatim.
6. If the reply describes a change to the design, route it through the `dietpowers:update-spec` skill (in a brainstorm, fold it into the design instead), and set back to `open` any earlier item it affects.
7. Then carry on. In a review: the remaining `open` items, then the `fix` items, then the second pass if it is still `pending`. In a brainstorm: the remaining `open` items; with none open, resume at the earliest unfinished brainstorm step, judged from the tracker: the purpose questions (brainstorm step 3); then research (step 4), not yet run while `Research:` is empty and there is no research proposal item; then the remaining design questions (step 5); then the approaches, the design, its approval, and the spec.
