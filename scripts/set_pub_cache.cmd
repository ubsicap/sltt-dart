@echo off
REM set_pub_cache.cmd
REM Detect and set PUB_CACHE in the current cmd.exe session to your global pub cache.
REM Usage: run this in a cmd.exe window. If you want the variable to persist across new shells,
REM use the printed setx suggestion or run setx yourself.
REM
REM Examples:
REM   # Set for current shell only
REM   set_pub_cache.cmd
REM
REM   # Persist for future shells (explicit):
REM   setx PUB_CACHE "C:\Users\ericd\AppData\Local\Pub\Cache"

SETLOCAL

if defined PUB_CACHE (
  echo PUB_CACHE is already set to %PUB_CACHE%
  goto :done
)

REM Allow an explicit path as first argument
if not "%~1"=="" (
  set "CANDIDATE=%~1"
) else (
  set "CANDIDATE=%APPDATA%\Pub\Cache"
  if not exist "%CANDIDATE%" set "CANDIDATE=%LOCALAPPDATA%\Pub\Cache"
  if not exist "%CANDIDATE%" set "CANDIDATE=%USERPROFILE%\.pub-cache"
)

if not exist "%CANDIDATE%" (
  echo Could not find a pub-cache at the standard locations.
  echo Please pass the path as the first argument, for example:
  echo   set_pub_cache.cmd "C:\Users\you\AppData\Roaming\Pub\Cache"
  goto :done
)

set "PUB_CACHE=%CANDIDATE%"
echo Setting PUB_CACHE to "%PUB_CACHE%" for the current cmd.exe session.
echo If you launched this script via a tool that used "cmd /c", your interactive shell may not inherit it.
echo Run this script directly in your interactive cmd.exe window, or persist it for new shells with:
echo   setx PUB_CACHE "%PUB_CACHE%"

:done
REM Export the value from the SETLOCAL block into the calling shell
ENDLOCAL & set "PUB_CACHE=%PUB_CACHE%"

exit /b 0
