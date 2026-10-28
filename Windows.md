# SVWS-Tools beim SVWS-Server unter Windows

## Einbinden der SVWS-Tools Conference, Gradehub, Import, Laufbahnplanung und Prognos

## Automatische Installation

 [Download der Batch-Datei](https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/SVWS-Tools-Installieren.zip)  

Die Datei **SVWS-Tools-Installieren.zip** entpacken und als Administrator start. 

![Administartor](graphics/administartor.png)

## Installations-Anleitung Schritt für Schritt 

### 1. Schritte

---

### Hinweis: 

Es kann sein das ProgrammData nicht angezeigt wird!

![Ausgeblendet](graphics/ausgeblendet.png)

---

In der Datei **svwsconfig.json** im Pfad: C:\ProgrammData\SVWS-Server\res\ folgendes Eintragen:

**"AppsPath" : "C:\\ProgramData\\SVWS-Server/tools",**

![svwsconfig](graphics/svwsconfig_windows.png)

### 2. Schritte

[Download der Datei **tools.zip** und diese in dem Verzeichniss **"C:\ProgramData\SVWS-Server"** entpacken.](https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip)

(wenn der SVWS-Server unter C: installiert ist !?!)

![ProgamData](graphics/ProgramData.png)

### 3. Schritte

Den Dienst SVWS-Java-Service neu Starten.

![SVWS-Java-Service](graphics/SVWS-Java-Service.png)

### 4. Schritte

Im Browser https://localhost/app/start eingeben und es müsste das erscheinen.

![tools](graphics/tools.png)

