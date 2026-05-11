$ErrorActionPreference = "Stop"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Capsule="$Repo\03_AI_CHATS"
$StatusMap="$Repo\00_START_HERE\CURRENT_STATUS_MAP.md"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force $AuditRoot,$Capsule | Out-Null

$RunReport="$AuditRoot\GLOBAL_AI_CHAT_BACKUP_STRATEGY_RUN_$Stamp.md"
$Csv="$AuditRoot\GLOBAL_AI_CHAT_ROOTS_INDEX_$Stamp.csv"
$Summary="$Capsule\GLOBAL_AI_CHAT_BACKUP_STRATEGY.md"
$Matrix="$Capsule\AI_CHAT_BACKUP_STRATEGY_MATRIX.md"
$Restore="$Capsule\AI_CHAT_RESTORE_PLAN.md"
$IgnorePolicy="$Capsule\AI_CHAT_GITIGNORE_AND_EXCLUDE_POLICY.md"
$Checkpoint="$Capsule\AI_CHAT_BACKUP_STRATEGY_CHECKPOINT.md"
$SafeIndex="$Capsule\AI_CHAT_ROOTS_SAFE_INDEX_SUMMARY.md"

function Add-Line($Text){ $Text | Add-Content -LiteralPath $RunReport -Encoding UTF8 }

function Stop-Safely($Message){
  Add-Line ""
  Add-Line "## STOPPED SAFELY"
  Add-Line $Message

  @"
# AI Chat Backup Strategy Checkpoint

## Result

STOPPED SAFELY.

## Reason

$Message

## Local run report

$RunReport

## Safety

No raw chats copied.
No secrets copied.
No browser session copied.
No encrypted archive created.
No sync enabled.
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

  git -C $Repo add `
    tools\Run-GlobalAIChatBackupStrategyPhase.ps1 `
    03_AI_CHATS\AI_CHAT_BACKUP_STRATEGY_CHECKPOINT.md 2>$null

  $staged=@(git --no-pager -C $Repo diff --cached --name-only)
  if($staged.Count -gt 0){
    git -C $Repo commit -m "Record AI chat backup strategy stop point" | Out-Null
    git -C $Repo push origin main | Out-Null
  }

  Write-Host "`n=== STOPPED SAFELY ===" -ForegroundColor Yellow
  Write-Host $Message -ForegroundColor Yellow
  Write-Host "RUN REPORT: $RunReport" -ForegroundColor Yellow
  Get-Content -LiteralPath $RunReport -Tail 180
  exit 0
}

"# Global AI Chat Backup Strategy Phase" | Set-Content -LiteralPath $RunReport -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: audit + strategy + GitHub-safe metadata only"
Add-Line ""
Add-Line "Safety:"
Add-Line "- no raw chat copy"
Add-Line "- no browser profile copy"
Add-Line "- no cookies/session/local storage copy"
Add-Line "- no API/private/secret content copy"
Add-Line "- no Git LFS enable"
Add-Line "- no encrypted archive creation"
Add-Line "- no scheduled sync enable"
Add-Line "- commit only small strategy/index files"

Write-Host "`n=== STEP 1 / INPUT CHECK ===" -ForegroundColor Cyan
Add-Line "`n## Step 1 - Input check"

Add-Line "- Repo: $Repo"
Add-Line "- Repo exists: $(Test-Path -LiteralPath $Repo)"
Add-Line "- AuditRoot: $AuditRoot"
Add-Line "- Capsule: $Capsule"

if(-not (Test-Path -LiteralPath $Repo)){ Stop-Safely "Repo not found: $Repo" }

$RepoStatusBefore=git --no-pager -C $Repo status --short --branch 2>&1
Add-Line "`nRepo status before:"
$RepoStatusBefore | ForEach-Object { Add-Line $_ }

Write-Host "`n=== STEP 2 / DISCOVER CHAT ROOTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 2 - Discover chat roots"

$UserProfile=$env:USERPROFILE
$CandidateRoots=@(
  "J:\_AI_CHATS_ОБЩИЕ",
  "J:\Setup_VcCode_Workspace",
  "J:\ПРОЕКТЫ",
  "J:\ClaudeData",
  "J:\AI-Home",
  "J:\VSCode-Portable\data\user-data",
  "J:\VSCode-Live",
  "J:\VSCode-Backup",
  "J:\S08_GLOBAL_AI_CHATS",
  "$UserProfile\.claude",
  "$UserProfile\.codex",
  "$UserProfile\AppData\Roaming\Code\User",
  "$UserProfile\AppData\Roaming\Cursor\User",
  "$UserProfile\AppData\Roaming\Windsurf\User",
  "$UserProfile\AppData\Roaming\Claude",
  "$UserProfile\AppData\Local\Claude",
  "$UserProfile\AppData\Roaming\GitHub Copilot",
  "$UserProfile\AppData\Local\GitHub Copilot"
) | Sort-Object -Unique

$ExistingRoots=@()
foreach($r in $CandidateRoots){
  if(Test-Path -LiteralPath $r){
    $ExistingRoots += $r
  }
}

Add-Line "- Candidate roots checked: $($CandidateRoots.Count)"
Add-Line "- Existing roots found: $($ExistingRoots.Count)"
$ExistingRoots | ForEach-Object { Add-Line "  - $_" }

if($ExistingRoots.Count -eq 0){
  Stop-Safely "No AI/chat candidate roots found."
}

Write-Host "`n=== STEP 3 / METADATA INDEX ONLY ===" -ForegroundColor Cyan
Add-Line "`n## Step 3 - Metadata index only"

$ChatLikeNamePattern="(?i)(chat|conversation|history|transcript|memory|claude|codex|copilot|gpt|chatgpt|openai|cursor|windsurf|specstory|notebooklm|agent|llm|session|workspaceStorage|globalStorage)"
$StrictSecretPathPattern="(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|auth|cookie|session|local storage|session storage|indexeddb|trusttoken|login|account|bearer|oauth|\.env)"
$BrowserStatePattern="(?i)(chrome_profile|indexeddb|local storage|session storage|extension state|cookies|network|webstorage|sync data|cache|code cache|gpucache|browsermetrics)"
$RawChatExtPattern="(?i)\.(jsonl|json|md|txt|log|sqlite|db|csv|yaml|yml)$"
$ArchiveExtPattern="(?i)\.(zip|7z|rar|tar|gz|mp4|mov|avi|webm|mp3|wav|m4a|pdf|exe|msi|dmg|bin|dat|ldb|sqlite|db)$"

$Rows=New-Object System.Collections.Generic.List[object]

foreach($root in $ExistingRoots){
  Write-Host "Scanning: $root" -ForegroundColor DarkCyan
  Add-Line "- Scanning root: $root"

  $files = Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue

  foreach($f in $files){
    $rel=$f.FullName.Substring($root.Length).TrimStart("\")
    $path=$f.FullName
    $name=$f.Name

    $isChatLike=($path -match $ChatLikeNamePattern -or $name -match $ChatLikeNamePattern)
    $isSecretLike=($path -match $StrictSecretPathPattern -or $name -match $StrictSecretPathPattern)
    $isBrowserState=($path -match $BrowserStatePattern)
    $isRawChatExt=($f.Extension -match $RawChatExtPattern)
    $isArchiveExt=($f.Extension -match $ArchiveExtPattern)
    $isLarge=($f.Length -gt 50MB)
    $isHuge=($f.Length -gt 500MB)

    $class="OTHER_METADATA_ONLY"
    $strategy="MANIFEST_ONLY"

    if($isSecretLike){
      $class="STRICT_PRIVATE_EXCLUDE"
      $strategy="DO_NOT_PUSH_REVIEW_PRIVATE"
    } elseif($isBrowserState){
      $class="BROWSER_STATE_PRIVATE"
      $strategy="ENCRYPTED_ARCHIVE_OR_LOCAL_ONLY"
    } elseif($isHuge){
      $class="HUGE_RAW_OR_ARCHIVE"
      $strategy="LOCAL_ARCHIVE_OR_ENCRYPTED_ARCHIVE"
    } elseif($isLarge){
      $class="LARGE_RAW_OR_ARCHIVE"
      $strategy="GIT_LFS_CANDIDATE_OR_ENCRYPTED_ARCHIVE"
    } elseif($isChatLike -and $isRawChatExt){
      $class="CHAT_MEMORY_CANDIDATE"
      $strategy="NORMAL_GIT_ONLY_IF_REDACTED_AND_SMALL_ELSE_ARCHIVE"
    } elseif($isChatLike){
      $class="CHAT_RELATED_METADATA"
      $strategy="MANIFEST_OR_REVIEW"
    } elseif($isArchiveExt){
      $class="ARCHIVE_BINARY_EXCLUDE"
      $strategy="LOCAL_ARCHIVE_ONLY"
    }

    if($isChatLike -or $isSecretLike -or $isBrowserState -or $isLarge -or $isArchiveExt){
      $safeName=$name
      if($isSecretLike){
        $safeName="[REDACTED_SECRET_LIKE_FILENAME]"
      }

      $Rows.Add([pscustomobject]@{
        Root=$root
        RelativeFolder=(Split-Path -Parent $rel)
        FileName=$safeName
        Extension=$f.Extension
        MB=[math]::Round($f.Length/1MB,4)
        LastWriteTime=$f.LastWriteTime
        Class=$class
        Strategy=$strategy
        ChatLike=$isChatLike
        SecretLike=$isSecretLike
        BrowserState=$isBrowserState
        LargeOver50MB=$isLarge
        HugeOver500MB=$isHuge
      }) | Out-Null
    }
  }
}

$Rows | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8

$TotalRows=$Rows.Count
$TotalMB=[math]::Round((($Rows | Measure-Object MB -Sum).Sum),2)
$LargeCount=($Rows | Where-Object {$_.LargeOver50MB -eq $true}).Count
$HugeCount=($Rows | Where-Object {$_.HugeOver500MB -eq $true}).Count
$SecretCount=($Rows | Where-Object {$_.SecretLike -eq $true}).Count
$BrowserCount=($Rows | Where-Object {$_.BrowserState -eq $true}).Count

Add-Line "- CSV: $Csv"
Add-Line "- Indexed metadata rows: $TotalRows"
Add-Line "- Represented MB: $TotalMB"
Add-Line "- Large >50MB rows: $LargeCount"
Add-Line "- Huge >500MB rows: $HugeCount"
Add-Line "- Secret-like rows redacted: $SecretCount"
Add-Line "- Browser-state rows: $BrowserCount"

Write-Host "`n=== STEP 4 / WRITE STRATEGY DOCUMENTS ===" -ForegroundColor Cyan
Add-Line "`n## Step 4 - Write strategy documents"

$ByClass = $Rows |
  Group-Object Class |
  ForEach-Object {
    [pscustomobject]@{
      Class=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByStrategy = $Rows |
  Group-Object Strategy |
  ForEach-Object {
    [pscustomobject]@{
      Strategy=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),2)
    }
  } |
  Sort-Object MB -Descending

$ByRoot = $Rows |
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
# Global AI Chat Backup Strategy

## Purpose

Create a safe backup strategy for Igor's AI chats, AI memory, Claude/Codex/Copilot/ChatGPT-related files, VS Code workspace history, and project restore context.

## Current decision

This phase is strategy/index only.

It does not:
- copy raw chats
- copy browser profiles
- copy cookies/session/local storage/IndexedDB
- expose secrets
- enable Git LFS
- create encrypted archives
- enable scheduled sync

## Latest metadata CSV

$Csv

## Summary

- Existing roots scanned: $($ExistingRoots.Count)
- Metadata rows indexed: $TotalRows
- Represented MB: $TotalMB
- Large >50MB rows: $LargeCount
- Huge >500MB rows: $HugeCount
- Secret-like rows redacted: $SecretCount
- Browser-state rows: $BrowserCount

## Why not push raw chats directly

GitHub warns on files larger than 50 MiB, and large object/repository limits make huge raw chat dumps unsuitable for normal Git. Git LFS can be used later, but only after explicit tracking rules and a separate storage decision.

Browser state and private/session/API-like files are not suitable for normal GitHub backup.

## Strategy

1. Normal Git:
   - capsules
   - manifests
   - restore plans
   - small redacted AI context summaries
   - safe scripts
   - small indexes without raw secrets

2. Git LFS candidate:
   - selected large but non-private files only
   - only after review
   - only after .gitattributes rules are approved

3. Encrypted private archive:
   - raw AI chats
   - raw jsonl
   - raw chat exports
   - selected IndexedDB/browser-state only if needed for restore
   - never public, never normal Git

4. Local archive only:
   - caches
   - browser cache
   - runtime output
   - temporary files
   - generated logs
   - installers/media

5. Manifest only:
   - secret-like locations
   - API/private/session/cookie/browser-state references
   - anything not safe to copy
"@ | Set-Content -LiteralPath $Summary -Encoding UTF8

@"
# AI Chat Backup Strategy Matrix

## By class

$($ByClass | Format-Table -AutoSize | Out-String -Width 1600)

## By strategy

$($ByStrategy | Format-Table -AutoSize | Out-String -Width 1600)

## By root

$($ByRoot | Format-Table -AutoSize | Out-String -Width 1800)

## Rules

| Class | Default action |
|---|---|
| CHAT_MEMORY_CANDIDATE | Review; small redacted summaries may go normal Git; raw content goes encrypted/archive/LFS decision |
| CHAT_RELATED_METADATA | Manifest or review |
| LARGE_RAW_OR_ARCHIVE | Git LFS candidate only after manual approval, otherwise encrypted/local archive |
| HUGE_RAW_OR_ARCHIVE | Local/encrypted archive, not normal Git |
| BROWSER_STATE_PRIVATE | Do not push; encrypted archive only if restore-critical |
| STRICT_PRIVATE_EXCLUDE | Do not push; manifest only |
| ARCHIVE_BINARY_EXCLUDE | Local archive only |
| OTHER_METADATA_ONLY | Manifest only unless explicitly approved |
"@ | Set-Content -LiteralPath $Matrix -Encoding UTF8

@"
# AI Chat Restore Plan

## Restore goal

Restore enough project and AI context so Igor can continue work from the same workspace and so future AI agents understand the project history.

## Restore order

1. Clone or restore:
   Incomesbook/workspaces

2. Open:
   J:\Setup_VcCode_Workspace\S10_GitHub\workspaces\01_WORKSPACES\Igor_Master_Workspace.code-workspace

3. Read:
   00_START_HERE\MASTER_STRUCTURE_AND_MEMORY_LOCK.md

4. Read:
   00_START_HERE\CURRENT_STATUS_MAP.md

5. Read:
   03_AI_CHATS\GLOBAL_AI_CHAT_BACKUP_STRATEGY.md
   03_AI_CHATS\AI_CHAT_BACKUP_STRATEGY_MATRIX.md

6. Read project capsules:
   06_AI_CONTEXT_CAPSULE\G01_ALL_ABOUT_TRADING
   06_AI_CONTEXT_CAPSULE\G01_P01_POCKETOPTION
   06_AI_CONTEXT_CAPSULE\G01_P02_TRADINGVIEW_CLAUDE
   06_AI_CONTEXT_CAPSULE\G01_P03_MARKET_AGENT

7. Restore local project folders from J: or backup archive.

8. Restore raw AI chat archive only from approved private/encrypted source.

## Not done yet

- encrypted archive format not selected
- Git LFS not enabled
- weekly/biweekly sync not enabled
- clean-machine restore test not done
"@ | Set-Content -LiteralPath $Restore -Encoding UTF8

@"
# AI Chat Gitignore And Exclude Policy

## Normal Git allowed

- capsules
- manifests
- restore notes
- safe summaries
- safe indexes
- safe scripts

## Never push blindly

- *.jsonl
- *.sqlite
- *.db
- *.log
- browser cache
- Chrome profiles
- IndexedDB
- Local Storage
- Session Storage
- cookies
- auth/session data
- API/private/key folders
- .env
- raw chat exports
- huge diagnostics
- installers
- media dumps

## Recommended ignore patterns for future raw-chat repos

*.jsonl
*.sqlite
*.db
*.log
*.ldb
*.lock
*.env
*.zip
*.7z
*.rar
*.mp4
*.mp3
*.wav
*.pdf
**/Cache/**
**/Code Cache/**
**/GPUCache/**
**/IndexedDB/**
**/Local Storage/**
**/Session Storage/**
**/Extension State/**
**/Network/**
**/WebStorage/**
**/*token*
**/*secret*
**/*password*
**/*credential*
**/*api_key*
**/*private_key*
"@ | Set-Content -LiteralPath $IgnorePolicy -Encoding UTF8

@"
# AI Chat Roots Safe Index Summary

## CSV

$Csv

## Summary

- Metadata rows indexed: $TotalRows
- Represented MB: $TotalMB
- Large >50MB rows: $LargeCount
- Huge >500MB rows: $HugeCount
- Secret-like rows redacted: $SecretCount
- Browser-state rows: $BrowserCount

## By class

$($ByClass | Format-Table -AutoSize | Out-String -Width 1600)

## By strategy

$($ByStrategy | Format-Table -AutoSize | Out-String -Width 1600)

## Safety

This summary contains metadata only.
It does not contain raw chat content.
Secret-like filenames are redacted.
No raw files were copied.
"@ | Set-Content -LiteralPath $SafeIndex -Encoding UTF8

@"
# AI Chat Backup Strategy Checkpoint

## Status

Global AI Chat Backup Strategy Phase completed.

## What was done

- discovered likely AI/chat roots
- generated metadata-only CSV
- redacted secret-like filenames
- classified large/browser/private/chat-like rows
- created strategy documents
- created restore plan
- created Git ignore/exclude policy
- updated current status map

## What was not done

- no raw chat copy
- no browser profile copy
- no secret copy
- no Git LFS enable
- no encrypted archive
- no scheduled sync
- no restore test

## Next recommended phase

Choose backup layer:

1. encrypted private archive for raw AI chats
2. Git LFS only for approved non-private large files
3. weekly/biweekly scheduled dry-run sync
4. clean-machine restore test
"@ | Set-Content -LiteralPath $Checkpoint -Encoding UTF8

@"
# Current Status Map

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Done

- Main repo Incomesbook/workspaces is active and clean.
- G01_P03 is closed.
- G01_P01 is closed.
- G01_P02 is closed after FIX.
- Obsolete G01_P02 failed CleanSource artifacts were archived.
- Global AI Chat Backup Strategy Phase completed.
- AI/chat roots metadata index created.
- AI chat backup strategy matrix created.
- AI chat restore plan created.
- AI chat gitignore/exclude policy created.

## Current latest phase

Global AI Chat Backup Strategy completed as metadata/strategy only.

## Not done yet

- Raw AI chats are not copied to GitHub.
- Git LFS is not enabled.
- Encrypted archive is not created.
- Weekly/biweekly sync is not enabled.
- Restore test is not done.

## Next

Choose and implement private encrypted archive phase or scheduled sync dry-run phase.
"@ | Set-Content -LiteralPath $StatusMap -Encoding UTF8

Write-Host "`n=== STEP 5 / COMMIT AND PUSH CONTROL REPO ===" -ForegroundColor Cyan
Add-Line "`n## Step 5 - Commit and push"

$FilesToAdd=@(
  "tools\Run-GlobalAIChatBackupStrategyPhase.ps1",
  "03_AI_CHATS\GLOBAL_AI_CHAT_BACKUP_STRATEGY.md",
  "03_AI_CHATS\AI_CHAT_BACKUP_STRATEGY_MATRIX.md",
  "03_AI_CHATS\AI_CHAT_RESTORE_PLAN.md",
  "03_AI_CHATS\AI_CHAT_GITIGNORE_AND_EXCLUDE_POLICY.md",
  "03_AI_CHATS\AI_CHAT_BACKUP_STRATEGY_CHECKPOINT.md",
  "03_AI_CHATS\AI_CHAT_ROOTS_SAFE_INDEX_SUMMARY.md",
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
  git -C $Repo commit -m "Add global AI chat backup strategy" | Tee-Object -Variable CommitOutput | Out-Null
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
Write-Host "CSV: $Csv" -ForegroundColor Green
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
$FinalStatus
Write-Host "`n=== LAST COMMITS ===" -ForegroundColor Cyan
$LastCommits
Write-Host "`n=== REPORT TAIL ===" -ForegroundColor Cyan
Get-Content -LiteralPath $RunReport -Tail 180
