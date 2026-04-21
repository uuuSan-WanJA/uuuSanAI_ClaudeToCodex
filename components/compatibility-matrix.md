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
