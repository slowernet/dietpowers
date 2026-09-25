---
name: write-plan
description: Use when you have an approved spec or clear requirements for a multi-step change, before touching code
---

# Write Plan

The plan is executed task by task, possibly in a fresh session that has only the plan, the spec, and the repository. Give each task what that executor needs to build it without guessing: paths, interfaces, behaviors, tests. Leave implementation code to the executor, which writes it against the real repository and runs it.

1. Check scope. If the spec spans independent subsystems, write one plan per subsystem; each must produce working, testable software on its own.
2. Map the files: what gets created, what gets modified, what each is responsible for. Follow the codebase's existing patterns, and name the existing file each new one should imitate.
3. Draw task boundaries at the smallest unit that carries its own test cycle. Fold setup, config and docs into the task that needs them. Split only where a reviewer could reject one task while approving its neighbor.
4. Open the plan with a `Spec:` line linking the spec, the goal in one sentence, the architecture in two or three, a Global Constraints section copying the spec's Constraints verbatim, and a References section carrying the spec's references each task will need, with their facts, written once.
5. For each task write: a `- [ ]` checkbox heading; Files, with exact paths; Interfaces, with the exact signatures it consumes and produces; Context, the plan references and existing files the task relies on, plus any fact only this task needs; Behavior, each item concrete enough that two engineers would build the same thing; Tests, naming each test, the behavior it checks, and the production change that would make it fail; the command that runs them.
6. Save to `docs/dietpowers/YYYY-MM-DD-<topic>-plan.md`, using the spec's topic, and commit it.

Terminal state: invoke the `review` skill on the plan.
