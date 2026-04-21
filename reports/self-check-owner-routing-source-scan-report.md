---
kind: source-scan-report
format_version: "1.0"
status: completed
generated_at: "2026-04-21T17:09:06+09:00"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex"
report_stem: "self-check-owner-routing"
---

# Source Scan Report

## Target Summary

| field | value |
| --- | --- |
| project_path | D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex |
| project_type | unknown |
| operating_system_assumptions | posix, windows |
| shell_assumptions | bash, powershell |
| relevant_surface_file_count | 9 |
| relevant_surface_total_lines | 839 |
| dynamic_orchestration_recommended | false |

## Claude Surfaces

### Root policy file

| path | title | lines |
| --- | --- | --- |
| `CLAUDE.md` | Claude Operating Guide | 60 |

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
| scripts/patch-harnessmaker-owner-routing.ps1 | powershell | 388 | content references Claude runtime |

### Runtime-facing docs

| path | title | lines | focus |
| --- | --- | --- | --- |
| AGENTS.md | Codex Operating Guide | 48 | runtime instructions |
| applied-solutions.md | - | 102 | runtime instructions |
| CLAUDE.md | Claude Operating Guide | 60 | runtime instructions |
| compatibility-matrix.md | Compatibility Matrix | 29 | runtime instructions |
| README.md | uuuSanAI_ClaudeToCodex | 35 | runtime instructions |
| SESSION-HANDOFF.md | Session Handoff | 30 | runtime instructions |
| docs/architecture.md | Architecture | 88 | runtime instructions |
| docs/pipeline.md | Conversion Pipeline | 59 | runtime instructions |

## Continuity Surfaces

### Repo-root Codex guides

| path | title | lines |
| --- | --- | --- |
| AGENTS.md | Codex Operating Guide | 48 |

### Runtime launchers

- none

### Session handoff artifacts

| path | title | lines | reason |
| --- | --- | --- | --- |
| SESSION-HANDOFF.md | Session Handoff | 30 | filename suggests durable handoff note |

## Portability Risks

| category | severity | surface | description | evidence |
| --- | --- | --- | --- | --- |
| Codex missing equivalent | medium | Root policy file | The project relies on CLAUDE.md guidance that must be represented honestly for Codex. | `CLAUDE.md` |
| Environment mismatch | medium | Wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching. | `scripts/patch-harnessmaker-owner-routing.ps1` |
| Permission mismatch | medium | Approval and hook policy | The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules. | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `docs/architecture.md`, `docs/pipeline.md`, `SESSION-HANDOFF.md` |
| Unclear behavior | medium | Operating system assumptions | The runtime surface mixes Windows and POSIX expectations, so the transformer must decide whether to preserve both paths or declare a supported subset. | `AGENTS.md`, `CLAUDE.md`, `scripts/patch-harnessmaker-owner-routing.ps1` |

## Candidate Edit Areas

| category | target | rationale | evidence |
| --- | --- | --- | --- |
| modify | CLAUDE.md | Root operating guidance likely needs dual-runtime notes or explicit Codex handoff. | `CLAUDE.md` |
| verify-only | Repo-root Codex guide | Existing Codex-facing guidance should be checked for parity with the Claude-side contract. | `AGENTS.md` |
| modify | Claude-oriented wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement. | `scripts/patch-harnessmaker-owner-routing.ps1` |
| add | Codex wrapper script(s) matching existing entrypoints | Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification. | `scripts/patch-harnessmaker-owner-routing.ps1` |
| verify-only | Session handoff artifact | Existing handoff notes should stay aligned with real runtime surfaces and open work. | `SESSION-HANDOFF.md` |
| modify | Runtime-facing markdown docs | Project docs already describe runtime behavior and will need dual-runtime wording. | `AGENTS.md`, `applied-solutions.md`, `CLAUDE.md`, `compatibility-matrix.md`, `README.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md` |

## Orchestration Note

Dynamic orchestration is not recommended by the repository default thresholds (min_file_count: 3, min_total_lines: 1000).
