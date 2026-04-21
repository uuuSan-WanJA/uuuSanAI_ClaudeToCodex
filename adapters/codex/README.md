# Codex Adapter

## Role

Represent how a Claude-side runtime surface is satisfied in Codex after conversion.

## Target Surfaces To Produce Or Compare

- instruction layers
- repo-root Codex guide such as `AGENTS.md`
- project-scoped Codex config such as `.codex/config.toml`
- repo-local compatibility files
- shell and sandbox model
- escalation and approval behavior
- delegation behavior
- launcher or entrypoint parity, including a startup prompt that front-loads explicit delegation approval for owner-bound work
- durable session handoff artifact
- progress reporting conventions
- verification flow

## Mapping Rules

- prefer direct mapping when Codex has a first-class equivalent
- use explicit emulation when behavior matters but there is no one-to-one surface
- mark as `blocked` when the source expectation cannot be represented honestly

## Notes

Codex compatibility is not just prompt translation. It includes permissions, tooling, reporting style, workflow control, and target-project file changes.
When mandatory owners or preserved subagent structures matter, the adapter should prefer a project-scoped `developer_instructions` layer in `.codex/config.toml` instead of relying only on repo docs or operator memory.
For CLI entrypoints, pair that config layer with `RunCodex*.bat` launchers that inject a short delegation-first startup prompt so the first turn already carries explicit owner approval language.
