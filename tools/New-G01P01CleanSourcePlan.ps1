$ErrorActionPreference = "Continue"

$Repo="J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$AuditRoot="J:\_AI_CHATS_ОБЩИЕ\_AUDIT"
$Project="J:\ПРОЕКТЫ\G01_All_About_Trading\G01_P01_PocketOption"
$Target="J:\Setup_VcCode_Workspace\S20_Projects\G01_P01_PocketOption_CleanSource"
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"

$Csv="$AuditRoot\G01_P01_STRICT_CLEANSOURCE_PLAN_$Stamp.csv"
$Report="$AuditRoot\G01_P01_STRICT_CLEANSOURCE_PLAN_$Stamp.md"

New-Item -ItemType Directory -Force $AuditRoot | Out-Null

$ApprovedRoots=@(
  "G01_P01_02_Project_Settings\G01_P01_02_09_Tools\G01_P01_02_09_01_PROJECT_SKILLS",
  "G01_P01_02_Project_Settings\G01_P01_02_09_Tools\G01_P01_02_09_04_Automation_Scripts"
)

$ApprovedExtensions=@(
  ".ps1",".py",".js",".ts",".css",".html",".htm",".md",".txt",".json",".csv",".yaml",".yml",".xml",".svg"
)

$BlockPathPattern="(?i)(\\chrome_profile\\|\\Cache\\|\\Code Cache\\|\\GPUCache\\|\\IndexedDB\\|\\Local Storage\\|\\Session Storage\\|\\Extension State\\|\\Network\\|\\WebStorage\\|\\Sync Data\\|\\TrustTokenKeyCommitments\\|\\G01_P01_02_05_AI_Memory\\|\\G01_P01_02_06_Data\\|\\G01_P01_02_07_Results\\|\\G01_P01_02_08_Logs\\|\\G01_P01_02_10_Tech\\|\\G01_P01_02_03_05_API_Keys_And_IDs\\|\\G01_P01_02_03_06_External_Memory\\|\\NotebookLM_Staging\\|\\10_Артефакты\\|\\paper_scanner\\|\\shadow\\|\\runtime_common\\|\\node_modules\\|\\__pycache__\\|\\.venv\\|\\.git\\)"
$BlockExtPattern="(?i)\.(jsonl|sqlite|db|log|exe|msi|msix|dmg|zip|7z|rar|mp4|mov|avi|webm|mp3|pdf|download|tmp|cache|dat|bin|pma|tflite|pt|wasm)$"
$SecretPattern="(?i)(credential|credentials|secret|token|password|api[_-]?key|private[_-]?key|\.env|cookie|session|localstorage|indexeddb)"

$Rows=New-Object System.Collections.Generic.List[object]

if(Test-Path -LiteralPath $Project){
  Get-ChildItem -LiteralPath $Project -File -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $rel=$_.FullName.Substring($Project.Length).TrimStart("\")
    $rootOk=$false

    foreach($r in $ApprovedRoots){
      if($rel -eq $r -or $rel.StartsWith($r + "\")){
        $rootOk=$true
        break
      }
    }

    $extLower=$_.Extension.ToLowerInvariant()
    $extOk=$ApprovedExtensions -contains $extLower
    $blockedPath=$_.FullName -match $BlockPathPattern
    $blockedExt=$_.Extension -match $BlockExtPattern
    $secretLike=$rel -match $SecretPattern
    $tooLarge=$_.Length -gt 10MB

    $approved=($rootOk -and $extOk -and -not $blockedPath -and -not $blockedExt -and -not $secretLike -and -not $tooLarge)

    $reason=@()
    if(-not $rootOk){$reason+="ROOT_NOT_APPROVED"}
    if(-not $extOk){$reason+="EXT_NOT_APPROVED"}
    if($blockedPath){$reason+="BLOCKED_PATH"}
    if($blockedExt){$reason+="BLOCKED_EXT"}
    if($secretLike){$reason+="SECRET_LIKE"}
    if($tooLarge){$reason+="OVER_10MB"}

    $targetPath=Join-Path $Target $rel

    $Rows.Add([pscustomobject]@{
      Approved=$approved
      RelativePath=$rel
      SourcePath=$_.FullName
      TargetPath=$targetPath
      Extension=$_.Extension
      MB=[math]::Round($_.Length/1MB,4)
      LastWriteTime=$_.LastWriteTime
      Reason=($reason -join ";")
    }) | Out-Null
  }
}

$ApprovedRows=$Rows | Where-Object {$_.Approved}
$RejectedRows=$Rows | Where-Object {-not $_.Approved}

$ApprovedRows | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8

$collisionCount=($ApprovedRows | Group-Object TargetPath | Where-Object {$_.Count -gt 1}).Count
$missingSourceCount=($ApprovedRows | Where-Object {-not (Test-Path -LiteralPath $_.SourcePath)}).Count
$over10Count=($ApprovedRows | Where-Object {$_.MB -gt 10}).Count
$totalMb=[math]::Round((($ApprovedRows | Measure-Object MB -Sum).Sum),4)

"# G01 P01 Strict Clean Source Plan" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"READ ONLY. No files copied. No files moved. No delete. No git init. No commit. No push." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

"## Output files" | Add-Content -LiteralPath $Report -Encoding UTF8
"- CSV: $Csv" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Summary" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Source: $Project" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Future target: $Target" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Approved files: $($ApprovedRows.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Approved MB: $totalMb" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Rejected files: $($RejectedRows.Count)" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Target collisions: $collisionCount" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Missing approved sources: $missingSourceCount" | Add-Content -LiteralPath $Report -Encoding UTF8
"- Approved files over 10 MB: $over10Count" | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Approved by extension" | Add-Content -LiteralPath $Report -Encoding UTF8
$ApprovedRows |
  Group-Object Extension |
  ForEach-Object {
    [pscustomobject]@{
      Extension=$_.Name
      Files=$_.Count
      MB=[math]::Round((($_.Group | Measure-Object MB -Sum).Sum),4)
    }
  } |
  Sort-Object MB -Descending |
  Format-Table -AutoSize |
  Out-String -Width 1000 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Approved files" | Add-Content -LiteralPath $Report -Encoding UTF8
$ApprovedRows |
  Sort-Object RelativePath |
  Select-Object RelativePath,Extension,MB,LastWriteTime |
  Format-Table -AutoSize |
  Out-String -Width 1800 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Rejected reason summary" | Add-Content -LiteralPath $Report -Encoding UTF8
$RejectedRows |
  Group-Object Reason |
  Sort-Object Count -Descending |
  Select-Object Count,Name |
  Format-Table -AutoSize |
  Out-String -Width 1800 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Rejected top 80 largest" | Add-Content -LiteralPath $Report -Encoding UTF8
$RejectedRows |
  Sort-Object MB -Descending |
  Select-Object -First 80 RelativePath,Extension,MB,Reason,LastWriteTime |
  Format-Table -AutoSize |
  Out-String -Width 2200 |
  Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Decision" | Add-Content -LiteralPath $Report -Encoding UTF8
"- This is a strict CSV plan only." | Add-Content -LiteralPath $Report -Encoding UTF8
"- It is not approval to copy." | Add-Content -LiteralPath $Report -Encoding UTF8
"- Next step: review approved file count/MB and create copy dry-run only if reasonable." | Add-Content -LiteralPath $Report -Encoding UTF8

Write-Host "CSV:" -ForegroundColor Green
Write-Host $Csv
Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 220
