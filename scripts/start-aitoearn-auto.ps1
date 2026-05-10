$ErrorActionPreference = 'Stop'
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$installScript = Join-Path $PSScriptRoot 'install-docker-admin.ps1'
$appUrl = 'http://localhost:8080'
$healthUrl = 'http://127.0.0.1:8080/_nhealth'

function Write-Step {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Host ''
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-DockerReady {
  docker info *> $null
  return $LASTEXITCODE -eq 0
}

function Start-DockerDesktop {
  $candidates = @(
    (Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Docker\Docker\Docker Desktop.exe')
  )

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      Start-Process -FilePath $candidate | Out-Null
      return $true
    }
  }

  try {
    Start-Process 'Docker Desktop' | Out-Null
    return $true
  }
  catch {
    return $false
  }
}

function Wait-DockerReady {
  param([int]$TimeoutSeconds = 180)

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    if (Test-DockerReady) {
      return $true
    }
    Start-Sleep -Seconds 3
    Write-Host -NoNewline '.'
  }

  return $false
}

function Wait-AppReady {
  param([int]$TimeoutSeconds = 240)

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 5
      if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
        return $true
      }
    }
    catch {
      try {
        $response = Invoke-WebRequest -Uri $appUrl -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
          return $true
        }
      }
      catch {
        Start-Sleep -Seconds 5
        Write-Host -NoNewline '.'
      }
    }
  }

  return $false
}

Write-Step 'Checking Docker'
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host 'Docker is not installed or is not on PATH.' -ForegroundColor Yellow
  Write-Host 'Opening the Docker installer in an elevated PowerShell window...'
  Start-Process powershell.exe -Verb RunAs -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', "`"$installScript`""
  )
  Write-Host ''
  Write-Host 'After Docker finishes installing, reboot if Windows asks, then double-click START_AITOEARN.bat again.'
  exit 2
}

if (-not (Test-DockerReady)) {
  Write-Step 'Starting Docker Desktop'
  if (-not (Start-DockerDesktop)) {
    Write-Host 'Could not auto-start Docker Desktop. Open Docker Desktop manually, wait until it is running, then double-click START_AITOEARN.bat again.' -ForegroundColor Yellow
    exit 3
  }

  Write-Host 'Waiting for Docker Desktop to become ready' -NoNewline
  if (-not (Wait-DockerReady)) {
    Write-Host ''
    Write-Host 'Docker Desktop did not become ready in time. Open Docker Desktop manually and check its status.' -ForegroundColor Yellow
    exit 4
  }
  Write-Host ''
}

Write-Step 'Starting AiToEarn containers'
Push-Location $root
try {
  docker compose up -d
  if ($LASTEXITCODE -ne 0) {
    throw 'docker compose up -d failed.'
  }
}
finally {
  Pop-Location
}

Write-Step 'Waiting for AiToEarn web'
Write-Host 'Waiting for http://localhost:8080' -NoNewline
$ready = Wait-AppReady
Write-Host ''

if (-not $ready) {
  Write-Host 'The browser will open now, but the app may still be warming up. If the page is not ready, refresh after a minute.' -ForegroundColor Yellow
}

Write-Step 'Opening AiToEarn'
Start-Process $appUrl
Write-Host "Opened $appUrl"
