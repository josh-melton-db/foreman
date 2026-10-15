---
name: writing-for-agents
description: How to write documents an agent reaches by pointer - skills, AGENTS.md, steering and standards files. Use when authoring or editing this agent's own skills, or any doc a worker is told to read.
---

# writing-for-agents

A reader with no context and no ability to ask questions.

- **Front-load the decision.** The first line says when to use it and what it
  does. The `description` is what the model matches against, so make it concrete
  and action-shaped.
- **Imperative, second person.** "Do X", not "X should be done". Concrete
  commands over descriptions of intent.
- **One idea per bullet.** No hedging, no "generally", no "consider".
- **Point, do not duplicate.** Link to the canonical file instead of restating
  it - a stale copy is worse than no copy.
- **Say why it exists.** Name the failure mode the skill fixes, so a future
  editor knows what breaks if they delete it.
- **Keep it one screen.** Split by discipline, not by phase. A skill that needs
  scrolling to find its procedure is two skills.
- **No secrets, no environment specifics.** A skill is shared; identifiers are
  not.

Code fences for anything the reader should run verbatim.
