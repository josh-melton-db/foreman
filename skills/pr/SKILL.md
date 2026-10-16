---
name: pr
description: The shape a pull request body should take - smallest clear visual, before/after evidence, and a merge-danger call. Use when an implementer opens a PR, or when you assess one before merging.
---

# pr - the deliverable is the pull request

An implementer opens its own PR; once it passes review you merge it. Require
this shape, and enforce it at review.

## Body

- **Summary** - the smallest visual that makes the change clear: a short diff
  snippet, a tiny table, or a before/after sample. Not a wall of prose.
- **Evidence** - before/after, with the exact command(s) run and the result.
  "Ran the tests" is not evidence; `pytest tests/x.py -q` -> `12 passed` is.
- **Merge danger** - call the door: a **one-way door** (hard to reverse -
  schema, data migration, public API, security, anything already consumed) or a
  **two-way door** (cheap to revert). State the **blast radius**: what else
  touches this and what breaks if it is wrong.
- **Not done / residual risk** - anything untested, deferred, or assumed.

## Title

`<area>: <imperative change>` - e.g. `auth: reject expired refresh tokens`.

Keep the diff scoped to the task. Unrelated cleanup belongs in its own PR.
