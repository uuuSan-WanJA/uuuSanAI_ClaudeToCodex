param(
    [string]$TargetRoot = "D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path)
}

function Normalize-Newlines {
    param([string]$Text)
    return $Text -replace "`r`n", "`n"
}

function Write-Text {
    param(
        [string]$Path,
        [string]$Text
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    $normalized = ($Text -replace "`r?`n", "`r`n").TrimEnd("`r", "`n") + "`r`n"
    [System.IO.File]::WriteAllText($Path, $normalized, $encoding)
}

function Replace-Exact {
    param(
        [string]$Text,
        [string]$OldValue,
        [string]$NewValue
    )

    $normalizedText = Normalize-Newlines -Text $Text
    $normalizedOldValue = Normalize-Newlines -Text $OldValue
    $normalizedNewValue = Normalize-Newlines -Text $NewValue

    if ($normalizedText.Contains($normalizedNewValue)) {
        return $normalizedText
    }

    if (-not $normalizedText.Contains($normalizedOldValue)) {
        throw "Expected text not found."
    }

    return $normalizedText.Replace($normalizedOldValue, $normalizedNewValue)
}

function Insert-Before {
    param(
        [string]$Text,
        [string]$Anchor,
        [string]$Insert
    )

    $normalizedText = Normalize-Newlines -Text $Text
    $normalizedAnchor = Normalize-Newlines -Text $Anchor
    $normalizedInsert = Normalize-Newlines -Text $Insert

    if ($normalizedText.Contains($normalizedInsert.Trim())) {
        return $normalizedText
    }

    if (-not $normalizedText.Contains($normalizedAnchor)) {
        throw "Insert anchor not found."
    }

    return $normalizedText.Replace($normalizedAnchor, $normalizedInsert + $normalizedAnchor)
}

function Insert-After {
    param(
        [string]$Text,
        [string]$Anchor,
        [string]$Insert
    )

    $normalizedText = Normalize-Newlines -Text $Text
    $normalizedAnchor = Normalize-Newlines -Text $Anchor
    $normalizedInsert = Normalize-Newlines -Text $Insert

    if ($normalizedText.Contains($normalizedInsert.Trim())) {
        return $normalizedText
    }

    if (-not $normalizedText.Contains($normalizedAnchor)) {
        throw "Insert anchor not found."
    }

    return $normalizedText.Replace($normalizedAnchor, $normalizedAnchor + $normalizedInsert)
}

function Insert-AfterRegexFirst {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Insert
    )

    $normalizedText = Normalize-Newlines -Text $Text
    $normalizedInsert = Normalize-Newlines -Text $Insert

    if ($normalizedText.Contains($normalizedInsert.Trim())) {
        return $normalizedText
    }

    $match = [regex]::Match($normalizedText, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $match.Success) {
        throw "Regex anchor not found."
    }

    $insertAt = $match.Index + $match.Length
    return $normalizedText.Insert($insertAt, "`n`n" + $normalizedInsert)
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

$agentsPath = Join-Path $TargetRoot "AGENTS.md"
$handoffPath = Join-Path $TargetRoot "SESSION-HANDOFF.md"
$claudePath = Join-Path $TargetRoot "CLAUDE.md"
$readmePath = Join-Path $TargetRoot "README.md"
$graphifyIgnorePath = Join-Path $TargetRoot ".graphifyignore"
$codexParityPath = Join-Path $TargetRoot "docs/codex-parity.md"
$pendingImportsPath = Join-Path $TargetRoot "docs/pending-imports.md"
$appliedSolutionsPath = Join-Path $TargetRoot "applied-solutions.md"
$feedbackHookSpecPath = Join-Path $TargetRoot ".claude/hooks/feedback-prompt.md"
$codexFeedbackSignalPath = Join-Path $TargetRoot "scripts/codex-feedback-signal.ps1"
$runCodexPath = Join-Path $TargetRoot "RunCodex.bat"
$runCodexXhighPath = Join-Path $TargetRoot "RunCodex_xhigh.bat"

$agentsContent = @'
# Woore AI Knowledge — Codex Runtime Guide

이 파일은 Codex 진입점이다. 위키 운영 규칙의 authoritative source 는 `CLAUDE.md` 이고, Codex 에서 구조를 무너뜨리지 않게 하는 binding contract 는 이 파일이 맡는다.

## 시작 순서

1. `AGENTS.md`
2. `CLAUDE.md`
3. `SESSION-HANDOFF.md`
4. `wiki/index.md`
5. 사용자 입력 처리

## Graphify-safe layout

- Graphify 는 폴더 구조와 wikilink 경로에 민감하므로 `wiki/`, `raw/`, `docs/`, `graphify-out/`, `config/` 의 top-level 구조를 임의로 옮기거나 새 상위 디렉토리로 감싸지 않는다.
- 새 런타임 운영 파일은 루트에만 둔다. Graphify 대상이 아니므로 `.graphifyignore` 에 유지한다.
- `raw/` 는 절대 수정 금지다.

## Binding Owner Routing

- `.claude/agents/saturation-*.md` 는 descriptive role 이 아니라 **analysis runtime owner** 다.
- `saturation-*` 6역은 도메인 분석 런타임 owner 이고, saturation framework 재이식·manifest 갱신 owner 가 아니다.
- saturation framework 업그레이드, `.claude/agents/saturation-*.md` wholesale 교체, `config/saturation-driven.config.yml` 구조 재배치, `applied-solutions.md` pin 변경은 **`solution-transplanter`** 소관으로 본다.
- Codex 메인 에이전트는 named owner 구조를 무시하고 전 축 분석이나 유지보수 작업을 로컬로 평탄화하면 안 된다.

| task_kind | designated_owner | delegate_or_local | fallback | examples |
| --- | --- | --- | --- | --- |
| `full-analysis` | `saturation-completeness-overseer` | `delegate` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `/analyze`, `/analyze-code` default, `/analyze-spec` default |
| `code-analysis` | `saturation-code-analyst` | `delegate-via-overseer` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `--code-only`, code axis drill-down |
| `spec-analysis` | `saturation-spec-analyst` | `delegate-via-overseer` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `--spec-only`, spec corpus drill-down |
| `pairing-verification` | `saturation-cross-verifier` | `delegate-via-overseer` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `/pair`, confidence/state labeling |
| `system-curation` | `saturation-domain-curator` | `delegate-via-overseer` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `wiki/game-design/*`, `wiki/game-implementation/*` curation |
| `concept-curation` | `saturation-concept-curator` | `delegate-via-overseer` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `wiki/game-design/concepts/*` 생성·보강 |
| `framework-upgrade` | `solution-transplanter` | `delegate` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | saturation framework re-transplant, prompt redistribution |
| `applied-solutions-update` | `solution-transplanter` | `delegate` | delegation 이 정책상 불가하면 사용자 승인 후에만 local fallback | `applied-solutions.md`, pin/version history |

## Routing Preflight

owner-bound 작업을 시작하기 전 항상 아래 4가지를 먼저 확정한다.

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

mandatory owner 가 존재하면 메인 에이전트는 직접 편집을 시작할 수 없다.

## Delegation Fallback

- delegation 이 가능하면 owner 에 위임하는 것이 기본이다.
- 현재 런타임 정책상 delegation 이 불가하면 메인 에이전트는 즉시 멈추고 사용자에게 delegation 승인 또는 explicit local override 를 요청해야 한다.
- delegation 불가를 이유로 로컬 직접 수행으로 조용히 수렴하면 안 된다.

## Guarded Write Surfaces

다음 표면은 owner 확인 없이 직접 수정하면 안 된다.

- `.claude/agents/saturation-*.md`
- `.claude/commands/{analyze,analyze-code,analyze-spec,pair}.md`
- `config/saturation-driven.config.yml`
- `applied-solutions.md`
- `CLAUDE.md`, `AGENTS.md`, `SESSION-HANDOFF.md`
- Graphify-sensitive top-level layout (`wiki/`, `raw/`, `docs/`, `graphify-out/`, `config/`)

경고 문구:

`This change is owned by <designated_owner>. Delegation or explicit local override is required.`

## Command Surface

- `/route-check <task summary>`
- `/delegate saturation-completeness-overseer <task>`
- `/delegate saturation-code-analyst <task>`
- `/delegate saturation-spec-analyst <task>`
- `/delegate saturation-cross-verifier <task>`
- `/delegate saturation-domain-curator <task>`
- `/delegate saturation-concept-curator <task>`
- `/delegate solution-transplanter <task>`

Codex 는 실제 slash command 를 실행하지 못해도, 위 커맨드를 **라우팅 의도 표면** 으로 해석해야 한다.

## Command + Hook Parity

- command parity mapping 은 `docs/codex-parity.md` 에 둔다.
- `.claude/commands/*` 의 slash trigger 는 Codex 에서 literal shell command 가 아니라 **workflow label** 이다.
- `/analyze`, `/analyze-code`, `/analyze-spec`, `/pair` 는 owner-bound 분석 요청이다. Codex 는 `saturation-*` 구조를 보존한 채 같은 절차를 수행해야 한다.
- `feedback-prompt` hook 은 Codex 에서 native hook 으로 직접 돌지 않으므로, `docs/codex-parity.md` 와 `scripts/codex-feedback-signal.ps1` 절차로 수동 에뮬레이션한다.
- command, hook, wrapper, launcher parity 가 끝나기 전에는 Codex 연동 완료로 주장하지 않는다.

## Runtime Contract Installation Gate

named owner, preserved subagent structure, guarded write, routing command 중 하나라도 전제하는 변경은 `CLAUDE.md` 와 `AGENTS.md` 에 binding contract 가 반영될 때까지 완료가 아니다.

## Launcher / Switchback

- Claude entrypoints: `RunClaude*.bat`
- Codex entrypoints: `RunCodex*.bat`
- Codex 시작 시 `AGENTS.md` → `CLAUDE.md` → `SESSION-HANDOFF.md` → `wiki/index.md` 순서로 복원한다.
- Claude 또는 Codex 세션을 멈추기 전에 현재 milestone, files in motion, blockers, 다음 액션을 `SESSION-HANDOFF.md` 에 반영한다.
'@

$handoffContent = @'
# SESSION-HANDOFF

## Current State

- active milestone: Codex dual-runtime continuity for `woore-ai-knowledge-fsf2`
- last meaningful change: repo-root `AGENTS.md`, `RunCodex*.bat`, binding owner-routing contract, and Graphify-safe exclusions were installed for Codex operation.
- current focus: keep saturation 6-role analysis topology intact across Claude and Codex sessions.

## Read This First

- Claude start: `CLAUDE.md` → `SESSION-HANDOFF.md` → `wiki/index.md`
- Codex start: `AGENTS.md` → `CLAUDE.md` → `SESSION-HANDOFF.md` → `wiki/index.md`

## Files In Motion

- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `applied-solutions.md`
- `docs/pending-imports.md`
- `.graphifyignore`

## Runtime Notes

- saturation 6역 (`.claude/agents/saturation-*.md`) 은 분석 런타임 owner 다. Codex 메인이 이 구조를 평탄화하면 안 된다.
- saturation framework 재이식, prompt wholesale 교체, config 구조 변경, `applied-solutions.md` pin 변경은 `solution-transplanter` 소관이다.
- Graphify-sensitive layout 이므로 새 운영 자산은 루트에만 두고 `.graphifyignore` 에 유지한다.
- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. delegation 이 불가하면 explicit local override 없이는 owner-bound 변경을 진행하지 않는다.

## Next Action Template

- next action:
- blockers:
- evidence touched:
- switchback verification:
'@

$runCodexContent = @'
call codex.cmd -m gpt-5.4 --full-auto

pause
'@

$runCodexXhighContent = @'
call codex.cmd -m gpt-5.4 -c model_reasoning_effort=xhigh --full-auto

pause
'@

$codexParityContent = @'
# Codex Parity

Codex 연동은 루트 guide 설치만으로 끝나지 않는다. 이 문서는 `.claude/commands/*`, `.claude/hooks/*`, 런처, wrapper workflow 를 Codex 에서 어떻게 같은 의미로 보존하는지 정리한 runtime-facing parity map 이다.

## Workflow Parity Closure

- root contract, owner routing, command parity, hook parity, launcher parity, verification note 가 같이 있어야 Codex 연동 완료다.
- command, hook, wrapper, launcher behavior 가 day-to-day workflow 에 중요하면 분석과 검증 없이 후속 과제로 밀지 않는다.

## Command Parity

| Claude surface | Codex 해석 | designated_owner | parity rule |
| --- | --- | --- | --- |
| `/analyze` | full orchestration workflow label | `saturation-completeness-overseer` | source subagent structure 보존, 전 축 분석을 main local execution 으로 평탄화 금지 |
| `/analyze-code` | default 는 full orchestration, `--code-only` 만 partial | `saturation-completeness-overseer` or `saturation-code-analyst` | `--code-only` 가 아니면 code-only 로 축소 금지 |
| `/analyze-spec` | default 는 full orchestration, `--spec-only` 만 partial | `saturation-completeness-overseer` or `saturation-spec-analyst` | `--spec-only` 가 아니면 spec-only 로 축소 금지 |
| `/pair` | pairing + curation workflow label | `saturation-cross-verifier` | cross-verifier + curator 구조 보존 |
| `/feedback` | 동일한 feedback entry 저장 workflow | `local` | 사용자 동의 없이 자동 저장 금지 |
| `/query` | 동일한 wiki query workflow | `local` | `wiki/index.md` → graph/report → candidate pages → raw 최후수단 순서 유지 |
| `/ingest` | 동일한 ingest workflow | `local` | Gold In 게이트, raw 불변 규약 유지 |
| `/lint` | 동일한 lint workflow | `local` | 자동 수정 가능한 것만 즉시 수정 |
| `/graphify` | 동일한 graphify wrapper workflow | `local` | Graphify-sensitive layout 유지 |

## Hook Parity

### `feedback-prompt`

- Claude 의미: feedback signal 이 보이면 `/feedback` 또는 `feedback/inbox.md` 저장을 제안
- Codex parity: native hook 으로 직접 실행하지 않고, 응답 끝의 짧은 제안으로 의미를 에뮬레이션
- 자동 저장 금지
- helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/codex-feedback-signal.ps1 -PromptText "<user text>"
```

## Launcher Parity

- Claude: `RunClaude*.bat`
- Codex: `RunCodex*.bat`
- Codex 시작 순서: `AGENTS.md` → `CLAUDE.md` → `SESSION-HANDOFF.md` → `wiki/index.md`

## Verification

- analyze/pair 요청 시 main agent 가 source subagent structure 를 평탄화하지 않는지 확인
- feedback signal 에 자동 저장이 아니라 제안만 나가는지 확인
- Graphify-safe top-level layout 이 유지되는지 확인
- runtime 전환 후 `SESSION-HANDOFF.md` 만으로 다음 작업이 복원되는지 확인
'@

$codexFeedbackSignalContent = @'
param(
    [Parameter(Mandatory = $true)]
    [string]$PromptText
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$prompt = $PromptText.ToLowerInvariant()
$result = [ordered]@{
    triggered = $false
    type = $null
    message = $null
}

$keywordSets = @(
    @{ type = "bug"; keywords = @("버그", "이상해", "작동 안", "안 되네", "안돼", "실패", "에러", "오류", "bug", "broken", "not working", "fails", "error") },
    @{ type = "suggestion"; keywords = @("제안", "개선", "아이디어", "하면 좋겠", "하면 좋을", "있으면 좋겠", "suggest", "improve", "would be nice", "should have") },
    @{ type = "question"; keywords = @("왜 이렇게", "헷갈려", "이해 안", "혼란스러", "의아해", "why does this", "confused", "unclear") },
    @{ type = "praise"; keywords = @("좋네", "잘 되네", "깔끔", "유용", "nice", "great", "clean", "useful") }
)

foreach ($entry in $keywordSets) {
    foreach ($keyword in $entry.keywords) {
        if ($prompt.Contains($keyword)) {
            $result.triggered = $true
            $result.type = $entry.type
            $result.message = "feedback signal detected; suggest /feedback or feedback/inbox.md, never auto-save"
            break
        }
    }

    if ($result.triggered) {
        break
    }
}

$result | ConvertTo-Json -Depth 3
'@

Write-Text -Path $agentsPath -Text $agentsContent
Write-Text -Path $handoffPath -Text $handoffContent
Write-Text -Path $codexParityPath -Text $codexParityContent
Write-Text -Path $codexFeedbackSignalPath -Text $codexFeedbackSignalContent
Write-Text -Path $runCodexPath -Text $runCodexContent
Write-Text -Path $runCodexXhighPath -Text $runCodexXhighContent

$graphifyIgnore = Read-Text -Path $graphifyIgnorePath
$graphifyIgnore = Replace-Exact -Text $graphifyIgnore -OldValue @'
# ── 프로젝트 운영 파일
CLAUDE.md
.claude-state/
.gitignore
.graphifyignore
README.md
'@ -NewValue @'
# ── 프로젝트 운영 파일
AGENTS.md
CLAUDE.md
SESSION-HANDOFF.md
RunClaude*.bat
RunCodex*.bat
.claude-state/
.gitignore
.graphifyignore
README.md
'@
Write-Text -Path $graphifyIgnorePath -Text $graphifyIgnore

$readme = Read-Text -Path $readmePath
$readme = Replace-Exact -Text $readme -OldValue @'
2. `CLAUDE.md` 읽기 (위키 운영 스키마)
3. `docs/roles.md` 읽기 (내가 어떤 롤로 쓰는지)
4. `wiki/index.md` 훑어보기 (현재 지식 지형)
'@ -NewValue @'
2. 런타임에 맞는 루트 가이드 읽기
   - Claude Code: `CLAUDE.md`
   - Codex: `AGENTS.md` → `CLAUDE.md`
3. `docs/roles.md` 읽기 (내가 어떤 롤로 쓰는지)
4. `SESSION-HANDOFF.md` 가 있으면 읽기 (직전 세션 상태 복원)
5. `wiki/index.md` 훑어보기 (현재 지식 지형)
'@
$readme = Replace-Exact -Text $readme -OldValue '5. 분석 타겟 경로 등록 (첫 사용 시):' -NewValue '6. 분석 타겟 경로 등록 (첫 사용 시):'
$readme = Replace-Exact -Text $readme -OldValue '6. (선택) Graphify git hook 설치 — 커밋·체크아웃 시 지식 그래프 자동 갱신:' -NewValue '7. (선택) Graphify git hook 설치 — 커밋·체크아웃 시 지식 그래프 자동 갱신:'
$readme = Replace-Exact -Text $readme -OldValue @'
- `CLAUDE.md` — 운영 스키마 (LLM 이 매 세션 먼저 읽음)
- `wiki/` — 정제된 지식 (domains / sources / entities / concepts / syntheses / decisions / playbooks)
- `raw/` — 불변 원본·스냅샷 (targets / specs / decisions / incidents / conversations / external)
- `docs/` — 팀 롤·이식 대기 목록
- `scripts/` — 유틸리티 (타겟 경로 resolve 등)
- `.claude/commands/` — 슬래시 커맨드 (`/ingest`, `/query`, `/lint`, `/graphify`)
- `graphify-out/` — Graphify 산출물 (로컬 빌드, gitignore)
'@ -NewValue @'
- `AGENTS.md` — Codex runtime guide (Codex 는 이 파일부터 읽음)
- `CLAUDE.md` — 운영 스키마 (Claude 는 이 파일부터 읽음)
- `SESSION-HANDOFF.md` — Claude/Codex 세션 전환용 상태 노트
- `wiki/` — 정제된 지식 (domains / sources / entities / concepts / syntheses / decisions / playbooks)
- `raw/` — 불변 원본·스냅샷 (targets / specs / decisions / incidents / conversations / external)
- `docs/` — 팀 롤·이식 대기 목록 + Codex parity 문서
- `scripts/` — 유틸리티 (타겟 경로 resolve 등 + Codex parity helper)
- `.claude/commands/` — 슬래시 커맨드 (`/ingest`, `/query`, `/lint`, `/graphify`, `/analyze*`, `/pair`)
- `RunClaude*.bat` / `RunCodex*.bat` — 런타임 진입점
- `graphify-out/` — Graphify 산출물 (로컬 빌드, gitignore)
'@
Write-Text -Path $readmePath -Text $readme

$claude = Read-Text -Path $claudePath
$claude = Insert-Before -Text $claude -Anchor "## 본 repo 의 존재 이유" -Insert @'
## Claude + Codex 병용 계약

- Claude entrypoint 는 `CLAUDE.md`, Codex entrypoint 는 `AGENTS.md` 다. 운영 규칙이 바뀌면 두 파일을 함께 갱신한다.
- 세션 전환 상태는 루트 `SESSION-HANDOFF.md` 에 남긴다.
- Graphify 가 폴더 구조와 wikilink 경로를 읽으므로 top-level 디렉토리 구조(`wiki/`, `raw/`, `docs/`, `graphify-out/`, `config/`)를 임의로 옮기거나 새 상위 디렉토리로 감싸지 않는다.
- `.claude/agents/saturation-*.md` 는 descriptive role 이 아니라 **binding runtime owner** 다. Codex 메인 에이전트는 분석 구조를 직접 수행으로 평탄화하면 안 된다.
- saturation framework 재이식, `.claude/agents/saturation-*.md` wholesale 교체, `config/saturation-driven.config.yml` 구조 변경, `applied-solutions.md` pin 수정은 `solution-transplanter` 소관이다.

### Mandatory Owner Routing

| task_kind | designated_owner | delegate_or_local | fallback | examples |
|---|---|---|---|---|
| `full-analysis` | `saturation-completeness-overseer` | delegate | delegation 불가 + 사용자 승인 시에만 local fallback | `/analyze`, `/analyze-code` default, `/analyze-spec` default |
| `code-analysis` | `saturation-code-analyst` | delegate-via-overseer | delegation 불가 + 사용자 승인 시에만 local fallback | `--code-only`, code axis drill-down |
| `spec-analysis` | `saturation-spec-analyst` | delegate-via-overseer | delegation 불가 + 사용자 승인 시에만 local fallback | `--spec-only`, spec corpus drill-down |
| `pairing-verification` | `saturation-cross-verifier` | delegate-via-overseer | delegation 불가 + 사용자 승인 시에만 local fallback | `/pair`, confidence/state labeling |
| `system-curation` | `saturation-domain-curator` | delegate-via-overseer | delegation 불가 + 사용자 승인 시에만 local fallback | `wiki/game-design/*`, `wiki/game-implementation/*` curation |
| `concept-curation` | `saturation-concept-curator` | delegate-via-overseer | delegation 불가 + 사용자 승인 시에만 local fallback | `wiki/game-design/concepts/*` 생성·보강 |
| `framework-upgrade` | `solution-transplanter` | delegate | delegation 불가 + 사용자 승인 시에만 local fallback | saturation framework re-transplant, prompt redistribution |
| `applied-solutions-update` | `solution-transplanter` | delegate | delegation 불가 + 사용자 승인 시에만 local fallback | `applied-solutions.md`, pin/version history |

### Routing Preflight + Fallback

owner-bound 작업을 시작하기 전 항상 `task_kind`, `designated_owner`, `delegate_or_local`, `why` 를 먼저 확정한다. mandatory owner 가 있으면 메인 에이전트는 직접 편집을 시작할 수 없다.

delegation 이 정책상 불가하면 메인 에이전트는 즉시 멈추고 사용자에게 delegation 승인 또는 explicit local override 를 요청해야 한다. delegation 불가를 이유로 silent local execution 으로 수렴하면 안 된다.

### Guarded Write Surfaces

- `.claude/agents/saturation-*.md`
- `.claude/commands/{analyze,analyze-code,analyze-spec,pair}.md`
- `config/saturation-driven.config.yml`
- `applied-solutions.md`
- `CLAUDE.md`, `AGENTS.md`, `SESSION-HANDOFF.md`
- Graphify-sensitive top-level layout (`wiki/`, `raw/`, `docs/`, `graphify-out/`, `config/`)

경고 문구:

`This change is owned by <designated_owner>. Delegation or explicit local override is required.`

### Command Surface

- `/route-check <task summary>`
- `/delegate saturation-completeness-overseer <task>`
- `/delegate saturation-code-analyst <task>`
- `/delegate saturation-spec-analyst <task>`
- `/delegate saturation-cross-verifier <task>`
- `/delegate saturation-domain-curator <task>`
- `/delegate saturation-concept-curator <task>`
- `/delegate solution-transplanter <task>`

### Workflow Parity

- `.claude/commands/*` 의 slash trigger 는 Codex 에서 literal shell command 가 아니라 workflow label 로 해석한다.
- `docs/codex-parity.md` 는 command / hook / wrapper / launcher parity SSoT 다.
- `feedback-prompt` hook 은 Codex 에서 native hook 으로 직접 돌지 않으므로 `scripts/codex-feedback-signal.ps1` 또는 동등 절차로 의미만 에뮬레이션한다.
- command, hook, wrapper, launcher parity 가 분석·검증되지 않았다면 Codex 연동 완료로 주장하면 안 된다.

### Runtime Contract Installation Gate

named owner, preserved subagent structure, guarded write, routing command 중 하나라도 전제하는 변경은 `CLAUDE.md` 와 `AGENTS.md` 에 binding runtime contract 가 반영될 때까지 완료가 아니다.

'@
$claude = Replace-Exact -Text $claude -OldValue @'
named owner, preserved subagent structure, guarded write, routing command 중 하나라도 전제하는 변경은 `CLAUDE.md` 와 `AGENTS.md` 에 binding runtime contract 가 반영될 때까지 완료가 아니다.
## 본 repo 의 존재 이유
'@ -NewValue @'
named owner, preserved subagent structure, guarded write, routing command 중 하나라도 전제하는 변경은 `CLAUDE.md` 와 `AGENTS.md` 에 binding runtime contract 가 반영될 때까지 완료가 아니다.

## 본 repo 의 존재 이유
'@
$claude = Replace-Exact -Text $claude -OldValue @'
woore-ai-knowledge-fsf2/
├── CLAUDE.md                    ← 이 파일
├── README.md                    ← 팀 onboarding
├── docs/
│   ├── roles.md                 ← 팀 롤 · 에이전트 페르소나
│   └── pending-imports.md       ← 이식 대기 외부 자산
├── raw/                         ← 불변 원본·스냅샷·타겟 메타. 절대 수정 금지.
│   ├── targets/                 ← 분석 타겟 프로젝트 메타 (경로는 .local/paths.json)
│   ├── specs/                   ← 기획서 스냅샷
│   ├── decisions/               ← 회의록·ADR 원본
│   ├── incidents/               ← 장애·포스트모템 원본
│   ├── conversations/           ← 에이전트 세션 stash (비자명 결정·실패 인사이트)
│   └── external/                ← 외부 자료 (문서·논문·아티클)
├── wiki/                        ← 정제된 지식. 자유 편집.
│   ├── index.md                 ← 전체 카탈로그 (한 줄·120 자)
│   ├── log.md                   ← append-only 운영 기록
│   ├── overview.md              ← 전체 합성 뷰 (lint 시 갱신)
│   ├── domains/                 ← 3 도메인 entry (위 표 참조)
│   ├── sources/                 ← raw 요약 (사실만, 해석 금지)
│   ├── entities/                ← 사람·팀·제품·도구·외부 파트너
│   ├── concepts/                ← 개념·프레임워크·패턴 (cross-domain 우선 승격)
│   ├── decisions/               ← ADR 스타일 (why + 대안 + 결과)
│   ├── playbooks/               ← 기획/코딩 에이전트가 따라 실행하는 레시피
│   └── syntheses/               ← 쿼리 답변 중 재사용 가치 있는 것
├── graphify-out/                ← Graphify 산출 (graph.json/html, GRAPH_REPORT.md). gitignore.
├── scripts/
│   └── resolve_target.py        ← .local/paths.json 읽어 타겟 경로 resolve
├── .local/                      ← 각 사용자 로컬. gitignore.
│   └── paths.json               ← { "<target_name>": "<local_absolute_path>" }
└── .claude/
    └── commands/                ← /ingest /query /lint /graphify + 이식 대기 placeholder
'@ -NewValue @'
woore-ai-knowledge-fsf2/
├── AGENTS.md                    ← Codex runtime guide
├── CLAUDE.md                    ← Claude runtime guide
├── SESSION-HANDOFF.md           ← Claude/Codex switchback note
├── README.md                    ← 팀 onboarding
├── RunClaude*.bat               ← Claude 진입점
├── RunCodex*.bat                ← Codex 진입점
├── docs/
│   ├── roles.md                 ← 팀 롤 · 에이전트 페르소나
│   └── pending-imports.md       ← 이식 상태 + dual-runtime 메모
├── raw/                         ← 불변 원본·스냅샷·타겟 메타. 절대 수정 금지.
│   ├── targets/                 ← 분석 타겟 프로젝트 메타 (경로는 .local/paths.json)
│   ├── specs/                   ← 기획서 스냅샷
│   ├── decisions/               ← 회의록·ADR 원본
│   ├── incidents/               ← 장애·포스트모템 원본
│   ├── conversations/           ← 에이전트 세션 stash (비자명 결정·실패 인사이트)
│   └── external/                ← 외부 자료 (문서·논문·아티클)
├── wiki/                        ← 정제된 지식. 자유 편집.
│   ├── index.md                 ← 전체 카탈로그 (한 줄·120 자)
│   ├── log.md                   ← append-only 운영 기록
│   ├── overview.md              ← 전체 합성 뷰 (lint 시 갱신)
│   ├── domains/                 ← 3 도메인 entry (위 표 참조)
│   ├── sources/                 ← raw 요약 (사실만, 해석 금지)
│   ├── entities/                ← 사람·팀·제품·도구·외부 파트너
│   ├── concepts/                ← 개념·프레임워크·패턴 (cross-domain 우선 승격)
│   ├── decisions/               ← ADR 스타일 (why + 대안 + 결과)
│   ├── playbooks/               ← 기획/코딩 에이전트가 따라 실행하는 레시피
│   └── syntheses/               ← 쿼리 답변 중 재사용 가치 있는 것
├── graphify-out/                ← Graphify 산출 (graph.json/html, GRAPH_REPORT.md). gitignore.
├── scripts/
│   └── resolve_target.py        ← .local/paths.json 읽어 타겟 경로 resolve
├── .local/                      ← 각 사용자 로컬. gitignore.
│   └── paths.json               ← { "<target_name>": "<local_absolute_path>" }
└── .claude/
    ├── agents/                  ← saturation 6역 정의
    └── commands/                ← /ingest /query /lint /graphify /analyze* /pair
'@
Write-Text -Path $claudePath -Text $claude

$pendingImports = Read-Text -Path $pendingImportsPath
$pendingImports = Replace-Exact -Text $pendingImports -OldValue 'updated: 2026-04-20' -NewValue 'updated: 2026-04-21'
$pendingImports = Replace-Exact -Text $pendingImports -OldValue 'status: partial   # framework 이식 + v0.2 + v0.3 업그레이드 완료, 사이클 2 실행은 대기' -NewValue 'status: active   # framework v0.11.1 운영 중, Codex dual-runtime continuity 설치 완료'
$pendingImports = Replace-Exact -Text $pendingImports -OldValue '## 분석 서브에이전트 프레임워크 — **이식 완료 (small seed 2026-04-20 → v0.2 → v0.3 업그레이드 2026-04-20)**' -NewValue '## 분석 서브에이전트 프레임워크 — **이식 완료 (small seed 2026-04-20 → v0.11.1 업그레이드 2026-04-21)**'
$pendingImports = Replace-Exact -Text $pendingImports -OldValue '- `saturation-driven-analysis@0.3` (framework — HarnessMaker) — v0.1 → v0.2 → v0.3 연속 업그레이드 완료' -NewValue '- `saturation-driven-analysis@0.11.1` (framework — HarnessMaker) — v0.1 → v0.2 → v0.3 → v0.4 → v0.5 → v0.11.1 연속 업그레이드 완료'
$pendingImports = Replace-Exact -Text $pendingImports -OldValue '- 5-역 서브에이전트 정의 (`.claude/agents/saturation-*.md`)' -NewValue '- 6-역 서브에이전트 정의 (`.claude/agents/saturation-*.md`)'
$pendingImports = Replace-Exact -Text $pendingImports -OldValue '- 3 커맨드 본문 (`.claude/commands/{analyze-code,analyze-spec,pair}.md`)' -NewValue '- 4 커맨드 본문 (`.claude/commands/{analyze,analyze-code,analyze-spec,pair}.md`)'
$pendingImports = Insert-Before -Text $pendingImports -Anchor '## 미래 작업 (Phase C/D)' -Insert @'
## Dual-Runtime Continuity — **설치 완료 (2026-04-21)**

- 루트 Codex 가이드 `AGENTS.md` 설치
- 세션 전환 노트 `SESSION-HANDOFF.md` 설치
- Codex 런처 `RunCodex.bat`, `RunCodex_xhigh.bat` 추가
- workflow parity 문서 `docs/codex-parity.md` 설치
- feedback hook parity helper `scripts/codex-feedback-signal.ps1` 추가
- binding owner-routing 설치:
  - `saturation-*` 6역 = 분석 런타임 owner
  - `solution-transplanter` = saturation framework 재이식 / manifest update owner
- delegation 불가 시 main agent 가 silent local execution 으로 수렴하지 않고, 사용자 승인 또는 explicit local override 를 요구하도록 계약화
- Graphify-safe exclusions 업데이트 (`AGENTS.md`, `SESSION-HANDOFF.md`, `RunCodex*.bat`)

'@
Write-Text -Path $pendingImportsPath -Text $pendingImports

$appliedSolutions = Read-Text -Path $appliedSolutionsPath
$appliedSolutions = Insert-After -Text $appliedSolutions -Anchor '## 변경 이력' -Insert @'
- **2026-04-21 (Codex 연동)**: root `AGENTS.md`, `SESSION-HANDOFF.md`, `RunCodex.bat`, `RunCodex_xhigh.bat` 설치. `docs/codex-parity.md` 와 `scripts/codex-feedback-signal.ps1` 를 추가해 command/hook/workflow parity 를 문서화했다. `.graphifyignore` 에 새 운영 자산 제외 규칙을 추가해 Graphify 입력 표면을 유지. binding owner-routing 도입: `saturation-*` 6역은 analysis runtime owner, saturation framework 재이식 / `.claude/agents/saturation-*` wholesale 교체 / `config/saturation-driven.config.yml` 구조 변경 / `applied-solutions.md` pin 변경은 `solution-transplanter` 소관으로 명시. delegation 불가 시 메인 에이전트가 silent local execution 으로 수렴하지 않고 사용자 승인 또는 explicit local override 를 요구한다.
'@
$appliedSolutions = Replace-Exact -Text $appliedSolutions -OldValue '## 변경 이력- **2026-04-21 (Codex 연동)**' -NewValue @'
## 변경 이력

- **2026-04-21 (Codex 연동)**
'@
Write-Text -Path $appliedSolutionsPath -Text $appliedSolutions

$feedbackHookSpec = Read-Text -Path $feedbackHookSpecPath
$feedbackHookSpec = Insert-Before -Text $feedbackHookSpec -Anchor '## `.claude/settings.json` 등록 예시 (활성화 시)' -Insert @'
## Codex parity

Codex 세션에서는 `.claude/hooks/feedback-prompt.sh` 가 native hook 으로 자동 실행되지 않는다. 대신 아래 규약으로 의미를 에뮬레이션한다.

- 사용자 프롬프트에 bug / suggestion / question / praise signal 이 있으면, 응답 끝에 `/feedback` 또는 `feedback/inbox.md` 저장을 짧게 제안한다.
- 자동 저장 금지 규칙은 동일하다.
- 수동 검출이 필요하면 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/codex-feedback-signal.ps1 -PromptText "<user text>"` 를 사용한다.
- command / hook / launcher parity 의 authoritative mapping 은 `docs/codex-parity.md` 를 따른다.

'@
Write-Text -Path $feedbackHookSpecPath -Text $feedbackHookSpec

$commandParityNotes = @{
    "analyze.md" = "Codex 에서는 `/analyze` 를 literal slash command 가 아니라 full orchestration workflow label 로 해석한다. designated owner 는 `saturation-completeness-overseer` 다. source subagent structure 를 평탄화하면 안 된다."
    "analyze-code.md" = "Codex 에서는 `/analyze-code` 를 workflow label 로 해석한다. `--code-only` 가 없으면 full orchestration 이 기본이고, `saturation-completeness-overseer` 구조를 보존해야 한다."
    "analyze-spec.md" = "Codex 에서는 `/analyze-spec` 를 workflow label 로 해석한다. `--spec-only` 가 없으면 full orchestration 이 기본이고, `saturation-completeness-overseer` 구조를 보존해야 한다."
    "pair.md" = "Codex 에서는 `/pair` 를 workflow label 로 해석한다. designated owner 는 `saturation-cross-verifier` 이고, curator 단계까지 포함한 owner structure 를 평탄화하면 안 된다."
    "feedback.md" = "Codex 에서는 `/feedback` 를 같은 feedback entry 저장 workflow 로 수동 수행한다. 사용자의 동의 없이 자동 저장하면 안 된다."
    "query.md" = "Codex 에서는 `/query` 를 같은 wiki query workflow 로 수동 수행한다. `wiki/index.md` → graph/report → candidate pages → raw 최후수단 순서를 유지한다."
    "ingest.md" = "Codex 에서는 `/ingest` 를 같은 ingest workflow 로 수동 수행한다. Gold In 게이트와 `raw/` 불변 규칙을 그대로 유지한다."
    "lint.md" = "Codex 에서는 `/lint` 를 같은 lint workflow 로 수동 수행한다. 자동 수정 가능한 것만 즉시 수정하고, 판단이 필요한 항목은 제안으로 남긴다."
    "graphify.md" = "Codex 에서는 `/graphify` 를 같은 graphify wrapper workflow 로 수동 수행한다. Graphify-sensitive top-level layout 을 바꾸지 않는다."
}

foreach ($fileName in $commandParityNotes.Keys) {
    $commandPath = Join-Path $TargetRoot ".claude/commands/$fileName"
    $commandText = Read-Text -Path $commandPath
    $commandText = Insert-AfterRegexFirst -Text $commandText -Pattern '^# /[^\n]+$' -Insert ("## Codex Parity`n`n" + $commandParityNotes[$fileName])
    Write-Text -Path $commandPath -Text $commandText
}

Write-Host "Patched Codex integration for $TargetRoot"
