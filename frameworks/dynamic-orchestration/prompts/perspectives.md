# Dynamic Orchestration Perspectives

Planner reference for choosing dimensions, execution mode, and resource shape in this repository.

## Dimensions

### D1. Runtime Surface Structure

- What operational files define the target project's behavior?
- How are root policy, settings, hooks, agents, and skills arranged?

### D2. Claude-specific Behavior

- Which behaviors are Claude-native rather than repo-native?
- Which assumptions need Codex-side replacement or emulation?

### D3. Context Isolation

- What should stay out of the main agent context?
- Which delegated units need exact file reads?

### D4. Compatibility Risk

- Where is a direct Codex mapping missing?
- Which surfaces are most likely to regress the Claude-side path?

### D5. Verification Coverage

- Which workflows prove the conversion actually works?
- What evidence is still missing?

### D6. Failure Modes

- What can fail silently?
- Which findings should block transformation until clarified?

## Execution Mode Rules

### Single Worker

Use when combined scope is small enough to analyze directly.

### Two-stage

Use when raw scope is large enough that extraction and interpretation should be separated.

## Resource Guidance

- planner: strong synthesis model
- executor: lower-cost extraction-oriented model when possible
- analyzer: synthesis-oriented model

## Cost Rule

Prefer the minimum number of units that preserves evidence quality.
