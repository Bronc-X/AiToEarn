$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  throw 'Run this script from an elevated PowerShell window: Start menu -> PowerShell -> Run as administrator.'
}

function Repair-DockerProgramDataAcl {
  $dockerData = 'C:\ProgramData\DockerDesktop'
  if (-not (Test-Path -LiteralPath $dockerData)) {
    return
  }

  Write-Host "Repairing Docker Desktop data folder owner: $dockerData"
  $acl = Get-Acl -LiteralPath $dockerData
  $adminSid = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
  $acl.SetOwner($adminSid)
  Set-Acl -LiteralPath $dockerData -AclObject $acl
}

Repair-DockerProgramDataAcl

winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
wsl --install

Write-Host ''
Write-Host 'If Windows asks for a reboot, reboot before running docker compose.'
