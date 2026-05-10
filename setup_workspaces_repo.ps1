[CmdletBinding()]
param(
  [switch]$Push
)

$ErrorActionPreference = "Stop"

# ---------- CONFIG ----------
$RepoName = "workspaces"                 # GitHub repo name
$GitHubUser = "Incomesbook"              # your GitHub login
$Dest = "J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"  # local working dir
$MainBranch = "main"

# Choose ONE remote URL style:
# SSH (recommended if you already use git@github.com:...):
$RemoteUrl = "git@github.com:$GitHubUser/$RepoName.git"
# HTTPS alternative:
# $RemoteUrl = "https://github.com/$GitHubUser/$RepoName.git"

# ---------- SAFETY CHECKS ----------
Write-Host "==> Using Dest: $Dest"
if (-not (Test-Path $Dest)) {
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
}
Set-Location $Dest

# Init repo if needed
if (-not (Test-Path (Join-Path $Dest ".git"))) {
  git init | Out-Null
}

# Ensure main branch
git branch -M $MainBranch | Out-Null

# ---------- WRITE FILES ----------
# .gitignore (safe defaults for your case)
if (-not (Test-Path ".gitignore")) {
@'
# OS / editors
.DS_Store
Thumbs.db
*.lnk

# Node / Python typical
node_modules/
dist/
build/
__pycache__/
*.pyc

# VS Code (keep only small config files)
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/tasks.json

# Big caches / histories / collected FS / chat logs (important for your case)
**/.tmp/
**/_LIVE/
**/_COLLECTED_FS/
**/workspaceStorage/
**/Cache/
**/Code Cache/
**/GPUCache/
**/IndexedDB/
**/Local Storage/
**/Session Storage/
**/Service Worker/
**/Sentry/
**/logs/
**/*.log
**/*.ldb
**/*.sqlite
**/*.sqlite-journal
**/*.jsonl

# Secrets and local credentials must stay out of GitHub
**/.env
**/.env.*
**/api_keys.txt
**/*secret*
**/*secrets*
**/*credential*
**/*credentials*
**/*token*
**/*password*
**/S09_Shared_Private/

# Bulky generated media / archives
**/*.mp4
**/*.mkv
**/*.mov
**/*.avi
**/*.webm
**/*.zip
**/*.7z
**/*.rar

# PowerShell clutter
*.ps1~
'@ | Set-Content -Encoding UTF8 ".gitignore"
} else {
  Write-Host "==> .gitignore already exists; keeping existing file."
}

# Minimal README
if (-not (Test-Path "README.md")) {
@"
# $GitHubUser/$RepoName

Seed repository for workspace structure, scripts and configuration.

## What is intentionally NOT tracked
- Browser/app caches, VS Code workspaceStorage, _LIVE logs, _COLLECTED_FS, and other large generated data.
- See .gitignore for the full list.

## Next steps
- Add only curated folders/files (docs, scripts, configs).
"@ | Set-Content -Encoding UTF8 "README.md"
} else {
  Write-Host "==> README.md already exists; keeping existing file."
}

# Optional: keep a folder structure (empty folders need placeholder files)
New-Item -ItemType Directory -Force -Path ".vscode" | Out-Null
if (-not (Test-Path ".vscode/settings.json")) {
  @'
{
  "files.eol": "\n"
}
'@ | Set-Content -Encoding UTF8 ".vscode/settings.json"
}
if (-not (Test-Path ".vscode/extensions.json")) {
  @'
{
  "recommendations": []
}
'@ | Set-Content -Encoding UTF8 ".vscode/extensions.json"
}

# ---------- GIT ADD/COMMIT ----------
git add .gitignore README.md .vscode/settings.json .vscode/extensions.json

# Commit only if there is something to commit
$porcelain = git status --porcelain
if ($porcelain) {
  git commit -m "Initialize workspace seed repo" | Out-Null
  Write-Host "==> Committed."
} else {
  Write-Host "==> Nothing new to commit."
}

# ---------- REMOTE SETUP ----------
# If remote exists, show it; if not, add origin
$hasOrigin = $false
try {
  $remotes = git remote
  if ($remotes -match "^origin$") { $hasOrigin = $true }
} catch {}

if (-not $hasOrigin) {
  git remote add origin $RemoteUrl
  Write-Host "==> Added remote origin: $RemoteUrl"
} else {
  Write-Host "==> origin already exists:"
  git remote -v
}

# ---------- PUSH ----------
if ($Push.IsPresent) {
  Write-Host "==> Pushing to origin/$MainBranch ..."
  git push -u origin $MainBranch
  Write-Host "==> Done."
} else {
  Write-Host "==> Push skipped. Re-run with -Push only after reviewing git status and secret policy."
}
