@echo off
REM setup_test_env.bat
REM 1) Locate isar.dll in the local Pub cache (hosted pub.dev)
REM 2) Copy it into the package .dart_tool\isar folder (so tools that look there find it)
REM 3) Prepend the DLL folder to PATH for this session (so the Windows loader can find it when tests run from temp dirs)
REM 4) Run `dart test` in the target package (unless --setup-only is passed)

setlocal enabledelayedexpansion

REM Directory where hosted pub packages are stored
set "PUB_HOSTED=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev"

REM Default target package (relative to this script). Change if needed.
set "TARGET_PACKAGE=%~dp0..\packages\sync_manager"

REM Resolve absolute path to target package
pushd "%TARGET_PACKAGE%" || (echo Failed to set target package directory %TARGET_PACKAGE% & exit /b 1)
@echo off

REM setup_test_env.bat
REM 1) Locate isar.dll in local Pub cache
REM 2) Copy it into the package .dart_tool\isar folder
REM 3) Prepend the DLL folder to PATH for THIS CMD SESSION
REM 4) Optionally run `dart test` in the target package unless --setup-only is passed

set "PUB_HOSTED=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev"
set "TARGET_PACKAGE=%~dp0..\packages\sync_manager"

REM Handle quoted args safely (strip surrounding quotes)
set "FIRST_ARG=%~1"

REM Find isar.dll under pub cache (first match wins)
set "ISAR_DLL="
for /d %%D in ("%PUB_HOSTED%\isar_flutter_libs-*") do (
	if exist "%%~fD\windows\isar.dll" (
		set "ISAR_DLL=%%~fD\windows\isar.dll"
		goto :found
	)
)

echo ERROR: isar.dll not found in %PUB_HOSTED%.
echo        Run "dart pub get" in packages\sync_manager and retry.
exit /b 2

:found
echo Found isar.dll at "%ISAR_DLL%"

set "TARGET_ISAR_DIR=%TARGET_PACKAGE%\.dart_tool\isar"
if not exist "%TARGET_ISAR_DIR%" (
	mkdir "%TARGET_ISAR_DIR%" 1>nul 2>nul
)

copy /Y "%ISAR_DLL" "%TARGET_ISAR_DIR%\isar.dll" 1>nul
if errorlevel 1 (
	echo ERROR: Failed to copy isar.dll to "%TARGET_ISAR_DIR%".
	exit /b 3
)

echo Copied isar.dll to "%TARGET_ISAR_DIR%"

REM Prepend the isar.dll directory to PATH for this session only
for %%F in ("%ISAR_DLL%") do set "ISAR_DIR=%%~dpF"
set "PATH=%ISAR_DIR%;%PATH%"
echo Prepending "%ISAR_DIR%" to PATH for this session

REM Also copy DLL to temp directory for test kernels
set "TEMP_DIR=%TEMP%"
if not exist "%TEMP_DIR%" (
  set "TEMP_DIR=%TMP%"
)
if exist "%TEMP_DIR%" (
  copy /Y "%ISAR_DLL%" "%TEMP_DIR%\isar.dll" 1>nul 2>nul
  echo Copied isar.dll to "%TEMP_DIR%" for test kernel access
)

REM Hint Isar where to find the DLL explicitly
set "ISAR_DLL_PATH=%ISAR_DIR%"
echo Setting ISAR_DLL_PATH to "%ISAR_DIR%"

if /I "%FIRST_ARG%"=="--setup-only" (
	echo Setup complete; not running tests (use without --setup-only to run tests).
	exit /b 0
)

pushd "%TARGET_PACKAGE%" 1>nul
if errorlevel 1 (
	echo ERROR: Failed to cd into "%TARGET_PACKAGE%".
	exit /b 4
)

echo Running tests in "%CD%"
call dart test %*
set "EXIT_CODE=%ERRORLEVEL%"
popd 1>nul
exit /b %EXIT_CODE%
