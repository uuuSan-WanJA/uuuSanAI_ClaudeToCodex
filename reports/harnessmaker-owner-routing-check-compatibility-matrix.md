---
kind: compatibility-matrix
format_version: "1.0"
status: draft
last_updated: "2026-04-21"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_HarnessMaker"
report_stem: "harnessmaker-owner-routing-check"
---

# Compatibility Matrix

| axis | source_runtime | target_runtime | normalization_strategy | status | notes |
| --- | --- | --- | --- | --- | --- |
| Root policy file | `CLAUDE.md` | AGENTS.md or equivalent Codex-facing repo guide | rewrite | planned | Detected root operating guide at CLAUDE.md. Existing Codex guide(s): `AGENTS.md`. |
| Local runtime settings | `.claude/settings.json` | Codex-compatible execution and approval config or docs | rewrite | planned | Detected 1 settings file(s): `.claude/settings.json` |
| Hooks | `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh` | Scripts plus verification gates that emulate hook behavior | emulate | planned | Detected 5 hook file(s). |
| Agents | `.claude/agents/solution-transplanter.md` | Codex delegation prompts or task-role docs | emulate | planned | Detected 1 agent prompt file(s). Agent mirroring alone is not enough when ownership is mandatory. |
| Subagent architecture preservation | `AGENTS.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` | Codex-facing docs and workflows that preserve the source Claude subagent structure and owner boundaries | rewrite | planned | Detected structure-preservation language in `AGENTS.md`, `CLAUDE.md`, `SESSION-HANDOFF.md`. |
| Owner routing contract | `AGENTS.md`, `applications-matrix.md`, `applied-projects.md`, `applied-solutions.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` | Root runtime guides or policy docs that bind task kinds to mandatory owners | rewrite | planned | Detected binding owner-routing language in `AGENTS.md`, `applications-matrix.md`, `applied-projects.md`, `applied-solutions.md`, `CLAUDE.md`, `SESSION-HANDOFF.md`. |
| Routing preflight | `AGENTS.md`, `applications-matrix.md`, `applied-projects.md`, `applied-solutions.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` | Explicit `task_kind`, `designated_owner`, `delegate_or_local`, and `why` gate before edits | rewrite | planned | Owner-routing guidance appears to define preflight routing fields. |
| Delegation fallback | `AGENTS.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` | Delegation approval request or explicit local override before owner-bound local edits | rewrite | planned | Delegation fallback language was detected in `AGENTS.md`, `CLAUDE.md`, `SESSION-HANDOFF.md`. |
| Guarded write surfaces | `AGENTS.md`, `CLAUDE.md` | Warnings or hard stops for target-repo edits, manifest updates, version bumps, and agent redistribution | rewrite | planned | Guard language was detected in `AGENTS.md`, `CLAUDE.md`. |
| Owner command surface | `AGENTS.md`, `CLAUDE.md` | Explicit /delegate, /transplant-upgrade, or equivalent routing commands | rewrite | planned | Explicit routing command cues were detected in `AGENTS.md`, `CLAUDE.md`. |
| Wrapper commands | `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` | Shell recipes and helper scripts that preserve behavior across runtimes | rewrite | planned | Detected 9 wrapper script(s) with direct Claude references. |
| Launcher parity | `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat` | Claude and Codex entrypoints with parity or explicit documented substitutes | rewrite | planned | Detected 4 launcher candidate(s): `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`. Only Claude-side launcher candidates were detected. |
| Permission model | `.claude/settings.json`, `applied-projects.md`, `CLAUDE.md`, `SESSION-HANDOFF.md` | Codex sandbox and escalation policy documentation | emulate | planned | Approval or permission language was detected in runtime settings or docs. |
| Session handoff | `SESSION-HANDOFF.md` | SESSION-HANDOFF.md or equivalent durable worklog | rewrite | planned | Existing handoff artifact(s): `SESSION-HANDOFF.md`. |
| Switchback verification | Manual confidence that paused work can resume after runtime switches | Explicit Claude-to-Codex and Codex-to-Claude resume checks | verify | planned | Continuity claims should be proven by workflow evidence, not only file presence. |
| Operating system assumptions | posix, windows | Codex-compatible platform policy or dual-path wrappers | rewrite | planned | Evidence: `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `applications-matrix.md`, `applied-projects.md`, `CLAUDE.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |
| Shell assumptions | bash, cmd, powershell | Codex shell usage and script normalization rules | rewrite | planned | Evidence: `.claude/hooks/guard-read-path.sh`, `.claude/hooks/problems-post-edit.sh`, `.claude/hooks/problems-session-start.sh`, `.claude/hooks/solutions-post-edit.sh`, `.claude/hooks/solutions-session-start.sh`, `applications-matrix.md`, `applied-projects.md`, `CLAUDE.md`, `RunClaude.bat`, `RunClaude_Opus_No1M.bat`, `RunClaude_Opus_xhigh.bat`, `RunClaude_Sonnet.bat`, `scripts/rescan-applications.sh` |
