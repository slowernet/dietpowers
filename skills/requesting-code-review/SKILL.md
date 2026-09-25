---
name: requesting-code-review
description: Use when work is implemented and needs review before merging
---

# Requesting Code Review

1. Commit everything. The reviewer reads commits, not your working tree.
2. Capture the range: `BASE_SHA=$(git merge-base HEAD <base-branch>)` for the whole branch, and `HEAD_SHA=$(git rev-parse HEAD)`.
3. Dispatch a `general-purpose` subagent using the template in `code-reviewer.md`, filling in the spec and plan paths (or a one-paragraph statement of what the change must do, when there is no spec) and the two SHAs.
4. Give the reviewer that and nothing else: never your session history, never a pasted diff. The reading of the diff stays in the reviewer's context; only the findings come back into yours.

Terminal state: invoke receiving-code-review with the findings and `BASE_SHA`.

Depth: code-reviewer.md
