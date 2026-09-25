---
name: review
description: Runs a hostile review of a spec, plan, or code in a fresh subagent, then fixes what holds. Use when a spec, a plan, or implemented code needs review before the next step; also when asked to review code, hunt for bugs, audit a diff or branch, stress-test a PR before merging, or "tear this apart".
argument-hint: "[spec, plan, or code]"
---

# Adversarial Review

A reviewer that has not seen this conversation judges the work itself, not the reasoning that produced it. One round of fixes and one re-review catch most of what a review will find; further rounds tend to add tests and fixes without converging, so the loop stops there.

Ask your partner one question at a time, in plain text; do not use the AskUserQuestion tool, because some clients show only the tool's question and drop the text around it. Put what your partner needs to answer in the same message: the problem and why it matters, then the options, recommended first, each with a one-line reason. End with a line naming the answers, such as `Reply with a, b, or c.`, and make the question the last thing in the message, after any tool use. Your partner may answer with an option, their own alternative, a question or an aside. Keep messages short: lead with the decision, then only the detail needed to answer it.

Commits follow two rules. Fixes in a code review follow the code-step rule: commit on the feature branch as you go; if you are on `main`, `master` or the plan's `Base:` branch, first ask once: "I'll create branch `<name>` for this work. Reply with yes or no.", and do no code work until a branch is agreed. Fixes in a spec or plan review follow the document rule: check the plan's `Commits:` line or your partner's earlier answer, and if neither settles it, ask once: "I'll work on branch `<name>`. May I commit the spec and plan to it as we go? Nothing is pushed or merged without asking. Reply with yes or no." Whatever the answer, move the work to that branch; never commit to `main` or `master`. If your partner declines, leave spec and plan edits on disk; the `dietpowers:finish-branch` skill proposes those commits at the end.

1. Pick the prompt file for the target from this skill's directory, `${CLAUDE_SKILL_DIR}`: `spec-reviewer.md` for a spec (needs `SPEC_FILE_PATH`), `plan-reviewer.md` for a plan (`PLAN_FILE_PATH`, `SPEC_FILE_PATH`), `code-reviewer.md` for code (`SPEC_AND_PLAN_PATHS` or a one-paragraph `REQUIREMENTS`, and `BASE_SHA=$(git merge-base HEAD <base>)`, with `<base>` from the plan's `Base:` line, or ask). Do not read the prompt file yourself.
2. Save all work to disk, and commit it: code always, a spec or plan if commits are approved. The reviewer reads the files on disk and git history, never this conversation.
3. Dispatch a `general-purpose` subagent whose whole prompt is: "Read `${CLAUDE_SKILL_DIR}/<prompt file>` and follow it," then the placeholder values. Run it on the same model as this session, and wait for its report before doing anything else. Send nothing else: never your session history, never a pasted diff.
4. Check each finding against the files and decide which hold. Decide clear-cut findings yourself, and before fixing tell your partner which ones you will fix, one line each: the finding and why it holds. This is a notice, not a question; carry on without waiting. Ask your partner, one finding at a time with your recommendation, about any finding you want to reject, any with more than one reasonable fix, and any whose fix changes the approved spec (in a spec review, the approved design). Keep the evidence for each decision.
5. Fix every finding that holds, most severe first. For code, start each fix with a test that reproduces the finding and fails, then make it pass. A spec or plan under review is edited directly. When a fix to a plan or code would alter behavior the approved spec describes, invoke the `dietpowers:update-spec` skill before making it. Commit code fixes; commit spec and plan fixes if commits are approved.
6. If you fixed anything, dispatch one re-review the same way, adding `FINDINGS`: the findings you fixed. Fix what holds the same way. Dispatch no third review.
7. Report to your partner, leading with the outcome: what you fixed, what you rejected and why, and anything still open. Append the rejected findings and their reasons to a `Review notes` section at the end of the reviewed spec or plan; for code, at the end of the plan.

Terminal state: ask whether to continue, recommending it only when nothing is open, and end the question with `Reply with continue, revise, or stop.`
- After a spec: "Continue with write-plan?" On yes, invoke the `dietpowers:write-plan` skill.
- After a plan: "Continue with execute-plan?" On yes, invoke the `dietpowers:execute-plan` skill.
- After code: "Continue to finishing?" On yes, invoke the `dietpowers:prove-done` skill.

If your partner chooses to revise, make the changes and run this skill again on the revised work. If they choose to stop, report what is on disk and what is uncommitted, and stop.
