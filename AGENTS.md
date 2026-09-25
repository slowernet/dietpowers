# dietpowers

10 skills for Claude Code, forked from [tim-hub/superpowers-slim](https://github.com/tim-hub/superpowers-slim), which was reduced from [obra/superpowers](https://github.com/obra/superpowers). The published plugin holds skills only: no session-start hook (the dev-only `dev/` companion has one) and no support for other agent tools.

## Working on the skills

- Skill text changes how the model behaves. An edit that reads well can still make behaviour worse, so test skill changes by running them, and do not rely on reading them.
- Claude Code loads a `SKILL.md` in full when the skill is invoked. It loads other files in the skill's directory only when the model follows a pointer to them. Put detail in a separate file and point to it.
- A skill's `description` says what the skill produces and when to use it, with the words a user would say. It must not summarise the steps: the model treats a summary as a shortcut and skips the body. No script checks this.
- Every `SKILL.md` has the same parts: title; an optional short opening (why the step matters, how to ask questions, the commit approval rule); numbered steps, optionally grouped under headings and followed by short notes or a table; a terminal-state line naming the next skill or the skill to return to; and, where detail files exist, a `Depth:` line pointing to them.
- Name other skills in full, as `dietpowers:<name>`. Bare names can collide with other commands, such as Claude Code's built-in `/review`.
- Refer to files in a skill's own directory as `${CLAUDE_SKILL_DIR}/<file>`; Claude Code replaces it with the absolute path when the skill loads.

## Testing

Run `bash tests/skills/check-skills.sh` after any skill edit. The script is the only record of the mechanical rules (frontmatter keys and size, the ban on `@` links, references to renamed or deleted skills), so read its failure output.

`docs/testing.md` explains the behavioral tests and how to read their results.

To try the flow on a real project, load the dev companion plugin as well: `claude --plugin-dir /path/to/dietpowers --plugin-dir /path/to/dietpowers/dev`. Its session-start hook asks the agent to record problems with the skills (unclear or conflicting instructions, skipped steps, wrong hand-offs, loops, frustration) in `.claude/dietpowers/problems.md` at the project root. Bring those entries back here. The dev plugin is never published.

## Communication and writing style

These rules apply to docs and reports. Skill and reviewer prompts follow current prompting guidance for the target model instead (see the README's sources).

### Reading level and plainness
- Write for a smart non-specialist. Short, plain sentences.
- Define every technical term from first principles: in a short "Words used in this report" section near the top, and again briefly where it first appears. Give a concrete example with each definition.
- Avoid compressed language and stacked abstractions. Say who did what, with the verb visible ("the court blocked the rule"), not a nominalised chain ("regulatory blockage dynamics").
- Never coin a term. Name things with words that already exist in the sources, the code or the spec. If a label is needed, say what it refers to.
- No language tricks that make an observation sound like an insight: no catchy names for things, no gratuitous counterintuitive framing, no mic-drop sentences. Strip the trick and see what is left; if only the observation remains, write the observation. Point out something surprising only when it changes what the reader should do.
- No throat-clearing ("Great question", "Let's dive in"), no meta-commentary ("It's worth noting", "Here's the thing", "The key insight is"), no negation frames ("Not X, but Y"), no "load-bearing".
- No em dashes; use commas, colons, semicolons or full stops. No emojis.
- Prefer concrete nouns and numbers ("631 signals labelled by storyline") over abstractions ("the labelled corpus").

### Document structure

These rules apply to reports, such as research notes. Skill files keep the skill anatomy above.

- Open with the short answer in a few plain sentences.
- Then a table of contents, then "Words used in this report".
- Sentence-case headings.
- Tables where they help comparison; short numbered lists over long paragraphs.
- For each item surveyed, say plainly why it matters to the reader's own problem.
- End with what this means for the reader's specific situation, then a "How much to trust this report" section.

### Evidence and honesty
- Cite every claim with a link.
- Keep company claims visibly separate from independent evidence.
- Mark anything seen only in a search snippet, not opened, or unverified. Mark preprints as not yet peer reviewed.
- If a figure or status is uncertain or sources disagree, say so where it appears.
- State gaps plainly: what was not found or not checked.
