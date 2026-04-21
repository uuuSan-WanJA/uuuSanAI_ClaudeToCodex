---
version: "1.0"
status: active
solves:
  - source-project-scan
  - behavior-equivalence-verification
  - subagent-context-isolation
  - subagent-report-interpretation
---

# Dynamic Orchestration

## Summary

General-purpose planner-worker framework for large read, analysis, and verification tasks. Transplanted and adapted from HarnessMaker's `dynamic-orchestration`.

This framework is intentionally not the default writer for target-project patch application. In this repository it is primarily a scale-up mechanism for:

- large source-project scans
- split verification runs
- evidence-heavy comparison work

## Fit Conditions

- 3 or more relevant files
- 1000 or more total lines in scope
- evidence gathering benefits from parallel analysis
- main-context loading would be wasteful or risky

## Non-fit Conditions

- a single small file
- tightly serial work with no real delegation value
- direct target-project patch application that should stay under a single writer

## Components

| file | role |
|------|------|
| `frameworks/dynamic-orchestration/prompts/perspectives.md` | dimension pool, execution-mode rules, resource logic |
| `frameworks/dynamic-orchestration/prompts/planner.md` | planner prompt |
| `frameworks/dynamic-orchestration/prompts/worker.md` | single-worker prompt for small scopes |
| `frameworks/dynamic-orchestration/prompts/executor.md` | extraction unit for larger scopes |
| `frameworks/dynamic-orchestration/prompts/analyzer.md` | analysis unit for extracted data |

## Usage

### 1. Metadata Collection

The main agent gathers file list, path, and line-count metadata. It does not load full source content at this step.

### 2. Level Selection

- small scope -> single worker
- larger scope -> planner + mixed worker / executor / analyzer plan

### 3. Planner Phase

The planner receives:

- target metadata
- work type
- execution packet
- the perspectives prompt

It returns a `work_plan`.

### 4. Mechanical Validation

Before dispatch:

1. `single` mode items must stay under the size threshold.
2. context anchors must exist.
3. any consolidated analysis ids must match real consolidation groups.

If validation fails, planning must be retried rather than silently patched by the main agent.

### 5. Execution

- `single` items -> `worker.md`
- `two_stage` items -> `executor.md` then `analyzer.md`

Use `components/execution-packet.md` for handoff and `components/subagent-reporting-protocol.md` for returned structure.

### 6. Synthesis

The main agent integrates structural findings and interpretation separately. Raw results are supporting artifacts, not the final user-facing synthesis.

## Configuration

Policy-shaped defaults should follow `components/policy-optionality-convention.md`.

Suggested defaults:

```yaml
activation:
  min_file_count: 3
  min_total_lines: 1000
  level0_max_lines_per_file: 100

execution_mode:
  two_stage_threshold_lines: 200

cost_ceiling:
  max_workers: 5

scope_policy:
  default_domains:
    - scanner
    - verifier
  transformer_apply_uses_dynamic: false
```

## Hard-coded vs Configurable

| type | examples | policy |
|------|----------|--------|
| hard-coded | planner-worker split, single vs two-stage modes, main agent should not absorb large raw scopes unnecessarily | framework identity |
| configurable | thresholds, worker cap, model defaults, scope domains where the framework auto-activates | project policy |

## This Repository's Rule

Dynamic orchestration is a first-class framework here, but its default operational domain is:

- scanner
- verifier

The `codex-compat-transformer` may use its primitives for assessment work, but target-project apply steps should remain single-writer unless a later explicit design proves otherwise.
