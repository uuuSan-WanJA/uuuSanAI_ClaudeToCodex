---
solves:
  - codex-compat-patching
  - dual-runtime-preservation
  - mandatory-owner-routing
version: "0.1"
status: draft
---

# Codex Compatibility Transformer

## Summary

Convert scan findings into concrete target-project edits that make the project work under Codex while preserving the Claude-side workflow and, when required, a clean session switchback path.

This framework absorbs the most relevant structure from HarnessMaker's `solution-transplanter`: phased conversion, rollback discipline, conflict handling, and explicit approval modes.

Batch conversion across many repositories should be coordinated by `frameworks/multi-project-rollout/definition.md`. This framework remains the single-target apply unit.

## Modes

| mode | behavior |
|------|----------|
| `assess-only` | produce or refine the patch plan without editing the target project |
| `apply` | plan, establish rollback safety, and apply approved edits |

## Responsibilities

- select project files to edit
- classify task kind and designated owner before editing
- define the compatibility patch plan
- apply Codex-specific representations
- keep Claude-safe behavior where possible
- preserve source Claude subagent structure and owner boundaries when the target project already declares them
- preserve or install binding owner-routing docs when the target project uses named owners
- install project-scoped Codex config such as `.codex/config.toml` with `developer_instructions` when delegation-first routing or preserved owner boundaries matter
- treat runtime-contract installation as a completion gate when the target project depends on named owners or preserved subagent structure
- establish runtime-guide, launcher, and handoff continuity when the target project needs session switching
- treat command, hook, and wrapper parity as workflow-safety surfaces rather than optional cleanup
- do not claim completion while runtime-facing workflows remain only partially analyzed or unverified

## Phases

### Phase 0: Task Routing

- classify the requested work as a stable `task_kind`
- resolve `designated_owner`
- decide `delegate_or_local`
- record `why`
- if a mandatory owner exists and delegation cannot run, stop for delegation approval first; only ask for explicit local fallback approval after delegation remains unavailable or the user declines it

### Phase 1: Patch Assessment

- read the source scan report
- refine the compatibility matrix
- emit or update the patch plan
- decide whether session-switch continuity artifacts are required
- decide whether commands, hooks, wrapper scripts, or launcher flows require explicit Codex parity artifacts
- separate `blocking parity` from `workflow parity`, but keep both in scope for the same completion claim

### Phase 2: Pre-apply Validation

- verify target files still match the scan assumptions
- classify patch items with `components/three-tier-blocking.md`
- check for existing Codex-side artifacts that may conflict
- verify whether role docs are merely descriptive or backed by a binding owner contract
- verify whether the source subagent structure must be preserved rather than rewritten into main-agent local work

### Phase 3: Rollback Preparation

- if the target project is a git repo, capture a safe pre-transform snapshot
- otherwise, prepare a reversible backup of touched portability files

### Phase 4: Apply Conversion

- patch existing project files
- add compatibility artifacts where needed
- add `.codex/config.toml` or equivalent project-scoped Codex config when the converted runtime needs reinforcement above repo docs
- preserve or recreate the source Claude subagent structure in Codex-facing docs and workflows when applicable
- add or update owner-routing docs, fallback language, and guarded-surface rules where needed
- add continuity artifacts where needed
- patch or explicitly emulate runtime-facing commands, hooks, wrapper scripts, and launcher semantics when they matter to day-to-day operation
- avoid Claude-side regressions by default
- leave the target in `blocked` or incomplete status if the required runtime contract could not be installed
- leave the target in `blocked` or incomplete status if workflow parity for required commands, hooks, or wrappers is still only partial

### Phase 5: Post-apply Verification Handoff

- hand off required checks to the verifier
- update the verification status in the compatibility matrix
- include switchback checks when alternating runtimes is part of the target workflow
- record any local-fallback override for mandatory-owner work
- confirm that any required runtime contract was actually installed before claiming completion
- verify the patched project still supports the important runtime-facing workflows it exposed before conversion
- do not treat root-guide continuity alone as enough when hooks, commands, or wrapper scripts remain behaviorally important

### Phase 6: Manifest And Report Update

- update durable reports
- record adopted conversion artifacts when appropriate

## Output

- patch plan
- actual project edits
- updated compatibility matrix

## Conflict Handling

| situation | default action |
|-----------|----------------|
| existing Codex artifact already matches | skip and record |
| existing Codex artifact conflicts but is clearly older or incomplete | ask before overwrite |
| task kind has a mandatory owner but the current agent is not it | do not edit; delegate or ask for explicit local fallback approval |
| proposed conversion would flatten an existing Claude subagent structure into main-agent local execution | stop and ask for explicit override |
| required runtime-contract installation could not be completed | stop and leave the target marked incomplete or blocked |
| required command, hook, or wrapper parity is still only sketched but not applied or verified | stop and leave the target marked incomplete or blocked |
| proposed edit would likely break the Claude-side path | stop and escalate |
| rollback path could not be established for risky edits | stop and do not apply |

## Rollback Rule

Any patch item above `NON_BLOCKING` requires a reversible path before edits are applied.

## Options

Use `components/policy-optionality-convention.md` for:

- rollback strictness
- conflict policy
- assess-only vs apply default
- scan-to-patch confidence threshold

## Rules

- prefer local project modifications over external instructions-only fixes
- preserve Claude behavior by default
- record why each edit is needed and how it is verified
- risky actions must pass `components/three-tier-blocking.md`
- treat role docs as descriptive unless a binding owner contract says otherwise
- mandatory-owner work defaults to delegation
- if delegation is unavailable, ask for approval instead of silently continuing locally
- if the source project declares subagent ownership boundaries, preserve them by default in the converted Codex workflow
- if the target needs a binding runtime contract for those boundaries, installing it is part of completion, not a follow-up suggestion
- if the target relies on mandatory owners or preserved subagent structure, install project-scoped Codex config that reinforces delegation-first behavior instead of relying only on repo docs or operator memory
- if session switching is in scope, leave behind a durable handoff path rather than relying on session memory
- if the target exposes commands, hooks, wrapper scripts, or launcher flows that operators actually use, analyze and verify those workflows before claiming Codex attachment is complete
- do not split `blocking parity` and `workflow parity` into separate success claims unless the user explicitly asked for a staged rollout
