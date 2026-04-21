---
id: source-project-scan
name: Source project scan
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we inspect a Claude Code project deeply enough to modify it safely for Codex without over-reading irrelevant source code?

## Scope

- operational files
- runtime assumptions
- Claude-specific behaviors
- wrapper commands
- high-risk portability signals

## Current Direction

The scan should focus on the target project's operating surface first and produce a durable report that the transformer can act on directly.
