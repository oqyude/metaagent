@echo off
setlocal enabledelayedexpansion

REM MetaAgent — Windows installer (cmd batch)
REM Usage: install.bat [--update] [target_path]

set "METAAGENT_SRC=%~dp0"
set "UPDATE="
set "TARGET_PATH="

:parse
if "%~1"=="" goto :parse_done
if /i "%~1"=="--update" set "UPDATE=1" & shift & goto :parse
if /i "%~1"=="--help" goto :help
if not defined TARGET_PATH set "TARGET_PATH=%~1" & shift & goto :parse
goto :parse_done

:parse_done
if not defined TARGET_PATH set /p "TARGET_PATH=Enter path to target project: "
if not defined TARGET_PATH (
    echo Error: No target path provided.
    exit /b 1
)

for /f "delims=" %%i in ("%TARGET_PATH%") do set "TARGET_PATH=%%~fi"

if not exist "%TARGET_PATH%\*" (
    echo Error: Directory '%TARGET_PATH%' does not exist.
    exit /b 1
)

set "AGENT_DIR=%TARGET_PATH%\.agent"
set "SRC_DIR=%AGENT_DIR%\src"
set "RULES_DIR=%AGENT_DIR%\rules"
set "ARCHIVE_DIR=%AGENT_DIR%\archive"
set "TEMP_DIR=%TARGET_PATH%\.temp"

set "VERSION=?"
if exist "%METAAGENT_SRC%\VERSION" (
    for /f "usebackq delims=" %%v in ("%METAAGENT_SRC%\VERSION") do (
        if "!VERSION!"=="?" set "VERSION=%%v"
    )
)

mkdir "%SRC_DIR%" 2>nul
mkdir "%RULES_DIR%" 2>nul
mkdir "%ARCHIVE_DIR%" 2>nul
mkdir "%TEMP_DIR%" 2>nul

echo Installing MetaAgent v%VERSION% -^> %SRC_DIR%

REM --- .gitignore ---
if not exist "%TARGET_PATH%\.gitignore" (
    > "%TARGET_PATH%\.gitignore" echo .temp/
    echo   [create] .gitignore (.temp/^)
    ) else (
        findstr /x /c:".temp/" "%TARGET_PATH%\.gitignore" >nul 2>&1
        if !errorlevel! neq 0 (
            >> "%TARGET_PATH%\.gitignore" echo .temp/
            echo   [update] .gitignore (added .temp/^)
        ) else (
            echo   [skip] .gitignore (.temp/ already present^)
        )
)

REM --- copy files ---
call :copy_file "%METAAGENT_SRC%META_AGENT_GUIDE.md" "%SRC_DIR%"
call :copy_file "%METAAGENT_SRC%BOUNDARIES.md" "%SRC_DIR%"
call :copy_file "%METAAGENT_SRC%WORKFLOW.md" "%SRC_DIR%"
call :copy_file "%METAAGENT_SRC%VERSION" "%SRC_DIR%"
call :copy_dir  "%METAAGENT_SRC%PROTOCOLS" "%SRC_DIR%"
call :copy_dir  "%METAAGENT_SRC%TEMPLATES" "%SRC_DIR%"
call :copy_file "%METAAGENT_SRC%install.sh" "%SRC_DIR%"
call :copy_file "%METAAGENT_SRC%install.ps1" "%SRC_DIR%"

REM --- AGENTS.md ---
set "NEED_AGENTS="
if not exist "%TARGET_PATH%\AGENTS.md" set "NEED_AGENTS=1"
if "%UPDATE%"=="1" set "NEED_AGENTS=1"
if defined NEED_AGENTS (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $t = (Get-Content '%METAAGENT_SRC:\=\\%AGENTS.template.md' -Encoding UTF8 -Raw) -replace '{VERSION}', ((Get-Content '%METAAGENT_SRC:\=\\%VERSION' -Encoding UTF8 -Raw).Trim()); [System.IO.File]::WriteAllBytes('%TARGET_PATH:\=\\%\AGENTS.md', [System.Text.Encoding]::UTF8.GetBytes($t)) }"
    if !errorlevel! equ 0 (
        echo   [create/update] AGENTS.md
    ) else (
        echo   [error] AGENTS.md (powershell failed^)
    )
) else (
    echo   [skip] AGENTS.md (exists, use --update to overwrite^)
)

echo.
setlocal disabledelayedexpansion
echo Done! MetaAgent v%VERSION% installed at %SRC_DIR%
setlocal enabledelayedexpansion
exit /b 0

REM ============ FUNCTIONS ============

:copy_file
set "SRC_FILE=%~1"
set "DST_DIR=%~2"
for %%i in ("%SRC_FILE%") do set "FNAME=%%~nxi"
if not exist "%SRC_FILE%" (
    echo   [skip] !FNAME! (not found^)
    goto :eof
)
if exist "%DST_DIR%\!FNAME!" (
    if not "%UPDATE%"=="1" (
        echo   [skip] !FNAME! (exists, use --update to overwrite^)
        goto :eof
    )
)
copy /Y "%SRC_FILE%" "%DST_DIR%\!FNAME!" >nul
if !errorlevel! equ 0 (
    echo   [copy] !FNAME!
) else (
    echo   [error] !FNAME!
)
goto :eof

:copy_dir
set "SRC_DIR_IN=%~1"
set "DST_PARENT=%~2"
for %%i in ("%SRC_DIR_IN%") do set "DNAME=%%~nxi"
if not exist "%SRC_DIR_IN%\*" (
    echo   [skip] !DNAME!/ (not found^)
    goto :eof
)
if not exist "%DST_PARENT%\!DNAME!" mkdir "%DST_PARENT%\!DNAME!" >nul 2>&1
xcopy /E /I /Y /Q "%SRC_DIR_IN%\*" "%DST_PARENT%\!DNAME!\" >nul 2>&1
echo   [copy] !DNAME!/
goto :eof

:help
echo Usage: install.bat [--update] [target_path]
echo.
echo Install MetaAgent sources into ^<target^>/.agent/src/
echo.
echo Options:
echo   --update    Overwrite existing files in .agent/src/
echo   --help      Show this help
echo.
echo Examples:
echo   install.bat
echo   install.bat C:\Projects\MyApp
echo   install.bat --update C:\Projects\MyApp
exit /b 0
