@echo off
setlocal EnableDelayedExpansion

:: =================================================
::  TrainPON - Latein Vokabeltrainer (Offline-Version)
:: =================================================
title TrainPON - Latein Vokabeltrainer
color 0A
mode con: cols=85 lines=40

set "VERSION=1.1"
set "REPO=https://raw.githubusercontent.com/pcs666-de/TrainPON/main"
set "SELF=%~nx0"
set "STATS=statistiken.json"
set "STREAK=streak.txt"

:: === Beim Start automatisch Update pruefen ===
call :CHECK_FOR_UPDATE

:: === Banner ===
:START
cls
echo:
echo  ==============================================
echo       TrainPON - Latein Vokabeltrainer v%VERSION%
echo  ==============================================
echo        von OfficialPixelPower (GitHub: pcs666-de)
echo:
call :LOAD_STREAK
call :SHOW_STATS

echo [1] Training starten
echo [2] Statistiken anzeigen
echo [3] Beenden
choice /c 123 /n /m "Auswahl: "
if errorlevel 3 exit /b
if errorlevel 2 call :SHOW_STATS & pause & goto START
if errorlevel 1 call :TRAINING & goto START

:: === Trainingsmodus ===
:TRAINING
cls
echo *** Training ***
echo.
set /p lek=Welche Lektion? (z.B. lektion1.txt): 
if not exist !lek! echo [!] Datei nicht gefunden & pause & goto START

:LOOP
set /a r=%RANDOM% %% 2
if !r! EQU 0 (
    for /f "tokens=1,2 delims==" %%A in ('findstr "=" !lek! ^| sort /R') do (
        set "frage=%%A"
        set "antwort=%%B"
        goto :ASK
    )
) else (
    for %%F in (formen*.txt) do (
        for /f "tokens=1,2 delims==" %%A in ('findstr "=" %%F ^| sort /R') do (
            set "frage=%%A"
            set "antwort=%%B"
            goto :ASK
        )
    )
)

:ASK
cls
echo Was heisst: !frage!
echo.
set /p input=Antwort: 
if /i "!input!" == "!antwort!" (
    echo ✅ Richtig!
    call :SOUND richtig.wav
    call :UPDATE_STATS richtig
) else (
    echo ❌ Falsch. Richtig waere: !antwort!
    call :SOUND falsch.wav
    call :UPDATE_STATS falsch
)
call :UPDATE_STREAK
pause
goto LOOP

:: === Streak laden ===
:LOAD_STREAK
if not exist %STREAK% (
    echo %DATE%,1 > %STREAK%
)
for /f "tokens=1,2 delims=," %%A in (%STREAK%) do (
    set "LASTDATE=%%A"
    set "COUNT=%%B"
)
set "TODAY=%DATE%"
if "%TODAY%"=="%LASTDATE%" (
    echo 🔥 Streak: %COUNT% Tage
) else (
    set /a COUNT+=1
    echo %DATE%,!COUNT! > %STREAK%
    echo 🔥 Neuer Tag! Streak: !COUNT! Tage
)
exit /b

:: === Streak aktualisieren ===
:UPDATE_STREAK
>nul
exit /b

:: === Sound abspielen ===
:SOUND
powershell -c "(New-Object Media.SoundPlayer '%~1').PlaySync();"
exit /b

:: === Statistik aktualisieren ===
:UPDATE_STATS
setlocal EnableDelayedExpansion
set "typ=%1"
if not exist %STATS% echo {"richtig":0,"falsch":0} > %STATS%
(for /f "delims=" %%L in (%STATS%) do set "line=%%L")
set /a richtig=0
set /a falsch=0
for %%C in (richtig falsch) do (
    for /f "tokens=2 delims=:,}" %%V in ("!line:":=!") do (
        if "%%C"=="%typ%" set /a %%C=%%V+1
    )
)
echo {"richtig":!richtig!,"falsch":!falsch!} > %STATS%
endlocal
exit /b

:: === Statistiken anzeigen ===
:SHOW_STATS
cls
echo === Statistiken ===
if exist %STATS% (
    type %STATS%
) else (
    echo Noch keine Daten vorhanden.
)
echo.
exit /b

:: === Auto-Update-Pruefung ===
:CHECK_FOR_UPDATE
curl -s -o latest.bat %REPO%/TrainPON.bat
fc /B "%~f0" latest.bat >nul
if %errorlevel%==0 (
    del latest.bat >nul
    goto :EOF
) else (
    echo Update verfuegbar! Wird installiert ...
    timeout /t 2 >nul
    copy /Y latest.bat "%~f0" >nul
    echo Update abgeschlossen. Starte neu ...
    start "" "%~f0"
    exit /b
)
exit /b
