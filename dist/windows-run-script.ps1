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
#https://raw.githubusercontent.com/RenkiBrenki/zebralink-desktop-server/main/dist/windows-run-script.ps1

$JarUrl = "https://raw.githubusercontent.com/RenkiBrenki/zebralink-desktop-server/main/dist/zebralink-1.0.0.jar"

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
    $jdkInstallDir = Join-Path $env:ProgramData "Java\jdk-21"

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

# Path to Java executable
$JavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
$JavaPath = Join-Path $JavaHome "bin\javaw.exe"

# Use the folder containing the JAR as the working directory
$WorkingDir = Split-Path $AppPath

# Create the scheduled task action
$Action = New-ScheduledTaskAction -Execute $JavaPath -Argument "-jar `"$AppPath`"" -WorkingDirectory $WorkingDir

# Trigger at ANY user logon with 30-second delay
$Trigger = New-ScheduledTaskTrigger -AtLogOn  # Remove -User parameter for any user
$Trigger.Delay = "PT30S"

# Run as current user with highest privileges
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Task settings - configured for Windows 10
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -Compatibility Win8  # Windows 10 uses Win8 compatibility mode

# Build the task object
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Description "Start ZebraLink at login"

# Register or overwrite existing task (run this script as Administrator)
Register-ScheduledTask -TaskName "ZebraLink" -InputObject $Task -Force
