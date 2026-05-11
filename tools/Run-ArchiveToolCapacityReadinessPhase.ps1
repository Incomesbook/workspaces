$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$ArchiveRoot="J:\Setup_VcCode_Workspace\S30_Large_Local_Archive"
$EncryptedRoot="$ArchiveRoot\ENCRYPTED_AI_CHAT_ARCHIVE"
$LfsReviewRoot="$ArchiveRoot\GIT_LFS_REVIEW"
$LocalOnlyRoot="$ArchiveRoot\LOCAL_ONLY_ARCHIVE"
$RestoreRoot="J:\Setup_VcCode_Workspace\S40_Restore_Manifests"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule | Out-Null

$RunReport="$AuditRoot\ARCHIVE_TOOL_CAPACITY_READINESS_RUN_$Stamp.md"
$ReadinessDoc="$Capsule\ARCHIVE_TOOL_CAPACITY_READINESS.md"
$CapacityDoc="$Capsule\BACKUP_DESTINATION_CAPACITY_REPORT.md"
$SevenZipDoc="$Capsule\SEVENZIP_INSTALL_AND_ENCRYPTION_READINESS.md"
$LfsReadinessDoc="$Capsule\GIT_LFS_READINESS_REPORT.md"
$ExecutionGateDoc="$Capsule\ARCHIVE_EXECUTION_GATE.md"
$Checkpoint="$Capsule\ARCHIVE_TOOL_CAPACITY_READINESS_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Archive Tool Capacity Readiness Checkpoint

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Safety

No raw files copied.
No raw chats copied.
No encrypted archive created.
No Git LFS enabled.
No sync enabled.
No files deleted.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-ArchiveToolCapacityReadinessPhase.ps1 `
    03_AI_CHATS\ARCHIVE_TOOL_CAPACITY_READINESS_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record archive tool capacity readiness stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 180
  exit 0
}

function Get-DirSizeMB($Path){
  if(Test-Path -LiteralPath $Path){
    $sum=(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    return [math]::Round(($sum / 1MB),2)
  }
  return 0
}

"# Archive Tool Capacity Readiness Phase" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: tool/capacity readiness only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no raw file copy"
Add-Line "- no raw chat copy"
Add-Line "- no encrypted archive creation"
Add-Line "- no Git LFS enable"
Add-Line "- no sync enable"
Add-Line "- no delete"
Add-Line "- optional 7-Zip install only after explicit local YES"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestEncrypted=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$LatestLfs=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ARCHIVE_DRYRUN_LFS_CANDIDATES_*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$LatestLocal=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ARCHIVE_DRYRUN_LOCAL_ONLY_CANDIDATES_*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if(-not $LatestEncrypted){ Stop-Safely "Encrypted dry-run CSV not found." }
if(-not $LatestLfs){ Stop-Safely "LFS dry-run CSV not found." }
if(-not $LatestLocal){ Stop-Safely "Local-only dry-run CSV not found." }

Add-Line "- Repo: $Repo"
Add-Line "- Latest encrypted CSV: $($LatestEncrypted.FullName)"
Add-Line "- Latest LFS CSV: $($LatestLfs.FullName)"
Add-Line "- Latest local-only CSV: $($LatestLocal.FullName)"
Add-Line "- ArchiveRoot: $ArchiveRoot"
Add-Line "- RestoreRoot: $RestoreRoot"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / READ CSV COUNTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Read CSV counts"

$EncryptedRows=Import-Csv -LiteralPath $LatestEncrypted.FullName
$LfsRows=Import-Csv -LiteralPath $LatestLfs.FullName
$LocalRows=Import-Csv -LiteralPath $LatestLocal.FullName

$EncryptedCount=$EncryptedRows.Count
$LfsCount=$LfsRows.Count
$LocalCount=$LocalRows.Count

$EncryptedMB=[math]::Round((($EncryptedRows | Measure-Object MB -Sum).Sum),2)
$LfsMB=[math]::Round((($LfsRows | Measure-Object MB -Sum).Sum),2)
$LocalMB=[math]::Round((($LocalRows | Measure-Object MB -Sum).Sum),2)

Add-Line "- Encrypted rows: $EncryptedCount / MB: $EncryptedMB"
Add-Line "- LFS rows: $LfsCount / MB: $LfsMB"
Add-Line "- Local-only rows: $LocalCount / MB: $LocalMB"

Write-Host "`n=== STEP 3 / CREATE TARGET ROOTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Create target roots"

New-Item -ItemType Directory -Force $ArchiveRoot,$EncryptedRoot,$LfsReviewRoot,$LocalOnlyRoot,$RestoreRoot | Out-Null

Add-Line "- ArchiveRoot exists: $(Test-Path -LiteralPath $ArchiveRoot)"
Add-Line "- EncryptedRoot exists: $(Test-Path -LiteralPath $EncryptedRoot)"
Add-Line "- LfsReviewRoot exists: $(Test-Path -LiteralPath $LfsReviewRoot)"
Add-Line "- LocalOnlyRoot exists: $(Test-Path -LiteralPath $LocalOnlyRoot)"
Add-Line "- RestoreRoot exists: $(Test-Path -LiteralPath $RestoreRoot)"

Write-Host "`n=== STEP 4 / CAPACITY CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Capacity check"

$DriveJ=Get-PSDrive -Name J -ErrorAction SilentlyContinue
if(-not $DriveJ){ Stop-Safely "Drive J: not found." }

$JFreeMB=[math]::Round(($DriveJ.Free/1MB),2)
$JUsedMB=[math]::Round(($DriveJ.Used/1MB),2)
$JFreeGB=[math]::Round(($DriveJ.Free/1GB),2)
$JUsedGB=[math]::Round(($DriveJ.Used/1GB),2)

$ArchiveCurrentMB=Get-DirSizeMB $ArchiveRoot
$RestoreCurrentMB=Get-DirSizeMB $RestoreRoot

$EstimatedEncryptedArchiveNeedGB=[math]::Round(($EncryptedMB/1024),2)
$EstimatedLocalNeedGB=[math]::Round(($LocalMB/1024),2)
$EstimatedLfsReviewNeedGB=[math]::Round(($LfsMB/1024),2)

# Conservative archive planning: assume encrypted archive may need close to source size before compression.
$MinimumRecommendedFreeGB=[math]::Round((($EncryptedMB + $LocalMB + $LfsMB) / 1024 * 1.15),2)

Add-Line "- J used GB: $JUsedGB"
Add-Line "- J free GB: $JFreeGB"
Add-Line "- ArchiveRoot current MB: $ArchiveCurrentMB"
Add-Line "- RestoreRoot current MB: $RestoreCurrentMB"
Add-Line "- Estimated encrypted candidate GB: $EstimatedEncryptedArchiveNeedGB"
Add-Line "- Estimated local-only candidate GB: $EstimatedLocalNeedGB"
Add-Line "- Estimated LFS review candidate GB: $EstimatedLfsReviewNeedGB"
Add-Line "- Minimum recommended free GB for full raw archive staging: $MinimumRecommendedFreeGB"

$CapacityStatus="UNKNOWN"
if($JFreeGB -ge $MinimumRecommendedFreeGB){
  $CapacityStatus="ENOUGH_FOR_FULL_STAGING_ESTIMATE"
} elseif($JFreeGB -ge ($EstimatedEncryptedArchiveNeedGB * 0.5)){
  $CapacityStatus="PARTIAL_OR_SPLIT_ARCHIVE_REQUIRED"
} else {
  $CapacityStatus="NOT_ENOUGH_FOR_FULL_ARCHIVE_STAGING"
}

Add-Line "- Capacity status: $CapacityStatus"

Write-Host "`n=== STEP 5 / TOOL CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Tool check"

$SevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
if(-not $SevenZip){ $SevenZip = Get-Command 7z -ErrorAction SilentlyContinue }

$Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if(-not $Winget){ $Winget = Get-Command winget -ErrorAction SilentlyContinue }

$GitLfsText=$null
$GitLfsAvailable=$false
try {
  $GitLfsText = git lfs version 2>&1
  if($LASTEXITCODE -eq 0){ $GitLfsAvailable=$true }
} catch {
  $GitLfsAvailable=$false
}

Add-Line "- 7z found before install prompt: $([bool]$SevenZip)"
if($SevenZip){ Add-Line "- 7z path: $($SevenZip.Source)" }
Add-Line "- winget found: $([bool]$Winget)"
if($Winget){ Add-Line "- winget path: $($Winget.Source)" }
Add-Line "- git lfs available: $GitLfsAvailable"
if($GitLfsAvailable){ Add-Line "- git lfs version: $GitLfsText" }

Write-Host "`n=== STEP 6 / OPTIONAL 7-ZIP INSTALL PROMPT ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Optional 7-Zip install prompt"

$InstallAttempted=$false
$InstallResult="NOT_NEEDED_OR_SKIPPED"

if(-not $SevenZip){
  Write-Host ""
  Write-Host "7-Zip не найден." -ForegroundColor Yellow
  Write-Host "Для encrypted archive лучше иметь 7-Zip (.7z AES-256)." -ForegroundColor Yellow
  Write-Host "Напиши YES чтобы установить 7-Zip через winget. Любой другой ввод = пропустить установку." -ForegroundColor Yellow
  $answer=Read-Host "Install 7-Zip now via winget?"
  Add-Line "- Local install answer: $answer"

  if($answer -eq "YES"){
    if(-not $Winget){
      $InstallResult="FAILED_WINGET_NOT_FOUND"
      Add-Line "- Install skipped/failed: winget not found."
    } else {
      $InstallAttempted=$true
      Add-Line "- Installing 7-Zip via winget..."
      winget install --id 7zip.7zip -e --source winget --accept-package-agreements --accept-source-agreements | Tee-Object -Variable WingetOutput | Out-Null
      $WingetOutput | ForEach-Object { Add-Line $_ }

      $SevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
      if(-not $SevenZip){ $SevenZip = Get-Command 7z -ErrorAction SilentlyContinue }

      if($SevenZip){
        $InstallResult="INSTALLED_OR_FOUND_AFTER_INSTALL"
      } else {
        $InstallResult="INSTALL_ATTEMPTED_BUT_7Z_NOT_IN_PATH"
      }
    }
  } else {
    $InstallResult="USER_SKIPPED_INSTALL"
  }
} else {
  $InstallResult="7Z_ALREADY_FOUND"
}

Add-Line "- Install attempted: $InstallAttempted"
Add-Line "- Install result: $InstallResult"

$SevenZipAfter = Get-Command 7z.exe -ErrorAction SilentlyContinue
if(-not $SevenZipAfter){ $SevenZipAfter = Get-Command 7z -ErrorAction SilentlyContinue }

Add-Line "- 7z found after prompt: $([bool]$SevenZipAfter)"
if($SevenZipAfter){ Add-Line "- 7z final path: $($SevenZipAfter.Source)" }

Write-Host "`n=== STEP 7 / WRITE READINESS DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 7 - Write readiness documents"

@"
# Archive Tool Capacity Readiness

## Status

Archive Tool + Capacity Readiness Phase completed.

## Source CSVs

- Encrypted:
  $($LatestEncrypted.FullName)

- Git LFS:
  $($LatestLfs.FullName)

- Local-only:
  $($LatestLocal.FullName)

## Candidate counts

- Encrypted rows: $EncryptedCount / $EncryptedMB MB
- LFS rows: $LfsCount / $LfsMB MB
- Local-only rows: $LocalCount / $LocalMB MB

## Target roots

- ArchiveRoot:
  $ArchiveRoot

- EncryptedRoot:
  $EncryptedRoot

- LfsReviewRoot:
  $LfsReviewRoot

- LocalOnlyRoot:
  $LocalOnlyRoot

- RestoreRoot:
  $RestoreRoot

## Capacity

- J used GB: $JUsedGB
- J free GB: $JFreeGB
- Estimated encrypted candidate GB: $EstimatedEncryptedArchiveNeedGB
- Estimated local-only candidate GB: $EstimatedLocalNeedGB
- Estimated LFS review candidate GB: $EstimatedLfsReviewNeedGB
- Minimum recommended free GB for full raw archive staging: $MinimumRecommendedFreeGB
- Capacity status: $CapacityStatus

## Tool status

- 7z found: $([bool]$SevenZipAfter)
$(if($SevenZipAfter){"- 7z path: $($SevenZipAfter.Source)"}else{"- 7z path: NOT FOUND"})
- winget found: $([bool]$Winget)
$(if($Winget){"- winget path: $($Winget.Source)"}else{"- winget path: NOT FOUND"})
- Git LFS available: $GitLfsAvailable
$(if($GitLfsAvailable){"- Git LFS version: $GitLfsText"}else{"- Git LFS version: NOT FOUND"})

## Safety

No raw files were copied.
No raw chats were copied.
No encrypted archive was created.
No Git LFS was enabled.
No sync was enabled.
"@ | Set-Content -LiteralPath $ReadinessDoc -Encoding UTF8

@"
# Backup Destination Capacity Report

## Drive J

- Used GB: $JUsedGB
- Free GB: $JFreeGB

## Current archive folders

- ArchiveRoot: $ArchiveRoot
- ArchiveRoot current MB: $ArchiveCurrentMB

- RestoreRoot: $RestoreRoot
- RestoreRoot current MB: $RestoreCurrentMB

## Estimated candidates

- Encrypted candidate GB: $EstimatedEncryptedArchiveNeedGB
- Local-only candidate GB: $EstimatedLocalNeedGB
- LFS review candidate GB: $EstimatedLfsReviewNeedGB

## Capacity status

$CapacityStatus

## Interpretation

ENOUGH_FOR_FULL_STAGING_ESTIMATE:
Enough free space for full staging estimate.

PARTIAL_OR_SPLIT_ARCHIVE_REQUIRED:
Do not make one huge archive. Split by root/project/date.

NOT_ENOUGH_FOR_FULL_ARCHIVE_STAGING:
Need external drive/cloud/archive target before raw backup execution.

## Current decision

No full archive execution yet.
"@ | Set-Content -LiteralPath $CapacityDoc -Encoding UTF8

@"
# SevenZip Install And Encryption Readiness

## Why 7-Zip

7-Zip .7z archives support AES-256 encryption and can encrypt archive headers/file names.

## Current status

- 7z found before prompt: $([bool]$SevenZip)
- 7z found after prompt: $([bool]$SevenZipAfter)
$(if($SevenZipAfter){"- 7z final path: $($SevenZipAfter.Source)"}else{"- 7z final path: NOT FOUND"})
- Install attempted: $InstallAttempted
- Install result: $InstallResult
- winget found: $([bool]$Winget)

## Password rule

Never paste archive passwords into ChatGPT.
Never save archive passwords inside GitHub.
Future archive script should ask for password locally or use a local-only protected key file.

## Next

If 7z is available:
- create tiny encrypted test archive
- verify archive can list and extract
- then create split archive dry-run

If 7z is not available:
- install 7-Zip first
- re-run readiness check
"@ | Set-Content -LiteralPath $SevenZipDoc -Encoding UTF8

@"
# Git LFS Readiness Report

## Current status

- Git LFS available: $GitLfsAvailable
$(if($GitLfsAvailable){"- Git LFS version: $GitLfsText"}else{"- Git LFS version: NOT FOUND"})

## Candidate source

$($LatestLfs.FullName)

## Candidate count

- LFS rows: $LfsCount
- LFS MB: $LfsMB

## Current decision

Git LFS is available, but not enabled for any new repo in this phase.

Before enabling:
1. Choose which repo owns LFS assets.
2. Remove private/browser/session/chat raw material.
3. Approve extensions/path patterns.
4. Create .gitattributes.
5. Test clone/restore.
6. Check GitHub LFS quota.
"@ | Set-Content -LiteralPath $LfsReadinessDoc -Encoding UTF8

@"
# Archive Execution Gate

## Current gate status

- 7z available: $([bool]$SevenZipAfter)
- Capacity status: $CapacityStatus
- Git LFS available: $GitLfsAvailable
- Encrypted rows: $EncryptedCount
- Encrypted MB: $EncryptedMB

## Allowed now

- planning
- dry-run
- capacity check
- tool check
- small test archive only after 7z is available

## Not allowed yet

- full raw archive execution
- Git LFS tracking
- Git LFS push
- weekly sync
- restore marked complete

## Required before full archive execution

1. 7z available or another encryption method chosen.
2. Password/key policy chosen.
3. Destination chosen.
4. Archive split strategy chosen.
5. Missing path check completed.
6. Small encrypted test archive completed.
7. Restore test completed on a small sample.

## Current recommendation

Proceed next to:
Encrypted archive sample test + split-plan dry-run.
"@ | Set-Content -LiteralPath $ExecutionGateDoc -Encoding UTF8

@"
# Archive Tool Capacity Readiness Checkpoint

## Status

Archive Tool + Capacity Readiness Phase completed.

## What was done

- Checked latest archive dry-run CSVs.
- Created S30/S40 target folders if missing.
- Checked J: free space.
- Checked 7z / winget / Git LFS.
- Optionally prompted for 7-Zip install.
- Wrote readiness documents.
- Updated current status map.

## What was not done

- no raw files copied
- no raw chats copied
- no encrypted archive created
- no Git LFS enabled
- no sync enabled
- no restore test executed

## Next phase

Encrypted archive sample test + split-plan dry-run.
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
- Archive Tool + Capacity Readiness Phase completed.
- S30/S40 archive/restore folders are prepared.
- Git LFS availability checked.
- 7-Zip availability checked.

## Current latest phase

Archive Tool + Capacity Readiness completed.

## Not done yet

- Raw AI chats are not copied to GitHub.
- Git LFS is not enabled.
- Encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Restore test is not done.

## Next

Encrypted archive sample test + split-plan dry-run.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 8 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 8 - Commit and push"

$FilesToAdd=@(
  "tools\Run-ArchiveToolCapacityReadinessPhase.ps1",
  "03_AI_CHATS\ARCHIVE_TOOL_CAPACITY_READINESS.md",
  "03_AI_CHATS\BACKUP_DESTINATION_CAPACITY_REPORT.md",
  "03_AI_CHATS\SEVENZIP_INSTALL_AND_ENCRYPTION_READINESS.md",
  "03_AI_CHATS\GIT_LFS_READINESS_REPORT.md",
  "03_AI_CHATS\ARCHIVE_EXECUTION_GATE.md",
  "03_AI_CHATS\ARCHIVE_TOOL_CAPACITY_READINESS_CHECKPOINT.md",
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
  git -C $Repo commit -m "Add archive tool capacity readiness report" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
