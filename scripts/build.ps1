#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InfoBasePath,
    [string]$V8Path,
    [string]$UserName,
    [string]$Password,
    [string]$ExtensionName = "Orbitas",
    [string]$SourcePath,
    [string]$OutputFile,
    [switch]$SkipUpdateDBCfg
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($SourcePath)) { $SourcePath = Join-Path $RepoRoot "src\extension" }
if ([string]::IsNullOrWhiteSpace($OutputFile)) { $OutputFile = Join-Path $RepoRoot "build\Orbitas.cfe" }

function Resolve-1CExecutable {
    param([string]$Candidate)
    if ($Candidate) {
        if (Test-Path $Candidate -PathType Container) {
            $p1 = Join-Path $Candidate "1cv8.exe"
            $p2 = Join-Path $Candidate "bin\1cv8.exe"
            if (Test-Path $p1) { return (Resolve-Path $p1).Path }
            if (Test-Path $p2) { return (Resolve-Path $p2).Path }
        }
        if (Test-Path $Candidate -PathType Leaf) { return (Resolve-Path $Candidate).Path }
        throw "1С:Предприятие не найдено по пути: $Candidate"
    }

    $items = @()
    foreach ($root in @("C:\Program Files\1cv8", "C:\Program Files (x86)\1cv8")) {
        if (-not (Test-Path $root)) { continue }
        $items += Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $exe = Join-Path $_.FullName "bin\1cv8.exe"
            if (Test-Path $exe) {
                [pscustomobject]@{ Version = try { [version]$_.Name } catch { [version]"0.0" }; Path = $exe }
            }
        }
    }
    $found = $items | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $found) { throw "1cv8.exe не найден. Передайте -V8Path." }
    return $found.Path
}

function Assert-FileInfoBase {
    param([string]$Path)
    if (-not (Test-Path $Path -PathType Container)) { throw "Каталог информационной базы не найден: $Path" }
    if (-not (Test-Path (Join-Path $Path "1Cv8.1CD") -PathType Leaf)) {
        throw "В $Path не найден 1Cv8.1CD. build.ps1 сейчас поддерживает файловую ИБ."
    }
}

function Get-AuthArgs {
    $result = @()
    if ($UserName) { $result += "/N$UserName" }
    if ($Password) { $result += "/P$Password" }
    return $result
}

function Invoke-Designer {
    param([string]$Operation, [string[]]$OperationArgs)
    $logDir = Join-Path $RepoRoot "build\logs"
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $safeName = ($Operation -replace '[^A-Za-z0-9_-]', '_')
    $logFile = Join-Path $logDir "$safeName.log"
    $resultFile = Join-Path $logDir "$safeName.result"
    Remove-Item $logFile, $resultFile -Force -ErrorAction SilentlyContinue

    $args = @("DESIGNER", "/F", $InfoBasePath)
    $args += Get-AuthArgs
    $args += @("/DisableStartupMessages", "/DisableStartupDialogs")
    $args += $OperationArgs
    $args += @("/Out", $logFile, "/DumpResult", $resultFile)

    Write-Host ""
    Write-Host "==> $Operation" -ForegroundColor Cyan
    & $script:OneCExe @args
    $exitCode = $LASTEXITCODE

    $batchCode = $null
    if (Test-Path $resultFile) {
        $raw = Get-Content $resultFile -Raw -ErrorAction SilentlyContinue
        if ($raw) {
            $digits = $raw -replace '[^0-9-]', ''
            if ($digits -match '^-?\d+$') { $batchCode = [int]$digits }
        }
    }

    if ($exitCode -ne 0 -or $batchCode -ne 0) {
        $log = if (Test-Path $logFile) { Get-Content $logFile -Raw -ErrorAction SilentlyContinue } else { "" }
        throw "Операция '$Operation' завершилась ошибкой. ExitCode=$exitCode; DumpResult=$batchCode.$([Environment]::NewLine)$log"
    }
}

$InfoBasePath = (Resolve-Path $InfoBasePath).Path
Assert-FileInfoBase $InfoBasePath

if (-not (Test-Path $SourcePath -PathType Container)) { throw "Каталог исходников не найден: $SourcePath" }
$configXml = Join-Path $SourcePath "Configuration.xml"
if (-not (Test-Path $configXml -PathType Leaf)) {
    throw "В $SourcePath нет Configuration.xml. Сначала выполните bootstrap/export расширения Orbitas в этот каталог. См. docs/BUILD.md"
}

$outDir = Split-Path $OutputFile -Parent
if ($outDir) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$OutputFile = [System.IO.Path]::GetFullPath($OutputFile)
$script:OneCExe = Resolve-1CExecutable $V8Path

Write-Host "Платформа: $script:OneCExe"
Write-Host "Исходники: $SourcePath"
Write-Host "Build ИБ: $InfoBasePath"
Write-Host "Расширение: $ExtensionName"
Write-Host "Артефакт: $OutputFile"

Invoke-Designer "01-load-extension-from-files" @("/LoadConfigFromFiles", $SourcePath, "-Extension", $ExtensionName, "-updateConfigDumpInfo")
if (-not $SkipUpdateDBCfg) {
    Invoke-Designer "02-update-db-extension" @("/UpdateDBCfg", "-Extension", $ExtensionName)
}
Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
Invoke-Designer "03-dump-cfe" @("/DumpCfg", $OutputFile, "-Extension", $ExtensionName)

if (-not (Test-Path $OutputFile -PathType Leaf)) { throw "1С вернула успех, но файл не создан: $OutputFile" }
$size = (Get-Item $OutputFile).Length
if ($size -le 0) { throw "Создан пустой CFE: $OutputFile" }

Write-Host ""
Write-Host "Готово: $OutputFile ($size bytes)" -ForegroundColor Green
