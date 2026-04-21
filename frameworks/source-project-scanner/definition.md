---
solves:
  - source-project-scan
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
- `.claude` runtime files
- wrapper scripts
- runtime-specific documentation
- environment assumptions

## Output

- source scan report
- compatibility matrix rows
- identified portability risks
- candidate transform targets

## Rules

- scan operating surfaces before business code
- record evidence paths
- stop scanning deeper once the transformation-relevant facts are clear
- keep delegated scan context narrow and evidence-oriented
