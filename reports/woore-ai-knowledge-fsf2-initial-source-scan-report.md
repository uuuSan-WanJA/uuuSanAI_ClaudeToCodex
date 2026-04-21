---
kind: source-scan-report
format_version: "1.0"
status: completed
generated_at: "2026-04-21T17:34:16+09:00"
project_path: "D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2"
report_stem: "woore-ai-knowledge-fsf2-initial"
---

# Source Scan Report

## Target Summary

| field | value |
| --- | --- |
| project_path | D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2 |
| project_type | unknown |
| operating_system_assumptions | posix, windows |
| shell_assumptions | bash, cmd, powershell |
| relevant_surface_file_count | 27 |
| relevant_surface_total_lines | 3514 |
| dynamic_orchestration_recommended | true |

## Claude Surfaces

### Root policy file

| path | title | lines |
| --- | --- | --- |
| `CLAUDE.md` | Woore AI Knowledge — 운영 스키마 | 243 |

### .claude/settings*.json

- none

### Hooks

| path | shell | lines |
| --- | --- | --- |
| .claude/hooks/feedback-prompt.md | unknown | 120 |
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
| .claude/commands/analyze-code.md | /analyze-code | 74 |
| .claude/commands/analyze-spec.md | /analyze-spec | 89 |
| .claude/commands/analyze.md | /analyze | 79 |
| .claude/commands/feedback.md | /feedback | 78 |
| .claude/commands/graphify.md | /graphify (Woore wiki 래퍼) | 31 |
| .claude/commands/ingest.md | /ingest | 29 |
| .claude/commands/lint.md | /lint | 26 |
| .claude/commands/pair.md | /pair | 102 |
| .claude/commands/query.md | /query | 28 |

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
| applied-solutions.md | - | 146 | runtime instructions |
| CLAUDE.md | Woore AI Knowledge — 운영 스키마 | 243 | runtime instructions |
| README.md | woore-ai-knowledge-fsf2 | 36 | runtime instructions |
| docs/framework-import-brief.md | Framework Import Brief | 70 | runtime instructions |
| docs/pending-imports.md | Pending Imports — 이식 대기 자산 | 63 | runtime instructions |
| docs/roles.md | Roles — 팀 롤과 에이전트 페르소나 | 50 | runtime instructions |

## Continuity Surfaces

### Repo-root Codex guides

- none

### Runtime launchers

| path | runtime | shell | lines | reason |
| --- | --- | --- | --- | --- |
| RunClaude.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_No1M.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Opus_xhigh.bat | claude | cmd | 2 | filename suggests runtime entrypoint |
| RunClaude_Sonnet.bat | claude | cmd | 2 | filename suggests runtime entrypoint |

### Session handoff artifacts

- none

## Portability Risks

| category | severity | surface | description | evidence |
| --- | --- | --- | --- | --- |
| Codex missing equivalent | medium | Root policy file | The project relies on CLAUDE.md guidance that must be represented honestly for Codex. | `CLAUDE.md` |
| Session continuity gap | medium | Root runtime guides | CLAUDE.md was found, but no repo-root Codex guide such as AGENTS.md was detected, so runtime switching may depend on undocumented memory. | `CLAUDE.md` |
| Codex missing equivalent | high | Hooks | Claude hooks usually require script or verification-gate emulation on the Codex side. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| Codex missing equivalent | medium | Agents | Claude agent prompts may need Codex delegation rewrites, but role mirroring alone is insufficient without a binding owner contract. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| Codex missing equivalent | medium | Commands | Claude command docs are likely to require Codex-specific command or workflow rewrites. | `.claude/commands/analyze-code.md`, `.claude/commands/analyze-spec.md`, `.claude/commands/analyze.md`, `.claude/commands/feedback.md`, `.claude/commands/graphify.md`, `.claude/commands/ingest.md`, `.claude/commands/lint.md`, `.claude/commands/pair.md`, `.claude/commands/query.md` |
| Behavior drift | high | Subagent architecture preservation | Agent prompts were detected, but no explicit structure-preservation rule was found. Codex conversion may flatten the source Claude subagent topology into main-agent local execution. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| Unclear behavior | high | Runtime contract installation gate | Owner-bound or structure-preserving work appears to exist, but no explicit completion gate says the target remains blocked or incomplete until the binding runtime contract is installed. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| Unclear behavior | high | Delegation fallback | Owner-bound work appears to exist, but no explicit fallback rule says what happens when delegation cannot run under the current runtime policy. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| Unclear behavior | medium | Guarded write surfaces | Owner-bound work appears to exist, but no explicit guard rules were detected for protected files or action classes. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| Unclear behavior | medium | Owner command surface | No explicit routing command surface was detected, so the main agent may need to infer ownership from descriptive docs instead of an unambiguous trigger. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| Environment mismatch | medium | Wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Session continuity gap | medium | Launcher parity | Launcher-style entrypoints were detected for one runtime but not the other, so session switching may require undocumented commands. | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Permission mismatch | medium | Approval and hook policy | The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md`, `README.md` |
| Session continuity gap | medium | Session handoff | No durable handoff note was detected, so alternating Claude and Codex sessions may lose current-state context. | `CLAUDE.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Unclear behavior | medium | Operating system assumptions | The runtime surface mixes Windows and POSIX expectations, so the transformer must decide whether to preserve both paths or declare a supported subset. | `.claude/hooks/feedback-prompt.sh`, `applied-solutions.md`, `CLAUDE.md`, `README.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |

## Candidate Edit Areas

| category | target | rationale | evidence |
| --- | --- | --- | --- |
| modify | CLAUDE.md | Root operating guidance likely needs dual-runtime notes or explicit Codex handoff. | `CLAUDE.md` |
| add | AGENTS.md or equivalent repo-root Codex guide | The project has a root Claude guide but no repo-root Codex guide for switchback-safe operation. | `CLAUDE.md` |
| verify-only | .claude/hooks/** | Hook behavior should be preserved or consciously replaced, not changed blindly. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| add | Codex-side hook emulation scripts or verification gates | Hook semantics usually need explicit emulation outside .claude/hooks/. | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` |
| verify-only | .claude/agents/** | Agent instructions are part of the source behavior contract and should stay readable as evidence. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| add | Codex delegation prompt files or role docs plus a binding owner-routing contract | Agent roles likely need Codex-local equivalents, but role docs alone are not enough when task ownership is mandatory. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| add | Subagent architecture preservation rule in runtime guides | Projects with named agents should preserve the source Claude subagent topology instead of flattening it into main-agent local execution. | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` |
| add | Runtime contract installation completion gate | When owner routing or source subagent preservation is required, completion should stay blocked until the binding runtime contract is installed in repo-root guides. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| add | Delegation fallback rule for mandatory-owner work | If delegation is unavailable, the runtime contract must force approval or explicit local override instead of silent local execution. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| add | Guard rules for owner-bound writes | Protected surfaces should warn or stop before the main agent edits them locally. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| add | Owner-routing command surface | Explicit routing commands reduce ambiguity around mandatory-owner work and help Codex avoid local misrouting. | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` |
| modify | .claude/commands/** | Claude command docs often need dual-runtime language or adjacent Codex task docs. | `.claude/commands/analyze-code.md`, `.claude/commands/analyze-spec.md`, `.claude/commands/analyze.md`, `.claude/commands/feedback.md`, `.claude/commands/graphify.md`, `.claude/commands/ingest.md`, `.claude/commands/lint.md`, `.claude/commands/pair.md`, `.claude/commands/query.md` |
| modify | Claude-oriented wrapper scripts | Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| add | Codex wrapper script(s) matching existing entrypoints | Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification. | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| add | Missing runtime launcher or documented substitute | Launcher-style entrypoints exist for only one runtime, so session switching needs parity or an explicit substitute path. | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| add | SESSION-HANDOFF.md or equivalent durable worklog | Alternating Claude and Codex sessions should leave behind a durable next-step artifact instead of relying on session memory. | `CLAUDE.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| modify | Runtime-facing markdown docs | Project docs already describe runtime behavior and will need dual-runtime wording. | `applied-solutions.md`, `CLAUDE.md`, `README.md`, `docs/framework-import-brief.md`, `docs/pending-imports.md`, `docs/roles.md` |

## Orchestration Note

Dynamic orchestration is recommended by the repository default thresholds (min_file_count: 3, min_total_lines: 1000).
