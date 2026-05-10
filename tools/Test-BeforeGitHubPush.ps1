$ErrorActionPreference = "Continue"

$Repo = "J:\Setup_VcCode_Workspace\S10_GitHub\workspaces"
$OutDir = Join-Path $Repo "02_PROJECTS_INDEX"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Report = Join-Path $OutDir "PRE_PUSH_SAFETY_CHECK_$Stamp.md"

New-Item -ItemType Directory -Force $OutDir | Out-Null

"# Pre-Push Safety Check" | Set-Content -LiteralPath $Report -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content -LiteralPath $Report -Encoding UTF8
"READ ONLY. No push. No pull. No delete." | Add-Content -LiteralPath $Report -Encoding UTF8
"" | Add-Content -LiteralPath $Report -Encoding UTF8

"## Git status" | Add-Content -LiteralPath $Report -Encoding UTF8
git --no-pager -C $Repo status --short --branch | Add-Content -LiteralPath $Report -Encoding UTF8

"`n## Local commits not pushed to origin/main" | Add-Content -LiteralPath $Report -Encoding UTF8
if (git -C $Repo rev-parse --verify origin/main 2>$null) { git --no-pager -C $Repo log --oneline origin/main..HEAD 2>&1 | Add-Content -LiteralPath $Report -Encoding UTF8 } else { "- origin/main is not available locally yet. Run fetch later before final push check." | Add-Content -LiteralPath $Report -Encoding UTF8 }

"`n## Tracked files over 50 MB" | Add-Content -LiteralPath $Report -Encoding UTF8
$tracked = git -C $Repo ls-files
$largeFound = $false
foreach ($f in $tracked) {
  $full = Join-Path $Repo $f
  if (Test-Path -LiteralPath $full) {
    $item = Get-Item -LiteralPath $full
    if ($item.Length -gt 50MB) {
      $largeFound = $true
      "- $f | $([math]::Round($item.Length / 1MB, 2)) MB" | Add-Content -LiteralPath $Report -Encoding UTF8
    }
  }
}
if (-not $largeFound) {
  "- OK: no tracked files over 50 MB" | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Suspicious tracked filenames" | Add-Content -LiteralPath $Report -Encoding UTF8
$nameHits = $tracked | Where-Object { $_ -match "(?i)(\.env|api[_-]?key|secret|token|password|credential|private[_-]?key)" }
if ($nameHits) {
  $nameHits | ForEach-Object { "- $_" | Add-Content -LiteralPath $Report -Encoding UTF8 }
} else {
  "- OK: no suspicious tracked filenames" | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Possible secret keyword hits in tracked text files" | Add-Content -LiteralPath $Report -Encoding UTF8
$pattern = "(?i)(api[_-]?key|secret|token|password|credential|private[_-]?key|BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY|BEGIN PRIVATE KEY)"
$hitCount = 0
foreach ($f in $tracked) {
  $full = Join-Path $Repo $f
  if (Test-Path -LiteralPath $full) {
    $ext = [IO.Path]::GetExtension($full)
    if ($ext -in ".md",".txt",".json",".ps1",".cmd",".bat",".gitignore",".gitattributes",".code-workspace") {
      Select-String -LiteralPath $full -Pattern $pattern -ErrorAction SilentlyContinue | Select-Object -First 20 | ForEach-Object {
        $hitCount++
        "- $f : line $($_.LineNumber) : $($_.Line.Trim())" | Add-Content -LiteralPath $Report -Encoding UTF8
      }
    }
  }
}
if ($hitCount -eq 0) {
  "- OK: no obvious secret keywords found in tracked text files" | Add-Content -LiteralPath $Report -Encoding UTF8
} else {
  "- REVIEW REQUIRED: keyword hits found above. Some may be false positives from README/.gitignore policy text." | Add-Content -LiteralPath $Report -Encoding UTF8
}

"`n## Result" | Add-Content -LiteralPath $Report -Encoding UTF8
"- No GitHub push was performed." | Add-Content -LiteralPath $Report -Encoding UTF8
"- Review this report before any push." | Add-Content -LiteralPath $Report -Encoding UTF8

Write-Host "REPORT:" -ForegroundColor Green
Write-Host $Report
Get-Content -LiteralPath $Report -Tail 120

