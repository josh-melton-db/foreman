---
name: tdd
description: The red-green-refactor contract to require of implementers - one vertical slice at a time. Use when dispatching implementation work, or when a worker's change lands with weak or absent tests.
---

# tdd - red, green, refactor

Require this of every implementer, and name the seam and the exact command that
must go green in the task prompt.

## The loop

1. **Red** - write the smallest failing test that expresses the next behaviour.
   Run it and confirm it fails for the right reason. A test that passes before
   the change proves nothing.
2. **Green** - make it pass with the simplest change that works. No speculative
   generality, no hooks for needs the spec does not have.
3. **Refactor** - with tests green, remove the duplication you just created and
   deepen the module (see the design guidance), re-running the tests after each
   step.

One slice at a time: a complete vertical path through schema, logic, and tests,
sized to fit one fresh context. Do not batch slices to "get to green faster".

## What makes a bad test

- Asserts internals rather than behaviour through the public interface.
- Passes when the feature is reverted.
- Was weakened or skipped to reach green - that is a failure, not a fix.
- Covers the framework rather than the decision you made.

## Ground truth

Report the exact command, the file set, and the commit. Collected test cases are
the count (for pytest, `python -m pytest --collect-only -q <same files>`);
`grep -c 'def test_'` counts functions, not cases, and is not an oracle.
