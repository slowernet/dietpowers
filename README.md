# dietpowers

A linear, test-first development flow for Claude Code, in 9 short skills.

**Work in progress.** 

dietpowers is a fork of [tim-hub/superpowers-slim](https://github.com/tim-hub/superpowers-slim). superpowers-slim is a cut-down copy of [obra/superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and Prime Radiant. It kept the Superpowers steps and cut 71% of the prose. It also removed the session-start hook (a script Claude Code runs when a session opens) and subagent-driven development. This fork adds three reviews and puts the skills in one fixed order.

Each review is done by a fresh-context hostile reviewer: a subagent that has not seen the conversation and is told to hunt for faults.

## The flow

```
brainstorming                 design, one question at a time; your approval; spec written
adversarial-review (spec)     fresh-context hostile reviewer; fix; one re-review
  ? continue with writing-plans
writing-plans                 task-by-task plan in TDD order
adversarial-review (plan)     fresh-context hostile reviewer; fix; one re-review
  ? continue with executing-plans
executing-plans               inline, one task at a time, each via test-driven-development
  ? continue with code review
adversarial-review (code)     fresh-context hostile reviewer over the whole branch; fix test-first; one re-review
  ? continue to finishing
verification-before-completion
finishing-a-development-branch   full suite green, then merge, PR or keep

systematic-debugging ──▶ test-driven-development   (lock the fix with a regression test)
receiving-code-review         for feedback from people, such as PR comments
```

Each skill ends by naming the next. Each `?` is a question to you, with a recommended answer; the flow stops there until you answer. There is no session-start hook, so start a piece of work by naming the first skill, for example `/dietpowers:brainstorming`, or by asking Claude to use it. The superpowers-slim author measured that without a hook, brainstorming starts on its own in 0 to 2 of 15 runs (`docs/superpowers/baseline/2026-08-04-after.md`).

## What changed from superpowers-slim

- **Every stage gets a hostile review.** One `adversarial-review` skill reviews the spec, the plan and the code, each with its own checklist. The reviewer is a fresh subagent that has not seen the conversation. superpowers-slim reviewed only code, with a general "senior reviewer" prompt over the last commit.
- **Code review covers the whole branch**, with the prompt from [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review), plus a test-suite run and a check for tests that cannot fail.
- **Fixes are checked once more, then the loop stops.** Code fixes start with a failing test. One re-review checks only the fixes, and anything still open goes to you.
- **You approve each step.** After the spec, the plan, the implementation and the review, the flow asks whether to continue and recommends an answer.
- **Questions come one at a time,** as multiple choice with a recommended option and a reason.
- **One order.** All tasks are executed first, then the branch is reviewed, then the work is finished. superpowers-slim's skills disagreed about when review happens.
- **A new name.** `dietpowers` installs alongside Superpowers without a clash.

Every reviewer prompt gives the same three instructions: say nothing about what is fine; give a concrete trigger (the input, sequence or timing that causes the problem) for each finding; and say "No issues found" (for code, "No bugs found") when there are none.

## Installation

```bash
/plugin marketplace add slowernet/dietpowers
/plugin install dietpowers
```

For local development:

```bash
claude --plugin-dir /path/to/dietpowers
```

## Contributing

See `AGENTS.md`. Run `bash tests/skills/check-skills.sh` after any skill edit.

## License

MIT, see `LICENSE`. The upstream projects keep their copyright.
