---
name: tdd
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development

A test written before the code states what the code should do; a test written after tends to restate what the code happens to do. Write each test first.

1. Write one small test for one behaviour. Name it after the behaviour, not the function. Inside a plan, the task's Tests are the starting set; add a test when you find a behaviour they miss.
2. Run it. Confirm it fails, and that it fails because the feature is missing rather than from a typo or a broken setup. A test that passes at this point is testing something that already works; fix the test.
3. Write the simplest code that makes it pass and works for every valid input, not only the test's. No extra options, no unrelated cleanup, nothing the test does not ask for.
4. Run it again. Confirm it passes, the rest of the suite still passes, and the output is clean with no stray errors or warnings. If it fails, fix the code. If the test itself is wrong, say so and correct it openly; never weaken a test to get to green. If it is wrong because the spec is wrong, invoke the `update-spec` skill.
5. Refactor while green: remove duplication, improve names, extract helpers. Add no behaviour.
6. Repeat for the next behaviour.

Production code written before a failing test: delete it and start at step 1. Adapting it while writing tests produces tests that describe the code instead of the requirement.

Assert on real behaviour, not on mock behaviour. Match test style to the surrounding suite. If a test is hard to write, the interface is probably hard to use — treat that as a design signal.

For a bug: write a test that reproduces it, watch it fail, then fix it. The test is what stops the bug coming back.

Terminal state: inside a plan, return to the `execute-plan` skill for the next task. Outside a plan, invoke the `review` skill on the code once the change is committed.

Depth: writing-good-tests.md
