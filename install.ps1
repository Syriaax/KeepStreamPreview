# Sets up everything for KeepStreamPreview: installs Git and Node.js if missing, builds Vencord from source
# with this plugin, injects it into Discord Stable, enables the plugin and restarts Discord.
# Usage: double-click install.cmd, or run: powershell -ExecutionPolicy Bypass -File install.ps1 [-VencordDir <path>]
param(
    [string]$VencordDir = "$env:USERPROFILE\Vencord"
)

$ErrorActionPreference = "Stop"
$pluginName = "KeepStreamPreview"
$pluginSrc = Join-Path $PSScriptRoot "index.ts"
$discordDir = "$env:LOCALAPPDATA\Discord"
$settingsFile = "$env:APPDATA\Vencord\settings\settings.json"

function Write-Step($text) {
    Write-Host ""
    Write-Host "==> $text" -ForegroundColor Cyan
}

function Assert-ExitCode($what) {
    if ($LASTEXITCODE -ne 0) { throw "$what failed with exit code $LASTEXITCODE" }
}

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-WithWinget($id) {
    if (-not (Test-Command "winget")) {
        throw "winget not found. Install 'App Installer' from the Microsoft Store, then run this again."
    }
    winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements
    Update-Path
}

function Get-NodeMajor {
    if (-not (Test-Command "node")) { return 0 }
    return [int](node -p "process.versions.node.split('.')[0]")
}

if (-not (Test-Path "$discordDir\Update.exe")) {
    throw "Discord (Stable) not found in $discordDir. Install Discord from discord.com, start it once, then run this again."
}

Write-Step "Checking Git"
if (-not (Test-Command "git")) {
    Install-WithWinget "Git.Git"
    if (-not (Test-Command "git")) { throw "Git installation failed. Install it from git-scm.com and run this again." }
}

Write-Step "Checking Node.js (22 or newer)"
if ((Get-NodeMajor) -lt 22) {
    Install-WithWinget "OpenJS.NodeJS.LTS"
    if ((Get-NodeMajor) -lt 22) { throw "Node.js 22+ installation failed. Install it from nodejs.org and run this again." }
}

if (Test-Path (Join-Path $VencordDir ".git")) {
    Write-Step "Updating Vencord in $VencordDir"
    git -C $VencordDir pull --ff-only
    Assert-ExitCode "git pull"
} else {
    Write-Step "Cloning Vencord into $VencordDir"
    git clone https://github.com/Vendicated/Vencord.git $VencordDir
    Assert-ExitCode "git clone"
}

Write-Step "Copying plugin"
$pluginDir = Join-Path $VencordDir "src\userplugins\keepStreamPreview"
New-Item -ItemType Directory -Force $pluginDir | Out-Null
Copy-Item $pluginSrc (Join-Path $pluginDir "index.ts") -Force

Push-Location $VencordDir
try {
    # Run the pnpm version Vencord pins, through npx, so no global install is needed
    $packageManager = (Get-Content "package.json" -Raw | ConvertFrom-Json).packageManager
    $pnpm = if ($packageManager) { $packageManager -replace "\+.*$", "" } else { "pnpm@latest" }

    Write-Step "Installing dependencies"
    npx.cmd --yes $pnpm install --frozen-lockfile
    Assert-ExitCode "pnpm install"

    Write-Step "Building Vencord"
    npx.cmd --yes $pnpm build
    Assert-ExitCode "pnpm build"

    Write-Step "Closing Discord"
    Get-Process Discord -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2

    Write-Step "Injecting Vencord into Discord Stable"
    node scripts\runInstaller.mjs -- --install -branch stable
    Assert-ExitCode "Vencord installer"
} finally {
    Pop-Location
}

Write-Step "Enabling $pluginName"
$enableScript = Join-Path $env:TEMP "enable-vencord-plugin.js"
@'
const fs = require("fs"), path = require("path");
const [file, name] = process.argv.slice(2);
const settings = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
settings.plugins ??= {};
settings.plugins[name] = { ...settings.plugins[name], enabled: true };
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, JSON.stringify(settings, null, 4));
'@ | Set-Content -Path $enableScript -Encoding ASCII
node $enableScript $settingsFile $pluginName
Assert-ExitCode "Enabling the plugin"
Remove-Item $enableScript

Write-Step "Starting Discord"
Start-Process "$discordDir\Update.exe" -ArgumentList "--processStart", "Discord.exe"

Write-Host ""
Write-Host "Done. KeepStreamPreview is installed and enabled." -ForegroundColor Green
