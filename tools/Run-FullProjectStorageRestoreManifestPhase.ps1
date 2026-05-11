$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule | Out-Null

$RunReport="$AuditRoot\FULL_PROJECT_STORAGE_RESTORE_MANIFEST_RUN_$Stamp.md"
$DetailedManifest="$AuditRoot\FULL_PROJECT_STORAGE_RESTORE_MANIFEST_$Stamp.csv"
$Policy="$Capsule\FULL_PROJECT_STORAGE_POLICY.md"
$RestoreSummary="$Capsule\FULL_RESTORE_MANIFEST_SUMMARY.md"
$StorageDecision="$Capsule\STORAGE_LAYER_DECISION_MATRIX.md"
$RawArchiveReq="$Capsule\RAW_AI_CHAT_ARCHIVE_REQUIREMENTS.md"
$LfsPlan="$Capsule\GIT_LFS_CANDIDATE_PLAN.md"
$EncryptedPlan="$Capsule\ENCRYPTED_ARCHIVE_CANDIDATE_PLAN.md"
$LocalArchivePlan="$Capsule\LOCAL_ARCHIVE_ONLY_PLAN.md"
$Checkpoint="$Capsule\FULL_PROJECT_STORAGE_RESTORE_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Full Project Storage Restore Checkpoint

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Safety

No raw files copied.
No raw chats copied.
No files deleted.
No Git LFS enabled.
No archive created.
No sync enabled.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-FullProjectStorageRestoreManifestPhase.ps1 `
    03_AI_CHATS\FULL_PROJECT_STORAGE_RESTORE_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record full project storage restore stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 180
  exit 0
}

function BoolVal($v){
  return ("$v" -match "^(True|true|1|YES|yes)$")
}

function Decide-RestoreRole($row){
  $class="$($row.Class)"
  $strategy="$($row.Strategy)"
  $ext="$($row.Extension)".ToLowerInvariant()
  $secret=BoolVal $row.SecretLike
  $browser=BoolVal $row.BrowserState
  $large=BoolVal $row.LargeOver50MB
  $huge=BoolVal $row.HugeOver500MB

  if($secret){ return "PRIVATE_SECRET_REVIEW" }
  if($browser){ return "BROWSER_STATE_RESTORE_IF_NEEDED" }
  if($class -eq "CHAT_MEMORY_CANDIDATE"){ return "REQUIRED_FOR_AI_CONTEXT" }
  if($class -eq "CHAT_RELATED_METADATA"){ return "AI_CONTEXT_METADATA" }
  if($huge){ return "HUGE_HISTORY_OR_DIAGNOSTICS_REVIEW" }
  if($large){ return "LARGE_REQUIRED_OR_HISTORY_REVIEW" }
  if($class -eq "ARCHIVE_BINARY_EXCLUDE"){ return "HISTORY_OR_RECREATABLE_REVIEW" }
  return "MANIFEST_ONLY_REVIEW"
}

function Decide-StorageLayer($row){
  $class="$($row.Class)"
  $ext="$($row.Extension)".ToLowerInvariant()
  $secret=BoolVal $row.SecretLike
  $browser=BoolVal $row.BrowserState
  $large=BoolVal $row.LargeOver50MB
  $huge=BoolVal $row.HugeOver500MB

  if($secret){ return "DO_NOT_PUSH_PRIVATE__ENCRYPTED_ARCHIVE_REVIEW" }
  if($browser){ return "ENCRYPTED_ARCHIVE_OR_LOCAL_ONLY" }
  if($class -eq "CHAT_MEMORY_CANDIDATE"){ return "ENCRYPTED_ARCHIVE_RECOMMENDED" }
  if($huge){ return "LOCAL_OR_ENCRYPTED_ARCHIVE__SPLIT_IF_NEEDED" }
  if($large -and -not $secret -and -not $browser){ return "GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE" }
  if($class -eq "ARCHIVE_BINARY_EXCLUDE"){ return "LOCAL_ARCHIVE_ONLY" }
  if($class -eq "CHAT_RELATED_METADATA"){ return "MANIFEST_OR_REDACTED_SUMMARY" }
  return "MANIFEST_ONLY"
}

function DecidePriority($row){
  $role=Decide-RestoreRole $row
  $storage=Decide-StorageLayer $row
  $mb=[double]$row.MB

  if($role -eq "REQUIRED_FOR_AI_CONTEXT"){ return "HIGH" }
  if($role -eq "PRIVATE_SECRET_REVIEW"){ return "HIGH_PRIVATE" }
  if($role -eq "BROWSER_STATE_RESTORE_IF_NEEDED"){ return "MEDIUM_PRIVATE" }
  if($mb -gt 500){ return "HIGH_SIZE_REVIEW" }
  if($mb -gt 50){ return "MEDIUM_SIZE_REVIEW" }
  return "NORMAL"
}

"# Full Project Storage Restore Manifest Phase" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: storage policy + restore manifest only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no raw file copy"
Add-Line "- no raw chat copy"
Add-Line "- no delete"
Add-Line "- no Git LFS enable"
Add-Line "- no encrypted archive creation"
Add-Line "- no scheduled sync enable"
Add-Line "- commit only small policy/summary/script files"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestCsv=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "GLOBAL_AI_CHAT_ROOTS_INDEX_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $LatestCsv){
  Stop-Safely "No GLOBAL_AI_CHAT_ROOTS_INDEX_*.csv found in $AuditRoot"
}

Add-Line "- Repo: $Repo"
Add-Line "- AuditRoot: $AuditRoot"
Add-Line "- Latest source CSV: $($LatestCsv.FullName)"
Add-Line "- Detailed restore manifest output: $DetailedManifest"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / READ METADATA CSV ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Read metadata CSV"

$Rows=Import-Csv -LiteralPath $LatestCsv.FullName

$InputCount=$Rows.Count
$InputMB=[math]::Round((($Rows | Measure-Object MB -Sum).Sum),2)

Add-Line "- Input rows: $InputCount"
Add-Line "- Input MB represented: $InputMB"

if($InputCount -lt 1){
  Stop-Safely "Input CSV has no rows."
}

Write-Host "`n=== STEP 3 / BUILD FULL STORAGE RESTORE MANIFEST ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Build full storage restore manifest"

$Detailed=New-Object System.Collections.Generic.List[object]

foreach($r in $Rows){
  $role=Decide-RestoreRole $r
  $storage=Decide-StorageLayer $r
  $priority=DecidePriority $r

  $reason=@()
  if(BoolVal $r.SecretLike){$reason+="secret-like"}
  if(BoolVal $r.BrowserState){$reason+="browser-state"}
  if(BoolVal $r.LargeOver50MB){$reason+="over-50MB"}
  if(BoolVal $r.HugeOver500MB){$reason+="over-500MB"}
  if("$($r.Class)" -match "CHAT"){$reason+="chat-related"}
  if("$($r.Extension)" -match "(?i)\.(jsonl|sqlite|db|log)"){$reason+="raw-or-db-log"}

  $Detailed.Add([pscustomobject]@{
    Root=$r.Root
    RelativeFolder=$r.RelativeFolder
    FileName=$r.FileName
    Extension=$r.Extension
    MB=$r.MB
    LastWriteTime=$r.LastWriteTime
    OriginalClass=$r.Class
    OriginalStrategy=$r.Strategy
    RestoreRole=$role
    StorageLayer=$storage
    Priority=$priority
    Reason=($reason -join ";")
  }) | Out-Null
}

$Detailed | Export-Csv -LiteralPath $DetailedManifest -NoTypeInformation -Encoding UTF8

$TotalRows=$Detailed.Count
$TotalMB=[math]::Round((($Detailed | Measure-Object MB -Sum).Sum),2)

$ByStorage=$Detailed |
  Group-Object StorageLayer |
  ForEach-Object {
    [pscustomobject]@{
      StorageLayer=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByRole=$Detailed |
  Group-Object RestoreRole |
  ForEach-Object {
    [pscustomobject]@{
      RestoreRole=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByRoot=$Detailed |
  Group-Object Root |
  ForEach-Object {
    [pscustomobject]@{
      Root=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByPriority=$Detailed |
  Group-Object Priority |
  ForEach-Object {
    [pscustomobject]@{
      Priority=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$LfsCandidates=$Detailed | Where-Object {$_.StorageLayer -eq "GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE"}
$EncryptedCandidates=$Detailed | Where-Object {$_.StorageLayer -match "ENCRYPTED"}
$LocalOnly=$Detailed | Where-Object {$_.StorageLayer -eq "LOCAL_ARCHIVE_ONLY" -or $_.StorageLayer -match "LOCAL_OR_ENCRYPTED"}
$PrivateCandidates=$Detailed | Where-Object {$_.StorageLayer -match "DO_NOT_PUSH_PRIVATE"}
$AiContextCandidates=$Detailed | Where-Object {$_.RestoreRole -eq "REQUIRED_FOR_AI_CONTEXT" -or $_.RestoreRole -eq "AI_CONTEXT_METADATA"}

Add-Line "- Detailed manifest: $DetailedManifest"
Add-Line "- Total rows: $TotalRows"
Add-Line "- Total MB: $TotalMB"
Add-Line "- LFS candidates: $($LfsCandidates.Count)"
Add-Line "- Encrypted candidates: $($EncryptedCandidates.Count)"
Add-Line "- Local-only candidates: $($LocalOnly.Count)"
Add-Line "- Private candidates: $($PrivateCandidates.Count)"
Add-Line "- AI context candidates: $($AiContextCandidates.Count)"

Write-Host "`n=== STEP 4 / WRITE POLICY DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Write policy documents"

@"
# Full Project Storage Policy

## Core rule

No project file is considered lost just because it is not suitable for normal Git.

Filtering does not mean deleting.
Filtering means routing each file to the correct storage layer.

## Storage layers

1. NORMAL_GIT
   - source code
   - small configs without secrets
   - capsules
   - manifests
   - restore notes
   - safe scripts

2. GIT_LFS
   - large non-private project assets
   - only after explicit approval
   - only after .gitattributes rules are approved

3. ENCRYPTED_ARCHIVE
   - raw AI chats
   - Claude/Codex/Copilot/ChatGPT exports
   - private AI memory
   - sensitive restore data
   - browser/IndexedDB/session state only if restore-critical

4. LOCAL_ARCHIVE_ONLY
   - cache
   - runtime output
   - installers
   - generated diagnostics
   - files useful for history but not required for clean project operation

5. RECREATE_FROM_SCRIPT
   - dependencies
   - node_modules
   - .venv
   - temporary generated outputs
   - cache that can be rebuilt

6. MANIFEST_ONLY
   - references to sensitive/private/unknown files
   - files requiring manual review before storage decision

## Latest detailed manifest

$DetailedManifest

## Summary

- Total metadata rows: $TotalRows
- Total MB represented: $TotalMB
- LFS candidates: $($LfsCandidates.Count)
- Encrypted/archive candidates: $($EncryptedCandidates.Count)
- Local-only candidates: $($LocalOnly.Count)
- Private candidates: $($PrivateCandidates.Count)
- AI context candidates: $($AiContextCandidates.Count)

## Decision

This phase creates the full routing map.
It does not copy raw files.
It does not enable Git LFS.
It does not create encrypted archives.
"@ | Set-Content -LiteralPath $Policy -Encoding UTF8

@"
# Full Restore Manifest Summary

## Detailed CSV manifest

$DetailedManifest

## By storage layer

$($ByStorage | Format-Table -AutoSize | Out-String -Width 1800)

## By restore role

$($ByRole | Format-Table -AutoSize | Out-String -Width 1800)

## By priority

$($ByPriority | Format-Table -AutoSize | Out-String -Width 1400)

## By root

$($ByRoot | Format-Table -AutoSize | Out-String -Width 2200)

## Important

This is not the full raw backup.
This is the map that says where each class of file must go before the system can be called fully restorable.
"@ | Set-Content -LiteralPath $RestoreSummary -Encoding UTF8

@"
# Storage Layer Decision Matrix

## Matrix

| Storage layer | Use for | Do not use for | Current status |
|---|---|---|---|
| NORMAL_GIT | code, rules, capsules, manifests, small safe configs | raw chats, secrets, browser state, huge files | active |
| GIT_LFS | approved large non-private assets | secrets, cookies, sessions, raw private chats without review | not enabled yet |
| ENCRYPTED_ARCHIVE | raw AI chats, private memory, sensitive restore data | cache-trash, public source code | not created yet |
| LOCAL_ARCHIVE_ONLY | cache, installers, runtime, diagnostics, historical dumps | files required for clean project clone | not created yet |
| RECREATE_FROM_SCRIPT | dependencies/cache/build output | unique project memory | not implemented yet |
| MANIFEST_ONLY | sensitive references, unknown review items | files required for immediate run | active |

## Current counts by storage

$($ByStorage | Format-Table -AutoSize | Out-String -Width 1800)

## Next decision

Build archive plan in this order:
1. encrypted archive candidates
2. Git LFS candidate review
3. local archive-only review
4. restore test
"@ | Set-Content -LiteralPath $StorageDecision -Encoding UTF8

@"
# Raw AI Chat Archive Requirements

## Goal

Preserve Igor's AI chats and AI memory so future work can continue from the same context.

## Archive candidate counts

- AI context candidates: $($AiContextCandidates.Count)
- Encrypted candidates: $($EncryptedCandidates.Count)
- Private candidates: $($PrivateCandidates.Count)

## Must be protected

Raw AI chat/archive layer may contain:
- prompts
- model responses
- personal data
- API references
- local paths
- project strategy
- private memory
- browser/session traces

## Required archive properties

- private
- restorable
- searchable later
- not normal public Git
- not committed with cookies/session/API keys
- ideally encrypted if stored online

## Candidate preview: top encrypted/archive files by size

$($EncryptedCandidates | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority | Format-Table -AutoSize | Out-String -Width 2600)

## Not done yet

- archive format not selected
- encryption method not selected
- destination not selected
- restore test not done
"@ | Set-Content -LiteralPath $RawArchiveReq -Encoding UTF8

@"
# Git LFS Candidate Plan

## Important

Git LFS is not enabled yet.

This file only lists candidate categories and counts.

## Candidate count

- LFS candidate files: $($LfsCandidates.Count)
- LFS candidate MB: $([math]::Round((($LfsCandidates | Measure-Object MB -Sum).Sum),2))

## Candidate preview: top by size

$($LfsCandidates | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority | Format-Table -AutoSize | Out-String -Width 2600)

## Rules before enabling LFS

1. Do not include secret-like files.
2. Do not include browser/session/cookie/local storage.
3. Do not include raw private AI chats unless explicitly approved.
4. Create .gitattributes rules first.
5. Test clone/restore after push.
"@ | Set-Content -LiteralPath $LfsPlan -Encoding UTF8

@"
# Encrypted Archive Candidate Plan

## Candidate count

- Encrypted/archive candidate files: $($EncryptedCandidates.Count)
- Encrypted/archive candidate MB: $([math]::Round((($EncryptedCandidates | Measure-Object MB -Sum).Sum),2))

## Candidate preview: top by size

$($EncryptedCandidates | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 100 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority | Format-Table -AutoSize | Out-String -Width 2800)

## Next step

Create a dry-run archive plan only.

Do not create encrypted archive until:
- destination is chosen
- encryption method is chosen
- restore test plan exists
"@ | Set-Content -LiteralPath $EncryptedPlan -Encoding UTF8

@"
# Local Archive Only Plan

## Candidate count

- Local/archive-only files: $($LocalOnly.Count)
- Local/archive-only MB: $([math]::Round((($LocalOnly | Measure-Object MB -Sum).Sum),2))

## Candidate preview: top by size

$($LocalOnly | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority | Format-Table -AutoSize | Out-String -Width 2600)

## Rule

Local archive only does not mean delete.
It means:
- keep outside normal Git
- write path in restore manifest
- decide later whether to compress/encrypt/delete/recreate
"@ | Set-Content -LiteralPath $LocalArchivePlan -Encoding UTF8

@"
# Full Project Storage Restore Checkpoint

## Status

Full Project Storage Restore Manifest Phase completed.

## What was done

- Loaded latest AI/chat metadata CSV.
- Built detailed restore/storage manifest.
- Classified each metadata row by RestoreRole.
- Routed each row to a StorageLayer.
- Created full storage policy.
- Created restore manifest summary.
- Created Git LFS candidate plan.
- Created encrypted archive candidate plan.
- Created local archive-only plan.
- Updated current status map.

## What was not done

- no raw file copy
- no raw chat copy
- no Git LFS enable
- no encrypted archive
- no scheduled sync
- no restore test

## Detailed manifest

$DetailedManifest

## Next recommended phase

Create archive dry-run plan:
- encrypted archive candidate dry-run
- Git LFS candidate review
- restore-test checklist
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

@"
# Current Status Map

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Done

- Main repo Incomesbook/workspaces is active and clean.
- G01_P03 is closed.
- G01_P01 is closed.
- G01_P02 is closed after FIX.
- Global AI Chat Backup Strategy Phase completed.
- Full Project Storage Restore Manifest Phase completed.
- Detailed storage/restore manifest created locally.
- Storage policy created.
- Git LFS candidate plan created.
- Encrypted archive candidate plan created.
- Local archive-only plan created.

## Current latest phase

Full Project Storage Restore Manifest completed as policy/manifest only.

## Not done yet

- Raw AI chats are not copied to GitHub.
- Git LFS is not enabled.
- Encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Restore test is not done.

## Next

Create archive dry-run plan, then choose:
1. encrypted archive destination/method
2. Git LFS candidate approval
3. weekly/biweekly sync dry-run
4. restore test
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 5 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Commit and push"

$FilesToAdd=@(
  "tools\Run-FullProjectStorageRestoreManifestPhase.ps1",
  "03_AI_CHATS\FULL_PROJECT_STORAGE_POLICY.md",
  "03_AI_CHATS\FULL_RESTORE_MANIFEST_SUMMARY.md",
  "03_AI_CHATS\STORAGE_LAYER_DECISION_MATRIX.md",
  "03_AI_CHATS\RAW_AI_CHAT_ARCHIVE_REQUIREMENTS.md",
  "03_AI_CHATS\GIT_LFS_CANDIDATE_PLAN.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_CANDIDATE_PLAN.md",
  "03_AI_CHATS\LOCAL_ARCHIVE_ONLY_PLAN.md",
  "03_AI_CHATS\FULL_PROJECT_STORAGE_RESTORE_CHECKPOINT.md",
  "00_START_HERE\CURRENT_STATUS_MAP.md"
)

foreach($f in $FilesToAdd){
  $full=Join-Path $Repo $f
  if(Test-Path -LiteralPath $full){
    git -C $Repo add -- $f
  }
}

$Staged=@(git --no-pager -C $Repo diff --cached --name-only)
Add-Line "`nStaged files:"
$Staged | ForEach-Object { Add-Line "- $_" }

$LargeStaged=@()
foreach($sf in $Staged){
  $p=Join-Path $Repo $sf
  if(Test-Path -LiteralPath $p){
    $i=Get-Item -LiteralPath $p
    if($i.Length -gt 50MB){
      $LargeStaged += [pscustomobject]@{File=$sf;MB=[math]::Round($i.Length/1MB,2)}
    }
  }
}

if($LargeStaged.Count -gt 0){
  Stop-Safely "Large staged files found. Commit/push aborted."
}

if($Staged.Count -gt 0){
  git -C $Repo commit -m "Add full project storage restore manifest policy" | Tee-Object -Variable CommitOutput | Out-Null
  $CommitOutput | ForEach-Object { Add-Line $_ }

  git -C $Repo push origin main | Tee-Object -Variable PushOutput | Out-Null
  $PushOutput | ForEach-Object { Add-Line $_ }
} else {
  Add-Line "No staged files to commit."
}

$FinalStatus=git --no-pager -C $Repo status --short --branch
$LastCommits=git --no-pager -C $Repo log --oneline -10

Add-Line "`n## Final repo status"
$FinalStatus | ForEach-Object { Add-Line $_ }

Add-Line "`n## Last commits"
$LastCommits | ForEach-Object { Add-Line $_ }

Write-Host "`n=== DONE ===" -ForegroundColor Green
Write-Host "RUN REPORT: $RunReport" -ForegroundColor Green
Write-Host "DETAILED MANIFEST: $DetailedManifest" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
