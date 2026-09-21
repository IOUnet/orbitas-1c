#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$BuildInfoBasePath,
    [Parameter(Mandatory = $true)][string]$TestInfoBasePath,
    [string]$V8Path,
    [string]$UserName,
    [string]$Password,
    [string]$ExtensionName = "Orbitas",
    [string]$CfePath,
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($CfePath)) { $CfePath = Join-Path $RepoRoot "build\Orbitas.cfe" }
$CfePath = [System.IO.Path]::GetFullPath($CfePath)

function Resolve-1CExecutable {
    param([string]$Candidate)
    if ($Candidate) {
        if (Test-Path $Candidate -PathType Container) {
            foreach ($rel in @("1cv8.exe", "bin\1cv8.exe")) {
                $p = Join-Path $Candidate $rel
                if (Test-Path $p) { return (Resolve-Path $p).Path }
            }
        }
        if (Test-Path $Candidate -PathType Leaf) { return (Resolve-Path $Candidate).Path }
        throw "1С:Предприятие не найдено: $Candidate"
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
    if (-not (Test-Path (Join-Path $Path "1Cv8.1CD") -PathType Leaf)) { throw "Не найдена файловая ИБ: $Path" }
}

function Invoke-TestDesigner {
    param([string]$Operation, [string[]]$OperationArgs)
    $logDir = Join-Path $RepoRoot "build\logs"
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $logFile = Join-Path $logDir "$Operation.log"
    $resultFile = Join-Path $logDir "$Operation.result"
    Remove-Item $logFile, $resultFile -Force -ErrorAction SilentlyContinue

    $args = @("DESIGNER", "/F", $TestInfoBasePath)
    if ($UserName) { $args += "/N$UserName" }
    if ($Password) { $args += "/P$Password" }
    $args += @("/DisableStartupMessages", "/DisableStartupDialogs")
    $args += $OperationArgs
    $args += @("/Out", $logFile, "/DumpResult", $resultFile)

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
        throw "Ошибка '$Operation'. ExitCode=$exitCode; DumpResult=$batchCode.$([Environment]::NewLine)$log"
    }
}

$BuildInfoBasePath = (Resolve-Path $BuildInfoBasePath).Path
$TestInfoBasePath = (Resolve-Path $TestInfoBasePath).Path
Assert-FileInfoBase $BuildInfoBasePath
Assert-FileInfoBase $TestInfoBasePath
$script:OneCExe = Resolve-1CExecutable $V8Path

if (-not $SkipBuild) {
    $params = @{ InfoBasePath = $BuildInfoBasePath; V8Path = $script:OneCExe; ExtensionName = $ExtensionName; OutputFile = $CfePath }
    if ($UserName) { $params.UserName = $UserName }
    if ($Password) { $params.Password = $Password }
    & (Join-Path $PSScriptRoot "build.ps1") @params
}

if (-not (Test-Path $CfePath -PathType Leaf)) { throw "CFE не найден: $CfePath" }
if ((Get-Item $CfePath).Length -le 0) { throw "CFE пуст: $CfePath" }

Write-Host ""
Write-Host "Smoke-test CFE на отдельной тестовой ИБ" -ForegroundColor Cyan
Invoke-TestDesigner "10-smoke-load-cfe" @("/LoadCfg", $CfePath, "-Extension", $ExtensionName)
Invoke-TestDesigner "11-smoke-update-db" @("/UpdateDBCfg", "-Extension", $ExtensionName)

Write-Host ""
Write-Host "Smoke-test пройден: CFE загружается и применяется." -ForegroundColor Green
Write-Host "Это не заменяет YAxUnit/Vanessa и функциональную проверку Orbitas." -ForegroundColor Yellow
