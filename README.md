# dietpowers

**Work in progress.** 

A linear, test-first development flow for Claude Code, tuned for `claude-opus-5-5`.

dietpowers is a fork of [tim-hub/superpowers-slim](https://github.com/tim-hub/superpowers-slim) by [Tim Bai](https://tim.bai.uno/), itself a cut-down fork of [obra/superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com/). 

## The flow

```
brainstorm        design, one question at a time; spec written
review (spec)     hostile review; fix; one re-review
write-plan        tasks: paths, interfaces, tests; no code
review (plan)     hostile review; fix; one re-review
execute-plan      one task at a time, test first
review (code)     hostile review of the branch; fix; one re-review
prove-done        evidence before any claim of done
finish-branch     full suite green, then merge, PR or keep

find-root-cause   root cause, then a regression test
handle-feedback   feedback from people, such as PR comments
```

## Usage

There is no session-start hook, so skills rarely start on their own. Start a piece of work by typing the skill as a slash command, followed by what you want:

```
/dietpowers:brainstorm add a CSV export to the reports page
```

Each skill hands on to the next and asks before each new stage. Other steps can be started directly:

```
/dietpowers:review the code on this branch against docs/dietpowers/2026-09-24-csv-export-plan.md
/dietpowers:find-root-cause the export test fails on empty reports
```

## Why dietpowers

Superpowers taught coding agents a disciplined process: agree a spec, plan, build test-first, review. As models improved, the process grew around them: capitalised instructions injected into every session, a fresh subagent for every task with a ledger of briefs, reports and review packages, and review loops of up to five rounds per task. Current models already do much of this themselves. Anthropic says Opus 5 "verifies its own work without being told to" ([Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5#task-scope-and-over-verification)), and Superpowers' maintainer says frontier models have "gotten better at executing work inline" ([6.4 release](https://blog.fsck.com/2026/09/21/superpowers-6.4/)). So the extra structure repeats work the model does anyway, or pulls against it, and features take longer and cost more than they need to. Users report the same in [issue #2017](https://github.com/obra/superpowers/issues/2017). Anthropic removed over 80% of Claude Code's own system prompt for Claude 5 models, saying "we were overconstraining Claude Code, both through our system prompt and in our CLAUDE.md files and skills" ([post](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models)).

dietpowers keeps what still pays for itself and drops the rest:

- **Keeps:** a spec agreed before any code, test-first implementation, and review by a fresh reviewer that has not seen the conversation.
- **Drops:** always-on instructions, per-task subagents and ledgers, emphatic rules, and code written into plans.
- **Aims for:** one linear flow biased toward simplicity and correctness. It does not try to go faster through parallel agents.

## What dietpowers changes from superpowers-slim

Ordered by impact, and by how far each departs from what Superpowers users expect.

- **Plan files carry no implementation code.** Superpowers writes every line into the plan, for an executor with "zero context for our codebase and questionable taste." Each task in the plan includes paths, signatures, behaviors and tests, and names the code change that would make each test fail. Our rationale:
  - Superpowers plan code is written without being run, then rewritten during execution.
  - Opus 5.5 is "strongest on multistep work in a real repository, such as carrying a change through a large code base until its tests pass" ([Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)).
  - Plan defects are often missing decisions, such as an ignored error-handling convention. Paths, interfaces, behaviors and tests capture those; code review catches code bugs later.
  - Shorter plans are faster to read and approve.
  - The trade-off: less is fixed before you approve, and tests are written during execution. Code review checks for tests that could never fail.
- **Every stage gets a hostile review in a clean context.** A `review` skill reviews the spec, the plan and the code, each with its own checklist. The reviewer is a fresh subagent on the same model, which has not seen the conversation. Superpowers dropped its spec and plan reviewers in 5.0.6 and, in subagent-driven mode, reviews code task by task.
- **Code is reviewed once, over the whole branch**, with the prompt from [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review), plus a test-suite run and a check for tests that cannot fail. superpowers-slim reviewed the last commit with a general "senior reviewer" prompt.
- **Fixes are checked once more, then the loop stops.** Code fixes start with a failing test. One re-review checks only the fixes, and anything still open goes to you. In subagent-driven mode, Superpowers allows up to five fix rounds per task.
- **You approve each step.** After the spec, the plan, the implementation and the review, the flow asks whether to continue and recommends an answer.
- **Brainstorming aims for the simplest well-grounded spec.** It looks up how the problem is usually solved, always offers the simplest approach and one built on existing libraries or patterns, pushes back on requests with a simpler route, asks only questions that change the design, and writes a spec with fixed sections: constraints, inputs and failure behavior, testable success criteria.
- **Research and context travel with the work.** The spec records the docs, library versions, API details and existing code it relies on, each with the specific fact used. The plan carries those facts once, in a References section, and each task names the references and files it needs. The executor reads both the plan and the spec. In superpowers-slim the plan had no link to the spec and the executor read only the plan, so research reached it only if the plan happened to repeat it.
- **Questions come one at a time,** as multiple choice with a recommended option and a reason.
- **Prompts tuned for Opus 5.5.** The skill and reviewer prompts are being revised, one file at a time, against Anthropic's [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5) guide.
- **One order and one folder.** All tasks are executed, then the branch is reviewed, then the work is finished; superpowers-slim's skills disagreed about when review happens. Specs and plans sit side by side in `docs/dietpowers/` as `YYYY-MM-DD-<topic>-spec.md` and `-plan.md`.
- **Imperative skill names.** `brainstorm`, `write-plan`, `execute-plan`, `tdd`, `review`, `prove-done`, `finish-branch`, `find-root-cause` and `handle-feedback` replace Superpowers' gerund-based naming convention.

## What superpowers-slim changed from superpowers

Taken from the [superpowers-slim README](https://github.com/tim-hub/superpowers-slim). It largely based these changes on Anthropic's post [The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models) (July 2026).

- **Claude Code only.** Upstream supports eleven agent tools.
- **9 skills instead of 14.** It deleted `using-superpowers`, `using-git-worktrees`, `subagent-driven-development`, `dispatching-parallel-agents` and `writing-skills`.
- **No session-start hook.** Nothing is injected into every session. Each skill loads only when invoked.
- **Inline execution.** The session that holds the plan implements it, one task at a time. Superpowers' subagent-driven development sends a fresh implementer and reviewers to every task; superpowers-slim dropped it because "that runtime cost dominates everything else these skills do." Superpowers' own [6.4 release](https://blog.fsck.com/2026/09/21/superpowers-6.4/) later measured its inline mode at about twice as fast and half the cost. dietpowers keeps inline execution and reviews the whole branch once at the end.
- **71% less prose.** Each skill is numbered steps. Iron Law fences, rationalization tables and red-flag lists are gone.
- **Fewer examples.** The good/bad code pairs and worked examples were removed, because the post says examples narrow what the model explores.
- **Detail in separate files.** `SKILL.md` holds the steps; longer reference material sits in files that load only when the model follows a pointer to them.

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
