# -----------------------------
# Paths
# -----------------------------
$TargetFolder = Join-Path $env:ProgramData "ZebraLink"
if (-not (Test-Path $TargetFolder)) {
    New-Item -ItemType Directory -Force -Path $TargetFolder | Out-Null
}
$AppPath = Join-Path $TargetFolder "zebralink-latest.jar"

# -----------------------------
# Download latest JAR from GitHub
# -----------------------------
$JarUrl = "https://github.com/RenkiBrenki/zebralink-desktop-server/releases/latest/download/zebralink-1.0.0.jar"

Write-Host "Downloading latest ZebraLink JAR..."
Invoke-WebRequest -Uri $JarUrl -OutFile $AppPath -UseBasicParsing
Write-Host "Downloaded to $AppPath"

# -----------------------------
# Check if Java is installed
# -----------------------------
$javaInstalled = Get-Command javaw -ErrorAction SilentlyContinue

if (-not $javaInstalled) {
    Write-Host "Java not found. Installing OpenJDK..."

    # Download OpenJDK (Temurin 21)
    $jdkUrl = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse"
    $jdkZip = Join-Path $env:TEMP "OpenJDK.zip"
    $jdkInstallDir = "C:\Java\jdk-21"
    $jdkInstallDir = Join-Path $env:ProgramData "jdk-21"

    if (-not (Test-Path $jdkInstallDir)) {
        New-Item -ItemType Directory -Force -Path $jdkInstallDir | Out-Null
    }

    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip -UseBasicParsing
    Expand-Archive -LiteralPath $jdkZip -DestinationPath $jdkInstallDir -Force
    Remove-Item $jdkZip -Force

    $extractedDir = Get-ChildItem -Path $jdkInstallDir -Directory | Select-Object -First 1
    if (-not $extractedDir) {
        Write-Error "Failed to find extracted JDK folder in $jdkInstallDir"
        exit 1
    }

    $jdkRealDir = $extractedDir.FullName
    $binDir = Join-Path $jdkRealDir "bin"

    Write-Host "Detected JDK folder: $jdkRealDir"
    Write-Host "Detected BIN path: $binDir"

    $env:PATH = "$binDir;$env:PATH"

    $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($oldPath -notlike "*$binDir*") {
        $newPath = "$oldPath;$binDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added $binDir to PATH"
    }

    [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkRealDir, "User")
    Write-Host "JAVA_HOME set to $jdkRealDir"
} else {
    Write-Host "Java is already installed."
}

# -----------------------------
# Create startup .bat
# -----------------------------
$zebralinkBat = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\Startup\zebralink.bat"
$batchContent = @"
@echo off
start javaw -jar "`"$AppPath`""
"@

Set-Content -Path $zebralinkBat -Value $batchContent -Encoding ASCII
Write-Host "Created startup script at `"$zebralinkBat`""
