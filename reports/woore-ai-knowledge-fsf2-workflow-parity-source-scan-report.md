---
kind: source-scan-report
format_version: "1.0"
status: completed
generated_at: "2026-04-21T17:57:26+09:00"
project_path: "D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2"
report_stem: "woore-ai-knowledge-fsf2-workflow-parity"
---

# Source Scan Report

## Target Summary

| field | value |
| --- | --- |
| project_path | D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2 |
| project_type | unknown |
| operating_system_assumptions | posix, windows |
| shell_assumptions | bash, cmd, powershell |
| relevant_surface_file_count | 32 |
| relevant_surface_total_lines | 3747 |
| dynamic_orchestration_recommended | true |

## Claude Surfaces

### Root policy file

| path | title | lines |
| --- | --- | --- |
| `CLAUDE.md` | Woore AI Knowledge — 운영 스키마 | 293 |

### .claude/settings*.json

- none

### Hooks

| path | shell | lines |
| --- | --- | --- |
| .claude/hooks/feedback-prompt.md | unknown | 126 |
| .claude/hooks/feedback-prompt.sh | bash | 52 |

### Agents

| path | title | lines |
| --- | --- | --- |
| .claude/agents/saturation-code-analyst.md | Saturation: Code Analyst | 357 |
| .claude/agents/saturation-completeness-overseer.md | Saturation: Completeness Overseer | 615 |
| .claude/agents/saturation-concept-curator.md | Saturation: Concept Curator | 209 |
| .claude/agents/saturation-cross-verifier.md | Saturation: Cross Verifier | 426 |
| .claude/agents/saturation-domain-curator.md | Saturation: Domain Curator | 323 |
| .claude/agents/saturation-spec-analyst.md | Saturation: Spec Analyst | 260 |

### Skills

- none

### Commands

| path | title | lines |
| --- | --- | --- |
| .claude/commands/analyze-code.md | /analyze-code | 76 |
| .claude/commands/analyze-spec.md | /analyze-spec | 91 |
| .claude/commands/analyze.md | /analyze | 81 |
| .claude/commands/feedback.md | /feedback | 80 |
| .claude/commands/graphify.md | /graphify (Woore wiki 래퍼) | 33 |
| .claude/commands/ingest.md | /ingest | 32 |
| .claude/commands/lint.md | /lint | 28 |
| .claude/commands/pair.md | /pair | 104 |
| .claude/commands/query.md | /query | 30 |

### Wrapper scripts

| path | shell | lines | reason |
| --- | --- | --- | --- |
| .claude/hooks/feedback-prompt.sh | bash | 52 | content references Claude runtime |
| RunClaude.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Opus_No1M.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Opus_xhigh.bat | cmd | 2 | content references Claude runtime |
| RunClaude_Sonnet.bat | cmd | 2 | content references Claude runtime |

### Runtime-facing docs

| path | title | lines | focus |
| --- | --- | --- | --- |
| AGENTS.md | Woore AI Knowledge — Codex Runtime Guide | 77 | runtime instructions |
| applied-solutions.md | - | 147 | runtime instructions |
| CLAUDE.md | Woore AI Knowledge — 운영 스키마 | 293 | runtime instructions |
| README.md | woore-ai-knowledge-fsf2 | 42 | runtime instructions |
| SESSION-HANDOFF.md | SESSION-HANDOFF | 25 | runtime instructions |
| docs/codex-parity.md | Codex Parity | 35 | runtime instructions |
| docs/framework-import-brief.md | Framework Import Brief | 70 | runtime instructions |
| docs/pending-imports.md | Pending Imports — 이식 대기 자산 | 73 | runtime instructions |
| docs/roles.md | Roles — 팀 롤과 에이전트 페르소나 | 50 | runtime instructions |

## Continuity Surfaces

### Repo-root Codex guides

| path | title | lines |
| --- | --- | --- |
| AGENTS.md | Woore AI Knowledge — Codex Runtime Guide | 77 |

### Runtime launchers

| path | runtime | shell | lines | reason |
| --- | --- | --- | --- | --- |
| RunClaude.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_No1M.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_xhigh.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Sonnet.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunCodex.bat | codex | cmd | 2 | filename suggests runtime entrypoint |
| RunCodex_xhigh.bat | codex | cmd | 2 | filename suggests runtime entrypoint |

### Session handoff artifacts

| path | title | lines | reason |
| --- | --- | --- | --- |
| SESSION-HANDOFF.md | SESSION-HANDOFF | 25 | filename suggests durable handoff note |

## Portability Risks

| category | severity | surface | description | evidence |
| --- | --- | --- | --- | --- |
| Codex missing equivalent | medium | Root policy file | The project relies on CLAUDE.md guidance that must be represented honestly for Codex. | `CLAUDE.md` |
| Codex missing equivalent | high | Hooks | Claude hooks usually require script or verification-gate emulation on the Codex side. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| Codex missing equivalent | medium | Agents | Claude agent prompts may need Codex delegation rewrites, but role mirroring alone is insufficient without a binding owner contract. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| Codex missing equivalent | medium | Commands | Claude command docs are likely to require Codex-specific command or workflow rewrites. | `.claude/commands/analyze-code.md`, `.claude/commands/analyze-spec.md`, `.claude/commands/analyze.md`, `.claude/commands/feedback.md`, `.claude/commands/graphify.md`, `.claude/commands/ingest.md`, `.claude/commands/lint.md`, `.claude/commands/pair.md`, `.claude/commands/query.md` |
| Environment mismatch | medium | Wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Permission mismatch | medium | Approval and hook policy | The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules. | `AGENTS.md`, `applied-solutions.md`, `CLAUDE.md`, `docs/codex-parity.md`, `docs/pending-imports.md`, `README.md`, `SESSION-HANDOFF.md` |
| Unclear behavior | medium | Operating system assumptions | The runtime surface mixes Windows and POSIX expectations, so the transformer must decide whether to preserve both paths or declare a supported subset. | `.claude/hooks/feedback-prompt.sh`, `AGENTS.md`, `applied-solutions.md`, `CLAUDE.md`, `docs/codex-parity.md`, `README.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `RunCodex.bat`, `RunCodex_xhigh.bat` |

## Candidate Edit Areas

| category | target | rationale | evidence |
| --- | --- | --- | --- |
| modify | CLAUDE.md | Root operating guidance likely needs dual-runtime notes or explicit Codex handoff. | `CLAUDE.md` |
| verify-only | Repo-root Codex guide | Existing Codex-facing guidance should be checked for parity with the Claude-side contract. | `AGENTS.md` |
| verify-only | .claude/hooks/** | Hook behavior should be preserved or consciously replaced, not changed blindly. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| add | Codex-side hook emulation scripts or verification gates | Hook semantics usually need explicit emulation outside .claude/hooks/. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| verify-only | .claude/agents/** | Agent instructions are part of the source behavior contract and should stay readable as evidence. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| add | Codex delegation prompt files or role docs plus a binding owner-routing contract | Agent roles likely need Codex-local equivalents, but role docs alone are not enough when task ownership is mandatory. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| modify | .claude/commands/** | Claude command docs often need dual-runtime language or adjacent Codex task docs. | `.claude/commands/analyze-code.md`, `.claude/commands/analyze-spec.md`, `.claude/commands/analyze.md`, `.claude/commands/feedback.md`, `.claude/commands/graphify.md`, `.claude/commands/ingest.md`, `.claude/commands/lint.md`, `.claude/commands/pair.md`, `.claude/commands/query.md` |
| modify | Claude-oriented wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| add | Codex wrapper script(s) matching existing entrypoints | Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| verify-only | Session handoff artifact | Existing handoff notes should stay aligned with real runtime surfaces and open work. | `SESSION-HANDOFF.md` |
| modify | Runtime-facing markdown docs | Project docs already describe runtime behavior and will need dual-runtime wording. | `AGENTS.md`, `applied-solutions.md`, `CLAUDE.md`, `README.md`, `SESSION-HANDOFF.md`, `docs/codex-parity.md`, `docs/framework-import-brief.md`, `docs/pending-imports.md`, `docs/roles.md` |

## Orchestration Note

Dynamic orchestration is recommended by the repository default thresholds (min_file_count: 3, min_total_lines: 1000).
