---
kind: compatibility-matrix
format_version: "1.0"
status: draft
last_updated: "2026-04-21"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex"
report_stem: "uuusanai-claudetocodex-20260421-151520"
---

# Compatibility Matrix

| axis | source_runtime | target_runtime | normalization_strategy | status | notes |
| --- | --- | --- | --- | --- | --- |
| Wrapper commands | `scripts/scan-claude-project.ps1` | Shell recipes and helper scripts that preserve behavior across runtimes | rewrite | planned | Detected 1 wrapper script(s) with direct Claude references. |
| Permission model | `compatibility-matrix.md`, `docs/architecture.md` | Codex sandbox and escalation policy documentation | emulate | planned | Approval or permission language was detected in runtime settings or docs. |
| Operating system assumptions | windows | Codex-compatible platform policy or dual-path wrappers | rewrite | planned | Evidence: `scripts/scan-claude-project.ps1` |
| Shell assumptions | powershell | Codex shell usage and script normalization rules | rewrite | planned | Evidence: `scripts/scan-claude-project.ps1` |
