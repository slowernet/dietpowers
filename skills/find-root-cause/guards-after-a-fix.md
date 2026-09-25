# Guards After a Fix

Validate data where it enters the system: user input, external APIs, files, configuration, and test setup. Trust internal code and framework guarantees; a check for a case that cannot happen is code to maintain with nothing to catch.

After fixing a bug at its source, add a guard inside the system only where this bug showed the boundary check can be bypassed, for example by another caller, a test helper, or a mock that skips the entry point. Put the guard where the dangerous operation happens, make it fail loudly with the bad value in the message, and cover it with a test that reaches it by the bypass route.

Example: an empty directory reached `git init` through a test helper that skipped `Project.create`'s validation. The fix belonged at the source (the helper), and one guard belonged at `git init` itself, because more than one route leads there:

```typescript
async function gitInit(directory: string) {
  if (!directory) throw new Error(`gitInit: empty directory (cwd ${process.cwd()})`);
  await execFileAsync('git', ['init'], { cwd: directory });
}
```
