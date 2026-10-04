@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title ViperHub NextGen Toolbox
color 0B

if /i "%~1"=="build" goto build
if /i "%~1"=="check" goto check
if /i "%~1"=="run" goto runtime_start
if /i "%~1"=="runtime" goto runtime_start
if /i "%~1"=="serve" goto runtime_serve
if /i "%~1"=="stop" goto runtime_stop
if /i "%~1"=="release" goto release
if /i "%~1"=="verify" goto verify
if /i "%~1"=="share" goto share_start
if /i "%~1"=="unshare" goto share_stop
if /i "%~1"=="link" goto share_link
if /i "%~1"=="log" goto share_log
if /i "%~1"=="status" goto share_status
if /i "%~1"=="help" goto help
if not "%~1"=="" goto unknown
call :powershell "scripts/toolbox-ui.ps1"
exit /b %ERRORLEVEL%

:menu
cls
echo.
echo       +----------------------------------------------------------+
echo       ^|  V I P E R H U B   N E X T G E N                       ^|
echo       ^|  Developer toolbox                              v0.3.0  ^|
echo       +----------------------------------------------------------+
echo.
if exist "work\runtime-server.pid" (
    echo       RUNTIME  [ON]   http://127.0.0.1:8766
) else (
    echo       RUNTIME  [OFF]  Start with option 3
)
echo.
echo       -- DEVELOPMENT --------------------------------------------
echo        1   Build source artifacts
echo        2   Check code, tests and artifact integrity
echo.
echo       -- POTASSIUM ----------------------------------------------
echo        3   Build + start local runtime server
echo        4   Stop local runtime server (and sharing)
echo        5   Open generated files
echo.
echo       -- SHARE WITH TESTERS -------------------------------------
echo        8   Share over the internet (background tunnel) + copy link
echo        9   Stop sharing (server keeps running)
echo        C   Copy the tester link   L   View access log
echo.
echo       -- RELEASE ------------------------------------------------
echo        6   Build release artifacts
echo        7   Verify release artifacts
echo.
echo       +----------------------------------------------------------+
echo       ^|  H  Help                                        0  Exit   ^|
echo       +----------------------------------------------------------+
echo.
choice /c 123456789CLH0 /n /m "       Choose [1-9, C, L, H, 0]: "
if errorlevel 13 goto end
if errorlevel 12 goto help_menu
if errorlevel 11 goto share_log
if errorlevel 10 goto share_link
if errorlevel 9 goto share_stop
if errorlevel 8 goto share_start
if errorlevel 7 goto verify
if errorlevel 6 goto release
if errorlevel 5 goto openwork
if errorlevel 4 goto runtime_stop
if errorlevel 3 goto runtime_start
if errorlevel 2 goto check
if errorlevel 1 goto build
goto menu

:build
cls
echo ==================== BUILD DEVELOPMENT ====================
call :powershell "scripts/build.ps1"
goto result

:check
cls
echo ====================== LOCAL CHECKS =======================
call :powershell "scripts/check.ps1"
goto result

:runtime_start
cls
echo ================= START POTASSIUM RUNTIME =================
call :powershell "scripts/start-runtime.ps1"
goto result

:runtime_serve
color 0A
title ViperHub Runtime Server - Port 8766
call :powershell "scripts/run-runtime.ps1"
set "exitCode=%ERRORLEVEL%"
echo.
echo Runtime server exited with code %exitCode%.
pause
exit /b %exitCode%

:share_start
cls
echo ================= SHARE WITH TESTERS ======================
call :powershell "scripts/share-runtime.ps1" -Action start
goto result

:share_stop
cls
echo ==================== STOP SHARING =========================
call :powershell "scripts/share-runtime.ps1" -Action stop
goto result

:share_link
cls
echo ===================== TESTER LINK =========================
call :powershell "scripts/share-runtime.ps1" -Action link
goto result

:share_log
cls
echo ==================== ACCESS LOG ===========================
call :powershell "scripts/share-runtime.ps1" -Action log
goto result

:share_status
call :powershell "scripts/share-runtime.ps1" -Action status
exit /b %ERRORLEVEL%

:runtime_stop
cls
echo ================== STOP POTASSIUM RUNTIME =================
call :powershell "scripts/stop-runtime.ps1"
goto result

:release
cls
echo ====================== BUILD RELEASE ======================
call :powershell "scripts/build.ps1" -Release
goto result

:verify
cls
echo ===================== VERIFY RELEASE ======================
call :powershell "scripts/verify-release.ps1"
goto result

:openwork
if not exist "work" mkdir "work"
start "" explorer.exe "%CD%\work"
goto menu

:powershell
where pwsh.exe >nul 2>nul
if not errorlevel 1 (
    pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0%~1" %2 %3 %4 %5 %6 %7 %8 %9
) else (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0%~1" %2 %3 %4 %5 %6 %7 %8 %9
)
exit /b %ERRORLEVEL%

:result
set "exitCode=%ERRORLEVEL%"
echo.
if "%exitCode%"=="0" (
    color 0A
    echo [SUCCESS] Operation completed successfully.
) else (
    color 0C
    echo [FAILED] Operation exited with code %exitCode%.
)
if not "%~1"=="" exit /b %exitCode%
echo.
pause
color 0B
goto menu

:help_menu
call :show_help
pause
goto menu

:help
call :show_help
exit /b 0

:show_help
cls
echo.
echo       +----------------------------------------------------------+
echo       ^|  VIPERHUB NEXTGEN  /  QUICK COMMANDS                   ^|
echo       +----------------------------------------------------------+
echo.
echo        build     Build development artifacts
echo        check     Run all local checks
echo        run       Build and open runtime server window
echo        stop      Stop runtime server
echo        share     Share the runtime with remote testers (tunnel)
echo        unshare   Stop sharing
echo        link      Copy the tester link again
echo        log       Show recent runtime requests
echo        status    Show server and sharing status
echo        release   Build release artifacts
echo        verify    Verify release artifacts
echo        help      Show this page
echo.
echo       -- PASTE ONCE IN POTASSIUM --------------------------------
echo        loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()
echo       ----------------------------------------------------------
echo        Remote testers get the link from "ViperHub.cmd share".
echo        Anyone with that link can download the dev script.
echo.
exit /b 0

:unknown
color 0C
echo Unknown command: %~1
echo Run ViperHub.cmd help for available commands.
exit /b 2

:end
endlocal
exit /b 0
