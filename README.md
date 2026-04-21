# uuuSanAI_ClaudeToCodex

System for taking a project written to run under Claude Code and modifying that project so it also runs correctly under Codex without breaking the Claude-side workflow or losing cross-session handoff clarity.

## Goal

The repository is centered on project conversion, not on meta documentation.

The intended pipeline is:

1. Scan a target Claude Code project.
2. Detect Claude-specific operational surfaces.
3. Plan the Codex compatibility changes needed.
4. Apply project edits.
5. Verify that the edited project still works as intended in both runtimes.
6. Preserve a clean session handoff path when work will alternate between Claude Code and Codex.

## Main Working Areas

- `scanner/`: source-project discovery rules and scan outputs
- `transformer/`: compatibility patch planning and project modification rules
- `verifier/`: dual-runtime verification rules
- `reports/`: durable scan, patch, and verification artifacts
- `adapters/`: runtime-specific contracts used by the pipeline
- `preflight/`: required gating before claiming success

## Core Artifacts

- `compatibility-matrix.md`: Claude surface to Codex surface mapping
- `applied-solutions.md`: record of which conversion artifacts this repo itself is already using
- `preflight/checklist.md`: mandatory gates before a project can be called Codex-compatible
- `components/owner-routing-contract.md`: binding rule for separating descriptive roles from mandatory task owners
- `components/session-handoff-note.md`: durable continuity note shape for cross-runtime session switches
- `CLAUDE.md` and `AGENTS.md`: repo-root runtime guides that carry the live owner-routing contract

## Direction

This repository should produce:

- scan reports
- patch plans
- actual project modifications
- verification reports
- continuity-safe runtime guidance and handoff artifacts when the target project needs session switching
- binding owner-routing guidance when the target project assigns named owners to specific task kinds
- converted Codex-side docs and workflows that preserve the source Claude subagent structure when the target project already uses one

If an artifact does not help one of those outcomes, it is not central.
