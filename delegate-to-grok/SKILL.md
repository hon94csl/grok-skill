---
name: delegate-to-grok
description: Delegate bounded, mechanical, objectively verifiable coding execution to the local Grok Build CLI, then inspect its changes and run relevant tests. Use after understanding the request and relevant code, before editing, when behavior is already decided and the work is repetitive, multi-file, or likely to take more than one minute. Do not use for trivial edits, ambiguous requirements, architectural decisions, security-sensitive work, destructive operations, production actions, or tasks the user asked not to delegate.
---

# Delegate to Grok

Retain judgment and final responsibility. Give Grok only a clearly bounded execution unit.

## Delegate

1. Inspect enough relevant code to decide the intended behavior, scope, and verification.
2. Keep architectural, product, compatibility, security, and destructive decisions in the current agent.
3. Delegate only when all of these conditions hold:
   - No material decision remains.
   - The task follows an existing pattern or has explicit implementation requirements.
   - The allowed scope can be stated precisely.
   - Success can be checked through tests, build output, lint, or direct inspection.
   - Direct completion would probably take more than one minute.
4. Combine related mechanical changes into one execution unit. Do not call Grok separately for types, implementation, tests, and lint when one bounded task can cover them.
5. Build a concise task brief with this shape:

```text
Objective:
<one concrete outcome>

Relevant files and reference patterns:
- <path and why it matters>

Required changes:
- <observable requirement>

Constraints:
- Do not change <boundary>.
- Do not edit unrelated files.

Acceptance criteria:
- <objective verification>
```

6. Run this skill's `scripts/run-grok.sh` from the target repository directory. Pass the brief as the only argument or through stdin. Wait for it to finish before editing the delegated files.
7. Invoke Grok at most once for the same execution unit. If it fails or leaves incomplete work, finish locally instead of repeatedly delegating.

## Verify

1. Inspect the working tree and every file Grok changed. Preserve pre-existing user changes.
2. Reject unrelated edits, invented requirements, weakened tests, unsafe behavior, or public API changes outside the brief.
3. Run the smallest relevant verification first, then broader checks when warranted.
4. Fix remaining issues locally.
5. Report Grok delegation as part of the implementation only when it is useful to explain the result or a limitation.

## Handle failures

- If `grok` is unavailable, unauthenticated, denied by the environment, or exits unsuccessfully, continue locally and mention the limitation briefly.
- If the task becomes ambiguous during scoping, do not delegate it.
- Never treat Grok's success statement as verification.
