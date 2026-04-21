# Claude Operating Guide

This repository treats owner routing as a binding contract, not as descriptive commentary.
Named roles are not execution authority unless a task kind is explicitly assigned to them.

See also:

- `components/owner-routing-contract.md`
- `AGENTS.md`

## Preflight Routing

Before editing portability files or target-project files, record:

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

If a mandatory owner exists, do not start direct edits until routing is resolved.
Claude-side agent prompts or slash commands do not override this rule by themselves.

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

## 세션 종료 시 (인사이트 수집)

작업 중 발견한 Claude vs Codex 동작 차이, 변환 패턴, 설계 결정을 Vault에 stash한다.

```bash
python scripts/stash_to_vault.py \
  --title "발견 제목" \
  --why "왜 잃기 아까운가 (한 줄)" \
  [--body "인라인 본문" | --file path/to/body.md]
```

- 도메인 `ai-systems`, visibility `portfolio` 자동 적용
- stash 대상: 런타임 기본값 차이, 변환 갭, 소유자 라우팅 엣지케이스, 검증 결과
- 0건도 명시적으로 보고("이번 세션 stash 없음")

---

## Fallback Rule

If the current runtime cannot delegate a mandatory-owner task:

1. stop before editing
2. request delegation approval or explicit local override
3. if a local override is approved, keep scope narrow and record it in `SESSION-HANDOFF.md` or a verification report

Do not silently continue locally.

## Command Surface

Use explicit routing phrases instead of relying on inference:

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`

If slash commands are unavailable, use the same phrases verbatim in the user request or handoff note.

## Guarded Writes

Warn and stop before the main agent directly edits:

- external target repositories
- `applied-solutions.md`
- framework version bumps or registry version pin changes
- transplanted `.claude/agents/**` redistribution

Use this message shape:

`This change is owned by solution-transplanter. Delegation or explicit local override is required.`
