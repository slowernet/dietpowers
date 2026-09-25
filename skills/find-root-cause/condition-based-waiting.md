# Condition-Based Waiting

Flaky tests often guess at timing with fixed delays, so they pass on a fast machine and fail under load or in CI. Wait for the condition you actually care about instead of guessing how long it takes.

Use it when a test sleeps or sets a timeout before checking a result. Don't use it when the test is about timing itself (debounce, throttle, intervals); there, a fixed delay is correct, and its comment should say why.

```typescript
// Before: guessing at timing
await new Promise(r => setTimeout(r, 50));
expect(getResult()).toBeDefined();

// After: waiting for the condition
await waitFor(() => getResult(), 'result to be set');
expect(getResult()).toBeDefined();
```

A generic polling helper, if the project has none:

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000
): Promise<T> {
  const start = Date.now();
  while (true) {
    const result = condition();
    if (result) return result;
    if (Date.now() - start > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }
    await new Promise(r => setTimeout(r, 10));
  }
}
```

Mistakes to avoid:

- Polling too fast (every 1ms) wastes CPU; every 10ms is enough.
- No timeout means a test hangs forever when the condition never holds; always time out with a message naming what was awaited.
- Reading state once before the loop checks stale data; call the getter inside the loop.

When a fixed delay is correct, wait for the triggering condition first, base the delay on known timing, and say why in a comment:

```typescript
await waitFor(() => manager.started, 'tool to start');
await new Promise(r => setTimeout(r, 200)); // tool ticks every 100ms; two ticks to see partial output
```
