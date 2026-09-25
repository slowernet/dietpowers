# Root Cause Tracing

Bugs often show up deep in a call stack: `git init` in the wrong directory, a file written to the wrong place, a database opened with the wrong path. Fixing where the error appears treats the symptom. Trace backward through the call chain to the original trigger and fix it there.

## Tracing a bad value

1. **Observe the symptom.** `Error: git init failed in ~/project/packages/core`
2. **Find the code that directly causes it.** `execFileAsync('git', ['init'], { cwd: projectDir })`
3. **Ask what called it, and with what value.** Walk up one caller at a time: `WorktreeManager.createSessionWorktree(projectDir)` ← `Session.initializeWorkspace()` ← `Session.create()` ← `Project.create()` in a test. Here `projectDir` was `''`, and an empty `cwd` resolves to the current directory, which was the source tree.
4. **Keep going until the value originates.** The test read `context.tempDir` at module load, before `beforeEach` had set it, so it was still `''`.
5. **Fix at the origin.** Make `tempDir` a getter that throws if read before setup. A guard at the symptom would have hidden the next caller that passes an empty directory.

If you cannot trace one level further, you have found the limit of what you know. Say so, and capture more context rather than fixing at the symptom.

## Capturing the call chain

When you can't trace by reading, log just before the dangerous operation:

```typescript
async function gitInit(directory: string) {
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack: new Error().stack,
  });
  await execFileAsync('git', ['init'], { cwd: directory });
}
```

- In tests, use `console.error`; a logger may be suppressed.
- Log before the operation runs; after it fails, the context may be gone.
- Include the directory, working directory, relevant environment variables, and `new Error().stack` for the full chain.
- Run and filter: `npm test 2>&1 | grep 'DEBUG git init'`. Look for test file names, the triggering line, and whether it is always the same test or parameter.

## Finding which test causes pollution

When something appears during a test run and you don't know which test creates it, run `find-polluter.sh` from this directory. It runs test files one at a time and stops at the first one that creates the file:

```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
```
