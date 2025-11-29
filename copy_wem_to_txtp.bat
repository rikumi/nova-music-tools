@echo off
setlocal enabledelayedexpansion

:: --- Configuration ---
set "SOURCE_DIR=.."
set "TARGET_DIR=wem"

echo Starting WEM file cleanup and renaming...
echo.

:: 1. Check if the source directory exists
if not exist "%SOURCE_DIR%" (
    echo ERROR: Source directory "%SOURCE_DIR%" not found.
    echo Please make sure you run this script from the parent folder of "txtp".
    goto :eof
)

:: 2. Create the output directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo Created output directory: "%TARGET_DIR%"
)

set COUNT=0

:: 3. Loop through all files matching *.media.wem in the source directory
for %%f in ("%SOURCE_DIR%\*.media.wem") do (
    :: Extract the original filename with extension
    set "FILENAME=%%~nxf"
    
    :: Remove the ".media" part from the filename
    set "NEW_FILENAME=!FILENAME:.media=!"
    
    :: Copy and rename the file
    copy "%%f" "%TARGET_DIR%\!NEW_FILENAME!" >nul
    
    set /a COUNT+=1
)

echo.
echo Operation complete.
echo Successfully processed %COUNT% files.
echo The cleaned files are now in the "%TARGET_DIR%" folder.
pause
endlocal