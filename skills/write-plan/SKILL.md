---
name: write-plan
description: Turns an approved spec into a task-by-task implementation plan of paths, interfaces, behaviors and tests. Use when you have an approved spec or clear requirements for a multi-step change, before touching code.
argument-hint: "[spec path]"
---

# Write Plan

The plan is executed task by task, possibly in a fresh session that has only the plan, the spec, and the repository. Give each task what that executor needs to build it without guessing: paths, interfaces, behaviors, tests. Leave implementation code to the executor, which writes it against the real repository and runs it.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

Before your first commit for this piece of work, check the plan's `Commits:` line or your partner's earlier answer. If neither settles it, ask once: "I'll work on branch `<name>`. May I commit to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, commits are held back: commit nothing, and wherever a step says to commit, leave the work on disk; the `dietpowers:finish-branch` skill proposes the commits at the end.

1. Check scope. If the spec spans independent subsystems, invoke the `dietpowers:update-spec` skill to move all but one to Out of scope as follow-ups, then plan the one that remains. If the spec is missing something the plan needs, or planning shows it must change, invoke the `dietpowers:update-spec` skill.
2. Map the files: what gets created, what gets modified, what each is responsible for. Follow the codebase's existing patterns, and name the existing file each new one should imitate.
3. Draw task boundaries at the smallest unit that carries its own test cycle. Fold setup, config and docs into the task that needs them. Split only where a reviewer could reject one task while approving its neighbor.
4. Open the plan with a header: `Spec: <path> @ <commit>`, giving the spec and its current commit, which marks the approved version (`@ uncommitted` if commits are held back); `Base: <branch>`, the branch this work merges into; `Commits: approved` or `Commits: held back`; the goal in one sentence; the architecture in two or three; a Global Constraints section copying the spec's Constraints verbatim; and a References section carrying the spec's references each task will need, with their facts, written once.
5. For each task write: a `- [ ]` checkbox heading; Files, with exact paths; Interfaces, with the exact signatures it consumes and produces; Context, the plan references and existing files the task relies on, plus any fact only this task needs; Behavior, each item concrete enough that two engineers would build the same thing; Tests, naming each test, the behavior it checks, and the production change that would make it fail; the command that runs them.
6. Save to `docs/dietpowers/YYYY-MM-DD-<topic>-plan.md`, using the spec's topic, and commit it if commits are approved.

Terminal state: invoke the `dietpowers:review` skill on the plan.
