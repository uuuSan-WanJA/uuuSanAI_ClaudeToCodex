# Claude Adapter

## Role

Treat Claude Code oriented projects as the source side of a conversion run.

## Source Surfaces To Scan

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/settings.local.json`
- `.claude/hooks/*`
- `.claude/agents/*.md`
- `.claude/skills/**/SKILL.md`
- `.claude/commands/*.md`
- project wrapper scripts

## Adapter Output

- source scan findings
- compatibility matrix rows
- list of surfaces that require Codex-side handling

## Notes

This adapter should describe what exists, not how Codex should fix it. Fix strategy belongs to the transformer.
