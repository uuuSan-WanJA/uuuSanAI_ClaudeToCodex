# Reports

Durable artifacts produced by the conversion pipeline should accumulate here.

## Expected Report Types

- source scan reports
- patch plans
- verification reports
- batch rollout closeout summaries that index per-project evidence when `frameworks/multi-project-rollout` is in use

The repository should prefer report files over undocumented session-only conclusions.
If a project also uses a session handoff note, that note should reference the durable reports instead of duplicating them.
If a mandatory-owner task needed local fallback, the verification report or handoff note should record that override explicitly.

## Batch Rollout Guidance

When `frameworks/multi-project-rollout` is in use:

- keep scan, patch, and verification evidence isolated per target project
- use any batch-level closeout summary as an index to per-project reports, not as a substitute for them
- carry unresolved exceptions forward explicitly instead of collapsing them into a generic rollout status

## Freshness And Selection

- for the same target, prefer the newest report by `generated_at` or the intentionally maintained current report stem
- older reports may remain as historical evidence, but should be treated as superseded once a newer equivalent exists
- session handoff notes should link to the current report set rather than a stale report stem
