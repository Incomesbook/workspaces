$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$ArchiveRoot="J:\Setup_VcCode_Workspace\S30_Large_Local_Archive"
$EncryptedRoot="$ArchiveRoot\ENCRYPTED_AI_CHAT_ARCHIVE"
$RestoreRoot="J:\Setup_VcCode_Workspace\S40_Restore_Manifests"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule,$ArchiveRoot,$EncryptedRoot,$RestoreRoot | Out-Null

$RunReport="$AuditRoot\ENCRYPTED_ARCHIVE_SAMPLE_SPLIT_RUN_$Stamp.md"
$SplitPlanCsv="$AuditRoot\ENCRYPTED_ARCHIVE_SPLIT_PLAN_$Stamp.csv"
$RootSummaryCsv="$AuditRoot\ENCRYPTED_ARCHIVE_ROOT_SUMMARY_$Stamp.csv"
$SampleDir="$AuditRoot\_7Z_SAMPLE_TEST_$Stamp"
$SampleArchive="$AuditRoot\_7Z_SAMPLE_TEST_$Stamp.7z"
$SampleExtract="$AuditRoot\_7Z_SAMPLE_EXTRACT_$Stamp"

$SampleDoc="$Capsule\ENCRYPTED_ARCHIVE_SAMPLE_TEST_RESULT.md"
$SplitPlanDoc="$Capsule\ENCRYPTED_ARCHIVE_SPLIT_PLAN.md"
$PasswordPolicyDoc="$Capsule\ENCRYPTED_ARCHIVE_PASSWORD_POLICY.md"
$ExecutionGateDoc="$Capsule\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md"
$Checkpoint="$Capsule\ENCRYPTED_ARCHIVE_SAMPLE_SPLIT_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Encrypted Archive Sample Split Checkpoint

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Safety

No raw AI chats archived.
No raw project copied.
No Git LFS enabled.
No full encrypted archive created.
No password saved to GitHub.
No files deleted except temporary sample files if cleanup was possible.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-EncryptedArchiveSampleAndSplitPlan.ps1 `
    03_AI_CHATS\ENCRYPTED_ARCHIVE_SAMPLE_SPLIT_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record encrypted archive sample split stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 180
  exit 0
}

function Find-7Zip {
  $candidates=@()

  $cmd=Get-Command 7z.exe -ErrorAction SilentlyContinue
  if($cmd){ $candidates += $cmd.Source }

  $cmd=Get-Command 7z -ErrorAction SilentlyContinue
  if($cmd){ $candidates += $cmd.Source }

  $common=@(
    "$env:ProgramFiles\7-Zip\7z.exe",
    "${env:ProgramFiles(x86)}\7-Zip\7z.exe",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\7zip.7zip_Microsoft.Winget.Source_8wekyb3d8bbwe\7z.exe"
  )

  foreach($p in $common){
    if($p -and (Test-Path -LiteralPath $p)){
      $candidates += $p
    }
  }

  $fromDisk=Get-ChildItem -LiteralPath "C:\Program Files","C:\Program Files (x86)" -Filter "7z.exe" -Recurse -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

  foreach($p in $fromDisk){
    if($p -and (Test-Path -LiteralPath $p)){
      $candidates += $p
    }
  }

  return ($candidates | Select-Object -Unique | Select-Object -First 1)
}

"# Encrypted Archive Sample Test + Split Plan Dry-Run" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: sample encryption test + split-plan dry-run only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no raw AI chat archive created"
Add-Line "- no raw project copied"
Add-Line "- no Git LFS enable"
Add-Line "- no scheduled sync enable"
Add-Line "- no real archive password requested"
Add-Line "- sample password is temporary and not used for real data"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestEncrypted=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $LatestEncrypted){
  Stop-Safely "Encrypted candidate CSV not found."
}

Add-Line "- Repo: $Repo"
Add-Line "- Latest encrypted CSV: $($LatestEncrypted.FullName)"
Add-Line "- ArchiveRoot: $ArchiveRoot"
Add-Line "- EncryptedRoot: $EncryptedRoot"
Add-Line "- RestoreRoot: $RestoreRoot"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / FIND 7-ZIP ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Find 7-Zip"

$SevenZipPath=Find-7Zip

if(-not $SevenZipPath){
  Stop-Safely "7-Zip was installed by winget but 7z.exe still was not found. Close/reopen PowerShell or check C:\Program Files\7-Zip."
}

$SevenZipDir=Split-Path -Parent $SevenZipPath
if($env:Path -notlike "*$SevenZipDir*"){
  $env:Path="$env:Path;$SevenZipDir"
}

Add-Line "- 7z path: $SevenZipPath"
Add-Line "- 7z dir added to current session PATH: $SevenZipDir"

$SevenZipInfo=& $SevenZipPath i 2>&1
Add-Line "`n7z info first lines:"
$SevenZipInfo | Select-Object -First 20 | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 3 / SMALL ENCRYPTED SAMPLE TEST ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Small encrypted sample test"

New-Item -ItemType Directory -Force $SampleDir,$SampleExtract | Out-Null

$SampleFile=Join-Path $SampleDir "sample_restore_test.txt"
$SampleContent="Igor archive sample test. Generated $Stamp. This is not raw chat data."
$SampleContent | Set-Content -LiteralPath $SampleFile -Encoding UTF8

$BeforeHash=(Get-FileHash -LiteralPath $SampleFile -Algorithm SHA256).Hash

# Temporary local sample password only. Not used for real archives.
$SamplePassword="SAMPLE-ONLY-$Stamp"

$ArchiveArgs=@(
  "a",
  "-t7z",
  "-mhe=on",
  "-mx=7",
  "-p$SamplePassword",
  $SampleArchive,
  "$SampleDir\*"
)

& $SevenZipPath @ArchiveArgs | Tee-Object -Variable ArchiveOutput | Out-Null
$ArchiveExit=$LASTEXITCODE

Add-Line "- 7z archive exit code: $ArchiveExit"
$ArchiveOutput | Select-Object -First 80 | ForEach-Object { Add-Line $_ }

if($ArchiveExit -ne 0){
  Stop-Safely "7-Zip sample archive creation failed."
}

if(-not (Test-Path -LiteralPath $SampleArchive)){
  Stop-Safely "7-Zip sample archive was not created."
}

$ListArgs=@(
  "l",
  "-p$SamplePassword",
  $SampleArchive
)

& $SevenZipPath @ListArgs | Tee-Object -Variable ListOutput | Out-Null
$ListExit=$LASTEXITCODE

Add-Line "- 7z list exit code: $ListExit"
$ListOutput | Select-Object -First 80 | ForEach-Object { Add-Line $_ }

if($ListExit -ne 0){
  Stop-Safely "7-Zip sample archive list test failed."
}

$ExtractArgs=@(
  "x",
  "-y",
  "-p$SamplePassword",
  "-o$SampleExtract",
  $SampleArchive
)

& $SevenZipPath @ExtractArgs | Tee-Object -Variable ExtractOutput | Out-Null
$ExtractExit=$LASTEXITCODE

Add-Line "- 7z extract exit code: $ExtractExit"
$ExtractOutput | Select-Object -First 80 | ForEach-Object { Add-Line $_ }

if($ExtractExit -ne 0){
  Stop-Safely "7-Zip sample archive extract test failed."
}

$ExtractedFile=Get-ChildItem -LiteralPath $SampleExtract -Filter "sample_restore_test.txt" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1

if(-not $ExtractedFile){
  Stop-Safely "Extracted sample file not found."
}

$AfterHash=(Get-FileHash -LiteralPath $ExtractedFile.FullName -Algorithm SHA256).Hash
$SampleReady=($BeforeHash -eq $AfterHash)

Add-Line "- Before hash: $BeforeHash"
Add-Line "- After hash: $AfterHash"
Add-Line "- Sample ready: $SampleReady"

if(-not $SampleReady){
  Stop-Safely "Sample archive hash mismatch."
}

# Clean up sample folders and archive to avoid clutter.
try {
  Remove-Item -LiteralPath $SampleDir -Recurse -Force -ErrorAction Stop
  Remove-Item -LiteralPath $SampleExtract -Recurse -Force -ErrorAction Stop
  Remove-Item -LiteralPath $SampleArchive -Force -ErrorAction Stop
  Add-Line "- Temporary sample files cleaned: True"
} catch {
  Add-Line "- Temporary sample cleanup warning: $($_.Exception.Message)"
}

Write-Host "`n=== STEP 4 / BUILD SPLIT PLAN DRY-RUN ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Build split plan dry-run"

$Rows=Import-Csv -LiteralPath $LatestEncrypted.FullName
$TotalRows=$Rows.Count
$TotalMB=[math]::Round((($Rows | Measure-Object MB -Sum).Sum),2)

# Keep chunks conservative to avoid huge single archive files.
$MaxShardMB=20480

$Sorted=$Rows | Sort-Object Root,RelativeFolder,FileName
$Plan=New-Object System.Collections.Generic.List[object]

$shardIndex=1
$currentMB=0
$currentRoot=""

foreach($r in $Sorted){
  $mb=[double]$r.MB
  $root="$($r.Root)"

  if($currentRoot -ne "" -and $root -ne $currentRoot){
    $shardIndex++
    $currentMB=0
  }

  if($currentMB -gt 0 -and ($currentMB + $mb) -gt $MaxShardMB){
    $shardIndex++
    $currentMB=0
  }

  $currentRoot=$root
  $shardName=("AI_CHAT_ENCRYPTED_SHARD_{0:D4}" -f $shardIndex)

  $Plan.Add([pscustomobject]@{
    Shard=$shardName
    Root=$r.Root
    RelativeFolder=$r.RelativeFolder
    FileName=$r.FileName
    Extension=$r.Extension
    MB=$r.MB
    RestoreRole=$r.RestoreRole
    StorageLayer=$r.StorageLayer
    Priority=$r.Priority
    Reason=$r.Reason
    FutureArchivePath=(Join-Path $EncryptedRoot "$shardName.7z")
  }) | Out-Null

  $currentMB += $mb
}

$Plan | Export-Csv -LiteralPath $SplitPlanCsv -NoTypeInformation -Encoding UTF8

$RootSummary=$Plan |
  Group-Object Root |
  ForEach-Object {
    [pscustomobject]@{
      Root=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
      Shards=($_.Group | Select-Object -ExpandProperty Shard -Unique | Measure-Object).Count
    }
  } |
  Sort-Object MB -Descending

$RootSummary | Export-Csv -LiteralPath $RootSummaryCsv -NoTypeInformation -Encoding UTF8

$ShardSummary=$Plan |
  Group-Object Shard |
  ForEach-Object {
    [pscustomobject]@{
      Shard=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
      FutureArchivePath=($_.Group | Select-Object -First 1).FutureArchivePath
      RootCount=($_.Group | Select-Object -ExpandProperty Root -Unique | Measure-Object).Count
    }
  } |
  Sort-Object Shard

$ShardCount=$ShardSummary.Count
$LargestShardMB=[math]::Round((($ShardSummary | Measure-Object MB -Maximum).Maximum),2)

Add-Line "- Encrypted candidate rows: $TotalRows"
Add-Line "- Encrypted candidate MB: $TotalMB"
Add-Line "- Max shard MB target: $MaxShardMB"
Add-Line "- Shard count: $ShardCount"
Add-Line "- Largest shard MB: $LargestShardMB"
Add-Line "- Split plan CSV: $SplitPlanCsv"
Add-Line "- Root summary CSV: $RootSummaryCsv"

Write-Host "`n=== STEP 5 / WRITE DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Write documents"

@"
# Encrypted Archive Sample Test Result

## Status

PASSED.

## 7-Zip

- 7z path: $SevenZipPath
- 7z directory added to current session PATH: $SevenZipDir

## Sample test

- Archive creation exit code: $ArchiveExit
- List exit code: $ListExit
- Extract exit code: $ExtractExit
- Hash matched: $SampleReady

## Important

This was only a tiny sample test.

No raw AI chats were archived.
No project files were archived.
No real archive password was requested.
The temporary sample archive was removed after verification.
"@ | Set-Content -LiteralPath $SampleDoc -Encoding UTF8

@"
# Encrypted Archive Split Plan

## Status

Dry-run split plan created.

## Source CSV

$($LatestEncrypted.FullName)

## Output CSVs

- Split plan:
  $SplitPlanCsv

- Root summary:
  $RootSummaryCsv

## Summary

- Candidate files/rows: $TotalRows
- Candidate MB: $TotalMB
- Max shard target MB: $MaxShardMB
- Shard count: $ShardCount
- Largest shard MB: $LargestShardMB

## Future archive root

$EncryptedRoot

## Shard summary top 80

$($ShardSummary | Select-Object -First 80 | Format-Table -AutoSize | Out-String -Width 2200)

## Root summary

$($RootSummary | Format-Table -AutoSize | Out-String -Width 2400)

## Decision

This is still dry-run only.

No real archive was created.
No raw files were copied.
"@ | Set-Content -LiteralPath $SplitPlanDoc -Encoding UTF8

@"
# Encrypted Archive Password Policy

## Critical rule

Never paste real archive passwords into ChatGPT.
Never save passwords in GitHub.
Never commit passwords in scripts, .env files, markdown files, or restore manifests.

## Recommended handling

For real archive execution later:
- script should prompt locally with Read-Host -AsSecureString
- password must remain outside GitHub
- recovery phrase/password should be stored in your own offline/private password manager
- create a small restore test before trusting the archive

## Important limitation

Any command-line archiver may expose a password briefly to the local process list if passed as a command argument.
For highly sensitive archives, consider VeraCrypt/Cryptomator/rclone crypt instead of plain command-line password arguments.

## Current phase

Only sample temporary password was used.
No real password was requested.
No real raw archive was created.
"@ | Set-Content -LiteralPath $PasswordPolicyDoc -Encoding UTF8

@"
# Encrypted Archive Execution Gate

## Current gate status

- 7-Zip usable: True
- Sample encrypted archive test: PASSED
- Split plan created: True
- Raw archive created: False
- Restore test on real archive: False

## Allowed next

- Missing-source dry-run for split plan
- Per-shard dry-run counts
- User choice of archive destination
- User choice of encryption method

## Not allowed yet

- full raw archive execution
- deleting originals
- marking archive layer complete
- enabling scheduled sync

## Required before full real archive

1. Choose destination.
2. Confirm enough disk space.
3. Choose password storage policy.
4. Run missing-source dry-run.
5. Run one small real shard archive test.
6. Extract and verify the small shard.
7. Only then archive the full set in split shards.
"@ | Set-Content -LiteralPath $ExecutionGateDoc -Encoding UTF8

@"
# Encrypted Archive Sample Split Checkpoint

## Status

Encrypted Archive Sample Test + Split Plan completed.

## What was done

- Found 7-Zip path.
- Added 7-Zip folder to current session PATH.
- Created tiny encrypted sample archive.
- Listed encrypted sample archive.
- Extracted encrypted sample archive.
- Verified SHA256 hash.
- Removed temporary sample files.
- Created encrypted archive split-plan dry-run.
- Wrote password policy.
- Wrote execution gate.
- Updated current status map.

## What was not done

- no raw AI chats archived
- no project raw files archived
- no Git LFS enabled
- no scheduled sync enabled
- no full restore test

## Next phase

Encrypted archive missing-source dry-run + first tiny real shard test.
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
- 7-Zip installed/found and sample encryption tested.
- Encrypted archive split-plan dry-run created.

## Current latest phase

Encrypted Archive Sample Test + Split Plan completed.

## Not done yet

- Raw AI chats are not archived.
- Git LFS is not enabled.
- Full encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Full restore test is not done.

## Next

Encrypted archive missing-source dry-run + first tiny real shard test.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 6 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Commit and push"

$FilesToAdd=@(
  "tools\Run-EncryptedArchiveSampleAndSplitPlan.ps1",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_SAMPLE_TEST_RESULT.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_SPLIT_PLAN.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_PASSWORD_POLICY.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_SAMPLE_SPLIT_CHECKPOINT.md",
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
  git -C $Repo commit -m "Add encrypted archive sample test and split plan" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "SPLIT PLAN CSV: $SplitPlanCsv" -ForegroundColor Green
Write-Host "ROOT SUMMARY CSV: $RootSummaryCsv" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
