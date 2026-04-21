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
| Root policy file | `CLAUDE.md` style root operating guide | Repo policy docs plus Codex instruction layers | rewrite | planned | Codex has no identical file contract. |
| Local runtime settings | `.claude/settings.json` | Repo-local Codex-compatible execution docs or config | rewrite | planned | Target project may need new local artifacts. |
| Hooks | `.claude/hooks/*` | scripts plus verification gates | emulate | planned | No one-to-one hook file surface assumed. |
| Agents | `.claude/agents/*.md` | Codex delegation patterns and role prompts | emulate | planned | May require project-local prompt rewrites. |
| Skills | `.claude/skills/**/SKILL.md` | Codex skills or repo-native task docs | direct-or-emulate | planned | Depends on target project shape. |
| Wrapper commands | batch files and slash-command habits | shell recipes and runner scripts | rewrite | planned | Behavior matters more than command names. |
| Permission model | Claude approval and hook denial flow | Codex sandbox and escalation flow | direct-or-emulate | planned | Must be checked per target project. |
| Progress reporting | Claude-oriented progress messages | Codex commentary and final channels | direct | planned | Behavior can map directly with policy rules. |
| Dual-runtime preservation | Claude-first project behavior | Claude-plus-Codex behavior after patch | verify | planned | Conversion must not silently break Claude-side use. |
| Verification workflows | ad hoc human confidence | explicit scan, patch, and verification reports | rewrite | planned | This repo should force evidence-based success. |
