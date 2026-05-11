$ErrorActionPreference = "Continue"

try {
  [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  chcp.com 65001 > $null 2>&1
} catch {}

$Repo = "J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$CommonRoot = "J:\_AI_CHATS_ОБЩИЕ"
$AuditRoot = Join-Path $CommonRoot "_AUDIT"
$SourcesRoot = Join-Path $CommonRoot "_SOURCES"

$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"

$RunReport = Join-Path $AuditRoot "AUTO_LOCAL_RAW_MIRROR_RUN_$Stamp.md"
$RunCsv = Join-Path $AuditRoot "AUTO_LOCAL_RAW_MIRROR_RUN_$Stamp.csv"
$LockPath = Join-Path $AuditRoot "AUTO_LOCAL_RAW_MIRROR.lock"

$ManifestRel = "04_MANIFESTS/AI_CHAT_AUTO_LOCAL_RAW_MIRROR_MANIFEST.md"
$ManifestCsvRel = "04_MANIFESTS/AI_CHAT_AUTO_LOCAL_RAW_MIRROR_MANIFEST.csv"
$LastRunRel = "00_START_HERE/AI_CHAT_AUTO_LOCAL_RAW_MIRROR_LAST_RUN.md"

$ManifestDoc = Join-Path $Repo ($ManifestRel -replace "/","\")
$ManifestCsv = Join-Path $Repo ($ManifestCsvRel -replace "/","\")
$LastRunDoc = Join-Path $Repo ($LastRunRel -replace "/","\")

$AllowedRel = @($ManifestRel,$ManifestCsvRel,$LastRunRel)

$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Ensure-Dir {
  param([string]$Path)
  if(-not (Test-Path -LiteralPath $Path)){
    New-Item -ItemType Directory -Force $Path | Out-Null
  }
}

function Ensure-Parent {
  param([string]$Path)
  Ensure-Dir (Split-Path -Parent $Path)
}

function Set-TextUtf8Bom {
  param([string]$Path,[string]$Text)
  Ensure-Parent $Path
  [System.IO.File]::WriteAllText($Path,$Text,$script:Utf8Bom)
}

function Add-RunLine {
  param([object]$Text)
  [System.IO.File]::AppendAllText($script:RunReport,"$Text`r`n",$script:Utf8Bom)
}

function Normalize-GitPath {
  param([string]$Path)
  return ($Path -replace "\\","/").Trim('"')
}

function Get-GitStatusFiles {
  param([string[]]$Lines)
  $Files=@()
  foreach($Line in $Lines){
    if([string]::IsNullOrWhiteSpace($Line)){ continue }
    if($Line.Length -ge 4){ $P=$Line.Substring(3).Trim() } else { $P=$Line.Trim() }
    if($P -match " -> "){ $P=($P -split " -> ")[-1] }
    $Files += (Normalize-GitPath $P)
  }
  return @($Files)
}

function Run-Git {
  param([string[]]$GitArgs,[switch]$AllowFail)
  $Out=@(& git @GitArgs 2>&1)
  $Code=$LASTEXITCODE
  Add-RunLine "git $($GitArgs -join ' ')"
  foreach($Line in $Out){ Add-RunLine $Line }
  if($Code -ne 0 -and -not $AllowFail){ throw "Git failed with code $Code : git $($GitArgs -join ' ')" }
  [pscustomobject]@{ Code=$Code; Output=@($Out) }
}

function SafeName {
  param([string]$Text)
  $Name = $Text -replace "[^\p{L}\p{Nd}\-_]+","_"
  $Name = $Name.Trim("_")
  if([string]::IsNullOrWhiteSpace($Name)){ $Name = "Unknown" }
  return $Name
}

function Is-UnderRoot {
  param([string]$Path,[string]$Root)
  if([string]::IsNullOrWhiteSpace($Path)){ return $false }
  $P=$Path.TrimEnd("\")
  $R=$Root.TrimEnd("\")
  if($P.Equals($R,[System.StringComparison]::OrdinalIgnoreCase)){ return $true }
  if($P.StartsWith($R + "\",[System.StringComparison]::OrdinalIgnoreCase)){ return $true }
  return $false
}

function Count-RootSafe {
  param([string]$Root,[string]$Label)
  $Exists = Test-Path -LiteralPath $Root
  $FilesSeen=0; $Jsonl=0; $Json=0; $Md=0; $Db=0; $SizeMB=0.0; $Err=""
  if($Exists){
    try {
      $Files=@(Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object -First 20000)
      $FilesSeen=$Files.Count
      $Jsonl=@($Files | Where-Object { $_.Extension -eq ".jsonl" }).Count
      $Json=@($Files | Where-Object { $_.Extension -eq ".json" }).Count
      $Md=@($Files | Where-Object { $_.Extension -eq ".md" }).Count
      $Db=@($Files | Where-Object { $_.Extension -in @(".db",".sqlite") }).Count
      $Sum=($Files | Measure-Object Length -Sum).Sum
      if($null -eq $Sum){ $Sum=0 }
      $SizeMB=[Math]::Round($Sum/1MB,2)
    } catch { $Err=$_.Exception.Message }
  }
  [pscustomobject]@{
    Label=$Label
    Root=$Root
    Exists=$Exists
    FilesSeenCapped=$FilesSeen
    Jsonl=$Jsonl
    Json=$Json
    Md=$Md
    Db=$Db
    SizeMBSeenCapped=$SizeMB
    Error=$Err
  }
}

function Invoke-RobocopySafe {
  param([string]$Source,[string]$Dest,[string]$LogPath)

  Ensure-Dir $Dest
  Ensure-Parent $LogPath

  $Args = @(
    $Source,
    $Dest,
    "/E",
    "/COPY:DAT",
    "/DCOPY:DAT",
    "/R:1",
    "/W:1",
    "/MT:8",
    "/XJ",
    "/FFT",
    "/NP",
    "/LOG+:$LogPath"
  )

  & robocopy @Args | Out-Null
  $Code = $LASTEXITCODE

  [pscustomobject]@{
    Ok = ($Code -le 7)
    Code = $Code
    Log = $LogPath
  }
}

function Add-SourceRow {
  param([object[]]$Rows,[string]$Label,[string]$Root,[string]$SourceType)
  if([string]::IsNullOrWhiteSpace($Root)){ return @($Rows) }
  $Rows += [pscustomobject]@{
    Label = $Label
    Root = $Root
    SourceType = $SourceType
  }
  return @($Rows)
}

function Add-ImmediateKeywordDirs {
  param([object[]]$Rows,[string]$Parent,[string]$Prefix)

  if(-not (Test-Path -LiteralPath $Parent)){ return @($Rows) }

  $Keywords = @(
    "Claude","Cloud","Codex","Code","Copilot","Cherry","ChatGPT","OpenAI",
    "Cursor","Windsurf","Continue","Cline","Roo","SpecStory","OmniRoute",
    "AI","LLM","Anthropic"
  )

  try {
    $Dirs = @(Get-ChildItem -LiteralPath $Parent -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 300)
    foreach($D in $Dirs){
      if(Is-UnderRoot $D.FullName $CommonRoot){ continue }
      if($D.FullName -ieq "J:\Setup_VcCode_Workspace"){ continue }

      foreach($K in $Keywords){
        if($D.Name -like "*$K*"){
          $Rows += [pscustomobject]@{
            Label = (SafeName ($Prefix + "_" + $D.Name))
            Root = $D.FullName
            SourceType = "dynamic-keyword"
          }
          break
        }
      }
    }
  } catch {}

  return @($Rows)
}

try {
  Ensure-Dir $AuditRoot
  Ensure-Dir $SourcesRoot
  Set-TextUtf8Bom $RunReport "# Auto local raw mirror run`r`n`r`nRun: $Stamp`r`nCyrillic: Общие чаты, кириллица, UTF-8`r`n"

  $LockStream = $null
  try {
    $LockStream = [System.IO.File]::Open($LockPath,[System.IO.FileMode]::OpenOrCreate,[System.IO.FileAccess]::ReadWrite,[System.IO.FileShare]::None)
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes("running $Stamp")
    $LockStream.SetLength(0)
    $LockStream.Write($Bytes,0,$Bytes.Length)
    $LockStream.Flush()
  } catch {
    Add-RunLine "Another auto mirror run is already active. Exit cleanly."
    exit 0
  }

  $Sources = @()

  $Sources = Add-SourceRow $Sources "Claude_User_claude_IgorK" "C:\Users\IgorK\.claude" "static"
  $Sources = Add-SourceRow $Sources "Codex_User_codex_IgorK" "C:\Users\IgorK\.codex" "static"
  $Sources = Add-SourceRow $Sources "Codex_HOME_LIVE" "J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE" "static"
  $Sources = Add-SourceRow $Sources "Claude_J_Config" "J:\ClaudeData\.claude" "static"
  $Sources = Add-SourceRow $Sources "Claude_J_Memory" "J:\ClaudeData\memory" "static"
  $Sources = Add-SourceRow $Sources "ClaudeHub" "J:\ClaudeHub" "static"

  $Sources = Add-SourceRow $Sources "ClaudeDesktop_Roaming" "C:\Users\IgorK\AppData\Roaming\Claude" "static"
  $Sources = Add-SourceRow $Sources "ClaudeDesktop_Local" "C:\Users\IgorK\AppData\Local\Claude" "static"

  $Sources = Add-SourceRow $Sources "CherryStudio_Roaming_NoSpace" "C:\Users\IgorK\AppData\Roaming\CherryStudio" "static"
  $Sources = Add-SourceRow $Sources "CherryStudio_Roaming_Space" "C:\Users\IgorK\AppData\Roaming\Cherry Studio" "static"
  $Sources = Add-SourceRow $Sources "CherryStudio_Local_NoSpace" "C:\Users\IgorK\AppData\Local\CherryStudio" "static"
  $Sources = Add-SourceRow $Sources "CherryStudio_Local_Space" "C:\Users\IgorK\AppData\Local\Cherry Studio" "static"

  $Sources = Add-SourceRow $Sources "ChatGPT_Roaming" "C:\Users\IgorK\AppData\Roaming\ChatGPT" "static"
  $Sources = Add-SourceRow $Sources "ChatGPT_Local" "C:\Users\IgorK\AppData\Local\ChatGPT" "static"
  $Sources = Add-SourceRow $Sources "OpenAI_Roaming" "C:\Users\IgorK\AppData\Roaming\OpenAI" "static"
  $Sources = Add-SourceRow $Sources "OpenAI_Local" "C:\Users\IgorK\AppData\Local\OpenAI" "static"

  $Sources = Add-SourceRow $Sources "VSCode_User_History" "C:\Users\IgorK\AppData\Roaming\Code\User\History" "static"
  $Sources = Add-SourceRow $Sources "VSCode_User_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage" "static"
  $Sources = Add-SourceRow $Sources "VSCode_User_WorkspaceStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\workspaceStorage" "static"

  $Sources = Add-SourceRow $Sources "Copilot_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\github.copilot" "static"
  $Sources = Add-SourceRow $Sources "CopilotChat_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\github.copilot-chat" "static"
  $Sources = Add-SourceRow $Sources "Continue_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\continue.continue" "static"
  $Sources = Add-SourceRow $Sources "Cline_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev" "static"
  $Sources = Add-SourceRow $Sources "Roo_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\rooveterinaryinc.roo-cline" "static"

  $Sources = Add-SourceRow $Sources "Cursor_User_History" "C:\Users\IgorK\AppData\Roaming\Cursor\User\History" "static"
  $Sources = Add-SourceRow $Sources "Cursor_User_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Cursor\User\globalStorage" "static"
  $Sources = Add-SourceRow $Sources "Cursor_User_WorkspaceStorage" "C:\Users\IgorK\AppData\Roaming\Cursor\User\workspaceStorage" "static"

  $Sources = Add-SourceRow $Sources "Windsurf_User_History" "C:\Users\IgorK\AppData\Roaming\Windsurf\User\History" "static"
  $Sources = Add-SourceRow $Sources "Windsurf_User_GlobalStorage" "C:\Users\IgorK\AppData\Roaming\Windsurf\User\globalStorage" "static"
  $Sources = Add-SourceRow $Sources "Windsurf_User_WorkspaceStorage" "C:\Users\IgorK\AppData\Roaming\Windsurf\User\workspaceStorage" "static"

  $Sources = Add-SourceRow $Sources "OmniRoute_FreeClaudeCode" "C:\OmniRoute_FreeClaudeCode" "static"

  $Sources = Add-ImmediateKeywordDirs $Sources "C:\Users\IgorK\AppData\Roaming" "Roaming"
  $Sources = Add-ImmediateKeywordDirs $Sources "C:\Users\IgorK\AppData\Local" "Local"
  $Sources = Add-ImmediateKeywordDirs $Sources "C:\Users\IgorK" "UserRoot"
  $Sources = Add-ImmediateKeywordDirs $Sources "J:\Setup_VcCode_Workspace" "JWorkspace"
  $Sources = Add-ImmediateKeywordDirs $Sources "J:\ClaudeData" "JClaudeData"
  $Sources = Add-ImmediateKeywordDirs $Sources "J:\" "JRoot"

  $Sources = @($Sources | Where-Object { $_ -ne $null -and -not [string]::IsNullOrWhiteSpace($_.Root) } | Sort-Object Root -Unique)

  $Rows=@()

  foreach($S in $Sources){
    $Label = SafeName $S.Label
    $Source = $S.Root
    $Target = Join-Path $SourcesRoot $Label
    $RoboLog = Join-Path $AuditRoot ("AUTO_ROBOCOPY_" + $Label + "_" + $Stamp + ".log")

    $Exists = Test-Path -LiteralPath $Source
    $UnderCommon = Is-UnderRoot $Source $CommonRoot
    $Action = "skipped"
    $RoboCode = ""
    $ErrorText = ""

    if(-not $Exists){
      $Action = "missing-source"
    } elseif($UnderCommon){
      $Action = "already-under-common-root-manifest-only"
    } else {
      try {
        $Robo = Invoke-RobocopySafe -Source $Source -Dest $Target -LogPath $RoboLog
        $RoboCode = $Robo.Code
        if($Robo.Ok){
          $Action = "copied-local-non-delete"
        } else {
          $Action = "robocopy-warning-or-failed"
          $ErrorText = "robocopy exit code $RoboCode; see $RoboLog"
        }
      } catch {
        $Action = "error"
        $ErrorText = $_.Exception.Message
      }
    }

    $Count = Count-RootSafe -Root $Source -Label $Label
    $TargetCount = Count-RootSafe -Root $Target -Label ($Label + "_target")

    $Rows += [pscustomobject]@{
      Label=$Label
      SourceType=$S.SourceType
      Source=$Source
      Target=$Target
      Exists=$Exists
      UnderCommonRoot=$UnderCommon
      Action=$Action
      RobocopyCode=$RoboCode
      SourceFilesSeenCapped=$Count.FilesSeenCapped
      SourceSizeMBSeenCapped=$Count.SizeMBSeenCapped
      TargetFilesSeenCapped=$TargetCount.FilesSeenCapped
      TargetSizeMBSeenCapped=$TargetCount.SizeMBSeenCapped
      Log=$RoboLog
      Error=$ErrorText
    }
  }

  Ensure-Parent $RunCsv
  $Rows | Export-Csv -LiteralPath $RunCsv -NoTypeInformation -Encoding UTF8

  Ensure-Parent $ManifestCsv
  $Rows | Export-Csv -LiteralPath $ManifestCsv -NoTypeInformation -Encoding UTF8

  $Now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $RowsText = ($Rows | ForEach-Object {
    "- $($_.Label): type=$($_.SourceType), action=$($_.Action), rc=$($_.RobocopyCode), source=$($_.Source), target=$($_.Target)"
  }) -join "`r`n"

  $ManifestText = @"
# AI Chat Auto Local Raw Mirror Manifest

Last run: $Now

Mode: auto local raw mirror.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## Safety

- No deletion.
- No move.
- No raw GitHub push.
- No Git LFS.
- Originals stay in place.
- Copy uses robocopy /E, not /MIR.
- Dynamic discovery scans known AI/app roots and keyword folders.

## Rows

$RowsText
"@

  $LastRunText = @"
# AI Chat Auto Local Raw Mirror Last Run

Last run: $Now

Result: auto local raw mirror worker completed.

Raw files were copied only to local common root:
$SourcesRoot

No raw chats were pushed to GitHub.
No files were deleted.
No originals were moved.

Local run report:
$RunReport

Local run CSV:
$RunCsv
"@

  Set-TextUtf8Bom $ManifestDoc $ManifestText
  Set-TextUtf8Bom $LastRunDoc $LastRunText

  $Inside = Run-Git -GitArgs @("-C",$Repo,"rev-parse","--is-inside-work-tree") -AllowFail
  if($Inside.Code -eq 0){
    $StatusObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"status","--porcelain","--untracked-files=all") -AllowFail
    $Dirty = @(Get-GitStatusFiles $StatusObj.Output)
    $UnexpectedDirty = @($Dirty | Where-Object { $_ -notin $AllowedRel })

    if($UnexpectedDirty.Count -eq 0){
      Run-Git -GitArgs @("-C",$Repo,"add","-f","--",$ManifestRel,$ManifestCsvRel,$LastRunRel) -AllowFail | Out-Null
      $StagedObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"diff","--cached","--name-only") -AllowFail
      $Staged = @($StagedObj.Output | ForEach-Object { Normalize-GitPath $_ })

      if($Staged.Count -gt 0){
        Run-Git -GitArgs @("-C",$Repo,"commit","-m","Update auto local raw mirror manifest") -AllowFail | Out-Null
        Run-Git -GitArgs @("-C",$Repo,"push","origin","main") -AllowFail | Out-Null
      }
    } else {
      Add-RunLine "Git manifest commit skipped because repo has unexpected dirty files:"
      foreach($D in $UnexpectedDirty){ Add-RunLine "- $D" }
    }
  }

  if($LockStream){ $LockStream.Close() }
  exit 0

} catch {
  $Err=$_.Exception.Message
  $FailLog=Join-Path $AuditRoot ("AUTO_LOCAL_RAW_MIRROR_FAILED_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".md")
  Set-TextUtf8Bom $FailLog "# Auto local raw mirror failed`r`n`r`n$Err"
  if($LockStream){ $LockStream.Close() }
  exit 1
}