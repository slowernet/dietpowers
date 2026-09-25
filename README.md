# dietpowers

**Work in progress** 

An opinionated, test-first development flow tuned for latest Opus models (`claude-opus-5-5` at time of writing).

dietpowers is a fork of [tim-hub/superpowers-slim](https://github.com/tim-hub/superpowers-slim) by [Tim Bai](https://tim.bai.uno/), itself a cut-down fork of [obra/superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com/). 

## Motivation

I've been a happy and grateful Superpowers user in Claude Code, but over time I developed a sense that the workflow had lost some efficiency. Late 2025 models often felt like pair programming with an enthusiastic puppy, but the baseline has improved, and my vague sense was that the capabilities Opus has gained are at times fighting against the scaffold. Most of all, I wanted to have a more interactive conversation with the agent that preserved my flow state. Specific shortcomings I noticed:

- **No enforced path through the flow.** Nothing made the agent move from one skill to the next in order, so I would miss steps or handle them sloppily (eg. running a review in the implementor's context, biasing the findings).
- **Prompts written to support every coding agent diluted efficiency.** Supporting many agent tools meant the prompts and workflows were not tuned for the newest Opus models and harnesses. See below for details.
- **Spec drift.** Decisions made after the spec was written did not  make it back into the spec.
- **No required review of specs and plans.** Mistakes in a spec or plan passed straight into the code: garbage in, garbage out.
- **Breaks between questions.** Gaps in the questioning broke my focus on intricate problems.
- **No room to think inside a question.** Multiple-choice prompts left no natural place to digress, ask a follow-up or step away. dietpowers asks for one decision at a time, in plain text with the reasoning alongside, so I can explore a tangent, question the options, propose my own, or pause and pick up later.

I started from superpowers-slim because it had already done part of this work. 

## The skill flow

```
brainstorm                 design, one question at a time; spec written
adversarial-review (spec)  hostile review; you decide what matters; fix; one fix check
write-plan                 tasks: paths, interfaces, tests; no code
adversarial-review (plan)  hostile review; you decide what matters; fix; one fix check
execute-plan               one task at a time, test first
adversarial-review (code)  hostile review of the branch; you decide; fix; one fix check
prove-done                 fresh full run; each success criterion shown; spec changes listed
finish-branch              full suite green, then merge, PR or keep

find-root-cause            root cause, failing test, one fix at the source
handle-feedback            feedback from people, such as PR comments
update-spec                approved change to specified behavior, noted in the spec
```

## Usage

There is no session-start hook, so skills rarely start on their own. Start a piece of work by typing the skill as a slash command, followed by what you want:

```
/dietpowers:brainstorm add a CSV export to the reports page
```

Each skill hands on to the next, and the flow asks before moving on after each review and after execution. Other steps can be started directly:

```
/dietpowers:adversarial-review the code on this branch against docs/dietpowers/2026-09-24-csv-export-plan.md
/dietpowers:find-root-cause the export test fails on empty reports
```

## How dietpowers differs from its upstreams

Ordered by how far each departs from what Superpowers users may expect.

- **Imperative skill names.** `brainstorm`, `write-plan`, `execute-plan`, `tdd`, `adversarial-review`, `prove-done`, `finish-branch`, `find-root-cause` and `handle-feedback` replace Superpowers' gerund-based naming convention; `adversarial-review` and `update-spec` are new; the review skill is named `adversarial-review` so it cannot be confused with Claude Code's built-in `/review`. Skills refer to each other by full name, such as `dietpowers:adversarial-review`, so bare names cannot collide with other commands.
- **The spec stays the source of truth.** Any change to specified behavior, whether it comes up in planning, execution, review, debugging, PR feedback or from you, goes through one `update-spec` skill, which the other skills invoke once the spec is approved: you approve the change, only the affected sections change, a dated note under each changed section records what changed, why, and who approved it, and the spec change travels with the code change. A new goal or feature goes back to `brainstorm` instead. Before finishing, `prove-done` pairs each success criterion with the test that shows it and lists every change since approval, so you see drift in one place.
- **Plan files carry no implementation code.** Superpowers writes every line into the plan, for an executor with "zero context for our codebase and questionable taste." Each task in the plan includes paths, signatures, behaviors and tests, and names the code change that would make each test fail. Our rationale:
  - Superpowers plan code is written without being run, then rewritten during execution.
  - Opus 5.5 is "strongest on multistep work in a real repository, such as carrying a change through a large code base until its tests pass" ([Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)).
  - Plan defects are often missing decisions, such as an ignored error-handling convention. Paths, interfaces, behaviors and tests capture those; code review catches code bugs later.
  - Shorter plans are faster to read and approve.
  - The trade-off: less is fixed before you approve, and tests are written during execution. Code review checks for tests that could never fail.
- **Spec, plan and code each get a hostile review.** An `adversarial-review` skill reviews the spec, the plan and the code, each with its own checklist. The reviewer is a fresh subagent on the same model, which has not seen the conversation.
- **Code is reviewed once, over the whole branch**, with a test-suite run and a check for tests that cannot fail.
- **Fixes are checked once more, then the loop stops.** Code fixes start with a failing test. Once every finding is decided and fixed, one fix check looks only at the fixes; anything it finds comes to you, and no further review runs. In subagent-driven mode, Superpowers allows up to five fix rounds per task.
- **You approve each step.** After the spec, the plan, the implementation and the review, the flow asks whether to continue and recommends an answer. Code is always committed on a feature branch, never on the base branch. Committing the spec and plan needs your approval once per piece of work, recorded in the plan; if you decline, they stay on disk and `finish-branch` proposes their commits at the end. Pushing and merging always ask.
- **Brainstorming aims for the simplest well-grounded spec.** It looks up how the problem is usually solved, always offers the simplest approach and one built on existing libraries or patterns, pushes back on requests with a simpler route, asks only questions that change the design, and writes a spec with fixed sections: constraints, inputs and failure behavior, testable success criteria.
- **Research and context travel with the work.** The spec records the docs, library versions, API details and existing code it relies on, each with the specific fact used. The plan carries those facts once, in a References section, and each task names the references and files it needs. The executor reads both the plan and the spec. In superpowers-slim the plan had no link to the spec and the executor read only the plan, so research reached it only if the plan happened to repeat it.
- **Questions come one at a time, in plain text,** with the problem, the options, a recommendation and a reason in one message, ending with a `Reply with` line. You can answer with an option, your own idea, a question or an aside.
- **Reviews and brainstorms can pause and resume.** Reply `pause` to any finding or design question; say "resume" later, even in a new session, and the flow picks up from a tracker file in `.claude/dietpowers/trackers/`. That directory ignores itself in git, so nothing in it is ever committed.
- **Prompts tuned for Opus 5.5.** Skill and reviewer prompts were grounded against Anthropic's [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5) guide. See [What changed in each skill](#what-changed-in-each-skill-vs-superpowers-slim).

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
claude --plugin-dir /path/to/dietpowers --plugin-dir /path/to/dietpowers/dev
```

## What changed in each skill vs superpowers-slim

Every skill that asks you anything gained the same rule: one question at a time, in plain text rather than the question tool, recommended option first with a reason, ending with a `Reply with` line. Most also gained a line asking for short messages that lead with the question or outcome. Code steps always commit on the feature branch, asking once to create it if you are on the base branch. The spec and plan skills ask once per piece of work before their first commit ("I'll work on branch `<name>`. May I commit the spec and plan to it as we go?"), and the plan records the answer in a `Commits:` line; if you decline, the spec and plan stay on disk and `finish-branch` proposes their commits at the end. Nothing is pushed or merged without asking, and nothing is committed to `main` or `master`. Every description now says what the skill produces as well as when to use it, and the skills you start directly have an argument hint.

- **`brainstorm`** (was `brainstorming`)
  - Description says what it produces and when to use it; "You MUST" and the summary of steps are gone.
  - Opens with why the spec matters and a preference for the simplest well-grounded design.
  - Reads context beyond what the request names.
  - Asks only questions that change the design and records routine calls as assumptions; covers input limits, failure and rerun behavior.
  - Pushes back when the request seems mistaken or a simpler change would do.
  - New research step for well-known problems and outside APIs or dependencies, preferring what current documentation recommends and avoiding what it marks deprecated or insecure.
  - Approaches must include the simplest one and one built on an existing library or pattern.
  - One design approval replaces approval after each section; the self re-read is gone because a review follows.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-spec.md` with fixed sections, including testable success criteria and References.
  - When a request spans several subsystems, lists the other parts as follow-ups in the spec's Out of scope section.
  - Hands off to `adversarial-review` instead of `writing-plans`.
  - Records each question, the approaches and the design in a tracker, so you can reply `pause` and resume later.
- **`adversarial-review`** (new; replaces `requesting-code-review`)
  - Reviews a spec, plan or code with a matching prompt, in a fresh subagent on the same model that reads its own prompt file, and waits for its report. It reads the work from disk, so it does not need anything committed.
  - The reviewer grades each finding blocker, major or minor. Minor findings with one obvious fix are fixed with a one-line notice; every blocker and major, and any finding it wants to reject or fix more than one way, comes to you one at a time with a recommendation.
  - Records every finding, the evidence, the question and your decision in a tracker, so you can reply `pause` and resume later.
  - Edits a spec or plan under review directly; code fixes start with a failing test; a fix that changes the approved spec goes through `update-spec`.
  - Once every finding is decided and fixed, runs one fix check that looks only at the fixes, then stops.
  - Reports outcome first, then asks whether to continue, revise (a new review run of the revision) or stop. The spec and plan carry no review notes; the tracker is the record, and `finish-branch` copies it into the pull request.
  - `spec-reviewer.md` (was `brainstorming/spec-document-reviewer-prompt.md`, which nothing used): rewritten as a hostile review with nine checks, including input limits, failure behavior, over-complex designs, reference facts, and security and data access (untrusted input, permissions, unbounded reads, missing transactions, deprecated or insecure practices).
  - `plan-reviewer.md` (was `writing-plans/plan-document-reviewer-prompt.md`, also unused): rewritten as a hostile review with eight checks, including tests that cannot fail, missing task context, and security and data access (N+1 queries, unbounded reads, skipped permission checks, deprecated APIs).
  - `code-reviewer.md` (was `requesting-code-review/code-reviewer.md`): the general "senior reviewer" prompt is replaced by [claude-adversarial-review](https://github.com/slowernet/claude-adversarial-review), plus a test-suite run, a check for tests that cannot fail, a check of departures recorded in the plan, a check of the seams between plan tasks, a check for deprecated or insecure practices, and a read-only rule. It reviews every change since the base branch, committed or not, instead of the last commit.
- **`write-plan`** (was `writing-plans`)
  - No implementation code and no TDD micro-steps.
  - Header: `Spec: <path> @ <commit>` marking the approved spec (or `@ uncommitted`), `Base:` branch, `Commits:` approved or held back, then goal, architecture, Global Constraints and shared References.
  - A spec that spans several subsystems goes back through `update-spec`, which moves all but one to follow-ups; one plan per spec.
  - Each task: Files, Interfaces, Context, Behavior, and Tests naming the change that would make each fail, plus the command to run them.
  - Names an existing file for each new one to imitate.
  - The banned-phrase list, the self re-read and the subagent-era lines are gone.
  - Writes `docs/dietpowers/YYYY-MM-DD-<topic>-plan.md` and hands off to `adversarial-review`.
- **`execute-plan`** (was `executing-plans`)
  - Reads the plan and the spec.
  - Builds each task with `tdd`, uses the plan's checkboxes as its task list, and uses `find-root-cause` for unclear failures.
  - Makes routine calls itself and records each as a `Departure:` line under its task in the plan; asks only about changes to interfaces, requirements or other tasks, and routes changes to specified behavior through `update-spec`.
  - Names the stops it should and should not make.
  - Works on the plan's branch; the optional worktree step is gone.
  - Stops and asks when a declined spec change leaves a task unbuildable.
  - Ends with a short report, then asks before code review; it used to go straight to finishing.
- **`tdd`** (was `test-driven-development`)
  - Explains why the test comes first.
  - Starts from the plan's Tests.
  - Code must work for every valid input, including those no test covers; a test is never weakened to get green, and a test that is wrong because the spec is wrong goes through `update-spec`.
  - Returns to the skill whose steps it is working within, or to `execute-plan` while the plan has unticked tasks; only on its own does it hand off to `adversarial-review`.
  - `writing-good-tests.md`: the separate checklists are merged into one closing checklist, and it gains a contents line; the quotes from Superpowers' author are gone. New: expected values taken from the spec or requirement before reading the implementation; deterministic, isolated, straight-line tests with clear failure messages; an order of preference for test doubles (real, then fake, then stub or mock), asserting outcomes before calls; the spec's input limits and failure behavior in the mutation check; and the project's existing suite takes precedence.
- **`prove-done`** (was `verification-before-completion`)
  - Runs at the end of a finished, reviewed branch instead of before any commit, and returns to `handle-feedback` when that skill invoked it; otherwise it hands on to `finish-branch`.
  - Runs the full suite, linter and build fresh.
  - Lists every change to the spec since approval, from its `Changed` notes checked against git history from the plan's `Spec:` commit when there is one.
  - Pairs each current success criterion with the test or command that shows it, and never passes a criterion the code and spec disagree on; it asks you which side should change, fixes code through `tdd` and runs again, and with no spec uses the review's requirements.
  - Hands on to `finish-branch` only when everything passed; otherwise it reports what is unmet and stops.
  - The paragraph about paraphrases and "expressions of satisfaction" is gone.
- **`finish-branch`** (was `finishing-a-development-branch`)
  - Reuses `prove-done`'s run instead of running the suite again.
  - Stops on failing tests or unmet success criteria.
  - When the spec and plan were held back, proposes their commits before the menu and creates them only after you approve; declining leaves only "keep".
  - On a merge conflict, aborts the merge; if tests fail after a local merge, offers to undo it with your confirmation.
  - Asks the integration menu as one question, recommending the pull request unless you've said otherwise.
  - Writes the PR description from the run: what changed and why with a spec link, the commits grouped by plan task, each success criterion with its evidence, the spec's `Changed` notes, the review record from this branch's trackers (fixed findings with their evidence; deferred, won't-fix, rejected and duplicate findings with their reasons), and open items. After a local merge, the final report lists the deferred, won't-fix and rejected findings.
  - When a pull request is already open, pushes (after your approval) instead of showing the menu, and returns to the skill that invoked it.
  - Hands off to `handle-feedback` when PR comments arrive.
- **`handle-feedback`** (was `receiving-code-review`)
  - Opens with why: feedback is a claim to check, answered with changes and evidence.
  - Starts by finding the pull request, its comments, and the spec and plan it links, so it works in a fresh session.
  - Scoped to feedback from people and pull requests.
  - An item that could be read two ways blocks only itself and what depends on it.
  - Changes to specified behavior go through `update-spec`; each fix starts with a test that reproduces the problem.
  - Commits each fix with its test; asks one question, "Push the fixes and post these replies?"; posts in-thread only after `prove-done` and `finish-branch` have pushed the fixes.
- **`update-spec`** (new)
  - The one way specified behavior changes once you have approved the spec: states the change, gets approval, edits only the affected sections plus the plan's matching tasks, Global Constraints and References, adds a dated `Changed` note under each edited section, and commits with the code.
  - A declined change edits nothing, and the calling skill drops it, or stops and asks when it cannot go on without it.
  - With no approved spec, says so and stops.
  - For a new goal or feature, asks whether to record it as a follow-up and carry on, or to pause and start it with `brainstorm`.
  - Called from `write-plan`, `execute-plan`, `adversarial-review`, `tdd`, `handle-feedback`, `find-root-cause` and `prove-done`, or directly by you.
- **`find-root-cause`** (was `systematic-debugging`)
  - Opens with why the cause comes before the fix.
  - A bug in the spec goes through `update-spec` before the fix.
  - Returns to the skill whose steps it is working within, or to `execute-plan` while the plan has unticked tasks; otherwise commits and hands off to `adversarial-review` instead of `test-driven-development`.
  - `defense-in-depth.md` ("validate at EVERY layer") is replaced by `guards-after-a-fix.md`: validate at system boundaries, and add an internal guard only where the bug showed the boundary can be bypassed, with a test.
  - `root-cause-tracing.md` loses its diagrams, "NEVER" nodes and session anecdote (739 to 375 words).
  - `condition-based-waiting.md` is trimmed, and its 666-word example file, written for one specific project, is gone.
  - `find-polluter.sh` stops with an error when the pollution exists before any test runs, instead of reporting "all tests clean"; runs test paths containing spaces as one file; is run from the project root by its full path; and no longer calls itself a bisection script.

### Sources

- Anthropic, [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5): the primary guide.
- Anthropic, [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5): fallback from the above.
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

See `AGENTS.md`. Run `bash tests/skills/check-skills.sh` after any skill edit. 

To trial the flow, also load `dev/` (`--plugin-dir /path/to/dietpowers/dev`), which logs problems with the skills to `.claude/dietpowers/problems.md` in the project you are working on.

## License

MIT, see `LICENSE`. The upstream projects keep their copyright.
