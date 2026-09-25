# dietpowers

A linear, test-first development flow for Claude Code, in 9 short skills.

**Work in progress.** The skills have not been run end to end on real work yet. Expect breaking changes, and do not rely on it.

dietpowers is a fork of [tim-hub/superpowers-slim](https://github.com/tim-hub/superpowers-slim). superpowers-slim is a cut-down copy of [obra/superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and Prime Radiant. It kept the Superpowers steps and cut 71% of the prose. It also removed the session-start hook (a script Claude Code runs when a session opens) and subagent-driven development. This fork adds three reviews and puts the skills in one fixed order.

Each review is done by a fresh-context hostile reviewer: a subagent that has not seen the conversation and is told to hunt for faults.

## The flow

```
brainstorming                 spec, one question at a time; your approval
  └ spec review               fresh-context hostile reviewer; revise; your review
writing-plans                 task-by-task plan in TDD order
  └ plan review               fresh-context hostile reviewer; revise; your approval
executing-plans               inline, one task at a time, each via test-driven-development
requesting-code-review        fresh-context hostile reviewer over the whole branch
receiving-code-review         fix what holds, test first; one scoped re-review of the fixes; stop
verification-before-completion
finishing-a-development-branch   full suite green, then merge, PR or keep

systematic-debugging ──▶ test-driven-development   (lock the fix with a regression test)
```

Each skill ends by naming the next. There is no session-start hook, so start a piece of work by naming the first skill, for example `/dietpowers:brainstorming`, or by asking Claude to use it. The superpowers-slim author measured that without a hook, brainstorming starts on its own in 0 to 2 of 15 runs (`docs/superpowers/baseline/2026-08-04-after.md`).

## What changed from superpowers-slim

- **The spec gets a hostile review.** A fresh-context reviewer checks it before you do. superpowers-slim had only a self-check and your review.
- **The plan gets a hostile review and your approval.** superpowers-slim had neither.
- **Code review is hostile and covers the whole branch.** superpowers-slim used a general "senior reviewer" prompt over the last commit only. The new prompt is based on [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review).
- **Review fixes are checked once more, then the loop stops.** Each fix starts with a failing test, one re-review checks only the fixes, and anything still open goes to you.
- **One order.** All tasks are executed first, then the branch is reviewed, then the work is finished. superpowers-slim's skills disagreed about when review happens.
- **A new name.** `dietpowers` installs alongside Superpowers without a clash.

Every reviewer gets the same three instructions: say nothing about what is fine; give a concrete trigger (the input, sequence or timing that causes the problem) for each finding; and say "No issues found" when there are none.

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
