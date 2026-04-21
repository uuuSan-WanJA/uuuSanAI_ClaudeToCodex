---
id: multi-project-rollout-consistency
name: Multi-project rollout consistency
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## Question

How do we apply the same Claude-to-Codex conversion standard across many projects without losing per-project rigor or creating conflicting writes?

## Scope

- batch intake
- parallel scan and verification waves
- shared policy baselines
- per-project exceptions
- single-writer discipline

## Current Direction

Parallelism should accelerate reads, analysis, and verification, while target-project apply steps stay explicitly controlled per repository. Shared rollout policy must never erase project-specific evidence.
