---
name: adversarial-review
description: Use when a spec, a plan, or implemented code needs review before the next step; also when asked to review code, hunt for bugs, audit a diff or branch, stress-test a PR before merging, or "tear this apart".
---

# Adversarial Review

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text.

1. Pick the prompt for the target: `spec-reviewer.md` for a spec, `plan-reviewer.md` for a plan, `code-reviewer.md` for code. For code, capture `BASE_SHA=$(git merge-base HEAD <base-branch>)` and `HEAD_SHA=$(git rev-parse HEAD)`.
2. Commit everything. The reviewer reads files and commits, never this conversation.
3. Dispatch a `general-purpose` subagent with the filled-in prompt and nothing else: never your session history, never a pasted diff.
4. Check each finding against the files. Reject any that does not hold, and keep the evidence.
5. Note the current commit as `FIX_BASE`. Fix every finding that holds, most severe first. For code, start each fix with a test that reproduces the finding and fails, then make it pass. Commit.
6. If you fixed anything, dispatch one re-review with the same prompt, its scope replaced by: "Check only whether each of these findings is fixed, and whether the fixes broke anything: [FINDINGS]". For code, the range is `FIX_BASE..HEAD`. Fix what holds the same way. Dispatch no third review.
7. Report to your partner: what you fixed, what you rejected and why, and anything still open.

Terminal state: ask whether to continue, recommending it only when nothing is open. After a spec, "Continue with writing-plans?"; after a plan, "Continue with executing-plans?"; after code, "Continue to finishing?", then invoke verification-before-completion. The other options are to revise or to stop.

Depth: spec-reviewer.md, plan-reviewer.md, code-reviewer.md
