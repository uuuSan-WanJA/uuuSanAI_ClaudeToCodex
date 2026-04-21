# Codex Operating Guide

This repository uses a binding owner-routing contract.
Role docs are descriptive unless a task kind is explicitly assigned to a mandatory owner.

See also:

- `components/owner-routing-contract.md`
- `CLAUDE.md`

## Preflight Routing

Before editing portability files or target-project files, record:

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

If a mandatory owner exists, do not start direct edits until routing is resolved.
Codex defaults toward main-agent local execution, so this routing gate overrides that default.

## Owner Classes

- `saturation-*`: domain-analysis runtime roles only
- `solution-transplanter`: maintenance owner for framework upgrade, transplant, and manifest update work

The saturation roles do not own framework maintenance or target-repository rewrite work.

## Structure Preservation

If a source Claude project already declares `.claude/agents/**`, slash-command owners, or other subagent boundaries, preserve that structure by default in the Codex-side workflow.
Do not flatten owner-bound work into main-agent local execution unless an explicit replacement decision is recorded.

## Mandatory Owner Table

| task_kind | mandatory_owner | default_execution | local_fallback | guarded_surfaces |
|-----------|-----------------|-------------------|----------------|------------------|
| `framework-upgrade` | `solution-transplanter` | `delegate` | only after user approval when delegation cannot run | framework version bumps, framework definition rewrites, registry pin changes |
| `target-repo-transplant` | `solution-transplanter` | `delegate` | only after user approval when delegation cannot run | external target repo edits, transplanted `.claude/agents/**`, runtime guide redistribution |
| `applied-solutions-update` | `solution-transplanter` | `delegate` | only after user approval when delegation cannot run | `applied-solutions.md`, related manifest rows, adoption records |
| `saturation-domain-analysis` | `saturation-*` | `local-or-delegate` | local synthesis allowed if no maintenance owner is implicated | analysis notes and evidence only |

## Fallback Rule

If the current Codex runtime policy does not allow delegation or subagent use for a mandatory-owner task:

1. stop before editing
2. request delegation approval first, with an explicit owner surface such as `/delegate solution-transplanter <task>` or `solution-transplanter로 진행`
3. only if delegation remains unavailable or the user declines it, request explicit local override
4. if a local override is approved, keep scope narrow and record it in `SESSION-HANDOFF.md` or a verification report

Do not silently continue locally.
Do not phrase the first fallback question as a main-agent local-override request when delegation approval has not been asked yet.

## Command Surface

Use explicit routing phrases instead of relying on inference:

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`
- natural-language equivalents such as `solution-transplanter로 진행`, `서브에이전트로 처리`, `바로 위임해` count as explicit delegation approval for the named owner

If slash commands are unavailable, use the same phrases verbatim in the user request or handoff note.

## Project-scoped Codex config

- `.codex/config.toml` is a required Codex runtime layer for this repo.
- It should use `developer_instructions`, not `model_instructions_file`, so built-in Codex instructions remain intact while delegation-first owner routing is reinforced.
- Future Codex conversions should install the same project-scoped config layer when mandatory owners, preserved subagent structure, or guarded-write surfaces matter.
- `RunCodex.bat` and `RunCodex_xhigh.bat` should front-load the same delegation-first rule in the startup prompt so the first turn already carries explicit owner approval language.

## Guarded Writes

Warn and stop before the main agent directly edits:

- external target repositories
- `applied-solutions.md`
- framework version bumps or registry version pin changes
- transplanted `.claude/agents/**` redistribution

Use this message shape:

`This change is owned by solution-transplanter. Delegation approval is required first; explicit local override is only the fallback.`
