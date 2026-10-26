# SVWS-Tools beim SVWS-Server unter Windows

## Download-Link zur Datei **tools.zip**:

https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip

## Einbinden der SVWS-Tools Conference, Gradehub, Import, Laufbahnplanung und Prognos

## Anleitung

### 1. Schritte

---

### Hinweis: 

Es kann sein das ProgrammData nicht angezeigt wird!

![Ausgeblendet](graphics/ausgeblendet.png)

---

In der **svwsconfig.json** im Pfad: C:\ProgrammData\SVWS-Server\res\  folgendes Eintragen:

**AppsPath" : "C:\\ProgramData\\SVWS-Server/tools",**

![svwsconfig](graphics/svwsconfig.png)

### 2. Schritte

in dem Verzeichniss **"C:\ProgramData\SVWS-Server"** *(wenn der SVWS-Server unter C: installiert ist!?)

dort bitte die Datei **tools.zip** entpacken.

![ProgamData](graphics/ProgramData.png)

### 3. Schritte

Den Dienst SVWS-Java-Service neu Starten.

![SVWS-Java-Service](graphics/SVWS-Java-Service.png)

### 4. Schritte

Im Browser https://localhost/app/start eingeben und es müsste das Erscheinen.

![tools](graphics/tools.png)

