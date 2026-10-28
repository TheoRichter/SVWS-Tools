@echo off
setlocal
title SVWS-Tools installieren

REM =====================================================
REM SVWS-Tools herunterladen, entpacken und konfigurieren
REM =====================================================

set "BASE=C:\ProgramData\SVWS-Server"
set "CONFIG=%BASE%\res\svwsconfig.json"
set "ZIP=%TEMP%\tools.zip"
set "PSFILE=%TEMP%\svws-tools-install.ps1"

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

REM PowerShell-Skript erstellen
> "%PSFILE%" echo $ErrorActionPreference = 'Stop'
>>"%PSFILE%" echo $base = 'C:\ProgramData\SVWS-Server'
>>"%PSFILE%" echo $config = Join-Path $base 'res\svwsconfig.json'
>>"%PSFILE%" echo $zip = Join-Path $env:TEMP 'tools.zip'
>>"%PSFILE%" echo $url = 'https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip'
>>"%PSFILE%" echo $appsPath = 'C:\\ProgramData\\SVWS-Server/tools'
>>"%PSFILE%" echo.
>>"%PSFILE%" echo if (-not (Test-Path $base)) { throw "SVWS-Ordner nicht gefunden: $base" }
>>"%PSFILE%" echo if (-not (Test-Path $config)) { throw "Konfigurationsdatei nicht gefunden: $config" }
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '1. Lade tools.zip herunter...'
>>"%PSFILE%" echo [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
>>"%PSFILE%" echo Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '2. Entpacke tools.zip direkt in den SVWS-Server-Ordner...'
>>"%PSFILE%" echo Expand-Archive -LiteralPath $zip -DestinationPath $base -Force
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '3. Sichere und aktualisiere svwsconfig.json...'
>>"%PSFILE%" echo Copy-Item -LiteralPath $config -Destination "$config.bak" -Force
>>"%PSFILE%" echo $content = Get-Content -LiteralPath $config -Raw -Encoding UTF8
>>"%PSFILE%" echo $pattern = '(?m)^([ \t]*"AppsPath"[ \t]*:[ \t]*)null([ \t]*,?)'
>>"%PSFILE%" echo if ([regex]::IsMatch($content, $pattern)) {
>>"%PSFILE%" echo     $content = [regex]::Replace($content, $pattern, ('$1"' + $appsPath + '"$2'), 1)
>>"%PSFILE%" echo } elseif ([regex]::IsMatch($content, '(?m)^[ \t]*"AppsPath"[ \t]*:')) {
>>"%PSFILE%" echo     $content = [regex]::Replace($content, '(?m)^([ \t]*"AppsPath"[ \t]*:[ \t]*)("[^"]*"|null)([ \t]*,?)', ('$1"' + $appsPath + '"$3'), 1)
>>"%PSFILE%" echo } else {
>>"%PSFILE%" echo     $adminPattern = '(?m)^([ \t]*)"AdminClientPath"[ \t]*:[ \t]*("[^"]*")[ \t]*,?[ \t]*$'
>>"%PSFILE%" echo     if (-not [regex]::IsMatch($content, $adminPattern)) { throw 'AdminClientPath wurde nicht gefunden.' }
>>"%PSFILE%" echo     $content = [regex]::Replace($content, $adminPattern, ('$1"AdminClientPath" : $2,' + "`r`n" + '$1"AppsPath" : "' + $appsPath + '",'), 1)
>>"%PSFILE%" echo }
>>"%PSFILE%" echo $null = $content ^| ConvertFrom-Json
>>"%PSFILE%" echo [System.IO.File]::WriteAllText($config, $content, (New-Object System.Text.UTF8Encoding($false)))
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '4. Starte SVWS-Java-Service neu...'
>>"%PSFILE%" echo Restart-Service -Name 'SVWS-Java-Service' -ErrorAction Stop
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Write-Host '5. Oeffne Browser...'
>>"%PSFILE%" echo Start-Process 'https://localhost/app/start'
>>"%PSFILE%" echo.
>>"%PSFILE%" echo Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
>>"%PSFILE%" echo Write-Host 'Installation erfolgreich abgeschlossen.'

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
set "RC=%ERRORLEVEL%"

del "%PSFILE%" >nul 2>&1

if not "%RC%"=="0" (
    echo.
    echo FEHLER bei der Installation!
    echo Bitte die Fehlermeldung oben beachten.
    echo Sicherung der Konfiguration: %CONFIG%.bak
    pause
    exit /b 1
)

echo.
echo Installation erfolgreich abgeschlossen.
pause
endlocal