---
name: prove-done
description: Shows evidence that a branch meets its spec's success criteria and lists every spec change since approval. Use when a branch's work is finished and reviewed, before finishing the branch or opening a pull request; also when asked to prove a change is done.
---

# Prove Done

A claim that work is done is only as good as the command output behind it. This step turns the spec's success criteria into evidence your partner can check, and shows every change of direction made since the spec was approved.

Ask your partner one question at a time, in plain text; do not use the AskUserQuestion tool, because some clients show only the tool's question and drop the text around it. Put what your partner needs to answer in the same message: the problem and why it matters, then the options, recommended first, each with a one-line reason. End with a line naming the answers, such as `Reply with a, b, or c.`, and make the question the last thing in the message, after any tool use. Your partner may answer with an option, their own alternative, a question or an aside. Keep messages short: lead with the decision, then only the detail needed to answer it.

Before your first commit for this piece of work, check the plan's `Commits:` line or your partner's earlier answer. If neither settles it, ask once: "I'll work on branch `<name>`. May I commit to it as we go? Nothing is pushed or merged without asking. Reply with yes or no." Never commit to `main` or `master`. If your partner declines, commits are held back: commit nothing, and wherever a step says to commit, leave the work on disk; the `dietpowers:finish-branch` skill proposes the commits at the end.

1. Run the project's full test suite, linter and build fresh on the current state of the branch. Read the whole output and the exit codes.
2. List every change to the spec since it was approved, from its `Changed` notes, and, when the plan's `Spec:` line names a commit, check them against `git log -p <commit>..HEAD -- <spec>` and `git diff HEAD -- <spec>` for edits without a note.
3. For each success criterion in the spec as it stands now, name the test or command that shows it holds, and its result. With no spec, use the requirements the review used, or ask your partner for them. Mark any criterion nothing demonstrates. Where the code and the spec disagree, never mark that criterion as passed: ask your partner which side should change, with your recommendation. To change the code, use the `dietpowers:tdd` skill, commit if commits are approved, and run step 1 again. To change the spec, invoke the `dietpowers:update-spec` skill.
4. Report: pass or fail, the criteria with their evidence, the spec changes, and anything unmet. State only what the output shows.

Evidence for common claims:

| Claim | Evidence |
|---|---|
| Tests pass | Test command output showing 0 failures |
| Linter clean | Linter output showing 0 errors |
| Build succeeds | Build command exiting 0 |
| Bug fixed | The original symptom retested, now passing |
| Regression test works | Reverted the fix, watched the test fail, restored it |
| A subagent finished | The VCS diff, not the agent's report |
| Requirements met | Each spec success criterion paired with the test or command that shows it |

Terminal state: if the `dietpowers:handle-feedback` skill invoked you, return to it. Otherwise, if everything passed and every criterion is shown, invoke the `dietpowers:finish-branch` skill; if not, report what is unmet and stop.
