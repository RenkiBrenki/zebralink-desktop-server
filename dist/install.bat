@echo off
SETLOCAL

REM --- Configuration ---
SET SERVICE_NAME=ZebraLink
SET SERVICE_DISPLAY_NAME=ZebraLink App Service
SET SERVICE_DESCRIPTION=ZebraLink running as a Windows service
SET JAR_PATH=%~dp0myapp.jar
SET WINSW_URL=https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW-x64.exe
SET WINSW_EXE=%~dp0%SERVICE_NAME%.exe
SET WINSW_XML=%~dp0%SERVICE_NAME%.xml
SET LOG_PATH=%~dp0logs

REM --- Create logs directory ---
if not exist "%LOG_PATH%" mkdir "%LOG_PATH%"

REM --- Download WinSW if not exists ---
if not exist "%WINSW_EXE%" (
    echo Downloading WinSW...
    powershell -Command "Invoke-WebRequest -Uri '%WINSW_URL%' -OutFile '%WINSW_EXE%'"
)

REM --- Create WinSW XML configuration ---
echo Creating WinSW XML...
(
echo ^<service^>
echo   ^<id^>%SERVICE_NAME%^</id^>
echo   ^<name^>%SERVICE_DISPLAY_NAME%^</name^>
echo   ^<description^>%SERVICE_DESCRIPTION%^</description^>
echo   ^<executable^>java^</executable^>
echo   ^<arguments^>-jar "%JAR_PATH%"^</arguments^>
echo   ^<logpath^>%LOG_PATH%^</logpath^>
echo   ^<log mode="roll-by-size"/^>
echo ^</service^>
) > "%WINSW_XML%"

REM --- Install and start service ---
echo Installing Windows service...
"%WINSW_EXE%" install
echo Starting service...
"%WINSW_EXE%" start

echo.
echo Service "%SERVICE_NAME%" installed and started successfully!
pause
ENDLOCAL
