---
id: capability-preflight-gate
name: Capability preflight gate
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

What must be checked before we can truthfully say that a Claude Code target project can be modified to run correctly on Codex?

## Scope

- required Codex capabilities
- unsupported Claude-specific surfaces
- emulation requirements
- project patch risk
- verification readiness

## Current Direction

Make preflight explicit and mandatory. No target project should be marked ready until unknowns and blockers are surfaced before the transformer edits files.
