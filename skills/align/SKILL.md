---
name: align
description: Resolve the design before delegating — interrogate the human until every branch of the design tree is settled, then write a short spec the workers implement without guessing. Use when a goal is under-specified or has open design branches.
---

# align - resolve the design before delegating

Fixes the most common failure mode: you build the wrong thing confidently. Use
when the goal is a one-liner, the plan has open decisions, or you are about to
fan out more than one worker behind a guess.

## Procedure

1. Restate the goal in one sentence and say what you will NOT do.
2. Walk the design tree - ask, in batches of at most four, about the branches
   that actually change the build:
   - scope and non-goals; what is out of bounds
   - which modules/files are touched, and where the seam is
   - data shapes, states, and error behaviour
   - compatibility, migration, and rollout
   - what "done" is verifiable by
   For each question, propose a default so the human can just confirm.
3. Stop when every branch is resolved or explicitly deferred. Deferred branches
   become non-goals, not silent guesses.
4. Write the result to `SPEC.md` in the workspace: goal, non-goals, the decided
   branches with their reasoning, and the acceptance checks.
5. Only then dispatch, handing each worker the spec path.

This is a gate, not a stall: if the human says "just do it", record the defaults
you assumed and proceed. One round is often enough; do not interrogate past the
point where the remaining branches no longer change the build.
