# Making recommendations

Source: issue [#26](https://github.com/slowernet/dietpowers/issues/26) and the brainstorm recorded in `.dietpowers/trackers/2026-10-03-option-premortem-brainstorm.md`.

## Goal

When the adversarial review decides what to do about a finding, and when it makes the fix, its recommendation should hold up. In the rep project's two dietpowers runs, 12 of 44 spec and plan review findings came from mechanism added by an earlier fix or design (plan fix #8 removed an ID and caused a blocker, "every command would fail"), and 16 came from relying on code or text without confirming the property used. A short set of checks, kept in one shared file, makes the review confirm what a recommendation turns on and recommend only correct options and, among those, the smallest, queueing any larger structural change as an open item, before it asks the partner and before it edits.

## Constraints

Later steps copy these values exactly.

- Shared file: `shared/making-recommendations.md` at the plugin root, with this content:

  ```markdown
  # Making recommendations

  Before you recommend an option, check it:

  - Name the facts your recommendation turns on, and confirm each in the file or output that shows it.
  - Settle a fact it turns on with a quick test, or a lookup when the fact lies outside the repository, or say it is unverified.
  - Recommend only an option that is correct: it solves the actual problem, fits the spec and code as they stand, and creates no new problem for a later fix to patch.
  - Among correct options, prefer the smallest. Count what each adds, such as new rules, states, files or hand-offs; this applies to your partner's alternatives and to review fixes too. When a larger, structural change might be worth making but would widen the scope, recommend the small change and add the larger one as an open item.
  - Check any claim you write against what you have already recorded.
  ```

- Pointer sentence: "read `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md` and follow it".
- `skills/adversarial-review/SKILL.md` gains the pointer in step 5, before it offers options for a finding, and in step 6, before it makes each fix.
- No other skill changes.

## Design

- **`shared/making-recommendations.md`** (new): the content in Constraints. It sits outside `skills/`, so it is not a skill and loads only when a skill points to it.
- **`skills/adversarial-review/SKILL.md`**:
  - Step 5, in the bullet that asks the partner: before offering the options for a finding, read the shared file and follow it.
  - Step 6: before making each fix, read the shared file and follow it, so a fix that adds a rule, state or hand-off is weighed against a smaller one.
- **`tests/skills/check-skills.sh`**: asserts that `shared/making-recommendations.md` exists and contains "Name the facts your recommendation turns on", and that `skills/adversarial-review/SKILL.md` contains `${CLAUDE_PLUGIN_ROOT}/shared/making-recommendations.md` at least twice.
- **README**: the adversarial-review entry gains one line saying the review checks each recommendation and fix against `shared/making-recommendations.md`.
- **`docs/testing.md`**: the manual trial in Success criterion 2.

## Inputs and failure behavior

- **The shared file cannot be read** (for example, a plugin install missing it): the review says so in one line and carries on without the checks.
- **A deciding fact cannot be settled** by a quick test or lookup: the recommendation says it is unverified, as the file instructs.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and asserts the file and both pointers.
2. Manual trial: in a review of a spec or plan where a finding's obvious fix adds a new rule or state, the review reads `shared/making-recommendations.md` before asking (a Read of that path appears before the question), names the facts the recommended fix turns on with where each was confirmed, and recommends the fix that adds least, or says why not.
3. `docs/testing.md` describes trial 2.

## Assumptions

- `${CLAUDE_PLUGIN_ROOT}` is substituted in plugin skill Markdown; the docs name "resources shared between the plugin's skills" as its use ([skills docs](https://code.claude.com/docs/en/skills)). The `..` path rejection applies to `plugin.json` component paths, not skill bodies ([plugins reference](https://code.claude.com/docs/en/plugins-reference#path-rules)).
- A pointed-to file is read reliably: in a probe of `triage-open-items` with the same pointer in its opening, the file was read in 3 of 3 runs, in the first tool call. The review flow was not probed.
- The added time is small: in that probe the checks cost about 6 seconds once per run (first question 18 s to 24 s), and later questions took the same 6 to 8 seconds with or without them. The review flow's cost was not measured.

## References

- Rep evidence, from `/Users/eliot/code/rep/.dietpowers/trackers/2026-09-30-meta-pixel-*.md` and `2026-10-01-jev-classification-*.md`: 44 spec and plan review findings, of which 16 seam blindness, 12 mechanism or fix-created, 5 unverified facts, 11 ordinary defects; fix-created example: Jev plan fix #8 caused blocker #9.
- Probes in `/tmp/triage-probe` (2026-10-04), summarised in the brainstorm tracker.
- `skills/adversarial-review/SKILL.md` steps 5 and 6.

## Out of scope

- Pointing brainstorm, write-plan, update-spec or triage-open-items at the shared file (queued as an open item).
- Moving `trackers.md` to `shared/` (queued as an open item).
