<#
.SYNOPSIS
    Clone repositories script for Windows development environment

.DESCRIPTION
    Clones a configured list of repositories from GitHub.
    Uses configuration from config.ps1

.PARAMETER Config
    Path to configuration file (default: .\config.ps1)

.EXAMPLE
    .\clone-repos.ps1
    Clone all repositories defined in config.ps1

.EXAMPLE
    .\clone-repos.ps1 -Config .\my-config.ps1
    Use custom configuration file
#>

param(
    [string]$Config = ".\config.ps1"
)

# Load shared functions and config
. "$PSScriptRoot\functions.ps1"
Load-Config -ConfigPath $Config

################################################################################
# Validation
################################################################################

Write-Section "Repository Cloning"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "Git is not installed or not in PATH"
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Err "GitHub CLI (gh) is not installed or not in PATH"
    Write-Info "Please run setup.ps1 first"
    exit 1
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Not authenticated with GitHub"
    Write-Info "Please run: gh auth login"
    exit 1
}

Write-Ok "Git and GitHub CLI are available"

################################################################################
# Repository Cloning
################################################################################

if (-not $GitHubOrg) {
    Write-Err "GitHubOrg is not configured in $Config"
    Write-Info "Please set the GitHub organization or username in config.ps1"
    exit 1
}

if ($null -eq $RepositoriesToClone -or $RepositoriesToClone.Count -eq 0) {
    Write-Warn "No repositories configured to clone"
    Write-Info "Please add repositories to RepositoriesToClone array in config.ps1"
    Write-Info "Example:"
    Write-Host '  $RepositoriesToClone = @(' -ForegroundColor DarkGray
    Write-Host '      "repo1"' -ForegroundColor DarkGray
    Write-Host '      "repo2"' -ForegroundColor DarkGray
    Write-Host '      "repo3"' -ForegroundColor DarkGray
    Write-Host '  )' -ForegroundColor DarkGray
    exit 0
}

if (-not (Test-Path $CodeDirectory)) {
    Write-Info "Creating directory: $CodeDirectory"
    New-Item -ItemType Directory -Path $CodeDirectory | Out-Null
}

Write-Info "Cloning repositories to: $CodeDirectory"
Write-Info "GitHub Organization: $GitHubOrg"
Write-Info "Repositories to clone: $($RepositoriesToClone.Count)"
Write-Host ""

Set-Location $CodeDirectory

$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($repo in $RepositoriesToClone) {
    $repoPath = Join-Path $CodeDirectory $repo

    if (Test-Path $repoPath) {
        Write-Info "$repo - already exists, skipping"
        $skipCount++
        continue
    }

    Write-Info "Cloning $repo..."

    $repoUrl = "https://github.com/$GitHubOrg/$repo.git"
    git clone $repoUrl 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$repo cloned successfully"
        $successCount++
    }
    else {
        Write-Err "$repo failed to clone"
        $failCount++
    }
}

################################################################################
# Summary
################################################################################

Write-Section "Cloning Complete"

Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Successfully cloned: " -NoNewline; Write-Host $successCount -ForegroundColor Green
Write-Host "  Skipped (already exists): " -NoNewline; Write-Host $skipCount -ForegroundColor Yellow
Write-Host "  Failed: " -NoNewline; Write-Host $failCount -ForegroundColor Red
Write-Host ""

if ($failCount -gt 0) {
    Write-Warn "Some repositories failed to clone. Check if they exist in the organization."
    Write-Info "You can verify repository names at: https://github.com/$GitHubOrg"
}
else {
    Write-Ok "All repositories processed successfully!"
}

Write-Info "Repositories location: $CodeDirectory"
