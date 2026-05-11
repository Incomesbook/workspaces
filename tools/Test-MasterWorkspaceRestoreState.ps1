$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"

Write-Host "=== MASTER WORKSPACE RESTORE STATE CHECK ===" -ForegroundColor Cyan

$Paths=@(
"J:\Setup_VcCode_Workspace",
"J:\Setup_VcCode_Workspace\S10_GitHub\workspaces",
"J:\Setup_VcCode_Workspace\S20_Projects",
"J:\_AI_CHATS_ОБЩИЕ",
"J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats",
"J:\ClaudeData",
"J:\ClaudeHub"
)

foreach($p in $Paths){
  [pscustomobject]@{
    Path=$p
    Exists=(Test-Path -LiteralPath $p)
  }
} | Format-Table -AutoSize

Write-Host "`n=== REQUIRED CONTROL FILES ===" -ForegroundColor Cyan

$Files=@(
"00_START_HERE\CURRENT_STOP_POINT.md",
"01_WORKSPACES\Igor_Master_Workspace.code-workspace",
"02_PROJECTS_INDEX\PROJECTS_MASTER_INDEX.md",
"03_AI_CHATS\CHATS_MASTER_INDEX.md",
"04_SETTINGS\AUTOMATION_PROTECTION_MAP.md",
"04_SETTINGS\SYNC_POLICY.md",
"05_RESTORE\MASTER_RESTORE_PLAN.md",
"tools\New-MasterWorkspaceSyncDryRun.ps1"
)

foreach($f in $Files){
  $full=Join-Path $Repo $f
  [pscustomobject]@{
    File=$f
    Exists=(Test-Path -LiteralPath $full)
  }
} | Format-Table -AutoSize

Write-Host "`n=== GIT STATUS ===" -ForegroundColor Cyan
git --no-pager -C $Repo status --short --branch

Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
git --no-pager -C $Repo log --oneline -8

Write-Host "`n=== DONE ===" -ForegroundColor Green
