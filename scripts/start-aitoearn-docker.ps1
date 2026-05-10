$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw 'Docker is not available on PATH. Install Docker Desktop first, then reopen PowerShell.'
}

Push-Location (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..'))
try {
  docker compose up -d
  Write-Host ''
  Write-Host 'AiToEarn should be available at http://localhost:8080'
}
finally {
  Pop-Location
}
