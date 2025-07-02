@echo off
setlocal EnableDelayedExpansion

:: =============================================
::  TrainPON Setup Wizard v0.1
:: =============================================
title TrainPON Setup Wizard v0.1
color 1F
mode con: cols=80 lines=25

set "REPO=https://raw.githubusercontent.com/pcs666-de/TrainPON/main"
set "FILES=TrainPON.bat richtig.wav falsch.wav statistik.json streak.txt"
set "VOKS=lektion0.txt lektion1.txt lektion2.txt lektion3.txt lektion4.txt lektion5.txt lektion6.txt lektion7.txt lektion8.txt lektion9.txt lektion10.txt"
set "FORMS=formen_a-Deklination.txt formen_is_ea_id_Plural.txt formen_is_ea_id_Singular.txt formen_konsonantische-Deklination.txt formen_o-Deklination_maskulin.txt formen_o-Deklination_neutrum.txt formen_perfekt.txt"

cls
echo  =========================================
echo      Willkommen zum TrainPON Installer
echo  =========================================
echo.
echo Dieses Programm wird TrainPON installieren.
echo.
echo Lizenzbedingungen:
echo - Code von PCS
echo - Vokabeln aus PONTES 2022, Klett Verlag
echo - Nutzung nur zu Lernzwecken erlaubt.
echo.
choice /c JA /n /m "Akzeptieren Sie die Lizenzbedingungen? (J/N): "
if errorlevel 2 exit /b

echo.
choice /c JA /n /m "TrainPON installieren? (J/N): "
if errorlevel 2 exit /b

:: === Dateien herunterladen ===
cls
echo Lade Dateien herunter...
for %%F in (%FILES% %VOKS% %FORMS%) do (
    echo Lade %%F...
    curl -s -O "%REPO%/%%F"
)

echo.
echo Installation abgeschlossen!
echo Druecken Sie eine Taste, um TrainPON zu starten ...
pause >nul
start TrainPON.bat
exit /b
