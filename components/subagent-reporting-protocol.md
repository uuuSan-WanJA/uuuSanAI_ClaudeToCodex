---
solves:
  - subagent-report-interpretation
version: "1.0"
status: active
---

# Subagent Reporting Protocol

## Summary

Structured report format for delegated scan, transform, or verification work. Adapted from HarnessMaker's `subagent-reporting-protocol` component.

## Required Sections

### 1. Context Anchor

- overall goal
- this unit's contribution

### 2. Structural Layer

- factual findings only
- explicit evidence references
- no speculative interpretation

### 3. Interpretation Layer

- weight
- surprise
- gaps
- confidence

### 4. Persona Slot

Optional perspective layer when the caller explicitly asks for one.

## Integration Rules

1. Merge structural layers across units.
2. Keep interpretation layers separate until synthesis.
3. Treat persona commentary as optional input, not core evidence.

## Why It Helps Here

Large source-project scans and split verification runs are hard to recombine cleanly. This protocol prevents facts, interpretation, and commentary from getting mixed together.
