@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==========================================
REM SVWS-Tools herunterladen und installieren
REM Windows 10 / Windows 11
REM ==========================================

title SVWS-Tools Installation

echo.
echo ==========================================
echo        SVWS-Tools Installation
echo ==========================================
echo.
echo 1^) conference
echo 2^) info
echo 3^) gradhub
echo 4^) prognos
echo 5^) laufbahn
echo.

set "AUSWAHL="
set /p "AUSWAHL=Tool eingeben (1-5): "

REM ==========================================
REM Tool konfigurieren
REM ==========================================

if "%AUSWAHL%"=="1" (
    set "TOOL=conference"
    set "REPO=SVWS-Conference"
    set "ZIP_PREFIX=svws-conference-"
    set "ZIP_SUFFIX=-webserver.zip"
    set "INSTALL_DIR=C:\ProgramData\SVWS-Server\tools\conference"
    goto VERSION
)

if "%AUSWAHL%"=="2" (
    set "TOOL=info"
    set "REPO=SVWS-Import"
    set "ZIP_PREFIX=SVWS-Import-"
    set "ZIP_SUFFIX=-webapp.zip"
    set "INSTALL_DIR=C:\ProgramData\SVWS-Server\tools\info"
    goto VERSION
)

if "%AUSWAHL%"=="3" (
    set "TOOL=gradhub"
    set "REPO=SVWS-GradeHub"
    set "ZIP_PREFIX=gradehub-"
    set "ZIP_SUFFIX=-webserver.zip"
    set "INSTALL_DIR=C:\ProgramData\SVWS-Server\tools\gradhub"
    goto VERSION
)

if "%AUSWAHL%"=="4" (
    set "TOOL=prognos"
    set "REPO=SVWS-Prognos"
    set "ZIP_PREFIX=svws-prognos-"
    set "ZIP_SUFFIX=-webserver.zip"
    set "INSTALL_DIR=C:\ProgramData\SVWS-Server\tools\prognos"
    goto VERSION
)

if "%AUSWAHL%"=="5" (
    set "TOOL=laufbahn"
    set "REPO=SVWS-Server"
    set "ZIP_PREFIX=SVWS-Laufbahnplanung-"
    set "ZIP_SUFFIX=.zip"
    set "INSTALL_DIR=C:\ProgramData\SVWS-Server\tools\laufbahn"
    goto VERSION
)

echo.
echo FEHLER: Ungueltige Auswahl.
pause
exit /b 1

REM ==========================================
REM Versionsnummer abfragen und pruefen
REM ==========================================

:VERSION

echo.
set "VERSION="
set /p "VERSION=Versionsnummer eingeben (z.B. 1.4.1): "

REM Erlaubt beispielsweise 1.4.1 oder 1.4.1-rc1
powershell.exe -NoProfile -Command ^
    "if ('%VERSION%' -match '^[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.-]+)?$') { exit 0 } else { exit 1 }"

if errorlevel 1 (
    echo.
    echo FEHLER: Ungueltige Versionsnummer: %VERSION%
    echo Beispiel: 1.4.1
    pause
    exit /b 1
)

REM ==========================================
REM Download-Informationen erstellen
REM ==========================================

set "ZIP_NAME=%ZIP_PREFIX%%VERSION%%ZIP_SUFFIX%"
set "DOWNLOAD_URL=https://github.com/SVWS-NRW/%REPO%/releases/download/v%VERSION%/%ZIP_NAME%"

REM ==========================================
REM Voraussetzungen pruefen
REM ==========================================

where curl.exe >nul 2>&1
if errorlevel 1 (
    echo FEHLER: curl.exe wurde nicht gefunden.
    pause
    exit /b 1
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Windows PowerShell wurde nicht gefunden.
    pause
    exit /b 1
)

REM ==========================================
REM Uebersicht und Bestaetigung
REM ==========================================

echo.
echo ==========================================
echo Tool:        %TOOL%
echo Version:     %VERSION%
echo Download:    %DOWNLOAD_URL%
echo Zielordner:  %INSTALL_DIR%
echo ZIP-Datei:   %ZIP_NAME%
echo ==========================================
echo.

choice /C JN /N /M "Installation starten? (J/N): "

if errorlevel 2 (
    echo Installation abgebrochen.
    exit /b 0
)

REM ==========================================
REM Temporäres Download-Verzeichnis
REM ==========================================

set "TEMP_DIR=%TEMP%\SVWS-Tools-%RANDOM%-%RANDOM%"
set "ZIP_FILE=%TEMP_DIR%\%ZIP_NAME%"

mkdir "%TEMP_DIR%" 2>nul

if not exist "%TEMP_DIR%" (
    echo FEHLER: Temporaeres Verzeichnis konnte nicht erstellt werden.
    pause
    exit /b 1
)

REM ==========================================
REM Download
REM ==========================================

echo.
echo Lade Datei herunter ...

curl.exe -fL --retry 2 --connect-timeout 20 ^
    -o "%ZIP_FILE%" "%DOWNLOAD_URL%"

if errorlevel 1 (
    echo.
    echo FEHLER: Download fehlgeschlagen.
    echo Bitte Version und Download-Adresse pruefen.
    echo Download-Verzeichnis: %TEMP_DIR%
    pause
    exit /b 1
)

REM ==========================================
REM ZIP-Datei pruefen
REM ==========================================

echo.
echo Pruefe ZIP-Datei ...

powershell.exe -NoProfile -Command ^
    "Add-Type -AssemblyName System.IO.Compression.FileSystem; try { $z = [System.IO.Compression.ZipFile]::OpenRead('%ZIP_FILE%'); if ($z.Entries.Count -eq 0) { throw 'ZIP-Datei ist leer' }; $z.Dispose(); Write-Host 'ZIP-Datei ist gueltig.'; exit 0 } catch { Write-Host ('FEHLER: ' + $_.Exception.Message); exit 1 }"

if errorlevel 1 (
    echo.
    echo FEHLER: ZIP-Datei konnte nicht geprueft werden.
    echo Die Datei bleibt zur Analyse erhalten:
    echo %ZIP_FILE%
    pause
    exit /b 1
)

REM ==========================================
REM Zielverzeichnis erstellen
REM ==========================================

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

if not exist "%INSTALL_DIR%" (
    echo FEHLER: Zielverzeichnis konnte nicht erstellt werden.
    echo Bitte Schreibrechte pruefen.
    pause
    exit /b 1
)

REM ==========================================
REM ZIP-Datei entpacken
REM ==========================================

echo.
echo Entpacke Dateien nach:
echo %INSTALL_DIR%
echo.

powershell.exe -NoProfile -Command ^
    "try { Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath '%INSTALL_DIR%' -Force -ErrorAction Stop; Write-Host 'Entpacken erfolgreich.'; exit 0 } catch { Write-Host ('FEHLER: ' + $_.Exception.Message); exit 1 }"

if errorlevel 1 (
    echo.
    echo FEHLER: Entpacken fehlgeschlagen.
    echo ZIP-Datei bleibt erhalten:
    echo %ZIP_FILE%
    pause
    exit /b 1
)

REM ==========================================
REM Temporäre Dateien loeschen
REM ==========================================

del /q "%ZIP_FILE%" 2>nul
rmdir /s /q "%TEMP_DIR%" 2>nul

REM ==========================================
REM Abschlussmeldung
REM ==========================================

echo.
echo ==========================================
echo Installation erfolgreich abgeschlossen!
echo ==========================================
echo Tool:        %TOOL%
echo Version:     %VERSION%
echo Verzeichnis: %INSTALL_DIR%
echo ZIP-Datei:   geloescht
echo ==========================================
echo.

pause
exit /b 0