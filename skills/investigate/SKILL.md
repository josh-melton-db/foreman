---
name: investigate
description: Answer read-only investigation, debugging, audit, search, or code-understanding questions by dispatching explore/search sub-agents and synthesizing ONLY from their cited findings. Use for any question about how the code or an external system actually behaves.
---

# investigate - delegated, cited, read-only

Never answer a repository-specific or factual question from your own reading.
Dispatch it, and require evidence you could hand to a skeptic.

## Procedure

1. Decompose the question into one or more bounded investigation tasks. For an
   ambiguous or high-stakes question, send two independent lenses.
2. Require **high-trust primary sources**: the code itself, its tests, the
   upstream repo, the vendor's own docs, the running system. Not a summary of a
   summary, not a blog post about the docs, not your prior. For every claim, cite
   `file:line`, a command and its output, or a URL.
3. Dispatch each task:
   `sys_session_send(agent="claude_code"|"codex"|"flash", title="explore-<task_slug>",
   args={purpose: "explore", input: "<question + exact scope + the evidence
   requested>"})`
   A task-based title (`explore-ci-flake`), never the raw vendor name. Use
   `purpose: "search"` when the question is primarily external/document search.
   Tell the worker to edit NOTHING and to return file, command, or line
   evidence - findings, not a transcript.
4. Capture the result as a **cited Markdown artifact** in the workspace
   (`docs/findings/<slug>.md`): the question, the answer, the evidence, and the
   open questions. A claim without a citation is not a finding.
5. Synthesize from the reports. Where two lenses disagree, say so and say which
   evidence decides it. Mark anything the workers could not establish as
   unknown rather than smoothing over it.

## Notes

- Never dispatch a second exploration of the same question to the same worker
  without new scope - escalate or change the lens instead.
- Keep the answer proportional: an audit cites its sources; a yes/no cites the
  one line that decides it.
- If nothing is found after a real attempt, that is a finding worth reporting -
  with the commands that came up empty.
