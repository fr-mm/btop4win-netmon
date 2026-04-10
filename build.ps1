# btop4win-netmon PowerShell Build Script

Write-Host "####################################" -ForegroundColor Cyan
Write-Host "# btop4win-netmon Build Script     #" -ForegroundColor Cyan
Write-Host "####################################" -ForegroundColor Cyan

# 1. Locate MSBuild
$msbuild = $null
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $vswhere) {
    $installationPath = & $vswhere -latest -products * -property installationPath
    if ($installationPath) {
        $msbuild = Join-Path $installationPath "MSBuild\Current\Bin\MSBuild.exe"
        if (-not (Test-Path $msbuild)) {
            $msbuild = Join-Path $installationPath "MSBuild\15.0\Bin\MSBuild.exe"
        }
    }
}

if (-not $msbuild) {
    $msbuild = Get-Command msbuild -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

if (-not $msbuild) {
    Write-Host "`n[ERROR] MSBuild.exe not found." -ForegroundColor Red
    Write-Host "Please ensure Visual Studio 2022 or Build Tools are installed with 'Desktop development with C++'." -ForegroundColor Yellow
    return
}

Write-Host "`n[INFO] Using MSBuild: $msbuild" -ForegroundColor Blue
Write-Host "[INFO] Building Solution: btop4win.sln (Debug | x64)...`n" -ForegroundColor Blue

# 2. Attempt Build with v143 (Default)
$buildParams = @("btop4win.sln", "/p:Configuration=Debug", "/p:Platform=x64", "/m", "/v:m")
& $msbuild $buildParams

# 3. Handle Toolset Error (v143 -> v142 fallback)
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[WARNING] Build failed with the default v143 toolset (Visual Studio 2022)." -ForegroundColor Yellow
    Write-Host "[INFO] Retrying with v142 toolset (Visual Studio 2019)...`n" -ForegroundColor Blue
    
    $fallbackParams = $buildParams + "/p:PlatformToolset=v142"
    & $msbuild $fallbackParams
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[ERROR] Build failed even with v142 toolset." -ForegroundColor Red
        Write-Host "If you have VS 2019, ensure you have the 'Desktop development with C++' component and C++20 support." -ForegroundColor Yellow
        exit $LASTEXITCODE
    }
}

Write-Host "`n[SUCCESS] Build completed successfully!" -ForegroundColor Green
Write-Host "[INFO] Binary location: $(Join-Path $PSScriptRoot "x64\Debug\btop4win.exe")" -ForegroundColor Blue
