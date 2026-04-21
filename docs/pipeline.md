# Conversion Pipeline

## Purpose

The repository should operate like a conversion engine for target projects.

## Routing Gate

Before the main agent edits portability files or target-project code, it must record:

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

If a mandatory owner exists for the task kind, the main agent may not begin direct edits until routing is resolved.
If delegation is unavailable under the current runtime policy, the workflow must stop for delegation approval first and only fall back to explicit local override after delegation remains unavailable or is declined.

## Stages

### 1. Scan

Input:
- target project path

Output:
- source scan report
- first-pass compatibility matrix

Large scans may use `frameworks/dynamic-orchestration/definition.md`.
Multi-repository scan waves may use `frameworks/multi-project-rollout/definition.md`.

### 2. Plan

Input:
- scan report
- compatibility matrix

Output:
- patch plan
- routing decision for any owner-bound work
- workflow-parity scope for commands, hooks, wrappers, and launcher behavior
- project-scoped Codex config decision for `.codex/config.toml` or an equivalent local `developer_instructions` layer

### 3. Transform

Input:
- patch plan

Output:
- target-project file edits
- owner-routing contract or root-guide updates when the target project needs binding ownership
- `.codex/config.toml` or equivalent project-scoped Codex config when the runtime needs delegation-first reinforcement above repo docs
- command, hook, wrapper, and launcher parity artifacts when those workflows matter to operators

Multi-repository transform waves may use `frameworks/multi-project-rollout/definition.md`.
The rollout wrapper should keep one active writer per repository root.

### 4. Verify

Input:
- edited target project

Output:
- verification report
- workflow-parity verdict for runtime-facing commands, hooks, wrappers, and launcher flows when applicable

Large verification runs may use `frameworks/dynamic-orchestration/definition.md`.
Multi-repository verification waves may use `frameworks/multi-project-rollout/definition.md`.

## Batch Execution Overlay

`frameworks/multi-project-rollout/definition.md` wraps the single-project pipeline when the same conversion standard must be applied across many repositories.

Batch execution adds:

- batch intake and rollout policy defaults
- central baseline review between scan and transform waves
- per-project exception tracking through transform and verification
- rollout closeout that preserves per-project verdicts and handoff context
- an optional batch summary index in `reports/` that points to per-project evidence

## Success Standard

A project is only considered converted when:

1. the required edits were applied
2. the Claude-side path is still acceptable
3. the Codex-side path is now acceptable
4. switchback expectations are documented when the project will alternate between runtimes
5. switchback resume results are verified or explicitly marked not applicable when runtime alternation is in scope
6. mandatory-owner work was routed according to the owner contract, or an explicit local fallback approval was recorded
7. project-scoped Codex config was installed when mandatory owners or preserved subagent structure needed runtime reinforcement above repo docs
8. important commands, hooks, wrappers, and launcher flows were analyzed and either preserved, explicitly emulated, or honestly marked blocked
9. evidence is recorded in a verification report
