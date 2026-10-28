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
  - A name you made up while working, or one from a document your partner has not read, such as a reviewer's report or a test fixture, is not shared vocabulary. Before you use it in a message, say what the thing is in plain words, with an example.
  - Justify an option by what another part of the system needs only when that part exists or its spec states the need.
  - In a sequence of questions, say where your partner is, such as "question 4 of 6". If the count grows, say why, for example that a fix check added findings.
  - Know the goal each decision serves. When you are unsure what a decision is for, or how exact, complete or correct the work must be, ask your partner about the goal before asking about the detail. Once it is settled, quote it in their words where it matters and decide routine questions against it yourself; ask again only when something comes up that it does not cover.

  A question whose text a skill gives in quotes is asked as written. When you ask a recorded question again on resume, update only its position count.
  ```

  > **Changed 2026-10-28:** the shared file gains a rule that a name made up while working, or taken from a document the partner has not read, is explained in plain words with an example before it is used in a message (from no such rule). Why: in this branch's own review the agent put fixture and reviewer terms ("refunds", "the two readings") into questions without explaining them, and the partner asked for the guard to be in scope. Approved by the partner on 2026-10-28 ("yes thank you").

- Pointer sentence, appended to the question paragraph ("Ask your partner one question at a time, ...") in all 11 `skills/*/SKILL.md`, after its last sentence; the rest of the paragraph is unchanged: "Before your first question, read `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` and follow it; if it cannot be read, say so once and carry on."
- `Depth:` line: every `SKILL.md` names `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` on its `Depth:` line, last in the list. A skill with no `Depth:` line (execute-plan, finish-branch, handle-feedback, prove-done, update-spec, write-plan) gets `Depth: ${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md` as its last line.
- New bullet in `shared/making-recommendations.md`, after the first bullet: "- For a review finding, say what triggers it (the data, state or usage it needs), whether that exists now where the work will run, and how often. Check with a quick read-only query or file read when one is cheap and needs no credentials or access your partner has not already given; otherwise say it is unverified. If the trigger does not exist now, say so, and when you ask about the finding, offer deferring it as a full option."

  > **Changed 2026-10-27 (spec review):** the bullet names the trigger (data, state or usage; the code path is taken as given) and limits checks to read-only ones needing no new access, where the limit was only in Inputs and failure behavior (findings 1 and 5). Approved by the partner in the spec review.
- Review tracker header field, added to `## Tracker format` in `shared/trackers.md` after `FIX_BASE:`: "- `Goal:` the goal the review serves, quoted from the spec's Goal section or from `REQUIREMENTS`, and how exact, complete or correct the work must be, in your partner's words where they gave them. Recorded at review step 5."
- `shared/trackers.md` `## Resuming` step 5: "check it now, as in the first pass (a minor finding with one reasonable fix gets a notice; the rest are asked)" becomes "check it now, as in review step 5". The `Question:` field's "`notice only` for a minor finding fixed without asking" becomes "`notice only` for a minor finding fixed without asking, or a major deferred because it does not block the recorded goal".

  > **Changed 2026-10-27 (spec review):** adds the two `shared/trackers.md` changes, so resume and the `Question:` field match the new step 5 (finding 3). Approved by the partner in the spec review.

## Design

- **`shared/asking-questions.md`** (new): the content in Constraints. It applies to all questions in all skills, including the commit, menu and terminal questions.
- **All 11 `skills/*/SKILL.md`**: the pointer sentence and `Depth:` entry from Constraints. No other change to the question paragraph, so the check script's existing format checks hold.
- **`shared/making-recommendations.md`**: the new bullet from Constraints. Only `dietpowers:adversarial-review` reads this file, so the rule reaches review findings only.
- **`skills/adversarial-review/SKILL.md`**:
  - Step 5, after the pointer to `making-recommendations.md`: "Then record the tracker's `Goal:` line. If the spec or `REQUIREMENTS` does not settle how exact, complete or correct the work must be, ask your partner once before any finding, and record the answer." This question is not a tracker item and does not offer `pause`.
  - Step 5 gains a bullet after the minor-finding bullet: "A major finding that holds but plainly does not block the recorded goal, and that you would not otherwise ask about: mark it `deferred`, add it as an open item as the **add to open items** answer does, set its Question to `notice only`, and tell your partner in one line the finding and why it does not block the goal. Do not wait for a reply. If your partner objects, remove the open item added for it, set the finding back to `open` with its Question recorded, and ask. When a major finding's trigger does not exist now, judge whether it could realistically arise where the work will run, such as on other data, for other users or with later use. If it could, ask it. If it could not, tell your partner in one line what the trigger is and why it cannot arise, set the item to `deferred` with Question `notice only`, and do not wait for a reply."

    > **Changed 2026-10-27 (spec review):** an objection removes the open item (finding 2); a finding whose trigger does not exist now is asked, not deferred by notice (finding 5). Approved by the partner in the spec review.

    > **Changed 2026-10-27 (fix check):** for a major whose trigger does not exist now, the review judges whether the trigger could realistically arise: if so it asks; if not, a one-line notice and no open item (fix-check finding 1, the partner's own rule). The rule covers majors only; minors keep their notice (fix-check finding 2). Approved by the partner in the spec review.
  - The ask bullet's first clause becomes: "Every blocker, every major finding that blocks the recorded goal or whose bearing on it is unclear, and any finding you want to reject, downgrade, ..." (the rest unchanged).
  - The sentence "Review findings reach open items only through the **add to open items** answer" becomes "Review findings reach open items only through the **add to open items** answer or the non-blocking major bullet above".
  - "You may raise a grade on your own; lower one only by asking" is unchanged: deferring a major does not change its grade.
  - Terminal state: "recommending it only when no blocker or major item is `deferred` either" becomes "recommending it only when no blocker or major item is `deferred` either, other than majors whose Question is `notice only`".
  - Step 7 handles second-pass findings as in step 5, so the new rules cover them with no change to step 7.
- **`shared/trackers.md`**: the `Goal:` header field, the resume rule and the `Question:` field from Constraints.
- **`tests/skills/check-skills.sh`** asserts:
  - `shared/asking-questions.md` exists and contains `Know the goal each decision serves`, `question 4 of 6` and `is not shared vocabulary`;
  - every `SKILL.md` contains `read \`${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md\`` and has a `Depth:` line naming `${CLAUDE_PLUGIN_ROOT}/shared/asking-questions.md`;
  - `shared/making-recommendations.md` contains `say what triggers it` and `read-only`;
  - the review's step 5 line contains `` `Goal:` `` and the review contains `plainly does not block the recorded goal`;
  - `shared/trackers.md` contains `` `Goal:` `` and `as in review step 5`, and no longer contains `as in the first pass`;
  - the existing `Depth:` assertion for adversarial-review is updated to the new line.
- **`README.md`**:
  - in "What changed in each skill", the paragraph beginning "Every skill that asks you anything gained the same rule" gains: "Each also reads `shared/asking-questions.md` before its first question: questions stand alone, lead with the problem in everyday terms, give an example, use the names the code already uses, explain any name your partner has not seen before using it, say how many remain, and ask about the goal before the detail when the goal is unclear.";
  > **Changed 2026-10-28:** check and README sentence follow the shorthand rule; see the note under Constraints.
  - the `adversarial-review` entry gains a bullet: "Records the goal the review serves in the tracker, asking once if the spec leaves unclear how exact the work must be; says what triggers each finding and whether that trigger exists now; defers a major finding that does not block that goal with a one-line notice, and asks about the rest."
- **`docs/testing.md`**: a section describing the probe in Success criterion 2, how to run it and how to score it.

## Inputs and failure behavior

- **`shared/asking-questions.md` cannot be read**: the skill says so once and carries on with the inline paragraph alone.
- **The spec has no Goal section, and a code review has no `REQUIREMENTS`**: the review asks the partner for the goal once, as the goal rule says, and records the answer as `Goal:`.
- **The partner objects to a non-blocking-major notice**: the open item added for it is removed, and the finding goes back to `open` and is asked, as step 5's new bullet says.
- **Resuming a review tracker written before this change, with no `Goal:` line**: the review records the line before asking the next question, asking once if needed. This is not treated as a missing field under `## Resuming` step 4.
- **Checking whether a trigger exists now needs a query that writes, or credentials or access the partner has not given**: the review does not run it and says the answer is unverified, as the making-recommendations bullet says.

## Success criteria

1. `bash tests/skills/check-skills.sh` exits 0 and makes the assertions listed under Design.
2. Probe: a fixture repository with a spec, run against two copies of the plugin, 0.1.0 and the branch. In both copies, `skills/adversarial-review/spec-reviewer.md` is replaced by a prompt that returns the same fixed report, so both see the same findings and the normal first pass (steps 1 to 5) is tested:
   - (a) a major finding whose trigger does not exist in the fixture's data but could realistically arise there, for example data the fixture's other records already show;
   - (b) a major finding that does not block the spec's goal and whose trigger exists;
   - (c) a major finding that blocks the goal, worded with a label the spec does not use.

   The review runs three times on each copy, with the model and effort level pinned. The replies are scripted: if the review asks about the goal, the reply is the fixture spec's Goal section quoted with "as written"; each finding question is answered **add to open items**. A run ends after the last step 5 question is answered; steps 6 and 7 are not scored. Each run is scored on these checks:
   1. a Read of `shared/asking-questions.md` appears before the first question;
   2. the tracker has a `Goal:` line before the first finding question;
   3. finding (a)'s question says its trigger does not exist now, why it could arise, and offers deferring as a full option;
   4. finding (b) gets a one-line notice and no question, and is in `.dietpowers/trackers/open-items.md`;
   5. no question uses (c)'s label without saying what it refers to, and no question refers to "the draft", "this goal" or "item N" without quoting it;
   6. each question in the sequence says how many remain.

   The criterion is met when every check passes in all 3 branch runs. A failed run is diagnosed and the skill text fixed before the probe runs again; a run is never repeated only to get a pass. The 0.1.0 runs are scored on the same checks and recorded for comparison; they are expected to fail checks 1, 2 and 4, which test rules 0.1.0 does not have.

   > **Changed 2026-10-27 (spec review):** states the probe method (a fixed reviewer report in both copies), each finding's grade, and the pass bar (all checks in 3 of 3 branch runs) (findings 5, 6 and 7). Approved by the partner in the spec review.
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
