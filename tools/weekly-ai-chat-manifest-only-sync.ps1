$ErrorActionPreference = "Stop"

try {
  [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  chcp.com 65001 > $null 2>&1
} catch {}

$Repo = "J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$CommonRoot = "J:\_AI_CHATS_ОБЩИЕ"
$AuditRoot = Join-Path $CommonRoot "_AUDIT"

$ManifestRel = "04_MANIFESTS/AI_CHAT_WEEKLY_MANIFEST.md"
$ManifestCsvRel = "04_MANIFESTS/AI_CHAT_WEEKLY_MANIFEST.csv"
$StatusRel = "00_START_HERE/AI_CHAT_WEEKLY_MANIFEST_LAST_RUN.md"

$AllowedRel = @($ManifestRel,$ManifestCsvRel,$StatusRel)

$ManifestDoc = Join-Path $Repo ($ManifestRel -replace "/","\")
$ManifestCsv = Join-Path $Repo ($ManifestCsvRel -replace "/","\")
$StatusDoc = Join-Path $Repo ($StatusRel -replace "/","\")

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Ensure-Parent {
  param([string]$Path)
  $Parent = Split-Path -Parent $Path
  if(-not (Test-Path -LiteralPath $Parent)){
    New-Item -ItemType Directory -Force $Parent | Out-Null
  }
}

function Set-TextUtf8Bom {
  param([string]$Path,[string]$Text)
  Ensure-Parent $Path
  [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8Bom)
}

function Export-CsvSafe {
  param([object[]]$Rows,[string]$Path)
  Ensure-Parent $Path
  $Rows | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
}

function Normalize-GitPath {
  param([string]$Path)
  return ($Path -replace "\\","/").Trim('"')
}

function Get-GitStatusFiles {
  param([string[]]$Lines)

  $Files = @()

  foreach($Line in $Lines){
    if([string]::IsNullOrWhiteSpace($Line)){ continue }

    if($Line.Length -ge 4){
      $P = $Line.Substring(3).Trim()
    } else {
      $P = $Line.Trim()
    }

    if($P -match " -> "){
      $P = ($P -split " -> ")[-1]
    }

    $Files += (Normalize-GitPath $P)
  }

  return @($Files)
}

function Run-Git {
  param([string[]]$GitArgs,[switch]$AllowFail)

  $Out = @(& git @GitArgs 2>&1)
  $Code = $LASTEXITCODE

  if($Code -ne 0 -and -not $AllowFail){
    throw "Git failed with code $Code : git $($GitArgs -join ' ')`n$($Out -join "`n")"
  }

  [pscustomobject]@{
    Code = $Code
    Output = @($Out)
  }
}

function Test-SensitiveLikeContent {
  param([string[]]$Lines)

  $Regexes = @(
    "ghp_[A-Za-z0-9_]{20,}",
    "github_pat_[A-Za-z0-9_]{20,}",
    "sk-[A-Za-z0-9]{20,}",
    "xox[baprs]-[A-Za-z0-9-]{20,}",
    "BEGIN [A-Z ]*PRIVATE KEY",
    "Authorization:\s*Bearer\s+[A-Za-z0-9._\-]{20,}",
    "(?i)(api[_-]?key|access[_-]?token|refresh[_-]?token|private[_-]?key)\s*[:=]\s*['""][^'""]{12,}['""]"
  )

  $Hits = @()

  foreach($R in $Regexes){
    $Matches = @($Lines | Select-String -Pattern $R)
    if($Matches.Count -gt 0){
      $Hits += [pscustomobject]@{
        Pattern = $R
        Count = $Matches.Count
      }
    }
  }

  return @($Hits)
}

function Count-RootSafe {
  param([string]$Root,[string]$Label)

  $Exists = Test-Path -LiteralPath $Root
  $JsonlCount = 0
  $JsonCount = 0
  $MdCount = 0
  $DbCount = 0
  $TotalSizeMB = 0.0
  $ErrorText = ""

  if($Exists){
    try {
      $Files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 10000)
      $JsonlCount = @($Files | Where-Object { $_.Extension -eq ".jsonl" }).Count
      $JsonCount = @($Files | Where-Object { $_.Extension -eq ".json" }).Count
      $MdCount = @($Files | Where-Object { $_.Extension -eq ".md" }).Count
      $DbCount = @($Files | Where-Object { $_.Extension -in @(".db",".sqlite") }).Count
      $Sum = ($Files | Measure-Object Length -Sum).Sum
      if($null -eq $Sum){ $Sum = 0 }
      $TotalSizeMB = [Math]::Round($Sum / 1MB, 2)
    } catch {
      $ErrorText = $_.Exception.Message
    }
  }

  [pscustomobject]@{
    Label = $Label
    Root = $Root
    Exists = $Exists
    JsonlCountSeen = $JsonlCount
    JsonCountSeen = $JsonCount
    MdCountSeen = $MdCount
    DbCountSeen = $DbCount
    SizeMBSeenCapped = $TotalSizeMB
    Action = "manifest only"
    Error = $ErrorText
  }
}

try {
  if(-not (Test-Path -LiteralPath $AuditRoot)){
    New-Item -ItemType Directory -Force $AuditRoot | Out-Null
  }

  if(-not (Test-Path -LiteralPath $Repo)){
    throw "Repo not found: $Repo"
  }

  $Inside = Run-Git -GitArgs @("-C",$Repo,"rev-parse","--is-inside-work-tree")
  if((($Inside.Output -join "").Trim()) -ne "true"){
    throw "Not a git worktree: $Repo"
  }

  $BranchObj = Run-Git -GitArgs @("-C",$Repo,"branch","--show-current")
  $Branch = (($BranchObj.Output -join "").Trim())
  if($Branch -ne "main"){
    throw "Unexpected branch: $Branch"
  }

  $StatusBeforeObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"status","--porcelain","--untracked-files=all")
  $BeforeFiles = @(Get-GitStatusFiles $StatusBeforeObj.Output)
  $UnexpectedBefore = @($BeforeFiles | Where-Object { $_ -notin $AllowedRel })

  if($UnexpectedBefore.Count -gt 0){
    throw "Unexpected dirty files before weekly manifest. Stop."
  }

  Run-Git -GitArgs @("-C",$Repo,"pull","--ff-only","origin","main") -AllowFail | Out-Null

  $Roots = @(
    @{ Label="CommonRoot"; Root="J:\_AI_CHATS_ОБЩИЕ" },
    @{ Label="CodexCommon"; Root="J:\_AI_CHATS_ОБЩИЕ\CODEX" },
    @{ Label="CodexHome"; Root="J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE" },
    @{ Label="ClaudeJConfig"; Root="J:\ClaudeData\.claude" },
    @{ Label="ClaudeJMemory"; Root="J:\ClaudeData\memory" },
    @{ Label="ClaudeHub"; Root="J:\ClaudeHub" },
    @{ Label="ClaudeCUser"; Root="C:\Users\IgorK\.claude" },
    @{ Label="CodexCUser"; Root="C:\Users\IgorK\.codex" },
    @{ Label="CherryStudio"; Root="C:\Users\IgorK\AppData\Roaming\CherryStudio" },
    @{ Label="ClaudeDesktopLocal"; Root="C:\Users\IgorK\AppData\Local\Claude" },
    @{ Label="ClaudeDesktopRoaming"; Root="C:\Users\IgorK\AppData\Roaming\Claude" },
    @{ Label="ChatGPTLocalOpenAI"; Root="C:\Users\IgorK\AppData\Local\OpenAI" },
    @{ Label="VSCodeRoaming"; Root="C:\Users\IgorK\AppData\Roaming\Code" },
    @{ Label="CursorRoaming"; Root="C:\Users\IgorK\AppData\Roaming\Cursor" },
    @{ Label="WindsurfRoaming"; Root="C:\Users\IgorK\AppData\Roaming\Windsurf" }
  )

  $Rows = @()

  foreach($R in $Roots){
    $Rows += Count-RootSafe -Root $R.Root -Label $R.Label
  }

  Export-CsvSafe -Rows $Rows -Path $ManifestCsv

  $Now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $RowsText = ($Rows | ForEach-Object {
    "- $($_.Label): exists=$($_.Exists), jsonl=$($_.JsonlCountSeen), json=$($_.JsonCountSeen), md=$($_.MdCountSeen), db=$($_.DbCountSeen), sizeMB_seen=$($_.SizeMBSeenCapped), root=$($_.Root)"
  }) -join "`r`n"

  $ManifestText = @"
# AI Chat Weekly Manifest

Last run: $Now

Mode: manifest-only.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## Safety

- No deletion.
- No raw chat copy.
- No raw GitHub sync.
- No archive.
- No Git LFS.
- No ENV/PATH change.

## Roots

$RowsText
"@

  $StatusText = @"
# AI Chat Weekly Manifest Last Run

Last run: $Now

Result: manifest-only run completed.

No raw chats were copied.
No raw chats were pushed to GitHub.
No files were deleted.
"@

  Set-TextUtf8Bom $ManifestDoc $ManifestText
  Set-TextUtf8Bom $StatusDoc $StatusText

  $AfterObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"status","--porcelain","--untracked-files=all")
  $AfterFiles = @(Get-GitStatusFiles $AfterObj.Output)
  $UnexpectedAfter = @($AfterFiles | Where-Object { $_ -notin $AllowedRel })

  if($UnexpectedAfter.Count -gt 0){
    throw "Unexpected repo files changed after manifest. Stop."
  }

  $AddArgs = @("-C",$Repo,"add","-f","--") + $AllowedRel
  Run-Git -GitArgs $AddArgs | Out-Null

  $StagedObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"diff","--cached","--name-only")
  $Staged = @(($StagedObj.Output) | ForEach-Object { Normalize-GitPath $_ })

  $UnexpectedStaged = @($Staged | Where-Object { $_ -notin $AllowedRel })
  if($UnexpectedStaged.Count -gt 0){
    Run-Git -GitArgs @("-C",$Repo,"reset","-q") -AllowFail | Out-Null
    throw "Unexpected staged files."
  }

  if($Staged.Count -gt 0){
    $DiffObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"diff","--cached")
    $Diff = @($DiffObj.Output)

    $SensitiveHits = @(Test-SensitiveLikeContent $Diff)

    if($SensitiveHits.Count -gt 0){
      Run-Git -GitArgs @("-C",$Repo,"reset","-q") -AllowFail | Out-Null
      throw "Sensitive-like value found in weekly manifest."
    }

    Run-Git -GitArgs @("-C",$Repo,"commit","-m","Weekly AI chat manifest-only sync")
    Run-Git -GitArgs @("-C",$Repo,"push","origin","main")
  }
} catch {
  $Err = $_.Exception.Message
  $FailLog = Join-Path $AuditRoot ("WEEKLY_MANIFEST_ONLY_FAILED_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".md")
  Set-TextUtf8Bom $FailLog "# Weekly manifest-only failed`r`n`r`n$Err"
  exit 1
}