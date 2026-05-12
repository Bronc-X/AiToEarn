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

function Enable-DockerWindowsFeatures {
  $features = @(
    'Microsoft-Windows-Subsystem-Linux',
    'VirtualMachinePlatform'
  )

  foreach ($feature in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($state -ne 'Enabled') {
      Write-Host "Enabling Windows optional feature: $feature"
      Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart | Out-Null
    }
    else {
      Write-Host "Windows optional feature already enabled: $feature"
    }
  }
}

Enable-DockerWindowsFeatures

winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements
wsl --install --no-distribution
wsl --update

Write-Host ''
Write-Host 'Reboot Windows before running Docker if any feature or WSL command requested it.'
