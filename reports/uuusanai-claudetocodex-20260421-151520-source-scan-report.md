---
kind: source-scan-report
format_version: "1.0"
status: completed
generated_at: "2026-04-21T15:15:20+09:00"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex"
report_stem: "uuusanai-claudetocodex-20260421-151520"
---

# Source Scan Report

## Target Summary

| field | value |
| --- | --- |
| project_path | D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex |
| project_type | .NET |
| operating_system_assumptions | windows |
| shell_assumptions | powershell |
| relevant_surface_file_count | 6 |
| relevant_surface_total_lines | 1197 |
| dynamic_orchestration_recommended | true |

## Claude Surfaces

### Root policy file

- none

### .claude/settings*.json

- none

### Hooks

- none

### Agents

- none

### Skills

- none

### Commands

- none

### Wrapper scripts

| path | shell | lines | reason |
| --- | --- | --- | --- |
| scripts/scan-claude-project.ps1 | powershell | 968 | content references Claude runtime |

### Runtime-facing docs

| path | title | lines | focus |
| --- | --- | --- | --- |
| applied-solutions.md | - | 81 | runtime instructions |
| compatibility-matrix.md | Compatibility Matrix | 20 | runtime instructions |
| README.md | uuuSanAI_ClaudeToCodex | 28 | runtime instructions |
| docs/architecture.md | Architecture | 66 | runtime instructions |
| docs/pipeline.md | Conversion Pipeline | 34 | runtime instructions |

## Portability Risks

| category | severity | surface | description | evidence |
| --- | --- | --- | --- | --- |
| Environment mismatch | medium | Wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching. | `scripts/scan-claude-project.ps1` |
| Permission mismatch | medium | Approval and hook policy | The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules. | `compatibility-matrix.md`, `docs/architecture.md` |
| Environment mismatch | medium | Operating system assumptions | The scanned runtime surface appears Windows-oriented, so Codex workflows may need explicit PowerShell-safe handling. | `scripts/scan-claude-project.ps1` |

## Candidate Edit Areas

| category | target | rationale | evidence |
| --- | --- | --- | --- |
| modify | Claude-oriented wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement. | `scripts/scan-claude-project.ps1` |
| add | Codex wrapper script(s) matching existing entrypoints | Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification. | `scripts/scan-claude-project.ps1` |
| modify | Runtime-facing markdown docs | Project docs already describe runtime behavior and will need dual-runtime wording. | `applied-solutions.md`, `compatibility-matrix.md`, `README.md`, `docs/architecture.md`, `docs/pipeline.md` |

## Orchestration Note

Dynamic orchestration is recommended by the repository default thresholds (min_file_count: 3, min_total_lines: 1000).
