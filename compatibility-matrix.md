---
kind: compatibility-matrix
format_version: "1.0"
status: draft
last_updated: "2026-04-21"
---

# Compatibility Matrix

Initial conversion map for this repository's own design model.

| axis | source_runtime | target_runtime | normalization_strategy | status | notes |
|------|----------------|----------------|------------------------|--------|-------|
| Root policy file | `CLAUDE.md` style root operating guide | `AGENTS.md` or equivalent Codex-facing repo guide plus cross-references | rewrite | planned | Codex has no identical built-in file contract, so repo-local guidance must be explicit. |
| Local runtime settings | `.claude/settings.json` | `.codex/config.toml` plus any required Codex-compatible execution docs | rewrite | planned | Target project may need project-scoped `developer_instructions` and other local artifacts. |
| Project-scoped Codex config | owner-routing and structure-preservation requirements that need reinforcement above repo docs | `.codex/config.toml` with `developer_instructions` that enforce delegation-first routing and preserve owner boundaries | rewrite | planned | Project-local Codex config should be installed when mandatory owners or preserved subagent structure matter. |
| Hooks | `.claude/hooks/*` | scripts plus verification gates | emulate | planned | No one-to-one hook file surface assumed. |
| Workflow parity closure | command docs, hook specs, wrapper scripts, and launcher workflows that operators actually use | Codex-side artifacts and verification that preserve those workflows end-to-end | rewrite | planned | Root contracts alone are not enough when runtime-facing workflows still drift. |
| Agents | `.claude/agents/*.md` | Codex delegation patterns and role prompts | emulate | planned | May require project-local prompt rewrites. |
| Subagent architecture preservation | source `.claude/agents/*.md`, role docs, and owner boundaries | Codex-facing docs and workflows that preserve the same subagent ownership structure | rewrite | planned | Conversions should not flatten source subagent topology into main-agent local execution without an explicit override. |
| Runtime contract installation gate | source project or transplanted solution depends on named owners, guarded writes, or preserved subagent structure | target remains blocked or incomplete until the binding runtime contract is installed in repo-root guides | rewrite | planned | Installing the runtime contract is part of completion, not a follow-up suggestion. |
| Owner routing contract | descriptive role docs or agent prompts | root guides or policy docs that bind `task_kind` to a mandatory owner | rewrite | planned | Roles are descriptive unless the repo defines binding ownership. |
| Routing preflight | ad hoc main-agent interpretation | explicit `task_kind`, `designated_owner`, `delegate_or_local`, and `why` gate before edits | rewrite | planned | Mandatory-owner work must not start before routing is resolved. |
| Delegation fallback | silent local execution when delegation is unavailable | delegation approval request or explicit local override workflow | rewrite | planned | Local fallback is exceptional and must stay visible. |
| Guarded write surfaces | implicit caution around risky files | warning or stop rules for owner-bound surfaces | rewrite | planned | External target repos, manifests, version bumps, and agent redistribution should be guarded explicitly. |
| Owner command surface | freeform routing inference | `/delegate`, `/transplant-upgrade`, or equivalent explicit commands | rewrite | planned | Command surfaces reduce routing ambiguity but do not replace the binding contract. |
| Skills | `.claude/skills/**/SKILL.md` | Codex skills or repo-native task docs | direct-or-emulate | planned | Depends on target project shape. |
| Wrapper commands | batch files and slash-command habits | shell recipes and runner scripts | rewrite | planned | Behavior matters more than command names. |
| Launcher parity | Claude-side launcher or documented entrypoint | Codex-side launcher or documented entrypoint | rewrite | planned | Session switching is fragile when one runtime has no obvious way in. |
| Permission model | Claude approval and hook denial flow | Codex sandbox and escalation flow | direct-or-emulate | planned | Must be checked per target project. |
| Session handoff | implicit session memory or ad hoc notes | `SESSION-HANDOFF.md` or an equivalent durable worklog | rewrite | planned | Alternating runtimes across sessions needs a repo-local continuity artifact. |
| Progress reporting | Claude-oriented progress messages | Codex commentary and final channels | direct | planned | Behavior can map directly with policy rules. |
| Dual-runtime preservation | Claude-first project behavior | Claude-plus-Codex behavior after patch | verify | planned | Conversion must not silently break Claude-side use. |
| Switchback verification | operator confidence that a paused session can resume elsewhere | explicit Claude-to-Codex and Codex-to-Claude resume checks | verify | planned | Continuity claims require workflow evidence, not only file presence. |
| Verification workflows | ad hoc human confidence | explicit scan, patch, and verification reports | rewrite | planned | This repo should force evidence-based success. |
