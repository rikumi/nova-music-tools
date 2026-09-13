@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Hot-update directory: the directory containing this script.
for %%I in ("%~dp0.") do set "HOT_DIR=%%~fI"
for %%I in ("%HOT_DIR%\..\..\..\xtlr_Data\StreamingAssets\InstallResource\txtp") do set "INSTALL_DIR=%%~fI"

set "WWISER=%HOT_DIR%\wwiser.pyz"
set "INSTALL_BANK_DIR=%INSTALL_DIR%\.."
set "HOT_BANK_DIR=%HOT_DIR%\.."

if not exist "%WWISER%" (
    echo ERROR: wwiser.pyz was not found:
    echo %WWISER%
    echo Download it from https://github.com/bnnm/wwiser and put it next to run.bat.
    pause
    exit /b 1
)

if not exist "%INSTALL_BANK_DIR%\Music_*.bnk" (
    echo ERROR: no install Music_*.bnk files were found:
    echo %INSTALL_BANK_DIR%
    pause
    exit /b 1
)

if not exist "%HOT_BANK_DIR%\Music_*.bnk" (
    echo ERROR: no hot-update Music_*.bnk files were found:
    echo %HOT_BANK_DIR%
    pause
    exit /b 1
)

echo [1/3] Generating install TXTP files...
pushd "%INSTALL_BANK_DIR%"
if errorlevel 1 (
    echo ERROR: cannot enter the install bank directory.
    pause
    exit /b 1
)
rem Use paths relative to the bank directory so TXTP references stay ../Media/*.wem.
py -3 "%WWISER%" -d none -g "-go=txtp" Music_*.bnk
set "WWISER_ERROR=%ERRORLEVEL%"
popd
if not "%WWISER_ERROR%"=="0" (
    echo ERROR: install TXTP generation failed. Code: %WWISER_ERROR%
    pause
    exit /b %WWISER_ERROR%
)

echo [2/3] Generating hot-update TXTP files...
pushd "%HOT_BANK_DIR%"
if errorlevel 1 (
    echo ERROR: cannot enter the hot-update bank directory.
    pause
    exit /b 1
)
py -3 "%WWISER%" -d none -g "-go=txtp" Music_*.bnk
set "WWISER_ERROR=%ERRORLEVEL%"
popd
if not "%WWISER_ERROR%"=="0" (
    echo ERROR: hot-update TXTP generation failed. Code: %WWISER_ERROR%
    pause
    exit /b %WWISER_ERROR%
)

echo [3/3] Removing hot-update TXTP files with install IDs...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$install = [IO.Path]::GetFullPath($env:INSTALL_DIR); $hot = [IO.Path]::GetFullPath($env:HOT_DIR); $installFiles = @(Get-ChildItem -LiteralPath $install -File -Filter '*.txtp'); $hotFiles = @(Get-ChildItem -LiteralPath $hot -File -Filter '*.txtp'); $installCount = $installFiles.Count; $hotCount = $hotFiles.Count; $ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal); $installFiles | ForEach-Object { $m = [regex]::Match($_.BaseName, '\d+(?!.*\d)'); if ($m.Success) { [void]$ids.Add($m.Value) } }; $deleted = 0; $hotFiles | ForEach-Object { $m = [regex]::Match($_.BaseName, '\d+(?!.*\d)'); if ($m.Success -and $ids.Contains($m.Value)) { Remove-Item -LiteralPath $_.FullName -Force; $deleted++ } }; $remaining = @(Get-ChildItem -LiteralPath $hot -File -Filter '*.txtp').Count; $difference = [Math]::Abs($installCount - $hotCount); Write-Host ('Original install TXTP: {0}; original hot-update TXTP: {1}' -f $installCount, $hotCount); Write-Host ('Remaining hot-update TXTP: {0}; original count difference: {1}' -f $remaining, $difference); Write-Host ('Deleted duplicate hot-update TXTP files: {0}' -f $deleted); if ($remaining -lt $difference) { Write-Warning ('Remaining hot-update TXTP count is less than the original count difference by {0}.' -f ($difference - $remaining)) }"
if errorlevel 1 (
    echo ERROR: duplicate cleanup failed.
    pause
    exit /b 1
)

echo Done.
pause
exit /b 0
