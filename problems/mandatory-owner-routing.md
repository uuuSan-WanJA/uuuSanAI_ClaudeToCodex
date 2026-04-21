---
id: mandatory-owner-routing
name: Mandatory owner routing
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we stop descriptive role docs from being misread as optional hints when some task kinds must be owned by a designated maintainer?

## Scope

- role versus owner separation
- task-kind routing
- delegation-by-default for mandatory owners
- explicit local fallback approval
- guarded write surfaces
- command surfaces for routing

## Current Direction

Publish a binding owner-routing contract in repo-root operating docs.
The main agent must resolve `task_kind`, `designated_owner`, `delegate_or_local`, and `why` before edits.
If delegation is unavailable for mandatory-owner work, the workflow must stop for delegation approval or explicit local-fallback approval.
