$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$ArchiveRoot="J:\Setup_VcCode_Workspace\S30_Large_Local_Archive"
$FutureEncryptedRoot="$ArchiveRoot\ENCRYPTED_AI_CHAT_ARCHIVE"
$FutureLfsReviewRoot="$ArchiveRoot\GIT_LFS_REVIEW"
$FutureLocalOnlyRoot="$ArchiveRoot\LOCAL_ONLY_ARCHIVE"
$FutureRestoreRoot="J:\Setup_VcCode_Workspace\S40_Restore_Manifests"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule | Out-Null

$RunReport="$AuditRoot\ARCHIVE_DRYRUN_PLAN_RUN_$Stamp.md"
$EncryptedCsv="$AuditRoot\ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_$Stamp.csv"
$LfsCsv="$AuditRoot\ARCHIVE_DRYRUN_LFS_CANDIDATES_$Stamp.csv"
$LocalCsv="$AuditRoot\ARCHIVE_DRYRUN_LOCAL_ONLY_CANDIDATES_$Stamp.csv"
$PrivateCsv="$AuditRoot\ARCHIVE_DRYRUN_PRIVATE_REVIEW_$Stamp.csv"
$AiContextCsv="$AuditRoot\ARCHIVE_DRYRUN_AI_CONTEXT_CANDIDATES_$Stamp.csv"

$ArchivePlan="$Capsule\ARCHIVE_DRYRUN_PLAN.md"
$EncryptedDryRun="$Capsule\ENCRYPTED_ARCHIVE_DRYRUN_PLAN.md"
$LfsDryRun="$Capsule\GIT_LFS_REVIEW_DRYRUN_PLAN.md"
$LocalDryRun="$Capsule\LOCAL_ARCHIVE_DRYRUN_PLAN.md"
$RestoreChecklist="$Capsule\RESTORE_TEST_CHECKLIST.md"
$NextActions="$Capsule\NEXT_BACKUP_ACTIONS.md"
$Checkpoint="$Capsule\ARCHIVE_DRYRUN_PLAN_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Archive Dry-Run Plan Checkpoint

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
No encrypted archive created.
No Git LFS enabled.
No sync enabled.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-ArchiveDryRunPlanPhase.ps1 `
    03_AI_CHATS\ARCHIVE_DRYRUN_PLAN_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record archive dry-run plan stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 160
  exit 0
}

"# Archive Dry-Run Plan Phase" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: dry-run planning only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no raw file copy"
Add-Line "- no raw chat copy"
Add-Line "- no delete"
Add-Line "- no encrypted archive creation"
Add-Line "- no Git LFS enable"
Add-Line "- no sync enable"
Add-Line "- commit only small planning files"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestManifest=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "FULL_PROJECT_STORAGE_RESTORE_MANIFEST_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $LatestManifest){
  Stop-Safely "No FULL_PROJECT_STORAGE_RESTORE_MANIFEST_*.csv found in $AuditRoot"
}

Add-Line "- Repo: $Repo"
Add-Line "- Latest manifest: $($LatestManifest.FullName)"
Add-Line "- ArchiveRoot future target: $ArchiveRoot"
Add-Line "- FutureEncryptedRoot: $FutureEncryptedRoot"
Add-Line "- FutureLfsReviewRoot: $FutureLfsReviewRoot"
Add-Line "- FutureLocalOnlyRoot: $FutureLocalOnlyRoot"
Add-Line "- FutureRestoreRoot: $FutureRestoreRoot"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / READ RESTORE MANIFEST ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Read restore manifest"

$Rows=Import-Csv -LiteralPath $LatestManifest.FullName
$TotalRows=$Rows.Count
$TotalMB=[math]::Round((($Rows | Measure-Object MB -Sum).Sum),2)

Add-Line "- Rows: $TotalRows"
Add-Line "- MB represented: $TotalMB"

if($TotalRows -lt 1){
  Stop-Safely "Restore manifest has no rows."
}

Write-Host "`n=== STEP 3 / SPLIT BY STORAGE LAYER ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Split by storage layer"

$Encrypted=$Rows | Where-Object {
  $_.StorageLayer -match "ENCRYPTED" -or
  $_.RestoreRole -eq "REQUIRED_FOR_AI_CONTEXT" -or
  $_.RestoreRole -eq "AI_CONTEXT_METADATA"
}

$Lfs=$Rows | Where-Object {
  $_.StorageLayer -eq "GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE"
}

$LocalOnly=$Rows | Where-Object {
  $_.StorageLayer -eq "LOCAL_ARCHIVE_ONLY" -or
  $_.StorageLayer -match "LOCAL_OR_ENCRYPTED"
}

$Private=$Rows | Where-Object {
  $_.StorageLayer -match "DO_NOT_PUSH_PRIVATE" -or
  $_.RestoreRole -eq "PRIVATE_SECRET_REVIEW"
}

$AiContext=$Rows | Where-Object {
  $_.RestoreRole -eq "REQUIRED_FOR_AI_CONTEXT" -or
  $_.RestoreRole -eq "AI_CONTEXT_METADATA"
}

$Encrypted | Export-Csv -LiteralPath $EncryptedCsv -NoTypeInformation -Encoding UTF8
$Lfs | Export-Csv -LiteralPath $LfsCsv -NoTypeInformation -Encoding UTF8
$LocalOnly | Export-Csv -LiteralPath $LocalCsv -NoTypeInformation -Encoding UTF8
$Private | Export-Csv -LiteralPath $PrivateCsv -NoTypeInformation -Encoding UTF8
$AiContext | Export-Csv -LiteralPath $AiContextCsv -NoTypeInformation -Encoding UTF8

$EncryptedMB=[math]::Round((($Encrypted | Measure-Object MB -Sum).Sum),2)
$LfsMB=[math]::Round((($Lfs | Measure-Object MB -Sum).Sum),2)
$LocalMB=[math]::Round((($LocalOnly | Measure-Object MB -Sum).Sum),2)
$PrivateMB=[math]::Round((($Private | Measure-Object MB -Sum).Sum),2)
$AiContextMB=[math]::Round((($AiContext | Measure-Object MB -Sum).Sum),2)

Add-Line "- Encrypted rows: $($Encrypted.Count) / MB: $EncryptedMB"
Add-Line "- LFS rows: $($Lfs.Count) / MB: $LfsMB"
Add-Line "- Local-only rows: $($LocalOnly.Count) / MB: $LocalMB"
Add-Line "- Private review rows: $($Private.Count) / MB: $PrivateMB"
Add-Line "- AI context rows: $($AiContext.Count) / MB: $AiContextMB"

Write-Host "`n=== STEP 4 / TOOL CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Tool check"

$SevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
if(-not $SevenZip){ $SevenZip = Get-Command 7z -ErrorAction SilentlyContinue }

$GitLfs = $null
try {
  $GitLfsText = git lfs version 2>&1
  if($LASTEXITCODE -eq 0){ $GitLfs=$GitLfsText }
} catch {
  $GitLfs=$null
}

Add-Line "- 7z found: $([bool]$SevenZip)"
if($SevenZip){ Add-Line "- 7z path: $($SevenZip.Source)" }
Add-Line "- git lfs available: $([bool]$GitLfs)"
if($GitLfs){ Add-Line "- git lfs version: $GitLfs" }

Write-Host "`n=== STEP 5 / WRITE DRY-RUN DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Write dry-run documents"

$EncryptedTop=$Encrypted | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority,Reason
$LfsTop=$Lfs | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority,Reason
$LocalTop=$LocalOnly | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority,Reason
$PrivateTop=$Private | Sort-Object {[double]$_.MB} -Descending | Select-Object -First 80 Root,RelativeFolder,FileName,Extension,MB,RestoreRole,StorageLayer,Priority,Reason

$ByStorage=$Rows |
  Group-Object StorageLayer |
  ForEach-Object {
    [pscustomobject]@{
      StorageLayer=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByRoot=$Rows |
  Group-Object Root |
  ForEach-Object {
    [pscustomobject]@{
      Root=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

@"
# Archive Dry-Run Plan

## Purpose

Move from “filtered out” to “routed to storage layer”.

This is a dry-run plan only.

## Source manifest

$($LatestManifest.FullName)

## Generated dry-run CSVs

- Encrypted archive candidates:
  $EncryptedCsv

- Git LFS candidates:
  $LfsCsv

- Local archive-only candidates:
  $LocalCsv

- Private review candidates:
  $PrivateCsv

- AI context candidates:
  $AiContextCsv

## Future target roots

- Encrypted archive root:
  $FutureEncryptedRoot

- Git LFS review root:
  $FutureLfsReviewRoot

- Local archive-only root:
  $FutureLocalOnlyRoot

- Restore manifests:
  $FutureRestoreRoot

## Counts

- Total rows: $TotalRows
- Total MB represented: $TotalMB
- Encrypted archive candidates: $($Encrypted.Count) / $EncryptedMB MB
- Git LFS candidates: $($Lfs.Count) / $LfsMB MB
- Local-only candidates: $($LocalOnly.Count) / $LocalMB MB
- Private review candidates: $($Private.Count) / $PrivateMB MB
- AI context candidates: $($AiContext.Count) / $AiContextMB MB

## Tool check

- 7z available: $([bool]$SevenZip)
- git lfs available: $([bool]$GitLfs)

## Decision

No files were copied.
No archive was created.
No Git LFS tracking was enabled.
No sync was enabled.
"@ | Set-Content -LiteralPath $ArchivePlan -Encoding UTF8

@"
# Encrypted Archive Dry-Run Plan

## Goal

Preserve raw AI chats, private AI memory, sensitive restore material, and selected browser/session state only if restore-critical.

## Candidate CSV

$EncryptedCsv

## Candidate counts

- Files/rows: $($Encrypted.Count)
- MB represented: $EncryptedMB

## Recommended future archive root

$FutureEncryptedRoot

## Requirements before execution

1. Choose encryption method.
2. Choose password/key storage method.
3. Choose archive destination.
4. Decide whether to split archives by root/project/date.
5. Do a small test archive first.
6. Do a restore test before trusting the archive.

## 7z status

- 7z available: $([bool]$SevenZip)
$(if($SevenZip){"- 7z path: $($SevenZip.Source)"}else{"- 7z not found. Do not create encrypted archives yet."})

## Top candidates by size

$($EncryptedTop | Format-Table -AutoSize | Out-String -Width 2800)

## Safety rule

Encrypted archive candidate does not mean safe to publish.
It means: preserve privately, preferably encrypted, and verify restore.
"@ | Set-Content -LiteralPath $EncryptedDryRun -Encoding UTF8

@"
# Git LFS Review Dry-Run Plan

## Goal

Identify large non-private project assets that may be suitable for Git LFS later.

## Candidate CSV

$LfsCsv

## Candidate counts

- Files/rows: $($Lfs.Count)
- MB represented: $LfsMB

## git lfs status

- git lfs available: $([bool]$GitLfs)
$(if($GitLfs){"- git lfs version: $GitLfs"}else{"- git lfs not available or not detected."})

## Before enabling Git LFS

Do not run git lfs track yet.

First decide:
- Which repo should own LFS objects.
- Which extensions are actually required for project run.
- Which files are non-private.
- Whether GitHub LFS quota is enough.
- Whether clone/restore test works.

## Top candidates by size

$($LfsTop | Format-Table -AutoSize | Out-String -Width 2800)

## Decision

Git LFS is not enabled yet.
"@ | Set-Content -LiteralPath $LfsDryRun -Encoding UTF8

@"
# Local Archive Dry-Run Plan

## Goal

Keep cache/runtime/diagnostics/installers/history dumps outside normal Git, but not lost.

## Candidate CSV

$LocalCsv

## Candidate counts

- Files/rows: $($LocalOnly.Count)
- MB represented: $LocalMB

## Recommended future root

$FutureLocalOnlyRoot

## Rule

Local archive only does not mean delete.
It means:
- keep outside normal Git
- preserve path in manifest
- decide later whether to compress, encrypt, or mark recreatable

## Top candidates by size

$($LocalTop | Format-Table -AutoSize | Out-String -Width 2800)
"@ | Set-Content -LiteralPath $LocalDryRun -Encoding UTF8

@"
# Restore Test Checklist

## Goal

Prove that Igor can continue work on a new or clean machine without losing project context.

## Test 1 - GitHub control repo restore

- Clone Incomesbook/workspaces.
- Open Igor_Master_Workspace.code-workspace.
- Confirm CURRENT_STATUS_MAP.md exists.
- Confirm capsules exist:
  - G01_P01_POCKETOPTION
  - G01_P02_TRADINGVIEW_CLAUDE
  - G01_P03_MARKET_AGENT
  - G01_ALL_ABOUT_TRADING

## Test 2 - CleanSource restore

- Confirm CleanSource folders exist or can be recreated:
  - G01_P01_PocketOption_CleanSource
  - G01_P02_TVClaude_CleanSource
  - G01_P03_MarketAgent_CleanSource
  - LiveControl_CleanSource

## Test 3 - Archive restore

Not ready yet.

Needed first:
- encrypted archive destination
- archive creation script
- archive verification script
- restore extraction test

## Test 4 - AI context restore

Not ready yet.

Needed first:
- raw AI chat archive decision
- Claude/Codex/Copilot/ChatGPT export procedure
- searchable index strategy

## Test 5 - Full project run

Not ready yet.

Needed first:
- identify REQUIRED_TO_RUN files
- identify recreatable dependencies
- identify private files needed locally but not in Git

## Pass condition

The system is not fully finished until:
1. GitHub control repo restores project map.
2. CleanSource restores safe project source.
3. Archive layer restores raw/history/private material.
4. AI context can be found and read by future agents.
5. Missing/recreatable files are documented.
"@ | Set-Content -LiteralPath $RestoreChecklist -Encoding UTF8

@"
# Next Backup Actions

## Current state

Archive dry-run plan completed.

## Done

- Full storage manifest exists.
- Storage policy exists.
- Archive dry-run CSVs exist.
- Encrypted archive candidate plan exists.
- Git LFS review dry-run plan exists.
- Local archive dry-run plan exists.
- Restore test checklist exists.

## Next recommended order

### 1. Choose encrypted archive method

Recommended options to decide manually:
- 7z AES-256 archive if 7z is installed
- VeraCrypt container
- Cryptomator vault
- rclone crypt remote
- private offline drive backup

Do not create archive until destination and password/key policy are clear.

### 2. Create encrypted archive dry-run verification

Before real archive:
- count files
- count MB
- check missing paths
- split by root
- exclude secret-like filenames from normal logs
- write restore instructions

### 3. Review Git LFS candidates

Before enabling LFS:
- verify non-private
- verify required for project
- verify GitHub quota
- test clone

### 4. Weekly/biweekly sync dry-run

Do not enable scheduled sync yet.
First create dry-run task that only reports what would change.

### 5. Restore test

Only after archive exists.
"@ | Set-Content -LiteralPath $NextActions -Encoding UTF8

@"
# Archive Dry-Run Plan Checkpoint

## Status

Archive Dry-Run Plan Phase completed.

## What was done

- Loaded latest full restore manifest.
- Split candidates into encrypted/archive/LFS/local/private/AI context CSVs.
- Created encrypted archive dry-run plan.
- Created Git LFS review dry-run plan.
- Created local archive dry-run plan.
- Created restore test checklist.
- Created next backup actions.
- Updated status map.

## What was not done

- no raw files copied
- no archive created
- no Git LFS enabled
- no sync enabled
- no restore test executed

## Next phase

Choose encrypted archive method and create encrypted archive DRY-RUN verification script.
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
- Archive Dry-Run Plan Phase completed.
- Encrypted archive candidate CSV created locally.
- Git LFS review CSV created locally.
- Local archive-only CSV created locally.
- Restore test checklist created.

## Current latest phase

Archive Dry-Run Plan completed.

## Not done yet

- Raw AI chats are not copied to GitHub.
- Git LFS is not enabled.
- Encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Restore test is not done.

## Next

Choose archive method:
1. 7z AES-256
2. VeraCrypt
3. Cryptomator
4. rclone crypt
5. offline drive backup

Then create encrypted archive dry-run verification script.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 6 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Commit and push"

$FilesToAdd=@(
  "tools\Run-ArchiveDryRunPlanPhase.ps1",
  "03_AI_CHATS\ARCHIVE_DRYRUN_PLAN.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_DRYRUN_PLAN.md",
  "03_AI_CHATS\GIT_LFS_REVIEW_DRYRUN_PLAN.md",
  "03_AI_CHATS\LOCAL_ARCHIVE_DRYRUN_PLAN.md",
  "03_AI_CHATS\RESTORE_TEST_CHECKLIST.md",
  "03_AI_CHATS\NEXT_BACKUP_ACTIONS.md",
  "03_AI_CHATS\ARCHIVE_DRYRUN_PLAN_CHECKPOINT.md",
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
  git -C $Repo commit -m "Add archive dry-run backup plan" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "ENCRYPTED CSV: $EncryptedCsv" -ForegroundColor Green
Write-Host "LFS CSV: $LfsCsv" -ForegroundColor Green
Write-Host "LOCAL CSV: $LocalCsv" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
