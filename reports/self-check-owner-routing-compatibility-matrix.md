---
kind: compatibility-matrix
format_version: "1.0"
status: draft
last_updated: "2026-04-21"
project_path: "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_ClaudeToCodex"
report_stem: "self-check-owner-routing"
---

# Compatibility Matrix

| axis | source_runtime | target_runtime | normalization_strategy | status | notes |
| --- | --- | --- | --- | --- | --- |
| Root policy file | `CLAUDE.md` | AGENTS.md or equivalent Codex-facing repo guide | rewrite | planned | Detected root operating guide at CLAUDE.md. Existing Codex guide(s): `AGENTS.md`. |
| Subagent architecture preservation | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `README.md` | Codex-facing docs and workflows that preserve the source Claude subagent structure and owner boundaries | rewrite | planned | Detected structure-preservation language in `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `README.md`. |
| Owner routing contract | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md` | Root runtime guides or policy docs that bind task kinds to mandatory owners | rewrite | planned | Detected binding owner-routing language in `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md`. |
| Routing preflight | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md` | Explicit `task_kind`, `designated_owner`, `delegate_or_local`, and `why` gate before edits | rewrite | planned | Owner-routing guidance appears to define preflight routing fields. |
| Delegation fallback | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md` | Delegation approval request or explicit local override before owner-bound local edits | rewrite | planned | Delegation fallback language was detected in `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `SESSION-HANDOFF.md`, `docs/architecture.md`, `docs/pipeline.md`. |
| Guarded write surfaces | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md` | Warnings or hard stops for target-repo edits, manifest updates, version bumps, and agent redistribution | rewrite | planned | Guard language was detected in `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`. |
| Owner command surface | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md` | Explicit /delegate, /transplant-upgrade, or equivalent routing commands | rewrite | planned | Explicit routing command cues were detected in `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`. |
| Wrapper commands | `scripts/patch-harnessmaker-owner-routing.ps1` | Shell recipes and helper scripts that preserve behavior across runtimes | rewrite | planned | Detected 1 wrapper script(s) with direct Claude references. |
| Launcher parity | No runtime launcher or documented substitute detected | Claude and Codex entrypoints with parity or explicit documented substitutes | rewrite | planned | No launcher candidates were detected yet. If runtime switching is expected, document equivalent Claude and Codex entry paths explicitly. |
| Permission model | `AGENTS.md`, `CLAUDE.md`, `compatibility-matrix.md`, `docs/architecture.md`, `docs/pipeline.md`, `SESSION-HANDOFF.md` | Codex sandbox and escalation policy documentation | emulate | planned | Approval or permission language was detected in runtime settings or docs. |
| Session handoff | `SESSION-HANDOFF.md` | SESSION-HANDOFF.md or equivalent durable worklog | rewrite | planned | Existing handoff artifact(s): `SESSION-HANDOFF.md`. |
| Switchback verification | Manual confidence that paused work can resume after runtime switches | Explicit Claude-to-Codex and Codex-to-Claude resume checks | verify | planned | Continuity claims should be proven by workflow evidence, not only file presence. |
| Operating system assumptions | posix, windows | Codex-compatible platform policy or dual-path wrappers | rewrite | planned | Evidence: `AGENTS.md`, `CLAUDE.md`, `scripts/patch-harnessmaker-owner-routing.ps1` |
| Shell assumptions | bash, powershell | Codex shell usage and script normalization rules | rewrite | planned | Evidence: `AGENTS.md`, `CLAUDE.md`, `scripts/patch-harnessmaker-owner-routing.ps1` |
