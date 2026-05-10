$ErrorActionPreference = 'Stop'
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
  $PSNativeCommandUseErrorActionPreference = $false
}

$repo = 'yikart/AiToEarn'
$forkRepo = 'Bronc-X/AiToEarn'
$upstreamRemote = "https://github.com/$repo.git"
$forkRemote = "https://github.com/$forkRepo.git"

$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath;$env:Path"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  $ghAvailable = $false
}
else {
  $ghAvailable = $true
}

function Test-GitRemote {
  param([Parameter(Mandatory = $true)][string]$Url)

  git ls-remote $Url HEAD *> $null
  return $LASTEXITCODE -eq 0
}

function Set-GitRemote {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Url
  )

  $currentUrl = git remote get-url $Name 2>$null
  if ($LASTEXITCODE -ne 0) {
    git remote add $Name $Url
  }
  elseif ($currentUrl -ne $Url) {
    git remote set-url $Name $Url
  }
}

if (Test-GitRemote -Url $forkRemote) {
  Write-Host "Fork is reachable: $forkRemote"
}
else {
  if (-not $ghAvailable) {
    throw 'GitHub CLI is not installed and the fork remote is not reachable. Install gh or create the fork manually.'
  }

  $authStatus = gh auth status 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not logged in. Starting gh auth login...'
    gh auth login
    if ($LASTEXITCODE -ne 0) {
      throw 'GitHub login did not finish successfully. Re-run this script after logging in.'
    }
  }

  Write-Host "Creating fork: $forkRepo"
  gh repo fork $repo --remote=false --clone=false
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create fork for $repo. Check GitHub auth and repository access."
  }
}

Set-GitRemote -Name 'upstream' -Url $upstreamRemote
Set-GitRemote -Name 'origin' -Url $forkRemote

if (-not (Test-GitRemote -Url 'origin')) {
  throw "Origin is configured as $forkRemote, but it is not reachable yet. Confirm the fork exists under $forkRepo."
}

Write-Host ''
Write-Host 'Remotes are ready:'
git remote -v
Write-Host ''
Write-Host 'When you want to push your branch: git push -u origin main'
