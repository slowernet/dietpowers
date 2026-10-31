# Question probe results

The probe in `tests/question-probe/` (see `docs/testing.md`, "Question probe") runs a spec review of a made-up store-totals spec, with a fixed reviewer report of three planted bugs, and answers each question from a script. The bar (spec Success criterion 2): every check passes in all 3 branch runs.

The checks:

1. The shared rules file `shared/asking-questions.md` is read before the first question.
2. The tracker's `Goal:` line is written before the first finding question.
3. The refund bug (no refund rows exist yet, but the file format allows them) is asked, says the trigger does not exist now and why it could arise, and offers deferring.
4. The log-timestamp bug (local time where `data/README.md` requires UTC; no effect on totals) gets a one-line notice, no question, and lands in `.dietpowers/trackers/open-items.md`.
5. No question uses the reviewer's label "ledger roll-up" without explaining it, or refers to "the draft", "this goal" or "item N" without quoting it.
6. Each question says how many remain.

## Round 1, 2026-10-28

Model `claude-opus-5-5`, effort `high`, Claude Code 2.1.308. Branch at `20805ea`; 0.1.0 is `5ffdda8`. Run by the partner in a terminal, because this session's permission check blocks starting `claude` with `--dangerously-skip-permissions`.

The script scored check 2 as failed in all branch runs. That was a scoring bug: all three runs wrote the `Goal:` line before the first finding question, through Python inside a Bash command, and the script's pattern rejected the backslash before the quoted goal. The pattern is fixed; the table shows the corrected result. Checks 3 to 6 were scored by reading each run's `questions.md`.

| Check | Branch 1 | Branch 2 | Branch 3 | 0.1.0 1 | 0.1.0 2 | 0.1.0 3 |
|---|---|---|---|---|---|---|
| 1 | pass | pass | pass | fail (no such file) | fail | fail |
| 2 | pass | pass | pass | fail (no `Goal:` line) | fail | fail |
| 3 | pass | pass | pass | fail: does not say no refunds exist yet | fail: same | fail: same |
| 4 | pass | **fail**: deferred with no notice; first mentioned in the end report | **fail**: same | fail: asked as a question | fail: asked | fail: asked |
| 5 | pass | pass | pass | pass | pass | pass |
| 6 | pass | pass | pass | fail: "Item 1:" with no count | pass ("Item 1 of 3") | pass |

Also seen, outside the checks:

- All three branch runs, and the 0.1.0 runs, wrote progress lines that use tracker item numbers without saying which finding they mean, for example "Recording item 3 as deferred and adding it to open items as item 2" (branch run 2) and "Next I'll add the open item and ask about item 1" (branch run 1, where tracker item 1 was asked as question 2). Check 5 covers only questions, so these pass it.
- In all six runs the review also raised a fourth problem of its own: the spec's Design never filters rows by `date`.
- Branch run 1 raised the newline bug from major to blocker on its own, because it hits today's data; step 5 allows raising a grade.

Result: the bar is not met. Check 4 failed in 2 of 3 branch runs.

Questions from branch run 1, for reference: see the logs at `$TMPDIR/dietpowers-tests/1793198322-60748/question-probe/worktree/run-1/questions.md` (not kept in the repository).

## Fixes after round 1

- `3aa1486`: review step 5 gives both kinds of notice "before your first question" (spec note 2026-10-28, probe round 1).
- `b39c40c`: `shared/asking-questions.md` adds "Tracker item numbers are your notes too: in any message, name the finding, such as "the refund finding", instead of its number."

## Round 2, 2026-10-28

Same model, effort and CLI as round 1. Branch at `b39c40c`. Branch runs only; 0.1.0 is unchanged, so round 1's 0.1.0 runs stand as the comparison. Checks 3 to 6 were read from `questions.md`. Checks 1 and 2 were scored by the script; check 2 cannot be seen in `questions.md`, so the code review (2026-10-28) checked it in the stream logs: in all three runs the first tracker write before the first question recorded the quoted goal. The code review also tightened the script's check 2, which had counted commands that only read the tracker; rescoring rounds 1 and 2 with the tightened script gives the same results.

| Check | Branch 1 | Branch 2 | Branch 3 |
|---|---|---|---|
| 1 | pass | pass | pass |
| 2 | pass | pass | pass |
| 3 | pass | pass | pass |
| 4 | pass | pass | pass |
| 5 | pass | pass | pass |
| 6 | pass ("Question 1 of 2") | pass ("Question 1 of 3"; the review added its own date finding as a question) | pass |

Every run gave the log-timestamp notice in its first question message, for example (branch run 1): "**Not asking:** the spec logs each run with a local-time timestamp, but `data/README.md` says "All logs use UTC." The log line doesn't change the printed totals, so it doesn't block your goal. I've put it in `.dietpowers/trackers/open-items.md` for later."

No message in any run used a tracker item number, "ledger" or "roll-up". Progress lines named findings instead, for example "Next I'll add the newline finding to open items, then ask about refunds."

Result: the bar is met. Every check passes in all 3 branch runs.

## Round 3, 2026-10-31

Run for `dietpowers:prove-done`, because `ebadc35` changed the notice wording after round 2 (from "before your first question" to "before your first finding question in that pass, or before the report if no finding is asked"). Branch at `f4f84f4`. Model `claude-opus-5-5`, effort `high`, Claude Code 2.1.309. Checks 1 and 2 scored by `score.py`; checks 3 to 6 read from `questions.md`.

| Check | Branch 1 | Branch 2 | Branch 3 |
|---|---|---|---|
| 1 | pass | pass | pass |
| 2 | pass | pass | pass |
| 3 | pass | pass | pass |
| 4 | pass | pass | pass |
| 5 | pass | pass | pass |
| 6 | pass | pass | pass |

Each run gave the log-timestamp notice in its first question message, before "Question 1 of 2", for example (branch run 3): "**Noted, no reply needed:** the log line uses a local-time timestamp, but `data/README.md` says "All logs use UTC." I've added this to open items rather than asking, because the log doesn't change the printed totals." Open-item numbers appeared only next to the finding's name, such as "The missing-last-row finding is now open item #2".

Result: the bar is met on the current text. Every check passes in all 3 branch runs.
