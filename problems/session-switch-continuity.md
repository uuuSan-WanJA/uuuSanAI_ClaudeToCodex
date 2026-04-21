---
id: session-switch-continuity
name: Session switch continuity
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we let work move from Claude Code to Codex and back again across sessions without losing operating context, next-step clarity, or safety constraints?

## Scope

- root runtime guides
- runtime launcher parity
- durable handoff artifacts
- resume workflow expectations
- switchback verification

## Current Direction

Dual-runtime compatibility is not enough by itself. Projects that are meant to alternate between Claude Code and Codex should preserve a durable handoff path and prove that both runtimes can resume work safely.
