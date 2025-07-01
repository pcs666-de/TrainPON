@echo off
setlocal EnableDelayedExpansion

:: ==============================================
::  TrainPON Installer - Erstinstallation & Setup
:: ==============================================
title TrainPON Installer
color 0A
mode con: cols=85 lines=25

set "REPO_RAW=https://raw.githubusercontent.com/pcs666-de/TrainPON/main"
set "FILES=TrainPON.bat lektion0.txt lektion1.txt lektion2.txt lektion3.txt lektion4.txt lektion5.txt lektion6.txt lektion7.txt lektion8.txt lektion9.txt lektion10.txt richtig.wav falsch.wav"
set "FORMEN=formen_a-Deklination.txt formen_is_ea_id_Plural.txt formen_is_ea_id_Singular.txt formen_konsonantische-Deklination.txt formen_o-Deklination_maskulin.txt formen_o-Deklination_neutrum.txt formen_perfekt.txt"

:: === Willkommensbildschirm ===
echo =====================================================
echo         Willkommen zum TrainPON-Installer
echo -----------------------------------------------------
echo  Das Programm wird alle benoetigten Dateien laden.
echo =====================================================
echo.
pause

:: === Verzeichnis anlegen ===
echo [*] Erstelle Ordner TrainPON ...
mkdir TrainPON >nul 2>&1
cd TrainPON

:: === Dateien herunterladen ===
echo [*] Lade noetige Dateien herunter ...

for %%F in (%FILES%) do (
    echo    > Lade %%F ...
    curl -s -O %REPO_RAW%/%%F
)

for %%F in (%FORMEN%) do (
    echo    > Lade %%F ...
    curl -s -O %REPO_RAW%/%%F
)

:: === Pruefen, ob alles da ist ===
echo.
echo [*] Pruefe heruntergeladene Dateien ...
set "missing=0"

for %%F in (%FILES%) do (
    if not exist %%F echo [FEHLT] %%F & set /a missing+=1
)

for %%F in (%FORMEN%) do (
    if not exist %%F echo [FEHLT] %%F & set /a missing+=1
)

if !missing! NEQ 0 (
    echo.
    echo [!] Es fehlen !missing! Dateien. Bitte manuell pruefen.
    pause
    exit /b
)

:: === Abschluss ===
echo.
echo [OK] Alle Dateien wurden erfolgreich installiert!
echo.
echo Du kannst das Programm nun starten:
echo.
echo    TrainPON.bat

pause
start TrainPON.bat
exit /b
