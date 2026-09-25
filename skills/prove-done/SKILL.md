---
name: prove-done
description: Use when a branch's work is finished and reviewed, before finishing the branch or opening a pull request; also when asked to prove a change is done.
---

# Prove Done

A claim that work is done is only as good as the command output behind it. This step turns the spec's success criteria into evidence your partner can check, and shows every change of direction made since the spec was approved.

Keep each message to your partner short: lead with the outcome, then only the detail needed to act on it.

1. Run the project's full test suite, linter and build fresh on the current commit. Read the whole output and the exit codes.
2. List every change to the spec since it was approved, from its `Changed` notes, and check them against `git log -p <commit>..HEAD -- <spec>`, using the commit on the plan's `Spec:` line, for edits without a note.
3. For each success criterion in the spec as it stands now, name the test or command that shows it holds, and its result. Mark any criterion nothing demonstrates. Where the code and the spec disagree, never mark that criterion as passed: recommend which one should change, and either fix the code or invoke the `update-spec` skill.
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

Terminal state: if another skill invoked you, return to it; otherwise invoke the `finish-branch` skill.
