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
- switchback workflows pass when the project is meant to alternate between runtimes

## Output

- verification report
- compatibility verdict by workflow
- continuity verdict for resume paths when applicable

## Rules

- verify workflows, not only files
- treat unknowns as failures to prove compatibility
- keep evidence attached to each verdict
- keep delegated verification results fact-first and mergeable
- when continuity is in scope, check both Claude-to-Codex and Codex-to-Claude resume paths explicitly
