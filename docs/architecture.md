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
- `.claude/settings*.json`
- hooks
- agents
- skills
- wrapper scripts
- runtime assumptions

The scanner produces a durable report, not just notes in a session.

### 2. Transformer

Turn scan findings into concrete project edits:

- direct mappings
- Codex-side replacements
- compatibility shims
- dual-runtime safe rewrites

The transformer must answer two questions for every change:

- what file must change
- why that change does not break the Claude-side behavior

### 3. Verifier

Run proof-oriented checks after edits:

- Claude-side workflow still valid
- Codex-side workflow now valid
- representative tasks still behave the same way

### 4. Reporting

Every run should be able to leave behind:

- a source scan report
- a patch plan
- a verification report

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

## Design Rules

### Conversion-first

If a document does not help scanning, patching, or verification, it is secondary.

### Dual-runtime preservation

The system should not "port to Codex" by breaking the original Claude path. The target state is Claude-plus-Codex unless the user asks for a full runtime replacement.

### Durable evidence

The repository should prefer explicit artifacts over session memory:

- scan report
- compatibility matrix
- patch plan
- verification report

### Conservative success criteria

Compatibility is only real after representative verification passes.
