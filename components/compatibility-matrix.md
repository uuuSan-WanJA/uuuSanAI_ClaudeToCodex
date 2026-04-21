---
solves:
  - source-project-scan
  - codex-compat-patching
  - capability-preflight-gate
version: "1.0"
status: active
---

# Compatibility Matrix

## Summary

Specification for `compatibility-matrix.md`, the repo-level artifact that compares Claude-side project surfaces against Codex representations.

## Required Columns

| column | purpose |
|--------|---------|
| `axis` | Stable surface being compared. |
| `source_runtime` | Claude-side artifact or behavior. |
| `target_runtime` | Codex-side artifact or behavior. |
| `normalization_strategy` | Direct map, emulate, rewrite, or unsupported. |
| `status` | `planned`, `in-progress`, `verified`, or `blocked`. |
| `notes` | Constraints and caveats. |

## Rules

- One row per stable portability axis.
- Status must stay conservative.
- `verified` means tested, not merely designed.
- The matrix should be specific enough to drive a patch plan.
- When session switching is in scope, include explicit axes for root-guide parity, launcher parity, handoff continuity, and switchback verification.
- When a project defines agent roles or named maintainers, include explicit axes for subagent architecture preservation, runtime contract installation gate, owner routing contract, routing preflight, delegation fallback, guarded write surfaces, and any task-routing command surface.
- When a project depends on mandatory owners or preserved subagent structure, include an explicit project-scoped Codex config axis for `.codex/config.toml` or an equivalent local `developer_instructions` layer.
- When commands, hooks, wrapper scripts, or launcher flows are part of normal operation, include an explicit workflow-parity axis rather than treating those surfaces as optional cleanup.
