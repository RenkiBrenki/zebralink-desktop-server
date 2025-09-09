# Path to your JAR
$AppPath = "C:\zebralink-desktop-server\dist\zebralink-1.0.0.jar"
$WorkingDir = "C:\zebralink-desktop-server"

# Use javaw.exe so it runs in background (no console window)
$JavaPath = "javaw"  # assumes javaw is in PATH

# Create the scheduled task action
$Action = New-ScheduledTaskAction -Execute $JavaPath -Argument "-jar `"$AppPath`"" -WorkingDirectory $WorkingDir

# Trigger at user logon
$Trigger = New-ScheduledTaskTrigger -AtLogOn

# Run in interactive user session
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

# Define the task
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Description "Start ZebraLink at login"

# Register the task (force overwrite if exists)
Register-ScheduledTask -TaskName "ZebraLink" -InputObject $Task -Force

Write-Host "✅ ZebraLink task created. It will run on user logon in the background using javaw.exe"
