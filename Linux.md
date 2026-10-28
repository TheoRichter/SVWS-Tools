# SVWS-Tools beim SVWS-Server unter Linux

## Einbinden der SVWS-Tools Conference, Gradehub, Import, Laufbahnplanung und Prognos

## Automatische Installation

 [Download der Batch-Datei](https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/SVWS-Tools-Installieren.sh)  

Die Datei **SVWS-Tools-Installieren.sh** entpacken und als root mit bash SVWS-Tools-Installieren.sh ausführen. 

![Bash](graphics/bash.png)

## Installations-Anleitung Schritt für Schritt 

### 1. Schritte

In der Datei **svwsconfig.json** im Pfad: /etc/app/svws/conf/ folgendes Eintragen:

**"AppsPath" : "../tools",**

![svwsconfig](graphics/svwsconfig.png)

### 2. Schritte

[Download der Datei **tools.zip** und diese in dem Verzeichniss **"/opt/app/svws/"** entpacken.](https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip)

### 3. Schritte

Den Dienst svws-service mit ***systemctl restart svws.service** neu Starten.

### 4. Schritte

Im Browser https://localhost:8443/app/start eingeben und es müsste das erscheinen.