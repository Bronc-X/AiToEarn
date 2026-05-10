$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  throw 'Run this script from an elevated PowerShell window: Start menu -> PowerShell -> Run as administrator.'
}

winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
wsl --install

Write-Host ''
Write-Host 'If Windows asks for a reboot, reboot before running docker compose.'
