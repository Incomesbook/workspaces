$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$TradingRoot="J:\ПРОЕКТЫ\G01_All_About_Trading"
$PreferredProject="J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P02_TradingView_Claude"
$Capsule="$Repo\06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule | Out-Null

$RunReport="$AuditRoot\G01_P02_CAPSULE_PHASE_RUN_$Stamp.md"
$AuditReport="$AuditRoot\G01_P02_TRADINGVIEW_CLAUDE_AUDIT_$Stamp.md"

function Add-Line($Text){
  $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8
}

function Add-Audit($Text){
  $Text | Add-Content -LiteralPath $AuditReport -Encoding UTF8
}

function Fail-Step($Message){
  Add-Line ""
  Add-Line "## FAILED"
  Add-Line $Message
  Write-Host "FAILED: $Message" -ForegroundColor Red
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Write-Host "AUDIT REPORT: $AuditReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 120
  exit 1
}

"# G01 P02 Capsule Phase Run" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: controlled read-only audit + GitHub-safe capsule/manifest/checkpoint"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no delete"
Add-Line "- no move"
Add-Line "- no raw project copy"
Add-Line "- no git init inside G01_P02"
Add-Line "- no push of G01_P02 raw project"
Add-Line "- no AI memory/raw chat/API/private/browser-state push"

"# G01 P02 TradingView Claude Audit" | Set-Content -LiteralPath $AuditReport -Encoding UTF8
Add-Audit "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Audit "READ ONLY. No copy. No move. No delete. No git init. No raw project push."
Add-Audit ""

Write-Host "`n=== STEP 1 / FIND PROJECT ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Find project"

$Project=$null
$Candidates=@()

if(Test-Path -LiteralPath $PreferredProject){
  $Project=$PreferredProject
} elseif(Test-Path -LiteralPath $TradingRoot) {
  $Candidates = Get-ChildItem -LiteralPath $TradingRoot -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "^G01_P02" } |
    Select-Object -ExpandProperty FullName

  if($Candidates.Count -eq 1){
    $Project=$Candidates[0]
  } elseif($Candidates.Count -gt 1){
    Add-Line "Multiple G01_P02 candidates found:"
    $Candidates | ForEach-Object { Add-Line "- $_" }

    Add-Audit "## Multiple candidates found"
    $Candidates | ForEach-Object { Add-Audit "- $_" }

    Fail-Step "Multiple G01_P02 candidates found. I stopped without changing the project."
  }
}

Add-Line "- Trading root: $TradingRoot"
Add-Line "- Preferred project: $PreferredProject"
Add-Line "- Selected project: $Project"
Add-Line "- Project exists: $(if($Project){Test-Path -LiteralPath $Project}else{$false})"

if(-not $Project){
  Fail-Step "G01_P02 project folder was not found under $TradingRoot"
}

Write-Host "`n=== STEP 2 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Input check"

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1

Add-Line "- Repo: $Repo"
Add-Line "- Repo exists: $(Test-Path -LiteralPath $Repo)"
Add-Line "- Project: $Project"
Add-Line "- Project exists: $(Test-Path -LiteralPath $Project)"
Add-Line "- Project is Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))"
Add-Line "- Capsule target: $Capsule"

Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

if(-not (Test-Path -LiteralPath $Repo)){ Fail-Step "Repo not found: $Repo" }
if(-not (Test-Path -LiteralPath $Project)){ Fail-Step "Project not found: $Project" }

Write-Host "`n=== STEP 3 / READ-ONLY AUDIT ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Read-only audit"

Add-Audit "## Project root"
Add-Audit "- Path: $Project"
Add-Audit "- Exists: $(Test-Path -LiteralPath $Project)"
Add-Audit "- Is Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))"

Add-Audit "`n## Top-level folders/files"
Get-ChildItem -LiteralPath $Project -Force -ErrorAction SilentlyContinue |
  Select-Object Mode,Name,Length,LastWriteTime |
  Out-String -Width 1200 |
  Add-Content -LiteralPath $AuditReport -Encoding UTF8

Add-Audit "`n## Folder tree depth 4"
Get-ChildItem -LiteralPath $Project -Directory -Force -Recurse -Depth 4 -ErrorAction SilentlyContinue |
  Select-Object FullName,LastWriteTime |
  Out-String -Width 1800 |
  Add-Content -LiteralPath $AuditReport -Encoding UTF8

Add-Audit "`n## Existing root context files"
$ContextNames=@(
  "PROJECT_STATE.md",
  "NEXT_ACTIONS.md",
  "AI_MEMORY.md",
  "CHATS_INDEX.md",
  "DECISIONS.md",
  "RESTORE_NOTES.md",
  "PROJECT_RULES.md",
  "README.md"
)
foreach($n in $ContextNames){
  Add-Audit "- $n exists: $(Test-Path -LiteralPath (Join-Path $Project $n))"
}

Add-Audit "`n## Git status if repo"
if(Test-Path -LiteralPath (Join-Path $Project ".git")){
  git --no-pager -C $Project status --short --branch 2>&1 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8

  Add-Audit "`n## Remotes"
  git -C $Project remote -v 2>&1 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8
} else {
  Add-Audit "- Not a Git repo at this root."
}

$AllFiles=Get-ChildItem -LiteralPath $Project -File -Recurse -Force -ErrorAction SilentlyContinue
$TotalFiles=$AllFiles.Count
$TotalMB=[math]::Round((($AllFiles | Measure-Object Length -Sum).Sum / 1MB),2)

$Large=$AllFiles |
  Where-Object {$_.Length -gt 50MB} |
  Sort-Object Length -Descending |
  Select-Object -First 60 FullName,@{Name='MB';Expression={[math]::Round($_.Length/1MB,2)}},LastWriteTime

$AiDirs=Get-ChildItem -LiteralPath $Project -Directory -Recurse -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match "(?i)(AI_Memory|Chat|Claude|Codex|Copilot|Gemini|GPT|LLM|Agent|Memory|Conversation|History)" } |
  Select-Object FullName,LastWriteTime

$PrivateDirs=Get-ChildItem -LiteralPath $Project -Directory -Recurse -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match "(?i)(API|Keys|IDs|Credential|Credentials|Private|Secret|Token|Access|Auth|Session|Cookie)" } |
  Select-Object FullName,LastWriteTime

$BrowserDirs=Get-ChildItem -LiteralPath $Project -Directory -Recurse -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match "(?i)(chrome_profile|IndexedDB|Local Storage|Session Storage|Cache|GPUCache|Code Cache|BrowserMetrics|Extensions|Storage)" } |
  Select-Object FullName,LastWriteTime

Add-Audit "`n## Size summary"
Add-Audit "- Total files: $TotalFiles"
Add-Audit "- Total MB: $TotalMB"

Add-Audit "`n## Large files over 50 MB top 60"
if($Large){
  $Large |
    Out-String -Width 2200 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8
} else {
  Add-Audit "- OK: no files over 50 MB found."
}

Add-Audit "`n## AI / chat / LLM related folders"
if($AiDirs){
  $AiDirs |
    Out-String -Width 2200 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8
} else {
  Add-Audit "- No AI/chat-like folders found by name filter."
}

Add-Audit "`n## API / key / private / access-like folders"
if($PrivateDirs){
  $PrivateDirs |
    Out-String -Width 2200 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8
} else {
  Add-Audit "- No API/key/private-like folders found by name filter."
}

Add-Audit "`n## Browser/cache/profile-like folders"
if($BrowserDirs){
  $BrowserDirs |
    Out-String -Width 2200 |
    Add-Content -LiteralPath $AuditReport -Encoding UTF8
} else {
  Add-Audit "- No browser/cache/profile-like folders found by name filter."
}

Add-Audit "`n## File type summary"
$AllFiles |
  Group-Object Extension |
  Sort-Object Count -Descending |
  Select-Object Name,Count |
  Out-String -Width 1000 |
  Add-Content -LiteralPath $AuditReport -Encoding UTF8

Add-Line "- Audit report: $AuditReport"
Add-Line "- Total files: $TotalFiles"
Add-Line "- Total MB: $TotalMB"
Add-Line "- Large files over 50MB found: $($Large.Count)"
Add-Line "- AI/chat folders found: $($AiDirs.Count)"
Add-Line "- Private/API-like folders found: $($PrivateDirs.Count)"
Add-Line "- Browser/cache-like folders found: $($BrowserDirs.Count)"

Write-Host "`n=== STEP 4 / CREATE CAPSULE ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Create capsule"

New-Item -ItemType Directory -Force $Capsule | Out-Null

$LargeText = if($Large){ $Large | Out-String -Width 2200 } else { "- No files over 50 MB found in audit." }
$AiText = if($AiDirs){ $AiDirs | Out-String -Width 2200 } else { "- No AI/chat-like folders found by name filter." }
$PrivateText = if($PrivateDirs){ $PrivateDirs | Out-String -Width 2200 } else { "- No API/key/private-like folders found by name filter." }
$BrowserText = if($BrowserDirs){ $BrowserDirs | Out-String -Width 2200 } else { "- No browser/cache/profile-like folders found by name filter." }

@"
# PROJECT_STATE

## Project

G01_P02_TradingView_Claude

## Local path

$Project

## Role

This is Igor's TradingView / Claude-related trading project inside:

J:\ПРОЕКТЫ\G01_All_About_Trading

Purpose:
- TradingView-related workflow
- Claude / AI-assisted trading research or automation
- trading project settings, rules, scripts, source material, AI/chat memory and possible runtime artifacts

## Current audit result

- Path exists: $(Test-Path -LiteralPath $Project)
- Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))
- Total files found: $TotalFiles
- Total MB found: $TotalMB
- Large files over 50 MB: $($Large.Count)
- AI/chat-like folders: $($AiDirs.Count)
- API/private-like folders: $($PrivateDirs.Count)
- Browser/cache-like folders: $($BrowserDirs.Count)

## Important warning

Do not initialize Git here yet.
Do not push this folder directly.
Do not copy raw project contents into GitHub.

Reason:
This project may contain AI/chat history, private/API/access-like areas, runtime/data/log outputs, browser/cache/profile state, or large files.

## Audit report

$AuditReport
"@ | Set-Content -LiteralPath "$Capsule\PROJECT_STATE.md" -Encoding UTF8

@"
# NEXT_ACTIONS

## Immediate next steps

1. Keep G01_P02 in J:\ПРОЕКТЫ.
2. Do not Git-init G01_P02 root.
3. Do not push G01_P02 root to GitHub.
4. Review G01_P02_LARGE_PRIVATE_CHAT_MANIFEST.md.
5. Later create read-only clean-source candidate audit.
6. Later decide what belongs to:
   - normal Git
   - Git LFS
   - local archive
   - encrypted/private backup
   - manifest-only tracking

## Do not do

- Do not run git add . inside G01_P02.
- Do not publish from VS Code.
- Do not push raw AI memory.
- Do not push raw jsonl/db/log/runtime files.
- Do not push API/key/private folders.
- Do not delete AI memory, chat roots, or legacy material.
"@ | Set-Content -LiteralPath "$Capsule\NEXT_ACTIONS.md" -Encoding UTF8

@"
# AI_MEMORY

## Important memory

G01_P02_TradingView_Claude is part of Igor's G01_All_About_Trading group.

Future AI agents must treat it as a protected trading/AI workflow system, not as a simple clean code repo.

## Current known facts

- Selected local path: $Project
- Total files: $TotalFiles
- Total MB: $TotalMB
- Large files over 50 MB: $($Large.Count)
- AI/chat-like folders found: $($AiDirs.Count)
- API/private-like folders found: $($PrivateDirs.Count)
- Browser/cache-like folders found: $($BrowserDirs.Count)

## Strict rules

- Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md first.
- Read G01_ALL_ABOUT_TRADING capsule before changing this project.
- Read this capsule before changing G01_P02.
- Do not push project root directly.
- Do not expose API keys or credentials.
- Do not delete imported AI/chat history.
- Preserve TradingView/Claude project history and context.
"@ | Set-Content -LiteralPath "$Capsule\AI_MEMORY.md" -Encoding UTF8

@"
# CHATS_INDEX

## Known AI/chat-related roots from audit

$AiText

## Rule

This capsule only references chat locations.
It does not contain raw chat logs.
Raw chat exports require Git LFS, archive, or encrypted/private backup decision.
"@ | Set-Content -LiteralPath "$Capsule\CHATS_INDEX.md" -Encoding UTF8

@"
# LARGE_FILES_POLICY

## Large files found by audit

$LargeText

## Decision

Do not push large files to normal Git.

Future handling:
- normal Git only for small source/capsule/manifest files
- Git LFS only after explicit strategy
- archive-only for cache/runtime/browser state
- encrypted/private backup decision for raw AI/chat/browser/session material
"@ | Set-Content -LiteralPath "$Capsule\LARGE_FILES_POLICY.md" -Encoding UTF8

@"
# PRIVATE_AND_ACCESS_POLICY

## API/key/private/access-like roots from audit

$PrivateText

## Browser/cache/profile-like roots from audit

$BrowserText

## Rule

Do not push these folders blindly.
Do not expose secrets, tokens, API keys, credentials, passwords, private keys, .env files, account IDs, sessions, browser profile state, cookies, local storage, IndexedDB, or access files.

Before any GitHub action:
1. audit filenames
2. audit tracked candidates
3. exclude secret/private/browser-state files
4. commit only safe metadata/capsule/manifest files
"@ | Set-Content -LiteralPath "$Capsule\PRIVATE_AND_ACCESS_POLICY.md" -Encoding UTF8

@"
# DECISIONS

## Decisions

1. G01_P02 stays inside J:\ПРОЕКТЫ\G01_All_About_Trading.
2. G01_P02 is not converted to Git repo now.
3. G01_P02 is not pushed as a whole folder.
4. G01_P02 now has a GitHub-safe capsule in workspaces repo.
5. Large/private/chat/browser/runtime areas are protected.
6. Next phase should be clean-source candidate audit only.
"@ | Set-Content -LiteralPath "$Capsule\DECISIONS.md" -Encoding UTF8

@"
# RESTORE_NOTES

## Restore role

This capsule helps future AI agents understand and restore the G01_P02 TradingView Claude project.

Minimum restore order:

1. Restore or locate:
   $Project

2. Open master workspace:
   J:\Setup_VcCode_Workspace\S10_GitHub\workspaces\01_WORKSPACES\Igor_Master_Workspace.code-workspace

3. Read:
   00_START_HERE\MASTER_STRUCTURE_AND_MEMORY_LOCK.md

4. Read:
   06_AI_CONTEXT_CAPSULE\G01_ALL_ABOUT_TRADING

5. Read this capsule:
   06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE

6. Do not run Git operations inside G01_P02 until a separate cleanup/publish plan exists.

## Not finished yet

- clean-source candidate audit
- clean-source plan
- possible CleanSource extraction
- Git LFS/archive/private backup decision
- restore test
"@ | Set-Content -LiteralPath "$Capsule\RESTORE_NOTES.md" -Encoding UTF8

@"
# G01 P02 Large / Private / Chat Manifest

## Project

G01_P02_TradingView_Claude

## Local path

$Project

## Purpose

This file is a GitHub-safe manifest only.

It documents:
- large files
- AI/chat roots
- API/key/private-like folders
- browser/cache/profile-like folders
- what must never be pushed blindly

It does not contain raw chat logs, credentials, API keys, tokens, passwords, cookies, sessions, browser local storage, IndexedDB data, or private file contents.

## Current decision

Do not initialize Git at G01_P02 root.
Do not push G01_P02 as a whole folder.
Do not run git add . inside G01_P02.
Do not copy raw project contents into Incomesbook/workspaces.

## Size summary

- Total files: $TotalFiles
- Total MB: $TotalMB
- Large files over 50 MB: $($Large.Count)

## Large files over 50 MB

$LargeText

## AI / chat / LLM roots

$AiText

## Private / API / access-like roots

$PrivateText

## Browser/cache/profile-like roots

$BrowserText

## Decision

- preserve everything
- do not delete
- do not move blindly
- do not push raw project root
- use future clean-source audit before any copy
- use archive/LFS/private backup decision for large/raw files

## Next safe action

Create a read-only clean-source candidate audit for G01_P02.

Do not copy yet.
Do not move yet.
Do not Git-init yet.
"@ | Set-Content -LiteralPath "$Capsule\G01_P02_LARGE_PRIVATE_CHAT_MANIFEST.md" -Encoding UTF8

@"
# G01 P02 Completion Checkpoint

## Project

G01_P02_TradingView_Claude

## Local original path

$Project

## Current confirmed state

G01_P02 original project:
- exists
- Git repo: $(Test-Path -LiteralPath (Join-Path $Project '.git'))
- total files: $TotalFiles
- total MB: $TotalMB
- large files over 50 MB: $($Large.Count)
- AI/chat-like folders: $($AiDirs.Count)
- API/private-like folders: $($PrivateDirs.Count)
- browser/cache-like folders: $($BrowserDirs.Count)
- must not be pushed as a whole folder

## Done in this phase

- read-only audit
- AI Context Capsule
- large/private/chat manifest
- restore notes
- decisions file
- current status map update

## Not done yet

- no CleanSource extraction
- no Git init in G01_P02
- no GitHub repo for G01_P02
- no Git LFS/archive decision for large files
- no encrypted/private backup decision for raw AI chats / browser state
- no restore test for G01_P02 on clean machine

## Decision

G01_P02 is now safely represented in the main control repo by:
- capsule
- manifest
- audit report reference
- restore notes
- status map

The original G01_P02 remains protected in J:\ПРОЕКТЫ.

## Next priority

Create G01_P02 clean-source candidate audit only.

## Strict instruction for future AI agents

Before touching G01_P02:
1. Read MASTER_STRUCTURE_AND_MEMORY_LOCK.md.
2. Read G01_ALL_ABOUT_TRADING capsule.
3. Read this G01_P02 capsule.
4. Do not run git init inside original G01_P02.
5. Do not push original G01_P02.
6. Do not delete AI memory, browser/cache/profile data, API/private folders, logs, results, or legacy folders.
"@ | Set-Content -LiteralPath "$Capsule\G01_P02_COMPLETION_CHECKPOINT.md" -Encoding UTF8

Write-Host "`n=== STEP 5 / STATUS MAP ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Status map"

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
- G01_P01 is closed with completion checkpoint.
- G01_P01 CleanSource is copied and registered in master workspace.
- G01_P02 capsule phase completed.
- G01_P02 large/private/chat manifest created.
- G01_P02 audit completed.

## Current latest phase

G01_P02 capsule / manifest phase completed.

## Next

- G01_P02 clean-source candidate audit
- AI chat export confirmation
- Git LFS / archive / encrypted backup strategy
- weekly/biweekly sync
- restore test
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

@"
# G01 P02 Capsule Phase Result

## Final result

- Project: $Project
- Total files: $TotalFiles
- Total MB: $TotalMB
- Large files over 50 MB: $($Large.Count)
- AI/chat-like folders: $($AiDirs.Count)
- API/private-like folders: $($PrivateDirs.Count)
- Browser/cache-like folders: $($BrowserDirs.Count)
- Raw project pushed: No
- Git init inside G01_P02: No
- Files deleted: No
- Files moved: No

## Local run report

$RunReport

## Local audit report

$AuditReport

## Next recommended step

G01_P02 clean-source candidate audit
"@ | Set-Content -LiteralPath "$Capsule\G01_P02_CAPSULE_PHASE_RESULT.md" -Encoding UTF8

Write-Host "`n=== STEP 6 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 6 - Commit and push"

$FilesToAdd=@(
  "tools\Run-G01P02-CapsulePhase.ps1",
  "06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE",
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
  git -C $Repo commit -m "Add G01 P02 TradingView Claude capsule phase" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "AUDIT REPORT: $AuditReport" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 160
