---
solves:
  - action-authorization
version: "1.0"
status: active
---

# Three-Tier Blocking

## Summary

Risk-tier model for deciding which conversion actions may run automatically. Adapted from HarnessMaker's `three-tier-blocking` component.

## Tiers

| tier | example actions | runtime rule |
|------|-----------------|--------------|
| `NON_BLOCKING` | read-only scanning, report generation, metadata inspection | run immediately |
| `DELEGATED_OR_CONSENT` | patch application, new compatibility files, long verification runs, git snapshot creation | run only with explicit confirmation or approved policy |
| `HARD_GATE` | destructive deletion, reset-like rollback, overwriting user changes blindly, external side effects | never run automatically |

## Default Classification Rules

1. Unknown actions default to `HARD_GATE`.
2. Actions that alter target-project files are never `NON_BLOCKING`.
3. Rollback setup belongs at least in `DELEGATED_OR_CONSENT`.

## Why It Helps Here

This repository edits external target projects. Risk gating keeps the converter from treating real project changes like harmless local note updates.
