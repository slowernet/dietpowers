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
prove-done        fresh full run; each success criterion shown; spec changes listed
finish-branch     full suite green, then merge, PR or keep

find-root-cause   root cause, failing test, one fix at the source
handle-feedback   feedback from people, such as PR comments
update-spec       approved change to specified behavior, noted in the spec
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

## How dietpowers differs from its upstreams

Ordered by how far each departs from what Superpowers users may expect.

- **Imperative skill names.** `brainstorm`, `write-plan`, `execute-plan`, `tdd`, `review`, `prove-done`, `finish-branch`, `find-root-cause` and `handle-feedback` replace Superpowers' gerund-based naming convention.
- **The spec stays the source of truth.** Any change to specified behavior, whether it comes up in planning, execution, review, debugging, PR feedback or from you, goes through one `update-spec` skill, which the other skills invoke once the spec is approved: you approve the change, only the affected sections change, a dated note under each changed section records what changed, why, and who approved it, and the spec is committed with the code. A new goal or feature goes back to `brainstorm` instead. Before finishing, `prove-done` pairs each success criterion with the test that shows it and lists every change since approval, so you see drift in one place.
- **Plan files carry no implementation code.** Superpowers writes every line into the plan, for an executor with "zero context for our codebase and questionable taste." Each task in the plan includes paths, signatures, behaviors and tests, and names the code change that would make each test fail. Our rationale:
  - Superpowers plan code is written without being run, then rewritten during execution.
  - Opus 5.5 is "strongest on multistep work in a real repository, such as carrying a change through a large code base until its tests pass" ([Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)).
  - Plan defects are often missing decisions, such as an ignored error-handling convention. Paths, interfaces, behaviors and tests capture those; code review catches code bugs later.
  - Shorter plans are faster to read and approve.
  - The trade-off: less is fixed before you approve, and tests are written during execution. Code review checks for tests that could never fail.
- **Spec, plan and code each get a hostile review.** A `review` skill reviews the spec, the plan and the code, each with its own checklist. The reviewer is a fresh subagent on the same model, which has not seen the conversation.
- **Code is reviewed once, over the whole branch**, with a test-suite run and a check for tests that cannot fail.
- **Fixes are checked once more, then the loop stops.** Code fixes start with a failing test. One re-review checks only the fixes, and anything still open goes to you. In subagent-driven mode, Superpowers allows up to five fix rounds per task.
- **You approve each step.** After the spec, the plan, the implementation and the review, the flow asks whether to continue and recommends an answer.
- **Brainstorming aims for the simplest well-grounded spec.** It looks up how the problem is usually solved, always offers the simplest approach and one built on existing libraries or patterns, pushes back on requests with a simpler route, asks only questions that change the design, and writes a spec with fixed sections: constraints, inputs and failure behavior, testable success criteria.
- **Research and context travel with the work.** The spec records the docs, library versions, API details and existing code it relies on, each with the specific fact used. The plan carries those facts once, in a References section, and each task names the references and files it needs. The executor reads both the plan and the spec. In superpowers-slim the plan had no link to the spec and the executor read only the plan, so research reached it only if the plan happened to repeat it.
- **Questions come one at a time,** as multiple choice with a recommended option and a reason.
- **Prompts tuned for Opus 5.5.** Skill and reviewer prompts were grounded against Anthropic's [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5) guide. See [What changed in each skill](#what-changed-in-each-skill).

### What superpowers-slim changed from superpowers

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

## What changed in each skill

Compared with superpowers-slim. Every skill that asks you anything gained the same rule: one question at a time, multiple choice, recommended option first with a reason. Most also gained a line asking for short messages that lead with the question or outcome.

- **`brainstorm`** (was `brainstorming`)
  - Description says only when to use it; "You MUST" and the summary of steps are gone.
  - Opens with why the spec matters and a preference for the simplest well-grounded design.
  - Reads context beyond what the request names.
  - Asks only questions that change the design and records routine calls as assumptions; covers input limits, failure and rerun behavior.
  - Pushes back when the request seems mistaken or a simpler change would do.
  - New research step for well-known problems and outside APIs or dependencies.
  - Approaches must include the simplest one and one built on an existing library or pattern.
  - One design approval replaces approval after each section; the self re-read is gone because a review follows.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-spec.md` with fixed sections, including testable success criteria and References.
  - Hands off to `review` instead of `writing-plans`.
- **`review`** (new; replaces `requesting-code-review`)
  - Reviews a spec, plan or code with a matching prompt, in a fresh subagent on the same model that reads its own prompt file and runs in the foreground.
  - Lists the clear-cut findings it will fix, with one-line reasons, without stopping; asks you, one at a time with a recommendation, only about findings it wants to reject, findings with more than one reasonable fix, and fixes that change the approved spec.
  - Edits a spec or plan under review directly; code fixes start with a failing test; a fix that changes the approved spec goes through `update-spec`.
  - Runs one scoped re-review, then stops.
  - Reports outcome first, then asks whether to continue to the next stage.
  - `spec-reviewer.md` (was `brainstorming/spec-document-reviewer-prompt.md`, which nothing used): rewritten as a hostile review with eight checks, including input limits, failure behavior, over-complex designs and reference facts.
  - `plan-reviewer.md` (was `writing-plans/plan-document-reviewer-prompt.md`, also unused): rewritten as a hostile review with seven checks, including tests that cannot fail and missing task context.
  - `code-reviewer.md` (was `requesting-code-review/code-reviewer.md`): the general "senior reviewer" prompt is replaced by [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review), plus a test-suite run, a check for tests that cannot fail, a check of departures recorded in commits, and a read-only rule. It reviews the whole branch instead of the last commit.
- **`write-plan`** (was `writing-plans`)
  - No implementation code and no TDD micro-steps.
  - Header: `Spec: <path> @ <commit>`, marking the approved spec, then goal, architecture, Global Constraints and shared References.
  - Each task: Files, Interfaces, Context, Behavior, and Tests naming the change that would make each fail, plus the command to run them.
  - Names an existing file for each new one to imitate.
  - The banned-phrase list, the self re-read and the subagent-era lines are gone.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-plan.md` and hands off to `review`.
- **`execute-plan`** (was `executing-plans`)
  - Reads the plan and the spec.
  - Builds each task with `tdd`, uses the plan's checkboxes as its task list, and uses `find-root-cause` for unclear failures.
  - Makes routine calls itself and records them in commits; asks only about changes to interfaces, requirements or other tasks, and routes changes to specified behavior through `update-spec`.
  - Names the stops it should and should not make.
  - Ends with a short report, then asks before code review; it used to go straight to finishing.
- **`tdd`** (was `test-driven-development`)
  - Explains why the test comes first.
  - Starts from the plan's Tests.
  - Code must work for every valid input, including those no test covers; a test is never weakened to get green, and a test that is wrong because the spec is wrong goes through `update-spec`.
  - Returns to the skill that invoked it; only on its own does it hand off to `review`.
  - `writing-good-tests.md`: each rule appears once, in one closing checklist; the quotes from Superpowers' author are gone. New: expected values taken from the spec or requirement before reading the implementation; deterministic, isolated, straight-line tests with clear failure messages; an order of preference for test doubles (real, then fake, then stub or mock), asserting outcomes before calls; the spec's input limits and failure behavior in the mutation check; and the project's existing suite takes precedence.
- **`prove-done`** (was `verification-before-completion`)
  - Runs at the end of a finished, reviewed branch instead of before any commit, and returns to the skill that invoked it.
  - Runs the full suite, linter and build fresh.
  - Lists every change to the spec since approval, from its `Changed` notes checked against git history from the plan's `Spec:` commit.
  - Pairs each current success criterion with the test or command that shows it, and never passes a criterion the code and spec disagree on.
  - The paragraph about paraphrases and "expressions of satisfaction" is gone.
- **`finish-branch`** (was `finishing-a-development-branch`)
  - Reuses `prove-done`'s run instead of running the suite again.
  - Asks the integration menu as one question, recommending the pull request unless you've said otherwise.
  - Writes the PR description from the run: what changed and why with a spec link, the commits grouped by plan task, each success criterion with its evidence, the spec's `Changed` notes, review findings fixed and rejected, and open items.
  - When a pull request is already open, pushes instead of showing the menu, and returns to the skill that invoked it.
  - Hands off to `handle-feedback` when PR comments arrive.
- **`handle-feedback`** (was `receiving-code-review`)
  - Opens with why: feedback is a claim to check, answered with changes and evidence.
  - Scoped to feedback from people and pull requests.
  - An item that could be read two ways blocks only itself and what depends on it.
  - Changes to specified behavior go through `update-spec`; each fix starts with a test that reproduces the problem.
  - Replies are drafted and approved by you, and posted in-thread only after `prove-done` and `finish-branch` have pushed the fixes.
- **`update-spec`** (new)
  - The one way specified behavior changes once you have approved the spec: states the change, gets approval, edits only the affected sections plus the plan's matching tasks, Global Constraints and References, adds a dated `Changed` note under each edited section, and commits with the code.
  - A declined change edits nothing, and the calling skill drops it.
  - Sends new goals or features back to `brainstorm`.
  - Called from `write-plan`, `execute-plan`, `review`, `tdd`, `handle-feedback`, `find-root-cause` and `prove-done`, or directly by you.
- **`find-root-cause`** (was `systematic-debugging`)
  - Opens with why the cause comes before the fix.
  - A bug in the spec goes through `update-spec` before the fix.
  - Returns to the skill that invoked it; otherwise commits and hands off to `review` instead of `test-driven-development`.
  - `defense-in-depth.md` ("validate at EVERY layer") is replaced by `guards-after-a-fix.md`: validate at system boundaries, and add an internal guard only where the bug showed the boundary can be bypassed, with a test.
  - `root-cause-tracing.md` loses its diagrams, "NEVER" nodes and session anecdote (739 to 375 words).
  - `condition-based-waiting.md` is trimmed, and its 666-word example file, written for one specific project, is gone.
  - `find-polluter.sh` stops with an error when the pollution exists before any test runs, instead of reporting "all tests clean"; runs test paths containing spaces as one file; and no longer calls itself a bisection script.

### Sources

- Anthropic, [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5): the primary guide.
- Anthropic, [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5): used only where the 5.5 guide is silent.
- Anthropic, [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices).
- Anthropic, [The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models).
- Claude Code [skills documentation](https://code.claude.com/docs/en/skills) and Anthropic's [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).
- [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review).
- obra/superpowers [release notes](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md) and issues [#2017](https://github.com/obra/superpowers/issues/2017) and [#2112](https://github.com/obra/superpowers/issues/2112).
- Google, *Software Engineering at Google*: [Unit Testing](https://abseil.io/resources/swe-book/html/ch12.html) and [Test Doubles](https://abseil.io/resources/swe-book/html/ch13.html).
- Kent Beck, [Test Desiderata](https://testdesiderata.com/).
- [From Business Requirements to Test Assertions](https://arxiv.org/abs/2607.10277) and [VibeCheck](https://arxiv.org/abs/2609.05978), 2026 preprints, not yet peer reviewed.
- Birgitta Böckeler, [Understanding Spec-Driven Development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html).

## Contributing

See `AGENTS.md`. Run `bash tests/skills/check-skills.sh` after any skill edit. To trial the flow, also load `dev/` (`--plugin-dir /path/to/dietpowers/dev`), which logs problems with the skills to `.claude/dietpowers/problems.md` in the project you are working on.

## License

MIT, see `LICENSE`. The upstream projects keep their copyright.
