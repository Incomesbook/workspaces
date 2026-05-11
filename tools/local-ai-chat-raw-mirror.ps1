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
$BackupsRoot = Join-Path $CommonRoot "_BACKUPS_BEFORE_OVERWRITE"

$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$RunReport = Join-Path $AuditRoot "LOCAL_RAW_MIRROR_RUN_$Stamp.md"
$RunCsv = Join-Path $AuditRoot "LOCAL_RAW_MIRROR_RUN_$Stamp.csv"

$ManifestRel = "04_MANIFESTS/AI_CHAT_LOCAL_RAW_MIRROR_MANIFEST.md"
$ManifestCsvRel = "04_MANIFESTS/AI_CHAT_LOCAL_RAW_MIRROR_MANIFEST.csv"
$LastRunRel = "00_START_HERE/AI_CHAT_LOCAL_RAW_MIRROR_LAST_RUN.md"

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

function Run-Git {
  param([string[]]$GitArgs,[switch]$AllowFail)
  $Out = @(& git @GitArgs 2>&1)
  $Code = $LASTEXITCODE
  Add-RunLine "git $($GitArgs -join ' ')"
  foreach($Line in $Out){ Add-RunLine $Line }
  if($Code -ne 0 -and -not $AllowFail){
    throw "Git failed with code $Code : git $($GitArgs -join ' ')"
  }
  [pscustomobject]@{ Code=$Code; Output=@($Out) }
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

try {
  Ensure-Dir $AuditRoot
  Ensure-Dir $SourcesRoot
  Ensure-Dir $BackupsRoot

  Set-TextUtf8Bom $RunReport "# Local raw mirror run`r`n`r`nRun: $Stamp`r`nCyrillic: Общие чаты, кириллица, UTF-8`r`n"

  $Sources = @(
    @{ Label="Claude_User_claude_IgorK"; Root="C:\Users\IgorK\.claude" },
    @{ Label="Codex_User_codex_IgorK"; Root="C:\Users\IgorK\.codex" },
    @{ Label="Codex_HOME_LIVE"; Root="J:\Setup_VcCode_Workspace\_AI_CHATS_ОБЩИЕ\CODEX\_LIVE" },
    @{ Label="Claude_J_Config"; Root="J:\ClaudeData\.claude" },
    @{ Label="Claude_J_Memory"; Root="J:\ClaudeData\memory" },
    @{ Label="ClaudeHub"; Root="J:\ClaudeHub" },
    @{ Label="ClaudeDesktop_Roaming"; Root="C:\Users\IgorK\AppData\Roaming\Claude" },
    @{ Label="ClaudeDesktop_Local"; Root="C:\Users\IgorK\AppData\Local\Claude" },
    @{ Label="CherryStudio_Roaming_NoSpace"; Root="C:\Users\IgorK\AppData\Roaming\CherryStudio" },
    @{ Label="CherryStudio_Roaming_Space"; Root="C:\Users\IgorK\AppData\Roaming\Cherry Studio" },
    @{ Label="CherryStudio_Local_NoSpace"; Root="C:\Users\IgorK\AppData\Local\CherryStudio" },
    @{ Label="CherryStudio_Local_Space"; Root="C:\Users\IgorK\AppData\Local\Cherry Studio" },
    @{ Label="ChatGPT_Roaming"; Root="C:\Users\IgorK\AppData\Roaming\ChatGPT" },
    @{ Label="ChatGPT_Local"; Root="C:\Users\IgorK\AppData\Local\ChatGPT" },
    @{ Label="OpenAI_Roaming"; Root="C:\Users\IgorK\AppData\Roaming\OpenAI" },
    @{ Label="OpenAI_Local"; Root="C:\Users\IgorK\AppData\Local\OpenAI" },
    @{ Label="VSCode_User_History"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\History" },
    @{ Label="VSCode_User_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage" },
    @{ Label="VSCode_User_WorkspaceStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\workspaceStorage" },
    @{ Label="Copilot_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\github.copilot" },
    @{ Label="CopilotChat_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\github.copilot-chat" },
    @{ Label="Continue_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\continue.continue" },
    @{ Label="Cline_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev" },
    @{ Label="Roo_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Code\User\globalStorage\rooveterinaryinc.roo-cline" },
    @{ Label="Cursor_User_History"; Root="C:\Users\IgorK\AppData\Roaming\Cursor\User\History" },
    @{ Label="Cursor_User_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Cursor\User\globalStorage" },
    @{ Label="Cursor_User_WorkspaceStorage"; Root="C:\Users\IgorK\AppData\Roaming\Cursor\User\workspaceStorage" },
    @{ Label="Windsurf_User_History"; Root="C:\Users\IgorK\AppData\Roaming\Windsurf\User\History" },
    @{ Label="Windsurf_User_GlobalStorage"; Root="C:\Users\IgorK\AppData\Roaming\Windsurf\User\globalStorage" },
    @{ Label="Windsurf_User_WorkspaceStorage"; Root="C:\Users\IgorK\AppData\Roaming\Windsurf\User\workspaceStorage" },
    @{ Label="OmniRoute_FreeClaudeCode"; Root="C:\OmniRoute_FreeClaudeCode" }
  )

  $Rows=@()

  foreach($S in $Sources){
    $Label = SafeName $S.Label
    $Source = $S.Root
    $Target = Join-Path $SourcesRoot $Label
    $RoboLog = Join-Path $AuditRoot ("ROBOCOPY_" + $Label + "_" + $Stamp + ".log")

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
    "- $($_.Label): action=$($_.Action), rc=$($_.RobocopyCode), source=$($_.Source), target=$($_.Target)"
  }) -join "`r`n"

  $ManifestText = @"
# AI Chat Local Raw Mirror Manifest

Last run: $Now

Mode: local raw mirror only.

Cyrillic check: Общие чаты, кириллица, UTF-8.

## Safety

- No deletion.
- No move.
- No raw GitHub push.
- No Git LFS.
- Originals stay in place.
- Copy uses robocopy /E, not /MIR.

## Rows

$RowsText
"@

  $LastRunText = @"
# AI Chat Local Raw Mirror Last Run

Last run: $Now

Result: local raw mirror worker completed.

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
    Run-Git -GitArgs @("-C",$Repo,"add","-f","--",$ManifestRel,$ManifestCsvRel,$LastRunRel) -AllowFail | Out-Null
    $StagedObj = Run-Git -GitArgs @("--no-pager","-C",$Repo,"diff","--cached","--name-only") -AllowFail
    $Staged = @($StagedObj.Output | ForEach-Object { Normalize-GitPath $_ })

    if($Staged.Count -gt 0){
      Run-Git -GitArgs @("-C",$Repo,"commit","-m","Update local raw mirror manifest") -AllowFail | Out-Null
      Run-Git -GitArgs @("-C",$Repo,"push","origin","main") -AllowFail | Out-Null
    }
  }

  exit 0

} catch {
  $Err=$_.Exception.Message
  $FailLog=Join-Path $AuditRoot ("LOCAL_RAW_MIRROR_FAILED_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".md")
  Set-TextUtf8Bom $FailLog "# Local raw mirror failed`r`n`r`n$Err"
  exit 1
}