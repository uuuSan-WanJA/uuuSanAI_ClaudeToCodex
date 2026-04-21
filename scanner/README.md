# Scanner

Scanner logic is responsible for reading a target Claude Code project and producing a structured report of portability-relevant facts.

## Entry Point

- `scripts/scan-claude-project.ps1`
  - scans `CLAUDE.md`, `.claude/settings*.json`, hooks, agents, skills, commands, wrapper scripts, runtime-facing docs, and continuity surfaces such as `AGENTS.md`, launcher scripts, and handoff notes
  - writes durable artifacts to `reports/`

## Expected Output

- source scan report
- initial compatibility matrix rows
- continuity findings that can drive switchback-safe conversion work

Current report filenames:

- `<report-stem>-source-scan-report.md`
- `<report-stem>-compatibility-matrix.md`

## Non-goals

- patching the target project
- verifying behavior
