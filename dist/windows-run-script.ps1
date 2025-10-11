# -----------------------------
# Paths
# -----------------------------
$TargetFolder = Join-Path $env:LOCALAPPDATA "ZebraLink"
New-Item -ItemType Directory -Force -Path $TargetFolder
$AppPath = Join-Path $TargetFolder "zebralink-latest.jar"

# Create target folder if it doesn't exist
if (-not (Test-Path $TargetFolder)) {
    New-Item -ItemType Directory -Path $TargetFolder -Force
}

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
    $jdkZip = "$env:TEMP\OpenJDK.zip"
    $jdkInstallDir = "C:\Java\jdk-21"

    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip -UseBasicParsing
    Expand-Archive -LiteralPath $jdkZip -DestinationPath $jdkInstallDir -Force

	# Find the actual extracted JDK folder (e.g. C:\Java\jdk-21\jdk-21.0.8+9)
	$extractedDir = Get-ChildItem -Path $jdkInstallDir -Directory | Select-Object -First 1
	$jdkRealDir = $extractedDir.FullName

	# The bin directory path (where java.exe and javaw.exe live)
	$binDir = Join-Path $jdkRealDir "bin"

	# Verify
	Write-Host "Detected JDK folder: $jdkRealDir"
	Write-Host "Detected BIN path: $binDir"

	# Add to current PATH
	$env:PATH = "$binDir;$env:PATH"

	# Permanently add to user PATH
	$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
	if ($oldPath -notlike "*$binDir*") {
		$newPath = "$oldPath;$binDir"
		[Environment]::SetEnvironmentVariable("Path", $newPath, "User")
		Write-Host "Added $binDir to PATH"
	}

	# Set JAVA_HOME for convenience
	[Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkRealDir, "User")
	Write-Host "JAVA_HOME set to $jdkRealDir"
} else {
    Write-Host "Java is already installed."
}

# -----------------------------
# Create Scheduled Task
# -----------------------------
# Path to Java executable
$JavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
$JavaPath = Join-Path $JavaHome "bin\javaw.exe"

# Use the folder containing the JAR as the working directory
$WorkingDir = Split-Path $AppPath

# Create the scheduled task action
$Action = New-ScheduledTaskAction -Execute $JavaPath -Argument "-jar `"$AppPath`"" -WorkingDirectory $WorkingDir

# Trigger at user logon
$Trigger = New-ScheduledTaskTrigger -AtLogOn

# Run as current user with highest privileges
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

# Build the task object
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Description "Start ZebraLink at login"

# Register or overwrite existing task
Register-ScheduledTask -TaskName "ZebraLink" -InputObject $Task -Force

Write-Host "✅ ZebraLink task created. App will run on user logon in the background using javaw.exe"
Write-Host "JAR path: $AppPath"
Write-Host "Working directory: $WorkingDir"
