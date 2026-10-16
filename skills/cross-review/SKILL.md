---
name: cross-review
description: Have one different-vendor reviewer check an implementer's diff for Standards and Spec conformance. Use after implementation, before merging to main.
---

# cross-review - one reviewer, two checks

The implementer never signs off on its own work. Assign exactly ONE reviewer
from a DIFFERENT vendor to check both **Standards** and **Spec**. Do not send
duplicate reviews of the same ticket and head commit.

## Procedure

1. **Pin the fixed point.** Save the diff ONCE, outside the implementer's
   worktree, and record base/head SHAs:
   `gh pr diff <pr> > <abs diff path>` or
   `git -C .worktrees/<task_id> diff <base-sha>...<head-sha> > <abs diff path>`
   (three-dot, so you compare against the merge base). Confirm the ref resolves
   and the diff is non-empty before spawning anyone.
2. **Run the gates first** - tests / lint / typecheck via `sys_os_shell`. If red,
   send it back to the implementer; do not spend reviewers on a broken diff.
3. **Gather each axis's inputs.**
   - Spec: the task's acceptance contract, or the `SPEC.md` the work came from.
   - Standards: every file that documents how code is written here
     (`CONTRIBUTING.md`, `CODING_STANDARDS.md`, lint config), plus the smell
     baseline below.
4. **Dispatch one reviewer** from a different vendor than the implementer:
   `sys_session_send(agent="claude_code"|"codex"|"flash", title="review-<slug>",
   args={purpose: "review", input: "<snapshot path + base/head SHAs + contract + standards>"})`.
   Give it ONLY the snapshot path and inputs - never the implementer's worktree
   or transcript. Require separate Standards and Spec findings, each tagged
   blocking / non-blocking / suggestion with file:line evidence, plus one verdict.
   Record its conversation ID and the reviewed head SHA in the task registry.
   If that SHA is already under review or has a verdict, do not dispatch again.
5. **Resolve findings.** A blocking issue on either check becomes a fix-task on
   the registry scoped to the same worktree, sent back to the SAME implementer
   conversation (`purpose: "implement"`, reusing its title). After the fix,
   repeat steps 1-3 on the NEW head SHA and continue the SAME reviewer
   conversation with the fix diff. Never request another review of an unchanged
   head SHA.
6. Green gates + zero blocking issues on both checks => the PR is approved:
   merge it to main yourself.

## Standards axis - smell baseline

A fixed set of Fowler smells (_Refactoring_, ch.3) applies even when the repo
documents nothing. Two rules bind it: **a documented repo standard always wins**
(suppress the smell where the repo endorses it), and **every smell is a
judgement call** - name it as "possible Feature Envy", not a violation. Skip
anything tooling already enforces.

- **Mysterious Name** - the name does not reveal what it does or holds -> rename; if no honest name exists, the design is murky.
- **Duplicated Code** - the same logic shape in more than one hunk -> extract the shared shape.
- **Feature Envy** - a method reaches into another object's data more than its own -> move it onto that data.
- **Data Clumps** - the same few fields keep travelling together -> bundle them into a type.
- **Primitive Obsession** - a primitive standing in for a domain concept -> give the concept a type.
- **Repeated Switches** - the same switch on the same type recurs -> polymorphism, or one shared map.
- **Shotgun Surgery** - one logical change forces scattered edits -> gather what changes together.
- **Divergent Change** - one module edited for several unrelated reasons -> split by reason.
- **Speculative Generality** - abstraction for needs the spec lacks -> delete it.
- **Message Chains** - long `a.b().c().d()` navigation -> hide the walk behind one method.
- **Middle Man** - a class that mostly delegates -> cut it.
- **Refused Bequest** - a subclass ignoring most of what it inherits -> composition.

## Notes

- Cross-review needs at least two AVAILABLE workers (roster preflight). With one
  vendor available you cannot run independent review - say so at the plan gate.
- Only the implementer opens or updates a PR. A reviewer's stray edit never
  reaches the deliverable because the reviewer is never given write access to
  the worktree.
