#!/bin/bash
# Startet die App auf Pauls laufender Wayland-Sitzung.
#
# **Über systemd, nicht über `&`.** Ein Prozess, der aus einem git-Hook heraus
# gestartet wird, erbt dessen offene Leitungen — und solange auch nur eine
# davon offen bleibt, wartet `git push` auf der anderen Seite weiter, obwohl
# die App längst läuft. `setsid` mit Umleitungen reichte nicht; Paul musste
# jeden Durchgang von Hand abbrechen.
#
# `systemd-run --user` übergibt den Start an den Dienstverwalter. Der neue
# Prozess hängt an gar nichts mehr, was mit dieser SSH-Verbindung zu tun hat,
# und `--collect` räumt die Einheit auf, wenn sie endet.
set -uo pipefail
BAUM="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$BAUM/Linux/.build/debug/SwiftlyLinux"
LOG="$HOME/swiftly-linux.log"
[ -x "$BIN" ] || { echo "  kein Programm unter $BIN"; exit 1; }

systemctl --user stop swiftly.service 2>/dev/null
pkill -f "$BIN" 2>/dev/null
sleep 0.3

systemd-run --user --collect --unit=swiftly \
  --setenv=XDG_RUNTIME_DIR="/run/user/$(id -u)" \
  --setenv=WAYLAND_DISPLAY=wayland-0 \
  --setenv=GDK_BACKEND=wayland \
  --setenv=LD_LIBRARY_PATH="$HOME/.swift-compat" \
  --property=StandardOutput=append:"$LOG" \
  --property=StandardError=append:"$LOG" \
  "$BIN" >/dev/null 2>&1

sleep 1
if systemctl --user is-active --quiet swiftly.service; then
  echo "  läuft"
else
  echo "  !! nicht gestartet. Letzte Zeilen:"
  tail -6 "$LOG" 2>/dev/null | sed 's/^/     /'
fi
exit 0
