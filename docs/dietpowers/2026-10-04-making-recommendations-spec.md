# Making recommendations, and shared prompt elements

Source: issue [#26](https://github.com/slowernet/dietpowers/issues/26) and the brainstorm and spec review recorded in `.dietpowers/trackers/2026-10-03-option-premortem-brainstorm.md` and `2026-10-04-making-recommendations-spec-review.md`.

## Goal

When the adversarial review decides what to do about a finding, the options it offers should be correct across the whole system, and its recommendation should be the clearest of them. In the rep project's two dietpowers runs, 12 of 44 spec and plan review findings came from mechanism added by an earlier fix or design (plan fix #8 removed an ID and caused a blocker, "every command would fail"), and 16 came from relying on code or text without confirming the property used. A short set of checks in one shared file makes the review confirm what each option turns on, drop options that would create a new problem for a later fix to patch, and recommend the clearest correct option, before it asks the partner. The branch also adopts `shared/` as the one home for prompt text several skills use: `trackers.md` moves there from `skills/adversarial-review/`, and every skill refers to it as `${CLAUDE_PLUGIN_ROOT}/shared/trackers.md`. The review's handling of out-of-scope findings is simplified at the same time: they are handled like any other finding, and review findings reach open items only on the partner's answer.

> **Changed 2026-10-04 (spec review):** the file puts correctness first and recommends by clarity, with no scaffolding for complexity; the check runs only before options are offered (step 5), not before each fix; step 7's special rule for out-of-scope findings is removed; review findings reach open items only on the partner's answer; the pointer says what to do if the file cannot be read. Approved by the partner in the spec review.

## Constraints

Later steps copy these values exactly.

- Shared file: `shared/making-recommendations.md` at the plugin root, with this content:

  ```markdown
  # Making recommendations

  Before you offer options or recommend one, check them:

  - Name the facts each option turns on, and confirm each in the file or output that shows it. Settle what you can with a quick test, or a lookup when the fact lies outside the repository; otherwise say it is unverified.
  - Offer only options that are correct across the system: each solves the actual problem, fits the spec and code as they stand, and creates no new problem for a later fix to patch. If a proposed fix fails this, say in one line why it is not offered.
  - Recommend the clearest correct option, using size only to break ties, and state the trade-offs between options where they matter.
  - Check any claim you write against what you have already recorded.
  ```

- Pointer sentence, placed at the start of `skills/adversarial-review/SKILL.md` step 5, after "Decide which findings go to your partner.": "First read `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md` and follow it; if it cannot be read, say so once and carry on."
- Step 7's clause on `Out of scope` findings is removed, and the sentence around it reads: "Check them as in step 4's second sentence, then handle them as in steps 5 and 6, except that a finding that matches an item in this tracker is marked `duplicate of N` and not asked unless it brings new evidence, in which case show the earlier decision with it." Out-of-scope findings are handled like any other, as in step 5.
- **add to open items** and **leave here** remain ordinary options in step 5. Step 5's rule that review findings reach open items only through the **add to open items** answer stays.
- `skills/adversarial-review/trackers.md` moves to `shared/trackers.md` with its content unchanged. Every reference to it in `skills/` becomes `${CLAUDE_PLUGIN_ROOT}/shared/trackers.md`: the open-items sentence in each skill, the tracker and resume lines in brainstorm, adversarial-review and triage-open-items, and their `Depth:` lines, which name `${CLAUDE_PLUGIN_ROOT}/shared/trackers.md` in place of `trackers.md` or `../adversarial-review/trackers.md`.
- `skills/find-root-cause/condition-based-waiting.md`, used by tdd and find-root-cause, moves to `shared/condition-based-waiting.md` unchanged. The `Depth:` lines of tdd and find-root-cause name `${CLAUDE_PLUGIN_ROOT}/shared/condition-based-waiting.md`; the sentence in `skills/tdd/writing-good-tests.md` names `../../shared/condition-based-waiting.md`, since `${CLAUDE_PLUGIN_ROOT}` is substituted only in a skill's own content, not in a detail file the model reads.
- No skill changes beyond these.

  > **Changed 2026-10-04:** adds the move of `condition-based-waiting.md` (from not covered). Why: it is shared by two skills, so the new AGENTS.md rule covers it. Approved by the partner.

  > **Changed 2026-10-04:** adds the move of `trackers.md` to `shared/` (from listed as out of scope). Why: AGENTS.md's new rule that shared text lives in `shared/` would be contradicted from the day this branch merges. Approved by the partner ("fold in as adoption of shared prompt elements - with the supporting documentation").

## Design

- **`shared/making-recommendations.md`** (new): the content in Constraints. It sits outside `skills/`, so it is not a skill and loads only when a skill points to it.
- **`skills/adversarial-review/SKILL.md`**:
  - Step 5 begins with the pointer, so it covers both the judgement that a minor finding has one reasonable fix and the options put to the partner. Step 7 handles second-pass findings as in step 5, so the pointer covers them too.
  - Step 7 loses its out-of-scope sentence.
  - The `Depth:` line names both shared files: `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/trackers.md, ${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md`, as AGENTS.md's rule says.

    > **Changed 2026-10-04 (code review):** from "stays `Depth: trackers.md`" to naming both shared files. Why: the trackers.md move changed the line, and AGENTS.md's new rule lists shared files on it (code review findings 1 and 2). Approved under the review's notice rule.
- **`tests/skills/check-skills.sh`**:
  - asserts that `shared/making-recommendations.md` exists and contains `Recommend the clearest correct option`;
  - asserts that the line of `skills/adversarial-review/SKILL.md` starting `5.` contains `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md`, and that no line starting `6.` does;
  - points every `trackers.md` check at `shared/trackers.md`, updates the expected `Depth:` lines, and asserts that no file under `skills/` contains `adversarial-review/trackers.md` and that every `SKILL.md` contains `${CLAUDE_PLUGIN_ROOT}/shared/trackers.md`;
  - removes the two assertions for the out-of-scope rule (`listing **add to open items** and **leave here** first` and `for a blocker, recommend fixing and list fix first`) and asserts that ``for a finding under `Out of scope` `` is gone from the skill.
- **`shared/trackers.md`**: moved from `skills/adversarial-review/trackers.md` with `git mv`, content unchanged; all references updated as in Constraints.
- **`AGENTS.md`**: under "Working on the skills", one line: text shared by several skills lives in `shared/` at the plugin root and is referred to as `${CLAUDE_PLUGIN_ROOT}/shared/<file>`. The skill-anatomy line's `Depth:` description adds that it may name a shared file.
- **`README.md`**: "How dietpowers differs" gains a bullet: prompt text several skills use (the tracker rules, the recommendation checks) is written once in `shared/` and read by each skill that needs it. The superpowers-slim bullet "Detail in separate files" is left as it is, since it describes that fork.
- **`README.md`**: the `adversarial-review` entry under "What changed in each skill": the bullet on deferred findings drops its clause on out-of-scope findings, and a new bullet says that before offering options the review reads `shared/making-recommendations.md`, offers only correct options, and recommends the clearest.
- **`docs/testing.md`**: the manual trial in Success criterion 2.

## Inputs and failure behavior

- **The shared file cannot be read**: the review says so once and carries on without the checks, as the pointer sentence says.
- **A deciding fact cannot be settled** by a quick test or lookup: the option says it is unverified, as the file instructs.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and asserts the file, the pointer's place in step 5, its absence from step 6, the removal of step 7's out-of-scope sentence, `shared/trackers.md` in place of the old path everywhere, and the new `Depth:` lines.
2. Manual trial: in a review of a spec or plan where the reviewer's proposed fix for a finding would create a new problem, the review reads `shared/making-recommendations.md` before asking (a Read of that path appears before the question), says in one line why that fix is not offered, offers only correct options, and recommends the clearest, stating trade-offs where they matter.
3. `docs/testing.md` describes trial 2.

## Assumptions

- `${CLAUDE_PLUGIN_ROOT}` is substituted in plugin skill Markdown, and the docs name "resources shared between the plugin's skills" as its use ([skills docs](https://code.claude.com/docs/en/skills)). The `..` path rejection applies to `plugin.json` component paths, not skill bodies ([plugins reference](https://code.claude.com/docs/en/plugins-reference#path-rules)). The plugin is installed from the whole repository (marketplace `source: "./"`), so `shared/` ships.
- Probe 4 (brainstorm tracker), with an earlier wording of the file and pointers in steps 5 and 6: the file was read in 3 of 3 review runs before the first question; time to the first question averaged 33 s without the file and 34 s with it, cost +3%; the second question averaged 13 s and 14 s. The final wording, and the pointer in step 5 only, have not been probed.

## References

- Rep evidence, from `/Users/eliot/code/rep/.dietpowers/trackers/2026-09-30-meta-pixel-*.md` and `2026-10-01-jev-classification-*.md`: 44 spec and plan review findings, of which 16 seam blindness, 12 mechanism or fix-created, 5 unverified facts, 11 ordinary defects; fix-created example: Jev plan fix #8 caused blocker #9.
- `skills/adversarial-review/SKILL.md` steps 5 and 7.

## Out of scope

- Pointing brainstorm, write-plan, update-spec or triage-open-items at the shared file (queued as an open item).

> **Changed 2026-10-04 (fix check):** the resulting step 7 wording is given, and the goal and the note above say "review findings reach open items only on the partner's answer", which is narrower and accurate. Approved by the partner in the spec review.
