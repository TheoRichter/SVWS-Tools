@echo off
setlocal
title SVWS-Tools installieren

REM =====================================================
REM SVWS-Tools herunterladen, entpacken und konfigurieren
REM =====================================================

set "BASE=C:\ProgramData\SVWS-Server"
set "TOOLSDIR=%BASE%\tools"
set "CONFIG=%BASE%\res\svwsconfig.json"
set "ZIP=%TEMP%\tools.zip"
set "URL=https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip"
set "SERVICE=SVWS-Java-Service"
set "BROWSERURL=https://localhost/app/start"

echo.
echo ==========================================
echo       SVWS-Tools Installation
echo ==========================================
echo.

REM Administratorrechte pruefen
net session >nul 2>&1
if errorlevel 1 (
    echo FEHLER: Bitte als Administrator ausfuehren!
    pause
    exit /b 1
)

REM PowerShell-Skript temporaer erstellen
set "PSFILE=%TEMP%\svws-tools-install.ps1"

> "%PSFILE%" echo $ErrorActionPreference = 'Stop'
>>"%PSFILE%" echo $base = 'C:\ProgramData\SVWS-Server'
>>"%PSFILE%" echo $tools = Join-Path $base 'tools'
>>"%PSFILE%" echo $config = Join-Path $base 'res\svwsconfig.json'
>>"%PSFILE%" echo $zip = Join-Path $env:TEMP 'tools.zip'
>>"%PSFILE%" echo $url = 'https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip'
>>"%PSFILE%" echo $backup = "$config.bak"
>>"%PSFILE%" echo.
>>"%PSFILE%" echo if (-not (Test-Path $base)) { throw "SVWS-Ordner nicht gefunden: $base" }
>>"%PSFILE%" echo if (-not (Test-Path $config)) { throw "Konfigurationsdatei nicht gefunden: $config" }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '1. Lade tools.zip herunter...'
>>"%PSFILE%" echo [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
>>"%PSFILE%" echo Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '2. Entpacke Tools...'
>>"%PSFILE%" echo New-Item -ItemType Directory -Path $tools -Force ^| Out-Null
>>"%PSFILE%" echo Expand-Archive -LiteralPath $zip -DestinationPath $tools -Force
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '3. Sichere und aktualisiere svwsconfig.json...'
>>"%PSFILE%" echo Copy-Item -LiteralPath $config -Destination $backup -Force
>>"%PSFILE%" echo $json = Get-Content -LiteralPath $config -Raw -Encoding UTF8 ^| ConvertFrom-Json
>>"%PSFILE%" echo $json ^| Add-Member -MemberType NoteProperty -Name AppsPath -Value 'C:\ProgramData\SVWS-Server/tools' -Force
>>"%PSFILE%" echo $json ^| ConvertTo-Json -Depth 100 ^| Set-Content -LiteralPath $config -Encoding UTF8
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '4. Starte SVWS-Java-Service neu...'
>>"%PSFILE%" echo Restart-Service -Name 'SVWS-Java-Service' -ErrorAction Stop
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '5. Oeffne Browser...'
>>"%PSFILE%" echo Start-Process 'https://localhost/app/strat'
>>"%PSFILE%" echo Write-Host 'Installation erfolgreich abgeschlossen.'
>>"%PSFILE%" echo Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
if errorlevel 1 (
    echo.
    echo FEHLER bei der Installation!
    echo Bitte die Meldung oben beachten.
    echo Die Sicherung der Konfiguration liegt gegebenenfalls unter:
    echo %CONFIG%.bak
    pause
    exit /b 1
)

del "%PSFILE%" >nul 2>&1

echo.
echo Installation erfolgreich abgeschlossen.
pause
endlocal
