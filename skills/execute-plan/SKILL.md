---
name: execute-plan
description: Use when you have an approved implementation plan to build, task by task
---

# Execute Plan

You build the plan's tasks in order, test first, in this session. The plan names paths, interfaces, behaviors and tests; you write the code against the real repository.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

Before your first commit for this piece of work, unless your partner has already answered, ask once: "May I create branch `<name>` and commit this work to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, create the branch but commit nothing: wherever a step says to commit, leave the work on disk instead, and the `finish-branch` skill proposes the commits at the end.

1. Work on the approved branch. Use an isolated worktree when the work is long-running or would collide with other changes.
2. Read the plan and the spec it links, in full. If either conflicts with the repository in a way that changes what gets built, raise it now, before writing code.
3. Use the plan's task checkboxes as your task list, mirrored in todos.
4. For each task: build it with the `tdd` skill against its Behavior and Tests, tick its checkbox, and commit if commits are approved. When a test fails and the cause isn't obvious, use the `find-root-cause` skill.
5. When the repository differs from what the plan assumes, make the routine call yourself and record it under the task in the plan as a `Departure:` line. Stop to ask only when the difference would change an interface, a spec requirement, or another task. When a change would alter behavior the spec describes, invoke the `update-spec` skill.
6. Move from task to task without stopping to report progress or to offer to continue; put any status note in the same message as your next tool call. Stop only when nothing can move without your partner: a blocker you cannot resolve, a missing dependency, or a decision that changes the design.
7. If your partner changes a requirement, invoke the `update-spec` skill, then return to step 2.
8. When every task is ticked, report in a few lines: what was built, the calls you made under step 5, and anything left open.

Terminal state: ask "Continue with code review?", then invoke the `review` skill on the code.
