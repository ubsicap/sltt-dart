@echo off
REM Windows build script for AWS Lambda (requires Docker)

echo Building Dart Lambda function for Linux...

REM Remove old bootstrap
if exist bootstrap del bootstrap

REM Check if Docker is available
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is required for cross-compilation on Windows
    echo Please install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
    exit /b 1
)

REM Check if Docker daemon is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running. Please start Docker Desktop and try again.
    echo.
    echo After starting Docker Desktop:
    echo   1. Wait for Docker to fully start
    echo   2. Re-run this build script
    pause
    exit /b 1
)

echo Compiling Dart for Linux x64 using Docker...
echo This may take a few minutes on first run to download the Dart image...
echo.
echo NOTE: Mounting full workspace to access pubspec.yaml for workspace resolution.
echo Only aws_backend imports will be compiled - Isar won't be included unless imported.
echo.

REM Mount the full workspace root so Dart can resolve workspace dependencies
docker run --rm ^
  -v "%cd%\..\..":/workspace ^
  -w /workspace/packages/aws_backend ^
  dart:stable ^
  sh -c "echo 'Running pub get...' && dart pub get && echo 'Compiling to Linux binary...' && dart compile exe bin/bootstrap.dart -o bootstrap && chmod +x bootstrap"

if %errorlevel% neq 0 (
    echo ERROR: Docker build failed
    echo Check the Docker output above for compilation errors
    exit /b 1
)

if not exist bootstrap (
    echo ERROR: Bootstrap executable was not created
    exit /b 1
)

REM Verify it's a Linux binary
file bootstrap 2>nul || echo Bootstrap file created (file command not available on Windows)

echo.
echo ✅ Successfully built bootstrap for Linux x64
echo.
echo Restoring Windows packages...
dart pub get >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Windows packages restored
) else (
    echo ⚠️  Warning: Failed to restore Windows packages. Run 'dart pub get' manually.
)
echo.
echo To verify no Isar dependencies are included:
echo   docker run --rm -v "%cd%":/workspace -w /workspace alpine:latest ldd bootstrap 2^>^/dev^/null ^| grep -i isar ^|^| echo "No Isar libraries linked"
echo.
