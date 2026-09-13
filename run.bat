@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Hot-update directory: the directory containing this script.
for %%I in ("%~dp0.") do set "HOT_DIR=%%~fI"
for %%I in ("%HOT_DIR%\..\..\..\xtlr_Data\StreamingAssets\InstallResource\txtp") do set "INSTALL_DIR=%%~fI"

set "WWISER=%HOT_DIR%\wwiser.pyz"
for %%I in ("%INSTALL_DIR%\..\Music_AVG.bnk") do set "INSTALL_BANK=%%~fI"
for %%I in ("%HOT_DIR%\..\Music_AVG.bnk") do set "HOT_BANK=%%~fI"

if not exist "%WWISER%" (
    echo ERROR: wwiser.pyz was not found:
    echo %WWISER%
    echo Download it from https://github.com/bnnm/wwiser and put it next to run.bat.
    pause
    exit /b 1
)

if not exist "%INSTALL_BANK%" (
    echo ERROR: install Music_AVG.bnk was not found:
    echo %INSTALL_BANK%
    pause
    exit /b 1
)

if not exist "%HOT_BANK%" (
    echo ERROR: hot-update Music_AVG.bnk was not found:
    echo %HOT_BANK%
    pause
    exit /b 1
)

echo [1/3] Generating install TXTP files...
pushd "%INSTALL_BANK%\.."
if errorlevel 1 (
    echo ERROR: cannot enter the install bank directory.
    pause
    exit /b 1
)
rem Use paths relative to the bank directory so TXTP references stay ../Media/*.wem.
py -3 "%WWISER%" -d none -g "-go=txtp" "Music_AVG.bnk"
set "WWISER_ERROR=%ERRORLEVEL%"
popd
if not "%WWISER_ERROR%"=="0" (
    echo ERROR: install TXTP generation failed. Code: %WWISER_ERROR%
    pause
    exit /b %WWISER_ERROR%
)

echo [2/3] Generating hot-update TXTP files...
pushd "%HOT_BANK%\.."
if errorlevel 1 (
    echo ERROR: cannot enter the hot-update bank directory.
    pause
    exit /b 1
)
py -3 "%WWISER%" -d none -g "-go=txtp" "Music_AVG.bnk"
set "WWISER_ERROR=%ERRORLEVEL%"
popd
if not "%WWISER_ERROR%"=="0" (
    echo ERROR: hot-update TXTP generation failed. Code: %WWISER_ERROR%
    pause
    exit /b %WWISER_ERROR%
)

echo [3/3] Removing hot-update TXTP files with install IDs...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$install = [IO.Path]::GetFullPath($env:INSTALL_DIR); $hot = [IO.Path]::GetFullPath($env:HOT_DIR); $ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal); Get-ChildItem -LiteralPath $install -File -Filter '*.txtp' | ForEach-Object { $m = [regex]::Match($_.BaseName, '\d+(?!.*\d)'); if ($m.Success) { [void]$ids.Add($m.Value) } }; $deleted = 0; Get-ChildItem -LiteralPath $hot -File -Filter '*.txtp' | ForEach-Object { $m = [regex]::Match($_.BaseName, '\d+(?!.*\d)'); if ($m.Success -and $ids.Contains($m.Value)) { Remove-Item -LiteralPath $_.FullName -Force; $deleted++ } }; Write-Host ('Deleted duplicate hot-update TXTP files: {0}' -f $deleted)"
if errorlevel 1 (
    echo ERROR: duplicate cleanup failed.
    pause
    exit /b 1
)

echo Done.
pause
exit /b 0
