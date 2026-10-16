---
name: cross-review
description: Verify an implementer's diff along two independent axes - Standards (does it follow this repo's rules?) and Spec (does it do what was asked?) - each judged by a different-vendor reviewer, in parallel. Use after any implementation, before merging to main.
---

# cross-review - two axes, two vendors

The implementer never signs off on its own work. Press review along **two
independent axes**, each run by a DIFFERENT vendor than the implementer, in
parallel, so neither axis pollutes the other's context.

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
4. **Dispatch BOTH reviewers in parallel**, each tagged and each a different
   vendor from the implementer:
   `sys_session_send(agent="claude_code"|"codex"|"flash", title="review-standards-<slug>",
   args={purpose: "review", input: "..."})`
   and the same with `title="review-spec-<slug>"`.
   Give each ONLY the snapshot path plus its inputs - never the implementer's
   worktree or transcript. Instruct: report blocking / non-blocking /
   suggestions, each with file:line evidence; do not edit code.
5. **Aggregate.** A blocking issue from either axis becomes a fix-task on the
   registry scoped to the same worktree, sent back to the SAME implementer
   conversation (`purpose: "implement"`, reusing its title) so it keeps its
   branch and PR. Then loop to step 1.
6. Green gates + zero blocking issues on both axes => the PR is approved:
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
