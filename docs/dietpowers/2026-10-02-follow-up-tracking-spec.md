# Record follow-ups where the project tracks work

Source: issue [#24](https://github.com/slowernet/dietpowers/issues/24) and the brainstorm recorded in `.dietpowers/trackers/2026-10-02-follow-up-tracking-brainstorm.md`.

## Goal

The skills stop assuming where later work is recorded. Today `brainstorm`, `write-plan` and `update-spec` put follow-ups in the spec's Out of scope section; where follow-ups belong (an issue tracker, a notes file, the spec) varies by person and project. These three skills instead record follow-ups where the project instructions or the model's memory say work is tracked, and ask once when nothing says. Each follow-up is drafted and the partner approves it before it is filed, since filing in an issue tracker publishes it. The spec's Out of scope section goes back to holding what the feature excludes.

## Constraints

Later steps copy these values exactly.

- Shared paragraph, the same in the opening of `skills/brainstorm/SKILL.md`, `skills/write-plan/SKILL.md` and `skills/update-spec/SKILL.md`, placed after the commit paragraph:

  > Record follow-ups, later work this piece of work does not include, where the project instructions or your memory say work is tracked. If neither says, ask once where follow-ups go, for example an issue tracker, a notes file or the spec's Out of scope section, and offer to save the answer to memory. Draft each follow-up as a title and a few lines on why, with its evidence, and ask before filing it; if your partner declines, list it in your report instead.

- A follow-up is later work: a subsystem split off at a scope check, a suggested deep-research, or a new goal or feature found while changing a spec. Review findings marked `deferred` are not follow-ups; they stay in the review tracker and the PR description as today.
- Brainstorm gathers its follow-ups and asks once whether to file them, before it commits the spec.

## Design

### `skills/brainstorm/SKILL.md`

- The shared paragraph after the commit paragraph.
- Step 2: "split it: brainstorm only the first, and record the others as follow-ups, each to get its own spec later."
- Step 4: "If the report suggests a deep-research, pass that on and record it as a follow-up."
- Step 9: the section list reads "Out of scope" instead of "Out of scope, including follow-ups", and the step says to ask once whether to file the brainstorm's follow-ups before committing the spec.

### `skills/write-plan/SKILL.md`

- The shared paragraph after the commit paragraph.
- Step 1: "invoke the `dietpowers:update-spec` skill to move all but one out of the spec and record them as follow-ups, then plan the one that remains."

### `skills/update-spec/SKILL.md`

- The shared paragraph after the commit paragraph.
- Step 2: "ask your partner whether to record it as a follow-up and carry on (recommended), or to pause the current work and start it now with the `dietpowers:brainstorm` skill."

### Docs and tests

- `README.md`: line 114 (brainstorm: "lists the other parts as follow-ups in the spec's Out of scope section"), line 130 (write-plan: "moves all but one to follow-ups") and line 176 (update-spec: "record it as a follow-up") say follow-ups are recorded where the project tracks work, asking once if nothing says. The "What changed in each skill" intro paragraph gains one sentence on the shared paragraph.
- `tests/skills/check-skills.sh`: asserts that each of the three skills contains `where the project instructions or your memory say work is tracked`, and that no file under `skills/` contains `in the spec's Out of scope section as follow-ups`, `Out of scope, including follow-ups`, `list it in the spec's Out of scope as a follow-up` or `as a follow-up in the spec's Out of scope section`.
- `docs/testing.md`: the manual trial in Success criterion 2, and the structural gate list names the follow-up paragraph.

## Inputs and failure behavior

- **Nothing names a place**: ask once, offering examples; offer to save the answer to memory. Without auto memory the question repeats each session; a line in `CLAUDE.md` fixes that for everyone on the project.
- **The named place is an issue tracker that cannot be reached** (no `gh`, no remote, not signed in): say so, and list the drafts in the report for the partner to file.
- **The partner declines a draft**: list it in the report only.
- **The answer is "the spec's Out of scope"**: follow-ups go there, as today.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and asserts the strings in Docs and tests, present and absent.
2. Manual trial: in a project whose instructions and memory name no place for follow-ups, run brainstorm on a request with two independent parts. At the scope check it records the second part as a follow-up; before committing the spec it asks where follow-ups go and offers to remember the answer, then shows a draft and asks before filing it. In a project whose memory names GitHub issues, it shows the draft and files an issue only after the partner agrees.
3. `docs/testing.md` describes trial 2.

## Assumptions

- Claude Code loads `CLAUDE.md`, `AGENTS.md` and the memory index into every session, so the skill needs no step to look them up.
- Other skills that mention open items (`execute-plan` step 8, `finish-branch`'s "anything left open", `adversarial-review`'s deferred findings) stay as they are.

## References

- `skills/brainstorm/SKILL.md` steps 2, 4 and 9; `skills/write-plan/SKILL.md` step 1; `skills/update-spec/SKILL.md` step 2: the five places that record follow-ups in the spec's Out of scope today.
- The commit paragraph shared by the same skills: the pattern the follow-up paragraph copies (same text in each opening).
- `README.md` lines 114, 130, 176.

## Out of scope

- Filing review findings marked `deferred` as follow-ups.
- Changes to `execute-plan`, `finish-branch` and `adversarial-review`.
