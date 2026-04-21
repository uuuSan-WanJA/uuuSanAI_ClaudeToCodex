---
id: subagent-context-isolation
name: Subagent context isolation
status: active
importance: medium
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we delegate scan, transform, or verification work without leaking large, noisy session context into each worker?

## Scope

- delegated scan slices
- delegated verification slices
- focused file-read assignments
- retry and follow-up handoff

## Current Direction

Use a compact execution packet instead of passing full conversation or raw project context to every delegated unit.
