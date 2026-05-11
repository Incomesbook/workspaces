param(
  [string]$CsvPath = "",
  [string]$TargetRoot = "J:\Setup_VcCode_Workspace\S20_Projects\LiveControl_CleanSource",
  [switch]$Execute
)

$ErrorActionPreference = "Continue"

$AuditRoot = "J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Report = Join-Path $AuditRoot "LIVECONTROL_CLEAN_SOURCE_COPY_DRYRUN_$Stamp.md"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

function Add-Line {
  param([string]$Text = "")
  Add-Content -LiteralPath $Report -Value $Text -Encoding UTF8
}

"# LiveControl Clean Source Copy Check" | Set-Content -LiteralPath $Report -Encoding UTF8
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Mode: $(if($Execute.IsPresent){'EXECUTE COPY'}else{'DRY RUN ONLY'})"
Add-Line "TargetRoot: $TargetRoot"
Add-Line ""

if([string]::IsNullOrWhiteSpace($CsvPath)){
  $Latest = Get-ChildItem $AuditRoot -Filter "LIVECONTROL_SOURCE_COPY_PLAN_*.csv" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if($Latest){
    $CsvPath = $Latest.FullName
  }
}

Add-Line "CSV: $CsvPath"

if(-not (Test-Path -LiteralPath $CsvPath)){
  Add-Line ""
  Add-Line "ERROR: CSV not found."
  Write-Host "ERROR: CSV not found. Report:" -ForegroundColor Red
  Write-Host $Report
  Get-Content -LiteralPath $Report
  exit 1
}

if($TargetRoot -notlike "J:\Setup_VcCode_Workspace\S20_Projects\LiveControl_CleanSource*"){
  Add-Line ""
  Add-Line "ERROR: TargetRoot is outside approved LiveControl_CleanSource path."
  Write-Host "ERROR: TargetRoot outside approved path. Report:" -ForegroundColor Red
  Write-Host $Report
  exit 1
}

$Rows = Import-Csv -LiteralPath $CsvPath

Add-Line ""
Add-Line "## Summary"
Add-Line "- Rows: $($Rows.Count)"

$MissingSource = @()
$Over10MB = @()
$BadTarget = @()
$WouldCopy = @()
$ExistingSame = @()
$ExistingDifferent = @()

foreach($Row in $Rows){
  $src = $Row.SourcePath
  $dst = $Row.FutureTargetPath

  if(-not (Test-Path -LiteralPath $src)){
    $MissingSource += $Row
    continue
  }

  $item = Get-Item -LiteralPath $src -ErrorAction SilentlyContinue

  if($item.Length -gt 10MB){
    $Over10MB += [pscustomobject]@{
      SourcePath=$src
      FutureTargetPath=$dst
      MB=[math]::Round($item.Length/1MB,4)
    }
    continue
  }

  if($dst -notlike "$TargetRoot*"){
    $BadTarget += $Row
    continue
  }

  if(Test-Path -LiteralPath $dst){
    $dstItem = Get-Item -LiteralPath $dst -ErrorAction SilentlyContinue
    if($dstItem.Length -eq $item.Length){
      $ExistingSame += $Row
    } else {
      $ExistingDifferent += [pscustomobject]@{
        SourcePath=$src
        FutureTargetPath=$dst
        SourceMB=[math]::Round($item.Length/1MB,4)
        ExistingTargetMB=[math]::Round($dstItem.Length/1MB,4)
      }
    }
  } else {
    $WouldCopy += [pscustomobject]@{
      SourcePath=$src
      FutureTargetPath=$dst
      MB=[math]::Round($item.Length/1MB,4)
    }
  }
}

$TotalMB = ($WouldCopy | Measure-Object -Property MB -Sum).Sum
Add-Line "- Would copy files: $($WouldCopy.Count)"
Add-Line "- Would copy MB: $([math]::Round($TotalMB,2))"
Add-Line "- Missing sources: $($MissingSource.Count)"
Add-Line "- Over 10 MB blocked: $($Over10MB.Count)"
Add-Line "- Bad target paths: $($BadTarget.Count)"
Add-Line "- Existing same-size target files: $($ExistingSame.Count)"
Add-Line "- Existing different-size target files: $($ExistingDifferent.Count)"

Add-Line ""
Add-Line "## Safety gate"

$Abort = $false

if($MissingSource.Count -gt 0){
  Add-Line "- ABORT: missing source files found."
  $Abort = $true
}
if($Over10MB.Count -gt 0){
  Add-Line "- ABORT: files over 10 MB found."
  $Abort = $true
}
if($BadTarget.Count -gt 0){
  Add-Line "- ABORT: bad target paths found."
  $Abort = $true
}
if($ExistingDifferent.Count -gt 0){
  Add-Line "- ABORT: existing different-size target files found."
  $Abort = $true
}

if(-not $Abort){
  Add-Line "- OK: safety gate passed."
}

Add-Line ""
Add-Line "## Largest files that would copy"
$WouldCopy |
  Sort-Object MB -Descending |
  Select-Object -First 50 SourcePath,FutureTargetPath,MB |
  Format-Table -AutoSize |
  Out-String -Width 1200 |
  Add-Content -LiteralPath $Report -Encoding UTF8

Add-Line ""
Add-Line "## Root distribution"
$WouldCopy | ForEach-Object {
  $rel = $_.FutureTargetPath.Substring($TargetRoot.Length).TrimStart("\")
  $root = ($rel -split "\\")[0]
  [pscustomobject]@{Root=$root;MB=$_.MB}
} | Group-Object Root | ForEach-Object {
  [pscustomobject]@{
    Root=$_.Name
    Files=$_.Count
    MB=[math]::Round((($_.Group | Measure-Object -Property MB -Sum).Sum),2)
  }
} | Sort-Object MB -Descending | Format-Table -AutoSize | Out-String -Width 800 | Add-Content -LiteralPath $Report -Encoding UTF8

if(-not $Execute.IsPresent){
  Add-Line ""
  Add-Line "## Result"
  Add-Line "- DRY RUN ONLY."
  Add-Line "- No files copied."
  Add-Line "- No folders created."
  Add-Line "- No files deleted."
  Add-Line "- No Git changes."
  Add-Line "- To actually copy later, run this script with -Execute only after approval."
  Write-Host "REPORT:" -ForegroundColor Green
  Write-Host $Report
  Get-Content -LiteralPath $Report -Tail 180
  exit 0
}

if($Abort){
  Add-Line ""
  Add-Line "## Result"
  Add-Line "- EXECUTE BLOCKED by safety gate."
  Write-Host "EXECUTE BLOCKED. Report:" -ForegroundColor Red
  Write-Host $Report
  Get-Content -LiteralPath $Report -Tail 180
  exit 1
}

Add-Line ""
Add-Line "## Execute copy"
foreach($Item in $WouldCopy){
  $destDir = Split-Path $Item.FutureTargetPath -Parent
  New-Item -ItemType Directory -Force $destDir | Out-Null
  Copy-Item -LiteralPath $Item.SourcePath -Destination $Item.FutureTargetPath -Force:$false
}

Add-Line "- Copied files: $($WouldCopy.Count)"
Add-Line "- Copied MB: $([math]::Round($TotalMB,2))"

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 180
