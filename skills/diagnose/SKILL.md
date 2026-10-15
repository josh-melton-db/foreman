---
name: diagnose
description: A phase-gated loop for hard bugs and performance regressions - reproduce, minimise, hypothesise, instrument, fix, guard. Use when a failure resists a first look, or when a worker reports "fixed" without a failing repro.
---

# diagnose - a disciplined bug loop

Phases are gates: do not start the next until the current one holds evidence.

1. **Reproduce** - build the cheapest command that goes red on THIS bug, and run
   it. No repro, no diagnosis: fixing that first is the task.
2. **Minimise** - shrink the input and the surface until the smallest case still
   fails. The bug usually becomes obvious here.
3. **Hypothesise** - write down the competing explanations before touching code.
   One explanation is a guess; two is a diagnosis.
4. **Instrument** - gather evidence that discriminates between them: a log, a
   print, a failing assertion, a timing. Prefer evidence over reasoning.
5. **Fix** - the smallest change that addresses the confirmed cause. Not the
   symptom, and not a refactor.
6. **Guard** - add a regression test that fails without the fix. Run it both
   ways.

Never skip 1 or 6. Never "fix" by loosening an assertion, widening a timeout, or
retrying.
