[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HarnessMakerRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Text {
    param([string]$Path)
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Write-Text {
    param(
        [string]$Path,
        [string]$Content
    )
    $normalized = if ([string]::IsNullOrEmpty($Content)) {
        $Content
    }
    else {
        $Content.TrimEnd("`r", "`n") + [Environment]::NewLine
    }
    [System.IO.File]::WriteAllText($Path, $normalized, $Utf8NoBom)
}

function Insert-Before {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Insert
    )

    if ($Text.Contains($Insert.Trim())) {
        return $Text
    }

    if (-not $Text.Contains($Needle)) {
        throw "Needle not found for insert-before: $Needle"
    }

    return $Text.Replace($Needle, $Insert + $Needle)
}

function Insert-After {
    param(
        [string]$Text,
        [string]$Needle,
        [string]$Insert
    )

    if ($Text.Contains($Insert.Trim())) {
        return $Text
    }

    if (-not $Text.Contains($Needle)) {
        throw "Needle not found for insert-after: $Needle"
    }

    return $Text.Replace($Needle, $Needle + $Insert)
}

function Replace-Exact {
    param(
        [string]$Text,
        [string]$OldValue,
        [string]$NewValue
    )

    if ($Text.Contains($NewValue)) {
        return $Text
    }

    if (-not $Text.Contains($OldValue)) {
        $previewLength = [Math]::Min(120, $OldValue.Length)
        throw ("Expected text not found for replacement: " + $OldValue.Substring(0, $previewLength))
    }

    return $Text.Replace($OldValue, $NewValue)
}

$root = (Resolve-Path -LiteralPath $HarnessMakerRoot).Path

$agentsPath = Join-Path $root "AGENTS.md"
$claudePath = Join-Path $root "CLAUDE.md"
$handoffPath = Join-Path $root "SESSION-HANDOFF.md"
$appliedSolutionsPath = Join-Path $root "applied-solutions.md"
$componentRegistryPath = Join-Path $root "components/registry.md"
$executionPacketPath = Join-Path $root "components/execution-packet.md"
$threeTierPath = Join-Path $root "components/three-tier-blocking.md"
$solutionTransplanterPath = Join-Path $root "components/solution-transplanter.md"
$transplanterAgentPath = Join-Path $root ".claude/agents/solution-transplanter.md"
$roleProblemPath = Join-Path $root "problems/role-specialization.md"
$actionProblemPath = Join-Path $root "problems/action-authorization.md"
$multiProjectPath = Join-Path $root "frameworks/multi-project-rollout/definition.md"
$saturationPath = Join-Path $root "frameworks/saturation-driven-analysis/definition.md"
$ownerRoutingComponentPath = Join-Path $root "components/owner-routing-contract.md"
$ownerRoutingProblemPath = Join-Path $root "problems/mandatory-owner-routing.md"

$agents = Read-Text $agentsPath
$agentsSection = @'
## Binding Owner Routing

- 역할(role) 문서는 기본적으로 설명용이다. `task_kind` 가 mandatory owner 에 묶인 경우에만 binding contract 로 취급한다.
- 앞으로 Codex화할 프로젝트도 원래 Claude Code 프로젝트의 **서브에이전트 구조와 owner 경계**를 기본 보존해야 한다. Codex 메인 에이전트가 이를 평탄화하여 직접 수행하면 안 된다.
- 편집 전에는 항상 `task_kind`, `designated_owner`, `delegate_or_local`, `why` 를 먼저 결정한다.
- mandatory owner 가 존재하면 direct edit 를 시작하지 않는다. 현재 런타임 정책상 delegation 이 불가하면 사용자에게 delegation 승인 또는 explicit local override 를 요청한다.
- `saturation-*` 는 분석 런타임 역할이고, framework upgrade / transplant / manifest update owner 가 아니다.
- `solution-transplanter` 는 `framework-upgrade`, `target-repo-transplant`, `applied-solutions-update` 의 mandatory owner 다.

### Guarded Writes

다음 변경은 메인 에이전트가 직접 흡수하지 않는다.

- 외부 target repo 수정
- `applied-solutions.md`, `applied-projects.md` 갱신
- framework version bump
- transplanted `.claude/agents/**` 재배포

경고 문구 기본형:

`This change is owned by solution-transplanter. Delegation or explicit local override is required.`

### Command Surface

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`

'@
$agents = Insert-Before -Text $agents -Needle "## Runtime Notes" -Insert $agentsSection
$agentsGate = @'
### Transplant Completion Gate

- `solution-transplanter` 가 named owner, preserved subagent structure, guarded write, routing command 를 전제하는 솔루션을 이식하면 target repo 루트 운영 문서 세트에 binding runtime contract 를 함께 설치해야 한다.
- 이 gate 가 통과되지 않으면 상태는 완료가 아니라 `blocked` 또는 incomplete 다.

'@
$agents = Insert-Before -Text $agents -Needle "## Runtime Notes" -Insert $agentsGate
$agents = [regex]::Replace($agents, '(?m)^- `/route-check <task summary>`\r?\n(?=## Runtime Notes)', '- `/route-check <task summary>`' + [Environment]::NewLine + [Environment]::NewLine, 1)
Write-Text $agentsPath $agents

$claude = Read-Text $claudePath
$claudeSection = @'
## Binding Owner Routing (mandatory owner + 구조 보존)

역할(role) 문서는 기본적으로 설명용이다. Codex 병용 또는 외부 프로젝트 이식에서 특정 `task_kind` 가 mandatory owner 에 묶이지 않는 한, 단순 역할 문서를 binding contract 로 읽지 않는다.

### 핵심 규칙

1. **원래 Claude Code 프로젝트의 서브에이전트 구조를 보존할 것**: 앞으로 Codex화할 프로젝트는 기존 `.claude/agents/*`, 역할 분업, owner 경계를 기본 보존한다. 메인 에이전트가 이를 단일 로컬 작업으로 평탄화하면 안 된다.
2. **역할과 소유권을 분리할 것**: `saturation-*` 는 분석 런타임 역할이고, framework upgrade / transplant / manifest write owner 가 아니다.
3. **mandatory owner 작업은 delegation 기본**: `framework-upgrade`, `target-repo-transplant`, `applied-solutions-update` 는 `solution-transplanter` 소관이다.
4. **delegation 불가 시 자동 로컬 수행 금지**: 현재 런타임 정책상 delegation 이 안 되면 사용자에게 delegation 승인 또는 explicit local override 를 요청한다.

### Preflight Routing

owner-bound 작업 전에는 항상 아래 4개를 먼저 판단한다.

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

mandatory owner 가 존재하면 direct edit 를 시작하지 않는다.

### Mandatory Owner Table

| task_kind | mandatory_owner | 기본 실행 | local fallback | guarded surfaces |
|-----------|-----------------|-----------|----------------|------------------|
| `framework-upgrade` | `solution-transplanter` | delegate | delegation 불가 + 사용자 승인 시에만 | framework version bump, framework 정의 파일, registry version 행 |
| `target-repo-transplant` | `solution-transplanter` | delegate | delegation 불가 + 사용자 승인 시에만 | 외부 target repo, transplanted `.claude/agents/**`, 루트 운영 문서 재이식 |
| `applied-solutions-update` | `solution-transplanter` | delegate | delegation 불가 + 사용자 승인 시에만 | `applied-solutions.md`, `applied-projects.md`, 파생 적용 추적 |
| `saturation-domain-analysis` | `saturation-*` | local-or-delegate | maintenance owner 미연루 시 허용 | 분석 산출물과 evidence 한정 |

### Command Surface

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`

### Guarded Writes

다음 변경은 메인 에이전트가 직접 집어먹지 않는다.

- 외부 target repo 수정
- `applied-solutions.md`, `applied-projects.md` 갱신
- framework version bump
- transplanted `.claude/agents/**` 재배포

기본 경고 문구:

`This change is owned by solution-transplanter. Delegation or explicit local override is required.`

'@
$claudeGate = @'
### Transplant Completion Gate

`solution-transplanter` 가 아래 중 하나를 포함하거나 전제하는 솔루션을 target repo 에 이식하면 runtime contract installation gate 가 자동 발동한다.

- named subagents 또는 `.claude/agents/*`
- mandatory owner routing
- guarded writes
- explicit routing commands

이 경우 target repo 의 `CLAUDE.md`, `AGENTS.md` 또는 동등 루트 운영 문서에 binding runtime contract 가 실제 설치되어야 한다. 설치가 끝나지 않으면 상태는 완료가 아니라 `blocked` 또는 incomplete 다.

'@
$claude = Insert-Before -Text $claude -Needle "### Command Surface" -Insert $claudeGate
$claude = Insert-Before -Text $claude -Needle "## 작업 관리" -Insert $claudeSection
Write-Text $claudePath $claude

$executionPacket = Read-Text $executionPacketPath
$optionalFieldsBlock = @'
| `handoff_reason` | enum | `self-progress` / `followup` — 호출 맥락 분류 |
| `context_hash` | string | 원본 대화 식별자 (감사·재현용) |
| `required_reads` | array | 서브에이전트가 읽어야 할 파일 경로 (원문 위임) |
| `task_kind` | string | owner-routing 규약에서 쓰는 안정 task 분류 |
| `designated_owner` | string | 위임 또는 local fallback 전에 확정한 owner |
| `source_subagent_structure` | string | 원래 Claude 프로젝트의 역할/서브에이전트 구조 요약. Codex 변환 시 구조 보존 확인용 |
'@
$executionPacket = [regex]::Replace(
    $executionPacket,
    '\| `handoff_reason` \| enum \| `self-progress` / `followup` — 호출 맥락 분류 \|\r?\n\| `context_hash` \| string \| 원본 대화 식별자 \(감사·재현용\) \|\r?\n\| `required_reads` \| array \| 서브에이전트가 읽어야 할 파일 경로 \(원문 위임\) \|(?:\s*)\| `task_kind` \| string \| owner-routing 규약에서 쓰는 안정 task 분류 \|\r?\n\| `designated_owner` \| string \| 위임 또는 local fallback 전에 확정한 owner \|\r?\n\| `source_subagent_structure` \| string \| 원래 Claude 프로젝트의 역할/서브에이전트 구조 요약\. Codex 변환 시 구조 보존 확인용 \|',
    $optionalFieldsBlock.TrimEnd(),
    1
)
if (-not $executionPacket.Contains('| `task_kind` | string | owner-routing 규약에서 쓰는 안정 task 분류 |')) {
    $requiredReadsRow = '| `required_reads` | array | 서브에이전트가 읽어야 할 파일 경로 (원문 위임) |'
    $ownerRows = @'
| `task_kind` | string | owner-routing 규약에서 쓰는 안정 task 분류 |
| `designated_owner` | string | 위임 또는 local fallback 전에 확정한 owner |
| `source_subagent_structure` | string | 원래 Claude 프로젝트의 역할/서브에이전트 구조 요약. Codex 변환 시 구조 보존 확인용 |
'@
    $executionPacket = $executionPacket.Replace($requiredReadsRow, $requiredReadsRow + [Environment]::NewLine + $ownerRows.TrimEnd())
}

$step3 = "3. 원본 대화 로그, 파일 전체 덤프, 추측성 맥락을 **프롬프트 본문에 포함하지 않는다**"
$step4 = '4. owner-bound 작업 또는 Codex 변환 작업이면 `task_kind`, `designated_owner`, `source_subagent_structure` 를 함께 전달한다'
if ($executionPacket.Contains($step3 + $step4)) {
    $executionPacket = $executionPacket.Replace($step3 + $step4, $step3 + [Environment]::NewLine + $step4)
}
elseif (-not $executionPacket.Contains($step4)) {
    $executionPacket = $executionPacket.Replace($step3, $step3 + [Environment]::NewLine + $step4)
}
Write-Text $executionPacketPath $executionPacket

$threeTier = Read-Text $threeTierPath
$threeTier = Replace-Exact -Text $threeTier -OldValue "| **DELEGATED-OR-CONSENT** | engine-run, launch (60초+ 작업), 파일 생성, 설정 변경 | **preflight 체크** + **명시 동의** (텍스트 승인 또는 config 허용) |" -NewValue "| **DELEGATED-OR-CONSENT** | engine-run, launch (60초+ 작업), 파일 생성, 설정 변경, owner-bound manifest 갱신, transplanter 소관 이식 작업 | **preflight 체크** + **명시 동의** (텍스트 승인 또는 config 허용) |"
$threeTierBase = "4. **미분류 행동은 기본 HARD-GATE** (금지가 아닌 **승인 요구**)"
$threeTierExtra = @'
- **mandatory owner 예외 없음**: task 가 mandatory owner 에 묶여 있으면 main agent 가 이를 로컬 작업으로 평탄화할 수 없다. delegation 이 불가하면 explicit local override 승인 전까지 정지한다.
- **구조 보존 우선**: 원래 Claude 프로젝트의 서브에이전트 구조가 명시돼 있으면, Codex 병용 시 같은 owner / 역할 경계를 기본 유지한다.
'@
if ($threeTier.Contains($threeTierBase + "- **mandatory owner 예외 없음**")) {
    $threeTier = $threeTier.Replace($threeTierBase + "- **mandatory owner 예외 없음**", $threeTierBase + [Environment]::NewLine + "- **mandatory owner 예외 없음**")
}
if (-not $threeTier.Contains("- **mandatory owner 예외 없음**: task 가 mandatory owner 에 묶여 있으면 main agent 가 이를 로컬 작업으로 평탄화할 수 없다. delegation 이 불가하면 explicit local override 승인 전까지 정지한다.")) {
    $threeTier = $threeTier.Replace($threeTierBase, $threeTierBase + [Environment]::NewLine + $threeTierExtra.TrimEnd())
}
$threeTier = [regex]::Replace($threeTier, '(?m)^(4\. \*\*미분류 행동은 기본 HARD-GATE\*\* \(금지가 아닌 \*\*승인 요구\*\*\))\r?\n(?=- \*\*mandatory owner 예외 없음\*\*)', '$1' + [Environment]::NewLine + [Environment]::NewLine, 1)
Write-Text $threeTierPath $threeTier

$solutionTransplanter = Read-Text $solutionTransplanterPath
$bindingSection = @'
## Binding Owner Contract (owner 강제 + 구조 보존)

`solution-transplanter` 는 단순 추천 역할이 아니라, HarnessMaker 생태계에서 다음 task_kind 의 **mandatory owner** 다.

- `framework-upgrade`
- `target-repo-transplant`
- `applied-solutions-update`

따라서 메인 에이전트는 위 작업을 발견해도 직접 수행으로 흡수하지 않는다. 기본은 delegation 이며, 현재 런타임 정책상 delegation 이 불가하면 사용자에게 delegation 승인 또는 explicit local override 를 요청해야 한다.

또한 앞으로 Codex화할 프로젝트는 원래 Claude Code 프로젝트의 **서브에이전트 구조와 owner 경계**를 기본 보존해야 한다. transplanter 는 target 의 `.claude/agents/*`, 루트 운영 문서, slash command, manifest write owner 를 읽고 아래를 구분한다.

- 분석 런타임 역할 (`saturation-*` 등)
- 유지보수/이식 owner (`solution-transplanter` 등)
- 메인 에이전트가 직접 수행하면 안 되는 guarded surfaces

'@
$completionGateSection = @'
## Runtime Contract Installation Gate

`solution-transplanter` 가 selected solution 또는 target 구조에서 아래 신호를 발견하면, target repo 에 binding runtime contract 를 설치하는 것이 **completion gate** 가 된다.

- named subagents 또는 `.claude/agents/*`
- mandatory owner routing
- guarded writes
- explicit routing commands

이 gate 는 선택 사항이 아니다. 솔루션 파일 복사나 manifest 기록이 끝났더라도, target 루트 운영 문서 세트에 binding runtime contract 가 실제 설치되지 않았다면 상태는 `blocked` 또는 incomplete 다.

'@
$solutionTransplanter = Insert-Before -Text $solutionTransplanter -Needle "## 요약" -Insert $bindingSection
$solutionTransplanter = Insert-Before -Text $solutionTransplanter -Needle "## 요약" -Insert $completionGateSection
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '**기본 범위** (항상 전체 스캔):' -Insert @'
- `.claude/agents/*.md` 또는 명시된 역할 문서가 있으면, 역할(role)과 mandatory owner 를 분리해 기록한다. Codex 병용 시 이 구조를 보존해야 하는지 판정한다.
'@
$solutionTransplanter = Replace-Exact -Text $solutionTransplanter -OldValue '  - 루트 운영 문서 섹션 주입 또는 handoff 보존 (`CLAUDE.md`, `AGENTS.md`) + binding owner-routing contract 설치' -NewValue '  - 루트 운영 문서 섹션 주입 또는 handoff 보존 (`CLAUDE.md`, `AGENTS.md`) + binding runtime contract 설치 (selected solution 또는 target 구조가 요구할 때 필수)'
$solutionTransplanter = Insert-Before -Text $solutionTransplanter -Needle '### 0-4. 추천 리포트 생성' -Insert @'
### 0-3.5. 런타임 계약 필요 여부 분류

- 추천 또는 선택된 솔루션이 named subagents, mandatory owner, guarded writes, explicit routing commands 를 도입·전제하는지 판정한다.
- target 이 이미 이런 구조를 가지면 `runtime_contract_required=true` 로 기록한다.
- `full` 모드에서는 이 플래그가 completion gate 가 된다.

'@
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '- 충돌 리스크 (기존 applied-solutions + compositions/rules 검증)' -Insert @'
- runtime contract requirement (`required` | `not-required`)
'@
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '3. **둘 다 존재**:' -Insert @'
   - target 에 명시된 Claude-side 서브에이전트 구조가 있으면, Codex-side 문서도 같은 owner / 역할 경계를 보존한다. 메인 에이전트 평탄화는 explicit override 없이는 금지.
'@
$solutionTransplanter = Insert-Before -Text $solutionTransplanter -Needle '### 1-4. 매니페스트 기록' -Insert @'
### 1-3.5. Runtime Contract Installation Gate

- `runtime_contract_required=true` 이면 target 의 루트 운영 문서 세트(`CLAUDE.md`, `AGENTS.md` 또는 동등 문서)에 binding runtime contract 를 설치하거나 갱신한다.
- contract 에는 최소한 mandatory owner table, preflight routing, delegation fallback, guarded writes, source subagent structure preservation 이 포함되어야 한다.
- 이 설치를 끝내지 못하면 transplant 는 성공으로 닫지 않고 `blocked` 또는 incomplete 로 반환한다.

'@
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '- 구문 오류 확인 (YAML frontmatter 파싱 가능 여부)' -Insert @'
- `runtime_contract_required=true` 이면 target 루트 운영 문서 세트에 binding runtime contract 가 실제 존재해야 pass
'@
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '| **Phase 0 기록 유실** | advise-only 결과를 어디에도 안 남김 | 기본 `advise_output: harness` — 추천 품질 회귀 검토 자산 |' -Insert @'
| **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 |
'@
$solutionTransplanter = Insert-After -Text $solutionTransplanter -Needle '| **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 |' -Insert @'
| **솔루션만 복사** | framework/component 는 들어갔지만 target repo 루트 운영 문서에 binding runtime contract 가 없음 | transplant completion gate 실패로 처리하고 `blocked`/incomplete 반환 |
'@
$solutionTransplanter = [regex]::Replace($solutionTransplanter, '(?m)^- 메인 에이전트가 직접 수행하면 안 되는 guarded surfaces\r?\n(?=## Runtime Contract Installation Gate)', "- 메인 에이전트가 직접 수행하면 안 되는 guarded surfaces" + [Environment]::NewLine + [Environment]::NewLine, 1)
$solutionTransplanter = $solutionTransplanter.Replace('**기본 범위** (항상 전체 스캔):- `.claude/agents/*.md` 또는 명시된 역할 문서가 있으면, 역할(role)과 mandatory owner 를 분리해 기록한다. Codex 병용 시 이 구조를 보존해야 하는지 판정한다.', '**기본 범위** (항상 전체 스캔):' + [Environment]::NewLine + [Environment]::NewLine + '- `.claude/agents/*.md` 또는 명시된 역할 문서가 있으면, 역할(role)과 mandatory owner 를 분리해 기록한다. Codex 병용 시 이 구조를 보존해야 하는지 판정한다.')
$solutionTransplanter = $solutionTransplanter.Replace("3. **둘 다 존재**:   - target 에 명시된 Claude-side 서브에이전트 구조가 있으면, Codex-side 문서도 같은 owner / 역할 경계를 보존한다. 메인 에이전트 평탄화는 explicit override 없이는 금지.", "3. **둘 다 존재**:" + [Environment]::NewLine + "   - target 에 명시된 Claude-side 서브에이전트 구조가 있으면, Codex-side 문서도 같은 owner / 역할 경계를 보존한다. 메인 에이전트 평탄화는 explicit override 없이는 금지.")
$solutionTransplanter = $solutionTransplanter.Replace('- 충돌 리스크 (기존 applied-solutions + compositions/rules 검증)- runtime contract requirement (`required` | `not-required`)', '- 충돌 리스크 (기존 applied-solutions + compositions/rules 검증)' + [Environment]::NewLine + '- runtime contract requirement (`required` | `not-required`)')
$solutionTransplanter = $solutionTransplanter.Replace('- 구문 오류 확인 (YAML frontmatter 파싱 가능 여부)- `runtime_contract_required=true` 이면 target 루트 운영 문서 세트에 binding runtime contract 가 실제 존재해야 pass', '- 구문 오류 확인 (YAML frontmatter 파싱 가능 여부)' + [Environment]::NewLine + '- `runtime_contract_required=true` 이면 target 루트 운영 문서 세트에 binding runtime contract 가 실제 존재해야 pass')
$solutionTransplanter = $solutionTransplanter.Replace('| **Phase 0 기록 유실** | advise-only 결과를 어디에도 안 남김 | 기본 `advise_output: harness` — 추천 품질 회귀 검토 자산 || **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 |', '| **Phase 0 기록 유실** | advise-only 결과를 어디에도 안 남김 | 기본 `advise_output: harness` — 추천 품질 회귀 검토 자산 |' + [Environment]::NewLine + '| **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 |')
$solutionTransplanter = $solutionTransplanter.Replace('| **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 || **솔루션만 복사** | framework/component 는 들어갔지만 target repo 루트 운영 문서에 binding runtime contract 가 없음 | transplant completion gate 실패로 처리하고 `blocked`/incomplete 반환 |', '| **구조 평탄화** | 원래 Claude 프로젝트의 서브에이전트/owner 구조를 Codex 메인 에이전트 direct execution 으로 치환 | owner-routing contract 설치 + mandatory owner delegation 유지 |' + [Environment]::NewLine + '| **솔루션만 복사** | framework/component 는 들어갔지만 target repo 루트 운영 문서에 binding runtime contract 가 없음 | transplant completion gate 실패로 처리하고 `blocked`/incomplete 반환 |')
$solutionTransplanter = $solutionTransplanter.Replace('| **hard-coded (변경 불가)** | 복사 방식(v1.1), Phase 0/1 구조, 하네스 전수 스캔 기본, `applied-solutions-manifest` 준수, 롤백 경로 확보 의무 | 구조적 안전 — 변경 시 이식 규약 파괴 |', '| **hard-coded (변경 불가)** | 복사 방식(v1.1), Phase 0/1 구조, 하네스 전수 스캔 기본, `applied-solutions-manifest` 준수, 롤백 경로 확보 의무, runtime contract installation gate | 구조적 안전 — 변경 시 이식 규약 파괴 |')
$solutionTransplanter = $solutionTransplanter.Replace('  "transplant_summary": "[only if status==transplant-complete — list of ids + pin versions + target path]",', '  "transplant_summary": "[only if status==transplant-complete — list of ids + pin versions + target path]",' + [Environment]::NewLine + '  "completion_gate_status": "passed | not-required | blocked",')
Write-Text $solutionTransplanterPath $solutionTransplanter

$transplanterAgent = Read-Text $transplanterAgentPath
$transplanterAgentSection = @'
## Binding owner contract

- Read `components/owner-routing-contract.md` before planning a transplant that touches framework upgrades, target-repo rewrites, or manifest updates.
- Preserve the source Claude project's declared subagent structure and owner boundaries by default when preparing Codex-side operation.
- If a task belongs to a mandatory owner, do not flatten it into the main agent's local work. Return control for delegation approval or explicit local override when needed.
- If the selected solution or target structure requires a binding runtime contract, do not report success until that contract is installed in the target repo root guides.

'@
$transplanterAgent = Insert-Before -Text $transplanterAgent -Needle "## Input contract" -Insert $transplanterAgentSection
Write-Text $transplanterAgentPath $transplanterAgent

$componentRegistry = Read-Text $componentRegistryPath
$componentRegistry = Insert-After -Text $componentRegistry -Needle '| solution-transplanter | 솔루션 이식 전문가 서브에이전트 | active | 기성 외부 프로젝트 진단(Phase 0) → 솔루션 추천 → 승인 시 이식(Phase 1) 통합 에이전트. `advise-only`/`full` 모드 + 전량 복사 + 적응형 롤백(git commit-and-proceed 기본) + 신뢰도 3등급 추천. `applied-solutions-manifest` 의 첫 자동화 쓰기 주체. |' -Insert @'
| owner-routing-contract | owner 라우팅 계약 | active | 역할(role) 설명과 mandatory owner 를 분리하고, Codex 변환 시 원래 Claude 프로젝트의 서브에이전트 구조를 보존하도록 강제하는 루트 계약. |
'@
Write-Text $componentRegistryPath $componentRegistry

$actionProblem = Read-Text $actionProblemPath
$actionProblem = Insert-After -Text $actionProblem -Needle '- **직교**: `role-specialization` — 역할 구성과 행동 권한은 별개 축 (단, 관찰자 분리는 role-specialization L1/L2 결정과 연동).' -Insert @'
- **의존**: `mandatory-owner-routing` — named owner 작업은 행동 권한만으로 처리되지 않는다. 권한 체계와 별도로 owner routing contract 가 필요하다.
'@
Write-Text $actionProblemPath $actionProblem

$roleProblem = Read-Text $roleProblemPath
$roleProblem = Insert-After -Text $roleProblem -Needle '- **영향**: `user-decision-gate` (어느 역할이 사용자에게 질문을 거는가)' -Insert @'
- **직교**: `mandatory-owner-routing` (역할 팀 구성과 write ownership 는 다른 축. saturation 역할이 maintenance owner 를 자동 상속하지 않는다)
'@
Write-Text $roleProblemPath $roleProblem

$multiProject = Read-Text $multiProjectPath
$multiProject = Insert-After -Text $multiProject -Needle "- 워커는 sibling project worker 를 직접 spawn 하지 않는다. 추가 wave/분해가 필요하면 **배치 parent 에 계획만 반환** 한다" -Insert @'
- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다.
'@
$multiProject = $multiProject.Replace("- 워커는 sibling project worker 를 직접 spawn 하지 않는다. 추가 wave/분해가 필요하면 **배치 parent 에 계획만 반환** 한다- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다.", "- 워커는 sibling project worker 를 직접 spawn 하지 않는다. 추가 wave/분해가 필요하면 **배치 parent 에 계획만 반환** 한다" + [Environment]::NewLine + "- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다.")
$multiProject = Insert-After -Text $multiProject -Needle "- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다." -Insert @'
- target 이 runtime contract installation gate 대상이면, 해당 worker 가 gate 를 통과하기 전에는 batch parent 가 `approved` 또는 `verified` 로 승격하지 않는다.
'@
$multiProject = $multiProject.Replace("- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다.- target 이 runtime contract installation gate 대상이면, 해당 worker 가 gate 를 통과하기 전에는 batch parent 가 `approved` 또는 `verified` 로 승격하지 않는다.", "- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다. owner-bound work 는 해당 single-target worker 가 계속 소유한다." + [Environment]::NewLine + "- target 이 runtime contract installation gate 대상이면, 해당 worker 가 gate 를 통과하기 전에는 batch parent 가 `approved` 또는 `verified` 로 승격하지 않는다.")
$multiProject = [regex]::Replace($multiProject, '(?m)(^- source 프로젝트에 명시된 owner / 서브에이전트 구조가 있으면, batch parent 나 main agent 가 이를 평탄화하지 않는다\. owner-bound work 는 해당 single-target worker 가 계속 소유한다\.)- target ', '$1' + [Environment]::NewLine + '- target ', 1)
Write-Text $multiProjectPath $multiProject

$saturation = Read-Text $saturationPath
$saturationBoundary = @'

### Owner Boundary

이 프레임워크의 5역은 **분석 런타임 역할**이다.

- `code-analyst`, `spec-analyst`, `cross-verifier`, `completeness-overseer`, `domain-curator` 는 saturation 분석 책임만 가진다.
- framework upgrade, transplant, `applied-solutions.md` / `applied-projects.md` 갱신 같은 유지보수·이식 작업 owner 를 자동 상속하지 않는다.
- 이런 쓰기 작업은 사용처의 owner-routing contract 가 지정한 maintenance owner (예: `solution-transplanter`) 가 맡는다.

'@
$saturation = Insert-After -Text $saturation -Needle "역할 수 5개는 기본 — 도메인 복잡도 따라 4 (curator 축소) 또는 6 (추가 scope 를 1급 역할로 승격) 로 조정 가능." -Insert $saturationBoundary
Write-Text $saturationPath $saturation

$appliedSolutions = Read-Text $appliedSolutionsPath
if (-not $appliedSolutions.Contains("id: owner-routing-contract")) {
    $appliedSolutions = [regex]::Replace(
        $appliedSolutions,
        "---\r?\n\r?\n# Applied Solutions: HarnessMaker \(self\)",
@'
  - id: owner-routing-contract
    kind: component
    source_repo: <harnessmaker>
    source_path: components/owner-routing-contract.md
    pinned_version: "latest"
    applied_at: "2026-04-21"
    applied_by: <self>
---

# Applied Solutions: HarnessMaker (self)
'@,
        1
    )
}

$appliedSolutions = $appliedSolutions.Replace(
    '- **참고**: 포함되지 않은 솔루션(async-collab, control-plane, context-loading, role-specialization, call-site-provider-routing, competency-builder, design-reviewer-subagent, design-self-critique, execution-packet, session-lease, skill-unit, three-tier-blocking, solution-transplanter)은 현 시점 HarnessMaker 자신이 실제 운영 중이 아닌 ""관리·연구 대상"". 향후 실제 적용 시 엔트리 추가. `solution-transplanter` 는 첫 외부 이식 수행 시 self 엔트리 추가 판단.',
    '- **참고**: 포함되지 않은 솔루션(async-collab, control-plane, context-loading, role-specialization, call-site-provider-routing, competency-builder, design-reviewer-subagent, design-self-critique, execution-packet, session-lease, skill-unit, three-tier-blocking, solution-transplanter)은 현 시점 HarnessMaker 자신이 실제 운영 중이 아닌 ""관리·연구 대상"". 향후 실제 적용 시 엔트리 추가. `solution-transplanter` 는 첫 외부 이식 수행 시 self 엔트리 추가 판단.' + [Environment]::NewLine + '- **2026-04-21**: `owner-routing-contract` 를 self 적용. 역할 설명과 mandatory owner 를 분리하고, 앞으로 Codex화할 프로젝트도 원래 Claude Code 서브에이전트 구조를 보존하도록 루트 계약에 편입.'
)
Write-Text $appliedSolutionsPath $appliedSolutions

$handoff = Read-Text $handoffPath
$handoff = Replace-Exact -Text $handoff -OldValue '- active milestone: HarnessMaker 를 Claude Code 와 Codex 양쪽에서 끊김 없이 운영할 수 있도록 dual-runtime continuity 를 정리 중.' -NewValue '- active milestone: HarnessMaker 와 향후 Codex화 대상 프로젝트들에 binding owner-routing 과 subagent structure preservation 을 심는 중.'
$handoff = Replace-Exact -Text $handoff -OldValue '- last meaningful change: `AGENTS.md`, `RunCodex*.bat`, `frameworks/multi-project-rollout`, `solution-transplanter` v1.2 가 이미 추가되었고, 이번 단계에서 세션 handoff 자산과 switchback 운영 경로를 명시한다.' -NewValue '- last meaningful change: dual-runtime continuity 위에 binding owner-routing contract 를 추가하고, `solution-transplanter` / saturation 역할 / manifest write ownership 경계를 명시한다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- open blockers: `SESSION-HANDOFF.md` 는 추가되었지만 실제 switchback verdict 는 다음 의미 있는 Claude↔Codex 왕복 1회 이상 확인 후 `pass` 또는 `pass-with-gap` 으로 갱신해야 한다.' -NewValue '- open blockers: 실제 switchback verification report 는 아직 없고, 새 owner-routing 규약이 fsf2 같은 외부 대상 이식 경로에서 검증되어야 한다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- actively changing: `CLAUDE.md`, `AGENTS.md`, `SESSION-HANDOFF.md`, `components/solution-transplanter.md`, `.claude/agents/solution-transplanter.md`, `frameworks/multi-project-rollout/**`, `frameworks/registry.md`, `compositions/rules.md`' -NewValue '- actively changing: `CLAUDE.md`, `AGENTS.md`, `SESSION-HANDOFF.md`, `components/owner-routing-contract.md`, `components/solution-transplanter.md`, `.claude/agents/solution-transplanter.md`, `components/execution-packet.md`, `components/three-tier-blocking.md`, `frameworks/multi-project-rollout/**`, `frameworks/saturation-driven-analysis/definition.md`'
$handoff = Replace-Exact -Text $handoff -OldValue '- runtime 운영 규칙을 바꾸면 `CLAUDE.md` 와 `AGENTS.md` 를 함께 갱신하고, 세션을 멈추기 전 이 파일의 milestone / files in motion / blockers / next actions 를 업데이트한다.' -NewValue '- runtime 운영 규칙을 바꾸면 `CLAUDE.md`, `AGENTS.md`, `components/owner-routing-contract.md` 를 함께 갱신하고, 세션을 멈추기 전 이 파일의 milestone / files in motion / blockers / next actions 를 업데이트한다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- validation still required: dual-runtime 운영 문서나 런처를 수정한 뒤에는 아래 Switchback Smoke 를 1회 수행한다.' -NewValue '- validation still required: dual-runtime 운영 문서나 owner-routing 규약을 수정한 뒤에는 아래 Switchback Smoke 와 transplanter owner-routing smoke 를 최소 1회 수행한다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- Claude-only caveats: `.claude/settings.json` 과 `.claude/hooks/*` 는 여전히 Claude 측 authoritative surface 다. Codex 병용화 과정에서 삭제하거나 의미를 축소하지 않는다.' -NewValue '- Claude-only caveats: `.claude/settings.json` 과 `.claude/hooks/*` 는 여전히 Claude 측 authoritative surface 다. Codex 병용화 과정에서 삭제하거나 의미를 축소하지 않는다. 또한 Claude-side 역할 문서를 Codex 메인 에이전트 direct execution 허가로 오해하지 않는다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- Codex-only caveats: Codex 는 `AGENTS.md` 를 진입점으로 삼고, 그 다음 `CLAUDE.md` 로 handoff 받는다. `AGENTS.md` 를 독립 정책 트리처럼 drift 시키지 않는다.' -NewValue '- Codex-only caveats: Codex 는 `AGENTS.md` 를 진입점으로 삼고, 그 다음 `CLAUDE.md` 로 handoff 받는다. `AGENTS.md` 를 독립 정책 트리처럼 drift 시키지 않으며, owner-bound 작업을 main agent 로 평탄화하지 않는다.'
$handoff = Replace-Exact -Text $handoff -OldValue '- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. 둘 중 한쪽 진입점이나 권한 규칙이 바뀌면 이 파일에 즉시 적는다.' -NewValue '- permission or launcher caveats: Claude 는 `RunClaude*.bat`, Codex 는 `RunCodex*.bat` 를 기본 진입점으로 사용한다. 둘 중 한쪽 진입점이나 권한 규칙이 바뀌면 이 파일에 즉시 적고, delegation 불가 시 explicit local override 없이는 owner-bound 변경을 진행하지 않는다.'
Write-Text $handoffPath $handoff

$ownerRoutingComponent = @'
---
solves:
  - mandatory-owner-routing
version: "1.0"
---

# 컴포넌트: Owner Routing Contract (역할/소유권 분리 + binding owner 계약) [ACTIVE]

## 포지셔닝

역할(role) 설명과 실제 쓰기 owner 를 분리하는 루트 계약이다. Claude Code 프로젝트를 Codex 와 병용하거나 외부 프로젝트에 솔루션을 이식할 때, 기존 서브에이전트 구조를 **설명 문서**가 아니라 **실행 계약**으로 보존하게 만든다.

## 요약

이 계약은 다음을 강제한다.

1. 역할 문서는 기본적으로 descriptive 이다.
2. 특정 `task_kind` 가 `mandatory_owner` 에 묶이면 메인 에이전트는 direct edit 를 시작할 수 없다.
3. 앞으로 Codex화할 프로젝트도 원래 Claude Code 프로젝트의 서브에이전트 구조와 owner 경계를 기본 보존한다.
4. delegation 이 불가하면 사용자 승인 후 local fallback 만 허용한다.

## 필수 섹션

### 1. Owner Classes

- 분석 런타임 역할
- 유지보수/이식 owner
- 특정 역할이 maintenance owner 가 아님을 명시하는 부정 규칙

### 2. Task Routing Table

최소 컬럼:

| 컬럼 | 의미 |
|------|------|
| `task_kind` | 안정적인 작업 분류 |
| `mandatory_owner` | 반드시 맡아야 하는 owner (`none` 허용) |
| `default_execution` | `delegate`, `local`, `delegate-preferred` 등 |
| `local_fallback` | local 수행이 허용되는 조건 |
| `guarded_surfaces` | 경고 또는 중단해야 할 파일/행동 |
| `notes` | 예외와 추가 설명 |

### 3. Preflight Routing

편집 전 메인 에이전트는 아래 4개를 반드시 먼저 적는다.

- `task_kind`
- `designated_owner`
- `delegate_or_local`
- `why`

### 4. Structure Preservation

Codex화 대상 프로젝트에 기존 Claude Code 서브에이전트 구조가 있으면:

- `.claude/agents/*`, 역할 문서, slash command, owner 분업을 먼저 읽는다.
- Codex-side 문서와 실행 경로도 같은 owner / 역할 경계를 기본 보존한다.
- explicit replacement 승인 없이는 메인 에이전트 평탄화 금지.

### 5. Fallback Rule

mandatory owner 가 있지만 현 런타임 정책상 delegation 이 불가하면:

1. 편집 전에 정지
2. delegation 승인 또는 explicit local override 요청
3. 승인된 local fallback 이면 handoff / verification 자산에 기록

### 6. Command Surface

- `/delegate solution-transplanter <task>`
- `/transplant-upgrade <solution-or-framework> <target-repo>`
- `/route-check <task summary>`

### 7. Transplant Completion Gate

`solution-transplanter` 또는 동등 maintenance owner 가 아래 중 하나를 포함하는 솔루션을 target repo 에 이식하면, binding runtime contract 설치가 completion gate 가 된다.

- named subagents 또는 `.claude/agents/*`
- mandatory owner routing
- guarded writes
- explicit routing commands

이 gate 가 통과되지 않으면 솔루션 복사나 manifest 갱신이 끝났어도 상태는 `blocked` 또는 incomplete 다.

## HarnessMaker 기본 해석

| task_kind | mandatory_owner | 의미 |
|-----------|-----------------|------|
| `framework-upgrade` | `solution-transplanter` | 프레임워크 버전업·재이식·정의 동기화 |
| `target-repo-transplant` | `solution-transplanter` | 외부 target repo 수정, 루트 운영 문서 주입 |
| `applied-solutions-update` | `solution-transplanter` | `applied-solutions.md`, `applied-projects.md` 갱신 |
| `saturation-domain-analysis` | `saturation-*` | 분석 런타임 역할. maintenance owner 아님 |

## 관련

- `components/solution-transplanter.md`
- `components/three-tier-blocking.md`
- `components/execution-packet.md`
- `frameworks/multi-project-rollout/definition.md`
'@
Write-Text $ownerRoutingComponentPath $ownerRoutingComponent

$ownerRoutingProblem = @'
---
id: mandatory-owner-routing
name: mandatory owner routing
status: active
importance: high
impact: broad
maturity: 1
created: 2026-04-21
---

## 질문

역할 문서를 descriptive 정보가 아니라 binding owner 계약으로 어떻게 승격하는가? 특히 Claude Code 프로젝트를 Codex 와 병용하거나 외부 프로젝트로 이식할 때, 원래 서브에이전트 구조와 owner 경계를 어떻게 보존하는가?

## 선택지 카탈로그

| 옵션 | 축 | 출처 |
|------|-----|------|
| 루트 운영 문서에 mandatory owner table 명시 | 루트 계약 | HarnessMaker owner-routing contract |
| `task_kind` / `designated_owner` / `delegate_or_local` / `why` preflight 강제 | 라우팅 게이트 | 본 문제의 기본 절차 |
| delegation 불가 시 explicit local override 요구 | fallback 규약 | Codex/Claude 런타임 제약 |
| 원래 Claude 프로젝트의 서브에이전트 구조 보존 | 구조 보존 | HarnessMaker transplanter 운영 요구 |

## 현재 솔루션

- `components/owner-routing-contract` — 역할/owner 분리 + mandatory owner table + 구조 보존 규약

## 교차 관계

- **직교**: `role-specialization` — 역할 팀 구성과 write ownership 는 다른 축
- **의존**: `action-authorization` — owner-bound 작업은 권한 게이트와 함께 작동
- **영향**: `multi-project-rollout-consistency` — batch parent 가 project worker ownership 을 흡수하지 않게 한다

## 상태 결정 근거

- `status: active` — 다양한 하네스에서 반복되는 문제이며, 구체 owner 는 프로젝트마다 다를 수 있음
- `importance: high` — 잘못 설계하면 main agent 평탄화로 구조 drift 발생
- `impact: broad` — Claude-only, Claude+Codex, 외부 이식 모두 영향
- `maturity: 1` — 본 repo와 Codex 병용 이슈에서 직접 관찰된 문제를 토대로 정리
'@
Write-Text $ownerRoutingProblemPath $ownerRoutingProblem
