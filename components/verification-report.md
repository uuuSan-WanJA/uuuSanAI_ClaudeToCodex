---
solves:
  - behavior-equivalence-verification
  - dual-runtime-preservation
version: "1.0"
status: active
---

# Verification Report

## Summary

Specification for the evidence artifact produced after conversion work.

## Required Sections

### Workflow Table

- workflow id
- runtime
- expected result
- actual result
- verdict

### Claude-side Safety

- what was checked
- what still works
- what is unverified

### Codex-side Readiness

- what now works
- what still needs emulation
- blockers

### Session Switchback

- Claude-to-Codex resume result when applicable
- Codex-to-Claude resume result when applicable
- remaining continuity gaps

### Owner Routing Exceptions

- mandatory-owner tasks completed by delegation or local fallback
- approval or override evidence when local fallback was used
- remaining owner-contract gaps

## Verdict Values

- pass
- pass-with-gap
- fail

## Rules

- verification must refer to workflows, not only files
- unknowns must stay visible
- a project is not fully compatible while critical workflows remain unverified
- file presence alone is not enough to claim session-switch continuity
- if a mandatory-owner task ran through local fallback, the report must say so explicitly
