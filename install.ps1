#!/usr/bin/env pwsh
# MetaAgent — установка исходников в целевой проект
# Usage: .\install.ps1 [[-Path] target_path] [-Update]

param(
    [string]$Path = "",
    [switch]$Update,
    [switch]$Help
)

$MetaAgentSrc = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Usage {
    @"
Usage: install.ps1 [[-Path] target_path] [-Update] [-Help]

Install MetaAgent sources into <target>/.agent/src/

Options:
  -Path      Path to target project (default: interactive prompt)
  -Update    Overwrite existing files in .agent/src/
  -Help      Show this help

Examples:
  .\install.ps1
  .\install.ps1 -Path C:\Projects\MyApp
  .\install.ps1 -Path C:\Projects\MyApp -Update
"@
    exit 0
}

if ($Help) { Show-Usage }

$TargetPath = $Path
if (-not $TargetPath) {
    $TargetPath = Read-Host "Enter path to target project"
}

$TargetPath = $TargetPath.Trim()
if (-not (Test-Path $TargetPath -PathType Container)) {
    Write-Error "Directory '$TargetPath' does not exist."
    exit 1
}
$TargetPath = (Resolve-Path $TargetPath).Path

$AgentDir = Join-Path $TargetPath ".agent"
$SrcDir   = Join-Path $AgentDir "src"
$RulesDir   = Join-Path $AgentDir "rules"
$ArchiveDir = Join-Path $AgentDir "archive"
$TempDir    = Join-Path $TargetPath ".temp"
$VersionFile = Join-Path $MetaAgentSrc "VERSION"
$Version = if (Test-Path $VersionFile) { Get-Content $VersionFile -Raw -Encoding UTF8 | ForEach-Object { $_.Trim() } } else { "?" }

New-Item -ItemType Directory -Path $SrcDir -Force | Out-Null
New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
Write-Host "Installing MetaAgent v$Version → $SrcDir"

# --- create .temp/ and ensure .gitignore ---
$GitIgnore = Join-Path $TargetPath ".gitignore"
if (-not (Test-Path $GitIgnore -PathType Leaf)) {
    $utf8 = [System.Text.Encoding]::UTF8
    [System.IO.File]::WriteAllBytes($GitIgnore, $utf8.GetBytes(".temp/`n"))
    Write-Host "  [create] .gitignore (.temp/)"
} else {
    $content = Get-Content $GitIgnore -Raw
    if ($content -notmatch '^\.temp/$') {
        $existing = Get-Content $GitIgnore -Raw
        $utf8 = [System.Text.Encoding]::UTF8
        [System.IO.File]::WriteAllBytes($GitIgnore, $utf8.GetBytes($existing + ".temp/`n"))
        Write-Host "  [update] .gitignore (added .temp/)"
    } else {
        Write-Host "  [skip] .gitignore (.temp/ already present)"
    }
}

# --- copy files ---
function Copy-File {
    param([string]$Src, [string]$DstDir)
    $name = Split-Path $Src -Leaf
    if (-not (Test-Path $Src -PathType Leaf)) {
        Write-Host "  [skip] $name (not found)"
        return
    }
    $dst = Join-Path $DstDir $name
    if ($Update -or -not (Test-Path $dst)) {
        Copy-Item $Src $dst -Force
        Write-Host "  [copy] $name"
    } else {
        Write-Host "  [skip] $name (exists, use -Update to overwrite)"
    }
}

function Copy-Dir {
    param([string]$Src, [string]$DstDir)
    $name = Split-Path $Src -Leaf
    if (-not (Test-Path $Src -PathType Container)) {
        Write-Host "  [skip] $name/ (not found)"
        return
    }
    $dst = Join-Path $DstDir $name
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    if ($Update) {
        Get-ChildItem $Src | ForEach-Object {
            Copy-Item $_.FullName $dst -Recurse -Force
        }
    } else {
        Get-ChildItem $Src | ForEach-Object {
            $targetPath = Join-Path $dst $_.Name
            if (-not (Test-Path $targetPath)) {
                Copy-Item $_.FullName $dst -Recurse
            }
        }
    }
    Write-Host "  [copy] $name/"
}

Copy-File (Join-Path $MetaAgentSrc "META_AGENT_GUIDE.md") $SrcDir
Copy-File (Join-Path $MetaAgentSrc "BOUNDARIES.md") $SrcDir
Copy-File (Join-Path $MetaAgentSrc "WORKFLOW.md") $SrcDir
Copy-File (Join-Path $MetaAgentSrc "VERSION") $SrcDir
Copy-Dir  (Join-Path $MetaAgentSrc "PROTOCOLS") $SrcDir
Copy-Dir  (Join-Path $MetaAgentSrc "TEMPLATES") $SrcDir
Copy-File (Join-Path $MetaAgentSrc "install.sh") $SrcDir
Copy-File (Join-Path $MetaAgentSrc "install.ps1") $SrcDir

# --- create / update AGENTS.md in root of target ---
$AgentsMd = Join-Path $TargetPath "AGENTS.md"
$templatePath = Join-Path $MetaAgentSrc "AGENTS.template.md"

if (-not (Test-Path $AgentsMd -PathType Leaf)) {
    $template = Get-Content $templatePath -Raw -Encoding UTF8
    $content = $template.Replace("{VERSION}", $Version)
    $utf8 = [System.Text.Encoding]::UTF8
    [System.IO.File]::WriteAllBytes($AgentsMd, $utf8.GetBytes($content))
    Write-Host "  [create] AGENTS.md"
} elseif ($Update) {
    $template = Get-Content $templatePath -Raw -Encoding UTF8
    $content = $template.Replace("{VERSION}", $Version)
    $utf8 = [System.Text.Encoding]::UTF8
    [System.IO.File]::WriteAllBytes($AgentsMd, $utf8.GetBytes($content))
    Write-Host "  [update] AGENTS.md"
} else {
    Write-Host "  [skip] AGENTS.md (exists, use -Update to overwrite)"
}

Write-Host ""
Write-Host "Done! MetaAgent v$Version installed at $SrcDir"
