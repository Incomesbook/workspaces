$ErrorActionPreference = "Continue"

$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$Report="$AuditRoot\MASTER_WORKSPACE_SYNC_DRYRUN_$Stamp.md"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

"# Master Workspace Sync Dry Run" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"READ ONLY. No copy. No delete. No commit. No push. No schedule created." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

"## Main control repo" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Repo: $Repo" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Exists: $(Test-Path -LiteralPath $Repo)" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Git status" | Add-Content -LiteralPath $Report -Encoding UTF8
git --no-pager -C $Repo status --short --branch 2>&1 | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Recent commits" | Add-Content -LiteralPath $Report -Encoding UTF8
git --no-pager -C $Repo log --oneline -10 2>&1 | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Protected automation processes" | Add-Content -LiteralPath $Report -Encoding UTF8
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object {
    $_.CommandLine -like "*ProjectChatAutomation.ps1*" -or
    $_.CommandLine -like "*Watch-JWorkspaceProjectBootstrap.ps1*" -or
    $_.CommandLine -like "*mcp-server-filesystem*" -or
    $_.CommandLine -like "*server-filesystem*"
  } |
  Select-Object ProcessId,Name,CommandLine |
  Out-String -Width 1200 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Control repo large tracked files over 50 MB" | Add-Content -LiteralPath $Report -Encoding UTF8
$large=@()
git -C $Repo ls-files 2>$null | ForEach-Object {
  $p=Join-Path $Repo $_
  if(Test-Path -LiteralPath $p){
    $i=Get-Item -LiteralPath $p
    if($i.Length -gt 50MB){
      $large += [pscustomobject]@{File=$_;MB=[math]::Round($i.Length/1MB,2)}
    }
  }
}
if($large){
  $large | Format-Table -AutoSize | Out-String -Width 1000 | Add-Content -LiteralPath $Report -Encoding UTF8
} else {
  "- OK: no tracked files over 50 MB" | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Chat roots summary" | Add-Content -LiteralPath $Report -Encoding UTF8
$ChatRoots=@(
"J:\_AI_CHATS_ОБЩИЕ",
"J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats",
"J:\ClaudeData",
"J:\ClaudeHub"
)

foreach($Root in $ChatRoots){
  "`n### $Root" | Add-Content -LiteralPath $Report -Encoding UTF8
  "- Exists: $(Test-Path -LiteralPath $Root)" | Add-Content -LiteralPath $Report -Encoding UTF8

  if(Test-Path -LiteralPath $Root){
    $files=Get-ChildItem -LiteralPath $Root -File -Recurse -Force -ErrorAction SilentlyContinue
    "- Files: $(($files | Measure-Object).Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
    "- MB: $([math]::Round((($files | Measure-Object -Property Length -Sum).Sum / 1MB),2))" | Add-Content -LiteralPath $Report -Encoding UTF8

    "Top-level:" | Add-Content -LiteralPath $Report -Encoding UTF8
    Get-ChildItem -LiteralPath $Root -Force -ErrorAction SilentlyContinue |
      Select-Object Mode,Name,LastWriteTime |
      Out-String -Width 1000 |
      Add-Content -LiteralPath $Report -Encoding UTF8
  }
}

"`n## Project roots summary" | Add-Content -LiteralPath $Report -Encoding UTF8
$ProjectRoots=@(
"J:\Setup_VcCode_Workspace\S20_Projects",
"J:\ПРОЕКТЫ",
"C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ",
"C:\Users\IgorK\OneDrive\iNCOMEBOOK"
)

foreach($Root in $ProjectRoots){
  "`n### $Root" | Add-Content -LiteralPath $Report -Encoding UTF8
  "- Exists: $(Test-Path -LiteralPath $Root)" | Add-Content -LiteralPath $Report -Encoding UTF8

  if(Test-Path -LiteralPath $Root){
    Get-ChildItem -LiteralPath $Root -Force -ErrorAction SilentlyContinue |
      Select-Object Mode,Name,LastWriteTime |
      Out-String -Width 1000 |
      Add-Content -LiteralPath $Report -Encoding UTF8
  }
}

"`n## Git repos found under project roots, limited depth" | Add-Content -LiteralPath $Report -Encoding UTF8
foreach($Root in $ProjectRoots){
  if(Test-Path -LiteralPath $Root){
    Get-ChildItem -LiteralPath $Root -Directory -Force -Recurse -Depth 6 -ErrorAction SilentlyContinue |
      Where-Object {$_.Name -eq ".git"} |
      ForEach-Object {
        $r=Split-Path $_.FullName -Parent
        "`nRepo: $r" | Add-Content -LiteralPath $Report -Encoding UTF8
        git --no-pager -C $r status --short --branch 2>&1 | Select-Object -First 20 | Add-Content -LiteralPath $Report -Encoding UTF8
        git -C $r remote -v 2>&1 | Add-Content -LiteralPath $Report -Encoding UTF8
      }
  }
}

"`n## Decision" | Add-Content -LiteralPath $Report -Encoding UTF8
@(
"- This was read-only.",
"- No files copied.",
"- No files deleted.",
"- No commit performed.",
"- No push performed.",
"- No scheduled task created.",
"- Next step: review report and then create controlled weekly/biweekly sync script."
) | Add-Content -LiteralPath $Report -Encoding UTF8

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 220
