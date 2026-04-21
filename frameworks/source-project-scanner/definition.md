---
solves:
  - source-project-scan
  - mandatory-owner-routing
version: "0.1"
status: draft
---

# Source Project Scanner

## Summary

Read the operational surface of a Claude Code target project and produce a structured scan report for later transformation.

When a scan is large enough to be split, delegated scan units should use `components/execution-packet.md` for handoff and `components/subagent-reporting-protocol.md` for return format.
The default scale-up mechanism for such cases is `frameworks/dynamic-orchestration/definition.md`.

## Input Focus

- root policy file
- existing repo-root Codex guide
- `.claude` runtime files
- source subagent structure and owner boundaries when `.claude/agents/*` or role docs exist
- binding owner-routing guidance when roles or agents exist
- completion-gate language that says the target stays blocked or incomplete until the binding runtime contract is installed
- task-routing command surfaces and guarded-write rules when present
- wrapper scripts
- runtime launcher parity
- session handoff artifacts
- runtime-specific documentation
- environment assumptions

## Output

- source scan report
- compatibility matrix rows
- identified portability risks
- candidate transform targets
- continuity gaps relevant to Claude/Codex session switching
- ownership-routing gaps when role docs are present without binding owner rules
- structure-preservation gaps when source subagent topology exists but the conversion contract would flatten it
- completion-gate gaps when runtime-contract installation is treated as optional follow-up instead of part of done

## Rules

- scan operating surfaces before business code
- record evidence paths
- stop scanning deeper once the transformation-relevant facts are clear
- keep delegated scan context narrow and evidence-oriented
- treat existing Codex-side continuity artifacts as evidence to validate, not as proof of correctness
- treat role docs as descriptive unless binding owner-routing evidence is present
- when source agent surfaces exist, detect whether the conversion contract preserves or flattens that structure
- when owner routing or preserved subagent structure is in scope, detect whether the runtime contract is required for completion or left as optional guidance
