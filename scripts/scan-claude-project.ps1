[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProjectPath,

    [string]$ReportsDirectory,

    [string]$ReportStem
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ReportsDirectory)) {
    $ReportsDirectory = Join-Path $PSScriptRoot "..\reports"
}

$IgnoredPathSegments = @(
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    "dist",
    "build",
    ".next",
    "coverage",
    "vendor",
    ".venv",
    "venv",
    "env",
    "__pycache__",
    ".idea",
    ".vscode",
    "out",
    "tmp"
)

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
}

function Resolve-OutputDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        return (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    }

    $created = New-Item -ItemType Directory -Path $Path -Force
    return $created.FullName
}

function New-ReportStemValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [string]$Override
    )

    if (-not [string]::IsNullOrWhiteSpace($Override)) {
        return $Override.Trim()
    }

    $leaf = Split-Path -Path $ProjectRoot -Leaf
    if ([string]::IsNullOrWhiteSpace($leaf)) {
        $leaf = "project"
    }

    $slug = ($leaf.ToLowerInvariant() -replace "[^a-z0-9]+", "-").Trim("-")
    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = "project"
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    return "$slug-$timestamp"
}

function Get-RelativeUnixPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $normalizedBase = (Resolve-ExistingPath -Path $BasePath).TrimEnd("\", "/") + "\"
    $normalizedTarget = Resolve-ExistingPath -Path $TargetPath
    $baseUri = New-Object System.Uri($normalizedBase)
    $targetUri = New-Object System.Uri($normalizedTarget)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return ([System.Uri]::UnescapeDataString($relativeUri.ToString()) -replace "\\", "/")
}

function Test-IgnoredRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $segments = $RelativePath -split "[/\\]"
    foreach ($segment in $segments) {
        if ($IgnoredPathSegments -contains $segment) {
            return $true
        }
    }

    return $false
}

function Get-FileLineCount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [int](Get-Content -LiteralPath $Path -ErrorAction Stop | Measure-Object -Line).Lines
}

function Get-MarkdownHeading {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    foreach ($line in Get-Content -LiteralPath $Path -TotalCount 40 -ErrorAction Stop) {
        if ($line -match "^\s*#\s+(.+?)\s*$") {
            return $matches[1].Trim()
        }
    }

    return $null
}

function Get-ScriptShell {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    switch ($File.Extension.ToLowerInvariant()) {
        ".ps1" { return "powershell" }
        ".bat" { return "cmd" }
        ".cmd" { return "cmd" }
        ".sh" {
            try {
                $firstLine = Get-Content -LiteralPath $File.FullName -TotalCount 1 -ErrorAction Stop | Select-Object -First 1
                if ($firstLine -match "bash") {
                    return "bash"
                }

                if ($firstLine -match "zsh") {
                    return "zsh"
                }
            }
            catch {
                return "sh"
            }

            return "sh"
        }
        default { return "unknown" }
    }
}

function Get-ProjectType {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $types = [System.Collections.Generic.List[string]]::new()

    $manifests = @(
        @{ Path = "package.json"; Label = "Node.js" },
        @{ Path = "pnpm-workspace.yaml"; Label = "Node.js workspace" },
        @{ Path = "pyproject.toml"; Label = "Python" },
        @{ Path = "requirements.txt"; Label = "Python" },
        @{ Path = "Cargo.toml"; Label = "Rust" },
        @{ Path = "go.mod"; Label = "Go" },
        @{ Path = "Gemfile"; Label = "Ruby" },
        @{ Path = "composer.json"; Label = "PHP" },
        @{ Path = "mix.exs"; Label = "Elixir" },
        @{ Path = "pom.xml"; Label = "Java" },
        @{ Path = "build.gradle"; Label = "Java/Gradle" },
        @{ Path = "build.gradle.kts"; Label = "Java/Gradle" }
    )

    foreach ($manifest in $manifests) {
        $manifestPath = Join-Path $ProjectRoot $manifest.Path
        if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
            [void]$types.Add($manifest.Label)
        }
    }

    $dotNetProjects = @(
        Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @(".sln", ".csproj") } |
        Select-Object -First 1
    )
    if ($dotNetProjects.Count -gt 0) {
        [void]$types.Add(".NET")
    }

    if ($types.Count -eq 0) {
        return @("unknown")
    }

    return $types | Sort-Object -Unique
}

function Get-JsonTopLevelKeys {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $jsonObject = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $keys = @($jsonObject.PSObject.Properties.Name | Sort-Object -Unique)
        return [PSCustomObject]@{
            parse_status = "parsed"
            keys         = $keys
        }
    }
    catch {
        return [PSCustomObject]@{
            parse_status = "failed"
            keys         = @()
            error        = $_.Exception.Message
        }
    }
}

function Get-TomlSettingPresence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    try {
        return [bool](Select-String -LiteralPath $Path -Pattern $Pattern -Quiet -ErrorAction Stop)
    }
    catch {
        return $false
    }
}

function Format-MarkdownValue {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $Value
    )

    if ($null -eq $Value) {
        return "-"
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        $Value = @($Value | ForEach-Object { [string]$_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ", "
    }

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return "-"
    }

    return $text.Replace("|", "\|").Replace("`r", "").Replace("`n", "<br>")
}

function Format-Code {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "-"
    }

    return ('`' + $Value + '`')
}

function ConvertTo-MarkdownTable {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Rows,

        [Parameter(Mandatory = $true)]
        [string[]]$Columns
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.Add("| " + (($Columns | ForEach-Object { Format-MarkdownValue $_ }) -join " | ") + " |")
    [void]$lines.Add("| " + (($Columns | ForEach-Object { "---" }) -join " | ") + " |")

    foreach ($row in $Rows) {
        $values = foreach ($column in $Columns) {
            Format-MarkdownValue $row.$column
        }

        [void]$lines.Add("| " + ($values -join " | ") + " |")
    }

    return $lines -join "`n"
}

function Get-ScopedFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [string[]]$RelativeDirectories,

        [Parameter(Mandatory = $true)]
        [string[]]$Extensions,

        [int]$MaxFileSizeBytes = 262144
    )

    $unique = @{}

    foreach ($relativeDirectory in $RelativeDirectories) {
        $directoryPath = if ($relativeDirectory -eq ".") { $ProjectRoot } else { Join-Path $ProjectRoot $relativeDirectory }
        if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $directoryPath -Recurse -File -Force -ErrorAction SilentlyContinue) {
            $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
            if (Test-IgnoredRelativePath -RelativePath $relativePath) {
                continue
            }

            if ($Extensions.Count -gt 0 -and ($Extensions -notcontains $file.Extension.ToLowerInvariant())) {
                continue
            }

            if ($file.Length -gt $MaxFileSizeBytes) {
                continue
            }

            $unique[$file.FullName] = $file
        }
    }

    return @($unique.Values | Sort-Object FullName)
}

function Add-RelevantFile {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Registry,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [int]$Lines
    )

    if (-not $Registry.ContainsKey($Path)) {
        $Registry[$Path] = $Lines
    }
}

function Add-UniqueObject {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory = $true)]
        [hashtable]$Seen,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Value
    )

    if (-not $Seen.ContainsKey($Key)) {
        [void]$Collection.Add($Value)
        $Seen[$Key] = $true
    }
}

function Get-WrapperScripts {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = @{}
    $candidateFiles = Get-ScopedFiles -ProjectRoot $ProjectRoot -RelativeDirectories @(".", "scripts", "bin", "tools") -Extensions @(".ps1", ".sh", ".bat", ".cmd")

    foreach ($file in $candidateFiles) {
        if ($file.BaseName -match "^(scan|plan|apply|verify|regenerate)-") {
            continue
        }

        try {
            $matchesClaudeRuntime = Select-String -LiteralPath $file.FullName -Pattern "claude|\.claude|anthropic" -Quiet -ErrorAction Stop
        }
        catch {
            $matchesClaudeRuntime = $false
        }

        if (-not $matchesClaudeRuntime) {
            continue
        }

        $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
        $lines = Get-FileLineCount -Path $file.FullName
        $key = "wrapper::$relativePath"
        $value = [PSCustomObject]@{
            path   = $relativePath
            shell  = Get-ScriptShell -File $file
            lines  = $lines
            reason = "content references Claude runtime"
        }

        Add-UniqueObject -Collection $findings -Seen $seen -Key $key -Value $value
    }

    return $findings
}

function Get-RootCodexGuides {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = @{}

    foreach ($fileName in @("AGENTS.md", "CODEX.md")) {
        $fullPath = Join-Path $ProjectRoot $fileName
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            continue
        }

        $lineCount = Get-FileLineCount -Path $fullPath
        $key = "codex-guide::$fileName"
        $value = [PSCustomObject]@{
            path  = $fileName
            title = (Get-MarkdownHeading -Path $fullPath)
            lines = $lineCount
        }

        Add-UniqueObject -Collection $findings -Seen $seen -Key $key -Value $value
    }

    return $findings
}

function Get-ProjectCodexConfigFindings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $configPath = Join-Path $ProjectRoot ".codex\config.toml"
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        return $findings
    }

    $lineCount = Get-FileLineCount -Path $configPath
    [void]$findings.Add([PSCustomObject]@{
            path                    = ".codex/config.toml"
            developer_instructions  = if (Get-TomlSettingPresence -Path $configPath -Pattern '(^|\s)developer_instructions\s*=') { "present" } else { "absent" }
            model_instructions_file = if (Get-TomlSettingPresence -Path $configPath -Pattern '(^|\s)model_instructions_file\s*=') { "present" } else { "absent" }
            profile                 = if (Get-TomlSettingPresence -Path $configPath -Pattern '(^|\s)profile\s*=') { "present" } else { "absent" }
            lines                   = $lineCount
        })

    return $findings
}

function Get-RuntimeLaunchers {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = @{}
    $candidateFiles = Get-ScopedFiles -ProjectRoot $ProjectRoot -RelativeDirectories @(".", "scripts", "bin", "tools") -Extensions @(".ps1", ".sh", ".bat", ".cmd")

    foreach ($file in $candidateFiles) {
        if ($file.BaseName -match "^(scan|plan|apply|verify|regenerate)-") {
            continue
        }

        $looksLikeLauncher =
            ($file.BaseName -match "(?i)(run|launch|start|open|shell|console)") -or
            (($file.Directory.FullName -eq $ProjectRoot) -and ($file.BaseName -match "(?i)^(claude|codex)$"))

        if (-not $looksLikeLauncher) {
            continue
        }

        $runtime = $null
        if ($file.BaseName -match "(?i)claude") {
            $runtime = "claude"
        }

        if ($file.BaseName -match "(?i)codex") {
            if ($null -ne $runtime) {
                $runtime = "claude+codex"
            }
            else {
                $runtime = "codex"
            }
        }

        if ([string]::IsNullOrWhiteSpace($runtime)) {
            continue
        }

        $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        $key = "launcher::$relativePath"
        $value = [PSCustomObject]@{
            path    = $relativePath
            runtime = $runtime
            shell   = Get-ScriptShell -File $file
            lines   = $lineCount
            reason  = "filename suggests runtime entrypoint"
        }

        Add-UniqueObject -Collection $findings -Seen $seen -Key $key -Value $value
    }

    return $findings
}

function Get-SessionHandoffArtifacts {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = @{}
    $rootFiles = Get-ChildItem -LiteralPath $ProjectRoot -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLowerInvariant() -in @(".md", ".txt") }

    foreach ($file in $rootFiles) {
        if ($file.Name -notmatch "(?i)(session[-_]?handoff|next[-_]?session|handoff)") {
            continue
        }

        $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        $key = "handoff::$relativePath"
        $value = [PSCustomObject]@{
            path   = $relativePath
            title  = (Get-MarkdownHeading -Path $file.FullName)
            lines  = $lineCount
            reason = "filename suggests durable handoff note"
        }

        Add-UniqueObject -Collection $findings -Seen $seen -Key $key -Value $value
    }

    foreach ($relativeDirectory in @("docs", "instructions")) {
        $directoryPath = Join-Path $ProjectRoot $relativeDirectory
        if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $directoryPath -Recurse -File -Force -ErrorAction SilentlyContinue) {
            if ($file.Extension.ToLowerInvariant() -notin @(".md", ".txt")) {
                continue
            }

            if ($file.Name -notmatch "(?i)(session[-_]?handoff|next[-_]?session|handoff)") {
                continue
            }

            $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
            $lineCount = Get-FileLineCount -Path $file.FullName
            $key = "handoff::$relativePath"
            $value = [PSCustomObject]@{
                path   = $relativePath
                title  = (Get-MarkdownHeading -Path $file.FullName)
                lines  = $lineCount
                reason = "filename suggests durable handoff note"
            }

            Add-UniqueObject -Collection $findings -Seen $seen -Key $key -Value $value
        }
    }

    return $findings
}

function Get-RuntimeDocs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $docs = [System.Collections.Generic.List[object]]::new()
    $seen = @{}
    $keywords = "claude|codex|sandbox|approval|permission|permissions|hook|agent|skill|handoff|session|launcher|entrypoint|owner|delegate|delegation|task_kind|designated_owner|route|transplant|fallback"

    $rootMarkdownFiles = Get-ChildItem -LiteralPath $ProjectRoot -File -Force -Filter *.md -ErrorAction SilentlyContinue
    foreach ($file in $rootMarkdownFiles) {
        $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
        if (Test-IgnoredRelativePath -RelativePath $relativePath) {
            continue
        }

        try {
            $matchesRuntime = Select-String -LiteralPath $file.FullName -Pattern $keywords -Quiet -ErrorAction Stop
        }
        catch {
            $matchesRuntime = $false
        }

        if (-not $matchesRuntime) {
            continue
        }

        $key = "doc::$relativePath"
        $value = [PSCustomObject]@{
            path   = $relativePath
            title  = (Get-MarkdownHeading -Path $file.FullName)
            lines  = Get-FileLineCount -Path $file.FullName
            focus  = "runtime instructions"
        }

        Add-UniqueObject -Collection $docs -Seen $seen -Key $key -Value $value
    }

    foreach ($directory in @("docs", ".github", "instructions")) {
        $directoryPath = Join-Path $ProjectRoot $directory
        if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $directoryPath -Recurse -File -Force -Filter *.md -ErrorAction SilentlyContinue) {
            $relativePath = Get-RelativeUnixPath -BasePath $ProjectRoot -TargetPath $file.FullName
            if (Test-IgnoredRelativePath -RelativePath $relativePath) {
                continue
            }

            try {
                $matchesRuntime = Select-String -LiteralPath $file.FullName -Pattern $keywords -Quiet -ErrorAction Stop
            }
            catch {
                $matchesRuntime = $false
            }

            if (-not $matchesRuntime) {
                continue
            }

            $key = "doc::$relativePath"
            $value = [PSCustomObject]@{
                path   = $relativePath
                title  = (Get-MarkdownHeading -Path $file.FullName)
                lines  = Get-FileLineCount -Path $file.FullName
                focus  = "runtime instructions"
            }

            Add-UniqueObject -Collection $docs -Seen $seen -Key $key -Value $value
        }
    }

    return $docs
}

function Get-FileEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items,

        [Parameter(Mandatory = $true)]
        [string]$PropertyName
    )

    if (-not $Items -or $Items.Count -eq 0) {
        return "-"
    }

    return @(
        $Items |
        ForEach-Object {
            if ($_.PSObject.Properties.Name -contains $PropertyName) {
                $propertyValue = [string]($_.$PropertyName)
                if (-not [string]::IsNullOrWhiteSpace($propertyValue)) {
                    Format-Code $propertyValue
                }
            }
        }
    ) -join ", "
}

function Get-DocMatchPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot,

        [Parameter(Mandatory = $true)]
        [object[]]$Docs,

        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    $paths = [System.Collections.Generic.List[string]]::new()
    $seen = @{}

    foreach ($doc in $Docs) {
        if (-not ($doc.PSObject.Properties.Name -contains "path")) {
            continue
        }

        $docPath = Join-Path $ProjectRoot ($doc.path -replace "/", "\")
        try {
            $matched = Select-String -LiteralPath $docPath -Pattern $Pattern -Quiet -ErrorAction Stop
        }
        catch {
            $matched = $false
        }

        if (-not $matched) {
            continue
        }

        if (-not $seen.ContainsKey($doc.path)) {
            [void]$paths.Add($doc.path)
            $seen[$doc.path] = $true
        }
    }

    return @($paths)
}

function Add-Risk {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory = $true)]
        [hashtable]$Seen,

        [Parameter(Mandatory = $true)]
        [string]$Category,

        [Parameter(Mandatory = $true)]
        [string]$Severity,

        [Parameter(Mandatory = $true)]
        [string]$Surface,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$Evidence
    )

    $key = "${Category}::${Surface}::${Description}"
    $value = [PSCustomObject]@{
        category    = $Category
        severity    = $Severity
        surface     = $Surface
        description = $Description
        evidence    = $Evidence
    }

    Add-UniqueObject -Collection $Collection -Seen $Seen -Key $key -Value $value
}

function Add-EditArea {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory = $true)]
        [hashtable]$Seen,

        [Parameter(Mandatory = $true)]
        [string]$Category,

        [Parameter(Mandatory = $true)]
        [string]$Target,

        [Parameter(Mandatory = $true)]
        [string]$Rationale,

        [Parameter(Mandatory = $true)]
        [string]$Evidence
    )

    $key = "${Category}::${Target}"
    $value = [PSCustomObject]@{
        category  = $Category
        target    = $Target
        rationale = $Rationale
        evidence  = $Evidence
    }

    Add-UniqueObject -Collection $Collection -Seen $Seen -Key $key -Value $value
}

function Add-MatrixRow {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Collection,

        [Parameter(Mandatory = $true)]
        [hashtable]$Seen,

        [Parameter(Mandatory = $true)]
        [string]$Axis,

        [Parameter(Mandatory = $true)]
        [string]$SourceRuntime,

        [Parameter(Mandatory = $true)]
        [string]$TargetRuntime,

        [Parameter(Mandatory = $true)]
        [string]$NormalizationStrategy,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [string]$Notes
    )

    $key = "${Axis}::${SourceRuntime}"
    $value = [PSCustomObject]@{
        axis                   = $Axis
        source_runtime         = $SourceRuntime
        target_runtime         = $TargetRuntime
        normalization_strategy = $NormalizationStrategy
        status                 = $Status
        notes                  = $Notes
    }

    Add-UniqueObject -Collection $Collection -Seen $Seen -Key $key -Value $value
}

$projectRoot = Resolve-ExistingPath -Path $ProjectPath
$reportsRoot = Resolve-OutputDirectory -Path $ReportsDirectory
$reportStemValue = New-ReportStemValue -ProjectRoot $projectRoot -Override $ReportStem
$generatedAt = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$generatedDate = Get-Date -Format "yyyy-MM-dd"

$relevantFiles = @{}

$rootPolicyFile = $null
$rootPolicyPath = Join-Path $projectRoot "CLAUDE.md"
if (Test-Path -LiteralPath $rootPolicyPath -PathType Leaf) {
    $rootPolicyLines = Get-FileLineCount -Path $rootPolicyPath
    Add-RelevantFile -Registry $relevantFiles -Path $rootPolicyPath -Lines $rootPolicyLines
    $rootPolicyFile = [PSCustomObject]@{
        path  = "CLAUDE.md"
        title = (Get-MarkdownHeading -Path $rootPolicyPath)
        lines = $rootPolicyLines
    }
}

$rootCodexGuides = @(Get-RootCodexGuides -ProjectRoot $projectRoot)
foreach ($rootCodexGuide in $rootCodexGuides) {
    $absolutePath = Join-Path $projectRoot ($rootCodexGuide.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $rootCodexGuide.lines
}

$projectCodexConfigFindings = @(Get-ProjectCodexConfigFindings -ProjectRoot $projectRoot)
foreach ($projectCodexConfig in $projectCodexConfigFindings) {
    $absolutePath = Join-Path $projectRoot ($projectCodexConfig.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $projectCodexConfig.lines
}

$settingsFindings = [System.Collections.Generic.List[object]]::new()
$claudeDirectory = Join-Path $projectRoot ".claude"
if (Test-Path -LiteralPath $claudeDirectory -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $claudeDirectory -File -Force -Filter "settings*.json" -ErrorAction SilentlyContinue) {
        $relativePath = Get-RelativeUnixPath -BasePath $projectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        $jsonSummary = Get-JsonTopLevelKeys -Path $file.FullName
        Add-RelevantFile -Registry $relevantFiles -Path $file.FullName -Lines $lineCount

        [void]$settingsFindings.Add([PSCustomObject]@{
                path         = $relativePath
                parse_status = $jsonSummary.parse_status
                top_level    = if ($jsonSummary.keys.Count -gt 0) { $jsonSummary.keys -join ", " } else { "-" }
                lines        = $lineCount
                error        = if ($jsonSummary.PSObject.Properties.Name -contains "error") { $jsonSummary.error } else { "-" }
            })
    }
}

$hooksFindings = [System.Collections.Generic.List[object]]::new()
$hooksDirectory = Join-Path $claudeDirectory "hooks"
if (Test-Path -LiteralPath $hooksDirectory -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $hooksDirectory -Recurse -File -Force -ErrorAction SilentlyContinue) {
        $relativePath = Get-RelativeUnixPath -BasePath $projectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        Add-RelevantFile -Registry $relevantFiles -Path $file.FullName -Lines $lineCount

        [void]$hooksFindings.Add([PSCustomObject]@{
                path  = $relativePath
                shell = Get-ScriptShell -File $file
                lines = $lineCount
            })
    }
}

$agentsFindings = [System.Collections.Generic.List[object]]::new()
$agentsDirectory = Join-Path $claudeDirectory "agents"
if (Test-Path -LiteralPath $agentsDirectory -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $agentsDirectory -Recurse -File -Force -Filter *.md -ErrorAction SilentlyContinue) {
        $relativePath = Get-RelativeUnixPath -BasePath $projectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        Add-RelevantFile -Registry $relevantFiles -Path $file.FullName -Lines $lineCount

        [void]$agentsFindings.Add([PSCustomObject]@{
                path  = $relativePath
                title = (Get-MarkdownHeading -Path $file.FullName)
                lines = $lineCount
            })
    }
}

$skillsFindings = [System.Collections.Generic.List[object]]::new()
$skillsDirectory = Join-Path $claudeDirectory "skills"
if (Test-Path -LiteralPath $skillsDirectory -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $skillsDirectory -Recurse -File -Force -Filter SKILL.md -ErrorAction SilentlyContinue) {
        $relativePath = Get-RelativeUnixPath -BasePath $projectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        Add-RelevantFile -Registry $relevantFiles -Path $file.FullName -Lines $lineCount

        [void]$skillsFindings.Add([PSCustomObject]@{
                path  = $relativePath
                title = (Get-MarkdownHeading -Path $file.FullName)
                lines = $lineCount
            })
    }
}

$commandsFindings = [System.Collections.Generic.List[object]]::new()
$commandsDirectory = Join-Path $claudeDirectory "commands"
if (Test-Path -LiteralPath $commandsDirectory -PathType Container) {
    foreach ($file in Get-ChildItem -LiteralPath $commandsDirectory -Recurse -File -Force -Filter *.md -ErrorAction SilentlyContinue) {
        $relativePath = Get-RelativeUnixPath -BasePath $projectRoot -TargetPath $file.FullName
        $lineCount = Get-FileLineCount -Path $file.FullName
        Add-RelevantFile -Registry $relevantFiles -Path $file.FullName -Lines $lineCount

        [void]$commandsFindings.Add([PSCustomObject]@{
                path  = $relativePath
                title = (Get-MarkdownHeading -Path $file.FullName)
                lines = $lineCount
            })
    }
}

$wrapperScripts = @(Get-WrapperScripts -ProjectRoot $projectRoot)
foreach ($wrapperScript in $wrapperScripts) {
    $absolutePath = Join-Path $projectRoot ($wrapperScript.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $wrapperScript.lines
}

$runtimeLaunchers = @(Get-RuntimeLaunchers -ProjectRoot $projectRoot)
foreach ($runtimeLauncher in $runtimeLaunchers) {
    $absolutePath = Join-Path $projectRoot ($runtimeLauncher.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $runtimeLauncher.lines
}

$sessionHandoffArtifacts = @(Get-SessionHandoffArtifacts -ProjectRoot $projectRoot)
foreach ($sessionHandoffArtifact in $sessionHandoffArtifacts) {
    $absolutePath = Join-Path $projectRoot ($sessionHandoffArtifact.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $sessionHandoffArtifact.lines
}

$runtimeDocs = @(Get-RuntimeDocs -ProjectRoot $projectRoot)
foreach ($runtimeDoc in $runtimeDocs) {
    $absolutePath = Join-Path $projectRoot ($runtimeDoc.path -replace "/", "\")
    Add-RelevantFile -Registry $relevantFiles -Path $absolutePath -Lines $runtimeDoc.lines
}

$ownerRoutingEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "mandatory owner|owner routing|binding contract|task_kind|designated_owner|delegate_or_local|solution-transplanter|saturation-"
)
$structurePreservationEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "subagent structure|subagent architecture|owner boundaries|structure preservation|source_subagent_structure|flatten|flattening|서브에이전트 구조|owner 경계|구조 보존|평탄화"
)
$runtimeContractGateEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "completion gate|runtime contract installation gate|binding runtime contract|not complete until|blocked or incomplete|incomplete until"
)
$delegationFallbackEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "local fallback|local override|delegation approval|delegate_or_local|delegation cannot|delegation unavailable|delegation blocked"
)
$guardSurfaceEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "guarded write|guarded surface|guard rule|must not edit|must not touch|stop before editing|delegation or explicit local override is required|owned by solution-transplanter"
)
$runtimeCommandEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "/delegate|/transplant-upgrade|/route-check"
)
$projectCodexConfigEvidence = @(
    $projectCodexConfigFindings |
    Where-Object { $_.developer_instructions -eq "present" } |
    ForEach-Object { $_.path }
)
$workflowParityEvidence = @(
    Get-DocMatchPaths -ProjectRoot $projectRoot -Docs $runtimeDocs -Pattern "workflow parity|command parity|hook parity|runtime-facing workflow|end-to-end parity|do not claim completion|do not stop after root contract|wrapper parity|launcher behavior|hook behavior"
)
$commandDocRoutingEvidence = @(
    $commandsFindings |
    Where-Object { $_.path -match "(?i)(delegate|transplant|route|owner)" -or $_.title -match "(?i)(delegate|transplant|route|owner)" } |
    ForEach-Object { $_.path }
)
$routingCommandEvidence = @($runtimeCommandEvidence + $commandDocRoutingEvidence | Sort-Object -Unique)
$ownerRoutingInScope = ($agentsFindings.Count -gt 0 -or $ownerRoutingEvidence.Count -gt 0 -or $routingCommandEvidence.Count -gt 0)
$subagentStructureInScope = ($agentsFindings.Count -gt 0 -or $structurePreservationEvidence.Count -gt 0)
$workflowParityInScope = ($commandsFindings.Count -gt 0 -or $hooksFindings.Count -gt 0 -or $wrapperScripts.Count -gt 0 -or $runtimeLaunchers.Count -gt 0)

$projectTypes = Get-ProjectType -ProjectRoot $projectRoot
$osAssumptions = [System.Collections.Generic.List[string]]::new()
$shellAssumptions = [System.Collections.Generic.List[string]]::new()
$assumptionEvidence = [System.Collections.Generic.List[string]]::new()

if ($hooksFindings.Count -gt 0) {
    foreach ($hook in $hooksFindings) {
        if ($hook.shell -in @("powershell", "cmd")) {
            [void]$osAssumptions.Add("windows")
        }

        if ($hook.shell -in @("sh", "bash", "zsh")) {
            [void]$osAssumptions.Add("posix")
        }

        if ($hook.shell -ne "unknown") {
            [void]$shellAssumptions.Add($hook.shell)
            [void]$assumptionEvidence.Add($hook.path)
        }
    }
}

if ($wrapperScripts.Count -gt 0) {
    foreach ($wrapper in $wrapperScripts) {
        if ($wrapper.shell -in @("powershell", "cmd")) {
            [void]$osAssumptions.Add("windows")
        }

        if ($wrapper.shell -in @("sh", "bash", "zsh")) {
            [void]$osAssumptions.Add("posix")
        }

        if ($wrapper.shell -ne "unknown") {
            [void]$shellAssumptions.Add($wrapper.shell)
            [void]$assumptionEvidence.Add($wrapper.path)
        }
    }
}

if ($runtimeLaunchers.Count -gt 0) {
    foreach ($launcher in $runtimeLaunchers) {
        if ($launcher.shell -in @("powershell", "cmd")) {
            [void]$osAssumptions.Add("windows")
        }

        if ($launcher.shell -in @("sh", "bash", "zsh")) {
            [void]$osAssumptions.Add("posix")
        }

        if ($launcher.shell -ne "unknown") {
            [void]$shellAssumptions.Add($launcher.shell)
            [void]$assumptionEvidence.Add($launcher.path)
        }
    }
}

foreach ($doc in $runtimeDocs) {
    $fullPath = Join-Path $projectRoot ($doc.path -replace "/", "\")
    try {
        $windowsHint = Select-String -LiteralPath $fullPath -Pattern "windows|powershell|cmd.exe" -Quiet -ErrorAction Stop
        $posixHint = Select-String -LiteralPath $fullPath -Pattern "linux|macos|bash|zsh|sh " -Quiet -ErrorAction Stop
    }
    catch {
        $windowsHint = $false
        $posixHint = $false
    }

    if ($windowsHint) {
        [void]$osAssumptions.Add("windows")
        [void]$shellAssumptions.Add("powershell")
        [void]$assumptionEvidence.Add($doc.path)
    }

    if ($posixHint) {
        [void]$osAssumptions.Add("posix")
        [void]$shellAssumptions.Add("bash")
        [void]$assumptionEvidence.Add($doc.path)
    }
}

$osAssumptions = @($osAssumptions | Sort-Object -Unique)
$shellAssumptions = @($shellAssumptions | Sort-Object -Unique)
$assumptionEvidence = @($assumptionEvidence | Sort-Object -Unique)

if ($osAssumptions.Count -eq 0) {
    $osAssumptions = @("unknown")
}

if ($shellAssumptions.Count -eq 0) {
    $shellAssumptions = @("unknown")
}

$relevantFileCount = @($relevantFiles.Keys).Count
$relevantTotalLines = @($relevantFiles.Values | Measure-Object -Sum).Sum
if ($null -eq $relevantTotalLines) {
    $relevantTotalLines = 0
}

$dynamicOrchestrationRecommended = ($relevantFileCount -ge 3 -and $relevantTotalLines -ge 1000)

$risks = [System.Collections.Generic.List[object]]::new()
$riskSeen = @{}
$claudeLaunchers = @($runtimeLaunchers | Where-Object { $_.runtime -match "claude" })
$codexLaunchers = @($runtimeLaunchers | Where-Object { $_.runtime -match "codex" })
$continuityEvidence = @()
if ($null -ne $rootPolicyFile) {
    $continuityEvidence += "CLAUDE.md"
}

$continuityEvidence += @($rootCodexGuides | ForEach-Object { $_.path })
$continuityEvidence += @($projectCodexConfigFindings | ForEach-Object { $_.path })
$continuityEvidence += @($runtimeLaunchers | ForEach-Object { $_.path })
$continuityEvidence = @($continuityEvidence | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
$dualRuntimeContinuityInScope = ($null -ne $rootPolicyFile -or $rootCodexGuides.Count -gt 0 -or $projectCodexConfigFindings.Count -gt 0 -or $runtimeLaunchers.Count -gt 0 -or $sessionHandoffArtifacts.Count -gt 0 -or $runtimeDocs.Count -gt 0)
$continuityGapEvidence = if ($continuityEvidence.Count -gt 0) {
    @($continuityEvidence | ForEach-Object { Format-Code $_ }) -join ", "
}
else {
    Get-FileEvidence -Items $runtimeDocs -PropertyName "path"
}

if ($null -ne $rootPolicyFile) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "medium" -Surface "Root policy file" -Description "The project relies on CLAUDE.md guidance that must be represented honestly for Codex." -Evidence (Format-Code "CLAUDE.md")
}

if ($null -ne $rootPolicyFile -and $rootCodexGuides.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Session continuity gap" -Severity "medium" -Surface "Root runtime guides" -Description "CLAUDE.md was found, but no repo-root Codex guide such as AGENTS.md was detected, so runtime switching may depend on undocumented memory." -Evidence (Format-Code "CLAUDE.md")
}

if ($settingsFindings.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "high" -Surface "Local runtime settings" -Description "Claude runtime settings have no guaranteed one-to-one Codex file surface and will need translation or explicit replacement." -Evidence (Get-FileEvidence -Items $settingsFindings -PropertyName "path")
}

if (($ownerRoutingInScope -or $subagentStructureInScope) -and $projectCodexConfigFindings.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Behavior drift" -Severity "medium" -Surface "Project-scoped Codex config" -Description "Mandatory owners or preserved subagent structure were detected, but no project-scoped `.codex/config.toml` was found to reinforce delegation-first routing above repo docs." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($projectCodexConfigFindings.Count -gt 0 -and $projectCodexConfigEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "medium" -Surface "Project-scoped Codex config" -Description "A project-scoped Codex config was found, but it does not appear to define `developer_instructions`, so delegation-first routing may still depend on weaker layers." -Evidence (Get-FileEvidence -Items $projectCodexConfigFindings -PropertyName "path")
}

if ($hooksFindings.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "high" -Surface "Hooks" -Description "Claude hooks usually require script or verification-gate emulation on the Codex side." -Evidence (Get-FileEvidence -Items $hooksFindings -PropertyName "path")
}

if ($agentsFindings.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "medium" -Surface "Agents" -Description "Claude agent prompts may need Codex delegation rewrites, but role mirroring alone is insufficient without a binding owner contract." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if ($skillsFindings.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "medium" -Surface "Skills" -Description "Skill instructions may map cleanly, but installation path and runtime expectations still need validation." -Evidence (Get-FileEvidence -Items $skillsFindings -PropertyName "path")
}

if ($commandsFindings.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Codex missing equivalent" -Severity "medium" -Surface "Commands" -Description "Claude command docs are likely to require Codex-specific command or workflow rewrites." -Evidence (Get-FileEvidence -Items $commandsFindings -PropertyName "path")
}

if ($workflowParityInScope -and $workflowParityEvidence.Count -eq 0) {
    $workflowParitySourceItems = @($commandsFindings + $hooksFindings + $wrapperScripts + $runtimeLaunchers)
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Behavior drift" -Severity "high" -Surface "Workflow parity closure" -Description "Runtime-facing commands, hooks, wrappers, or launcher flows were detected, but no explicit workflow-parity plan says they must be analyzed and verified before completion. Root-guide continuity alone may hide broken day-to-day behavior." -Evidence (Get-FileEvidence -Items $workflowParitySourceItems -PropertyName "path")
}

if ($agentsFindings.Count -gt 0 -and $ownerRoutingEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "high" -Surface "Owner routing contract" -Description "Agent or role docs were detected, but no binding owner-routing contract was found. Codex may treat the roles as descriptive and perform mandatory-owner work locally." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if ($agentsFindings.Count -gt 0 -and $structurePreservationEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Behavior drift" -Severity "high" -Surface "Subagent architecture preservation" -Description "Agent prompts were detected, but no explicit structure-preservation rule was found. Codex conversion may flatten the source Claude subagent topology into main-agent local execution." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if (($ownerRoutingInScope -or $subagentStructureInScope) -and $runtimeContractGateEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "high" -Surface "Runtime contract installation gate" -Description "Owner-bound or structure-preserving work appears to exist, but no explicit completion gate says the target remains blocked or incomplete until the binding runtime contract is installed." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($ownerRoutingInScope -and $delegationFallbackEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "high" -Surface "Delegation fallback" -Description "Owner-bound work appears to exist, but no explicit fallback rule says what happens when delegation cannot run under the current runtime policy." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($ownerRoutingInScope -and $guardSurfaceEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "medium" -Surface "Guarded write surfaces" -Description "Owner-bound work appears to exist, but no explicit guard rules were detected for protected files or action classes." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($ownerRoutingInScope -and $routingCommandEvidence.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "medium" -Surface "Owner command surface" -Description "No explicit routing command surface was detected, so the main agent may need to infer ownership from descriptive docs instead of an unambiguous trigger." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($wrapperScripts.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Environment mismatch" -Severity "medium" -Surface "Wrapper scripts" -Description "Wrapper scripts reference Claude runtime behaviors directly and will need shell-safe Codex replacements or dual-runtime branching." -Evidence (Get-FileEvidence -Items $wrapperScripts -PropertyName "path")
}

if ($runtimeLaunchers.Count -gt 0 -and (($claudeLaunchers.Count -gt 0 -and $codexLaunchers.Count -eq 0) -or ($codexLaunchers.Count -gt 0 -and $claudeLaunchers.Count -eq 0))) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Session continuity gap" -Severity "medium" -Surface "Launcher parity" -Description "Launcher-style entrypoints were detected for one runtime but not the other, so session switching may require undocumented commands." -Evidence (Get-FileEvidence -Items $runtimeLaunchers -PropertyName "path")
}

$settingsPermissionEvidence = @(
    $settingsFindings |
    Where-Object { $_.top_level -match "permission|approval|allow|deny|hook" } |
    ForEach-Object { $_.path }
)

$docsPermissionEvidence = @()
foreach ($doc in $runtimeDocs) {
    $docPath = Join-Path $projectRoot ($doc.path -replace "/", "\")
    try {
        $hasPermissionMarkers = Select-String -LiteralPath $docPath -Pattern "permission|permissions|approval|allow|deny|hook" -Quiet -ErrorAction Stop
    }
    catch {
        $hasPermissionMarkers = $false
    }

    if ($hasPermissionMarkers) {
        $docsPermissionEvidence += $doc.path
    }
}

$permissionEvidence = @($settingsPermissionEvidence + $docsPermissionEvidence | Sort-Object -Unique)
if ($permissionEvidence.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Permission mismatch" -Severity "medium" -Surface "Approval and hook policy" -Description "The project documents approval, hook, or permission behavior that must be remapped to Codex sandbox and escalation rules." -Evidence (@($permissionEvidence | ForEach-Object { Format-Code $_ }) -join ", ")
}

if ($dualRuntimeContinuityInScope -and $sessionHandoffArtifacts.Count -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Session continuity gap" -Severity "medium" -Surface "Session handoff" -Description "No durable handoff note was detected, so alternating Claude and Codex sessions may lose current-state context." -Evidence $continuityGapEvidence
}

$settingsParseFailures = @($settingsFindings | Where-Object { $_.parse_status -eq "failed" })
if ($settingsParseFailures.Count -gt 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "high" -Surface "Settings parsing" -Description "At least one Claude settings file could not be parsed, so behavior must be clarified before planning safe edits." -Evidence (Get-FileEvidence -Items $settingsParseFailures -PropertyName "path")
}

if ($osAssumptions.Count -eq 1 -and $osAssumptions[0] -eq "windows") {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Environment mismatch" -Severity "medium" -Surface "Operating system assumptions" -Description "The scanned runtime surface appears Windows-oriented, so Codex workflows may need explicit PowerShell-safe handling." -Evidence (@($assumptionEvidence | ForEach-Object { Format-Code $_ }) -join ", ")
}

if ($osAssumptions.Count -eq 1 -and $osAssumptions[0] -eq "posix") {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Environment mismatch" -Severity "medium" -Surface "Operating system assumptions" -Description "The scanned runtime surface appears POSIX-oriented, so Codex workflows may need shell normalization or platform gating." -Evidence (@($assumptionEvidence | ForEach-Object { Format-Code $_ }) -join ", ")
}

if ($osAssumptions -contains "windows" -and $osAssumptions -contains "posix") {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "medium" -Surface "Operating system assumptions" -Description "The runtime surface mixes Windows and POSIX expectations, so the transformer must decide whether to preserve both paths or declare a supported subset." -Evidence (@($assumptionEvidence | ForEach-Object { Format-Code $_ }) -join ", ")
}

$surfaceCount =
    $(if ($null -ne $rootPolicyFile) { 1 } else { 0 }) +
    $settingsFindings.Count +
    $hooksFindings.Count +
    $agentsFindings.Count +
    $skillsFindings.Count +
    $commandsFindings.Count +
    $wrapperScripts.Count

if ($surfaceCount -eq 0) {
    Add-Risk -Collection $risks -Seen $riskSeen -Category "Unclear behavior" -Severity "high" -Surface "Claude runtime discovery" -Description "No canonical Claude operating surfaces were found, so this may not be a Claude-oriented project or the operational contract is undocumented." -Evidence "No CLAUDE.md, .claude/settings*.json, hooks, agents, skills, commands, or wrapper scripts detected."
}

$candidateEditAreas = [System.Collections.Generic.List[object]]::new()
$editAreaSeen = @{}

if ($null -ne $rootPolicyFile) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "modify" -Target "CLAUDE.md" -Rationale "Root operating guidance likely needs dual-runtime notes or explicit Codex handoff." -Evidence (Format-Code "CLAUDE.md")
    if ($rootCodexGuides.Count -eq 0) {
        Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "AGENTS.md or equivalent repo-root Codex guide" -Rationale "The project has a root Claude guide but no repo-root Codex guide for switchback-safe operation." -Evidence (Format-Code "CLAUDE.md")
    }
}

if ($rootCodexGuides.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target "Repo-root Codex guide" -Rationale "Existing Codex-facing guidance should be checked for parity with the Claude-side contract." -Evidence (Get-FileEvidence -Items $rootCodexGuides -PropertyName "path")
}

if ($settingsFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target ".claude/settings*.json" -Rationale "Local Claude runtime settings define behavior that must be preserved even if Codex support is implemented elsewhere." -Evidence (Get-FileEvidence -Items $settingsFindings -PropertyName "path")
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Codex execution or approval configuration docs" -Rationale "Claude runtime settings imply Codex-side policy or config artifacts will be needed." -Evidence (Get-FileEvidence -Items $settingsFindings -PropertyName "path")
}

if (($ownerRoutingInScope -or $subagentStructureInScope) -and $projectCodexConfigFindings.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target ".codex/config.toml" -Rationale "Mandatory-owner routing and preserved subagent structure should be reinforced by a project-scoped Codex `developer_instructions` layer instead of relying only on repo docs." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($projectCodexConfigFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target ".codex/config.toml" -Rationale "Existing project-scoped Codex config should be checked to ensure it reinforces delegation-first routing and does not replace built-in instructions too aggressively." -Evidence (Get-FileEvidence -Items $projectCodexConfigFindings -PropertyName "path")
}

if ($hooksFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target ".claude/hooks/**" -Rationale "Hook behavior should be preserved or consciously replaced, not changed blindly." -Evidence (Get-FileEvidence -Items $hooksFindings -PropertyName "path")
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Codex-side hook emulation scripts or verification gates" -Rationale "Hook semantics usually need explicit emulation outside .claude/hooks/." -Evidence (Get-FileEvidence -Items $hooksFindings -PropertyName "path")
}

if ($agentsFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target ".claude/agents/**" -Rationale "Agent instructions are part of the source behavior contract and should stay readable as evidence." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Codex delegation prompt files or role docs plus a binding owner-routing contract" -Rationale "Agent roles likely need Codex-local equivalents, but role docs alone are not enough when task ownership is mandatory." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if ($agentsFindings.Count -gt 0 -and $structurePreservationEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Subagent architecture preservation rule in runtime guides" -Rationale "Projects with named agents should preserve the source Claude subagent topology instead of flattening it into main-agent local execution." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if (($ownerRoutingInScope -or $subagentStructureInScope) -and $runtimeContractGateEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Runtime contract installation completion gate" -Rationale "When owner routing or source subagent preservation is required, completion should stay blocked until the binding runtime contract is installed in repo-root guides." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($agentsFindings.Count -gt 0 -and $ownerRoutingEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Binding owner-routing contract in root runtime guides" -Rationale "Projects with named agents should distinguish descriptive roles from mandatory owners before Codex patch work begins." -Evidence (Get-FileEvidence -Items $agentsFindings -PropertyName "path")
}

if ($ownerRoutingInScope -and $delegationFallbackEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Delegation fallback rule for mandatory-owner work" -Rationale "If delegation is unavailable, the runtime contract must force approval or explicit local override instead of silent local execution." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($ownerRoutingInScope -and $guardSurfaceEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Guard rules for owner-bound writes" -Rationale "Protected surfaces should warn or stop before the main agent edits them locally." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($ownerRoutingInScope -and $routingCommandEvidence.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Owner-routing command surface" -Rationale "Explicit routing commands reduce ambiguity around mandatory-owner work and help Codex avoid local misrouting." -Evidence $(if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" })
}

if ($skillsFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target ".claude/skills/**/SKILL.md" -Rationale "Skill behavior should be preserved as source evidence before any Codex mirroring." -Evidence (Get-FileEvidence -Items $skillsFindings -PropertyName "path")
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Codex skill artifacts or repo-native task docs" -Rationale "The source project uses skill-level instructions that likely need Codex-side equivalents." -Evidence (Get-FileEvidence -Items $skillsFindings -PropertyName "path")
}

if ($commandsFindings.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "modify" -Target ".claude/commands/**" -Rationale "Claude command docs often need dual-runtime language or adjacent Codex task docs." -Evidence (Get-FileEvidence -Items $commandsFindings -PropertyName "path")
}

if ($workflowParityInScope -and $workflowParityEvidence.Count -eq 0) {
    $workflowParitySourceItems = @($commandsFindings + $hooksFindings + $wrapperScripts + $runtimeLaunchers)
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Workflow parity plan and verification for commands, hooks, wrappers, and launcher flows" -Rationale "Projects should not be marked Codex-ready while day-to-day runtime-facing workflows remain only partially analyzed or unverified." -Evidence (Get-FileEvidence -Items $workflowParitySourceItems -PropertyName "path")
}

if ($wrapperScripts.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "modify" -Target "Claude-oriented wrapper scripts" -Rationale "Wrapper scripts reference Claude runtime behaviors directly and may need branching or replacement." -Evidence (Get-FileEvidence -Items $wrapperScripts -PropertyName "path")
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Codex wrapper script(s) matching existing entrypoints" -Rationale "Existing wrapper entrypoints imply Codex-safe entrypoints will improve parity and verification." -Evidence (Get-FileEvidence -Items $wrapperScripts -PropertyName "path")
}

if ($runtimeLaunchers.Count -gt 0 -and (($claudeLaunchers.Count -gt 0 -and $codexLaunchers.Count -eq 0) -or ($codexLaunchers.Count -gt 0 -and $claudeLaunchers.Count -eq 0))) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "Missing runtime launcher or documented substitute" -Rationale "Launcher-style entrypoints exist for only one runtime, so session switching needs parity or an explicit substitute path." -Evidence (Get-FileEvidence -Items $runtimeLaunchers -PropertyName "path")
}

if ($sessionHandoffArtifacts.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "verify-only" -Target "Session handoff artifact" -Rationale "Existing handoff notes should stay aligned with real runtime surfaces and open work." -Evidence (Get-FileEvidence -Items $sessionHandoffArtifacts -PropertyName "path")
}

if ($dualRuntimeContinuityInScope -and $sessionHandoffArtifacts.Count -eq 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "add" -Target "SESSION-HANDOFF.md or equivalent durable worklog" -Rationale "Alternating Claude and Codex sessions should leave behind a durable next-step artifact instead of relying on session memory." -Evidence $continuityGapEvidence
}

if ($runtimeDocs.Count -gt 0) {
    Add-EditArea -Collection $candidateEditAreas -Seen $editAreaSeen -Category "modify" -Target "Runtime-facing markdown docs" -Rationale "Project docs already describe runtime behavior and will need dual-runtime wording." -Evidence (Get-FileEvidence -Items $runtimeDocs -PropertyName "path")
}

$matrixRows = [System.Collections.Generic.List[object]]::new()
$matrixSeen = @{}

if ($null -ne $rootPolicyFile -or $dualRuntimeContinuityInScope) {
    $rootPolicySource = if ($null -ne $rootPolicyFile) { Format-Code "CLAUDE.md" } else { "No canonical Claude root operating guide detected" }
    $rootPolicyNotes = if ($null -ne $rootPolicyFile) {
        "Detected root operating guide at CLAUDE.md."
    }
    else {
        "Session continuity is in scope, but no canonical Claude root guide was detected."
    }
    if ($rootCodexGuides.Count -gt 0) {
        $rootPolicyNotes += " Existing Codex guide(s): " + (($rootCodexGuides | ForEach-Object { Format-Code $_.path }) -join ", ") + "."
    }

    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Root policy file" -SourceRuntime $rootPolicySource -TargetRuntime "AGENTS.md or equivalent Codex-facing repo guide" -NormalizationStrategy "rewrite" -Status $(if ($null -ne $rootPolicyFile) { "planned" } else { "blocked" }) -Notes $rootPolicyNotes
}

if ($settingsFindings.Count -gt 0) {
    $settingsNotes = "Detected " + $settingsFindings.Count + " settings file(s): " + (($settingsFindings | ForEach-Object { Format-Code $_.path }) -join ", ")
    if ($settingsParseFailures.Count -gt 0) {
        $settingsNotes += " Parse failures: " + (($settingsParseFailures | ForEach-Object { Format-Code $_.path }) -join ", ") + "."
    }

    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Local runtime settings" -SourceRuntime (Get-FileEvidence -Items $settingsFindings -PropertyName "path") -TargetRuntime "Codex-compatible execution and approval config or docs" -NormalizationStrategy "rewrite" -Status "planned" -Notes $settingsNotes
}

if (($ownerRoutingInScope -or $subagentStructureInScope) -or $projectCodexConfigFindings.Count -gt 0) {
    $projectConfigSource = if ($projectCodexConfigFindings.Count -gt 0) { Get-FileEvidence -Items $projectCodexConfigFindings -PropertyName "path" } elseif ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" }
    $projectConfigNotes = if ($projectCodexConfigFindings.Count -gt 0) {
        "Detected project-scoped Codex config in " + (($projectCodexConfigFindings | ForEach-Object { Format-Code $_.path }) -join ", ") + "."
    }
    else {
        "No project-scoped `.codex/config.toml` was detected even though owner-routing or subagent-structure reinforcement appears to be needed."
    }

    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Project-scoped Codex config" -SourceRuntime $projectConfigSource -TargetRuntime ".codex/config.toml with `developer_instructions` that reinforce delegation-first routing and preserved owner boundaries" -NormalizationStrategy "rewrite" -Status $(if ($projectCodexConfigEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $projectConfigNotes
}

if ($hooksFindings.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Hooks" -SourceRuntime (Get-FileEvidence -Items $hooksFindings -PropertyName "path") -TargetRuntime "Scripts plus verification gates that emulate hook behavior" -NormalizationStrategy "emulate" -Status "planned" -Notes ("Detected " + $hooksFindings.Count + " hook file(s).")
}

if ($workflowParityInScope) {
    $workflowParitySource = if ($workflowParityEvidence.Count -gt 0) { @($workflowParityEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items @($commandsFindings + $hooksFindings + $wrapperScripts + $runtimeLaunchers) -PropertyName "path" }
    $workflowParityNotes = if ($workflowParityEvidence.Count -gt 0) {
        "Detected workflow-parity language in " + (($workflowParityEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Runtime-facing commands, hooks, wrappers, or launcher flows were detected, but no explicit workflow-parity closure rule was found."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Workflow parity closure" -SourceRuntime $workflowParitySource -TargetRuntime "Codex-side artifacts and verification that preserve command, hook, wrapper, and launcher behavior end-to-end" -NormalizationStrategy "rewrite" -Status $(if ($workflowParityEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $workflowParityNotes
}

if ($agentsFindings.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Agents" -SourceRuntime (Get-FileEvidence -Items $agentsFindings -PropertyName "path") -TargetRuntime "Codex delegation prompts or task-role docs" -NormalizationStrategy "emulate" -Status "planned" -Notes ("Detected " + $agentsFindings.Count + " agent prompt file(s). Agent mirroring alone is not enough when ownership is mandatory.")
}

if ($subagentStructureInScope) {
    $structureSource = if ($structurePreservationEvidence.Count -gt 0) { @($structurePreservationEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { Get-FileEvidence -Items $agentsFindings -PropertyName "path" }
    $structureNotes = if ($structurePreservationEvidence.Count -gt 0) {
        "Detected structure-preservation language in " + (($structurePreservationEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Named agents were detected, but no explicit subagent-structure preservation rule was found."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Subagent architecture preservation" -SourceRuntime $structureSource -TargetRuntime "Codex-facing docs and workflows that preserve the source Claude subagent structure and owner boundaries" -NormalizationStrategy "rewrite" -Status $(if ($structurePreservationEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $structureNotes
}

if ($ownerRoutingInScope -or $subagentStructureInScope) {
    $runtimeContractSource = if ($runtimeContractGateEvidence.Count -gt 0) { @($runtimeContractGateEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { "No explicit runtime-contract completion gate detected" }
    $runtimeContractNotes = if ($runtimeContractGateEvidence.Count -gt 0) {
        "Detected completion-gate language in " + (($runtimeContractGateEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Owner routing or source subagent preservation appears in scope, but no explicit rule says the target remains blocked or incomplete until the binding runtime contract is installed."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Runtime contract installation gate" -SourceRuntime $runtimeContractSource -TargetRuntime "Target remains blocked or incomplete until the binding runtime contract is installed in repo-root guides" -NormalizationStrategy "rewrite" -Status $(if ($runtimeContractGateEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $runtimeContractNotes
}

if ($ownerRoutingInScope) {
    $ownerRoutingSource = if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { "Role or agent docs without binding owner contract" }
    $ownerRoutingNotes = if ($ownerRoutingEvidence.Count -gt 0) {
        "Detected binding owner-routing language in " + (($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Named agents were detected, but no binding owner-routing language was found."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Owner routing contract" -SourceRuntime $ownerRoutingSource -TargetRuntime "Root runtime guides or policy docs that bind task kinds to mandatory owners" -NormalizationStrategy "rewrite" -Status $(if ($ownerRoutingEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $ownerRoutingNotes

    $routingPreflightSource = if ($ownerRoutingEvidence.Count -gt 0) { @($ownerRoutingEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { 'No explicit `task_kind` / `designated_owner` routing preflight detected' }
    $routingPreflightNotes = if ($ownerRoutingEvidence.Count -gt 0) {
        "Owner-routing guidance appears to define preflight routing fields."
    }
    else {
        "Main-agent routing may still be inferred ad hoc."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Routing preflight" -SourceRuntime $routingPreflightSource -TargetRuntime 'Explicit `task_kind`, `designated_owner`, `delegate_or_local`, and `why` gate before edits' -NormalizationStrategy "rewrite" -Status $(if ($ownerRoutingEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $routingPreflightNotes

    $fallbackSource = if ($delegationFallbackEvidence.Count -gt 0) { @($delegationFallbackEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { "No explicit delegation fallback rule detected" }
    $fallbackNotes = if ($delegationFallbackEvidence.Count -gt 0) {
        "Delegation fallback language was detected in " + (($delegationFallbackEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Mandatory-owner work may collapse into silent local execution when delegation is unavailable."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Delegation fallback" -SourceRuntime $fallbackSource -TargetRuntime "Delegation approval request or explicit local override before owner-bound local edits" -NormalizationStrategy "rewrite" -Status $(if ($delegationFallbackEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $fallbackNotes

    $guardSource = if ($guardSurfaceEvidence.Count -gt 0) { @($guardSurfaceEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { "No owner-bound guard rules detected" }
    $guardNotes = if ($guardSurfaceEvidence.Count -gt 0) {
        "Guard language was detected in " + (($guardSurfaceEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Protected files and action classes are not explicitly guarded yet."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Guarded write surfaces" -SourceRuntime $guardSource -TargetRuntime "Warnings or hard stops for target-repo edits, manifest updates, version bumps, and agent redistribution" -NormalizationStrategy "rewrite" -Status $(if ($guardSurfaceEvidence.Count -gt 0) { "planned" } else { "blocked" }) -Notes $guardNotes

    $commandSurfaceSource = if ($routingCommandEvidence.Count -gt 0) { @($routingCommandEvidence | ForEach-Object { Format-Code $_ }) -join ", " } else { "No owner-routing command surface detected" }
    $commandSurfaceNotes = if ($routingCommandEvidence.Count -gt 0) {
        "Explicit routing command cues were detected in " + (($routingCommandEvidence | ForEach-Object { Format-Code $_ }) -join ", ") + "."
    }
    else {
        "Explicit routing commands are recommended to reduce owner inference ambiguity."
    }
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Owner command surface" -SourceRuntime $commandSurfaceSource -TargetRuntime "Explicit `/delegate`, `/transplant-upgrade`, or equivalent routing commands" -NormalizationStrategy "rewrite" -Status "planned" -Notes $commandSurfaceNotes
}

if ($skillsFindings.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Skills" -SourceRuntime (Get-FileEvidence -Items $skillsFindings -PropertyName "path") -TargetRuntime "Codex skills or repo-native task documentation" -NormalizationStrategy "direct map" -Status "planned" -Notes ("Detected " + $skillsFindings.Count + " skill artifact(s); format compatibility still requires validation.")
}

if ($commandsFindings.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Commands" -SourceRuntime (Get-FileEvidence -Items $commandsFindings -PropertyName "path") -TargetRuntime "Codex task docs, slash-command replacements, or wrapper scripts" -NormalizationStrategy "rewrite" -Status "planned" -Notes ("Detected " + $commandsFindings.Count + " command file(s).")
}

if ($wrapperScripts.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Wrapper commands" -SourceRuntime (Get-FileEvidence -Items $wrapperScripts -PropertyName "path") -TargetRuntime "Shell recipes and helper scripts that preserve behavior across runtimes" -NormalizationStrategy "rewrite" -Status "planned" -Notes ("Detected " + $wrapperScripts.Count + " wrapper script(s) with direct Claude references.")
}

if ($runtimeLaunchers.Count -gt 0 -or $dualRuntimeContinuityInScope) {
    $launcherSource = if ($runtimeLaunchers.Count -gt 0) { Get-FileEvidence -Items $runtimeLaunchers -PropertyName "path" } else { "No runtime launcher or documented substitute detected" }
    $launcherNotes = if ($runtimeLaunchers.Count -gt 0) {
        "Detected " + $runtimeLaunchers.Count + " launcher candidate(s): " + (($runtimeLaunchers | ForEach-Object { Format-Code $_.path }) -join ", ") + "."
    }
    else {
        "No launcher candidates were detected yet. If runtime switching is expected, document equivalent Claude and Codex entry paths explicitly."
    }
    if ($claudeLaunchers.Count -gt 0 -and $codexLaunchers.Count -gt 0) {
        $launcherNotes += " Both runtime families have launcher candidates."
    }
    elseif ($claudeLaunchers.Count -gt 0) {
        $launcherNotes += " Only Claude-side launcher candidates were detected."
    }
    elseif ($codexLaunchers.Count -gt 0) {
        $launcherNotes += " Only Codex-side launcher candidates were detected."
    }

    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Launcher parity" -SourceRuntime $launcherSource -TargetRuntime "Claude and Codex entrypoints with parity or explicit documented substitutes" -NormalizationStrategy "rewrite" -Status "planned" -Notes $launcherNotes
}

if ($permissionEvidence.Count -gt 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Permission model" -SourceRuntime (@($permissionEvidence | ForEach-Object { Format-Code $_ }) -join ", ") -TargetRuntime "Codex sandbox and escalation policy documentation" -NormalizationStrategy "emulate" -Status "planned" -Notes "Approval or permission language was detected in runtime settings or docs."
}

if ($dualRuntimeContinuityInScope) {
    $handoffSource = if ($sessionHandoffArtifacts.Count -gt 0) { Get-FileEvidence -Items $sessionHandoffArtifacts -PropertyName "path" } else { "Implicit session memory or ad hoc notes" }
    $handoffNotes = if ($sessionHandoffArtifacts.Count -gt 0) {
        "Existing handoff artifact(s): " + (($sessionHandoffArtifacts | ForEach-Object { Format-Code $_.path }) -join ", ") + "."
    }
    else {
        "No durable handoff artifact detected yet."
    }

    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Session handoff" -SourceRuntime $handoffSource -TargetRuntime "SESSION-HANDOFF.md or equivalent durable worklog" -NormalizationStrategy "rewrite" -Status "planned" -Notes $handoffNotes
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Switchback verification" -SourceRuntime "Manual confidence that paused work can resume after runtime switches" -TargetRuntime "Explicit Claude-to-Codex and Codex-to-Claude resume checks" -NormalizationStrategy "verify" -Status "planned" -Notes "Continuity claims should be proven by workflow evidence, not only file presence."
}

if ($osAssumptions.Count -gt 0 -and -not ($osAssumptions.Count -eq 1 -and $osAssumptions[0] -eq "unknown")) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Operating system assumptions" -SourceRuntime ($osAssumptions -join ", ") -TargetRuntime "Codex-compatible platform policy or dual-path wrappers" -NormalizationStrategy "rewrite" -Status "planned" -Notes ("Evidence: " + (@($assumptionEvidence | ForEach-Object { Format-Code $_ }) -join ", "))
}

if ($shellAssumptions.Count -gt 0 -and -not ($shellAssumptions.Count -eq 1 -and $shellAssumptions[0] -eq "unknown")) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Shell assumptions" -SourceRuntime ($shellAssumptions -join ", ") -TargetRuntime "Codex shell usage and script normalization rules" -NormalizationStrategy "rewrite" -Status "planned" -Notes ("Evidence: " + (@($assumptionEvidence | ForEach-Object { Format-Code $_ }) -join ", "))
}

if ($null -eq $rootPolicyFile -and $settingsFindings.Count -eq 0 -and $projectCodexConfigFindings.Count -eq 0 -and $hooksFindings.Count -eq 0 -and $agentsFindings.Count -eq 0 -and $skillsFindings.Count -eq 0 -and $commandsFindings.Count -eq 0 -and $wrapperScripts.Count -eq 0) {
    Add-MatrixRow -Collection $matrixRows -Seen $matrixSeen -Axis "Claude runtime discovery" -SourceRuntime "No canonical Claude surfaces detected" -TargetRuntime "Manual clarification required" -NormalizationStrategy "unsupported" -Status "blocked" -Notes "Scanner did not find CLAUDE.md, .claude/settings*.json, hooks, agents, skills, commands, or wrapper scripts."
}

$targetSummaryRows = @(
    [PSCustomObject]@{ field = "project_path"; value = $projectRoot },
    [PSCustomObject]@{ field = "project_type"; value = $projectTypes -join ", " },
    [PSCustomObject]@{ field = "operating_system_assumptions"; value = $osAssumptions -join ", " },
    [PSCustomObject]@{ field = "shell_assumptions"; value = $shellAssumptions -join ", " },
    [PSCustomObject]@{ field = "relevant_surface_file_count"; value = $relevantFileCount },
    [PSCustomObject]@{ field = "relevant_surface_total_lines"; value = $relevantTotalLines },
    [PSCustomObject]@{ field = "dynamic_orchestration_recommended"; value = if ($dynamicOrchestrationRecommended) { "true" } else { "false" } }
)

$scanReportLines = [System.Collections.Generic.List[string]]::new()
[void]$scanReportLines.Add("---")
[void]$scanReportLines.Add("kind: source-scan-report")
[void]$scanReportLines.Add("format_version: ""1.0""")
[void]$scanReportLines.Add("status: completed")
[void]$scanReportLines.Add("generated_at: ""$generatedAt""")
[void]$scanReportLines.Add("project_path: ""$projectRoot""")
[void]$scanReportLines.Add("report_stem: ""$reportStemValue""")
[void]$scanReportLines.Add("---")
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("# Source Scan Report")
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Target Summary")
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $targetSummaryRows -Columns @("field", "value")))
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Claude Surfaces")
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Root policy file")
[void]$scanReportLines.Add("")

if ($null -ne $rootPolicyFile) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows @([PSCustomObject]@{
                    path  = (Format-Code "CLAUDE.md")
                    title = if ($rootPolicyFile.title) { $rootPolicyFile.title } else { "-" }
                    lines = $rootPolicyFile.lines
                }) -Columns @("path", "title", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### .claude/settings*.json")
[void]$scanReportLines.Add("")
if ($settingsFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $settingsFindings -Columns @("path", "parse_status", "top_level", "lines", "error")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Project-scoped Codex config")
[void]$scanReportLines.Add("")
if ($projectCodexConfigFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $projectCodexConfigFindings -Columns @("path", "developer_instructions", "model_instructions_file", "profile", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Hooks")
[void]$scanReportLines.Add("")
if ($hooksFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $hooksFindings -Columns @("path", "shell", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Agents")
[void]$scanReportLines.Add("")
if ($agentsFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $agentsFindings -Columns @("path", "title", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Skills")
[void]$scanReportLines.Add("")
if ($skillsFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $skillsFindings -Columns @("path", "title", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Commands")
[void]$scanReportLines.Add("")
if ($commandsFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $commandsFindings -Columns @("path", "title", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Wrapper scripts")
[void]$scanReportLines.Add("")
if ($wrapperScripts.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $wrapperScripts -Columns @("path", "shell", "lines", "reason")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Runtime-facing docs")
[void]$scanReportLines.Add("")
if ($runtimeDocs.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $runtimeDocs -Columns @("path", "title", "lines", "focus")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Continuity Surfaces")
[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Repo-root Codex guides")
[void]$scanReportLines.Add("")
if ($rootCodexGuides.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $rootCodexGuides -Columns @("path", "title", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Project-scoped Codex config")
[void]$scanReportLines.Add("")
if ($projectCodexConfigFindings.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $projectCodexConfigFindings -Columns @("path", "developer_instructions", "model_instructions_file", "profile", "lines")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Runtime launchers")
[void]$scanReportLines.Add("")
if ($runtimeLaunchers.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $runtimeLaunchers -Columns @("path", "runtime", "shell", "lines", "reason")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("### Session handoff artifacts")
[void]$scanReportLines.Add("")
if ($sessionHandoffArtifacts.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $sessionHandoffArtifacts -Columns @("path", "title", "lines", "reason")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Portability Risks")
[void]$scanReportLines.Add("")
if ($risks.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $risks -Columns @("category", "severity", "surface", "description", "evidence")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Candidate Edit Areas")
[void]$scanReportLines.Add("")
if ($candidateEditAreas.Count -gt 0) {
    [void]$scanReportLines.Add((ConvertTo-MarkdownTable -Rows $candidateEditAreas -Columns @("category", "target", "rationale", "evidence")))
}
else {
    [void]$scanReportLines.Add("- none")
}

[void]$scanReportLines.Add("")
[void]$scanReportLines.Add("## Orchestration Note")
[void]$scanReportLines.Add("")
if ($dynamicOrchestrationRecommended) {
    [void]$scanReportLines.Add("Dynamic orchestration is recommended by the repository default thresholds (`min_file_count: 3`, `min_total_lines: 1000`).")
}
else {
    [void]$scanReportLines.Add("Dynamic orchestration is not recommended by the repository default thresholds (`min_file_count: 3`, `min_total_lines: 1000`).")
}

$matrixReportLines = [System.Collections.Generic.List[string]]::new()
[void]$matrixReportLines.Add("---")
[void]$matrixReportLines.Add("kind: compatibility-matrix")
[void]$matrixReportLines.Add("format_version: ""1.0""")
[void]$matrixReportLines.Add("status: draft")
[void]$matrixReportLines.Add("last_updated: ""$generatedDate""")
[void]$matrixReportLines.Add("project_path: ""$projectRoot""")
[void]$matrixReportLines.Add("report_stem: ""$reportStemValue""")
[void]$matrixReportLines.Add("---")
[void]$matrixReportLines.Add("")
[void]$matrixReportLines.Add("# Compatibility Matrix")
[void]$matrixReportLines.Add("")
[void]$matrixReportLines.Add((ConvertTo-MarkdownTable -Rows $matrixRows -Columns @("axis", "source_runtime", "target_runtime", "normalization_strategy", "status", "notes")))

$scanReportPath = Join-Path $reportsRoot "$reportStemValue-source-scan-report.md"
$matrixReportPath = Join-Path $reportsRoot "$reportStemValue-compatibility-matrix.md"

$scanReportLines -join "`n" | Set-Content -LiteralPath $scanReportPath -Encoding UTF8
$matrixReportLines -join "`n" | Set-Content -LiteralPath $matrixReportPath -Encoding UTF8

[PSCustomObject]@{
    project_path                     = $projectRoot
    source_scan_report_path          = $scanReportPath
    compatibility_matrix_report_path = $matrixReportPath
    relevant_surface_file_count      = $relevantFileCount
    relevant_surface_total_lines     = $relevantTotalLines
    dynamic_orchestration_recommended = $dynamicOrchestrationRecommended
}
