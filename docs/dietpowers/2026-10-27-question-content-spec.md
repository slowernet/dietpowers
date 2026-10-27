# Question content: context, plain language and the partner's goal

Source: issue [#30](https://github.com/slowernet/dietpowers/issues/30) and the brainstorm recorded in `.dietpowers/trackers/2026-10-27-question-content-brainstorm.md`.

## Goal

The partner should be able to answer a question on first read. Today's question paragraph, repeated in all 11 skills, covers format: one question, bold word labels, a `Reply with` line. It says little about content. In sessions on the rep project the partner stopped work many times because a question depended on a draft they did not have open, used a label invented mid-session, framed the problem abstractly, gave no sense of when a review finding would bite, or was asked with full ceremony when it did not block the goal. The fix gives the skills rules for question content in one shared file, and makes the review settle the partner's goal once and decide routine findings against it, asking only about what the goal does not settle.

## Constraints

Later steps copy these values exactly.

- New file `shared/asking-questions.md` at the plugin root, with this content:

  ```markdown
  # Asking questions

  Your partner should be able to answer a question on first read, without scrolling back or opening another file. Before you send a question, check it against these:

  - Make it stand alone. Say in the question what is being decided, and quote any goal, draft text or earlier item it depends on; never write "this goal", "item 3" or "the draft" without quoting it.
  - Lead with the problem in everyday terms: what breaks, for whom, and when. Names of files, classes and methods come after. Then give each option with its risk.
  - Give one concrete example, from your partner's own code or data where you can.
  - Use the names the code, spec and files already use, and the precise technical term for the thing at the centre of the question: say "strings" and "symbols", not "two forms". Do not invent labels.
  - Justify an option by what another part of the system needs only when that part exists or its spec states the need.
  - In a sequence of questions, say where your partner is, such as "question 4 of 6". If the count grows, say why, for example that a fix check added findings.
  - Know the goal each decision serves. When you are unsure what a decision is for, or how exact, complete or correct the work must be, ask your partner about the goal before asking about the detail. Once it is settled, quote it in their words where it matters and decide routine questions against it yourself; ask again only when something comes up that it does not cover.
  ```

- Pointer sentence, appended to the question paragraph ("Ask your partner one question at a time, ...") in all 11 `skills/*/SKILL.md`, after its last sentence; the rest of the paragraph is unchanged: "Before your first question, read `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` and follow it; if it cannot be read, say so once and carry on."
- `Depth:` line: every `SKILL.md` names `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` on its `Depth:` line, last in the list. A skill with no `Depth:` line (execute-plan, finish-branch, handle-feedback, prove-done, update-spec, write-plan) gets `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` as its last line.
- New bullet in `shared/making-recommendations.md`, after the first bullet: "- For a review finding, say when it happens: the data or state it needs, whether it can happen today, and how often. Check with a quick query or file read when one is cheap; otherwise say it is unverified. If it cannot happen now, say so and offer deferring it as a full option."
- Review tracker header field, added to `## Tracker format` in `shared/trackers.md` after `FIX_BASE:`: "- `Goal:` the goal the review serves, quoted from the spec's Goal section or from `REQUIREMENTS`, and how exact, complete or correct the work must be, in your partner's words where they gave them. Recorded at review step 5."

## Design

- **`shared/asking-questions.md`** (new): the content in Constraints. It applies to all questions in all skills, including the commit, menu and terminal questions.
- **All 11 `skills/*/SKILL.md`**: the pointer sentence and `Depth:` entry from Constraints. No other change to the question paragraph, so the check script's existing format checks hold.
- **`shared/making-recommendations.md`**: the new bullet from Constraints. Only `dietpowers:adversarial-review` reads this file, so the rule reaches review findings only.
- **`skills/adversarial-review/SKILL.md`**:
  - Step 5, after the pointer to `making-recommendations.md`: "Then record the tracker's `Goal:` line. If the spec or `REQUIREMENTS` does not settle how exact, complete or correct the work must be, ask your partner once before any finding, and record the answer." This question is not a tracker item and does not offer `pause`.
  - Step 5 gains a bullet after the minor-finding bullet: "A major finding that holds but plainly does not block the recorded goal, and that you would not otherwise ask about: mark it `deferred`, add it as an open item as the **add to open items** answer does, set its Question to `notice only`, and tell your partner in one line the finding and why it does not block the goal. Do not wait for a reply. If your partner objects, set it back to `open` and ask."
  - The ask bullet's first clause becomes: "Every blocker, every major finding that blocks the recorded goal or whose bearing on it is unclear, and any finding you want to reject, downgrade, ..." (the rest unchanged).
  - The sentence "Review findings reach open items only through the **add to open items** answer" becomes "Review findings reach open items only through the **add to open items** answer or the non-blocking major bullet above".
  - "You may raise a grade on your own; lower one only by asking" is unchanged: deferring a major does not change its grade.
  - Terminal state: "recommending it only when no blocker or major item is `deferred` either" becomes "recommending it only when no blocker or major item is `deferred` either, other than majors deferred because they do not block the recorded goal".
  - Step 7 handles second-pass findings as in step 5, so the new rules cover them with no change to step 7.
- **`shared/trackers.md`**: the `Goal:` header field from Constraints.
- **`tests/skills/check-skills.sh`** asserts:
  - `shared/asking-questions.md` exists and contains `Know the goal each decision serves` and `question 4 of 6`;
  - every `SKILL.md` contains `read \`${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md\`` and has a `Depth:` line naming `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md`;
  - `shared/making-recommendations.md` contains `say when it happens`;
  - the review's step 5 line contains `` `Goal:` `` and the review contains `plainly does not block the recorded goal`;
  - `shared/trackers.md` contains `` `Goal:` ``;
  - the existing `Depth:` assertion for adversarial-review is updated to the new line.
- **`README.md`**:
  - in "What changed in each skill", the paragraph beginning "Every skill that asks you anything gained the same rule" gains: "Each also reads `shared/asking-questions.md` before its first question: questions stand alone, lead with the problem in everyday terms, give an example, use the names the code already uses, say how many remain, and ask about the goal before the detail when the goal is unclear.";
  - the `adversarial-review` entry gains a bullet: "Records the goal the review serves in the tracker, asking once if the spec leaves unclear how exact the work must be; says when each finding happens and whether it can happen today; defers a major finding that does not block that goal with a one-line notice, and asks about the rest."
- **`docs/testing.md`**: a section describing the probe in Success criterion 2, how to run it and how to score it.

## Inputs and failure behavior

- **`shared/asking-questions.md` cannot be read**: the skill says so once and carries on with the inline paragraph alone.
- **The spec has no Goal section, and a code review has no `REQUIREMENTS`**: the review asks the partner for the goal once, as the goal rule says, and records the answer as `Goal:`.
- **The partner objects to a non-blocking-major notice**: the item goes back to `open` and is asked, as step 5's new bullet says.
- **Resuming a review tracker written before this change, with no `Goal:` line**: the review records the line before asking the next question, asking once if needed. This is not treated as a missing field under `## Resuming` step 4.
- **The check fact for "can it happen today" needs a query against a live database**: the review runs it only if it is read-only and quick; otherwise it says the answer is unverified.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and makes the assertions listed under Design.
2. Probe: a fixture repository with a spec and a spec review whose findings recreate rep cases: (a) a finding that cannot happen on the fixture's current data; (b) a major finding that does not block the spec's goal; (c) a reviewer finding worded with a label the spec does not use. The review runs three times on 0.1.0 and three times on the branch. In each branch run:
   - a Read of `shared/asking-questions.md` appears before the first question;
   - the tracker has a `Goal:` line before the first finding question;
   - finding (a)'s question says it cannot happen today and offers deferring as a full option;
   - finding (b) gets a one-line notice and no question, and is in `.dietpowers/trackers/open-items.md`;
   - no question uses (c)'s label without saying what it refers to, and no question refers to "the draft", "this goal" or "item N" without quoting it;
   - each question in the sequence says how many remain.
   The 0.1.0 runs are scored on the same checklist and recorded for comparison. The result is reported per run, with any failed item named.
3. `docs/testing.md` describes the probe in criterion 2.

## Assumptions

- The partner replied "1" to three brainstorm questions; each was taken as the first, recommended option (**partitioned**, **shared file**, **probe**). Recorded in the tracker, items 1 to 3.
- A shared file read on a pointer is followed reliably enough: the making-recommendations probe (spec `2026-10-04-making-recommendations-spec.md`, Assumptions) saw the file read in 3 of 3 review runs before the first question. This file is read in all 11 skills, which has not been probed; criterion 2 probes it in review only.
- Deferring a non-blocking major without asking is safe because the partner sees the notice and can object, and the finding is kept as an open item for triage.

## References

- Issue [#30](https://github.com/slowernet/dietpowers/issues/30): the eight rep problems and the proposed guidance, with examples from rep #345 (2026-10-23 and 2026-10-27).
- The question paragraph: identical in all 11 `skills/*/SKILL.md` (same md5 on 2026-10-27).
- `shared/making-recommendations.md`, read only from `skills/adversarial-review/SKILL.md` step 5.
- `skills/adversarial-review/SKILL.md` step 5 ("Every blocker and major finding ... ask your partner"; "lower one only by asking"), step 7, and the terminal state ("recommending it only when no blocker or major item is `deferred` either").
- `shared/trackers.md`, `## Tracker format` (review header) and `## Resuming` step 4.
- `tests/skills/check-skills.sh` lines 56-66 (question format checks) and 100 (adversarial-review `Depth:` line).
- `AGENTS.md`: a `SKILL.md` loads in full; other files load only when the model follows a pointer; `Depth:` names shared files.

## Out of scope

- Asking design questions in dependency order: issue #18.
- A project glossary of settled terms: issue #19.
- Triage's own recommendation rules: triage does not read `making-recommendations.md`, and this change does not add it.
- How the reviewer prompts grade findings: the grade stays the reviewer's input; only how the review acts on it changes.
