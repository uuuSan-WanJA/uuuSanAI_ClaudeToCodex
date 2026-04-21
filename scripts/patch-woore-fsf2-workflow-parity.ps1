param(
    [string]$TargetRoot = "D:\Work_GitHub\ClaudeCode_WooreAI\woore-ai-knowledge-fsf2"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-Newlines {
    param([string]$Text)
    return $Text -replace "`r`n", "`n"
}

function Read-Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path)
}

function Write-Text {
    param(
        [string]$Path,
        [string]$Text
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    $normalized = (Normalize-Newlines -Text $Text).TrimEnd("`n") + "`n"
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

function Replace-IfPresent {
    param(
        [string]$Text,
        [string]$OldValue,
        [string]$NewValue
    )

    $normalizedText = Normalize-Newlines -Text $Text
    $normalizedOldValue = Normalize-Newlines -Text $OldValue
    $normalizedNewValue = Normalize-Newlines -Text $NewValue

    if (-not $normalizedText.Contains($normalizedOldValue)) {
        return $normalizedText
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

    $separator = ""
    if (-not $normalizedInsert.StartsWith("`n")) {
        $separator = "`n"
    }

    return $normalizedText.Replace($normalizedAnchor, $normalizedAnchor + $separator + $normalizedInsert)
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

$agentsPath = Join-Path $TargetRoot "AGENTS.md"
$claudePath = Join-Path $TargetRoot "CLAUDE.md"
$readmePath = Join-Path $TargetRoot "README.md"
$pendingImportsPath = Join-Path $TargetRoot "docs/pending-imports.md"
$appliedSolutionsPath = Join-Path $TargetRoot "applied-solutions.md"
$sessionHandoffPath = Join-Path $TargetRoot "SESSION-HANDOFF.md"
$codexParityPath = Join-Path $TargetRoot "docs/codex-parity.md"
$feedbackHookSpecPath = Join-Path $TargetRoot ".claude/hooks/feedback-prompt.md"
$codexFeedbackSignalPath = Join-Path $TargetRoot "scripts/codex-feedback-signal.ps1"

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

Write-Text -Path $codexParityPath -Text $codexParityContent
Write-Text -Path $codexFeedbackSignalPath -Text $codexFeedbackSignalContent

$agents = Read-Text -Path $agentsPath
$agents = Insert-Before -Text $agents -Anchor "## Runtime Contract Installation Gate" -Insert @'
## Command + Hook Parity

- command parity mapping 은 `docs/codex-parity.md` 에 둔다.
- `.claude/commands/*` 의 slash trigger 는 Codex 에서 literal shell command 가 아니라 workflow label 이다.
- `/analyze`, `/analyze-code`, `/analyze-spec`, `/pair` 는 owner-bound 분석 요청이다. Codex 는 `saturation-*` 구조를 보존한 채 같은 절차를 수행해야 한다.
- `feedback-prompt` hook 은 Codex 에서 native hook 으로 직접 돌지 않으므로 `docs/codex-parity.md` 와 `scripts/codex-feedback-signal.ps1` 절차로 의미만 에뮬레이션한다.
- command, hook, wrapper, launcher parity 가 끝나기 전에는 Codex 연동 완료로 주장하지 않는다.

'@
Write-Text -Path $agentsPath -Text $agents

$claude = Read-Text -Path $claudePath
$claude = Insert-Before -Text $claude -Anchor "### Runtime Contract Installation Gate" -Insert @'
### Workflow Parity

- `.claude/commands/*` 의 slash trigger 는 Codex 에서 literal shell command 가 아니라 workflow label 로 해석한다.
- `docs/codex-parity.md` 는 command / hook / wrapper / launcher parity SSoT 다.
- `feedback-prompt` hook 은 Codex 에서 native hook 으로 직접 돌지 않으므로 `scripts/codex-feedback-signal.ps1` 또는 동등 절차로 의미만 에뮬레이션한다.
- command, hook, wrapper, launcher parity 가 분석·검증되지 않았다면 Codex 연동 완료로 주장하면 안 된다.

'@
Write-Text -Path $claudePath -Text $claude

$readme = Read-Text -Path $readmePath
$readme = Replace-Exact -Text $readme -OldValue '- `docs/` — 팀 롤·이식 대기 목록' -NewValue '- `docs/` — 팀 롤·이식 대기 목록 + Codex parity 문서'
$readme = Replace-Exact -Text $readme -OldValue '- `scripts/` — 유틸리티 (타겟 경로 resolve 등)' -NewValue '- `scripts/` — 유틸리티 (타겟 경로 resolve 등 + Codex parity helper)'
Write-Text -Path $readmePath -Text $readme

$pendingImports = Read-Text -Path $pendingImportsPath
$pendingImports = Replace-IfPresent -Text $pendingImports -OldValue '- Codex 런처 `RunCodex.bat`, `RunCodex_xhigh.bat` 추가- workflow parity 문서 `docs/codex-parity.md` 설치
- feedback hook parity helper `scripts/codex-feedback-signal.ps1` 추가' -NewValue '- Codex 런처 `RunCodex.bat`, `RunCodex_xhigh.bat` 추가
- workflow parity 문서 `docs/codex-parity.md` 설치
- feedback hook parity helper `scripts/codex-feedback-signal.ps1` 추가'
$pendingImports = Insert-After -Text $pendingImports -Anchor '- Codex 런처 `RunCodex.bat`, `RunCodex_xhigh.bat` 추가' -Insert @'
- workflow parity 문서 `docs/codex-parity.md` 설치
- feedback hook parity helper `scripts/codex-feedback-signal.ps1` 추가
'@
Write-Text -Path $pendingImportsPath -Text $pendingImports

$appliedSolutions = Read-Text -Path $appliedSolutionsPath
$appliedSolutions = Replace-Exact -Text $appliedSolutions -OldValue '- **2026-04-21 (Codex 연동)**: root `AGENTS.md`, `SESSION-HANDOFF.md`, `RunCodex.bat`, `RunCodex_xhigh.bat` 설치. `.graphifyignore` 에 새 운영 자산 제외 규칙을 추가해 Graphify 입력 표면을 유지. binding owner-routing 도입: `saturation-*` 6역은 analysis runtime owner, saturation framework 재이식 / `.claude/agents/saturation-*` wholesale 교체 / `config/saturation-driven.config.yml` 구조 변경 / `applied-solutions.md` pin 변경은 `solution-transplanter` 소관으로 명시. delegation 불가 시 메인 에이전트가 silent local execution 으로 수렴하지 않고 사용자 승인 또는 explicit local override 를 요구한다.' -NewValue '- **2026-04-21 (Codex 연동)**: root `AGENTS.md`, `SESSION-HANDOFF.md`, `RunCodex.bat`, `RunCodex_xhigh.bat` 설치. `docs/codex-parity.md` 와 `scripts/codex-feedback-signal.ps1` 를 추가해 command/hook/workflow parity 를 문서화했다. `.graphifyignore` 에 새 운영 자산 제외 규칙을 추가해 Graphify 입력 표면을 유지. binding owner-routing 도입: `saturation-*` 6역은 analysis runtime owner, saturation framework 재이식 / `.claude/agents/saturation-*` wholesale 교체 / `config/saturation-driven.config.yml` 구조 변경 / `applied-solutions.md` pin 변경은 `solution-transplanter` 소관으로 명시. delegation 불가 시 메인 에이전트가 silent local execution 으로 수렴하지 않고 사용자 승인 또는 explicit local override 를 요구한다.'
Write-Text -Path $appliedSolutionsPath -Text $appliedSolutions

$sessionHandoff = Read-Text -Path $sessionHandoffPath
$sessionHandoff = Replace-Exact -Text $sessionHandoff -OldValue '- last meaningful change: repo-root `AGENTS.md`, `RunCodex*.bat`, binding owner-routing contract, and Graphify-safe exclusions were installed for Codex operation.' -NewValue '- last meaningful change: `docs/codex-parity.md`, `scripts/codex-feedback-signal.ps1`, `.claude/commands/*` parity notes, and `.claude/hooks/feedback-prompt.md` Codex parity guidance were added on top of the repo-root Codex contract.'
$sessionHandoff = Replace-Exact -Text $sessionHandoff -OldValue '- current focus: keep saturation 6-role analysis topology intact across Claude and Codex sessions.' -NewValue '- current focus: keep the saturation 6-role analysis topology and feedback/command workflow parity intact across Claude and Codex sessions.'
$sessionHandoff = Replace-IfPresent -Text $sessionHandoff -OldValue '- `docs/pending-imports.md`- `docs/codex-parity.md`' -NewValue '- `docs/pending-imports.md`
- `docs/codex-parity.md`'
$sessionHandoff = Replace-IfPresent -Text $sessionHandoff -OldValue '- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. delegation 이 불가하면 explicit local override 없이는 owner-bound 변경을 진행하지 않는다.- `feedback-prompt` hook parity 는 `scripts/codex-feedback-signal.ps1` 로 의미만 에뮬레이션한다. 자동 저장은 금지되고, `/feedback` 또는 `feedback/inbox.md` 제안만 허용된다.' -NewValue '- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. delegation 이 불가하면 explicit local override 없이는 owner-bound 변경을 진행하지 않는다.
- `feedback-prompt` hook parity 는 `scripts/codex-feedback-signal.ps1` 로 의미만 에뮬레이션한다. 자동 저장은 금지되고, `/feedback` 또는 `feedback/inbox.md` 제안만 허용된다.'
$sessionHandoff = Insert-After -Text $sessionHandoff -Anchor '- `docs/pending-imports.md`' -Insert @'
- `docs/codex-parity.md`
- `scripts/codex-feedback-signal.ps1`
- `.claude/hooks/feedback-prompt.md`
- `.claude/commands/{analyze,analyze-code,analyze-spec,pair,feedback,query,ingest,lint,graphify}.md`
'@
$sessionHandoff = Insert-After -Text $sessionHandoff -Anchor '- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. delegation 이 불가하면 explicit local override 없이는 owner-bound 변경을 진행하지 않는다.' -Insert @'
- `feedback-prompt` hook parity 는 `scripts/codex-feedback-signal.ps1` 로 의미만 에뮬레이션한다. 자동 저장은 금지되고, `/feedback` 또는 `feedback/inbox.md` 제안만 허용된다.
'@
Write-Text -Path $sessionHandoffPath -Text $sessionHandoff

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

Write-Host "Patched workflow parity for $TargetRoot"
