$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Project="J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P01_PocketOption"
$Target="J:\Setup_VcCode_Workspace\S20_Projects\G01_P01_PocketOption_CleanSource"
$Capsule="$Repo\06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION"
$Workspace="$Repo\01_WORKSPACES\Igor_Master_Workspace.code-workspace"
$BackupDir="$AuditRoot\WORKSPACE_BACKUPS"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule,$BackupDir | Out-Null

$RunReport="$AuditRoot\G01_P01_CLEANSOURCE_PHASE_RUN_$Stamp.md"
$ResultFile="$Capsule\G01_P01_CLEANSOURCE_PHASE_RESULT.md"
$PlanResult="$Capsule\G01_P01_STRICT_CLEANSOURCE_PLAN_RESULT.md"
$CopyResult="$Capsule\G01_P01_CLEANSOURCE_COPY_RESULT.md"
$ReadinessResult="$Capsule\G01_P01_CLEANSOURCE_READINESS_RESULT.md"
$WorkspaceResult="$Capsule\G01_P01_MASTER_WORKSPACE_REGISTRATION_RESULT.md"
$Checkpoint="$Capsule\G01_P01_COMPLETION_CHECKPOINT.md"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"

function Add-Line($Text){
  $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8
}

function Fail-Step($Message){
  Add-Line ""
  Add-Line "## FAILED"
  Add-Line $Message
  Write-Host "FAILED: $Message" -ForegroundColor Red
  Write-Host "REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 120
  exit 1
}

"# G01 P01 CleanSource Phase Run" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: controlled multi-step execution"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no delete"
Add-Line "- no move original files"
Add-Line "- no git init in G01_P01"
Add-Line "- no git init in CleanSource"
Add-Line "- no raw project push"
Add-Line "- no Chrome profile push"
Add-Line "- no API/private folders push"
Add-Line "- no AI memory/raw chat push"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"
Add-Line "- Repo: $Repo"
Add-Line "- Project: $Project"
Add-Line "- Target: $Target"
Add-Line "- Workspace: $Workspace"
Add-Line "- Repo exists: $(Test-Path -LiteralPath $Repo)"
Add-Line "- Project exists: $(Test-Path -LiteralPath $Project)"
Add-Line "- Workspace exists: $(Test-Path -LiteralPath $Workspace)"
Add-Line "- Project is Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))"
Add-Line "- Target is Git repo: $(Test-Path -LiteralPath (Join-Path $Target '.git'))"

if(-not (Test-Path -LiteralPath $Repo)){ Fail-Step "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $Project)){ Fail-Step "Project not found: $Project" }
if(-not (Test-Path -LiteralPath $Workspace)){ Fail-Step "Workspace file not found: $Workspace" }

$RepoStatus = git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatus | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / RUN STRICT PLAN GENERATOR ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Run strict plan generator"

$Generator="$Repo\tools\New-G01P01CleanSourcePlan.ps1"
if(-not (Test-Path -LiteralPath $Generator)){
  Fail-Step "Generator not found: $Generator"
}

powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Generator | Tee-Object -Variable GeneratorOutput | Out-Null
$GeneratorOutput | ForEach-Object { Add-Line $_ }

$Csv = Get-ChildItem -LiteralPath $AuditRoot -File -Filter "G01_P01_STRICT_CLEANSOURCE_PLAN_*.csv" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

$PlanReport = Get-ChildItem -LiteralPath $AuditRoot -File -Filter "G01_P01_STRICT_CLEANSOURCE_PLAN_*.md" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if(-not $Csv){ Fail-Step "No strict CSV plan found after generator." }
if(-not $PlanReport){ Fail-Step "No strict plan report found after generator." }

$Rows=Import-Csv -LiteralPath $Csv.FullName
$ApprovedRows=$Rows | Where-Object { $_.Approved -eq "True" -or $_.Approved -eq $true }
$ApprovedCount=$ApprovedRows.Count
$ApprovedMB=[math]::Round((($ApprovedRows | Measure-Object MB -Sum).Sum),4)
$CollisionCount=($ApprovedRows | Group-Object TargetPath | Where-Object {$_.Count -gt 1}).Count
$MissingSourceCount=($ApprovedRows | Where-Object {-not (Test-Path -LiteralPath $_.SourcePath)}).Count
$Over10Count=($ApprovedRows | Where-Object {[double]$_.MB -gt 10}).Count

Add-Line "`nStrict plan summary:"
Add-Line "- CSV: $($Csv.FullName)"
Add-Line "- Plan report: $($PlanReport.FullName)"
Add-Line "- Approved files: $ApprovedCount"
Add-Line "- Approved MB: $ApprovedMB"
Add-Line "- Target collisions: $CollisionCount"
Add-Line "- Missing approved sources: $MissingSourceCount"
Add-Line "- Approved files over 10 MB: $Over10Count"

if($ApprovedCount -lt 1){ Fail-Step "Approved file count is 0. Nothing to copy." }
if($ApprovedCount -gt 50){ Fail-Step "Approved file count too high: $ApprovedCount. Manual review required." }
if($ApprovedMB -gt 10){ Fail-Step "Approved MB too high: $ApprovedMB. Manual review required." }
if($CollisionCount -gt 0){ Fail-Step "Target collisions found: $CollisionCount." }
if($MissingSourceCount -gt 0){ Fail-Step "Missing approved sources found: $MissingSourceCount." }
if($Over10Count -gt 0){ Fail-Step "Approved files over 10 MB found: $Over10Count." }

@"
# G01 P01 Strict CleanSource Plan Result

## Project

G01_P01_PocketOption

## Strict CSV plan

$($Csv.FullName)

## Local report

$($PlanReport.FullName)

## Result

- Approved files: $ApprovedCount
- Approved MB: $ApprovedMB
- Target collisions: $CollisionCount
- Missing approved sources: $MissingSourceCount
- Approved files over 10 MB: $Over10Count

## Approved files

$($ApprovedRows | Select-Object RelativePath,Extension,MB | Format-Table -AutoSize | Out-String -Width 1600)

## Decision

Safe enough for controlled copy execution.

This does not approve Git init.
This does not approve pushing raw G01_P01.
"@ | Set-Content -LiteralPath $PlanResult -Encoding UTF8

Write-Host "`n=== STEP 3 / COPY APPROVED FILES ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Copy approved files"

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

if($Missing.Count -gt 0){ Fail-Step "Missing sources before copy." }
if($BadTarget.Count -gt 0){ Fail-Step "Bad target paths before copy." }
if($ExistingDifferent.Count -gt 0){ Fail-Step "Existing different-size target files before copy." }

foreach($r in $WouldCopy){
  $dir=Split-Path -Parent $r.TargetPath
  New-Item -ItemType Directory -Force $dir | Out-Null
  Copy-Item -LiteralPath $r.SourcePath -Destination $r.TargetPath -Force
  $Copied += $r
}

Add-Line "- Copied files: $($Copied.Count)"
Add-Line "- Target exists after copy: $(Test-Path -LiteralPath $Target)"

@"
# G01 P01 CleanSource Copy Result

## Target

$Target

## Result

- Copied files: $($Copied.Count)
- Existing same-size skipped: $($ExistingSame.Count)
- Missing sources: $($Missing.Count)
- Bad target paths: $($BadTarget.Count)
- Existing different-size files: $($ExistingDifferent.Count)

## Files copied or already present

$($ApprovedRows | Select-Object RelativePath,Extension,MB,SourcePath,TargetPath | Format-Table -AutoSize | Out-String -Width 2000)

## Safety

This copied only strict approved clean-source files.

It did not:
- delete files
- move original files
- initialize Git
- push raw project files
- copy Chrome profile
- copy API/private folders
- copy AI memory
- copy logs/results/data/cache/runtime/browser state
"@ | Set-Content -LiteralPath $CopyResult -Encoding UTF8

Write-Host "`n=== STEP 4 / READINESS AUDIT ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Readiness audit"

$TargetFiles=@()
$Large=@()
$Blocked=@()
$SecretLike=@()
$Ready="False"
$TargetMB=0

if(Test-Path -LiteralPath $Target){
  $TargetFiles=Get-ChildItem -LiteralPath $Target -File -Recurse -Force -ErrorAction SilentlyContinue
  $TargetMB=[math]::Round((($TargetFiles | Measure-Object Length -Sum).Sum / 1MB),4)
  $Large=$TargetFiles | Where-Object {$_.Length -gt 50MB}
  $Blocked=$TargetFiles | Where-Object { $_.FullName -match "(?i)(\.jsonl$|\.sqlite$|\.db$|\.log$|\.exe$|\.msi$|\.msix$|\.dmg$|\.zip$|\.7z$|\.rar$|\.mp4$|\.mp3$|\.pdf$|\.env$|\.dat$|\.bin$|\.pma$|\.tflite$|\.pt$|\.wasm$)" }
  $SecretLike=$TargetFiles | Where-Object { $_.FullName -match "(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|\.env|cookie|session|localstorage|indexeddb)" }

  if($TargetFiles.Count -eq $ApprovedCount -and $Large.Count -eq 0 -and $Blocked.Count -eq 0 -and $SecretLike.Count -eq 0){
    $Ready="True"
  }
}

Add-Line "- Target files: $($TargetFiles.Count)"
Add-Line "- Target MB: $TargetMB"
Add-Line "- Large >50MB: $($Large.Count)"
Add-Line "- Blocked hits: $($Blocked.Count)"
Add-Line "- Secret-like hits: $($SecretLike.Count)"
Add-Line "- Ready: $Ready"

if($Ready -ne "True"){
  Fail-Step "Readiness audit failed. Target is not safe as expected."
}

@"
# G01 P01 CleanSource Readiness Result

## Target

$Target

## Result

- Target exists: $(Test-Path -LiteralPath $Target)
- Is Git repo: $(Test-Path -LiteralPath (Join-Path $Target '.git'))
- Files: $($TargetFiles.Count)
- Total MB: $TargetMB
- Files over 50 MB: $($Large.Count)
- Blocked extension/type hits: $($Blocked.Count)
- Secret-like filename/path hits: $($SecretLike.Count)
- Ready: $Ready

## Files

$($TargetFiles | Select-Object FullName,@{Name='MB';Expression={[math]::Round($_.Length/1MB,4)}},LastWriteTime | Sort-Object FullName | Format-Table -AutoSize | Out-String -Width 2000)

## Decision

CleanSource is safe enough to register in master workspace.

No Git repo was created here.
No raw project files were pushed.
"@ | Set-Content -LiteralPath $ReadinessResult -Encoding UTF8

Write-Host "`n=== STEP 5 / REGISTER IN MASTER WORKSPACE ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Register in master workspace"

$Backup="$BackupDir\Igor_Master_Workspace_before_G01_P01_$Stamp.code-workspace"
Copy-Item -LiteralPath $Workspace -Destination $Backup -Force

$json=Get-Content -LiteralPath $Workspace -Raw | ConvertFrom-Json

if(-not $json.folders){
  $json | Add-Member -MemberType NoteProperty -Name folders -Value @()
}

$already=$false
foreach($f in $json.folders){
  if($f.path -eq $Target -or $f.name -eq "G01_P01_PocketOption_CleanSource"){
    $already=$true
  }
}

if(-not $already){
  $newFolder=[pscustomobject]@{
    name="G01_P01_PocketOption_CleanSource"
    path=$Target
  }
  $json.folders=@($json.folders)+$newFolder
  $json | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $Workspace -Encoding UTF8
}

Add-Line "- Workspace backup: $Backup"
Add-Line "- Already registered before run: $already"

@"
# G01 P01 Master Workspace Registration Result

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

## Decision

G01_P01_PocketOption_CleanSource is registered in the master VS Code workspace.

This step did not:
- initialize Git inside G01_P01
- initialize Git inside CleanSource
- delete files
- move original files
- copy raw AI memory
- copy API/private folders
- copy logs/results/data/installers/large files
"@ | Set-Content -LiteralPath $WorkspaceResult -Encoding UTF8

Write-Host "`n=== STEP 6 / COMPLETION CHECKPOINT ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Completion checkpoint"

@"
# G01 P01 Completion Checkpoint

## Project

G01_P01_PocketOption

## Local original path

J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P01_PocketOption

## CleanSource path

$Target

## Current confirmed state

G01_P01 original project:
- exists
- not a Git repo
- contains Chrome profile/browser/runtime/cache material
- contains AI memory/chat roots
- contains API/private-like folders
- contains large files and legacy folders
- must not be pushed as a whole folder

G01_P01 CleanSource:
- exists
- not a Git repo
- contains $($TargetFiles.Count) strict approved clean-source files
- total size around $TargetMB MB
- no files over 50 MB
- no blocked extension/type hits
- no secret-like path/name hits
- registered in Igor_Master_Workspace.code-workspace

## Done

- read-only audit
- AI Context Capsule
- large/private/chat manifest
- clean-source candidate audit
- clean-source plan
- strict CSV clean-source generator
- controlled copy of strict approved files
- readiness audit
- registration in master VS Code workspace

## Not done yet

- no separate Git repo for G01_P01 CleanSource
- no GitHub repo for G01_P01 CleanSource
- no Git LFS/archive decision for large files
- no encrypted/private backup decision for raw AI chats / browser state
- no restore test for G01_P01 on clean machine

## Decision

G01_P01 is now safely represented in the main control repo by:
- capsule
- manifests
- plans
- tool scripts
- CleanSource reference
- master workspace registration

The original G01_P01 remains protected in J:\ПРОЕКТЫ.
The CleanSource folder is available in VS Code through Igor_Master_Workspace.

## Next priority

Continue to:
G01_P02_TradingView_Claude

Reason:
It is the next major trading/AI project that needs capsule/manifest protection before any Git or sync decision.

## Strict instruction for future AI agents

Before touching G01_P01:
1. Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md.
2. Read G01_ALL_ABOUT_TRADING capsule.
3. Read this G01_P01 capsule.
4. Do not run git init inside original G01_P01.
5. Do not push original G01_P01.
6. Do not delete AI memory, browser profile, Chrome/IndexedDB data, API/private folders, logs, results, or legacy folders.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

@"
# Current Status Map

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Done

- Main repo Incomesbook/workspaces is active.
- Master workspace architecture exists.
- AI chats safe index exists.
- G01_All_About_Trading capsule exists.
- G01_P03 is closed with completion checkpoint.
- G01_P03 CleanSource is copied and registered in master workspace.
- G01_P01 capsule exists.
- G01_P01 large/private/chat manifest exists.
- G01_P01 clean-source plan exists.
- G01_P01 strict plan generator exists.
- G01_P01 CleanSource is copied and registered in master workspace.

## Current latest phase

G01_P01 CleanSource phase completed.

## Next

- G01_P02_TradingView_Claude capsule
- AI chat export confirmation
- Git LFS / archive / encrypted backup strategy
- weekly/biweekly sync
- restore test
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

@"
# G01 P01 CleanSource Phase Result

## Final result

- Approved files copied/confirmed: $ApprovedCount
- CleanSource files: $($TargetFiles.Count)
- CleanSource MB: $TargetMB
- Ready: $Ready
- Master workspace registered: True
- Original G01_P01 touched: No destructive changes
- Git init in G01_P01: No
- Git init in CleanSource: No
- Raw project pushed: No

## Local run report

$RunReport

## Next recommended project

G01_P02_TradingView_Claude
"@ | Set-Content -LiteralPath $ResultFile -Encoding UTF8

Write-Host "`n=== STEP 7 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 7 - Commit and push"

$FilesToAdd=@(
  "tools\Run-G01P01-CleanSourcePhase.ps1",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_STRICT_CLEANSOURCE_PLAN_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_CLEANSOURCE_COPY_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_CLEANSOURCE_READINESS_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_MASTER_WORKSPACE_REGISTRATION_RESULT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_COMPLETION_CHECKPOINT.md",
  "06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION\G01_P01_CLEANSOURCE_PHASE_RESULT.md",
  "01_WORKSPACES\Igor_Master_Workspace.code-workspace",
  "00_START_HERE\CURRENT_STATUS_MAP.md"
)

foreach($f in $FilesToAdd){
  $full=Join-Path $Repo $f
  if(Test-Path -LiteralPath $full){
    git -C $Repo add -- $f
  }
}

$Staged=git --no-pager -C $Repo diff --cached --name-only
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
  Add-Line "`nABORT: large staged files found."
  $LargeStaged | Out-String -Width 1000 | Add-Content -LiteralPath $RunReport -Encoding UTF8
  Fail-Step "Large staged files found. Commit/push aborted."
}

if($Staged.Count -gt 0){
  git -C $Repo commit -m "Complete G01 P01 clean source workspace phase" | Tee-Object -Variable CommitOutput | Out-Null
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
Get-Content -LiteralPath $RunReport -Tail 160
