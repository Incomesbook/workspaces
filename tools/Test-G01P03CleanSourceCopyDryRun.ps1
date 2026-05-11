$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Target="J:\Setup_VcCode_Workspace\S20_Projects\G01_P03_MarketAgent_CleanSource"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"
$Report="$AuditRoot\G01_P03_COPY_DRYRUN_$Stamp.md"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

$Csv = Get-ChildItem -LiteralPath $AuditRoot -File -Filter "G01_P03_STRICT_CLEANSOURCE_PLAN_*.csv" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

"# G01 P03 Clean Source Copy Dry-Run" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"READ ONLY. No files copied. No directories created. No delete. No git init. No commit. No push." | Add-Content -LiteralPath $Report -Encoding UTF8
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
$existingSame = @()
$existingDifferent = @()
$wouldCopy = @()
$badTarget = @()

foreach($r in $Rows){
  if(-not (Test-Path -LiteralPath $r.SourcePath)){
    $missing += $r
    continue
  }

  if($r.TargetPath -notlike "$Target*"){
    $badTarget += $r
    continue
  }

  $src = Get-Item -LiteralPath $r.SourcePath -ErrorAction SilentlyContinue
  if(Test-Path -LiteralPath $r.TargetPath){
    $dst = Get-Item -LiteralPath $r.TargetPath -ErrorAction SilentlyContinue
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

$totalMb = [math]::Round((($wouldCopy | Measure-Object MB -Sum).Sum),4)

"## Inputs" | Add-Content -LiteralPath $Report -Encoding UTF8
"- CSV: $($Csv.FullName)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Target: $Target" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Dry-run summary" | Add-Content -LiteralPath $Report -Encoding UTF8
"- CSV rows: $($Rows.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Would copy: $($wouldCopy.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Would copy MB: $totalMb" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Missing sources: $($missing.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Bad target paths: $($badTarget.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Existing same-size files: $($existingSame.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Existing different-size files: $($existingDifferent.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Would copy files" | Add-Content -LiteralPath $Report -Encoding UTF8
$wouldCopy |
  Select-Object RelativePath,Extension,MB,SourcePath,TargetPath |
  Format-Table -AutoSize |
  Out-String -Width 1600 |
  Add-Content -LiteralPath $Report -Encoding UTF8

if($missing.Count -gt 0){
  "`n## Missing sources" | Add-Content -LiteralPath $Report -Encoding UTF8
  $missing | Select-Object RelativePath,SourcePath | Format-Table -AutoSize | Out-String -Width 1600 | Add-Content -LiteralPath $Report -Encoding UTF8
}

if($badTarget.Count -gt 0){
  "`n## Bad target paths" | Add-Content -LiteralPath $Report -Encoding UTF8
  $badTarget | Select-Object RelativePath,TargetPath | Format-Table -AutoSize | Out-String -Width 1600 | Add-Content -LiteralPath $Report -Encoding UTF8
}

if($existingDifferent.Count -gt 0){
  "`n## Existing different-size files" | Add-Content -LiteralPath $Report -Encoding UTF8
  $existingDifferent | Format-Table -AutoSize | Out-String -Width 1600 | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Decision" | Add-Content -LiteralPath $Report -Encoding UTF8
if($missing.Count -eq 0 -and $badTarget.Count -eq 0 -and $existingDifferent.Count -eq 0){
  "- DRY-RUN OK: copy execution can be considered next, but is not performed by this script." | Add-Content -LiteralPath $Report -Encoding UTF8
} else {
  "- DRY-RUN NOT OK: fix issues before any copy execution." | Add-Content -LiteralPath $Report -Encoding UTF8
}

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 180
