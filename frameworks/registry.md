# Framework Registry

Frameworks are larger solution patterns with internal design space.

| id | name | kind | status | version | solves | summary |
|----|------|------|--------|---------|--------|---------|
| dynamic-orchestration | Dynamic orchestration | execution | active | 1.0 | source-project-scan, behavior-equivalence-verification, subagent-context-isolation, subagent-report-interpretation | Planner-worker framework for large scan and verification work. |
| source-project-scanner | Source project scanner | execution | draft | 0.1 | source-project-scan | Inspect a Claude Code target project and emit a structured scan report. |
| codex-compat-transformer | Codex compatibility transformer | execution | draft | 0.1 | codex-compat-patching, dual-runtime-preservation | Turn scan findings into concrete, Claude-safe Codex compatibility edits. |
| behavior-equivalence-verifier | Behavior equivalence verifier | execution | draft | 0.1 | behavior-equivalence-verification, dual-runtime-preservation | Prove that important workflows still work after transformation. |
