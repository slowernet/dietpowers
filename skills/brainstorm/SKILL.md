---
name: brainstorm
description: Use when starting a new feature, component, or change in behavior, before any plan or code exists.
---

# Brainstorm

The spec you write here is what the plan, the reviewers, and the code are all checked against. Anything it leaves unstated, such as an input's allowed values or what happens when a call fails, becomes a gap no later step can see, so settle those here. The best spec is usually the simplest design that meets the goal, built on established practice.

Ask your partner questions one at a time with the AskUserQuestion tool: multiple choice, recommended option first, with a one-line reason. Where the tool is unavailable, ask the same way in plain text. Keep each message to your partner short: lead with the question or decision, then only the detail needed to answer it.

Before your first commit for this piece of work, unless your partner has already answered, ask once: "May I create branch `<name>` and commit this work to it as we go? Nothing is pushed or merged without asking." Never commit to `main` or `master`. If your partner declines, create the branch but commit nothing: wherever a step says to commit, leave the work on disk instead, and the `finish-branch` skill proposes the commits at the end.

1. Read the project context, including files and history the request doesn't mention but the change may touch.
2. Check scope. If the request spans several independent subsystems, split it and brainstorm only the first; each part gets its own spec.
3. Ask only questions whose answer would change the design; make routine calls yourself and record them as assumptions. Cover purpose, constraints, success criteria, the allowed values of each new input, and what should happen when each external call fails or is rerun. If the request seems mistaken, or a simpler change reaches the same goal, say so before designing.
4. When the problem has a well-known solution or involves an external API or dependency, find out how it is usually solved: existing libraries, framework features, and current documentation. Look these up instead of relying on memory when versions or APIs matter, and note what you used in the spec.
5. Propose approaches with their trade-offs: the simplest one that meets the success criteria, and one built on an existing library, framework feature, or codebase pattern where one fits. Add a less obvious option only when it is genuinely better; if only one approach is sensible, say so. Recommend the simplest unless a trade-off rules it out, and say why. Cut anything speculative.
6. Present the design, scaled to its complexity: architecture, components, data flow, error handling, testing. Give each unit one responsibility and an interface you can state without reading its internals. In an existing codebase, follow its patterns; clean up only what blocks this work, and mention other problems instead of fixing them.
7. Get explicit approval on the design.
8. Write the spec to `docs/dietpowers/YYYY-MM-DD-<topic>-spec.md` and commit it if commits are approved. Sections: Goal; Constraints (exact values later steps must copy); Design; Inputs and failure behavior; Success criteria, each checkable by a test; Assumptions; References (docs, library versions, API details and existing code the design relies on, each with its link or path and the specific fact used); Out of scope.

Terminal state: invoke the `review` skill on the spec. Invoke no other skill from here.
