---
name: glossary
description: Maintain the repo's shared language (GLOSSARY.md + short ADRs) and require every worker to use it. Use when workers invent near-synonyms, when a domain concept keeps being re-explained, or before dispatching parallel work.
---

# glossary - one name per concept

Workers in separate worktrees drift in vocabulary, and every synonym costs
tokens and makes the codebase harder to navigate. A shared language is the fix.

## Procedure

1. If `GLOSSARY.md` exists, read it and reuse its exact terms in every dispatch
   prompt.
2. When a domain concept needs a name, add one line:
   `term - one-sentence definition - where it lives (file or symbol)`.
   One line per concept, no essays.
3. Record decisions that are expensive to reverse as short ADRs under
   `docs/adr/NNNN-slug.md`: context, decision, consequences.
4. Hand the glossary to each implementer in its task prompt and require the
   terms be used in code, tests, and commit messages.
5. Enforce it on review: if a worker introduces a synonym for an existing term,
   the fix is to rename, not to accept the synonym.

You may write and edit `GLOSSARY.md` and ADRs yourself - they are docs, not
code.
