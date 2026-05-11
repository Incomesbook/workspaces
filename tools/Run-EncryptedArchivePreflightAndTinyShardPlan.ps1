$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$ArchiveRoot="J:\Setup_VcCode_Workspace\S30_Large_Local_Archive"
$EncryptedRoot="$ArchiveRoot\ENCRYPTED_AI_CHAT_ARCHIVE"
$RestoreRoot="J:\Setup_VcCode_Workspace\S40_Restore_Manifests"
$PreflightRoot="$RestoreRoot\ENCRYPTED_ARCHIVE_PREFLIGHT_$Stamp"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule,$ArchiveRoot,$EncryptedRoot,$RestoreRoot,$PreflightRoot | Out-Null

$RunReport="$AuditRoot\ENCRYPTED_ARCHIVE_PREFLIGHT_TINY_SHARD_RUN_$Stamp.md"
$PreflightCsv="$AuditRoot\ENCRYPTED_ARCHIVE_PREFLIGHT_MISSING_SOURCE_$Stamp.csv"
$TinyShardCsv="$AuditRoot\ENCRYPTED_ARCHIVE_TINY_REAL_SHARD_CANDIDATES_$Stamp.csv"

$SecurityPolicyDoc="$Capsule\ENCRYPTED_ARCHIVE_SECURITY_POLICY.md"
$PreflightDoc="$Capsule\ENCRYPTED_ARCHIVE_PREFLIGHT_MISSING_SOURCE_RESULT.md"
$TinyShardPlanDoc="$Capsule\ENCRYPTED_ARCHIVE_TINY_REAL_SHARD_PLAN.md"
$ExecutionGateDoc="$Capsule\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md"
$Checkpoint="$Capsule\ENCRYPTED_ARCHIVE_PREFLIGHT_TINY_SHARD_CHECKPOINT.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# Encrypted Archive Preflight Tiny Shard Checkpoint

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
    tools\Run-EncryptedArchivePreflightAndTinyShardPlan.ps1 `
    03_AI_CHATS\ENCRYPTED_ARCHIVE_PREFLIGHT_TINY_SHARD_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record encrypted archive preflight stop point" | Out-Null
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

"# Encrypted Archive Preflight + Tiny Real Shard Plan" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: preflight + tiny real shard plan only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no full raw archive"
Add-Line "- no Git LFS enable"
Add-Line "- no scheduled sync"
Add-Line "- no delete"
Add-Line "- no real password stored"
Add-Line "- fix ignored password-policy doc by creating security-policy doc"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $AuditRoot)){ Stop-Safely "AuditRoot not found: $AuditRoot" }

$LatestSplit=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ENCRYPTED_ARCHIVE_SPLIT_PLAN_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

$LatestEncrypted=Get-ChildItem -LiteralPath $AuditRoot -File -Filter "ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $LatestSplit){ Stop-Safely "Latest ENCRYPTED_ARCHIVE_SPLIT_PLAN_*.csv not found." }
if(-not $LatestEncrypted){ Stop-Safely "Latest ARCHIVE_DRYRUN_ENCRYPTED_CANDIDATES_*.csv not found." }

Add-Line "- Repo: $Repo"
Add-Line "- Latest split plan: $($LatestSplit.FullName)"
Add-Line "- Latest encrypted candidates: $($LatestEncrypted.FullName)"
Add-Line "- PreflightRoot: $PreflightRoot"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / 7Z CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - 7z check"

$SevenZipPath=Find-7Zip
if(-not $SevenZipPath){
  Stop-Safely "7z.exe not found. Reopen PowerShell or check C:\Program Files\7-Zip."
}

$SevenZipDir=Split-Path -Parent $SevenZipPath
if($env:Path -notlike "*$SevenZipDir*"){
  $env:Path="$env:Path;$SevenZipDir"
}

Add-Line "- 7z path: $SevenZipPath"

Write-Host "`n=== STEP 3 / FIX IGNORED PASSWORD POLICY DOC ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Fix ignored password policy doc"

$IgnoredPasswordDoc="$Capsule\ENCRYPTED_ARCHIVE_PASSWORD_POLICY.md"
if(Test-Path -LiteralPath $IgnoredPasswordDoc){
  $ArchiveIgnored=Join-Path $AuditRoot "IGNORED_ENCRYPTED_ARCHIVE_PASSWORD_POLICY_$Stamp.md"
  Copy-Item -LiteralPath $IgnoredPasswordDoc -Destination $ArchiveIgnored -Force
  Remove-Item -LiteralPath $IgnoredPasswordDoc -Force
  Add-Line "- Ignored password-policy doc archived then removed from repo folder: $ArchiveIgnored"
} else {
  Add-Line "- Ignored password-policy doc not present."
}

@"
# Encrypted Archive Security Policy

## Critical rule

Never paste real archive passwords into ChatGPT.
Never save archive passwords in GitHub.
Never commit passwords in scripts, .env files, markdown files, CSV files, or restore manifests.

## Real archive password handling

For real archive execution:
- the script must ask locally with `Read-Host -AsSecureString`
- the password must not be written to disk
- the password must not be printed to console
- the password must not be committed to GitHub
- the password must be stored only by Igor in a private/offline password manager

## Command-line limitation

7-Zip command-line needs a password passed to the process.
That can be visible locally to process inspection tools while the command runs.

For the most sensitive archive layer, consider later:
- VeraCrypt container
- Cryptomator vault
- rclone crypt remote
- offline encrypted drive backup

## Current rule

Do not run full archive yet.

Allowed next:
- missing-source dry-run
- tiny real shard archive test with local password prompt
- verify extract and hash on tiny sample

Not allowed yet:
- full raw archive
- scheduled sync
- deleting originals
"@ | Set-Content -LiteralPath $SecurityPolicyDoc -Encoding UTF8

Write-Host "`n=== STEP 4 / PREFLIGHT MISSING SOURCE DRY-RUN ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Preflight missing-source dry-run"

$SplitRows=Import-Csv -LiteralPath $LatestSplit.FullName
$Preflight=New-Object System.Collections.Generic.List[object]

foreach($r in $SplitRows){
  $root="$($r.Root)"
  $folder="$($r.RelativeFolder)"
  $file="$($r.FileName)"

  $redacted=($file -match "REDACTED")
  $candidatePath=$null
  $exists=$false
  $checkable=$false

  if(-not $redacted -and $root -and $file){
    if($folder){
      $candidatePath=Join-Path (Join-Path $root $folder) $file
    } else {
      $candidatePath=Join-Path $root $file
    }

    $checkable=$true
    $exists=Test-Path -LiteralPath $candidatePath
  }

  $Preflight.Add([pscustomobject]@{
    Shard=$r.Shard
    Root=$r.Root
    RelativeFolder=$r.RelativeFolder
    FileName=$r.FileName
    MB=$r.MB
    RestoreRole=$r.RestoreRole
    StorageLayer=$r.StorageLayer
    Priority=$r.Priority
    Checkable=$checkable
    Redacted=$redacted
    Exists=$exists
    CandidatePath=$candidatePath
    FutureArchivePath=$r.FutureArchivePath
  }) | Out-Null
}

$Preflight | Export-Csv -LiteralPath $PreflightCsv -NoTypeInformation -Encoding UTF8

$Total=$Preflight.Count
$Checkable=($Preflight | Where-Object {$_.Checkable -eq $true}).Count
$Redacted=($Preflight | Where-Object {$_.Redacted -eq $true}).Count
$ExistsCount=($Preflight | Where-Object {$_.Exists -eq $true}).Count
$MissingCount=($Preflight | Where-Object {$_.Checkable -eq $true -and $_.Exists -ne $true}).Count
$UncheckableCount=($Preflight | Where-Object {$_.Checkable -ne $true}).Count

Add-Line "- Total rows: $Total"
Add-Line "- Checkable rows: $Checkable"
Add-Line "- Redacted/uncheckable rows: $Redacted"
Add-Line "- Exists: $ExistsCount"
Add-Line "- Missing checkable: $MissingCount"
Add-Line "- Uncheckable: $UncheckableCount"
Add-Line "- Preflight CSV: $PreflightCsv"

Write-Host "`n=== STEP 5 / BUILD TINY REAL SHARD CANDIDATE PLAN ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Build tiny real shard candidate plan"

$TinyCandidates=$Preflight |
  Where-Object {
    $_.Exists -eq $true -and
    $_.Redacted -ne $true -and
    [double]$_.MB -gt 0 -and
    [double]$_.MB -le 2 -and
    $_.StorageLayer -notmatch "PRIVATE" -and
    $_.RestoreRole -ne "PRIVATE_SECRET_REVIEW"
  } |
  Sort-Object {[double]$_.MB} |
  Select-Object -First 10

$TinyCandidates | Export-Csv -LiteralPath $TinyShardCsv -NoTypeInformation -Encoding UTF8

$TinyCount=$TinyCandidates.Count
$TinyMB=[math]::Round((($TinyCandidates | Measure-Object MB -Sum).Sum),4)

Add-Line "- Tiny real shard candidate count: $TinyCount"
Add-Line "- Tiny real shard candidate MB: $TinyMB"
Add-Line "- Tiny shard CSV: $TinyShardCsv"

if($TinyCount -lt 1){
  Add-Line "- No safe tiny real shard candidates found. Real shard test must wait."
}

Write-Host "`n=== STEP 6 / WRITE DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Write documents"

@"
# Encrypted Archive Preflight Missing Source Result

## Source split plan

$($LatestSplit.FullName)

## Output CSV

$PreflightCsv

## Result

- Total rows: $Total
- Checkable rows: $Checkable
- Redacted/uncheckable rows: $Redacted
- Existing checkable rows: $ExistsCount
- Missing checkable rows: $MissingCount
- Uncheckable rows: $UncheckableCount

## Meaning

Checkable rows can be reconstructed from:
Root + RelativeFolder + FileName.

Uncheckable rows are usually redacted/private/secret-like references.
They require separate private handling and should not be blindly archived from public/normal manifests.

## Decision

No full archive yet.
Missing-source dry-run completed.
"@ | Set-Content -LiteralPath $PreflightDoc -Encoding UTF8

@"
# Encrypted Archive Tiny Real Shard Plan

## Purpose

Prepare for one small real archive test before full raw archive execution.

## Candidate CSV

$TinyShardCsv

## Result

- Candidate files: $TinyCount
- Candidate MB: $TinyMB

## Candidate preview

$($TinyCandidates | Select-Object CandidatePath,MB,RestoreRole,StorageLayer,Priority | Format-Table -AutoSize | Out-String -Width 2200)

## Safety

This phase did not create the real tiny shard archive.

Next phase may create one tiny encrypted archive only after:
- local password prompt
- no password written to disk
- archive created in S30
- archive extracted to temp folder
- SHA256 verified
- result written to manifest

## Not allowed yet

- full archive
- deleting originals
- scheduled sync
"@ | Set-Content -LiteralPath $TinyShardPlanDoc -Encoding UTF8

@"
# Encrypted Archive Execution Gate

## Current gate status

- 7-Zip usable: True
- Sample encrypted archive test: PASSED
- Split plan created: True
- Missing-source dry-run: DONE
- Tiny real shard candidate plan: DONE
- Full raw archive created: False
- Restore test on full archive: False

## Preflight result

- Total rows: $Total
- Checkable rows: $Checkable
- Existing checkable rows: $ExistsCount
- Missing checkable rows: $MissingCount
- Redacted/uncheckable rows: $UncheckableCount
- Tiny real shard candidates: $TinyCount

## Allowed next

- one tiny real shard archive test with local password prompt
- verify extract/hash
- write restore manifest

## Not allowed yet

- full raw archive execution
- deleting originals
- marking archive layer complete
- enabling scheduled sync

## Required before full real archive

1. Tiny real shard test passed.
2. Archive destination confirmed.
3. Password storage policy confirmed by Igor.
4. Missing-source handling decided.
5. Shard-by-shard execution script reviewed.
6. Restore test completed on at least one real shard.
"@ | Set-Content -LiteralPath $ExecutionGateDoc -Encoding UTF8

@"
# Encrypted Archive Preflight Tiny Shard Checkpoint

## Status

Encrypted archive preflight + tiny real shard plan completed.

## What was done

- Fixed ignored password-policy issue by creating ENCRYPTED_ARCHIVE_SECURITY_POLICY.md.
- Removed ignored ENCRYPTED_ARCHIVE_PASSWORD_POLICY.md from repo folder if present.
- Ran missing-source preflight on latest split plan.
- Created tiny real shard candidate CSV.
- Updated execution gate.
- Updated current status map.

## What was not done

- no full raw archive
- no tiny real archive yet
- no Git LFS enabled
- no scheduled sync
- no delete of originals

## Next phase

Run one tiny real encrypted shard test with local password prompt.
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

## Current latest phase

Encrypted Archive Preflight + Tiny Shard Plan completed.

## Not done yet

- Raw AI chats are not fully archived.
- Git LFS is not enabled.
- Full encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Full restore test is not done.

## Next

Run one tiny real encrypted shard test with local password prompt.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 7 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 7 - Commit and push"

$FilesToAdd=@(
  "tools\Run-EncryptedArchivePreflightAndTinyShardPlan.ps1",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_SECURITY_POLICY.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_PREFLIGHT_MISSING_SOURCE_RESULT.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_TINY_REAL_SHARD_PLAN.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_EXECUTION_GATE.md",
  "03_AI_CHATS\ENCRYPTED_ARCHIVE_PREFLIGHT_TINY_SHARD_CHECKPOINT.md",
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
  git -C $Repo commit -m "Add encrypted archive preflight and tiny shard plan" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "PREFLIGHT CSV: $PreflightCsv" -ForegroundColor Green
Write-Host "TINY SHARD CSV: $TinyShardCsv" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
