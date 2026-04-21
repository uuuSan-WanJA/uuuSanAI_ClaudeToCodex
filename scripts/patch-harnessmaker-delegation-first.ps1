param(
    [string]$HarnessMakerRoot = "D:\Work_GitHub\ClaudeCode_uuuSanAI\Projects\Bundle_Harness\uuuSanAI_HarnessMaker"
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
    $normalizedOld = Normalize-Newlines -Text $OldValue
    $normalizedNew = Normalize-Newlines -Text $NewValue

    if ($normalizedText.Contains($normalizedNew)) {
        return $normalizedText
    }

    if (-not $normalizedText.Contains($normalizedOld)) {
        throw "Expected text not found."
    }

    return $normalizedText.Replace($normalizedOld, $normalizedNew)
}

$agentsPath = Join-Path $HarnessMakerRoot "AGENTS.md"
$claudePath = Join-Path $HarnessMakerRoot "CLAUDE.md"
$ownerRoutingPath = Join-Path $HarnessMakerRoot "components/owner-routing-contract.md"
$solutionTransplanterPath = Join-Path $HarnessMakerRoot "components/solution-transplanter.md"
$solutionTransplanterAgentPath = Join-Path $HarnessMakerRoot ".claude/agents/solution-transplanter.md"
$threeTierBlockingPath = Join-Path $HarnessMakerRoot "components/three-tier-blocking.md"
$codexConfigDirectory = Join-Path $HarnessMakerRoot ".codex"
$codexConfigPath = Join-Path $codexConfigDirectory "config.toml"
$startupPromptPath = Join-Path $codexConfigDirectory "startup-prompt.ko.txt"
$runCodexPath = Join-Path $HarnessMakerRoot "RunCodex.bat"
$runCodexXhighPath = Join-Path $HarnessMakerRoot "RunCodex_xhigh.bat"

if (-not (Test-Path -LiteralPath $codexConfigDirectory -PathType Container)) {
    [void](New-Item -ItemType Directory -Path $codexConfigDirectory -Force)
}

$codexConfig = @'
developer_instructions = """
In HarnessMaker, if repo-local docs define a mandatory owner for the requested task kind, treat that as delegation-first routing.
Use the named owner or subagent first for owner-bound work such as framework-upgrade, target-repo-transplant, applied-solutions-update, or equivalent guarded-write maintenance tasks.
Do not ask for main-agent local override first.
Ask for explicit local override only if delegation cannot run or the user explicitly declines delegation.
Natural-language approvals that directly reference the designated owner, or phrases such as "서브에이전트로 처리" and "바로 위임해", count as explicit delegation approval for that owner.
Preserve declared Claude subagent structures and owner boundaries by default; do not flatten them into main-agent local execution without explicit override.
"""
'@
Write-Text -Path $codexConfigPath -Text $codexConfig

$startupPrompt = @'
이 repo에서는 owner-bound 작업이 있으면 repo 문서가 지정한 named owner 또는 subagent를 먼저 사용한다. 사용자가 해당 owner 이름으로 진행하라고 말하거나 서브에이전트로 처리, 바로 위임해처럼 승인하면 explicit delegation 승인으로 간주한다. 메인 에이전트 local override를 먼저 묻지 말고, 선언된 서브에이전트 구조와 owner 경계를 유지한다.
'@
Write-Text -Path $startupPromptPath -Text $startupPrompt

$runCodex = @'
@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -Command "$PromptText = (Get-Content -Raw -LiteralPath '%~dp0.codex\startup-prompt.ko.txt').Trim(); $CodexCmd = (Get-Command codex.cmd -CommandType Application -ErrorAction Stop).Source; & $CodexCmd $PromptText"

pause
'@
Write-Text -Path $runCodexPath -Text $runCodex

$runCodexXhigh = @'
@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -Command "$PromptText = (Get-Content -Raw -LiteralPath '%~dp0.codex\startup-prompt.ko.txt').Trim(); $CodexCmd = (Get-Command codex.cmd -CommandType Application -ErrorAction Stop).Source; & $CodexCmd -c 'model_reasoning_effort=xhigh' $PromptText"

pause
'@
Write-Text -Path $runCodexXhighPath -Text $runCodexXhigh

$agents = Read-Text -Path $agentsPath
$agents = Replace-Exact -Text $agents -OldValue '- mandatory owner 가 존재하면 direct edit 를 시작하지 않는다. 현재 런타임 정책상 delegation 이 불가하면 사용자에게 delegation 승인 또는 explicit local override 를 요청한다.' -NewValue '- mandatory owner 가 존재하면 direct edit 를 시작하지 않는다. 현재 런타임 정책상 implicit delegation 이 불가하면 사용자에게 delegation 승인을 먼저 요청하고, 그게 계속 불가하거나 사용자가 거절한 경우에만 explicit local override 를 요청한다.'
$agents = Replace-Exact -Text $agents -OldValue '`This change is owned by solution-transplanter. Delegation or explicit local override is required.`' -NewValue '`This change is owned by solution-transplanter. Delegation approval is required first; explicit local override is only the fallback.`'
$agents = Replace-Exact -Text $agents -OldValue '- `/route-check <task summary>`' -NewValue @'
- `/route-check <task summary>`
- `solution-transplanter로 진행`, `서브에이전트로 처리`, `바로 위임해` 같은 자연어는 named owner 에 대한 explicit delegation approval 로 해석한다.
- `.codex/config.toml` 의 `developer_instructions` 는 Codex 상위 레이어에서 delegation-first routing 을 보강하는 표준 자산이다.
'@
Write-Text -Path $agentsPath -Text $agents

$claude = Read-Text -Path $claudePath
$claude = Replace-Exact -Text $claude -OldValue '4. **delegation 불가 시 자동 로컬 수행 금지**: 현재 런타임 정책상 delegation 이 안 되면 사용자에게 delegation 승인 또는 explicit local override 를 요청한다.' -NewValue '4. **delegation 불가 시 자동 로컬 수행 금지**: 현재 런타임 정책상 implicit delegation 이 안 되면 사용자에게 delegation 승인을 먼저 요청하고, 그게 계속 불가하거나 사용자가 거절한 경우에만 explicit local override 를 요청한다.'
$claude = Replace-Exact -Text $claude -OldValue '`This change is owned by solution-transplanter. Delegation or explicit local override is required.`' -NewValue '`This change is owned by solution-transplanter. Delegation approval is required first; explicit local override is only the fallback.`'
$claude = Replace-Exact -Text $claude -OldValue '- `/route-check <task summary>`' -NewValue @'
- `/route-check <task summary>`
- `solution-transplanter로 진행`, `서브에이전트로 처리`, `바로 위임해` 같은 자연어는 named owner 에 대한 explicit delegation approval 로 해석한다.
- `.codex/config.toml` 의 `developer_instructions` 는 Codex 상위 레이어에서 delegation-first routing 을 보강하는 표준 자산이다.
'@
Write-Text -Path $claudePath -Text $claude

$ownerRouting = Read-Text -Path $ownerRoutingPath
$ownerRouting = Replace-Exact -Text $ownerRouting -OldValue '4. delegation 이 불가하면 사용자 승인 후 local fallback 만 허용한다.' -NewValue '4. delegation 이 불가하면 delegation 승인 요청이 먼저고, 그게 계속 불가하거나 사용자가 거절한 경우에만 local fallback 을 허용한다.'
$ownerRouting = Replace-Exact -Text $ownerRouting -OldValue @'
1. 편집 전에 정지
2. delegation 승인 또는 explicit local override 요청
3. 승인된 local fallback 이면 handoff / verification 자산에 기록
'@ -NewValue @'
1. 편집 전에 정지
2. delegation 승인을 먼저 요청
3. delegation 이 계속 불가하거나 사용자가 거절한 경우에만 explicit local override 요청
4. 승인된 local fallback 이면 handoff / verification 자산에 기록
'@
$ownerRouting = Replace-Exact -Text $ownerRouting -OldValue '- `/route-check <task summary>`' -NewValue @'
- `/route-check <task summary>`
- `solution-transplanter로 진행`, `서브에이전트로 처리`, `바로 위임해` 같은 자연어는 named owner 에 대한 explicit delegation approval 로 해석한다.
- Codex CLI 대상이면 `.codex/config.toml` + `developer_instructions` 를 함께 설치해 delegation-first routing 을 repo 문서보다 위 레이어에서 보강한다.
'@
Write-Text -Path $ownerRoutingPath -Text $ownerRouting

$solutionTransplanter = Read-Text -Path $solutionTransplanterPath
$solutionTransplanter = Replace-Exact -Text $solutionTransplanter -OldValue '따라서 메인 에이전트는 위 작업을 발견해도 직접 수행으로 흡수하지 않는다. 기본은 delegation 이며, 현재 런타임 정책상 delegation 이 불가하면 사용자에게 delegation 승인 또는 explicit local override 를 요청해야 한다.' -NewValue '따라서 메인 에이전트는 위 작업을 발견해도 직접 수행으로 흡수하지 않는다. 기본은 delegation 이며, 현재 런타임 정책상 implicit delegation 이 불가하면 사용자에게 delegation 승인을 먼저 요청해야 한다. 그게 계속 불가하거나 사용자가 거절한 경우에만 explicit local override 를 요청한다. Codex 대상 이식에서는 `.codex/config.toml` 의 `developer_instructions` 를 함께 설치해 이 규칙을 runtime 레이어에서도 강화한다.'
Write-Text -Path $solutionTransplanterPath -Text $solutionTransplanter

$solutionTransplanterAgent = Read-Text -Path $solutionTransplanterAgentPath
$solutionTransplanterAgent = Replace-Exact -Text $solutionTransplanterAgent -OldValue '- If a task belongs to a mandatory owner, do not flatten it into the main agent''s local work. Return control for delegation approval or explicit local override when needed.' -NewValue '- If a task belongs to a mandatory owner, do not flatten it into the main agent''s local work. Return control for delegation approval first. Explicit local override is only the fallback if delegation remains unavailable or the user declines it.'
Write-Text -Path $solutionTransplanterAgentPath -Text $solutionTransplanterAgent

$threeTierBlocking = Read-Text -Path $threeTierBlockingPath
$threeTierBlocking = Replace-Exact -Text $threeTierBlocking -OldValue '- **mandatory owner 예외 없음**: task 가 mandatory owner 에 묶여 있으면 main agent 가 이를 로컬 작업으로 평탄화할 수 없다. delegation 이 불가하면 explicit local override 승인 전까지 정지한다.' -NewValue '- **mandatory owner 예외 없음**: task 가 mandatory owner 에 묶여 있으면 main agent 가 이를 로컬 작업으로 평탄화할 수 없다. delegation 이 불가하면 delegation 승인을 먼저 요청하고, 그게 계속 불가하거나 사용자가 거절한 경우에만 explicit local override 승인 전까지 정지한다.'
Write-Text -Path $threeTierBlockingPath -Text $threeTierBlocking

Write-Host "Patched delegation-first owner routing for $HarnessMakerRoot"
