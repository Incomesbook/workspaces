$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$Project="J:\ПРОЕКТЫ\G01_All_About_Trading"
$Map="$Repo\06_AI_CONTEXT_CAPSULE\G01_ALL_ABOUT_TRADING\G01_SUBPROJECTS_MAP.md"

New-Item -ItemType Directory -Force (Split-Path $Map -Parent) | Out-Null

"# G01 Subprojects Map" | Set-Content -LiteralPath $Map -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Map -Encoding UTF8
"" | Add-Content -LiteralPath $Map -Encoding UTF8
"## Purpose" | Add-Content -LiteralPath $Map -Encoding UTF8
"This is a GitHub-safe structure map only. It does not copy raw project files, chats, credentials, logs, caches, installers, or large files." | Add-Content -LiteralPath $Map -Encoding UTF8
"" | Add-Content -LiteralPath $Map -Encoding UTF8

"## Project root" | Add-Content -LiteralPath $Map -Encoding UTF8
"- Path: $Project" | Add-Content -LiteralPath $Map -Encoding UTF8
"- Exists: $(Test-Path -LiteralPath $Project)" | Add-Content -LiteralPath $Map -Encoding UTF8
"- Is Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))" | Add-Content -LiteralPath $Map -Encoding UTF8
"" | Add-Content -LiteralPath $Map -Encoding UTF8

if(Test-Path -LiteralPath $Project){
  "## Top-level folders" | Add-Content -LiteralPath $Map -Encoding UTF8

  $Top = Get-ChildItem -LiteralPath $Project -Directory -Force -ErrorAction SilentlyContinue | Sort-Object Name

  foreach($d in $Top){
    "- $($d.Name)" | Add-Content -LiteralPath $Map -Encoding UTF8
  }

  "" | Add-Content -LiteralPath $Map -Encoding UTF8
  "## Subproject summary" | Add-Content -LiteralPath $Map -Encoding UTF8
  "| Folder | Direct child folders | Direct files | Size MB | Has .vscode | Has AI memory | Has API/key-like folder | Has large files >50MB |" | Add-Content -LiteralPath $Map -Encoding UTF8
  "|---|---:|---:|---:|---:|---:|---:|---:|" | Add-Content -LiteralPath $Map -Encoding UTF8

  foreach($d in $Top){
    $directDirs=(Get-ChildItem -LiteralPath $d.FullName -Directory -Force -ErrorAction SilentlyContinue | Measure-Object).Count
    $directFiles=(Get-ChildItem -LiteralPath $d.FullName -File -Force -ErrorAction SilentlyContinue | Measure-Object).Count
    $allFiles=Get-ChildItem -LiteralPath $d.FullName -File -Recurse -Force -ErrorAction SilentlyContinue
    $sizeMb=[math]::Round((($allFiles | Measure-Object Length -Sum).Sum / 1MB),2)
    $hasVscode=Test-Path -LiteralPath (Join-Path $d.FullName ".vscode")
    $hasAiMemory=[bool](Get-ChildItem -LiteralPath $d.FullName -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "(?i)(AI_Memory|Chat_Root|Claude|Codex|Copilot|Gemini)" } | Select-Object -First 1)
    $hasApi=[bool](Get-ChildItem -LiteralPath $d.FullName -Directory -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "(?i)(API|Keys|IDs|Credentials|Private|Access)" } | Select-Object -First 1)
    $hasLarge=[bool]($allFiles | Where-Object { $_.Length -gt 50MB } | Select-Object -First 1)

    "| $($d.Name) | $directDirs | $directFiles | $sizeMb | $hasVscode | $hasAiMemory | $hasApi | $hasLarge |" |
      Add-Content -LiteralPath $Map -Encoding UTF8
  }

  "" | Add-Content -LiteralPath $Map -Encoding UTF8
  "## Large-file warning" | Add-Content -LiteralPath $Map -Encoding UTF8
  "Some G01 subprojects contain large files, installers, runtime caches, PDF/MP3 files, and jsonl AI exports. These must not be pushed with normal Git." | Add-Content -LiteralPath $Map -Encoding UTF8

  "" | Add-Content -LiteralPath $Map -Encoding UTF8
  "## Next decision" | Add-Content -LiteralPath $Map -Encoding UTF8
  "Handle G01 subproject-by-subproject. Create separate capsules before Git cleanup or GitHub publishing." | Add-Content -LiteralPath $Map -Encoding UTF8
}

Write-Host "MAP:" -ForegroundColor Green
Write-Host $Map
Get-Content -LiteralPath $Map -Tail 120
