---
solves:
  - artifact-ownership-tracking
version: "1.0"
status: active
---

# Applied Solutions Manifest

## Summary

Specification for `applied-solutions.md`, the authoritative record of which conversion frameworks and components are in active use.

## Top-level Fields

| field | type | required | notes |
|-------|------|----------|-------|
| `project_id` | string | yes | Use `<self>` for this repository. |
| `project_path` | string | yes | `"."` is allowed for the current repo. |
| `format_version` | string | yes | Current value: `"1.0"`. |
| `applications` | array | yes | Applied solution entries. |

## Application Entry Fields

| field | type | required | notes |
|-------|------|----------|-------|
| `id` | string | yes | Solution id. |
| `kind` | string | yes | `framework` or `component`. |
| `source_path` | string | yes | Relative path inside this repo. |
| `pinned_version` | string | yes | `latest`, exact version, or future range notation. |
| `applied_at` | string | yes | ISO date. |
| `applied_by` | string | yes | `<self>` or tool name. |
| `notes` | string | no | Free-form adoption notes. |

## Rules

- This file is the source of truth for adoption state.
- Registry files describe available solutions, not active usage.
- A solution should not appear here unless the repo is honestly using it.
