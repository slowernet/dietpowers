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
- **The spec stays the source of truth.** Any change to specified behavior, whether it comes up in planning, execution, review, debugging, PR feedback or from you, goes through one `update-spec` skill: you approve it, only the affected sections change, a dated note under each changed section records what changed, why, and who approved it, and the spec is committed with the code. A new goal or feature goes back to `brainstorm` instead. Before finishing, `prove-done` pairs each success criterion with the test that shows it and lists every change since approval, so you see drift in one place.
- **Questions come one at a time,** as multiple choice with a recommended option and a reason.
- **Prompts tuned for Opus 5.5.** The skill and reviewer prompts are being revised, one file at a time, against Anthropic's [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5) guide. See [What changed in each skill](#what-changed-in-each-skill).
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

## What changed in each skill

Compared with superpowers-slim. Every skill that asks the user anything gained the same rule: one question at a time, multiple choice, recommended option first with a reason. Most also gained a line asking for short messages that lead with the question or outcome.

Each skill lists what grounds its changes. Sources, strongest first:

- **[5.5]** Anthropic, [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5). The primary guide.
- **[Opus 5]** Anthropic, [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5). The 5.5 guide calls its patterns "a reasonable starting point"; used only where 5.5 is silent.
- **[BP]** Anthropic, [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices), which apply to all current models.
- **[CE]** Anthropic, [The new rules of context engineering for Claude 5 generation models](https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models).
- **[Skills]** Claude Code [skills docs](https://code.claude.com/docs/en/skills) and Anthropic's [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).
- **[AR]** [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review).
- **[SP]** Superpowers' own history and issues, such as [#2017](https://github.com/obra/superpowers/issues/2017) (cost and speed) and [#2112](https://github.com/obra/superpowers/issues/2112) (review rounds that keep adding tests).
- **[Tests]** Google, *Software Engineering at Google*, chapters on [unit testing](https://abseil.io/resources/swe-book/html/ch12.html) and [test doubles](https://abseil.io/resources/swe-book/html/ch13.html); Kent Beck, [Test Desiderata](https://testdesiderata.com/); and two 2026 preprints, not yet peer reviewed, on tests written by AI tools: [requirements versus implementation in generated assertions](https://arxiv.org/abs/2607.10277) and [VibeCheck](https://arxiv.org/abs/2609.05978).
- **[SDD]** Birgitta Böckeler, [Understanding Spec-Driven Development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), on keeping a spec current as work proceeds.
- **Flow:** changes made so the skills fit together, with no outside source.

- **`brainstorm`** (was `brainstorming`)
  - Grounded in: [5.5] Opus 5.5 "tends to get to work quickly" and should look through sources the task does not mention, and stops for "decisions ... none of [which] blocks" are unwanted; [BP] give the reason behind instructions, and keep complexity to "the minimum needed"; [CE] no emphatic wording; [Opus 5] say so when "a better approach exists"; Flow: sections the plan and reviewers rely on.
  - Description names when to use it; "You MUST" and the summary of steps are gone.
  - Opens with why the spec matters and a preference for the simplest well-grounded design.
  - Reads context beyond what the request names.
  - Asks only questions that change the design and records routine calls as assumptions; covers input limits, failure and rerun behavior.
  - Pushes back when the request seems mistaken or a simpler change would do.
  - New research step for well-known problems and outside APIs or dependencies.
  - Approaches must include the simplest one and one built on an existing library or pattern.
  - One design approval replaces approval after each section; the self re-read is gone because a review follows.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-spec.md` with fixed sections, including testable success criteria and References.
  - Hands off to `review`.
- **`review`** (new; replaces `requesting-code-review`)
  - Grounded in: [5.5] wait for a running subagent before treating a task as done; [AR] the code-review prompt; [Opus 5] review prompts that say "only report high-severity issues" make the model report less, so ours limit scope, never severity; [SP] #2112, review rounds that keep adding tests, for stopping after one re-review; [Skills] a subagent reads its own prompt file, which keeps it out of the main context.
  - Reviews a spec, plan or code with a matching prompt, in a fresh subagent on the same model that reads its own prompt file and runs in the foreground.
  - Checks each finding, fixes what holds (test first for code), routes any fix that changes specified behavior through `update-spec`, runs one scoped re-review, then stops.
  - Reports outcome first, then asks whether to continue to the next stage.
  - `spec-reviewer.md` (was `brainstorming/spec-document-reviewer-prompt.md`, which nothing used): rewritten as a hostile review with eight checks, including input limits, failure behavior, over-complex designs and reference facts.
  - `plan-reviewer.md` (was `writing-plans/plan-document-reviewer-prompt.md`, also unused): rewritten as a hostile review with seven checks, including tests that cannot fail and missing task context.
  - `code-reviewer.md` (was `requesting-code-review/code-reviewer.md`): the general "senior reviewer" prompt is replaced by [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review), plus a test-suite run, a check for tests that cannot fail, a check of departures recorded in commits, and a read-only rule. It reviews the whole branch.
- **`write-plan`** (was `writing-plans`)
  - Grounded in: [5.5] Opus 5.5 is "strongest on multistep work in a real repository"; [Opus 5] it works best "given the complete task specification up front"; [CE] no instructions repeated across skills (the TDD steps live in `tdd`); Flow: plans linked to specs, and references carried once.
  - No implementation code and no TDD micro-steps.
  - Header: `Spec:` link, goal, architecture, Global Constraints, and shared References.
  - Each task: Files, Interfaces, Context, Behavior, and Tests naming the change that would make each fail, plus the command to run them.
  - Names an existing file for each new one to imitate.
  - The banned-phrase list, the self re-read and the subagent-era lines are gone.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-plan.md` and hands off to `review`.
- **`execute-plan`** (was `executing-plans`)
  - Grounded in: [5.5] name the early stops to avoid and the ones wanted, put status notes "in the same message as your next tool call", and keep tasks "in a checklist the model updates"; [Opus 5] check in "only when different readings ... would lead to materially different work"; Flow: no-code plans and `update-spec`.
  - Reads the plan and the spec.
  - Builds each task with `tdd`, uses the plan's checkboxes as its task list, and uses `find-root-cause` for unclear failures.
  - Makes routine calls itself and records them in commits; asks only about changes to interfaces, requirements or other tasks, and routes changes to specified behavior through `update-spec`.
  - Names the stops it should and should not make.
  - Ends with a short report, then asks before code review (it used to go straight to finishing).
- **`tdd`** (was `test-driven-development`)
  - Grounded in: [BP] "implement a solution that works correctly for all valid inputs, not just the test cases" and report tests that are wrong rather than work around them; [BP] give the reason for a rule; [SP] Superpowers found removing its TDD rebuttals made results worse, so the delete rule stays.
  - Explains why the test comes first.
  - Starts from the plan's Tests.
  - Code must work for every valid input, not only the test's; a test is never weakened to get green, and a test that is wrong because the spec is wrong goes through `update-spec`.
  - Inside a plan it returns to `execute-plan` instead of requesting a review.
  - `writing-good-tests.md`: each rule now appears once; the two gate functions, the mutation check, the quick reference and the warning signs are merged into one checklist; the quotes from Superpowers' author are gone (1,309 to 1,026 words). It then gained: expected values taken from the spec before reading the implementation; tests that are deterministic, isolated and straight-line, with clear failure messages; an order of preference for test doubles (real, then fake, then stub or mock) with outcomes asserted before calls; and the spec's input limits and failure behavior in the mutation check. Grounded in [Tests].
- **`prove-done`** (was `verification-before-completion`)
  - Grounded in: [Opus 5] explicit verification instructions "cause over-verification", so there is one final check instead of scattered ones; [5.5] reports should say "what it did, what it found, and what it needs from you"; Flow: success criteria from the spec, and drift from `update-spec`.
  - Runs the full suite, linter and build fresh.
  - Lists every change to the spec since approval, from its `Changed` notes checked against git history.
  - Pairs each current success criterion with the test or command that shows it, and never passes a criterion the code and spec disagree on; it fixes the code or routes the change through `update-spec`.
  - The paragraph about paraphrases and "expressions of satisfaction" is gone.
- **`finish-branch`** (was `finishing-a-development-branch`)
  - Grounded in: [5.5] keep "your own confirmation step for risky or irreversible actions", and reports that say "what it did, what it found, and what it needs from you"; Flow: no second suite run straight after `prove-done`, and a PR description built from what the flow produced.
  - Reuses `prove-done`'s run instead of running the suite again.
  - Asks the integration menu as one question, recommending the pull request unless you've said otherwise.
  - Writes the PR description from the run: what changed and why with a spec link, the commits grouped by plan task, each success criterion with its evidence, the spec's `Changed` notes, review findings fixed and rejected, and open items.
  - Hands off to `handle-feedback` when PR comments arrive, and skips the menu when a pull request is already open.
- **`handle-feedback`** (was `receiving-code-review`)
  - Grounded in: [5.5] keep a confirmation step for outward actions, and avoid stopping over decisions that block nothing; [Opus 5] check in only when readings "would lead to materially different work"; [BP] give the reason; Flow: feedback from people stays separate from `review`.
  - Opens with why: feedback is a claim to check, answered with changes and evidence.
  - Scoped to feedback from people and pull requests.
  - An item that could be read two ways blocks only itself and what depends on it.
  - Changes to specified behavior go through `update-spec`; each fix starts with a test that reproduces the problem.
  - Replies are drafted, shown to you, and posted in-thread only after you approve.
  - Hands off to `prove-done`, then `finish-branch`, which pushes to the open pull request instead of showing the integration menu again.
- **`update-spec`** (new)
  - Grounded in: [SDD] a spec kept current as the work proceeds; [Skills] invoked skill content "stays [in the conversation] across later turns", so the calling skill resumes where it stopped; Flow: one path for every change to specified behavior.
  - The one way specified behavior changes after approval: states the change, gets approval, edits only the affected sections and plan tasks, adds a dated `Changed` note under each edited section, and commits it with the code.
  - Sends new goals or features back to `brainstorm`.
  - Called from `write-plan`, `execute-plan`, `review`, `tdd`, `handle-feedback`, `find-root-cause` and `prove-done`, or directly by you.
- **`find-root-cause`** (was `systematic-debugging`)
  - Grounded in: [5.5] Opus 5.5 "tends to get to work quickly", so the investigate-first steps stay, and step 16 is the kind of stop the guide wants; [BP] give the reason; Flow: a correct hand-off from inside a plan.
  - Opens with why the cause comes before the fix.
  - Steps 1 to 16 unchanged; a bug in the spec goes through `update-spec` first.
  - Inside a plan it returns to `execute-plan`; otherwise it commits and hands off to `review`. The redundant hop to `tdd` is gone.
  - `defense-in-depth.md` ("validate at EVERY layer") is replaced by `guards-after-a-fix.md`: validate at system boundaries, and add an internal guard only where the bug showed the boundary can be bypassed, with a test. Grounded in [BP]: "Only validate at system boundaries (user input, external APIs)."
  - `root-cause-tracing.md` keeps the tracing method and logging tips without the diagrams, "NEVER" nodes and session anecdote (739 to 375 words).
  - `condition-based-waiting.md` is trimmed, and its 666-word example file, written for one specific project, is gone.
  - `find-polluter.sh` now stops with an error when the pollution exists before any test runs; it used to report "all tests clean". Its header no longer calls it a bisection script.

## Contributing

See `AGENTS.md`. Run `bash tests/skills/check-skills.sh` after any skill edit.

## License

MIT, see `LICENSE`. The upstream projects keep their copyright.
