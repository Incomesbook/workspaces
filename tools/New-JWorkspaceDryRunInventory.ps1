$ErrorActionPreference = "Continue"

$Repo = "J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$OutDir = Join-Path $Repo "02_PROJECTS_INDEX"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Report = Join-Path $OutDir "J_WORKSPACE_DRY_RUN_$Stamp.md"

New-Item -ItemType Directory -Force $OutDir | Out-Null

"# J Workspace Dry Run Inventory" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"DRY RUN ONLY. No copy. No delete. No push." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

"## Important folders" | Add-Content -LiteralPath $Report -Encoding UTF8

$Folders = @(
  "J:\Setup_VcCode_Workspace",
  "J:\Setup_VcCode_Workspace\S02_Shared_VSCode",
  "J:\Setup_VcCode_Workspace\S06_Shared_Automation",
  "J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats",
  "J:\Setup_VcCode_Workspace\S10_GitHub",
  "J:\_AI_CHATS_ОБЩИЕ",
  "J:\_AI_CHATS_ОБЩИЕ\CLAUDE",
  "J:\_AI_CHATS_ОБЩИЕ\CODEX",
  "J:\ClaudeData",
  "J:\ClaudeHub",
  "J:\ПРОЕКТЫ"
)

foreach ($F in $Folders) {
  "- $F | exists=$(Test-Path -LiteralPath $F)" | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Active protected automation" | Add-Content -LiteralPath $Report -Encoding UTF8

Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object {
    $_.CommandLine -like "*ProjectChatAutomation.ps1*" -or
    $_.CommandLine -like "*Watch-JWorkspaceProjectBootstrap.ps1*"
  } |
  Select-Object ProcessId,Name,CommandLine |
  Out-String -Width 900 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Existing workspaces" | Add-Content -LiteralPath $Report -Encoding UTF8

Get-ChildItem "J:\Setup_VcCode_Workspace","J:\_AI_CHATS_ОБЩИЕ","J:\ПРОЕКТЫ" -Depth 6 -File -Filter "*.code-workspace" -ErrorAction SilentlyContinue |
  Select-Object FullName,Length,LastWriteTime |
  Out-String -Width 900 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Git status of workspaces repo" | Add-Content -LiteralPath $Report -Encoding UTF8
git --no-pager -C $Repo status --short --branch | Add-Content -LiteralPath $Report -Encoding UTF8

Write-Host "DRY RUN REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 120
