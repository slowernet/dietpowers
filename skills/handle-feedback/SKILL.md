---
name: handle-feedback
description: Use when code review feedback from a person or a pull request has arrived, before implementing the suggestions
---

# Handle Feedback

Review feedback is a claim about the code, made by someone who may be missing context. Check each item before acting on it, and answer with changes and evidence rather than agreement.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

Before your first commit for this piece of work, unless your partner has already answered, ask once: "May I create branch `<name>` and commit this work to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, create the branch but commit nothing: wherever a step says to commit, leave the work on disk instead, and the `finish-branch` skill proposes the commits at the end.

1. Read all the feedback before reacting to any of it.
2. Restate each item as a technical requirement in your own words. If an item could be read two ways that lead to different changes, ask about it before implementing it or anything that depends on it; carry on with the rest.
3. Check each item against the codebase. Does it hold here? Does it break something that currently works? Is there a reason the code is the way it is? Does the reviewer have the full context?
4. Where a suggestion adds a feature nothing uses, grep for callers first and say what you found. An endpoint nothing calls should be removed, not implemented properly.
5. Where a suggestion is wrong, push back with technical reasoning and point at the tests or code that show it. Where it conflicts with a decision your partner already made, raise it with them rather than choosing for them.
6. Where an item would alter behavior the spec describes, invoke the `update-spec` skill before implementing it.
7. Where you cannot verify a claim, say what you would need to verify it instead of proceeding on assumption.
8. Implement in order: things that break or are insecure, then simple fixes, then complex ones. Start each fix with a test that reproduces the problem and fails, then make it pass. Check for regressions.
9. Draft a reply for each item: for correct feedback, the fix and where it landed, without agreement or thanks; for pushback, the reasoning and evidence; if you pushed back and turned out to be wrong, what you checked and what it showed.
10. Show your partner the drafts and get approval. Post nothing yet: replies must not cite changes the pull request does not have.

Terminal state: invoke the `prove-done` skill, then the `finish-branch` skill to push the fixes to the open pull request. Once the push succeeds, post the approved replies; on GitHub, reply inside each comment thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a new top-level comment.
