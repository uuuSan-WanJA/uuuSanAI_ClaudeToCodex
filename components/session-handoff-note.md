---
solves:
  - session-switch-continuity
  - dual-runtime-preservation
version: "1.0"
status: active
---

# Session Handoff Note

## Summary

Specification for a durable repo-local note that lets a project resume cleanly after work switches between Claude Code and Codex across separate sessions.

Recommended filename:

- `SESSION-HANDOFF.md`

## Required Sections

### Current State

- active milestone
- last meaningful change
- open blockers

### Files In Motion

- files intentionally being changed
- files that are intentionally left alone

### Linked Evidence

- latest source scan report
- current compatibility matrix
- latest verification report or explicit pending status

### Resume Workflow

- Claude-to-Codex resume path or explicit not-applicable note
- Codex-to-Claude resume path or explicit not-applicable note

### Switchback Status

- latest verified continuity status
- remaining continuity gaps

### Next Actions

- immediate next step
- validation still required

### Runtime-Specific Cautions

- Claude-only caveats
- Codex-only caveats
- permission or launcher caveats

## Rules

- keep the note concise and current
- point to durable reports instead of duplicating large raw evidence
- state when continuity checks are still pending instead of implying they passed
- update the note before pausing a cross-runtime workstream
- record any approved local fallback that bypassed a mandatory owner
- an existing project worklog may satisfy this component if it covers the same fields clearly
