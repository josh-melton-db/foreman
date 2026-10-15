---
name: wizard
description: Generate an interactive bash wizard for steps only a human can perform - provisioning, credentials, CI secrets, a third-party dashboard, a one-off cutover. Use when the goal is blocked on a human-only action.
---

# wizard - guide the human through what only they can do

When work blocks on something no agent can do (create a token, click a third
party dashboard, provision a resource), do not dump instructions into chat.
Generate a script that walks the human through it.

## Procedure

1. Enumerate the human-only steps, in order, with the exact confirmation each
   one produces.
2. Write `scripts/wizard.sh`: one step at a time, echo the instruction, wait for
   Enter, then VERIFY with a command that proves the step worked. Fail loud on a
   bad result and re-print the step.
3. Read secrets from the environment or the human's own tooling. Never echo a
   secret, and never write one into the repo. Write artifacts to a path the
   human names.
4. End with a checklist of what was done and where each artifact landed, so the
   next run can verify instead of re-asking.

The wizard is the artifact - it is reusable, reviewable, and safe to re-run.
