@echo off
setlocal EnableDelayedExpansion

:: ==============================================================
::  TrainPON - Latein Vokabeltrainer v0.2 by PCS (final)
:: ==============================================================
title TrainPON - Latein Vokabeltrainer v0.2
:: Hacker-Grün auf Schwarz
color 0A
mode con: cols=80 lines=25

set "VERSION=0.2"
set "STATS=statistik.json"
set "STREAK_FILE=streak.txt"
set "REPO=https://raw.githubusercontent.com/pcs666-de/TrainPON/main"

:: === Auto-Update ===
echo Pruefe auf Updates...
curl -s -o latest.bat "%REPO%/TrainPON.bat"
fc /B "%~nx0" latest.bat >nul 2>&1 && del latest.bat || (
    move /Y latest.bat "%~nx0" >nul
    echo Update installiert, starte neu...
    timeout /t 2 >nul
    start "" "%~nx0"
    exit /b
)

:: === Initialisierung Statistik/Streak ===
if not exist "%STATS%" echo {"richtig":0,"falsch":0} > "%STATS%"
if not exist "%STREAK_FILE%" echo %DATE%,0 > "%STREAK_FILE%"

:: === Lesen Streak ===
set "LASTDATE=" & set "STREAK=0"
for /f "tokens=1,2 delims=," %%A in (%STREAK_FILE%) do (
  set "LASTDATE=%%A" & set "STREAK=%%B"
)
if not defined LASTDATE set "LASTDATE=%DATE%"
if not defined STREAK set "STREAK=0"

:MAIN_MENU
cls

:: Zeichne Menü
echo +------------------------------------------------+
echo ^|      TrainPON v%VERSION% - Vokabeltrainer         ^|
echo +------------------------------------------------+
if "%DATE%" neq "%LASTDATE%" call :INCREMENT_STREAK
echo ^| Streak: %STREAK% Tag(e)                              ^|
echo +------------------------------------------------+
echo ^| 1) Vokabeltraining                               ^|
echo ^| 2) Formentraining                                ^|
echo ^| 3) Tutorial                                       ^|
echo ^| 4) Lizenzen                                       ^|
echo ^| 5) Dateien bearbeiten                             ^|
echo ^| 6) Statistiken                                    ^|
echo ^| 7) Uninstall                                      ^|
echo ^| 8) Beenden                                        ^|
echo +------------------------------------------------+
choice /c 12345678 /n /m "Auswahl: "
set "CHOICE=%errorlevel%"
if "%CHOICE%"=="8" exit /b
if "%CHOICE%"=="7" goto :UNINSTALL
if "%CHOICE%"=="6" (call :SHOW_STATS & pause & goto MAIN_MENU)
if "%CHOICE%"=="5" (call :EDIT_FILES & goto MAIN_MENU)
if "%CHOICE%"=="4" (call :SHOW_LICENSE & pause & goto MAIN_MENU)
if "%CHOICE%"=="3" (call :SHOW_TUTORIAL & pause & goto MAIN_MENU)
if "%CHOICE%"=="2" (set "TYPE=formen" & goto START_TRAIN)
if "%CHOICE%"=="1" (set "TYPE=lektion" & goto START_TRAIN)
goto MAIN_MENU

:START_TRAIN
cls
echo Verfuegbare %TYPE%-Dateien:
for %%F in (%TYPE%*.txt) do echo    %%~nF
set /p "NAME=Dateikuerzel (ohne .txt): "
set "FILE=%NAME%.txt"
if not exist "%FILE%" echo Datei nicht gefunden & pause & goto MAIN_MENU

echo Modus waehlen:
echo 1) Reihenfolge
echo 2) Zufall
choice /c 12 /n /m "Modus: "
if errorlevel 2 (set "MODE=random") else set "MODE=seq"

call :TRAIN_LOOP "%FILE%"

goto MAIN_MENU

:TRAIN_LOOP
setlocal EnableDelayedExpansion
set "F=%~1"
set /a COUNT=0
for /f "tokens=1,* delims==" %%A in ('type "%F%"') do (
  set /a COUNT+=1
  set "Q!COUNT!=%%A"
  set "A!COUNT!=%%B"
)
set /a IDX=0
:ASK_LOOP
cls
echo (Leer + Enter starten)
set /p dummy= 
if "%MODE%"=="random" (
  set /a IDX=!random! %% COUNT + 1
) else (
  set /a IDX+=1
  if !IDX! GTR %COUNT% endlocal & exit /b
)
echo Frage: !Q%IDX%!?
set /p "RESP=Antwort: "
if /i "!RESP!"=="!A%IDX%!" (
  echo Richtig!
  call :PLAY_SOUND richtig.wav
  call :UPDATE_STATS richtig
) else (
  echo Falsch. Richtig: !A%IDX%!
  call :PLAY_SOUND falsch.wav
  call :UPDATE_STATS falsch
)
pause
goto ASK_LOOP

:SHOW_TUTORIAL
cls
echo --- Tutorial ---
echo 1) Waehl Vokabel-/Formentraining
echo 2) Gib Dateikuerzel (ohne .txt) ein
echo 3) Leer + Enter startet Frage
echo 4) Gib Antwort wie im Buch ein (z.B. 1P SG AKK)
echo 5) Streak +1 pro Tag, Auslassen resetet
exit /b

:SHOW_LICENSE
cls
echo --- Lizenzen ---
echo Code: PCS (TrainPON Projekt)
echo Vokabeln: PONTES 2022, Ernst Klett Verlag
echo Nur fuer Lernzwecke
echo.
echo   ____   ____ ____  
echo  |  _ \ / ___/ ___| 
echo  | |_) | |   \___ \ 
echo  |  __/| |___ ___) |
echo  |_|    \____|____/ 
exit /b

:EDIT_FILES
cls
echo --- Dateien bearbeiten ---
for %%F in (lektion*.txt formen*.txt) do echo    %%~nF
set /p "EDIT=Kuerzel: "
set "EDITF=%EDIT%.txt"
if exist "%EDITF%" (start notepad "%EDITF%") else echo Datei nicht gefunden
pause
exit /b

:SHOW_STATS
cls
echo --- Statistiken ---
type %STATS%
exit /b

:UPDATE_STATS
setlocal EnableDelayedExpansion
set "T=%1"
for /f "delims=" %%L in (%STATS%) do set "L=%%L"
for %%K in (richtig falsch) do for /f "tokens=2 delims=:,}" %%V in ("!L:":=!" ) do (
  if "%%K"=="%T%" set /a %%K=%%V+1
  if "%%K" neq "%T%" set /a %%K=%%V
)
echo {"richtig":!richtig!,"falsch":!falsch!} > %STATS%
endlocal
exit /b

:INCREMENT_STREAK
set /a NEWST=%STREAK%+1
echo Aktualisiere Streak auf %NEWST%...
for /L %%i in (1,1,20) do (<nul set /p=.) & timeout /t 0 >nul
echo.
 echo %DATE%,%NEWST% > %STREAK_FILE%
set "STREAK=%NEWST%"
exit /b

:PLAY_SOUND
powershell -c "(New-Object Media.SoundPlayer '%~1').PlaySync();" >nul 2>&1
exit /b

:UNINSTALL
cls
echo Loeschen aller Dateien? (J/N)
choice /c JN /n /m "Auswahl: "
if errorlevel 2 goto MAIN_MENU
echo Loesche...
del /Q TrainPON.bat richtig.wav falsch.wav %STATS% %STREAK_FILE% lektion*.txt formen*.txt
pause
exit /b
