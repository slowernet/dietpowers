---
name: update-spec
description: Use when an approved spec needs to change - a decision during planning, execution, review, debugging or PR feedback would alter behavior the spec describes, or the user changes a requirement.
---

# Update Spec

The spec is what the plan, the reviewers and prove-done check against, so when specified behavior changes, the spec changes with it, in the same commit. This is a small edit to an approved spec. A new goal or feature goes back to the `brainstorm` skill.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

1. State the change in one sentence and name the spec sections it touches. If it alters the goal or adds a feature, stop and invoke the `brainstorm` skill instead.
2. Get your partner's approval, recommending an option with a reason. If the change came from your partner, confirm your one-sentence reading of it.
3. Edit only the affected sections and keep them consistent: Constraints, Inputs and failure behavior, Success criteria, References. If there is a plan, update the matching tasks and their Tests.
4. Under each section you edited, add a note in this form: `> **Changed YYYY-MM-DD:** what changed (from X to Y). Why: ... Approved by ...`. When one change touches several sections, give the full note in the main one and a one-line note pointing to it in the others.
5. Commit the spec and plan edits with the code change that needs them, or on their own before it if the code comes later. Name the change in the commit message.

Terminal state: return to the skill you were in and continue from where you stopped.
