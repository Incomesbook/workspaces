$ErrorActionPreference = "Continue"

$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$Report="$AuditRoot\AI_CHATS_BACKUP_READINESS_AUDIT_$Stamp.md"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

"# AI Chats Backup Readiness Audit" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"READ ONLY. No copy. No delete. No git add. No commit. No push." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

$ChatRoots=@(
"J:\_AI_CHATS_ОБЩИЕ",
"J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats",
"J:\ClaudeData",
"J:\ClaudeHub",
"J:\Setup_VcCode_Workspace\S02_Shared_VSCode",
"J:\VSCode-Portable\data\user-data\User",
"J:\VSCode-Live\Code\User",
"$env:APPDATA\Code\User",
"$env:APPDATA\Claude",
"$env:LOCALAPPDATA\Claude",
"$env:USERPROFILE\.claude"
)

"## Chat and AI storage roots" | Add-Content -LiteralPath $Report -Encoding UTF8

foreach($Root in $ChatRoots){
  "`n### $Root" | Add-Content -LiteralPath $Report -Encoding UTF8
  "- Exists: $(Test-Path -LiteralPath $Root)" | Add-Content -LiteralPath $Report -Encoding UTF8

  if(Test-Path -LiteralPath $Root){
    $files = Get-ChildItem -LiteralPath $Root -File -Recurse -Force -ErrorAction SilentlyContinue
    $count = ($files | Measure-Object).Count
    $mb = [math]::Round((($files | Measure-Object -Property Length -Sum).Sum / 1MB),2)

    "- Files: $count" | Add-Content -LiteralPath $Report -Encoding UTF8
    "- MB: $mb" | Add-Content -LiteralPath $Report -Encoding UTF8

    "`nTop-level:" | Add-Content -LiteralPath $Report -Encoding UTF8
    Get-ChildItem -LiteralPath $Root -Force -ErrorAction SilentlyContinue |
      Select-Object Mode,Name,LastWriteTime |
      Out-String -Width 1000 |
      Add-Content -LiteralPath $Report -Encoding UTF8

    "`nLargest files top 20:" | Add-Content -LiteralPath $Report -Encoding UTF8
    $files |
      Sort-Object Length -Descending |
      Select-Object -First 20 FullName,@{Name='MB';Expression={[math]::Round($_.Length/1MB,2)}},LastWriteTime |
      Out-String -Width 1200 |
      Add-Content -LiteralPath $Report -Encoding UTF8

    "`nLikely chat/export/runtime files by extension:" | Add-Content -LiteralPath $Report -Encoding UTF8
    $files |
      Where-Object { $_.Extension -match "\.(json|jsonl|md|txt|html|sqlite|db|log)$" } |
      Group-Object Extension |
      Sort-Object Count -Descending |
      Select-Object Name,Count |
      Out-String -Width 500 |
      Add-Content -LiteralPath $Report -Encoding UTF8
  }
}

"`n## Project context capsule candidates" | Add-Content -LiteralPath $Report -Encoding UTF8

$ProjectRoots=@(
"J:\Setup_VcCode_Workspace\S20_Projects",
"J:\ПРОЕКТЫ",
"C:\Users\IgorK\OneDrive\Рабочий стол\ПРОЕКТЫ"
)

$CapsuleNames=@(
"PROJECT_STATE.md",
"NEXT_ACTIONS.md",
"AI_MEMORY.md",
"CHATS_INDEX.md",
"DECISIONS.md",
"RESTORE_NOTES.md",
"PROJECT_RULES.md"
)

foreach($Root in $ProjectRoots){
  "`n### $Root" | Add-Content -LiteralPath $Report -Encoding UTF8
  "- Exists: $(Test-Path -LiteralPath $Root)" | Add-Content -LiteralPath $Report -Encoding UTF8

  if(Test-Path -LiteralPath $Root){
    Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction SilentlyContinue |
      Select-Object -First 30 |
      ForEach-Object {
        $Project=$_.FullName
        "`nProject: $Project" | Add-Content -LiteralPath $Report -Encoding UTF8
        foreach($Name in $CapsuleNames){
          $Full=Join-Path $Project $Name
          "- $Name exists: $(Test-Path -LiteralPath $Full)" | Add-Content -LiteralPath $Report -Encoding UTF8
        }
      }
  }
}

"`n## GitHub backup readiness decision" | Add-Content -LiteralPath $Report -Encoding UTF8
@(
"- Normal GitHub Git is OK only for small markdown indexes, manifests, scripts, and context capsules.",
"- Large raw chats/jsonl/sqlite/video/archive files need Git LFS, encrypted archive, or separate backup strategy.",
"- Web/Desktop chat continuity is not proven until exports and restore tests exist.",
"- Next step after this audit: save plan files into workspaces, then build AI_CHATS_EXPORT_IMPORT_MANIFEST."
) | Add-Content -LiteralPath $Report -Encoding UTF8

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 260
