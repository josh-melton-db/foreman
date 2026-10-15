---
name: retro
description: After a session, propose improvements to this agent's environment - navigation, automated checks, standards, steering files, tooling - most severe first. Use at the end of a run, or when the same mistake recurs.
---

# retro - improve the environment, not just the code

The code is done; the lesson is not. Survey the run and rank what would have
prevented the worst moment in it.

Look, most severe first, at:

- **Navigation** - could the agent have found the right files faster? A missing
  index, a misleading name, a stale README.
- **Automated checks** - which gate would have caught the bug or the wobble?
  Propose the exact command to add.
- **Standards** - which rule did a worker get wrong, twice? Write it down where
  the worker will actually read it.
- **Steering** - which instruction in this agent's own prompt or skills was
  wrong, missing, or ignored? Fix the file.
- **Tooling** - which command was slow, flaky, or awkward to run?

Output a short ranked list, each item one line of what to change and why. Apply
the trivial ones immediately - you may author docs and skills yourself - and
dispatch the rest.
