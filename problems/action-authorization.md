---
id: action-authorization
name: Action authorization
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

Which conversion actions can run immediately, which require user confirmation, and which must never run automatically?

## Scope

- read-only scanning
- target-project patching
- destructive project changes
- long-running verification
- git snapshot and rollback actions

## Current Direction

Use a stable risk-tier model so the transformer can move fast on safe actions without silently crossing into unsafe project modifications.
When a task is bound to a mandatory owner, authorization also requires the routing contract to be satisfied or an explicit local override to be approved.
