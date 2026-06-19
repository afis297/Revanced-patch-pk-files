@echo off
setlocal EnableDelayedExpansion

:: ==========================================
:: ReVanced Auto-Patcher (Fixed Version)
:: ==========================================

:: Force console to stay open on errors
on error resume next

:: CONFIGURATION
set "JAVA_PATH=C:\Users\Children\AppData\Local\Programs\Eclipse Adoptium\jdk-21.0.10.7-hotspot\bin\java.exe"
set "CLI_JAR=revanced-cli.jar"
set "PATCHES_FILE=patches.rvp"
set "OUTPUT_DIR=patched_apks"

:: Title and colors
title ReVanced Auto-Patcher
color 0A

echo ==========================================
echo    ReVanced Auto-Patcher
echo ==========================================
echo.

:: Check Java
echo [1/5] Checking Java...
if not exist "%JAVA_PATH%" (
    echo [ERROR] Java not found at: %JAVA_PATH%
    echo.
    echo Please edit JAVA_PATH in this script.
    goto :keep_open
)
echo [OK] Java found
echo.

:: Check CLI
echo [2/5] Checking ReVanced CLI...
if not exist "%CLI_JAR%" (
    echo [ERROR] %CLI_JAR% not found!
    goto :keep_open
)
echo [OK] CLI found
echo.

:: Check Patches
echo [3/5] Checking Patches file...
if not exist "%PATCHES_FILE%" (
    echo [ERROR] %PATCHES_FILE% not found!
    goto :keep_open
)
echo [OK] Patches found
echo.

:: Create output directory
echo [4/5] Creating output directory...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
echo [OK] Directory ready
echo.

:: Search for APK files
echo [5/5] Searching for APK files...
echo.

set "count=0"
for %%f in (*.apk) do (
    set "fname=%%f"
    set "is_patched=0"
    
    echo "!fname!" | findstr /i "revanced patched" >nul
    if !errorlevel! equ 0 set "is_patched=1"
    
    if !is_patched! equ 0 (
        set /a count+=1
        set "apk_!count!=%%f"
        echo [!count!] %%f
    )
)

if %count% equ 0 (
    echo.
    echo [ERROR] No APK files found!
    echo Place original APK files in this folder.
    goto :keep_open
)

echo.
echo ==========================================
echo Found %count% APK file(s)
echo ==========================================
echo.

:: Select APK
set /p choice="Enter APK number to patch (1-%count%): "

if !choice! lss 1 goto :invalid
if !choice! gtr %count% goto :invalid

set "selected_apk=!apk_%choice%!"
echo.
echo Selected: %selected_apk%
echo.

:: Prepare output filename
set "basename=%selected_apk:~0,-4%"
set "output_name=%OUTPUT_DIR%\%basename%-revanced.apk"

:: Run patching
echo ==========================================
echo Starting patching...
echo ==========================================
echo.
echo This may take 2-10 minutes...
echo.

"%JAVA_PATH%" -jar "%CLI_JAR%" patch ^
  -p "%PATCHES_FILE%" ^
  -b ^
  -o "%output_name%" ^
  "%selected_apk%"

echo.
if %errorlevel% equ 0 (
    echo ==========================================
    echo [SUCCESS] Patching completed!
    echo ==========================================
    echo Output: %output_name%
    echo.
    echo IMPORTANT: Install ReVanced GmsCore first!
    echo https://github.com/ReVanced/GmsCore/releases
) else (
    echo ==========================================
    echo [ERROR] Patching failed!
    echo ==========================================
    echo Check the error messages above.
)

:keep_open
echo.
echo ==========================================
echo Press any key to exit...
echo ==========================================
pause >nul
exit /b 0

:invalid
echo.
echo [ERROR] Invalid selection!
goto :keep_open