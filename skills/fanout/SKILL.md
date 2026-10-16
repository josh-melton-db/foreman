---
name: fanout
description: Run a set of dependent subtasks across parallel workers - build the task graph, dispatch only the ready frontier, integrate. Use for work with more than one piece, especially when pieces block each other.
---

# fanout - a task graph, not a flat list

Parallelism is only safe where tasks are independent. Model the work as a graph
and dispatch the frontier; do not dump a flat list at once.

## Procedure

1. **Split into tracer-bullet slices.** Each slice cuts a narrow but COMPLETE
   path through every layer (schema, logic, tests) and is verifiable on its own,
   sized to fit one fresh context. Prefactoring that makes the real change easy
   goes first, as its own slice.
2. **Declare each task's blocking edges** - the tasks that must land before it
   can start. A task with no blockers is ready now.
   Record `{task_id, title, worktree, branch, blocked_by, conversation_id,
   pr_url, reviewer_conversation_id, reviewed_head_sha}` in `.foreman/registry.json`.
   Write each task's contract to `.foreman/contracts/<task_id>.md` with outcome,
   acceptance checks, allowed change surface, exclusions, and gates. Use the
   spec as a context pointer when one exists; no issue tracker or ticket
   publication is required.
3. **Dispatch only the ready frontier.** For each ready task, create its
   worktree and dispatch one implementer:
   `sys_os_shell("git worktree add .worktrees/<task_id> -b foreman/<task_id> main")`
   `sys_session_send(agent="claude_code"|"codex", title="<task_slug>",
   args={purpose: "implement", input: "<contract path + worktree path>"})`
   Use a task-based title (`auth-refactor`, `fix-sse-error`), never a vendor
   name. State that the worker must stay inside `.worktrees/<task_id>`, drive to
   green, and open its OWN PR. Every commit it authors ends with the exact
   co-sign trailer `Co-authored-by: omnigent <noreply@omnigent.ai>`.
   Refresh `main` before creating the worktree. Dependent tasks start only
   after their blockers land; tell each worker to check its branch base before
   editing. For a long-running `claude_code` or `codex` task with an explicit
   completion condition, `input` may be one standalone `/goal <condition>` holding the same
   task, worktree, contract, gates, and PR requirement. Never for `flash`, and
   never for review/explore.
4. **Respect the per-turn cap** (policy-enforced). More ready tasks than the cap
   => dispatch in waves and let the running batch finish before starting more.
   A task whose blockers have not landed is NOT ready - hold it.
5. **Collect and close out.** Each worker notifies you through the inbox; record
   its PR URL, then send the PR through `cross-review` once per head SHA. Only
   when BOTH checks pass
   do you mark the task done and merge the PR to main.
   If the worker reports adjacent problems, change the contract only when a
   problem demonstrably blocks its outcome; otherwise record a separate
   follow-up. Re-check the contract before sending fix requests to the worker.
6. **Unblock.** When a task lands, mark it landed and dispatch the tasks whose
   blocking edges are now satisfied. Remove a finished worktree (`git worktree
   remove`) only once its PR is open and review is clean; the branch lives on the
   remote.
7. **Integrate.** When the slice set is complete, verify the combined result on
   main with the full relevant gates - the whole is not green just because
   every slice was.

## Notes

- Emit the worktree + `sys_session_send` calls in THIS turn, then end it. Do not
  announce and yield.
- If a worker is wrong, runaway, or superseded, `sys_cancel_task` with its
  recorded `conversation_id` before dispatching a replacement. `claude_code` is
  hard-stopped; `flash` honors the interrupt; `codex` cancellation is
  best-effort.
- A dark or failing worker: re-dispatch a FRESH implementer in a clean worktree,
  or escalate - do not loop on it.
- Because merges are yours to make, cross-PR conflicts surface as you merge.
  Keeping parallel tasks' file scope disjoint is what keeps that rare.
