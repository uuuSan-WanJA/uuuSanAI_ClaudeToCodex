---
solves:
  - subagent-context-isolation
version: "1.0"
status: active
---

# Execution Packet

## Summary

Compact handoff schema for delegated scan, transform, or verification work. Adapted from HarnessMaker's `execution-packet` component.

## Required Fields

| field | type | purpose |
|-------|------|---------|
| `goal_summary` | string | One-line objective for the delegated unit. |
| `active_milestone` | string | Current stage of the parent workflow. |
| `recent_failures` | array | Relevant failed attempts or blockers, capped and concise. |
| `stop_conditions` | array | Clear reasons to stop early or escalate. |

## Optional Fields

| field | type | purpose |
|-------|------|---------|
| `handoff_reason` | string | Why the work is being delegated now. |
| `task_kind` | string | Stable task classification used by owner-routing rules. |
| `designated_owner` | string | Owner chosen before delegation or local fallback. |
| `context_hash` | string | Trace id for the parent workflow or report set. |
| `required_reads` | array | Exact files the delegated unit may need to read. |
| `user_intent_note` | string | Short note for nuance that does not fit the structured fields. |

## Usage Rules

1. Do not pass full conversation history when an execution packet is sufficient.
2. Keep `recent_failures` short and concrete.
3. Put raw file reading behind `required_reads` instead of copying file contents into the handoff.
4. When the delegated work is owner-bound, include both `task_kind` and `designated_owner`.

## Why It Helps Here

This repository will eventually need to split large scans and verification runs. The packet prevents delegated units from inheriting bloated, low-signal context.
