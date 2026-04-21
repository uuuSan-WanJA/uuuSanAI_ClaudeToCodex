# Architecture

## Intent

The repository exists to change real target projects.

Input:
- a project authored around Claude Code

Output:
- the same project modified so it can also run under Codex

Success is not "we documented the gap".
Success is "the target project was edited and the edited result verified".

## Primary Pipeline

### 1. Scanner

Read the target project's Claude-oriented operating surfaces:

- `CLAUDE.md`
- existing repo-root Codex guide such as `AGENTS.md`
- `.claude/settings*.json`
- hooks
- agents
- skills
- binding owner-routing guidance when roles or named owners exist
- routing command surfaces and guarded-write rules when present
- wrapper scripts
- runtime launchers and handoff notes when present
- runtime assumptions

The scanner produces a durable report, not just notes in a session.

### 2. Transformer

Turn scan findings into concrete project edits:

- direct mappings
- Codex-side replacements
- compatibility shims
- dual-runtime safe rewrites
- binding owner-routing docs when the target project uses mandatory owners
- session-switch continuity artifacts when required

The transformer must answer two questions for every change:

- what file must change
- why that change does not break the Claude-side behavior

Before touching any owner-bound surface, the transformer must also answer:

- what `task_kind` this work belongs to
- which owner is designated
- whether the work will be delegated or performed locally
- why that routing is valid

### 3. Verifier

Run proof-oriented checks after edits:

- Claude-side workflow still valid
- Codex-side workflow now valid
- representative tasks still behave the same way
- cross-session switchback path is still understandable when the project expects alternating runtimes

### 4. Reporting

Every run should be able to leave behind:

- a source scan report
- a patch plan
- a verification report
- a durable session handoff note when switchback-safe collaboration is part of the target state

## Supporting Layers

### Adapters

`adapters/` are helper contracts for the pipeline. They are not the center of the system. Their job is to make scanner and transformer logic explicit.

### Preflight

`preflight/` blocks dishonest portability claims. If a required runtime surface is still unknown or unsupported, the project is not ready.

### Registries

`problems/`, `frameworks/`, and `components/` stay minimal and should only describe recurring conversion mechanisms.

### Imported Support Components

Some high-value operational patterns are transplanted from HarnessMaker and adapted here:

- `execution-packet` for narrow delegated handoff
- `subagent-reporting-protocol` for structured delegated output
- `three-tier-blocking` for action risk gating
- `policy-optionality-convention` for configurable conversion policy
- `dynamic-orchestration` for large read and verification workloads
- `multi-project-rollout` for coordinated batch conversion across many repositories

This repository also defines a repo-local `owner-routing-contract` component so descriptive role docs do not get mistaken for execution authority.

## Design Rules

### Conversion-first

If a document does not help scanning, patching, or verification, it is secondary.

### Dual-runtime preservation

The system should not "port to Codex" by breaking the original Claude path. The target state is Claude-plus-Codex unless the user asks for a full runtime replacement.

### Session continuity

If a project is meant to alternate between Claude Code and Codex across sessions, the conversion should leave behind enough durable guidance and state for the next runtime to resume work without guesswork.

### Binding ownership

Role descriptions are not enough when a repository assigns mandatory maintainers to specific task kinds.

- runtime roles and maintenance owners must be documented separately when they differ
- if a task kind has a mandatory owner, the main agent must not start direct edits until routing is resolved
- local fallback is exceptional and requires explicit user approval when delegation is unavailable

### Durable evidence

The repository should prefer explicit artifacts over session memory:

- scan report
- compatibility matrix
- patch plan
- verification report

### Conservative success criteria

Compatibility is only real after representative verification passes.
