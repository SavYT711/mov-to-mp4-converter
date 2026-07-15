@echo off
setlocal enabledelayedexpansion
title Convert to MP4

set "input=%~1"

if "%input%"=="" (
    echo No file was passed to this script.
    echo Usage: convert-to-mp4.bat "C:\path\to\video.mov"
    pause
    exit /b 1
)

if not exist "%input%" (
    echo File not found: %input%
    pause
    exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo.
    echo [ERROR] ffmpeg was not found on your PATH.
    echo Install it with "winget install ffmpeg" ^(or from https://ffmpeg.org/download.html^)
    echo and try again.
    echo.
    pause
    exit /b 1
)

if /i "%~x1"==".mp4" (
    echo This file is already an MP4. Nothing to do.
    pause
    exit /b 0
)

rem --- Load quality preset from config.ini next to this script, default to "balanced" ---
set "quality=balanced"
if exist "%~dp0config.ini" (
    for /f "usebackq tokens=1,2 delims==" %%A in (`findstr /i "^Quality=" "%~dp0config.ini"`) do set "quality=%%B"
)

if /i "%quality%"=="fast" (
    set "preset=veryfast"
    set "crf=23"
) else if /i "%quality%"=="high" (
    set "preset=slow"
    set "crf=16"
) else (
    set "preset=medium"
    set "crf=18"
)

set "output=%~dpn1.mp4"

if exist "%output%" (
    set /p overwrite="Output file already exists: %output%  Overwrite? (y/n): "
    if /i not "!overwrite!"=="y" (
        echo Cancelled.
        pause
        exit /b 0
    )
)

echo.
echo Converting ^(quality: %quality%^):
echo   Input:  %input%
echo   Output: %output%
echo.

ffmpeg -i "%input%" -c:v libx264 -crf %crf% -preset %preset% -c:a aac -b:a 192k "%output%"

echo.
if errorlevel 1 (
    echo [FAILED] Conversion did not complete successfully.
) else (
    echo [DONE] Saved to: %output%
)
echo.
pause
