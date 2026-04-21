---
solves:
  - multi-project-rollout-consistency
version: "0.1"
status: draft
---

# Multi-Project Rollout

## Summary

Coordinate Claude-to-Codex conversion work across multiple target projects while preserving the evidence discipline of the single-project pipeline.

This framework composes the existing execution frameworks. It does not replace them:

- `frameworks/source-project-scanner/definition.md`
- `frameworks/codex-compat-transformer/definition.md`
- `frameworks/behavior-equivalence-verifier/definition.md`
- `frameworks/dynamic-orchestration/definition.md`

## Primary Use

- many projects need the same conversion policy baseline
- scan and verification work can benefit from parallel waves
- final apply steps still need per-project control

## Phases

### 1. Batch Intake

- list target repositories
- record rollout policy defaults
- express rollout defaults and exceptions with `components/policy-optionality-convention.md`
- mark projects that require special handling

### 2. Parallel Scan Wave

- run `source-project-scanner` per target
- allow `dynamic-orchestration` for large scan scopes
- keep scan outputs isolated per project

### 3. Central Baseline Review

- compare scan findings
- separate global rules from project-specific exceptions
- decide which changes can be standardized safely

### 4. Per-Project Transform Wave

- run `codex-compat-transformer` per target
- keep one active writer per repository root
- stop and escalate when a project diverges from the shared baseline

### 5. Verification Wave

- run `behavior-equivalence-verifier` per target
- parallelize verification where evidence gathering is independent
- when verification splits further, reuse `frameworks/dynamic-orchestration/definition.md`, `components/execution-packet.md`, and `components/subagent-reporting-protocol.md`
- record per-project verdicts, not only batch-level summaries

### 6. Rollout Closeout

- capture unresolved exceptions
- note which projects passed, failed, or remain partial
- if a batch summary is produced, keep it as an index to per-project reports rather than a replacement for them
- preserve handoff context for later waves

## Dual-Runtime Continuity Gate

Before a project is marked rollout-ready, confirm:

- root runtime guidance is mirrored or explicitly cross-referenced
- Claude and Codex entrypoints have parity or an explicit documented substitute
- permission and escalation differences are documented
- when the target workflow alternates between Claude Code and Codex, a durable session handoff note exists or an equivalent project worklog is named
- when the target workflow alternates between Claude Code and Codex, a switchback verification workflow is defined

## Rules

- parallelize reads and verification freely, but never concurrent writes to the same repo
- do not apply a shared patch blindly across all projects
- record exceptions per target as first-class outputs
- batch success is the aggregation of project verdicts, not a substitute for them
