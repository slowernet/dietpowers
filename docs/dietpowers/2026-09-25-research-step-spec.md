# Brainstorm research step

Source: the partner's note in `tmp/notes.txt` (2026-09-25) and the brainstorm recorded in `.claude/dietpowers/trackers/2026-09-25-research-step-brainstorm.md`.

## Goal

Before designing, brainstorm decides whether the design would benefit from outside research. If it would, it proposes a small, visible research round, which the partner approves or trims, and it grounds the spec in the cited findings. If not, it says so in one line and carries on.

## Constraints

Later steps copy these values exactly.

- Research test: "Would this design, or the questions coming up as we decompose it, benefit from research into best practices, current developments, etc.?"
- Skip line: `No research: <reason>.`
- Override reply: `research anyway`.
- Proposal ending: `Reply with **go**, **trim** (name the numbers to drop), **skip**, or **pause**.`
- Proposal size: at most five concepts, each with the question it answers and the kinds of source to check.
- Rounds per brainstorm: one by default; at most one more.
- Researcher prompt file: `skills/brainstorm/researcher.md`. Placeholders: `TOPIC` (one paragraph: the settled purpose) and `QUESTIONS` (the approved list).
- Researcher budget: about 10 tool calls, never more than 15.
- Researcher output: about a page, returned to the dispatching session, not written to a file. For each question: `Takeaway`, `Cited Findings`, `Inferences`, `Gaps`.

## Design

### Brainstorm steps (`skills/brainstorm/SKILL.md`)

- Step 3 is split in two. First come the purpose questions: what the change is for, and for whom. Then the research step. Then the remaining design questions (constraints, success criteria, allowed input values, failure and rerun behavior).
- Step 4 ("When the problem has a well-known solution ... Note what you used in the spec.") is replaced by the research step. Checking existing libraries and framework features and preferring current documentation become part of what research covers.
- **Research step.**
  1. Apply the research test to what you know now.
  2. If the answer is no, say `No research: <reason>.` and continue. If the partner replies `research anyway`, go to 3.
  3. Otherwise, write the proposal into the tracker as a tracker item, then ask it: up to five concepts, each with the question it answers and the kinds of source to check (for example official documentation, a changelog, a standards body, or an issue tracker), ending with the proposal ending. `trim` drops the numbered questions and dispatches the rest. `skip` records the skip and continues. `pause` follows the tracker rules.
  4. On `go` (or after a trim), dispatch a `general-purpose` subagent on the same model whose whole prompt is "Read `${CLAUDE_SKILL_DIR}/researcher.md` and follow it," then `TOPIC` and `QUESTIONS`. Wait for its report.
  5. Write the report into the tracker, show the partner a short version (one line per question), and continue with the design questions.
- **Second round.** If a later question needs facts the first round did not cover, propose one more round the same way. Never a third.
- **Into the spec.** References lists each fact the design relies on, with its link, as it does today. The research report itself is not copied into the spec.

### Researcher prompt (`skills/brainstorm/researcher.md`)

Adapted from deep-research's `references/researcher.md`, keeping its language where it applies:

- **Role:** answer only the given `QUESTIONS` about `TOPIC`. The findings inform a design spec; do not recommend a design.
- **Loop:** find the gaps; search with short queries (under five words); fetch the full page of promising results, because search snippets are easy to take out of context; vary queries instead of repeating one; run searches and fetches in parallel; stop when the questions are answered with sourced findings, when nothing new turns up, or at the budget.
- **Sources:** tell speculation from confirmed fact; prefer primary sources over aggregators; flag sources that use false authority or unnamed sources; state conflicts between sources instead of picking one silently; say plainly when information is sparse or unavailable; for recent topics, trust search results over training data.
- **Output:** for each question, `Takeaway` (one or two sentences), `Cited Findings` (each with an inline link), `Inferences`, `Gaps`. About a page in total. Never fabricate; a fact without a source goes under Gaps. Mark anything seen only in a search snippet.
- **Read-only:** no changes to the working tree, the index or HEAD.

### Other files

- `tests/skills/check-skills.sh`: the assertions under Success criteria.
- `README.md`: a change note under brainstorm for the research step.

## Inputs and failure behavior

- **Proposal replies:** `go`, `trim` with numbers, `skip`, `pause`, or anything else as in the tracker's Replies rules. `trim` that drops every question is a skip.
- **No web tools, or the subagent fails or returns nothing usable:** say so, continue from the repository and your own knowledge, and list the unanswered questions in the spec's Assumptions, marked unverified.
- **Pause or crash during research:** the proposal is a tracker item. If the report was not yet written to the tracker, a resume finds the proposal item answered `go` with no report, and dispatches the round again. It still counts as one round.
- **Research contradicts the request:** say so before designing, as step 3 already requires for a mistaken request.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0, and asserts:
   - `skills/brainstorm/researcher.md` exists and contains `Takeaway`, `Cited Findings`, `Gaps` and `15`;
   - `skills/brainstorm/SKILL.md` contains `researcher.md`, `No research:`, `research anyway` and `**go**`;
   - `skills/brainstorm/SKILL.md` no longer contains `When the problem has a well-known solution`.
2. Manual trial: a brainstorm on a change with an outside dependency proposes research (at most five questions), dispatches on `go`, and cites the findings in the spec's References. A brainstorm on a repo-internal change (for example, renaming a skill) prints `No research: ...` and asks no research question.

## Assumptions

- The web tools (`WebSearch`, `WebFetch`) are available to a general-purpose subagent in the partner's harness; if they are not, the failure path applies.
- The research test is applied by the model's judgement; there is no scoring.

## References

- `/Users/eliot/.claude/skills/synced/.../deep-research/references/researcher.md`: the research loop, the 10 to 15 tool-call budget, the source-evaluation checks, and the Takeaway / Cited Findings / Inferences / Gaps structure adapted above.
- `skills/brainstorm/SKILL.md` at f7f8615: step 3 (questions) and step 4 (look up usual solutions), which this change splits and replaces.
- `skills/adversarial-review/SKILL.md` step 3: the dispatch pattern ("Read `${CLAUDE_SKILL_DIR}/<prompt file>` and follow it," then the placeholder values).
- `skills/adversarial-review/trackers.md`: tracker items, replies and resuming, which the proposal follows.
- Prompting Claude Opus 5.5, "Time signals for multiagent harnesses": research teams finish sooner under a budget, though they may search and verify a little less. This supports a fixed budget instead of an open-ended one. https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5

## Out of scope

- A deep technical dive before there is an idea to brainstorm: use `/anthropic-skills:deep-research`.
- Research steps in other skills.
- Follow-up: brainstorm trackers are created before the branch exists, so their `Branch:` is the base branch; resuming by branch on the feature branch misses them (seen in this brainstorm).
