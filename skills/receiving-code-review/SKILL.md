---
name: receiving-code-review
description: Use when code review feedback from a person or a pull request has arrived, before implementing the suggestions
---

# Receiving Code Review

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text.

1. Read all the feedback before reacting to any of it.
2. Restate each item as a technical requirement in your own words. If any item is unclear, stop and ask about it before implementing anything — items are often related, and partial understanding produces the wrong fix.
3. Check each item against the codebase. Does it hold here? Does it break something that currently works? Is there a reason the code is the way it is? Does the reviewer have the full context?
4. Where a suggestion adds a feature nothing uses, grep for callers first and say what you found. An endpoint nothing calls should be removed, not implemented properly.
5. Where a suggestion is wrong, push back with technical reasoning and point at the tests or code that show it. Where it conflicts with a decision your partner already made, raise it with them rather than choosing for them.
6. Where you cannot verify a claim, say what you would need to verify it instead of proceeding on assumption.
7. Implement in order: things that break or are insecure, then simple fixes, then complex ones. Start each fix with a test that reproduces the problem and fails, then make it pass. Check for regressions.
8. Answer correct feedback by stating the fix and where it landed. Skip the agreement and the thanks — the change is the answer.
9. If you pushed back and turned out to be wrong, say what you checked and what it showed, then fix it. No apology, no defence of the pushback.

On GitHub, reply inside the comment thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a new top-level PR comment.

Terminal state: invoke verification-before-completion.
