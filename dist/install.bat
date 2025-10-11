@echo off
REM -----------------------------
REM URL of the PowerShell installer script
REM -----------------------------
set ScriptUrl=https://raw.githubusercontent.com/RenkiBrenki/zebralink-desktop-server/dist/windows-run-script.ps1

REM Temporary path to save the downloaded script
set TempScript=%TEMP%\zebralink-install.ps1

echo Downloading installer script...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%ScriptUrl%' -OutFile '%TempScript%' -UseBasicParsing"

echo Running installer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%TempScript%"

REM Optional: delete the temporary script after execution
del "%TempScript%"
