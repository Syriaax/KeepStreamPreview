# Builds Vencord from source with the KeepStreamPreview user plugin and injects it into Discord.
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1 [-VencordDir <path>]
param(
    [string]$VencordDir = "$env:USERPROFILE\Vencord"
)

$ErrorActionPreference = "Stop"
$pluginSrc = Join-Path $PSScriptRoot "index.ts"

foreach ($cmd in "git", "node", "npm") {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd not found. Install it first (git-scm.com / nodejs.org)."
    }
}

if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "Installing pnpm..."
    npm install -g pnpm
}

if (Test-Path (Join-Path $VencordDir ".git")) {
    Write-Host "Updating Vencord in $VencordDir..."
    git -C $VencordDir pull --ff-only
} else {
    Write-Host "Cloning Vencord into $VencordDir..."
    git clone https://github.com/Vendicated/Vencord.git $VencordDir
}

$pluginDir = Join-Path $VencordDir "src\userplugins\keepStreamPreview"
New-Item -ItemType Directory -Force $pluginDir | Out-Null
Copy-Item $pluginSrc (Join-Path $pluginDir "index.ts") -Force
Write-Host "Plugin copied to $pluginDir"

Push-Location $VencordDir
try {
    pnpm install --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { throw "pnpm install failed" }
    pnpm build
    if ($LASTEXITCODE -ne 0) { throw "pnpm build failed" }
    # Interactive: pick your Discord install (Stable) when asked.
    pnpm inject
    if ($LASTEXITCODE -ne 0) { throw "pnpm inject failed" }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Done. Restart Discord fully, then enable KeepStreamPreview under Settings > Vencord > Plugins."
