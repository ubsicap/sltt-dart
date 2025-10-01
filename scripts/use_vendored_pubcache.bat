@echo off
REM use_vendored_pubcache.bat
REM Robust mirror of Windows pub-cache into repository's vendor/pub-cache using robocopy.

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: Default locations
SET "SRC=%USERPROFILE%\.pub-cache"
SET "DEST=%~dp0..\vendor\pub-cache"

:: Parse optional args: first = source, second = dest
IF /I "%~1"=="--help" GOTO show_help
IF /I "%~1"=="-h" GOTO show_help
IF NOT "%~1"=="" SET "SRC=%~1"
IF NOT "%~2"=="" SET "DEST=%~2"

:show_help
IF /I "%~1"=="--help" (
  ECHO use_vendored_pubcache.bat - copy the Windows pub-cache into vendor\pub-cache using robocopy
  ECHO.
  ECHO Usage:
  ECHO   scripts\use_vendored_pubcache.bat [sourcePubCachePath] [destPath]
  ECHO.
  ECHO Examples:
  ECHO   scripts\use_vendored_pubcache.bat
  ECHO   scripts\use_vendored_pubcache.bat "C:\Users\ericd\.pub-cache"
  ECHO   scripts\use_vendored_pubcache.bat "C:\Users\ericd\.pub-cache" "C:\myrepo\vendor\pub-cache"
  ECHO.
  EXIT /B 0
)

:: Ensure robocopy is available
where robocopy >NUL 2>&1
IF ERRORLEVEL 1 (
  ECHO robocopy not found on PATH. Please run this script on Windows with robocopy available.
  EXIT /B 3
)

:: Resolve absolute repository root
PUSHD %~dp0\.. >NUL 2>&1
SET "REPO_ROOT=%CD%"
POPD >NUL 2>&1

:: Normalize source/dest to absolute paths if relative provided
IF NOT "%SRC:~1,1%"==":" SET "SRC=%USERPROFILE%\%SRC%"
IF NOT "%DEST:~1,1%"==":" SET "DEST=%REPO_ROOT%\%DEST%"

ECHO Source pub-cache: "%SRC%"
ECHO Destination vendor pub-cache: "%DEST%"

IF NOT EXIST "%SRC%" (
  ECHO Source pub-cache not found: "%SRC%"
  ECHO Ensure you have a local pub-cache at %%USERPROFILE%%\.pub-cache or pass the path as the first argument.
  EXIT /B 2
)

:: Create destination directory if it doesn't exist
IF NOT EXIST "%DEST%" (
  ECHO Creating destination: "%DEST%"
  MKDIR "%DEST%"
  IF ERRORLEVEL 1 (
    ECHO Failed to create destination directory. Check permissions.
    EXIT /B 4
  )
)

ECHO Running robocopy (this may take a while)...
REM Use /MIR to mirror. Use /FFT for cross-filesystem timestamps, /Z restartable, /XA:H exclude hidden.
robocopy "%SRC%" "%DEST%" /MIR /FFT /Z /XA:H /W:5 /R:3
SET RC=%ERRORLEVEL%

REM According to robocopy docs, exit codes 0-7 are success-ish; >=8 indicates failure.
IF %RC% GEQ 8 (
  ECHO Robocopy failed with exit code %RC%. Please inspect the output above.
  EXIT /B %RC%
)

ECHO.
ECHO To use the vendored pub-cache in your current cmd.exe session run:
ECHO   set PUB_CACHE=%REPO_ROOT%\vendor\pub-cache
ECHO
ECHO Or in PowerShell run (in the same shell):
ECHO   $env:PUB_CACHE = "${REPO_ROOT}\vendor\pub-cache"

ECHO Done.
ENDLOCAL
EXIT /B 0
