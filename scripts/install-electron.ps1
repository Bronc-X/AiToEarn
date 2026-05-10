$ErrorActionPreference = 'Stop'

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')
$electronDir = Join-Path $root 'project\aitoearn-electron'
$nodeDir = Join-Path $root '.local-tools\node-v20'
$nodeExe = Join-Path $nodeDir 'node.exe'
$npmCmd = Join-Path $nodeDir 'npm.cmd'

if (-not (Test-Path -LiteralPath $nodeExe)) {
  throw "Portable Node 20 is missing at $nodeExe. Re-run setup or restore .local-tools/node-v20."
}

$env:Path = "$nodeDir;$env:Path"
$env:npm_config_better_sqlite3_binary_host = 'https://npmmirror.com/mirrors/better-sqlite3'
$env:npm_config_better_sqlite3_binary_host_mirror = 'https://npmmirror.com/mirrors/better-sqlite3'
$env:npm_config_build_from_source = 'false'

Write-Host "Using Node: $(& $nodeExe --version)"
Write-Host "Using npm: $(& $npmCmd --version)"

$nodeModules = Join-Path $electronDir 'node_modules'
if (Test-Path -LiteralPath $nodeModules) {
  $target = Resolve-Path -LiteralPath $electronDir
  $resolved = Resolve-Path -LiteralPath $nodeModules
  if (-not $resolved.Path.StartsWith($target.Path, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove outside Electron project: $($resolved.Path)"
  }
  Remove-Item -LiteralPath $resolved.Path -Recurse -Force
}

Push-Location $electronDir
try {
  & $npmCmd install
}
finally {
  Pop-Location
}
