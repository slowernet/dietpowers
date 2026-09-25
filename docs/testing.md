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

- the skill set is exactly the ten expected skills;
- each `SKILL.md` has frontmatter with the keys `name` and `description`, and optionally `argument-hint`, and the frontmatter
  is under 1024 characters;
- no `@`-link force-loads another skill (an `@` path makes Claude Code load that file at once);
- no file under `skills/` references a renamed or deleted skill.

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

## Reading behavioral results

Each run is one sample, so a single pass is weak evidence. A low `--max-turns` (the multi-turn scripts use 2 and 3)
can also stop a run before a skill is invoked, which produces a false FAIL. When a result informs a decision, run it three times
and report all three.

Recorded before/after measurements live in superpowers-slim's [`docs/superpowers/baseline/`](https://github.com/tim-hub/superpowers-slim/tree/master/docs/superpowers/baseline).

## Not included

Upstream's skill-behavior evals use the drill harness from
[superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/). That harness is not part
of this repo.
