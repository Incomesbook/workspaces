$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Project="J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P02_TradingView_Claude"

$OldTarget="J:\Setup_VcCode_Workspace\S20_Projects\G01_P02_TradingView_Claude_CleanSource"
$Target="J:\Setup_VcCode_Workspace\S20_Projects\G01_P02_TVClaude_CleanSource"

$Capsule="$Repo\06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE"
$Workspace="$Repo\01_WORKSPACES\Igor_Master_Workspace.code-workspace"
$BackupDir="$AuditRoot\WORKSPACE_BACKUPS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule,$BackupDir | Out-Null

$RunReport="$AuditRoot\G01_P02_CLEANSOURCE_FIX_RUN_$Stamp.md"
$CandidateAudit="$AuditRoot\G01_P02_CLEANSOURCE_FIX_AUDIT_$Stamp.md"
$Csv="$AuditRoot\G01_P02_STRICT_CLEANSOURCE_FIX_PLAN_$Stamp.csv"
$PlanReport="$AuditRoot\G01_P02_STRICT_CLEANSOURCE_FIX_PLAN_$Stamp.md"

$PlanResult="$Capsule\G01_P02_STRICT_CLEANSOURCE_FIX_PLAN_RESULT.md"
$CopyResult="$Capsule\G01_P02_CLEANSOURCE_FIX_COPY_RESULT.md"
$ReadinessResult="$Capsule\G01_P02_CLEANSOURCE_FIX_READINESS_RESULT.md"
$WorkspaceResult="$Capsule\G01_P02_MASTER_WORKSPACE_FIX_REGISTRATION_RESULT.md"
$Checkpoint="$Capsule\G01_P02_CLEANSOURCE_FIX_COMPLETION_CHECKPOINT.md"
$PhaseResult="$Capsule\G01_P02_CLEANSOURCE_FIX_PHASE_RESULT.md"
$PlanDoc="$Capsule\G01_P02_CLEANSOURCE_FIX_PLAN.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }
function Add-Audit($Text){ $Text | Add-Content -LiteralPath $CandidateAudit -Encoding UTF8 }
function Add-Plan($Text){ $Text | Add-Content -LiteralPath $PlanReport -Encoding UTF8 }

function Stage-And-Push-Stop($Message){
  @"
# G01 P02 CleanSource Fix Phase Result

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Candidate audit

$CandidateAudit

## Strict plan report

$PlanReport

## Safety

No original project delete.
No raw project push.
No Git init inside G01_P02.
No Git init inside CleanSource.
"@ | Set-Content -LiteralPath $PhaseResult -Encoding UTF8

  git -C $Repo add `
    tools\Run-G01P02-CleanSourcePhase_FIX.ps1 `
    06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_PHASE_RESULT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record G01 P02 clean source fix stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Write-Host "PLAN REPORT: $PlanReport" -ForegroundColor Yellow
  Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
  Get-Content -LiteralPath $RunReport -Tail 160
  exit 0
}

"# G01 P02 CleanSource Fix Run" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: fixed strict plan + safe copy + readiness + workspace registration"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no original project delete"
Add-Line "- no raw project push"
Add-Line "- no git init in original G01_P02"
Add-Line "- no git init in CleanSource"
Add-Line "- runtime/browser/profile/cache/data folders excluded"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"
Add-Line "- Repo: $Repo"
Add-Line "- Project: $Project"
Add-Line "- Old failed target: $OldTarget"
Add-Line "- New fixed target: $Target"
Add-Line "- Workspace: $Workspace"
Add-Line "- Repo exists: $(Test-Path -LiteralPath $Repo)"
Add-Line "- Project exists: $(Test-Path -LiteralPath $Project)"
Add-Line "- Workspace exists: $(Test-Path -LiteralPath $Workspace)"
Add-Line "- Old target exists: $(Test-Path -LiteralPath $OldTarget)"
Add-Line "- New target exists: $(Test-Path -LiteralPath $Target)"

if(-not (Test-Path -LiteralPath $Repo)){ Stage-And-Push-Stop "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $Project)){ Stage-And-Push-Stop "Project not found: $Project" }
if(-not (Test-Path -LiteralPath $Workspace)){ Stage-And-Push-Stop "Workspace file not found: $Workspace" }

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / ARCHIVE FAILED PARTIAL TARGET IF EXISTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Archive failed partial target"

if(Test-Path -LiteralPath $OldTarget){
  $Parent=Split-Path -Parent $OldTarget
  $FailedName="_FAILED_PARTIAL_G01_P02_CleanSource_$Stamp"
  $FailedPath=Join-Path $Parent $FailedName

  try {
    Rename-Item -LiteralPath $OldTarget -NewName $FailedName -ErrorAction Stop
    Add-Line "- Old partial target renamed to: $FailedPath"
  } catch {
    Add-Line "- WARNING: Could not rename old partial target."
    Add-Line "- Error: $($_.Exception.Message)"
    Add-Line "- Continuing with new short target: $Target"
  }
} else {
  Add-Line "- No old partial target found."
}

Write-Host "`n=== STEP 3 / CLEAN-SOURCE CANDIDATE AUDIT ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Clean-source candidate audit"

$BlockSegmentPattern="(?i)(^|\\)[^\\]*(chrome|profile|cache|gpu|indexeddb|local storage|session storage|extension state|network|webstorage|sync data|trusttoken|data|results|logs|tech|api|keys|credential|private|secret|token|access|auth|cookie|memory|chat|runtime|debug|notebooklm|артефакты|paper_scanner|shadow|node_modules|__pycache__|\.venv|\.git)[^\\]*(\\|$)"
$BlockExtPattern="(?i)\.(jsonl|sqlite|db|log|exe|msi|msix|dmg|zip|7z|rar|mp4|mov|avi|webm|mp3|pdf|download|tmp|cache|dat|bin|pma|tflite|pt|wasm|pak|ldb|lock)$"
$SecretPattern="(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|\.env|cookie|session|localstorage|indexeddb)"
$ApprovedPathPattern="(?i)(PROJECT_SKILLS|Project_Skills|GLOBAL_SKILL|WORKFLOW_RULES|AI_SHARED_INSTRUCTIONS|Automation_Scripts|Safe_Scripts|PROJECT_RULES|README)"
$ApprovedExtensions=@(".ps1",".py",".js",".ts",".css",".html",".htm",".md",".txt",".json",".csv",".yaml",".yml",".xml",".svg")

"# G01 P02 CleanSource Fix Candidate Audit" | Set-Content -LiteralPath $CandidateAudit -Encoding UTF8
Add-Audit "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Audit "READ ONLY. No copy. No move original. No delete. No git init. No raw project push."
Add-Audit ""
Add-Audit "## Project"
Add-Audit "- Path: $Project"
Add-Audit "- Exists: $(Test-Path -LiteralPath $Project)"
Add-Audit "- Is Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))"

$AllFiles=Get-ChildItem -LiteralPath $Project -File -Recurse -Force -ErrorAction SilentlyContinue

$Rows=$AllFiles | ForEach-Object {
  $rel=$_.FullName.Substring($Project.Length).TrimStart("\")
  $blockedPath=($_.FullName -match $BlockSegmentPattern)
  $blockedExt=($_.Extension -match $BlockExtPattern)
  $secretLike=($rel -match $SecretPattern)
  $approvedPath=($rel -match $ApprovedPathPattern)
  $extOk=$ApprovedExtensions -contains $_.Extension.ToLowerInvariant()
  $tooLarge=$_.Length -gt 10MB

  $category="REVIEW"
  if($blockedPath -or $blockedExt -or $secretLike -or $tooLarge){
    $category="EXCLUDE_OR_ARCHIVE"
  } elseif($approvedPath -and $extOk){
    $category="STRICT_APPROVED_CANDIDATE"
  } elseif($extOk){
    $category="POSSIBLE_CLEAN_SOURCE_REVIEW"
  }

  [pscustomobject]@{
    Category=$category
    RelativePath=$rel
    Extension=$_.Extension
    MB=[math]::Round($_.Length/1MB,4)
    LastWriteTime=$_.LastWriteTime
    BlockedPath=$blockedPath
    BlockedExt=$blockedExt
    SecretLike=$secretLike
    ApprovedPath=$approvedPath
  }
}

Add-Audit "`n## Summary"
$Rows |
  Group-Object Category |
  ForEach-Object {
    [pscustomobject]@{
      Category=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object Category |
  Format-Table -AutoSize |
  Out-String -Width 1200 |
  Add-Content -LiteralPath $CandidateAudit -Encoding UTF8

Add-Audit "`n## Strict approved candidates"
$Rows |
  Where-Object {$_.Category -eq "STRICT_APPROVED_CANDIDATE"} |
  Sort-Object RelativePath |
  Select-Object RelativePath,Extension,MB,LastWriteTime |
  Format-Table -AutoSize |
  Out-String -Width 2200 |
  Add-Content -LiteralPath $CandidateAudit -Encoding UTF8

Add-Audit "`n## Exclude/archive top 100 largest"
$Rows |
  Where-Object {$_.Category -eq "EXCLUDE_OR_ARCHIVE"} |
  Sort-Object MB -Descending |
  Select-Object -First 100 RelativePath,Extension,MB,BlockedPath,BlockedExt,SecretLike,LastWriteTime |
  Format-Table -AutoSize |
  Out-String -Width 2400 |
  Add-Content -LiteralPath $CandidateAudit -Encoding UTF8

$StrictCount=($Rows | Where-Object {$_.Category -eq "STRICT_APPROVED_CANDIDATE"}).Count
$ExcludeCount=($Rows | Where-Object {$_.Category -eq "EXCLUDE_OR_ARCHIVE"}).Count
$ReviewCount=($Rows | Where-Object {$_.Category -like "*REVIEW*"}).Count

Add-Line "- Candidate audit: $CandidateAudit"
Add-Line "- Total files audited: $($Rows.Count)"
Add-Line "- STRICT_APPROVED_CANDIDATE: $StrictCount"
Add-Line "- EXCLUDE_OR_ARCHIVE: $ExcludeCount"
Add-Line "- REVIEW-like: $ReviewCount"

Write-Host "`n=== STEP 4 / STRICT CSV PLAN ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Strict CSV plan"

$StrictRows=New-Object System.Collections.Generic.List[object]

foreach($f in $AllFiles){
  $rel=$f.FullName.Substring($Project.Length).TrimStart("\")
  $extLower=$f.Extension.ToLowerInvariant()

  $blockedPath=$f.FullName -match $BlockSegmentPattern
  $blockedExt=$f.Extension -match $BlockExtPattern
  $secretLike=$rel -match $SecretPattern
  $approvedPath=$rel -match $ApprovedPathPattern
  $extOk=$ApprovedExtensions -contains $extLower
  $tooLarge=$f.Length -gt 10MB

  $approved=($approvedPath -and $extOk -and -not $blockedPath -and -not $blockedExt -and -not $secretLike -and -not $tooLarge)

  $reason=@()
  if(-not $approvedPath){$reason+="PATH_NOT_STRICT_APPROVED"}
  if(-not $extOk){$reason+="EXT_NOT_APPROVED"}
  if($blockedPath){$reason+="BLOCKED_PATH"}
  if($blockedExt){$reason+="BLOCKED_EXT"}
  if($secretLike){$reason+="SECRET_LIKE"}
  if($tooLarge){$reason+="OVER_10MB"}

  $targetPath=Join-Path $Target $rel

  $StrictRows.Add([pscustomobject]@{
    Approved=$approved
    RelativePath=$rel
    SourcePath=$f.FullName
    TargetPath=$targetPath
    Extension=$f.Extension
    MB=[math]::Round($f.Length/1MB,4)
    LastWriteTime=$f.LastWriteTime
    Reason=($reason -join ";")
  }) | Out-Null
}

$ApprovedRows=$StrictRows | Where-Object {$_.Approved}
$RejectedRows=$StrictRows | Where-Object {-not $_.Approved}

$ApprovedRows | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8

$ApprovedCount=$ApprovedRows.Count
$ApprovedMB=[math]::Round((($ApprovedRows | Measure-Object MB -Sum).Sum),4)
$CollisionCount=($ApprovedRows | Group-Object TargetPath | Where-Object {$_.Count -gt 1}).Count
$MissingSourceCount=($ApprovedRows | Where-Object {-not (Test-Path -LiteralPath $_.SourcePath)}).Count
$Over10Count=($ApprovedRows | Where-Object {[double]$_.MB -gt 10}).Count

"# G01 P02 Strict CleanSource Fix Plan" | Set-Content -LiteralPath $PlanReport -Encoding UTF8
Add-Plan "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Plan "READ ONLY. No files copied in planning step. No delete. No git init. No raw project push."
Add-Plan ""
Add-Plan "## Output files"
Add-Plan "- CSV: $Csv"
Add-Plan ""
Add-Plan "## Summary"
Add-Plan "- Source: $Project"
Add-Plan "- Future target: $Target"
Add-Plan "- Approved files: $ApprovedCount"
Add-Plan "- Approved MB: $ApprovedMB"
Add-Plan "- Rejected files: $($RejectedRows.Count)"
Add-Plan "- Target collisions: $CollisionCount"
Add-Plan "- Missing approved sources: $MissingSourceCount"
Add-Plan "- Approved files over 10 MB: $Over10Count"

Add-Plan "`n## Approved files"
$ApprovedRows |
  Sort-Object RelativePath |
  Select-Object RelativePath,Extension,MB,LastWriteTime |
  Format-Table -AutoSize |
  Out-String -Width 2200 |
  Add-Content -LiteralPath $PlanReport -Encoding UTF8

Add-Plan "`n## Rejected reason summary"
$RejectedRows |
  Group-Object Reason |
  Sort-Object Count -Descending |
  Select-Object Count,Name |
  Format-Table -AutoSize |
  Out-String -Width 2200 |
  Add-Content -LiteralPath $PlanReport -Encoding UTF8

Add-Line "- Strict CSV: $Csv"
Add-Line "- Strict plan report: $PlanReport"
Add-Line "- Approved files: $ApprovedCount"
Add-Line "- Approved MB: $ApprovedMB"
Add-Line "- Collisions: $CollisionCount"
Add-Line "- Missing approved sources: $MissingSourceCount"
Add-Line "- Approved files over 10 MB: $Over10Count"

@"
# G01 P02 CleanSource Fix Plan

## Project

G01_P02_TradingView_Claude

## Local path

$Project

## Fixed target

$Target

## Why fix was needed

Previous script was too permissive and allowed runtime/browser extension path because it matched src/source/code-like folders. This fix excludes all runtime/data/browser/profile/cache/extension/private/memory/chat folders before copy.

## Latest fixed audit

$CandidateAudit

## Latest strict CSV

$Csv

## Latest strict plan report

$PlanReport

## Result

- Approved files: $ApprovedCount
- Approved MB: $ApprovedMB
- Target collisions: $CollisionCount
- Missing approved sources: $MissingSourceCount
- Approved files over 10 MB: $Over10Count
"@ | Set-Content -LiteralPath $PlanDoc -Encoding UTF8

@"
# G01 P02 Strict CleanSource Fix Plan Result

## Result

- Approved files: $ApprovedCount
- Approved MB: $ApprovedMB
- Target collisions: $CollisionCount
- Missing approved sources: $MissingSourceCount
- Approved files over 10 MB: $Over10Count

## CSV

$Csv

## Plan report

$PlanReport

## Approved files

$($ApprovedRows | Select-Object RelativePath,Extension,MB | Format-Table -AutoSize | Out-String -Width 2200)
"@ | Set-Content -LiteralPath $PlanResult -Encoding UTF8

if($ApprovedCount -lt 1){ Stage-And-Push-Stop "Approved file count is 0. Need manual review of G01_P02 strict roots." }
if($ApprovedCount -gt 40){ Stage-And-Push-Stop "Approved file count is too high: $ApprovedCount. Stopped before copy." }
if($ApprovedMB -gt 5){ Stage-And-Push-Stop "Approved MB too high: $ApprovedMB. Stopped before copy." }
if($CollisionCount -gt 0){ Stage-And-Push-Stop "Target collisions found: $CollisionCount." }
if($MissingSourceCount -gt 0){ Stage-And-Push-Stop "Missing approved sources found: $MissingSourceCount." }
if($Over10Count -gt 0){ Stage-And-Push-Stop "Approved files over 10 MB found: $Over10Count." }

Write-Host "`n=== STEP 5 / COPY APPROVED FILES ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Copy approved files"

$Missing=@()
$BadTarget=@()
$ExistingDifferent=@()
$ExistingSame=@()
$Copied=@()
$WouldCopy=@()

foreach($r in $ApprovedRows){
  if(-not (Test-Path -LiteralPath $r.SourcePath)){
    $Missing += $r
    continue
  }

  if($r.TargetPath -notlike "$Target*"){
    $BadTarget += $r
    continue
  }

  $src=Get-Item -LiteralPath $r.SourcePath

  if(Test-Path -LiteralPath $r.TargetPath){
    $dst=Get-Item -LiteralPath $r.TargetPath
    if($dst.Length -eq $src.Length){
      $ExistingSame += $r
    } else {
      $ExistingDifferent += [pscustomobject]@{
        RelativePath=$r.RelativePath
        SourceMB=[math]::Round($src.Length/1MB,4)
        TargetMB=[math]::Round($dst.Length/1MB,4)
        TargetPath=$r.TargetPath
      }
    }
  } else {
    $WouldCopy += $r
  }
}

Add-Line "- Would copy: $($WouldCopy.Count)"
Add-Line "- Missing sources: $($Missing.Count)"
Add-Line "- Bad target paths: $($BadTarget.Count)"
Add-Line "- Existing same-size: $($ExistingSame.Count)"
Add-Line "- Existing different-size: $($ExistingDifferent.Count)"

if($Missing.Count -gt 0){ Stage-And-Push-Stop "Missing sources before copy." }
if($BadTarget.Count -gt 0){ Stage-And-Push-Stop "Bad target paths before copy." }
if($ExistingDifferent.Count -gt 0){ Stage-And-Push-Stop "Existing different-size target files before copy." }

foreach($r in $WouldCopy){
  $dir=Split-Path -Parent $r.TargetPath
  New-Item -ItemType Directory -Force $dir | Out-Null
  Copy-Item -LiteralPath $r.SourcePath -Destination $r.TargetPath -Force
  $Copied += $r
}

Add-Line "- Copied files: $($Copied.Count)"
Add-Line "- Target exists after copy: $(Test-Path -LiteralPath $Target)"

@"
# G01 P02 CleanSource Fix Copy Result

## Target

$Target

## Result

- Copied files: $($Copied.Count)
- Existing same-size skipped: $($ExistingSame.Count)
- Missing sources: $($Missing.Count)
- Bad target paths: $($BadTarget.Count)
- Existing different-size files: $($ExistingDifferent.Count)

## Files copied or already present

$($ApprovedRows | Select-Object RelativePath,Extension,MB,SourcePath,TargetPath | Format-Table -AutoSize | Out-String -Width 2400)

## Safety

Copied only strict approved clean-source files.
No browser/runtime/profile/cache/private/chat/raw files were copied.
"@ | Set-Content -LiteralPath $CopyResult -Encoding UTF8

Write-Host "`n=== STEP 6 / READINESS AUDIT ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Readiness audit"

$TargetFiles=Get-ChildItem -LiteralPath $Target -File -Recurse -Force -ErrorAction SilentlyContinue
$TargetMB=[math]::Round((($TargetFiles | Measure-Object Length -Sum).Sum / 1MB),4)
$Large=$TargetFiles | Where-Object {$_.Length -gt 50MB}
$Blocked=$TargetFiles | Where-Object { $_.FullName -match $BlockSegmentPattern -or $_.Extension -match $BlockExtPattern }
$SecretLike=$TargetFiles | Where-Object { $_.FullName -match $SecretPattern }

$Ready="False"
if($TargetFiles.Count -eq $ApprovedCount -and $Large.Count -eq 0 -and $Blocked.Count -eq 0 -and $SecretLike.Count -eq 0){
  $Ready="True"
}

Add-Line "- Target files: $($TargetFiles.Count)"
Add-Line "- Target MB: $TargetMB"
Add-Line "- Large >50MB: $($Large.Count)"
Add-Line "- Blocked hits: $($Blocked.Count)"
Add-Line "- Secret-like hits: $($SecretLike.Count)"
Add-Line "- Ready: $Ready"

if($Ready -ne "True"){
  Stage-And-Push-Stop "Readiness audit failed. Target is not safe as expected."
}

@"
# G01 P02 CleanSource Fix Readiness Result

## Target

$Target

## Result

- Target exists: $(Test-Path -LiteralPath $Target)
- Is Git repo: $(Test-Path -LiteralPath (Join-Path $Target '.git'))
- Files: $($TargetFiles.Count)
- Total MB: $TargetMB
- Files over 50 MB: $($Large.Count)
- Blocked hits: $($Blocked.Count)
- Secret-like hits: $($SecretLike.Count)
- Ready: $Ready

## Files

$($TargetFiles | Select-Object FullName,@{Name='MB';Expression={[math]::Round($_.Length/1MB,4)}},LastWriteTime | Sort-Object FullName | Format-Table -AutoSize | Out-String -Width 2400)
"@ | Set-Content -LiteralPath $ReadinessResult -Encoding UTF8

Write-Host "`n=== STEP 7 / REGISTER IN MASTER WORKSPACE ===" -ForegroundColor Cyan
Add-Line "`n## Step 7 - Register in master workspace"

$Backup="$BackupDir\Igor_Master_Workspace_before_G01_P02_FIX_$Stamp.code-workspace"
Copy-Item -LiteralPath $Workspace -Destination $Backup -Force

$json=Get-Content -LiteralPath $Workspace -Raw | ConvertFrom-Json

if(-not $json.folders){
  $json | Add-Member -MemberType NoteProperty -Name folders -Value @()
}

$already=$false
foreach($f in $json.folders){
  if($f.path -eq $Target -or $f.name -eq "G01_P02_TVClaude_CleanSource"){
    $already=$true
  }
}

if(-not $already){
  $newFolder=[pscustomobject]@{
    name="G01_P02_TVClaude_CleanSource"
    path=$Target
  }
  $json.folders=@($json.folders)+$newFolder
  $json | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Workspace -Encoding UTF8
}

Add-Line "- Workspace backup: $Backup"
Add-Line "- Already registered before run: $already"

@"
# G01 P02 Master Workspace Fix Registration Result

## Target

$Target

## Workspace

$Workspace

## Result

- Target exists: $(Test-Path -LiteralPath $Target)
- Target is Git repo: $(Test-Path -LiteralPath (Join-Path $Target '.git'))
- Workspace exists: $(Test-Path -LiteralPath $Workspace)
- Backup created: $Backup
- Already registered before this run: $already
"@ | Set-Content -LiteralPath $WorkspaceResult -Encoding UTF8

Write-Host "`n=== STEP 8 / COMPLETION CHECKPOINT ===" -ForegroundColor Cyan
Add-Line "`n## Step 8 - Completion checkpoint"

@"
# G01 P02 CleanSource Fix Completion Checkpoint

## Project

G01_P02_TradingView_Claude

## Original path

$Project

## Fixed CleanSource path

$Target

## Current confirmed state

G01_P02 original:
- exists
- not converted to Git repo
- raw project not pushed
- protected browser/cache/runtime/private/chat areas remain outside normal Git

G01_P02 fixed CleanSource:
- exists
- not a Git repo
- contains $($TargetFiles.Count) strict approved clean-source files
- total size around $TargetMB MB
- no files over 50 MB
- no blocked path/ext hits
- no secret-like hits
- registered in Igor_Master_Workspace

## Why previous attempt failed

Previous copy attempt incorrectly allowed a runtime Chrome extension source path under Runtime_Data / ChromeDebugProfile / Extensions / src. This fix excludes those paths.

## Done

- old failed partial target handled if present
- strict fixed clean-source audit
- strict fixed CSV plan
- controlled copy
- readiness audit
- workspace registration

## Not done yet

- no separate Git repo for CleanSource
- no GitHub repo for CleanSource
- no Git LFS/archive/encrypted backup decision
- no restore test
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

@"
# Current Status Map

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Done

- Main repo Incomesbook/workspaces is active.
- G01_P03 is closed.
- G01_P01 is closed.
- G01_P02 capsule / manifest phase completed.
- G01_P02 CleanSource fix phase completed.
- G01_P02 fixed CleanSource is copied and registered in master workspace.

## Current latest phase

G01_P02 CleanSource fixed phase completed.

## Next

- Global AI chat export confirmation
- Git LFS / archive / encrypted backup strategy
- weekly/biweekly sync
- restore test
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

@"
# G01 P02 CleanSource Fix Phase Result

## Final result

- Approved files copied/confirmed: $ApprovedCount
- CleanSource files: $($TargetFiles.Count)
- CleanSource MB: $TargetMB
- Ready: $Ready
- Master workspace registered: True
- Original G01_P02 destructive changes: No
- Git init in G01_P02: No
- Git init in CleanSource: No
- Raw project pushed: No

## Local run report

$RunReport

## Candidate audit

$CandidateAudit

## Strict plan report

$PlanReport
"@ | Set-Content -LiteralPath $PhaseResult -Encoding UTF8

Write-Host "`n=== STEP 9 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 9 - Commit and push"

$FilesToAdd=@(
  "tools\Run-G01P02-CleanSourcePhase_FIX.ps1",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_PLAN.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_STRICT_CLEANSOURCE_FIX_PLAN_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_COPY_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_READINESS_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_MASTER_WORKSPACE_FIX_REGISTRATION_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_COMPLETION_CHECKPOINT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE\G01_P02_CLEANSOURCE_FIX_PHASE_RESULT.md",
  "01_WORKSPACES\Igor_Master_Workspace.code-workspace",
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
  Stage-And-Push-Stop "Large staged files found. Commit/push aborted."
}

if($Staged.Count -gt 0){
  git -C $Repo commit -m "Complete G01 P02 clean source fix phase" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "CANDIDATE AUDIT: $CandidateAudit" -ForegroundColor Green
Write-Host "PLAN REPORT: $PlanReport" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
