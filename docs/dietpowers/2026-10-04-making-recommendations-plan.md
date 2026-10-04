# Plan: making recommendations

Spec: docs/dietpowers/2026-10-04-making-recommendations-spec.md @ 5d7e5b9
Base: main
Commits: approved

**Goal:** before the adversarial review offers options for a finding, it reads one shared file and offers only correct options, recommending the clearest; out-of-scope findings lose their special rule.

**Architecture:** a new `shared/making-recommendations.md` at the plugin root holds the checks. `skills/adversarial-review/SKILL.md` step 5 opens with one pointer to it, which also covers second-pass findings because step 7 handles them as in step 5. Step 7's out-of-scope clause is removed.

## Global Constraints

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
- No other skill changes.

## References

- `skills/adversarial-review/SKILL.md`: step 5's first line is "5. Decide which findings go to your partner." Step 7's current sentence: "Check them as in step 4's second sentence, then handle them as in steps 5 and 6, with two differences: a finding that matches an item in this tracker is marked `duplicate of N` and not asked unless it brings new evidence, in which case show the earlier decision with it; and for a finding under `Out of scope`, offer step 5's options, listing **add to open items** and **leave here** first without recommending either; for a blocker, recommend fixing and list fix first."
- `tests/skills/check-skills.sh`: line 196 asserts `listing **add to open items** and **leave here** first`; line 203 asserts `for a blocker, recommend fixing and list fix first`; line 188 asserts `only through the **add to open items** answer` (kept). `$R` is `skills/adversarial-review/SKILL.md`. The script fails with `fail "<message>"` and ends with the PASS line.
- `README.md` line 123, in the `adversarial-review` entry under "What changed in each skill": "A finding you defer is either added to the open-items list (**add to open items**) or left in the review tracker (**leave here**), as you choose; out-of-scope findings from the fix check get no recommendation between the two unless they are blockers."
- `AGENTS.md` line 12, under "Working on the skills": "Refer to files in a skill's own directory as `${CLAUDE_SKILL_DIR}/<file>`; ..."
- `${CLAUDE_PLUGIN_ROOT}` is substituted in plugin skill Markdown ([skills docs](https://code.claude.com/docs/en/skills)); the plugin installs from the whole repository, so `shared/` ships.

## Tasks

### - [ ] Task 1: Shared file, step 5 pointer, step 7 simplification, tests and docs

**Files**
- Create `shared/making-recommendations.md`.
- Modify `skills/adversarial-review/SKILL.md` (steps 5 and 7).
- Modify `tests/skills/check-skills.sh`, `README.md`, `AGENTS.md`, `docs/testing.md`.

**Interfaces**
Produces the file `shared/making-recommendations.md`, read by the model through the pointer. No code interfaces.

**Context**
Global Constraints; References.

**Behavior**
- `shared/making-recommendations.md` contains exactly the file content in Global Constraints.
- `skills/adversarial-review/SKILL.md` step 5's first line becomes "5. Decide which findings go to your partner. First read `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md` and follow it; if it cannot be read, say so once and carry on." No other step contains the path. The `Depth:` line stays `Depth: trackers.md`.
- Step 7's sentence becomes exactly the wording in Global Constraints; the rest of step 7 is unchanged.
- `check-skills.sh`:
  - adds: `shared/making-recommendations.md` exists and contains `Recommend the clearest correct option`;
  - adds: the line of `$R` starting `5.` contains `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md`, and no line starting `6.` or `7.` does;
  - in both of these, write the pattern in single quotes (`'${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md'`) so bash does not expand it; the script runs under `set -u`, and `CLAUDE_PLUGIN_ROOT` is unset in a shell;
  - removes the assertions at lines 196 and 203;
  - adds: `$R` does not contain ``for a finding under `Out of scope` ``.
- `README.md` line 123 drops its clause after the semicolon, ending "...(**leave here**), as you choose." A new bullet follows it: "Before offering options for a finding, reads `shared/making-recommendations.md`: offers only options that are correct across the system, says why a proposed fix is not offered, and recommends the clearest correct option."
- `AGENTS.md` gains, after line 12: "- Text shared by several skills lives in `shared/` at the plugin root; refer to it as `${CLAUDE_PLUGIN_ROOT}/shared/<file>`."
- `docs/testing.md`, "Manual trials": add the trial from the spec's Success criterion 2: in a review of a spec or plan where the reviewer's proposed fix for a finding would create a new problem, the review should read `shared/making-recommendations.md` before asking, say in one line why that fix is not offered, offer only correct options, and recommend the clearest, stating trade-offs where they matter.

**Tests**
- "shared file present": fails if the file is missing or the clarity bullet is reworded.
- "pointer in step 5": fails if the pointer is moved out of step 5 or removed.
- "pointer not in steps 6 and 7": fails if a second pointer is added there.
- "out-of-scope clause gone": fails if step 7's clause returns.
- Add the four assertions and remove the two old ones first; run the script and confirm it prints FAIL for the missing file, the missing pointer and the clause still present. Then make the edits and confirm it passes.

Command: `bash tests/skills/check-skills.sh`
