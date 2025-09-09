$AppPath = "C:\zebralink-desktop-server\dist\zebralink-1.0.0.jar"
$WorkingDir = "C:\zebralink-desktop-server"

$Action  = New-ScheduledTaskAction -Execute "java" -Argument "-jar `"$AppPath`"" -WorkingDirectory $WorkingDir

$Trigger = New-ScheduledTaskTrigger -AtLogOn

$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Description "Start ZebraLink at login"

Register-ScheduledTask -TaskName "ZebraLink" -InputObject $Task -Force

Write-Host "✅ ZebraLink task created. It will run on user logon."
