---
name: execute-plan
description: Builds an approved plan task by task, test first, against the real repository. Use when you have an approved implementation plan to build.
argument-hint: "[plan path]"
---

# Execute Plan

You build the plan's tasks in order, test first, in this session. The plan names paths, interfaces, behaviors and tests; you write the code against the real repository.

Ask your partner one question at a time, in plain text; do not use the AskUserQuestion tool, because some clients show only the tool's question and drop the text around it. Put what your partner needs to answer in the same message: the problem and why it matters, then the options, recommended first, each with a one-line reason. End with a line naming the answers, such as `Reply with a, b, or c.`, and make the question the last thing in the message, after any tool use. Your partner may answer with an option, their own alternative, a question or an aside. Keep messages short: lead with the decision, then only the detail needed to answer it.

Before your first commit for this piece of work, check the plan's `Commits:` line or your partner's earlier answer. If neither settles it, ask once: "I'll work on branch `<name>`. May I commit to it as we go? Nothing is pushed or merged without asking. Reply with yes or no." Never commit to `main` or `master`. If your partner declines, commits are held back: commit nothing, and wherever a step says to commit, leave the work on disk; the `dietpowers:finish-branch` skill proposes the commits at the end.

1. Work on the plan's branch.
2. Read the plan and the spec it links, in full. If either conflicts with the repository in a way that changes what gets built, raise it now, before writing code.
3. Use the plan's task checkboxes as your task list, mirrored in todos.
4. For each task: build it with the `dietpowers:tdd` skill against its Behavior and Tests, tick its checkbox, and commit if commits are approved. When a test fails and the cause isn't obvious, use the `dietpowers:find-root-cause` skill.
5. When the repository differs from what the plan assumes, make the routine call yourself and record it under the task in the plan as a `Departure:` line. Stop to ask only when the difference would change an interface, a spec requirement, or another task. When a change would alter behavior the spec describes, invoke the `dietpowers:update-spec` skill; if the change is declined and the task cannot be built without it, stop and ask your partner how to proceed.
6. Move from task to task without stopping to report progress or to offer to continue; put any status note in the same message as your next tool call. Stop only when nothing can move without your partner: a blocker you cannot resolve, a missing dependency, or a decision that changes the design.
7. If your partner changes a requirement, invoke the `dietpowers:update-spec` skill, then return to step 2.
8. When every task is ticked, report in a few lines: what was built, the calls you made under step 5, and anything left open.

Terminal state: ask "Continue with code review? Reply with yes or no." On yes, invoke the `dietpowers:review` skill on the code. Otherwise, report what is built and what is uncommitted, and stop.
