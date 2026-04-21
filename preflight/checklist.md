# Preflight Checklist

Mandatory checks before claiming a target Claude Code project is ready for Codex compatibility work or has been successfully converted.

| check | why it matters | expected evidence | status |
|-------|----------------|-------------------|--------|
| Source project scanned | Missing one operating surface corrupts every later step. | Source scan report. | planned |
| Compatibility matrix drafted | Conversion work needs an explicit gap map. | `compatibility-matrix.md` rows for the target. | planned |
| Root runtime guides mapped | Session switching breaks down when only one runtime has an obvious repo-root guide. | Scan report plus compatibility matrix row for `CLAUDE.md`, `AGENTS.md`, or project-policy equivalents. | planned |
| Source subagent structure preserved | Conversions that flatten the original Claude subagent topology will drift from the source operating model. | Compatibility matrix row showing how `.claude/agents/*`, role docs, and owner boundaries are preserved or explicitly replaced. | planned |
| Runtime contract installation gate passed | Projects that depend on owner routing or preserved subagent structure are incomplete until the binding runtime contract is actually installed. | Root-guide evidence plus compatibility matrix or verification note showing the contract was installed or the work remains blocked. | planned |
| Role vs owner distinction mapped | Descriptive role docs are unsafe when the project also has mandatory maintainers. | Scan report notes or compatibility matrix row that separates runtime roles from task owners. | planned |
| Mandatory owner routing documented | Owner-bound work cannot be left to main-agent intuition. | Root-guide or policy evidence for `task_kind`, `designated_owner`, `delegate_or_local`, and `why`. | planned |
| Project-scoped Codex config installed or planned | Repo docs alone may not override Codex's main-agent default strongly enough for owner-bound work. | `.codex/config.toml` or equivalent local Codex config using `developer_instructions` to reinforce delegation-first routing and structure preservation. | planned |
| Hook dependence assessed | Hooks are a common Claude-specific portability risk. | Hook rows marked direct, rewrite, emulate, or blocked. | planned |
| Workflow parity scope mapped | Commands, hooks, wrappers, and launcher flows can still break day-to-day use even after root contracts exist. | Compatibility matrix rows or patch-plan notes for commands, hooks, wrapper scripts, and launcher behavior that matter operationally. | planned |
| Patchable files identified | The transformer needs concrete file targets. | Scan report plus patch plan candidates. | planned |
| Claude-safe strategy defined | Codex support must not silently break Claude behavior. | Patch items with Claude-side safety notes. | planned |
| Codex capability fit assessed | Some projects require features Codex may not expose directly. | Capability notes in compatibility matrix. | planned |
| Permission and escalation differences documented | Approval and sandbox mismatches can invalidate otherwise correct runtime guidance. | Scan report plus compatibility matrix row for permission model and required escalation behavior. | planned |
| Delegation fallback defined | Mandatory owners are ineffective if blocked delegation silently turns into local execution. | Root-guide or policy evidence that delegation approval is requested first and explicit local override is only the secondary fallback. | planned |
| Guarded write surfaces defined | Owner-bound files need visible stops before the main agent touches them. | Guard list covering external target repos, manifests, version bumps, or equivalent protected surfaces. | planned |
| Launcher parity or substitute documented | Operators need a clear way to enter both runtimes or a documented equivalent path. | Scan report plus compatibility matrix row for launcher parity or documented substitutes. | planned |
| Session handoff strategy defined | Cross-session runtime switching loses momentum without a durable handoff artifact. | `SESSION-HANDOFF.md` or a named equivalent worklog. | planned |
| Verification workflows chosen | Conversion success must be provable. | Named workflows for Claude-side, Codex-side, and switchback checks. | planned |
| Workflow parity verification chosen | Important runtime-facing workflows must be tested, not only designed. | Verification notes covering command, hook, wrapper, or launcher parity when those surfaces matter. | planned |
| Known blockers recorded | Hidden blockers create false success claims. | Compatibility matrix `blocked` or explicit notes. | planned |

## Passing Rule

Preflight only passes when critical surfaces are no longer unknown, source subagent structure is preserved or explicitly replaced when the project uses named agents, any required runtime contract has actually been installed or the target is honestly marked blocked, mandatory-owner routing is explicit when the project uses named owners, important commands/hooks/wrappers/launchers have explicit parity treatment, the session-switch path is explicit when required, and the project can proceed to transformation or verification honestly.

## Completion Note

This checklist gates readiness, not final compatibility claims. Projects that alternate between Claude Code and Codex still need a verification report with explicit Claude-to-Codex and Codex-to-Claude resume results, or a documented not-applicable decision.
