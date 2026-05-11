$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$DetailCsv="$AuditRoot\AI_CHATS_SAFE_INDEX_DETAIL_$Stamp.csv"
$LocalReport="$AuditRoot\AI_CHATS_SAFE_INDEX_LOCAL_REPORT_$Stamp.md"
$SafeSummary="$Repo\03_AI_CHATS\AI_CHATS_SAFE_INDEX_SUMMARY.md"

New-Item -ItemType Directory -Force $AuditRoot,"$Repo\03_AI_CHATS" | Out-Null

$Roots=@(
  [pscustomobject]@{System="AI_COMMON";Root="J:\_AI_CHATS_ОБЩИЕ"},
  [pscustomobject]@{System="S08_GLOBAL_AI_CHATS";Root="J:\Setup_VcCode_Workspace\S08_Shared_Global_AI_Chats"},
  [pscustomobject]@{System="CLAUDE_DATA_J";Root="J:\ClaudeData"},
  [pscustomobject]@{System="CLAUDE_HUB_J";Root="J:\ClaudeHub"},
  [pscustomobject]@{System="CLAUDE_USERPROFILE";Root="$env:USERPROFILE\.claude"},
  [pscustomobject]@{System="CLAUDE_ROAMING";Root="$env:APPDATA\Claude"},
  [pscustomobject]@{System="CLAUDE_LOCAL";Root="$env:LOCALAPPDATA\Claude"},
  [pscustomobject]@{System="VSCODE_SHARED";Root="J:\Setup_VcCode_Workspace\S02_Shared_VSCode"},
  [pscustomobject]@{System="VSCODE_PORTABLE_USER";Root="J:\VSCode-Portable\data\user-data\User"},
  [pscustomobject]@{System="VSCODE_LIVE_USER";Root="J:\VSCode-Live\Code\User"},
  [pscustomobject]@{System="VSCODE_APPDATA_USER";Root="$env:APPDATA\Code\User"}
)

$Rows = New-Object System.Collections.Generic.List[object]
$ExcludedSecretLike = New-Object System.Collections.Generic.List[object]

foreach($R in $Roots){
  if(-not (Test-Path -LiteralPath $R.Root)){
    continue
  }

  $files = Get-ChildItem -LiteralPath $R.Root -File -Recurse -Force -ErrorAction SilentlyContinue

  foreach($f in $files){
    $rel = $f.FullName.Substring($R.Root.Length).TrimStart("\")
    $isSecretLike = ($f.Name -match "(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|\.env)" -or $rel -match "(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|\.env)")
    $isLikelyChat = ($f.Extension -match "(?i)\.(jsonl|json|md|txt|html|sqlite|db|log)$")

    if($isSecretLike){
      $ExcludedSecretLike.Add([pscustomobject]@{
        System=$R.System
        Root=$R.Root
        RelativePath=$rel
        MB=[math]::Round($f.Length/1MB,4)
        LastWriteTime=$f.LastWriteTime
        Reason="SECRET_LIKE_NAME_EXCLUDED_FROM_GITHUB_SUMMARY"
      }) | Out-Null
      continue
    }

    if($isLikelyChat){
      $Rows.Add([pscustomobject]@{
        System=$R.System
        Root=$R.Root
        RelativePath=$rel
        Extension=$f.Extension
        MB=[math]::Round($f.Length/1MB,4)
        LastWriteTime=$f.LastWriteTime
        GitNormalSafe=($f.Length -lt 50MB)
        NeedsLfsOrArchive=($f.Length -ge 50MB)
      }) | Out-Null
    }
  }
}

$Rows | Export-Csv -LiteralPath $DetailCsv -NoTypeInformation -Encoding UTF8

"# AI Chats Safe Index Local Report" | Set-Content -LiteralPath $LocalReport -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
"READ ONLY. No raw chat content copied. No delete. No commit. No push." | Add-Content -LiteralPath $LocalReport -Encoding UTF8
"" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
"Detail CSV: $DetailCsv" | Add-Content -LiteralPath $LocalReport -Encoding UTF8

"`n## Summary by system" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
$Rows |
  Group-Object System |
  ForEach-Object {
    [pscustomobject]@{
      System=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
      NeedsLfsOrArchive=($_.Group | Where-Object {$_.NeedsLfsOrArchive}).Count
    }
  } |
  Sort-Object MB -Descending |
  Format-Table -AutoSize |
  Out-String -Width 1000 |
  Add-Content -LiteralPath $LocalReport -Encoding UTF8

"`n## Summary by extension" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
$Rows |
  Group-Object Extension |
  ForEach-Object {
    [pscustomobject]@{
      Extension=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending |
  Format-Table -AutoSize |
  Out-String -Width 1000 |
  Add-Content -LiteralPath $LocalReport -Encoding UTF8

"`n## Largest non-secret-like likely chat/runtime files top 50" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
$Rows |
  Sort-Object MB -Descending |
  Select-Object -First 50 System,Root,RelativePath,Extension,MB,LastWriteTime,NeedsLfsOrArchive |
  Format-Table -AutoSize |
  Out-String -Width 1600 |
  Add-Content -LiteralPath $LocalReport -Encoding UTF8

"`n## Secret-like files excluded from GitHub-safe summary" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
if($ExcludedSecretLike.Count -gt 0){
  $ExcludedSecretLike |
    Select-Object System,Root,RelativePath,MB,LastWriteTime,Reason |
    Format-Table -AutoSize |
    Out-String -Width 1600 |
    Add-Content -LiteralPath $LocalReport -Encoding UTF8
} else {
  "- OK: none detected by filename" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
}

"# AI Chats Safe Index Summary" | Set-Content -LiteralPath $SafeSummary -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"## Purpose" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"This is a GitHub-safe metadata summary only. It does not contain raw chat content, credentials, tokens, passwords, or API keys." | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"## Totals" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Likely chat/runtime metadata rows: $($Rows.Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Total MB represented: $([math]::Round((($Rows | Measure-Object MB -Sum).Sum),2))" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Files needing LFS/archive by size: $(($Rows | Where-Object {$_.NeedsLfsOrArchive}).Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Secret-like filenames excluded from summary: $($ExcludedSecretLike.Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8

"`n## Summary by system" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
$Rows |
  Group-Object System |
  ForEach-Object {
    "| $($_.Name) | $($_.Count) | $([math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)) MB | $(($_.Group | Where-Object {$_.NeedsLfsOrArchive}).Count) |"
  } |
  ForEach-Object -Begin {
    "| System | Files | MB | Needs LFS/archive |"
    "|---|---:|---:|---:|"
  } -Process { $_ } |
  Add-Content -LiteralPath $SafeSummary -Encoding UTF8

"`n## Decision" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
@(
"- Normal GitHub repo stores this summary, plans, scripts, and AI Context Capsules.",
"- Raw large chat files are not pushed yet.",
"- Secret-like files are excluded from the GitHub-safe summary.",
"- Next step: build project-level AI Context Capsules and export/import checklist."
) | Add-Content -LiteralPath $SafeSummary -Encoding UTF8

Write-Host "DETAIL CSV:" -ForegroundColor Green
Write-Host $DetailCsv
Write-Host "LOCAL REPORT:" -ForegroundColor Green
Write-Host $LocalReport
Write-Host "GITHUB-SAFE SUMMARY:" -ForegroundColor Green
Write-Host $SafeSummary

Get-Content -LiteralPath $LocalReport -Tail 220
