# Adapters

Adapters translate between runtime-specific surfaces and the conversion pipeline.

- `adapters/claude/`: source-runtime discovery contract
- `adapters/codex/`: target-runtime representation contract

These directories are support layers for scanner and transformer logic. They should stay small and concrete.
