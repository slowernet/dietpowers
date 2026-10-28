# Testing

There are two kinds of test. Structural tests check the shape of the skill files. Behavioral tests
check what an agent does when the skills load.

- **Structural**: is the skill set well-formed? Fast, gives the same result every run, makes no API
  calls. Run on every edit.
- **Behavioral**: does an agent invoke the right skill at the right moment? Slow, one sample per run,
  needs a working `claude` CLI.

## Structural gate

A gate is a check that must pass before a change goes in.

```bash
bash tests/skills/check-skills.sh
```

The script checks that:

- the skill set is exactly the eleven expected skills;
- each `SKILL.md` has frontmatter with the keys `name` and `description`, and optionally `argument-hint`, and the frontmatter
  is under 1024 characters;
- no `@`-link force-loads another skill (an `@` path makes Claude Code load that file at once);
- no file under `skills/` references a renamed or deleted skill;
- the text the flow depends on is present, and replaced text is gone: plain-text questions ending in `Reply with`, the commit rules for code and for the spec and plan, `shared/trackers.md` and the pointers to it, `shared/making-recommendations.md` and the review's pointer to it, the reviewers' severity lines and fix-check sections, the brainstorm research step and `researcher.md`, the open-items sentence in every skill and the `## Open items` format in `trackers.md`, and the README's descriptions of these.

It exits 0, or prints one `FAIL:` line per violation.

Two more scripts: `bash tests/shell-lint/test-lint-shell.sh` covers `scripts/lint-shell.sh`, and
`bash tests/find-root-cause/test-find-polluter.sh` covers that skill's `find-polluter.sh`, which runs test files one at a time.

## Behavioral tests

Both suites load this checkout with `--plugin-dir` and read the JSON stream the CLI prints. Both
require `--verbose` alongside `--print` and `--output-format stream-json`. Without it the CLI exits
at once and the harness reports a FAIL. That FAIL looks like a behavior failure, but the missing flag
caused it.

### Measuring autotrigger rate

Autotriggering means the model calls a skill on its own, without the user naming it.

```bash
bash tests/claude-code/measure-autotrigger.sh -n 15
```

The script sends exactly `Let's make a react todo list` N times. It reports how often
`dietpowers:brainstorm` fired, how often a file was written before any skill call, and how often the
turn budget cut the run off.

The script reports a rate and never fails on it. It exits 0 whenever the runs completed, so a `0/15`
firing rate is a result to record. It exits non-zero only when the test setup is broken. This skill set
has no session-start hook, and `brainstorm`'s description no longer carries the upstream
`"You MUST use this before any creative work..."` wording, so expect a rate near zero. Start work by
naming the skill.

Run it outside any command sandbox (a shell that blocks some file access). Inside one, a plugin
SessionStart hook fails with EPERM, a permission error, under `~/.claude`, so the run measures a
broken hook.

See `tests/claude-code/README.md` for the `-p` flag, used to compare two trees.

### Explicit skill requests

```bash
bash tests/explicit-skill-requests/run-all.sh
```

The runner sends four prompts that each name a skill: `execute-plan-please.txt`, `use-find-root-cause.txt`,
`please-use-brainstorm.txt` and `mid-conversation-execute-plan.txt`. A prompt passes if the named skill
fired. The runner also reports whether any tool ran before the skill did. `skip-formalities.txt`, run on
its own with `run-test.sh`, adds pressure to skip process ("Don't waste time - just read the plan and
start implementing immediately").

The other prompts in `prompts/` can be run one at a time with `run-test.sh <skill> <prompt-file>`.
`run-multiturn-test.sh` and `run-extended-multiturn-test.sh` carry their own prompts.

### Question probe

```bash
bash tests/question-probe/run-probe.sh -n 3              # this checkout
bash tests/question-probe/run-probe.sh -n 3 -r 5ffdda8   # 0.1.0, for comparison
```

The probe tests how the review asks its questions, the rules in `shared/asking-questions.md` and review step 5. It copies `tests/question-probe/fixture/` into a fresh git repository: a short spec for a command that prints each store's daily sales total, and the sales files it reads. It builds a copy of the plugin, from this checkout or from a git ref with `-r`, and replaces that copy's `spec-reviewer.md` with `tests/question-probe/fixed-report.md`, so every run gets the same three findings:

- refunds are added to a store's total instead of subtracted; no sales file has a refund row yet, but `data/README.md` allows them, so the review should ask, say the trigger does not exist now and why it could arise, and offer deferring;
- log lines use local time where `data/README.md` requires UTC; this does not affect the totals, so the review should defer it with a one-line notice;
- the "ledger roll-up" drops the last row of a file with no trailing newline; the spec never says "ledger", so a question should not use that name without saying what it means.

The partner's replies are scripted: a question whose `Reply with` line offers `**pause**` gets `add to open items`; the first other question that mentions the goal gets the spec's Goal section followed by "as written"; the script stops at the continue, revise or stop question, or after 8 replies. `-m` and `-e` pin the model and effort level (defaults `claude-opus-5-5` and `high`).

`tests/question-probe/score.py` does the scoring; `python3 tests/question-probe/test-score.py` tests which tool calls count as recording the goal for check 2. Each run writes, under `${TMPDIR:-/tmp}/dietpowers-tests/`, the stream logs, a copy of the run's trackers, `questions.md` (every message the review sent, in order, with the scripted replies) and `score.txt`. Checks 1 and 2 (the shared file read before the first question; the `Goal:` line written before the first finding question) and the open-items half of check 4 are scored automatically. Checks 3, 5 and 6 (the refund question; no unexplained "ledger roll-up" and no unquoted "the draft", "this goal" or "item N"; each question saying how many remain) and the notice half of check 4 are scored by reading `questions.md`.

The bar: every check passes in all 3 runs on the branch. 0.1.0 is expected to fail checks 1, 2 and 4, which test rules it does not have. A failed run is diagnosed and the skill text fixed before the probe runs again; never rerun only to get a pass. Like the other suites, run it outside any command sandbox.

## Manual trials

To test resuming a paused review, brainstorm or triage, pause in one session, then say `resume` in a new session, so the skill has to work from the tracker file alone. Over ACP there is no `/clear`; open a new session instead. Afterwards, `git check-ignore -v .dietpowers/trackers/<tracker>` should name `.dietpowers/.gitignore`.

To test open items and triage:

- During brainstorm on a request with two independent parts, the second part should be added to `.dietpowers/trackers/open-items.md` with a one-line notice and no question.
- `/dietpowers:triage-open-items` with three items, two of them about the same thing, should merge those two.
- With a GitHub backlog holding a close match, it should recommend **add to #N** for that item.
- After answers of **file new**, **keep** and **drop**, only the kept item should remain in the file, and the new issue should exist.
- At `finish-branch` with an open item, the triage question should come before the integration question.
- On the PR-feedback path, `handle-feedback` should ask the triage question after posting its replies, and `finish-branch` should not ask it.

To test making recommendations: in a review of a spec or plan where the reviewer's proposed fix for a finding would create a new problem, the review should read `shared/making-recommendations.md` before asking, say in one line why that fix is not offered, offer only correct options, and recommend the clearest, stating trade-offs where they matter.

## Reading behavioral results

Each run is one sample, so a single pass is weak evidence. A low `--max-turns` (the multi-turn scripts use 2 and 3)
can also stop a run before a skill is invoked, which produces a false FAIL. When a result informs a decision, run it three times
and report all three.

Recorded before/after measurements live in superpowers-slim's [`docs/superpowers/baseline/`](https://github.com/tim-hub/superpowers-slim/tree/master/docs/superpowers/baseline).

## Not included

Upstream's skill-behavior evals use the drill harness from
[superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/). That harness is not part
of this repo.
