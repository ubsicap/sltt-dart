@echo off
REM use_vendored_pubcache.bat
REM Copy the Windows pub-cache into the repository's vendor/pub-cache using robocopy.
REM NOTE: This script performs a one-way mirror copy from the user's pub-cache into vendor/pub-cache.

SETLOCAL ENABLEDELAYEDEXPANSION

:: Default locations
SET "SRC=%USERPROFILE%\.pub-cache"
SET "DEST=%~dp0..\vendor\pub-cache"

:: Allow optional args: first arg is source, second arg is destination
:parse_args
IF "%~1"=="" GOTO args_done
IF /I "%~1"=="--help" GOTO show_help
IF /I "%~1"=="-h" GOTO show_help
SET "SRC=%~1"
IF NOT "%~2"=="" SET "DEST=%~2"
GOTO args_done
:args_done

:show_help
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
ECHO What this does:
ECHO  - Mirrors the contents of the source pub-cache into the destination (creates destination if needed).
ECHO  - Uses robocopy flags: /MIR /FFT /Z /XA:H /W:5
ECHO    * /MIR: mirrors the source to destination (including deletions)
ECHO    * /FFT: improves timestamp compatibility across filesystems
ECHO    * /Z: copy in restartable mode
ECHO    * /XA:H: exclude hidden files (avoids copying some system files)
ECHO    * /W:5: wait 5s between retries
ECHO.
ECHO Notes:
ECHO  - Be careful with /MIR: if you point the source or destination incorrectly you may lose files.
ECHO  - Robocopy exit codes < 8 indicate success or recoverable conditions; >=8 indicates failure.
ECHO  - This script prints how to set PUB_CACHE for your current shell; run that command in the same shell after this script completes.
ECHO.
EXIT /B 0

:: Normalize destination to absolute path
PUSHD %~dp0\.. >NUL 2>&1
SET "REPO_ROOT=%CD%"
POPD >NUL 2>&1
IF NOT EXIST "%SRC%" (
  ECHO Source pub-cache not found: "%SRC%"
  ECHO Ensure you have a local pub-cache at %%USERPROFILE%%\.pub-cache or pass the path as the first argument.
  EXIT /B 2
)

ECHO Copying pub-cache from:
ECHO   %SRC%
ECHO to:
ECHO   %DEST%
ECHO.

REM Create destination dir if missing
IF NOT EXIST "%DEST%" (
  MKDIR "%DEST%"
)

ECHO Running robocopy (this may take a while)...
robocopy "%SRC%" "%DEST%" /MIR /FFT /Z /XA:H /W:5
SET RC=%ERRORLEVEL%
IF %RC% GEQ 8 (
  ECHO Robocopy returned error code %RC% — see robocopy docs. Exiting with failure.
  EXIT /B %RC%
)

ECHO.
ECHO To use the vendored pub-cache in your current cmd.exe session run:
ECHO   set PUB_CACHE=%CD%\vendor\pub-cache
ECHO
ECHO Or in PowerShell run:
ECHO   $env:PUB_CACHE = "$PWD\vendor\pub-cache"

ECHO Done.
ENDLOCAL
EXIT /B 0
