# Codex Adapter

## Role

Represent how a Claude-side runtime surface is satisfied in Codex after conversion.

## Target Surfaces To Produce Or Compare

- instruction layers
- repo-local compatibility files
- shell and sandbox model
- escalation and approval behavior
- delegation behavior
- progress reporting conventions
- verification flow

## Mapping Rules

- prefer direct mapping when Codex has a first-class equivalent
- use explicit emulation when behavior matters but there is no one-to-one surface
- mark as `blocked` when the source expectation cannot be represented honestly

## Notes

Codex compatibility is not just prompt translation. It includes permissions, tooling, reporting style, workflow control, and target-project file changes.
