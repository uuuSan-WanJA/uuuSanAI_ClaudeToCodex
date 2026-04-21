---
id: dual-runtime-preservation
name: Dual-runtime preservation
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we add Codex compatibility without silently breaking the original Claude-side workflow?

## Scope

- backward-safe edits
- runtime-specific branching
- shared artifacts
- runtime-specific instructions

## Current Direction

The default target state is compatibility expansion, not replacement. Transformer output should preserve Claude behavior unless the user explicitly requests otherwise.
