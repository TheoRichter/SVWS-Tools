# SVWS-Tools beim SVWS-Server unter Windows

## Download-Link zur Datei **tools.zip**:

https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip

## Anleitung

### Einbinden der SVWS-Tools Conference, Gradehub, Import, Laufbahnplanung und Prognos

In der **svwsconfig.json** folgendes Eintragen:

**AppsPath" : "C:\\ProgramData\\SVWS-Server/tools",**

![svwsconfig](graphics/svwsconfig.png)

in dem Verzeichniss **"C:\ProgramData\SVWS-Server"** *(wenn der SVWS-Server unter C: installiert ist!?)*

dort bitte die Datei **tools.zip** entpacken.

![ProgamData](graphics/ProgramData.png)

Den Dienst SVWS-Java-Service neu Starten.

![SVWS-Java-Service](graphics/SVWS-Java-Service.png)

Im Browser https://localhost/app/start eingeben und es müsste das Erscheinen.

![tools](graphics/tools.png)

