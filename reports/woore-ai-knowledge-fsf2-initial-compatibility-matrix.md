---
kind: compatibility-matrix
format_version: "1.0"
status: draft
last_updated: "2026-04-21"
project_path: "D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2"
report_stem: "woore-ai-knowledge-fsf2-initial"
---

# Compatibility Matrix

| axis | source_runtime | target_runtime | normalization_strategy | status | notes |
| --- | --- | --- | --- | --- | --- |
| Root policy file | `CLAUDE.md` | AGENTS.md or equivalent Codex-facing repo guide | rewrite | planned | Detected root operating guide at CLAUDE.md. |
| Hooks | `.claude/hooks/feedback-prompt.md`, `.claude/hooks/feedback-prompt.sh` | Scripts plus verification gates that emulate hook behavior | emulate | planned | Detected 2 hook file(s). |
| Agents | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` | Codex delegation prompts or task-role docs | emulate | planned | Detected 6 agent prompt file(s). Agent mirroring alone is not enough when ownership is mandatory. |
| Subagent architecture preservation | `.claude/agents/saturation-code-analyst.md`, `.claude/agents/saturation-completeness-overseer.md`, `.claude/agents/saturation-concept-curator.md`, `.claude/agents/saturation-cross-verifier.md`, `.claude/agents/saturation-domain-curator.md`, `.claude/agents/saturation-spec-analyst.md` | Codex-facing docs and workflows that preserve the source Claude subagent structure and owner boundaries | rewrite | blocked | Named agents were detected, but no explicit subagent-structure preservation rule was found. |
| Runtime contract installation gate | No explicit runtime-contract completion gate detected | Target remains blocked or incomplete until the binding runtime contract is installed in repo-root guides | rewrite | blocked | Owner routing or source subagent preservation appears in scope, but no explicit rule says the target remains blocked or incomplete until the binding runtime contract is installed. |
| Owner routing contract | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` | Root runtime guides or policy docs that bind task kinds to mandatory owners | rewrite | planned | Detected binding owner-routing language in `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md`. |
| Routing preflight | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md` | Explicit `task_kind`, `designated_owner`, `delegate_or_local`, and `why` gate before edits | rewrite | planned | Owner-routing guidance appears to define preflight routing fields. |
| Delegation fallback | No explicit delegation fallback rule detected | Delegation approval request or explicit local override before owner-bound local edits | rewrite | blocked | Mandatory-owner work may collapse into silent local execution when delegation is unavailable. |
| Guarded write surfaces | No owner-bound guard rules detected | Warnings or hard stops for target-repo edits, manifest updates, version bumps, and agent redistribution | rewrite | blocked | Protected files and action classes are not explicitly guarded yet. |
| Owner command surface | No owner-routing command surface detected | Explicit /delegate, /transplant-upgrade, or equivalent routing commands | rewrite | planned | Explicit routing commands are recommended to reduce owner inference ambiguity. |
| Commands | `.claude/commands/analyze-code.md`, `.claude/commands/analyze-spec.md`, `.claude/commands/analyze.md`, `.claude/commands/feedback.md`, `.claude/commands/graphify.md`, `.claude/commands/ingest.md`, `.claude/commands/lint.md`, `.claude/commands/pair.md`, `.claude/commands/query.md` | Codex task docs, slash-command replacements, or wrapper scripts | rewrite | planned | Detected 9 command file(s). |
| Wrapper commands | `.claude/hooks/feedback-prompt.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` | Shell recipes and helper scripts that preserve behavior across runtimes | rewrite | planned | Detected 5 wrapper script(s) with direct Claude references. |
| Launcher parity | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` | Claude and Codex entrypoints with parity or explicit documented substitutes | rewrite | planned | Detected 4 launcher candidate(s): `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`. Only Claude-side launcher candidates were detected. |
| Permission model | `applied-solutions.md`, `CLAUDE.md`, `docs/pending-imports.md`, `README.md` | Codex sandbox and escalation policy documentation | emulate | planned | Approval or permission language was detected in runtime settings or docs. |
| Session handoff | Implicit session memory or ad hoc notes | SESSION-HANDOFF.md or equivalent durable worklog | rewrite | planned | No durable handoff artifact detected yet. |
| Switchback verification | Manual confidence that paused work can resume after runtime switches | Explicit Claude-to-Codex and Codex-to-Claude resume checks | verify | planned | Continuity claims should be proven by workflow evidence, not only file presence. |
| Operating system assumptions | posix, windows | Codex-compatible platform policy or dual-path wrappers | rewrite | planned | Evidence: `.claude/hooks/feedback-prompt.sh`, `applied-solutions.md`, `CLAUDE.md`, `README.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
| Shell assumptions | bash, cmd, powershell | Codex shell usage and script normalization rules | rewrite | planned | Evidence: `.claude/hooks/feedback-prompt.sh`, `applied-solutions.md`, `CLAUDE.md`, `README.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` |
