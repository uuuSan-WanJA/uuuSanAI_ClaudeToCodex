---
kind: source-scan-report
format_version: "1.0"
status: completed
generated_at: "2026-04-21T17:25:25+09:00"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_HarnessMaker"
report_stem: "harnessmaker-completion-gate-check"
---

# Source Scan Report

## Target Summary

| field | value |
| --- | --- |
| project_path | D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_HarnessMaker |
| project_type | unknown |
| operating_system_assumptions | posix, windows |
| shell_assumptions | bash, cmd, powershell |
| relevant_surface_file_count | 18 |
| relevant_surface_total_lines | 1160 |
| dynamic_orchestration_recommended | true |

## Claude Surfaces

### Root policy file

| path | title | lines |
| --- | --- | --- |
| `CLAUDE.md` | uuuSanAI HarnessMaker | 307 |

### .claude/settings*.json

| path | parse_status | top_level | lines | error |
| --- | --- | --- | --- | --- |
| .claude/settings.json | parsed | hooks | 44 | - |

### Hooks

| path | shell | lines |
| --- | --- | --- |
| .claude/hooks/guard-read-path.sh | bash | 23 |
| .claude/hooks/problems-post-edit.sh | bash | 29 |
| .claude/hooks/problems-session-start.sh | bash | 57 |
| .claude/hooks/solutions-post-edit.sh | bash | 44 |
| .claude/hooks/solutions-session-start.sh | bash | 51 |

### Agents

| path | title | lines |
| --- | --- | --- |
| .claude/agents/solution-transplanter.md | solution-transplanter (v1.2 — single-agent implementation) | 177 |

### Skills

- none

### Commands

- none

### Wrapper scripts

| path | shell | lines | reason |
| --- | --- | --- | --- |
| .claude/hooks/problems-post-edit.sh | bash | 29 | content references Claude runtime |
| .claude/hooks/problems-session-start.sh | bash | 57 | content references Claude runtime |
| .claude/hooks/solutions-post-edit.sh | bash | 44 | content references Claude runtime |
| .claude/hooks/solutions-session-start.sh | bash | 51 | content references Claude runtime |
| RunClaude.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Opus_No1M.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Opus_xhigh.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Sonnet.bat | cmd | 2 | content references Claude runtime |
| scripts/rescan-applications.sh | bash | 181 | content references Claude runtime |

### Runtime-facing docs

| path | title | lines | focus |
| --- | --- | --- | --- |
| AGENTS.md | uuuSanAI HarnessMaker | 38 | runtime instructions |
| applications-matrix.md | Applications Matrix | 51 | runtime instructions |
| applied-projects.md | Applied Projects | 23 | runtime instructions |
| applied-solutions.md | - | 93 | runtime instructions |
| CLAUDE.md | uuuSanAI HarnessMaker | 307 | runtime instructions |
| SESSION-HANDOFF.md | Session Handoff | 34 | runtime instructions |

## Continuity Surfaces

### Repo-root Codex guides

| path | title | lines |
| --- | --- | --- |
| AGENTS.md | uuuSanAI HarnessMaker | 38 |

### Runtime launchers

| path | runtime | shell | lines | reason |
| --- | --- | --- | --- | --- |
| RunClaude.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_No1M.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_xhigh.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Sonnet.bat | claude | cmd | 2 | filename suggests runtime entrypoint |

### Session handoff artifacts

| path | title | lines | reason |
| --- | --- | --- | --- |
| SESSION-HANDOFF.md | Session Handoff | 34 | filename suggests durable handoff note |

## Portability Risks

| category | severity | surface | description | evidence |
| --- | --- | --- | --- | --- |
| Codex missing equivalent | medium | Root policy file | The project relies on CLAUDE.md guidance that must be represented honestly for Codex. | `CLAUDE.md` |
| Codex missing equivalent | high | Local runtime settings | Claude runtime settings have no guaranteed one-to-one Codex file surface and will need translation or explicit replacement. | `.claude/settings.json` |
| Codex missing equivalent | high | Hooks | Claude hooks usually require script or verification-gate emulation on the Codex side. | `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh` |
| Codex missing equivalent | medium | Agents | Claude agent prompts may need Codex delegation rewrites, but role mirroring alone is insufficient without a binding owner contract. | `.claude/agents/solution-transplanter.md` |
| Environment mismatch | medium | Wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching. | `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |
| Session continuity gap | medium | Launcher parity | Launcher-style entrypoints were detected for one runtime but not the other, so session switching may require undocumented commands. | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Permission mismatch | medium | Approval and hook policy | The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules. | `.claude/settings.json`, `applied-projects.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` |
| Unclear behavior | medium | Operating system assumptions | The runtime surface mixes Windows and POSIX expectations, so the transformer must decide whether to preserve both paths or declare a supported subset. | `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `applications-matrix.md`, `applied-projects.md`, `CLAUDE.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |

## Candidate Edit Areas

| category | target | rationale | evidence |
| --- | --- | --- | --- |
| modify | CLAUDE.md | Root operating guidance likely needs dual-runtime notes or explicit Codex handoff. | `CLAUDE.md` |
| verify-only | Repo-root Codex guide | Existing Codex-facing guidance should be checked for parity with the Claude-side contract. | `AGENTS.md` |
| verify-only | .claude/settings*.json | Local Claude runtime settings define behavior that must be preserved even if Codex support is implemented elsewhere. | `.claude/settings.json` |
| add | Codex execution or approval configuration docs | Claude runtime settings imply Codex-side policy or config artifacts will be needed. | `.claude/settings.json` |
| verify-only | .claude/hooks/** | Hook behavior should be preserved or consciously replaced, not changed blindly. | `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh` |
| add | Codex-side hook emulation scripts or verification gates | Hook semantics usually need explicit emulation outside .claude/hooks/. | `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh` |
| verify-only | .claude/agents/** | Agent instructions are part of the source behavior contract and should stay readable as evidence. | `.claude/agents/solution-transplanter.md` |
| add | Codex delegation prompt files or role docs plus a binding owner-routing contract | Agent roles likely need Codex-local equivalents, but role docs alone are not enough when task ownership is mandatory. | `.claude/agents/solution-transplanter.md` |
| modify | Claude-oriented wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement. | `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |
| add | Codex wrapper script(s) matching existing entrypoints | Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification. | `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |
| add | Missing runtime launcher or documented substitute | Launcher-style entrypoints exist for only one runtime, so session switching needs parity or an explicit substitute path. | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| verify-only | Session handoff artifact | Existing handoff notes should stay aligned with real runtime surfaces and open work. | `SESSION-HANDOFF.md` |
| modify | Runtime-facing markdown docs | Project docs already describe runtime behavior and will need dual-runtime wording. | `AGENTS.md`, `applications-matrix.md`, `applied-projects.md`, `applied-solutions.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` |

## Orchestration Note

Dynamic orchestration is recommended by the repository default thresholds (min_file_count: 3, min_total_lines: 1000).
