---
solves:
  - behavior-equivalence-verification
  - dual-runtime-preservation
version: "0.1"
status: draft
---

# Behavior Equivalence Verifier

## Summary

Verify that the converted project still behaves correctly in the workflows that matter.

Split verification runs may use `components/execution-packet.md` for handoff and `components/subagent-reporting-protocol.md` for structured results.
The default scale-up mechanism for such cases is `frameworks/dynamic-orchestration/definition.md`.

## Required Checks

- Claude-side path still valid
- Codex-side path now valid
- representative project workflow passes

## Output

- verification report
- compatibility verdict by workflow

## Rules

- verify workflows, not only files
- treat unknowns as failures to prove compatibility
- keep evidence attached to each verdict
- keep delegated verification results fact-first and mergeable
