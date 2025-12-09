<#
.SYNOPSIS
    Builds Power Platform solutions as managed solution packages.

.DESCRIPTION
    This script builds all managed solution packages from .cdsproj files found in the src/ directory.
    You must specify a version number for all solutions.

.PARAMETER Version
    Required. Version number in format Major.Minor.Patch.Build (e.g., "1.0.0.1").

.PARAMETER OutputPath
    Output directory for built solutions (default: "build/solutions").

.PARAMETER Configuration
    MSBuild configuration (default: "Release").

.EXAMPLE
    .\scripts\Build-Solutions.ps1 -Version "1.0.0.1"
    Builds all solutions with version 1.0.0.1

.EXAMPLE
    .\scripts\Build-Solutions.ps1 -Version "2.0.0.0" -OutputPath "dist"
    Builds all solutions with version 2.0.0.0 to the dist directory
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [string]$OutputPath = "build/solutions",
    
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

# Get script directory for relative paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# Find MSBuild.exe
function Find-MSBuild {
    $msbuildPaths = @(
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    )
    
    foreach ($path in $msbuildPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Fall back to PATH
    $msbuild = Get-Command msbuild -ErrorAction SilentlyContinue
    if ($msbuild) {
        return $msbuild.Source
    }
    
    Write-Error "MSBuild.exe not found. Please install Visual Studio Build Tools or ensure MSBuild is in your PATH."
    exit 1
}

$msbuildPath = Find-MSBuild

Write-Host "`n=== Power Platform Solution Builder ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor White
Write-Host "MSBuild: $msbuildPath" -ForegroundColor Gray

# Validate version format
if ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
    Write-Error "Version must be in format Major.Minor.Patch.Build (e.g., 1.0.0.1)"
    exit 1
}

# Find all solution projects
$solutionsPath = Join-Path $repoRoot "src"
$solutionProjects = @(Get-ChildItem -Path $solutionsPath -Filter "*.cdsproj" -Recurse)

if ($solutionProjects.Count -eq 0) {
    Write-Error "No solution projects found in $solutionsPath"
    exit 1
}

Write-Host "`nFound $($solutionProjects.Count) solution(s):" -ForegroundColor Cyan
foreach ($project in $solutionProjects) {
    Write-Host "  - $($project.BaseName)" -ForegroundColor Gray
}

# Update solution versions
Write-Host "`nUpdating solution versions..." -ForegroundColor Cyan
$versionUpdateErrors = @()

foreach ($project in $solutionProjects) {
    $solutionPath = $project.DirectoryName
    $solutionName = $project.BaseName
    $solutionXmlPath = Join-Path $solutionPath "src\Other\Solution.xml"
    
    if (-not (Test-Path $solutionXmlPath)) {
        Write-Warning "Solution.xml not found at: $solutionXmlPath"
        $versionUpdateErrors += "${solutionName}: Solution.xml not found"
        continue
    }
    
    Write-Host "  Updating $solutionName..." -ForegroundColor Yellow
    
    try {
        # Read and update Solution.xml
        [xml]$solutionXml = Get-Content $solutionXmlPath
        $versionNode = $solutionXml.SelectSingleNode("//Version")
        
        if ($null -eq $versionNode) {
            Write-Warning "    Version node not found in Solution.xml"
            $versionUpdateErrors += "${solutionName}: Version node not found"
            continue
        }
        
        $oldVersion = $versionNode.InnerText
        $versionNode.InnerText = $Version
        
        # Save with error handling to prevent partial updates
        $solutionXml.Save($solutionXmlPath)
        
        Write-Host "    Updated version: $oldVersion -> $Version" -ForegroundColor Gray
    }
    catch {
        Write-Error "    Failed to update $solutionName`: $_" -ErrorAction Continue
        $versionUpdateErrors += "${solutionName}: $($_.Exception.Message)"
    }
}

# Fail before building if any version updates failed
if ($versionUpdateErrors.Count -gt 0) {
    Write-Error "`nVersion update failed for $($versionUpdateErrors.Count) solution(s). Aborting build to prevent inconsistent state." -ErrorAction Stop
    Write-Host "`nErrors:" -ForegroundColor Red
    foreach ($error in $versionUpdateErrors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
$fullOutputPath = Resolve-Path $OutputPath

# Build solutions
Write-Host "`nBuilding solutions..." -ForegroundColor Cyan
$buildErrors = @()

foreach ($project in $solutionProjects) {
    $solutionName = $project.BaseName
    $projectDir = $project.DirectoryName
    $zipPath = Join-Path $fullOutputPath "$solutionName`_managed.zip"
    
    Write-Host "`n  Building $solutionName..." -ForegroundColor Yellow
    Write-Host "    Project: $($project.FullName)" -ForegroundColor Gray
    Write-Host "    Output: $zipPath" -ForegroundColor Gray
    
    # Clean obj and bin folders for fresh build state
    Write-Host "    Cleaning build artifacts..." -ForegroundColor Gray
    $objFolder = Join-Path $projectDir "obj"
    $binFolder = Join-Path $projectDir "bin"
    if (Test-Path $objFolder) {
        Remove-Item -Path $objFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $binFolder) {
        Remove-Item -Path $binFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Step 1: Restore NuGet packages
    Write-Host "    Restoring packages..." -ForegroundColor Gray
    $restoreArgs = @(
        "`"$($project.FullName)`"",
        "/t:Restore",
        "/p:RestorePackagesConfig=false",
        "/verbosity:minimal",
        "/nologo",
        "/noautoresponse"
    )
    
    $restoreOutput = & $msbuildPath $restoreArgs 2>&1
    $restoreExitCode = $LASTEXITCODE
    
    if ($restoreExitCode -ne 0) {
        Write-Host "    [FAIL] Package restore failed" -ForegroundColor Red
        $buildErrors += "${solutionName}: Package restore failed"
        continue
    }
    
    # Step 2: Build solution - use direct PowerShell invocation to properly handle paths with spaces
    Write-Host "    Building solution..." -ForegroundColor Gray
    $buildArgs = @(
        "`"$($project.FullName)`"",
        "/t:Build",
        "/p:Configuration=$Configuration",
        "/p:SolutionPackageType=Managed",
        "/p:SolutionPackageOutputPath=`"$fullOutputPath`"",
        "/p:SolutionPackageZipFilePath=`"$zipPath`"",
        "/p:SolutionRootPath=src",
        "/p:DeployOnBuild=false",
        "/verbosity:minimal",
        "/nologo",
        "/noautoresponse"
    )
    
    $buildOutput = & $msbuildPath $buildArgs 2>&1
    $buildExitCode = $LASTEXITCODE
    
    if ($buildExitCode -eq 0) {
        if (Test-Path $zipPath) {
            $fileSize = (Get-Item $zipPath).Length / 1MB
            $sizeRounded = [math]::Round($fileSize, 2)
            Write-Host "    [OK] Built successfully ($sizeRounded MB)" -ForegroundColor Green
        } else {
            Write-Warning "    Build succeeded but output file not found: $zipPath"
            $buildErrors += "${solutionName}: Output file missing"
        }
    } else {
        Write-Host "    [FAIL] Build failed" -ForegroundColor Red
        $buildErrors += "${solutionName}: Build failed"
    }
}

# Summary
Write-Host "`n=== Build Summary ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor White

if ($buildErrors.Count -eq 0) {
    Write-Host "Status: All solutions built successfully [OK]" -ForegroundColor Green
    Write-Host "`nBuilt solutions:" -ForegroundColor Cyan
    Get-ChildItem -Path $fullOutputPath -Filter "*_managed.zip" | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  - $($_.Name) ($size MB)" -ForegroundColor White
    }
    Write-Host "`nOutput directory: $fullOutputPath" -ForegroundColor Gray
} else {
    Write-Host "Status: Build completed with errors [FAIL]" -ForegroundColor Red
    Write-Host "`nErrors:" -ForegroundColor Red
    foreach ($error in $buildErrors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    exit 1
}

