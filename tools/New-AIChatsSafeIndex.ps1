$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$DetailCsv="$AuditRoot\AI_CHATS_SAFE_INDEX_DETAIL_V2_$Stamp.csv"
$LocalReport="$AuditRoot\AI_CHATS_SAFE_INDEX_LOCAL_REPORT_V2_$Stamp.md"
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

function Test-NoisePath {
  param([string]$RelativePath)

  return (
    $RelativePath -match "(?i)(\\node_modules\\|\\__pycache__\\|\\typeshed\\|\\dist\\bundled\\stubs\\|\\third_party\\typeshed\\|\\J_extensions\\|\\VSCode-Recovery\\|\\workspaceStorage_before_merge\\|\\Cache\\|\\Code Cache\\|\\GPUCache\\|\\Service Worker\\)"
  )
}

function Test-SecretLikeName {
  param([string]$RelativePath)

  $leaf=[System.IO.Path]::GetFileName($RelativePath)

  if($leaf -match "(?i)^\.env($|\.)"){ return $true }
  if($leaf -match "(?i)^\.credentials\.json$"){ return $true }
  if($leaf -match "(?i)(credential|credentials|api[_-]?key|private[_-]?key|password)"){ return $true }
  if($leaf -match "(?i)(^|[_\-.])secret(s)?([_\-.]|$)"){ return $true }
  if($leaf -match "(?i)(^|[_\-.])token(s)?([_\-.]|$)" -and $leaf -match "(?i)\.(json|txt|log|db|sqlite)$"){ return $true }

  return $false
}

function Test-LikelyChatFile {
  param([System.IO.FileInfo]$File)

  $ext=$File.Extension.ToLowerInvariant()
  return ($ext -in @(".jsonl",".json",".md",".txt",".html",".sqlite",".db",".log"))
}

$Rows = New-Object System.Collections.Generic.List[object]
$ExcludedSecretLike = New-Object System.Collections.Generic.List[object]
$IgnoredNoise = New-Object System.Collections.Generic.List[object]

foreach($R in $Roots){
  if(-not (Test-Path -LiteralPath $R.Root)){ continue }

  $files = Get-ChildItem -LiteralPath $R.Root -File -Recurse -Force -ErrorAction SilentlyContinue

  foreach($f in $files){
    $rel = $f.FullName.Substring($R.Root.Length).TrimStart("\")

    if(Test-NoisePath $rel){
      $IgnoredNoise.Add([pscustomobject]@{
        System=$R.System
        RelativePath=$rel
        MB=[math]::Round($f.Length/1MB,4)
        Reason="IGNORED_NOISE_PATH"
      }) | Out-Null
      continue
    }

    if(Test-SecretLikeName $rel){
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

    if(Test-LikelyChatFile $f){
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

"# AI Chats Safe Index Local Report V2" | Set-Content -LiteralPath $LocalReport -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
"READ ONLY. No raw chat content copied. No delete. No commit. No push." | Add-Content -LiteralPath $LocalReport -Encoding UTF8
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

"`n## Largest non-secret likely chat/runtime files top 50" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
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
  "- OK: none detected by strict filename filter" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
}

"`n## Noise ignored" | Add-Content -LiteralPath $LocalReport -Encoding UTF8
"- Ignored noise files: $($IgnoredNoise.Count)" | Add-Content -LiteralPath $LocalReport -Encoding UTF8

"# AI Chats Safe Index Summary" | Set-Content -LiteralPath $SafeSummary -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"## Purpose" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"This is a GitHub-safe metadata summary only. It does not contain raw chat content, credentials, tokens, passwords, or API keys." | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"## V2 filter note" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"V2 ignores common VS Code extension/recovery/dependency noise such as node_modules, typeshed, Python stubs, VSCode-Recovery, and workspaceStorage_before_merge." | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"## Totals" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Likely chat/runtime metadata rows: $($Rows.Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Total MB represented: $([math]::Round((($Rows | Measure-Object MB -Sum).Sum),2))" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Files needing LFS/archive by size: $(($Rows | Where-Object {$_.NeedsLfsOrArchive}).Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Strict secret-like filenames excluded from summary: $($ExcludedSecretLike.Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8
"- Noise files ignored: $($IgnoredNoise.Count)" | Add-Content -LiteralPath $SafeSummary -Encoding UTF8

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
"- Strict secret-like files are excluded from the GitHub-safe summary.",
"- Next step: build project-level AI Context Capsules and export/import checklist."
) | Add-Content -LiteralPath $SafeSummary -Encoding UTF8

Write-Host "DETAIL CSV:" -ForegroundColor Green
Write-Host $DetailCsv
Write-Host "LOCAL REPORT:" -ForegroundColor Green
Write-Host $LocalReport
Write-Host "GITHUB-SAFE SUMMARY:" -ForegroundColor Green
Write-Host $SafeSummary

Get-Content -LiteralPath $LocalReport -Tail 180
