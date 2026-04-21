---
solves:
  - mandatory-owner-routing
version: "1.0"
status: active
---

# Owner Routing Contract

## Summary

Binding repo-local contract that separates descriptive roles from mandatory task owners.
Use it when a project names agents, roles, or slash commands and some task kinds must route through a specific owner.
When a source Claude project already has a declared subagent structure, the converted Codex-side workflow must preserve that owner topology by default instead of flattening it into the main agent.

## Required Sections

### Owner Classes

- runtime roles used for analysis, review, or coordination
- maintenance owners used for framework upgrades, transplants, manifests, or other write-bearing work
- an explicit statement when a runtime role is not a maintenance owner

### Task Routing Table

Minimum columns:

| column | purpose |
|--------|---------|
| `task_kind` | Stable task classification. |
| `mandatory_owner` | Owner required for that task kind, or explicit `none`. |
| `default_execution` | Usually `delegate`, `local`, or `delegate-preferred`. |
| `local_fallback` | Conditions under which local execution is allowed. |
| `guarded_surfaces` | Files, directories, or action classes that must warn or stop. |
| `notes` | Clarifications and exceptions. |

### Routing Preflight

Before edits begin, the main agent must record:

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

### Structure Preservation

If the source project already declares named agents, slash-command owners, or other subagent boundaries:

- read the source agent and role surfaces before planning Codex-side edits
- preserve the same owner boundaries by default in Codex-facing docs and workflows
- treat main-agent flattening as a contract change that requires explicit approval

### Fallback Rule

If a mandatory owner exists but delegation cannot run under the current runtime policy:

1. stop before editing
2. request delegation approval first, preferably via an explicit owner surface such as `/delegate solution-transplanter <task>`
3. only if delegation remains unavailable or the user declines it, request explicit local override
4. record the decision in durable artifacts such as a verification report or session handoff note

The first fallback prompt must not be phrased as a main-agent local-override request when delegation approval has not been asked yet.

### Project-scoped Codex config

If the project will run under Codex CLI and depends on mandatory owners or preserved subagent structure:

- install `.codex/config.toml` or an equivalent local Codex config layer
- prefer `developer_instructions` rather than `model_instructions_file`
- use that config layer to reinforce delegation-first routing and the no-flattening rule above repo docs

### Completion Gate

If a solution, transplant, or Codex conversion depends on named agents, owner-bound writes, guarded surfaces, or explicit task routing:

- the target repo must receive a binding runtime contract in repo-root guides or equivalent policy docs
- the converted workflow must preserve the relevant source subagent structure unless an explicit replacement decision is recorded
- until those artifacts are installed, the work stays `blocked` or incomplete rather than being called done

### Command Surface

If the project uses explicit task commands, map them to the routing table.
Examples:

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`
- natural-language equivalents such as `solution-transplanter로 진행`, `서브에이전트로 처리`, `바로 위임해` count as explicit delegation approval for the named owner

## Binding Rules

- Role definitions are descriptive unless the routing table marks a task kind as owner-bound.
- If a task kind has a mandatory owner, the main agent must not start direct edits until routing preflight is complete.
- Runtime analysis roles and maintenance owners must stay distinct when their scopes differ.
- Converted Codex-side docs should preserve source subagent structure and owner boundaries unless an explicit replacement decision is recorded.
- Work that depends on owner routing or source subagent preservation is not complete until the binding runtime contract is installed in the target repo.
- Guarded surfaces should warn or stop before the main agent edits owner-bound files locally.

## Example Interpretation

| task_kind | mandatory_owner | meaning |
|-----------|-----------------|---------|
| `framework-upgrade` | `solution-transplanter` | Framework version bump, re-transplant, and compatibility re-application work belongs to the transplanter owner. |
| `target-repo-transplant` | `solution-transplanter` | External target repository edits should not be absorbed by the main agent by default. |
| `applied-solutions-update` | `solution-transplanter` | Manifest and adoption records belong to the maintenance owner, not to analysis roles. |
| `saturation-domain-analysis` | `saturation-*` | Saturation roles own analysis runtime tasks only; they do not inherit upgrade or transplant authority. |

## Anti-Pattern

- Do not treat `.claude/agents/**` as descriptive source material only and then collapse the converted Codex flow into main-agent local execution.
