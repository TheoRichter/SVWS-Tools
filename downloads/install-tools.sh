#!/bin/bash
set -Eeuo pipefail

# =========================================================
# SVWS-Tools installieren und konfigurieren
# =========================================================

TOOLS_URL="https://github.com/TheoRichter/SVWS-Tools/raw/refs/heads/main/downloads/tools.zip"

APP_DIR="/opt/app/svws"
CONFIG_FILE="/etc/app/svws/conf/svwsconfig.json"

ZIP_FILE="/tmp/svws-tools.zip"
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d-%H%M%S)"

SERVICE="svws.service"
BROWSER_URL="https://localhost:8443/app/start"

echo "================================================="
echo " SVWS-Tools Installation"
echo "================================================="

# ---------------------------------------------------------
# 1. Root-Rechte prüfen
# ---------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "FEHLER: Bitte als root oder mit sudo starten."
    exit 1
fi

# ---------------------------------------------------------
# 2. Voraussetzungen prüfen
# ---------------------------------------------------------

for CMD in curl unzip python3 systemctl; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo "FEHLER: $CMD ist nicht installiert."
        echo "Installation mit: apt install curl unzip python3"
        exit 1
    fi
done

# ---------------------------------------------------------
# 3. Verzeichnisse und Konfiguration prüfen
# ---------------------------------------------------------

if [ ! -d "$APP_DIR" ]; then
    echo "FEHLER: Verzeichnis $APP_DIR existiert nicht."
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "FEHLER: Konfigurationsdatei nicht gefunden:"
    echo "$CONFIG_FILE"
    exit 1
fi

# ---------------------------------------------------------
# 4. Sicherung der Konfiguration erstellen
# ---------------------------------------------------------

cp -a "$CONFIG_FILE" "$BACKUP_FILE"
echo "Sicherung erstellt: $BACKUP_FILE"

# ---------------------------------------------------------
# 5. tools.zip herunterladen
# ---------------------------------------------------------

echo
echo "Lade SVWS-Tools von GitHub herunter ..."

curl -fL --retry 3 "$TOOLS_URL" -o "$ZIP_FILE"

# ---------------------------------------------------------
# 6. ZIP prüfen und direkt entpacken
# ---------------------------------------------------------

echo
echo "Prüfe ZIP-Datei ..."

unzip -tq "$ZIP_FILE"

echo "Entpacke Dateien nach $APP_DIR ..."

unzip -oq "$ZIP_FILE" -d "$APP_DIR"

# ---------------------------------------------------------
# 7. svwsconfig.json bearbeiten
# ---------------------------------------------------------

echo
echo "Bearbeite $CONFIG_FILE ..."

python3 - "$CONFIG_FILE" <<'PYTHON'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])

try:
    config = json.loads(config_file.read_text(encoding="utf-8"))
except Exception as exc:
    print(f"FEHLER beim Lesen der JSON-Datei: {exc}")
    sys.exit(1)

if not isinstance(config, dict):
    print("FEHLER: Die Konfiguration ist kein JSON-Objekt.")
    sys.exit(1)

# AppsPath aktualisieren oder neu einfügen
if "AppsPath" in config:
    config["AppsPath"] = "../tools"
    print('AppsPath wurde auf "../tools" gesetzt.')
else:
    if "AdminClientPath" not in config:
        print("FEHLER: AdminClientPath wurde nicht gefunden.")
        sys.exit(1)

    updated = {}

    for key, value in config.items():
        updated[key] = value

        if key == "AdminClientPath":
            updated["AppsPath"] = "../tools"

    config = updated
    print('AppsPath wurde nach AdminClientPath eingefügt.')

# Reihenfolge prüfen: AppsPath vor LoggingEnabled
keys = list(config.keys())

if "LoggingEnabled" in keys:
    if keys.index("AppsPath") > keys.index("LoggingEnabled"):
        print("FEHLER: AppsPath steht hinter LoggingEnabled.")
        sys.exit(1)

# Temporäre Datei schreiben und JSON prüfen
temp_file = config_file.with_suffix(".json.tmp")

try:
    temp_file.write_text(
        json.dumps(config, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8"
    )

    json.loads(temp_file.read_text(encoding="utf-8"))
    temp_file.replace(config_file)

except Exception as exc:
    temp_file.unlink(missing_ok=True)
    print(f"FEHLER beim Speichern: {exc}")
    sys.exit(1)

print("svwsconfig.json erfolgreich aktualisiert.")
PYTHON

# ---------------------------------------------------------
# 8. SVWS-Dienst neu starten
# ---------------------------------------------------------

echo
echo "Starte $SERVICE neu ..."

systemctl restart "$SERVICE"

sleep 3

if systemctl is-active --quiet "$SERVICE"; then
    echo "SVWS-Dienst läuft erfolgreich."
else
    echo "FEHLER: SVWS-Dienst konnte nicht gestartet werden."
    systemctl --no-pager --full status "$SERVICE" || true
    echo "Konfigurationssicherung: $BACKUP_FILE"
    exit 1
fi

# ---------------------------------------------------------
# 9. Browser direkt auf Debian öffnen
# ---------------------------------------------------------

echo
echo "Öffne den Browser auf Debian ..."

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "Keine grafische Sitzung erkannt."
    echo "Bitte im Debian-Browser öffnen:"
    echo "$BROWSER_URL"

elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$BROWSER_URL" >/dev/null 2>&1 &
    echo "Browser wurde zum Öffnen aufgefordert."

elif command -v firefox-esr >/dev/null 2>&1; then
    firefox-esr "$BROWSER_URL" >/dev/null 2>&1 &
    echo "Firefox ESR wurde gestartet."

elif command -v firefox >/dev/null 2>&1; then
    firefox "$BROWSER_URL" >/dev/null 2>&1 &
    echo "Firefox wurde gestartet."

else
    echo "Kein Browser gefunden."
    echo "Installiere mit: apt install firefox-esr xdg-utils"
    echo "URL: $BROWSER_URL"
fi

# ---------------------------------------------------------
# 10. Aufräumen und Abschluss
# ---------------------------------------------------------

rm -f "$ZIP_FILE"

echo
echo "================================================="
echo " Installation abgeschlossen!"
echo "================================================="
echo "Tools:          $APP_DIR"
echo "Konfiguration:  $CONFIG_FILE"
echo "Sicherung:      $BACKUP_FILE"
echo "Dienst:         $SERVICE"
echo "Browser:        $BROWSER_URL"
echo "================================================="