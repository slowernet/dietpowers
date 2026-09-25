---
name: update-spec
description: Records an approved change to specified behavior in the spec and plan, with a dated note. Use when an approved spec needs to change: a decision during planning, execution, review, debugging or PR feedback would alter behavior the spec describes, or the user changes a requirement.
---

# Update Spec

The spec is what the plan, the reviewers and prove-done check against, so when specified behavior changes, the spec changes with it, alongside the code. This is a small edit to an approved spec: it applies once your partner has chosen to continue to planning. A new goal or feature goes back to the `dietpowers:brainstorm` skill.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

Before your first commit for this piece of work, check the plan's `Commits:` line or your partner's earlier answer. If neither settles it, ask once: "I'll work on branch `<name>`. May I commit to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, commits are held back: commit nothing, and wherever a step says to commit, leave the work on disk; the `dietpowers:finish-branch` skill proposes the commits at the end.

1. If there is no approved spec, say so and stop.
2. State the change in one sentence and name the spec sections it touches. If it alters the goal or adds a feature, ask your partner whether to record it as a follow-up in the spec's Out of scope section and carry on (recommended), or to pause the current work and start it now with the `dietpowers:brainstorm` skill. If they pause, note in the plan the task where work stopped.
3. Get your partner's approval, recommending an option with a reason. If the change came from your partner, confirm your one-sentence reading of it. If your partner declines, edit nothing, and have the calling skill drop the change; if the work cannot go on without it, the calling skill stops and asks your partner how to proceed. In a review, record the finding as rejected by your partner.
4. Edit only the affected sections and keep them consistent: Constraints, Inputs and failure behavior, Success criteria, References. If there is a plan, update its Global Constraints and References where they copy what you changed, and the matching tasks and their Tests.
5. Under each section you edited, add a note in this form: `> **Changed YYYY-MM-DD:** what changed (from X to Y). Why: ... Approved by ...`. When one change touches several sections, give the full note in the main one and a one-line note pointing to it in the others.
6. If commits are approved, commit the spec and plan edits with the code change that needs them, or on their own before it if the code comes later. If that code is already committed, commit the edits on their own and say so in the `Changed` note. Name the change in the commit message. If commits are held back, leave the edits on disk with the code.

Terminal state: return to the skill you were in and continue from where you stopped.
