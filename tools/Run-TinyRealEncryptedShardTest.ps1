$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$ArchiveRoot="J:\Setup_VcCode_Workspace\S30_Large_Local_Archive"
$EncryptedRoot="$ArchiveRoot\ENCRYPTED_AI_CHAT_ARCHIVE"
$RestoreRoot="J:\Setup_VcCode_Workspace\S40_Restore_Manifests"
$TestRoot="$RestoreRoot\TINY_REAL_ENCRYPTED_SHARD_TEST_$Stamp"

$StageDir="$AuditRoot\_TINY_REAL_SHARD_STAGE_$Stamp"
$ExtractDir="$AuditRoot\_TINY_REAL_SHARD_EXTRACT_$Stamp"
$ArchivePath="$EncryptedRoot\TINY_REAL_SHARD_TEST_$Stamp.7z"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule,$ArchiveRoot,$EncryptedRoot,$RestoreRoot,$TestRoot,$StageDir,$ExtractDir | Out-Null

$RunReport="$AuditRoot\TINY_REAL_ENCRYPTED_SHARD_TEST_RUN_$Stamp.md"
$HashManifest="$TestRoot\TINY_REAL_SHARD_HASH_MANIFEST_$Stamp.csv"
$RestoreManifest="$TestRoot\TINY_REAL_SHARD_RESTORE_MANIFEST_$Stamp.md"

$ResultDoc="$Capsule\TINY_REAL_ENCRYPTED_SHARD_TEST_RESULT.md"
$GateDoc="$Capsule\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md"
$Checkpoint="$Capsule\TINY_REAL_ENCRYPTED_SHARD_TEST_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Tiny Real Encrypted Shard Test Checkpoint

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Safety

No full raw archive created.
No Git LFS enabled.
No scheduled sync enabled.
No original files deleted.
No password saved to GitHub.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-TinyRealEncryptedShardTest.ps1 `
    03_AI_CHATS\TINY_REAL_ENCRYPTED_SHARD_TEST_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record tiny real encrypted shard test stop point" | Out-Null
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
    "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
  )

  foreach($p in $common){
    if($p -and (Test-Path -LiteralPath $p)){
      $candidates += $p
    }
  }

  return ($candidates | Select-Object -Unique | Select-Object -First 1)
}

function SecureString-ToPlainText($Secure){
  $bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
  try {
    return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

function Sanitize-FileName($Name){
  $bad=[IO.Path]::GetInvalidFileNameChars()
  $clean=$Name
  foreach($c in $bad){
    $clean=$clean.Replace($c,"_")
  }
  if($clean.Length -gt 80){
    $ext=[IO.Path]::GetExtension($clean)
    $base=[IO.Path]::GetFileNameWithoutExtension($clean)
    if($base.Length -gt 70){ $base=$base.Substring(0,70) }
    $clean="$base$ext"
  }
  return $clean
}

"# Tiny Real Encrypted Shard Test" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: one tiny real encrypted archive test"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no full archive"
Add-Line "- no Git LFS enable"
Add-Line "- no scheduled sync"
Add-Line "- no original file delete"
Add-Line "- password prompt is local only"
Add-Line "- password is not written to GitHub"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestTiny=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ENCRYPTED_ARCHIVE_TINY_REAL_SHARD_CANDIDATES_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $LatestTiny){
  Stop-Safely "Tiny real shard candidate CSV not found."
}

Add-Line "- Repo: $Repo"
Add-Line "- Latest tiny candidate CSV: $($LatestTiny.FullName)"
Add-Line "- ArchivePath: $ArchivePath"
Add-Line "- TestRoot: $TestRoot"
Add-Line "- StageDir: $StageDir"
Add-Line "- ExtractDir: $ExtractDir"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / 7Z CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - 7z check"

$SevenZipPath=Find-7Zip
if(-not $SevenZipPath){
  Stop-Safely "7z.exe not found."
}

$SevenZipDir=Split-Path -Parent $SevenZipPath
if($env:Path -notlike "*$SevenZipDir*"){
  $env:Path="$env:Path;$SevenZipDir"
}

Add-Line "- 7z path: $SevenZipPath"

Write-Host "`n=== STEP 3 / LOAD TINY CANDIDATES ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Load tiny candidates"

$Candidates=Import-Csv -LiteralPath $LatestTiny.FullName

$ValidCandidates=@()
foreach($c in $Candidates){
  $p="$($c.CandidatePath)"
  if($p -and (Test-Path -LiteralPath $p) -and ($p -notmatch "REDACTED")){
    $item=Get-Item -LiteralPath $p -ErrorAction SilentlyContinue
    if($item -and -not $item.PSIsContainer -and $item.Length -le 2MB){
      $ValidCandidates += $c
    }
  }
}

$CandidateCount=$Candidates.Count
$ValidCount=$ValidCandidates.Count
$ValidMB=[math]::Round((($ValidCandidates | Measure-Object MB -Sum).Sum),4)

Add-Line "- Candidate rows: $CandidateCount"
Add-Line "- Valid existing tiny files: $ValidCount"
Add-Line "- Valid tiny MB: $ValidMB"

if($ValidCount -lt 1){
  Stop-Safely "No valid tiny real shard files found."
}

Write-Host "`n=== STEP 4 / LOCAL PASSWORD PROMPT ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Local password prompt"

Write-Host ""
Write-Host "Введите пароль для ТЕСТОВОГО tiny encrypted archive." -ForegroundColor Yellow
Write-Host "Не присылай пароль в ChatGPT. Пароль вводится только локально в PowerShell." -ForegroundColor Yellow
Write-Host "Это маленький реальный тестовый архив, не полный архив." -ForegroundColor Yellow

$Secure1=Read-Host "Archive password" -AsSecureString
$Secure2=Read-Host "Repeat archive password" -AsSecureString

$Plain1=SecureString-ToPlainText $Secure1
$Plain2=SecureString-ToPlainText $Secure2

if([string]::IsNullOrWhiteSpace($Plain1)){
  $Plain1=$null
  $Plain2=$null
  Stop-Safely "Empty password is not allowed."
}

if($Plain1 -ne $Plain2){
  $Plain1=$null
  $Plain2=$null
  Stop-Safely "Passwords did not match."
}

$PasswordPlain=$Plain1
$Plain1=$null
$Plain2=$null

Add-Line "- Password entered locally: True"
Add-Line "- Password stored in report/GitHub: False"

Write-Host "`n=== STEP 5 / STAGE TINY FILES WITH HASH MANIFEST ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Stage tiny files with hash manifest"

$StageFilesDir=Join-Path $StageDir "files"
New-Item -ItemType Directory -Force $StageFilesDir | Out-Null

$HashRows=New-Object System.Collections.Generic.List[object]
$i=0

foreach($c in $ValidCandidates){
  $i++
  $source="$($c.CandidatePath)"
  $sourceItem=Get-Item -LiteralPath $source
  $safeName=Sanitize-FileName $sourceItem.Name
  $stageName=("file_{0:D4}_{1}" -f $i,$safeName)
  $stagePath=Join-Path $StageFilesDir $stageName

  Copy-Item -LiteralPath $source -Destination $stagePath -Force

  $sourceHash=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
  $stageHash=(Get-FileHash -LiteralPath $stagePath -Algorithm SHA256).Hash

  if($sourceHash -ne $stageHash){
    Stop-Safely "Hash mismatch during staging for $source"
  }

  $HashRows.Add([pscustomobject]@{
    Index=$i
    SourcePath=$source
    StageRelativePath=("files\" + $stageName)
    StagePath=$stagePath
    MB=[math]::Round($sourceItem.Length/1MB,6)
    SourceSHA256=$sourceHash
    StageSHA256=$stageHash
    RestoreRole=$c.RestoreRole
    StorageLayer=$c.StorageLayer
    Priority=$c.Priority
  }) | Out-Null
}

$HashRows | Export-Csv -LiteralPath $HashManifest -NoTypeInformation -Encoding UTF8

$StageMB=[math]::Round((($HashRows | Measure-Object MB -Sum).Sum),6)

Add-Line "- Files staged: $($HashRows.Count)"
Add-Line "- Stage MB: $StageMB"
Add-Line "- Hash manifest: $HashManifest"

Write-Host "`n=== STEP 6 / CREATE TINY ENCRYPTED ARCHIVE ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Create tiny encrypted archive"

if(Test-Path -LiteralPath $ArchivePath){
  Stop-Safely "Archive already exists: $ArchivePath"
}

$ArchiveArgs=@(
  "a",
  "-t7z",
  "-mhe=on",
  "-mx=7",
  "-p$PasswordPlain",
  $ArchivePath,
  "$StageDir\*"
)

& $SevenZipPath @ArchiveArgs | Tee-Object -Variable ArchiveOutput | Out-Null
$ArchiveExit=$LASTEXITCODE

Add-Line "- 7z archive exit code: $ArchiveExit"
$ArchiveOutput | Select-Object -First 120 | ForEach-Object { Add-Line $_ }

if($ArchiveExit -ne 0){
  $PasswordPlain=$null
  Stop-Safely "7-Zip tiny archive creation failed."
}

if(-not (Test-Path -LiteralPath $ArchivePath)){
  $PasswordPlain=$null
  Stop-Safely "Tiny archive was not created."
}

$ArchiveItem=Get-Item -LiteralPath $ArchivePath
$ArchiveMB=[math]::Round($ArchiveItem.Length/1MB,6)
$ArchiveSHA256=(Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash

Add-Line "- Archive MB: $ArchiveMB"
Add-Line "- Archive SHA256: $ArchiveSHA256"

Write-Host "`n=== STEP 7 / LIST AND EXTRACT VERIFY ===" -ForegroundColor Cyan
Add-Line "`n## Step 7 - List and extract verify"

$ListArgs=@(
  "l",
  "-p$PasswordPlain",
  $ArchivePath
)

& $SevenZipPath @ListArgs | Tee-Object -Variable ListOutput | Out-Null
$ListExit=$LASTEXITCODE

Add-Line "- 7z list exit code: $ListExit"
$ListOutput | Select-Object -First 120 | ForEach-Object { Add-Line $_ }

if($ListExit -ne 0){
  $PasswordPlain=$null
  Stop-Safely "7-Zip tiny archive list failed."
}

$ExtractArgs=@(
  "x",
  "-y",
  "-p$PasswordPlain",
  "-o$ExtractDir",
  $ArchivePath
)

& $SevenZipPath @ExtractArgs | Tee-Object -Variable ExtractOutput | Out-Null
$ExtractExit=$LASTEXITCODE

# Clear password variable as soon as 7z operations are done.
$PasswordPlain=$null
$Secure1=$null
$Secure2=$null

Add-Line "- 7z extract exit code: $ExtractExit"
$ExtractOutput | Select-Object -First 120 | ForEach-Object { Add-Line $_ }

if($ExtractExit -ne 0){
  Stop-Safely "7-Zip tiny archive extract failed."
}

$VerifyRows=New-Object System.Collections.Generic.List[object]
$Mismatch=0
$MissingExtracted=0

foreach($h in $HashRows){
  $extractedPath=Join-Path $ExtractDir $h.StageRelativePath
  $exists=Test-Path -LiteralPath $extractedPath

  $extractedHash=""
  $match=$false

  if($exists){
    $extractedHash=(Get-FileHash -LiteralPath $extractedPath -Algorithm SHA256).Hash
    $match=($extractedHash -eq $h.SourceSHA256)
  } else {
    $MissingExtracted++
  }

  if(-not $match){
    $Mismatch++
  }

  $VerifyRows.Add([pscustomobject]@{
    Index=$h.Index
    SourcePath=$h.SourcePath
    ExtractedPath=$extractedPath
    SourceSHA256=$h.SourceSHA256
    ExtractedSHA256=$extractedHash
    Exists=$exists
    Match=$match
  }) | Out-Null
}

$VerifyCsv="$TestRoot\TINY_REAL_SHARD_VERIFY_$Stamp.csv"
$VerifyRows | Export-Csv -LiteralPath $VerifyCsv -NoTypeInformation -Encoding UTF8

Add-Line "- Verify CSV: $VerifyCsv"
Add-Line "- Missing extracted: $MissingExtracted"
Add-Line "- Hash mismatches: $Mismatch"

if($MissingExtracted -gt 0 -or $Mismatch -gt 0){
  Stop-Safely "Tiny archive restore verification failed."
}

Write-Host "`n=== STEP 8 / CLEAN TEMP STAGING ===" -ForegroundColor Cyan
Add-Line "`n## Step 8 - Clean temp staging"

try {
  Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction Stop
  Remove-Item -LiteralPath $ExtractDir -Recurse -Force -ErrorAction Stop
  Add-Line "- Stage/extract temp removed: True"
} catch {
  Add-Line "- Temp cleanup warning: $($_.Exception.Message)"
}

Write-Host "`n=== STEP 9 / WRITE RESULT DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 9 - Write result documents"

@"
# Tiny Real Encrypted Shard Test Result

## Status

PASSED.

## Archive

$ArchivePath

## Archive metadata

- Archive MB: $ArchiveMB
- Archive SHA256: $ArchiveSHA256
- Files inside test shard: $($HashRows.Count)
- Source MB: $StageMB

## Verification

- 7z archive creation exit code: $ArchiveExit
- 7z list exit code: $ListExit
- 7z extract exit code: $ExtractExit
- Missing extracted files: $MissingExtracted
- Hash mismatches: $Mismatch

## Local manifests

- Hash manifest:
  $HashManifest

- Verify CSV:
  $VerifyCsv

- Restore manifest:
  $RestoreManifest

## Safety

No full raw archive was created.
Only tiny candidate files were archived.
Original files were not deleted.
Password was not written to GitHub.
Temporary staging/extract folders were removed after verification.

## Important

This proves the encryption/extract/hash workflow works on a tiny real shard.
It does not yet prove the full archive layer is complete.
"@ | Set-Content -LiteralPath $ResultDoc -Encoding UTF8

@"
# Tiny Real Shard Restore Manifest

## Archive

$ArchivePath

## Archive SHA256

$ArchiveSHA256

## Archive size MB

$ArchiveMB

## Hash manifest

$HashManifest

## Verify manifest

$VerifyCsv

## Restore steps

1. Confirm 7-Zip is installed.
2. Copy archive to restore machine:
   $ArchivePath
3. Extract with 7-Zip using Igor's private password.
4. Compare extracted file hashes with:
   $VerifyCsv
5. Do not delete originals until full restore test passes.

## File map

$($HashRows | Select-Object Index,SourcePath,StageRelativePath,MB,SourceSHA256 | Format-Table -AutoSize | Out-String -Width 2400)
"@ | Set-Content -LiteralPath $RestoreManifest -Encoding UTF8

@"
# Encrypted Archive Execution Gate

## Current gate status

- 7-Zip usable: True
- Sample encrypted archive test: PASSED
- Split plan created: True
- Missing-source dry-run: DONE
- Tiny real shard candidate plan: DONE
- Tiny real encrypted shard test: PASSED
- Full raw archive created: False
- Restore test on full archive: False

## Tiny real shard result

- Archive: $ArchivePath
- Archive SHA256: $ArchiveSHA256
- Files: $($HashRows.Count)
- MB: $ArchiveMB
- Verify result: PASSED

## Still blocking full archive

- Missing checkable rows from preflight still need review.
- Redacted/uncheckable/private rows still need private handling.
- Full archive destination/password policy must be confirmed.
- Shard-by-shard full archive script must be reviewed before execution.

## Allowed next

- missing-source review plan
- full shard execution DRY-RUN
- small first real shard archive only after review

## Not allowed yet

- deleting originals
- marking archive layer complete
- enabling scheduled sync
"@ | Set-Content -LiteralPath $GateDoc -Encoding UTF8

@"
# Tiny Real Encrypted Shard Test Checkpoint

## Status

Tiny Real Encrypted Shard Test completed.

## What was done

- Loaded latest tiny shard candidate CSV.
- Asked for password locally in PowerShell.
- Staged tiny real files.
- Created encrypted 7z archive.
- Listed archive.
- Extracted archive.
- Verified SHA256 original vs extracted.
- Removed temp staging/extract folders.
- Wrote restore manifest.

## What was not done

- no full raw archive
- no Git LFS enabled
- no scheduled sync
- no delete of originals
- no full restore test

## Next phase

Missing-source review plan + full shard execution dry-run.
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
- Encrypted archive missing-source preflight completed.
- Tiny real shard candidate plan created.
- Tiny real encrypted shard test PASSED.

## Current latest phase

Tiny Real Encrypted Shard Test completed.

## Not done yet

- Raw AI chats are not fully archived.
- Git LFS is not enabled.
- Full encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Full restore test is not done.
- Missing/uncheckable rows still need review.

## Next

Missing-source review plan + full shard execution dry-run.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 10 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 10 - Commit and push"

$FilesToAdd=@(
  "tools\Run-TinyRealEncryptedShardTest.ps1",
  "03_AI_CHATS\TINY_REAL_ENCRYPTED_SHARD_TEST_RESULT.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md",
  "03_AI_CHATS\TINY_REAL_ENCRYPTED_SHARD_TEST_CHECKPOINT.md",
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
  git -C $Repo commit -m "Add tiny real encrypted shard test result" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "ARCHIVE: $ArchivePath" -ForegroundColor Green
Write-Host "HASH MANIFEST: $HashManifest" -ForegroundColor Green
Write-Host "RESTORE MANIFEST: $RestoreManifest" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
