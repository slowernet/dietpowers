# Question content: implementation plan

Spec: docs/dietpowers/2026-10-27-question-content-spec.md @ e021870
Base: main
Commits: approved

Goal: the skills read shared rules for question content before their first question, and the review settles the partner's goal once and decides routine findings against it.

Architecture: one new shared file, `shared/asking-questions.md`, read by all 11 skills through a pointer sentence in their question paragraph. The review-only rules go into `shared/making-recommendations.md` and `skills/adversarial-review/SKILL.md` step 5, with matching changes to `shared/trackers.md`. A probe harness under `tests/question-probe/` runs the review against a fixture with a fixed reviewer report, on 0.1.0 and on the branch, and the results are recorded.

## Global Constraints

Copied verbatim from the spec.

- New file `shared/asking-questions.md` at the plugin root, with this content:

  ```markdown
  # Asking questions

  Your partner should be able to answer a question on first read, without scrolling back or opening another file. Before you send a question, check it against these:

  - Make it stand alone. Say in the question what is being decided, and quote any goal, draft text or earlier item it depends on; never write "this goal", "item 3" or "the draft" without quoting it.
  - Lead with the problem in everyday terms: what breaks, for whom, and when. Names of files, classes and methods come after. Then give each option with its risk.
  - Give one concrete example, from your partner's own code or data where you can.
  - Use the names the code, spec and files already use, and the precise technical term for the thing at the centre of the question: say "strings" and "symbols", not "two forms". Do not invent labels.
  - A name you made up while working, or one from a document your partner has not read, such as a reviewer's report or a test fixture, is not shared vocabulary. Before you use it in a message, say what the thing is in plain words, with an example. Tracker item numbers are your notes too: in any message, name the finding, such as "the refund finding", instead of its number.
  - Justify an option by what another part of the system needs only when that part exists or its spec states the need.
  - In a sequence of questions, say where your partner is, such as "question 4 of 6". If the count grows, say why, for example that a fix check added findings.
  - Know the goal each decision serves. When you are unsure what a decision is for, or how exact, complete or correct the work must be, ask your partner about the goal before asking about the detail. Once it is settled, quote it in their words where it matters and decide routine questions against it yourself; ask again only when something comes up that it does not cover.

  A question whose text a skill gives in quotes is asked as written. When you ask a recorded question again on resume, update only its position count.
  ```

  > **Changed 2026-10-28:** see the note under the spec's Constraints (shorthand rule added).
  > **Changed 2026-10-28 (probe round 1):** see the spec's Constraints (tracker item numbers).

- Pointer sentence, appended to the question paragraph ("Ask your partner one question at a time, ...") in all 11 `skills/*/SKILL.md`, after its last sentence; the rest of the paragraph is unchanged: "Before your first question, read `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` and follow it; if it cannot be read, say so once and carry on."
- `Depth:` line: every `SKILL.md` names `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` on its `Depth:` line, last in the list. A skill with no `Depth:` line (execute-plan, finish-branch, handle-feedback, prove-done, update-spec, write-plan) gets `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` as its last line.
- New bullet in `shared/making-recommendations.md`, after the first bullet: "- For a review finding, say what triggers it (the data, state or usage it needs), whether that exists now where the work will run, and how often. Check with a quick read-only query or file read when one is cheap and needs no credentials or access your partner has not already given; otherwise say it is unverified. If the trigger does not exist now, say so, and when you ask about the finding, offer deferring it as a full option."
- Review tracker header field, added to `## Tracker format` in `shared/trackers.md` after `FIX_BASE:`: "- `Goal:` the goal the review serves, quoted from the spec's Goal section or from `REQUIREMENTS`, and how exact, complete or correct the work must be, in your partner's words where they gave them. Recorded at review step 5."
- `shared/trackers.md` `## Resuming` step 5: "check it now, as in the first pass (a minor finding with one reasonable fix gets a notice; the rest are asked)" becomes "check it now, as in review step 5". The `Question:` field's "`notice only` for a minor finding fixed without asking" becomes "`notice only` for a minor finding fixed without asking, or a major deferred because it does not block the recorded goal".

## References

- `AGENTS.md`: a `SKILL.md` loads in full; other files load only when the model follows a pointer. `${CLAUDE_PLUGIN_ROOT}` is substituted only in a `SKILL.md`. Run `bash tests/skills/check-skills.sh` after any skill edit.
- The question paragraph is one line, identical in all 11 `skills/*/SKILL.md`, and ends "...after your partner answers, say what comes next before starting it." It is line 10 or 11 of each file.
- Existing `Depth:` lines (all are the last line of their file except find-root-cause, whose line continues with a sentence):
  - `skills/adversarial-review/SKILL.md:39` `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/trackers.md, ${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md`
  - `skills/brainstorm/SKILL.md:41` `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/trackers.md, researcher.md`
  - `skills/tdd/SKILL.md:31` `Depth: writing-good-tests.md, ${CLAUDE_PLUGIN_ROOT}/shared/condition-based-waiting.md`
  - `skills/find-root-cause/SKILL.md:49` `Depth: root-cause-tracing.md, guards-after-a-fix.md, ${CLAUDE_PLUGIN_ROOT}/shared/condition-based-waiting.md. To find which test creates unwanted files, run ...` (the new entry goes after `condition-based-waiting.md`, before the full stop that starts the sentence)
  - `skills/triage-open-items/SKILL.md:31` `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/trackers.md`
  - none in execute-plan, finish-branch, handle-feedback, prove-done, update-spec, write-plan.
- `tests/skills/check-skills.sh`: `fail "<message>"` records a failure; question-format checks at lines 56-66; review checks at lines 98-106 (`R="$SKILLS_DIR/adversarial-review/SKILL.md"`, the `for want in ...` list includes the adversarial-review `Depth:` line); brainstorm checks at 108-113; making-recommendations checks at 203-214 (`MR="shared/making-recommendations.md"`). New checks follow the same `grep -qF ... || fail ...` pattern.
- `skills/adversarial-review/SKILL.md` step 5 (line 24-27): first line "5. Decide which findings go to your partner. First read `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md` and follow it; if it cannot be read, say so once and carry on."; then three sub-bullets: the minor-finding notice bullet, the ask bullet beginning "Every blocker and major finding, and any finding you want to reject, downgrade, ...", which contains "Review findings reach open items only through the **add to open items** answer", and "You may raise a grade on your own; lower one only by asking." Terminal state line contains "recommending it only when no blocker or major item is `deferred` either".
- `shared/trackers.md`: review header list at lines 21-27 (`FIX_BASE:` at 26); `Question:` field at line 36; `## Resuming` step 4 at line 103 ("If the tracker cannot be read or is missing a field, say which, and ask whether to continue with what is readable or leave the tracker.") and step 5 at line 104.
- The spec's Inputs and failure behavior: "Resuming a review tracker written before this change, with no `Goal:` line: the review records the line before asking the next question, asking once if needed. This is not treated as a missing field under `## Resuming` step 4." The spec's Design: the step 5 goal question "is not a tracker item and does not offer `pause`."
- `README.md`: "## What changed in each skill" at line 104; its first paragraph (line 106) begins "Every skill that asks you anything gained the same rule"; the `adversarial-review` entry starts at line 121, and its second bullet says "every blocker and major, and ..." are asked.
- `docs/testing.md`: sections `## Behavioral tests` (33), `### Measuring autotrigger rate` (40), `### Explicit skill requests` (64), `## Manual trials` (79), `## Reading behavioral results` (94).
- `tests/claude-code/measure-autotrigger.sh`: the pattern for a behavioral script: `set -uo pipefail`, flag parsing with `-n` and `-p`, `claude -p ... --plugin-dir "$PLUGIN_DIR" --setting-sources project --dangerously-skip-permissions --max-turns N --output-format stream-json --verbose`, a timeout via `gtimeout`/`timeout`, logs under `${TMPDIR:-/tmp}/dietpowers-tests/`, workspaces outside the log directory, exit non-zero only for broken setup.
- `claude --help` (v2.1.308) offers `--model` and `--effort`, and no temperature flag. `--resume <session-id>` continues a session; the stream-json `init` event carries `session_id`.
- 0.1.0 is commit `5ffdda8` on `main`.

## Tasks

### - [x] Task 1: Shared question rules, read by all skills

Files:
- Create `shared/asking-questions.md` (imitate `shared/making-recommendations.md`: title, one opening line, bullets).
- Modify all 11 `skills/*/SKILL.md`.
- Modify `tests/skills/check-skills.sh`.
- Modify `README.md`.

Interfaces: produces `shared/asking-questions.md`, consumed by every skill through `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md`.

Context: Global Constraints (shared file content, pointer sentence, `Depth:` rule); References on the question paragraph, `Depth:` lines, check script and README.

Behavior:
1. `shared/asking-questions.md` holds exactly the content in Global Constraints.
2. In each `SKILL.md`, the question paragraph keeps its text and ends with a space and the pointer sentence exactly as in Global Constraints.
3. Each `SKILL.md` has one `Depth:` line naming `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` last, as in Global Constraints and the References list. The six skills without one gain `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` as their last line, after a blank line.
4. `check-skills.sh` gains a block, placed after the question-format checks at lines 56-66, that fails when: `shared/asking-questions.md` is missing, or lacks `Know the goal each decision serves`, `question 4 of 6` or `is not shared vocabulary`; any `SKILL.md` lacks the string ``read `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` ``; any `SKILL.md` has no line starting `Depth:` that contains `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md`.
5. `README.md` line 106: the paragraph gains, after its first sentence, the sentence from the spec's Design: "Each also reads `shared/asking-questions.md` before its first question: questions stand alone, lead with the problem in everyday terms, give an example, use the names the code already uses, explain any name your partner has not seen before using it, say how many remain, and ask about the goal before the detail when the goal is unclear."

Tests (all in `check-skills.sh`; run with `bash tests/skills/check-skills.sh`, expect `PASS` and exit 0):
- `asking-questions.md exists with its rules`: fails if the file is deleted or the goal bullet, position example or shorthand rule is removed.
- `every SKILL.md points to asking-questions.md`: fails if the pointer sentence is removed from any one skill.
- `every Depth line names asking-questions.md`: fails if any skill's `Depth:` line drops the file or the line is missing.
- Before editing the skills, add the checks and run the script once to see them fail (11 pointer and 11 `Depth:` failures and the missing file); record that output in the task's commit message.

### - [x] Task 2: Review rules: trigger, goal and notice-deferred majors

Files:
- Modify `shared/making-recommendations.md`.
- Modify `skills/adversarial-review/SKILL.md`.
- Modify `shared/trackers.md`.
- Modify `tests/skills/check-skills.sh`.
- Modify `README.md`.

Interfaces: consumes `shared/asking-questions.md` from Task 1 (the goal rule the step 5 question follows). Produces the tracker header field `Goal:`.

Context: Global Constraints (the making-recommendations bullet, the `Goal:` field, the two `shared/trackers.md` changes); the spec's Design bullets for `skills/adversarial-review/SKILL.md`, copied below; References on step 5, trackers.md and README.

Behavior:
1. `shared/making-recommendations.md`: the new bullet from Global Constraints, inserted after the first bullet.
2. `shared/trackers.md`: the `Goal:` field inserted after the `FIX_BASE:` line; `## Resuming` step 5 and the `Question:` field changed exactly as in Global Constraints. `## Resuming` step 4 gains, after its sentence: "A review tracker with no `Goal:` line is not missing a field: record the line as in review step 5 before asking the next question."
3. `skills/adversarial-review/SKILL.md` step 5, from the spec's Design:
   - After the pointer sentence on the step 5 line, append: "Then record the tracker's `Goal:` line. If the spec or `REQUIREMENTS` does not settle how exact, complete or correct the work must be, ask your partner once before any finding, and record the answer. This question is not a tracker item and does not offer `pause`."
   - A new sub-bullet after the minor-finding bullet: "A major finding that holds but plainly does not block the recorded goal, and that you do not want to reject or downgrade: mark it `deferred`, add it as an open item as the **add to open items** answer does, set its Question to `notice only`, and before your first question, tell your partner in one line the finding and why it does not block the goal. Do not wait for a reply. This applies even when its fix would change the approved spec, since deferring it changes nothing. If your partner objects, remove the open item added for it, set the finding back to `open` with its Question recorded, and ask. When a major finding's trigger does not exist now, judge whether it could realistically arise where the work will run, such as on other data, for other users or with later use. If it could, ask it. If it could not, before your first question, tell your partner in one line what the trigger is and why it cannot arise, set the item to `deferred` with Question `notice only`, and do not wait for a reply."
   - The ask bullet's opening "Every blocker and major finding, and any finding you want to reject, downgrade, ..." becomes "Every blocker, every major finding that blocks the recorded goal or whose bearing on it is unclear, and any finding you want to reject, downgrade, ..."; the rest of the bullet unchanged except: "Review findings reach open items only through the **add to open items** answer" becomes "Review findings reach open items only through the **add to open items** answer or the non-blocking major bullet above".
   - Terminal state: "recommending it only when no blocker or major item is `deferred` either" becomes "recommending it only when no blocker or major item is `deferred` either, other than majors whose Question is `notice only`".
   > **Changed 2026-10-28:** see the spec's note under Design (notice applies in spec reviews too).
   > **Changed 2026-10-28 (probe round 1):** see the spec's note under Design (notices before the first question).
   - Steps 6 and 7 and "You may raise a grade on your own; lower one only by asking." are unchanged.
4. `check-skills.sh`, in the review block and the making-recommendations block, fails when: the step 5 line (`grep -E '^5\. '`) lacks `` `Goal:` ``; the review lacks `plainly does not block the recorded goal`; `shared/making-recommendations.md` lacks `say what triggers it` or `read-only`; `shared/trackers.md` lacks `` `Goal:` ``, `as in review step 5` or `with no `Goal:` line is not missing a field`, or still contains `as in the first pass`; the review lacks `does not offer `pause``. The existing adversarial-review `Depth:` entry in the `for want in` list (line 100) becomes the full new line from Task 1.
5. `README.md`, `adversarial-review` entry: add the bullet from the spec's Design after the bullet on deferred findings: "Records the goal the review serves in the tracker, asking once if the spec leaves unclear how exact the work must be; says what triggers each finding and whether that trigger exists now; defers a major finding that does not block that goal with a one-line notice, and asks about the rest." In the entry's second bullet, "every blocker and major" becomes "every blocker, and every major that blocks the goal or whose bearing on it is unclear", so the README does not contradict the new step 5.

Tests (in `check-skills.sh`; run `bash tests/skills/check-skills.sh`, expect `PASS`):
- `review step 5 records the goal`: fails if the `Goal:` sentence leaves step 5.
- `review defers non-blocking majors`: fails if the new sub-bullet is removed.
- `notice applies in spec reviews`: fails if "since deferring it changes nothing" is removed from the review.
- `notices come before the first question`: fails if "before your first question, tell your partner in one line the finding" is removed from the review.
- `making-recommendations names the trigger, read-only`: fails if either phrase is removed.
- `trackers.md: Goal field and resume via step 5`: fails if the `Goal:` field or the missing-`Goal:` resume sentence is removed, or the old "as in the first pass" text returns.
- Add the checks first and run the script to see them fail; record the output in the commit message.

### - [x] Task 3: Probe harness and fixture

Files:
- Create `tests/question-probe/run-probe.sh` (imitate `tests/claude-code/measure-autotrigger.sh`).
- Create `tests/question-probe/fixed-report.md` (the replacement reviewer prompt).
- Create `tests/question-probe/fixture/` with `docs/dietpowers/2026-10-27-store-totals-spec.md`, `data/README.md`, `data/store-a.csv`, `data/store-b.csv`.
- Modify `docs/testing.md`.

Interfaces:
- `bash tests/question-probe/run-probe.sh [-n RUNS] [-r GIT_REF] [-m MODEL] [-e EFFORT] [-t MAX_TURNS]`. `-r` builds the plugin copy from a git ref with `git archive` (`-r 5ffdda8` for 0.1.0); without `-r` it copies the working tree. Defaults: `-n 3`, `-m claude-opus-5-5`, `-e` the value `claude --help` lists as the default or `high` (check the allowed values before choosing), `-t 30`.
- Output: a directory `${TMPDIR:-/tmp}/dietpowers-tests/<timestamp>-<pid>/question-probe/<label>/run-<i>/` holding `stream-*.json` (one per turn), `questions.md` (every top-level assistant message in order, numbered, with those containing `Reply with` marked as questions), a copy of the workspace's `.dietpowers/trackers/`, and `score.txt`. The script prints one summary line per run.

Context: References on `measure-autotrigger.sh`, `claude --help` and 0.1.0; the spec's Success criterion 2, copied here:

> Probe: a fixture repository with a spec, run against two copies of the plugin, 0.1.0 and the branch. In both copies, `skills/adversarial-review/spec-reviewer.md` is replaced by a prompt that returns the same fixed report, so both see the same findings and the normal first pass (steps 1 to 5) is tested: (a) a major finding whose trigger does not exist in the fixture's data but could realistically arise there, for example data the fixture's other records already show; (b) a major finding that does not block the spec's goal and whose trigger exists; (c) a major finding that blocks the goal, worded with a label the spec does not use. The review runs three times on each copy, with the model and effort level pinned. The replies are scripted: if the review asks about the goal, the reply is the fixture spec's Goal section quoted with "as written"; each finding question is answered **add to open items**. A run ends after the last step 5 question is answered; steps 6 and 7 are not scored. Checks: 1. a Read of `shared/asking-questions.md` appears before the first question; 2. the tracker has a `Goal:` line before the first finding question; 3. finding (a)'s question says its trigger does not exist now, why it could arise, and offers deferring as a full option; 4. finding (b) gets a one-line notice and no question, and is in `.dietpowers/trackers/open-items.md`; 5. no question uses (c)'s label without saying what it refers to, and no question refers to "the draft", "this goal" or "item N" without quoting it; 6. each question in the sequence says how many remain. The criterion is met when every check passes in all 3 branch runs. A failed run is diagnosed and the skill text fixed before the probe runs again; a run is never repeated only to get a pass.

Behavior:
1. Fixture: a spec for a command that prints each store's daily sales total from `data/*.csv`, for the owner to read each morning. Its Goal section says the totals must be correct for every store. `data/README.md` documents the CSV columns: `type`, with allowed values `sale` and `refund`, and `amount`, a positive number for both `sale` and `refund` rows. It also says all logs use UTC. No CSV currently has a `refund` row. `store-b.csv` has no trailing newline. The spec calls the computation "store totals" and never uses the word "ledger". The spec's Design contains the text that makes each finding hold: (a) "Each store's total is the sum of the `amount` column of every row."; (b) "Each run logs one line with a local-time timestamp."; (c) "Rows are the lines of the file that end with a newline character."
2. `fixed-report.md` tells the reviewer to output this report and nothing else, in the spec reviewer's finding format (`### ISSUE N: <title>`, `Section:`, `Check:`, `Severity:`, body, `Scenario:`, `Fix:`):
   - (a) major: refunds are added to the total instead of subtracted. Trigger: a `refund` row; none exists now, but `data/README.md` allows them.
   - (b) major: log lines use local time, not UTC as `data/README.md` requires. Scenario: two runs an hour apart across the daylight-saving change log the same hour. Trigger exists on every run; the goal (correct totals read by the owner) does not depend on log timestamps.
   - (c) major: "the ledger roll-up drops the last row when the file has no trailing newline". Trigger exists (`store-b.csv`); blocks the goal.
3. For each run, the script: copies the fixture into a fresh workspace outside the log directory, runs `git init`, creates branch `store-totals`, commits; builds the plugin copy and replaces its `skills/adversarial-review/spec-reviewer.md` with `fixed-report.md`; sends the first turn `/dietpowers:adversarial-review spec docs/dietpowers/2026-10-27-store-totals-spec.md. You may commit the spec to this branch.`; then loops: take the last assistant text of the turn and its last line containing `Reply with`; if that line contains `**pause**`, send `add to open items`; else if the line contains `**continue**`, stop; else if it has no `**pause**`, the text contains `goal` in any case, and the goal reply has not been sent yet in this run, send the fixture's Goal section followed by ` as written`; otherwise stop. Each follow-up uses `claude -p --resume <session_id>` with the same flags. At most 8 follow-ups.
4. Scoring in `score.txt`, per run: check 1 automatically (index of the first `Read` tool call whose path ends `shared/asking-questions.md` is before the first assistant text containing `Reply with`); check 2 automatically from the stream logs (the first Write or Edit tool call on the review tracker whose content has a `Goal:` line with text after `Goal:` comes before the first assistant text whose `Reply with` line contains `**pause**`); check 4 in two parts: automatically, `open-items.md` contains `UTC` or `local time`; by hand, from `questions.md`, finding (b) got a one-line notice and no question offering options for it; checks 3, 5 and 6, and the second part of check 4, marked `manual`, scored by reading `questions.md`, which lists every top-level assistant message in order, not only questions, so notices can be seen.
5. The script exits non-zero only for broken setup: an empty stream log, a plugin copy without `skills/adversarial-review/SKILL.md`, or a missing `claude`.
6. `docs/testing.md`: a new `### Question probe` section under `## Behavioral tests`, after `### Explicit skill requests`, saying what the probe tests, how to run it on the branch and on 0.1.0 (`-r 5ffdda8`), how the replies are scripted, which checks are automatic and which are read from `questions.md`, and the pass bar from criterion 2.

Tests:
- `bash -n tests/question-probe/run-probe.sh` passes.
- `bash scripts/lint-shell.sh tests/question-probe/run-probe.sh` passes (if the linter takes a path; otherwise run it as the repository does).
- One smoke run, `bash tests/question-probe/run-probe.sh -n 1`, completes, writes `questions.md` with at least one question and a `score.txt` with all six check lines, and the run's review tracker marks all three findings as holding under Verified. This fails if the reply loop stops at the first question, the plugin copy is not loaded, or the fixture spec does not contain the bugs.
- `bash tests/skills/check-skills.sh` still passes.

Departure: `scripts/lint-shell.sh` could not run, because `shellcheck` is not installed; `bash -n` passes. The scoring is inline Python in `run-probe.sh`, as `tests/claude-code/analyze-token-usage.py` already uses Python. The session's permission check blocks starting `claude` with `--dangerously-skip-permissions`, so the partner runs the probe in a terminal. The smoke run (2026-10-28) completed: all three findings held under Verified, and the scripted replies reached the final question. It showed two problems, both fixed in `bb20014`: check 1 counted only the Read tool, while the model read the file with `cat`; and the notice for a non-blocking major never fired in a spec review (see the spec's 2026-10-28 note).

### - [ ] Task 4: Run the probe and record the result

Files:
- Create `docs/dietpowers/2026-10-27-question-content-probe-results.md`.
- Modify skill text only if a run fails, as Behavior 3 says.

Interfaces: consumes `tests/question-probe/run-probe.sh` from Task 3.

Context: the criterion 2 text quoted in Task 3; `docs/testing.md` `## Reading behavioral results`.

Behavior:
1. Run `bash tests/question-probe/run-probe.sh -n 3 -r 5ffdda8` (0.1.0) and `bash tests/question-probe/run-probe.sh -n 3` (branch), with the same `-m` and `-e`.
2. Score checks 3, 5 and 6, and check 4's notice part, by reading each run's `questions.md`. Write the results file: date, model, effort, CLI version, a table of runs by checks (pass, fail, with a one-line reason for each fail), and the questions of one branch run quoted for reference.
3. If any check fails in any branch run: diagnose from the logs, change the skill text that caused it (through `dietpowers:update-spec` if the change alters behavior the spec describes), rerun all 3 branch runs, and record both rounds in the results file. Never rerun only to get a pass.
4. The task is done when every check passes in all 3 branch runs, or, after two rounds of fixes, when the remaining failures are reported to the partner with the logs.

Tests: the probe itself; the pass condition is criterion 2's bar. `bash tests/skills/check-skills.sh` passes after any skill text change.
