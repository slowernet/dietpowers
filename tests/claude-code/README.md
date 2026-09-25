# Claude Code skills tests

Behavioral tests for the skills, driven through the Claude Code CLI.

## Overview

These tests run Claude Code in headless mode (`claude -p`, no interactive session) with this checkout
loaded via `--plugin-dir`. They then read the JSON stream to see which skills fired and what the model
did before they fired. They test behavior. `tests/skills/check-skills.sh` checks the skill files
themselves.

## Requirements

- Claude Code CLI in PATH (`claude --version` should work)
- `jq`

`--output-format stream-json` requires `--verbose` when combined with `--print`. Without it the CLI
exits at once and a test reports a FAIL. That FAIL looks like a behavior failure, but the missing flag
caused it.

## Running tests

```bash
./measure-autotrigger.sh -n 15
```

There is no runner that calls all the tests. `run-skill-tests.sh` was deleted when the one test it
wrapped became a measurement script.

## Current tests

### measure-autotrigger.sh

Autotriggering means the model calls a skill on its own, without the user naming it.

The script sends exactly `Let's make a react todo list` N times against one tree. It reports how often
`dietpowers:brainstorm` fired, how often a file was written before any skill call, and how often the
turn budget cut the run off.

It never passes or fails on the rate. Autotriggering is a probabilistic model behavior, so the script
reports a rate and exits 0 whenever the runs completed. It exits non-zero only when the test setup is
broken:

- a log is empty;
- a bare skill name appears in the registered commands, which means `--setting-sources project` did
  not take effect and a personal `~/.claude/skills` copy is in play;
- a plugin hook did not succeed.

```bash
./measure-autotrigger.sh -n 15                        # current tree, 15 runs
./measure-autotrigger.sh -n 15 -p /path/to/other      # compare another checkout
./measure-autotrigger.sh -n 3 -t 3                    # lower turn budget
```

**Run it outside any command sandbox** (a shell that blocks some file access). Inside one, a plugin
SessionStart hook fails with EPERM, a permission error, under `~/.claude`. The hook's output never
reaches the model, so the run measures a broken hook while reporting the hook as present.

There is no session-start hook. superpowers-slim's recorded measurements live in its
[`docs/superpowers/baseline/`](https://github.com/tim-hub/superpowers-slim/tree/master/docs/superpowers/baseline).

## Test structure

### analyze-token-usage.py

Counts token use in a captured JSON stream.

## Adding new tests

1. Create `test-<name>.sh`, writing output under `${TMPDIR:-/tmp}`. A hardcoded `/tmp` is not
   writable in every environment.
2. Keep the agent's working directory out of that log path. The agent sees its working directory, so
   `superpowers`, a skill name, or `test` in the path can prompt the behavior you are trying to
   measure.
3. Pass `--setting-sources project` so `~/.claude` skills, hooks and CLAUDE.md stay out of the run.
   Require the `dietpowers:` prefix when matching a skill invocation.
4. `chmod +x test-<name>.sh`.

There is no runner to register with. Invoke the script directly.

## Related

- `tests/skills/check-skills.sh`: structural gate, a check that must pass (skill set, frontmatter,
  references)
- `tests/explicit-skill-requests/`: checks that a skill still fires when the user names it and also
  pushes the model to skip process
- `docs/testing.md`: how the structural and behavioral tests relate
