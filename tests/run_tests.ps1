# Vefna test suite (Windows). Run from the project root:
#   powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1 [path\to\vefna.exe]
param([string]$Vefna = "build\vefna.exe")

$ErrorActionPreference = "SilentlyContinue"
$Vefna = (Resolve-Path $Vefna).Path
$Root  = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Tmp   = Join-Path $Root "tests\tmp"
$script:Pass = 0
$script:Fail = 0

function T([string]$Name, [bool]$Ok) {
    if ($Ok) { $script:Pass++; Write-Host "  ok   $Name" }
    else     { $script:Fail++; Write-Host "  FAIL $Name" }
}

function TreesEqual([string]$A, [string]$B) {
    $fa = Get-ChildItem -Recurse -File $A | ForEach-Object { $_.FullName.Substring($A.Length) } | Sort-Object
    $fb = Get-ChildItem -Recurse -File $B | ForEach-Object { $_.FullName.Substring($B.Length) } | Sort-Object
    if (($fa -join "|") -ne ($fb -join "|")) { return $false }
    foreach ($rel in $fa) {
        $ha = (Get-FileHash -Algorithm SHA256 (Join-Path $A $rel)).Hash
        $hb = (Get-FileHash -Algorithm SHA256 (Join-Path $B $rel)).Hash
        if ($ha -ne $hb) { return $false }
    }
    return $true
}

if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp }
New-Item -ItemType Directory -Path $Tmp | Out-Null
Set-Location $Tmp

# --- CLI surface ---
$out = & $Vefna version
T "version prints version" ($out -match "vefna v")
& $Vefna help | Out-Null
T "help exits 0" ($LASTEXITCODE -eq 0)
& $Vefna bogus | Out-Null
T "unknown command exits non-zero" ($LASTEXITCODE -ne 0)
& $Vefna build | Out-Null
T "build outside a site exits non-zero" ($LASTEXITCODE -ne 0)
& $Vefna new "a/b" | Out-Null
T "new rejects a slash in the name" ($LASTEXITCODE -ne 0)

# --- new + double-new ---
& $Vefna new scaffolded | Out-Null
T "new creates a site" ($LASTEXITCODE -eq 0)
T "new lays out config, template, content" ((Test-Path "scaffolded\vefna.site") -and (Test-Path "scaffolded\templates\page.html") -and (Test-Path "scaffolded\content\index.md"))
& $Vefna new scaffolded | Out-Null
T "new refuses an existing directory" ($LASTEXITCODE -ne 0)
Push-Location scaffolded
& $Vefna build | Out-Null
T "scaffolded site builds" ($LASTEXITCODE -eq 0)
Pop-Location
T "scaffolded template holds literal {{slots}}" ((Get-Content "scaffolded\templates\page.html" -Raw) -match "\{\{title\}\}")
T "scaffolded site rendered markdown" ((Get-Content "scaffolded\site\index.html" -Raw) -match "<h1>")

# --- golden-file build ---
Copy-Item -Recurse (Join-Path $Root "tests\fixture") fx
Push-Location fx
& $Vefna build --clean | Out-Null
T "fixture builds clean" ($LASTEXITCODE -eq 0)
Pop-Location
T "fixture output matches golden files" (TreesEqual (Join-Path $Tmp "fx\site") (Join-Path $Root "tests\golden"))
$srcHash = (Get-FileHash "fx\static\img\rune.bin").Hash
$dstHash = (Get-FileHash "fx\site\static\img\rune.bin").Hash
T "binary asset round-trips byte-identical" ($srcHash -eq $dstHash)

# --- incremental behavior ---
Push-Location fx
$out = & $Vefna build
T "second build is a no-op" (($out -join "`n") -match "up to date")
Start-Sleep -Milliseconds 1100
(Get-Item "content\nested\deep.md").LastWriteTime = Get-Date
$out = & $Vefna build
T "touched page rebuilds exactly one page" (($out -join "`n") -match "Wove 1 of 3")
Start-Sleep -Milliseconds 1100
(Get-Item "templates\page.html").LastWriteTime = Get-Date
$out = & $Vefna build
T "touched template rebuilds every page" (($out -join "`n") -match "Wove 3 of 3")
Start-Sleep -Milliseconds 1100
(Get-Item "vefna.site").LastWriteTime = Get-Date
$out = & $Vefna build
T "touched config rebuilds every page" (($out -join "`n") -match "Wove 3 of 3")
Pop-Location

# --- determinism ---
Copy-Item -Recurse (Join-Path $Root "tests\fixture") fx2
Push-Location fx2
& $Vefna build --clean | Out-Null
Pop-Location
Push-Location fx
& $Vefna build --clean | Out-Null
Pop-Location
T "clean builds are deterministic" (TreesEqual (Join-Path $Tmp "fx\site") (Join-Path $Tmp "fx2\site"))

# --- error paths ---
Copy-Item -Recurse (Join-Path $Root "tests\fixture") fxerr
"---`ntitle: Broken`ntemplate: nope`n---`n`n# x`n" | Set-Content -NoNewline "fxerr\content\broken.md"
Push-Location fxerr
$out = & $Vefna build --clean
$code = $LASTEXITCODE
Pop-Location
T "missing template fails the build" ($code -ne 0)
T "missing template reports the page" (($out -join "`n") -match "error:")

# --- drafts (v1.1.0) ---
& $Vefna new drafttest | Out-Null
@('---','title: Draft','draft: true','---','# Draft body') | Set-Content "drafttest\content\secret.md"
Push-Location drafttest
& $Vefna build --clean | Out-Null
T "site with a draft builds" ($LASTEXITCODE -eq 0)
Pop-Location
T "draft is excluded by default" (-not (Test-Path "drafttest\site\secret.html"))
Push-Location drafttest
& $Vefna build --clean --drafts | Out-Null
T "build --drafts rebuilds" ($LASTEXITCODE -eq 0)
Pop-Location
T "draft is included with --drafts" (Test-Path "drafttest\site\secret.html")
Push-Location drafttest
$out = & $Vefna build --clean
T "default build reports skipped drafts" (($out -join "`n") -match "draft\(s\) skipped")
Pop-Location

Write-Host ""
Write-Host "$($script:Pass) passed, $($script:Fail) failed"
if ($script:Fail -ne 0) { exit 1 }
exit 0
