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

- the skill set is exactly the nine expected skills;
- each `SKILL.md` has frontmatter with exactly the keys `name` and `description`, and the frontmatter
  is under 1024 characters;
- no `@`-link force-loads another skill (an `@` path makes Claude Code load that file at once);
- no file under `skills/` references a deleted skill;
- each `SKILL.md` is within its word ceiling, the most words it may contain.

It exits 0, or prints one `FAIL:` line per violation.

Word ceilings live in the `budget()` function in that script. When a skill needs more room, raise its
ceiling there. Do not drop a workflow step to fit.

Two more scripts: `bash tests/shell-lint/test-lint-shell.sh` covers `scripts/lint-shell.sh`, and
`bash tests/systematic-debugging/test-find-polluter.sh` covers that skill's bisection helper.

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
`dietpowers:brainstorming` fired, how often a file was written before any skill call, and how often the
turn budget cut the run off.

The script reports a rate and never fails on it. It exits 0 whenever the runs completed, so a `0/15`
firing rate is a result to record. It exits non-zero only when the test setup is broken. This skill set
has no session-start hook. `brainstorming`'s description does carry binding language, wording that
orders the model to act: `"You MUST use this before any creative work..."`. It is still an open
question what makes the model call a first skill.

Run it outside any command sandbox (a shell that blocks some file access). Inside one, a plugin
SessionStart hook fails with EPERM, a permission error, under `~/.claude`, so the run measures a
broken hook.

See `tests/claude-code/README.md` for the `-p` flag, used to compare two trees.

### Explicit skill requests under pressure

```bash
bash tests/explicit-skill-requests/run-all.sh
```

The runner sends four prompts. Each names a skill and also pushes the model to skip process, for
example "Don't waste time, just read the plan and start implementing immediately". A prompt passes if
the named skill still fired. The runner also reports whether any tool ran before the skill did.

The other prompts in `prompts/` are run by `run-test.sh`, `run-haiku-test.sh`,
`run-multiturn-test.sh` and `run-extended-multiturn-test.sh`, each invoked on its own.

## Reading behavioral results

Each run is one sample, so a single pass is weak evidence. `--max-turns 3` can also stop a run before
a skill is invoked, which produces a false FAIL. When a result informs a decision, run it three times
and report all three.

Recorded before/after measurements live in `docs/superpowers/baseline/`.

## Not included

Upstream's skill-behavior evals use the drill harness from
[superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/). That harness is not part
of this repo. `.pre-commit-config.yaml` still carries three hooks scoped to `^evals/.*\.py$`. This repo
has no `evals/` directory, so they never fire.
