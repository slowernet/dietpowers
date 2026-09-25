---
name: finish-branch
description: Integrates a finished branch by local merge or pull request, only with your approval, and writes the PR description from the run. Use when implementation is complete and tests pass, and the work needs integrating.
---

# Finish Branch

Integration is the step that touches shared state, so it waits for your partner's choice. When the choice is a pull request, the description should let a reviewer judge the work without rereading the conversation.

Ask your partner one question at a time, in plain text; do not use the AskUserQuestion tool, because some clients show only the tool's question and drop the text around it. Put what your partner needs to answer in the same message: the problem and why it matters, then the options, each with a bold label, recommended first, each with a one-line reason. End with a line naming the answers in bold, such as `Reply with **a**, **b**, or **c**.`, and make the question the last thing in the message, after any tool use. Your partner may answer with an option, their own alternative, a question or an aside. Keep messages short: lead with the decision, then only the detail needed to answer it.

1. If the `dietpowers:prove-done` skill just ran on this state of the branch, use its result; otherwise run the project's full test suite. If anything fails or a success criterion is unmet, report it and stop — the menu comes only after a green suite.
2. Detect the workspace, capturing all three values now, before anything changes directory:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

3. Establish the base branch from the plan's `Base:` line, the conversation, or the branch's upstream. If it is not already known, ask — merging into the wrong base is expensive to undo.

   If the spec or plan is uncommitted because commits were held back, propose commits before the menu: the spec, then the plan. List them with their messages and create them only after your partner approves; then set the plan's `Spec:` line to the spec's commit and its `Commits:` line to `approved`. If your partner declines, offer only to keep the branch as it is.
4. If the branch already has an open pull request, skip the menu. Push the new commits once your partner has approved the push (the `dietpowers:handle-feedback` skill asks for it together with the replies; otherwise ask), report the URL, and if another skill invoked you, return to it. Otherwise, present the menu below as one question, recommending "Push and create a Pull Request" unless your partner has said otherwise, then wait. Print it exactly as written. The integration decision is your partner's.

Normal repo, or a worktree on a named branch:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Reply with **1**, **2**, or **3**.
```

Detached HEAD, meaning an externally managed workspace — no merge option:

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Reply with **1** or **2**.
```

5. **Merge locally:** first read this branch's trackers from `$WORKTREE_PATH/.claude/dietpowers/trackers/` (those whose `Branch:` is this branch) and keep their deferred, won't-fix and rejected findings, since cleanup may remove the worktree. Then `cd` to the main repo root, then `git checkout <base>`, `git pull`, `git merge <feature>`. On a conflict, run `git merge --abort` and report. Run the tests on the merged result. If they fail, report and offer to undo the merge with `git reset --hard ORIG_HEAD`, which needs your partner's confirmation; the branch and worktree stay in place and nothing was pushed. Once green, clean up per step 7, then `git branch -d <feature>`. In your final report, list the findings you kept, one line each.
6. **Push and PR:** `git push -u origin <feature>`, or from a detached HEAD `git push origin HEAD:refs/heads/<new-branch>`. Open the request against the base branch using the forge's CLI or the URL it prints on push. Write the description from what this run produced, fitted to the repo's PR template if it has one:
   - what changed and why, in two or three sentences, with a link to the spec;
   - the commits, one line each, grouped by plan task (`git log <base>..HEAD`);
   - each success criterion with the test or command that shows it, from `prove-done`;
   - every `Changed` note in the spec since approval;
   - from the trackers in `.claude/dietpowers/trackers/` whose `Branch:` is this branch: each fixed finding with how it was verified and its fix, and each deferred, won't-fix, rejected and duplicate finding with its reason;
   - anything left open.

   Report the URL. Keep the worktree — PR feedback gets fixed there.
7. **Cleanup**, for a local merge only. Run it from outside the worktree, using the values captured in step 2. If `GIT_DIR` equals `GIT_COMMON` there is no worktree to remove. If `WORKTREE_PATH` is under `.worktrees/` or `worktrees/` it is ours: `git worktree remove "$WORKTREE_PATH"` then `git worktree prune`. Otherwise the host environment owns it — leave it in place. No skill deletes a tracker directly; removing a worktree removes the trackers inside it.

Discarding the work happens only when your partner asks for it in so many words. Show exactly what will be deleted — branch, commit list, worktree path — and wait for them to type `discard` before `git branch -D`.

Terminal state: after a pull request, when review comments arrive, invoke the `dietpowers:handle-feedback` skill.
