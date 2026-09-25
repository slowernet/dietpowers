# Writing Good Tests

**Load this reference when:** writing or changing tests, adding mocks, or adding cleanup or helper methods for tests.

Where the project's existing suite already settles a question here (fixtures, network access, style), follow the suite.

A test exists to catch a specific break. Two principles govern everything here: every test names the break it catches, and every test exercises the real thing. Strict TDD produces both naturally: a test written first and watched failing against real code has already proven it can fail, and it only earns a mock when the real dependency proves slow or external.

## Principle 1: Name the break

Before writing the test body, answer: **what production change should make this test fail, and is that change a bug or a decision?** A test earns its place by catching a wrong branch, a missing side effect, a wrong argument, a boundary case, or a broken contract.

**Derive expectations independently.** Take expected values from the spec (its success criteria, input limits and failure behavior) or the plan's Tests where they cover the behavior; otherwise from the requirement as you understand it, such as the correct behavior for a bug. Write them down before reading the implementation; a test that encodes what the code happens to do cannot catch it doing the wrong thing. Use literals and hand-checked fixtures; table-driven tests with literal `want` values are the preferred shape. An expectation computed by the code under test, or its helpers, passes no matter what that code does:

```typescript
// Bad: the same builder computes both sides, so this is always true
const expected = buildSearchQuery({ tag: 'urgent' });
expect(buildSearchQuery({ tag: 'urgent' })).toBe(expected);

// Good: hand-derived literal
expect(buildSearchQuery({ tag: 'urgent' })).toBe('tag:"urgent"');
```

**No change detectors.** If only intentional decisions can fail a test (a constant's value, exact message wording, private structure), it fires on every redesign and misses real bugs. Test the behavior that depends on the decision: not `expect(MAX_RETRIES).toBe(5)` but "a failing call is retried 5 times and the 6th attempt never happens."

**Behavior, not text.** Asserting that a script, skill, or config contains an exact line proves only that the file says what it says. Run scripts against controlled inputs and assert outputs, side effects, or exit codes. Documents that instruct agents are tested by the consuming agent's behavior; prose for humans gets no test.

**Your code, not the framework.** Test the contract your code makes at its boundaries: the route you register, the query you emit, the payload you produce. Upstream mechanics are their maintainers' to test; asserting that your router calls a registered handler tests the framework. When upstream behavior genuinely surprised you, write one narrow test that records it and names your assumption. The same boundary applies inside your code: constructors, getters, constants, and trivial forwarding get tests only when they validate, normalize, default, derive, enforce, or cause side effects; otherwise assert the first result a caller can see that depends on them.

## Principle 2: Exercise the real thing

**Assert on the component, not the mock.** A mock assertion passes when the mock is present and fails when it is absent; it says nothing about the component. If the mock is what you are checking, unmock it or delete the assertion.

```typescript
// Good: real behavior
expect(screen.getByRole('navigation')).toBeInTheDocument();

// Bad: mock existence
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
```

**Mock at the right level.** Learn every side effect of the real method before replacing it; mock the slow or external operation and keep what the test depends on real. When unsure, run the test against the real implementation first and observe what actually needs to happen.

```typescript
// Bad: the mock swallows the config write that duplicate detection reads
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));

// Good: mock only the slow server startup; the config write stays real
vi.mock('MCPServerManager');
```

**Prefer real, then fake, then stub or mock.** Use the real implementation when it is fast, deterministic and simple to set up; otherwise a fake (a working lightweight version, such as an in-memory store); stub or mock only what neither can cover. Assert outcomes and state. Assert calls only when the call itself is the contract, such as sending an email or charging a card, and then assert its arguments and count exactly. Give each branch (success, error, malformed) its own fixture, so the wrong branch cannot satisfy the expectation.

**Mirror real data completely.** Mock the complete structure as it exists in reality, all documented fields, not just the ones your test reads. Partial mocks fail silently when downstream code reads an omitted field: the test passes while integration breaks.

**Keep test-only methods out of production classes.** Cleanup that only tests need lives in test utilities, never as a `destroy()` on the production class. If a method is called only from tests, or the class doesn't own that resource's lifecycle, it belongs in a test utility.

**Prefer real components over complex mocks.** When mock setup outgrows the test logic, mocks miss methods the real components have, or tests break when the mock changes, switch to an integration test with real components.

## Make tests deterministic and readable

A test gives the same result on every run and in any order. Control time and randomness, keep off the real network, and have each test set up its own state. For waiting on asynchronous work, see `../find-root-cause/condition-based-waiting.md`.

Keep test bodies straight-line: no conditionals and no computed expectations, though a loop over a table of literal cases is fine. A little duplication is fine when it makes a test clearer to read. A failing test should show the expected and the actual value, so the cause is obvious without a debugger.

## Ship only the tests the behavior needs

Trivial code and human prose need no tests, and a test written to satisfy process costs maintenance forever.

## Checklist

Before writing a test body:

- Name the production change that would make it fail. If you cannot, redesign the test around an observable behavior. If only intentional decisions would fail it, it is a change detector: test the behavior that depends on the decision.
- Derive the expected value without the code under test or its helpers.

Before adding a mock or test helper:

- List the real method's side effects; keep the ones the test depends on real and mock the slow or external level below them.
- Mirror the complete real structure in mock responses.
- About to assert on the mock itself? Unmock it or delete the assertion.

Before finishing a test file, mutate the production code in your head. At least one test should fail for each realistic mutation:

- Wrong constant or argument
- Wrong branch handler
- Missing state change or side effect
- Empty or default return
- Missing validation for zero, empty, nil, unauthorized, or malformed input
- Any input limit or failure behavior the spec states, handled wrongly or not at all

A mutation nothing catches means the behavior is unprotected, or a test always passes.

Signs a test is not doing its job:

- Setup and assertion share the same object, guaranteeing equality.
- It can fail only through a crash or a missing selector.
- It fails on every intentional change and never on accidental breakage.
- Expected values are hidden behind loops, builders, or helpers.
- It greps source text, or asserts a removed symbol stays removed.
- It checks only framework behavior.
- It exists for coverage, checking no side effect or outcome.
- Mock setup is more than half the test, or you cannot say why the mock is needed.
- Its result depends on the clock, randomness, the network, or the order tests run in.
- Its expected values were read off the implementation instead of the requirement.
