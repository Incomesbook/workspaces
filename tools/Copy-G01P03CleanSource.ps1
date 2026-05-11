param(
  [switch]$Execute
)

$ErrorActionPreference = "Stop"

$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Target="J:\Setup_VcCode_Workspace\S20_Projects\G01_P03_MarketAgent_CleanSource"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$Report="$AuditRoot\G01_P03_COPY_EXECUTION_$Stamp.md"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

$Csv = Get-ChildItem -LiteralPath $AuditRoot -File -Filter "G01_P03_STRICT_CLEANSOURCE_PLAN_*.csv" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

"# G01 P03 Clean Source Copy Execution" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"Mode: $(if($Execute){'EXECUTE COPY'}else{'DRY RUN ONLY'})" | Add-Content -LiteralPath $Report -Encoding UTF8
"No delete. No git init. No commit inside target. No push of target." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

if(-not $Csv){
  "ERROR: No strict clean-source CSV plan found in $AuditRoot" | Add-Content -LiteralPath $Report -Encoding UTF8
  Write-Host "REPORT:" -ForegroundColor Red
  Write-Host $Report
  Get-Content -LiteralPath $Report -Tail 80
  exit 1
}

$Rows = Import-Csv -LiteralPath $Csv.FullName

$missing = @()
$badTarget = @()
$existingDifferent = @()
$existingSame = @()
$copied = @()
$wouldCopy = @()

foreach($r in $Rows){
  if(-not (Test-Path -LiteralPath $r.SourcePath)){
    $missing += $r
    continue
  }

  if($r.TargetPath -notlike "$Target*"){
    $badTarget += $r
    continue
  }

  $src = Get-Item -LiteralPath $r.SourcePath
  if(Test-Path -LiteralPath $r.TargetPath){
    $dst = Get-Item -LiteralPath $r.TargetPath
    if($dst.Length -eq $src.Length){
      $existingSame += $r
    } else {
      $existingDifferent += [pscustomobject]@{
        RelativePath=$r.RelativePath
        SourceMB=[math]::Round($src.Length/1MB,4)
        TargetMB=[math]::Round($dst.Length/1MB,4)
        TargetPath=$r.TargetPath
      }
    }
  } else {
    $wouldCopy += $r
  }
}

$gateOk = ($missing.Count -eq 0 -and $badTarget.Count -eq 0 -and $existingDifferent.Count -eq 0)

"## Inputs" | Add-Content -LiteralPath $Report -Encoding UTF8
"- CSV: $($Csv.FullName)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Target: $Target" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Pre-copy gate" | Add-Content -LiteralPath $Report -Encoding UTF8
"- CSV rows: $($Rows.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Would copy: $($wouldCopy.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Missing sources: $($missing.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Bad target paths: $($badTarget.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Existing same-size files: $($existingSame.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Existing different-size files: $($existingDifferent.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Gate OK: $gateOk" | Add-Content -LiteralPath $Report -Encoding UTF8

if(-not $gateOk){
  "`n## Decision" | Add-Content -LiteralPath $Report -Encoding UTF8
  "- ABORT: gate failed. No files copied." | Add-Content -LiteralPath $Report -Encoding UTF8
  Write-Host "REPORT:" -ForegroundColor Red
  Write-Host $Report
  Get-Content -LiteralPath $Report -Tail 160
  exit 1
}

if($Execute){
  foreach($r in $wouldCopy){
    $dir = Split-Path -Parent $r.TargetPath
    New-Item -ItemType Directory -Force $dir | Out-Null
    Copy-Item -LiteralPath $r.SourcePath -Destination $r.TargetPath -Force
    $copied += $r
  }
}

"`n## Copy result" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Execute flag: $Execute" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Copied files: $($copied.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Existing same-size skipped: $($existingSame.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Target exists after run: $(Test-Path -LiteralPath $Target)" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Files copied or would copy" | Add-Content -LiteralPath $Report -Encoding UTF8
$wouldCopy |
  Select-Object RelativePath,Extension,MB,SourcePath,TargetPath |
  Format-Table -AutoSize |
  Out-String -Width 1800 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Decision" | Add-Content -LiteralPath $Report -Encoding UTF8
if($Execute){
  "- COPY EXECUTED: only approved clean-source files were copied." | Add-Content -LiteralPath $Report -Encoding UTF8
} else {
  "- DRY RUN ONLY: no files copied." | Add-Content -LiteralPath $Report -Encoding UTF8
}

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 180
