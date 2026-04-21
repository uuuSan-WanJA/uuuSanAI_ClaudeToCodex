---
id: behavior-equivalence-verification
name: Behavior equivalence verification
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

What evidence is enough to say that a converted project behaves the same way in the workflows that matter?

## Scope

- representative tasks
- pre and post patch comparison
- Claude-side safety checks
- Codex-side success checks

## Current Direction

Verification should be workflow-based. A project is not "compatible" because files were translated; it is compatible because representative tasks still work.
