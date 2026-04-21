---
id: codex-compat-patching
name: Codex compatibility patching
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we turn scan findings into concrete edits that make a Claude-oriented project run under Codex?

## Scope

- policy file rewrites
- compatibility shims
- command mapping
- project-local documentation changes
- runtime-specific configuration changes

## Current Direction

The patching layer should emit concrete file edits, not only recommendations.
