---
name: align
description: Resolve open design decisions before delegating, then write a short spec with acceptance checks. Use when those decisions would change the build.
---

# align - resolve the design before delegating

Fixes the most common failure mode: you build the wrong thing confidently. Use
when the plan has open decisions that would change the build. A short request
with clear behavior and acceptance checks can proceed without a separate spec.

## Procedure

1. Restate the goal and identify the decisions that would change the build.
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
5. Only then dispatch, handing each worker the spec path and its own acceptance
   contract. Point to the spec instead of copying its full text into every task.

This is a gate, not a stall: if the human says "just do it", record the defaults
you assumed and proceed. One round is often enough; do not interrogate past the
point where the remaining branches no longer change the build.
