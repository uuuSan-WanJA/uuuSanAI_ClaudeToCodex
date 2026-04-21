---
solves:
  - codex-compat-patching
  - dual-runtime-preservation
version: "0.1"
status: draft
---

# Codex Compatibility Transformer

## Summary

Convert scan findings into concrete target-project edits that make the project work under Codex while preserving the Claude-side workflow.

This framework absorbs the most relevant structure from HarnessMaker's `solution-transplanter`: phased conversion, rollback discipline, conflict handling, and explicit approval modes.

## Modes

| mode | behavior |
|------|----------|
| `assess-only` | produce or refine the patch plan without editing the target project |
| `apply` | plan, establish rollback safety, and apply approved edits |

## Responsibilities

- select project files to edit
- define the compatibility patch plan
- apply Codex-specific representations
- keep Claude-safe behavior where possible

## Phases

### Phase 0: Patch Assessment

- read the source scan report
- refine the compatibility matrix
- emit or update the patch plan

### Phase 1: Pre-apply Validation

- verify target files still match the scan assumptions
- classify patch items with `components/three-tier-blocking.md`
- check for existing Codex-side artifacts that may conflict

### Phase 2: Rollback Preparation

- if the target project is a git repo, capture a safe pre-transform snapshot
- otherwise, prepare a reversible backup of touched portability files

### Phase 3: Apply Conversion

- patch existing project files
- add compatibility artifacts where needed
- avoid Claude-side regressions by default

### Phase 4: Post-apply Verification Handoff

- hand off required checks to the verifier
- update the verification status in the compatibility matrix

### Phase 5: Manifest And Report Update

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
