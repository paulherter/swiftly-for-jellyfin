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
#
# **„läuft" hat einmal gelogen.** Am 04.09.2026 stand die Meldung da, während
# auf dem Bildschirm die alte Fassung weiterlief: `systemctl stop` kehrt
# zurück, bevor die Einheit wirklich unten ist, und `systemd-run` mit einem
# noch belegten Einheitennamen scheitert still — die Ausgabe ging nach
# /dev/null. `is-active` sagte darauf brav „ja", nur eben über den alten
# Prozess. Deshalb steht unten kein „läuft" mehr ohne Beweis: gemeldet wird
# nur, wenn der **gestartete Prozess jünger ist als das Programm auf der
# Platte**. Ein Zeitstempel allein beweist nichts, aber diese Reihenfolge
# schliesst genau den Fall aus, der uns getroffen hat.
set -uo pipefail
BAUM="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$BAUM/Linux/.build/debug/SwiftlyLinux"
LOG="$HOME/swiftly-linux.log"
[ -x "$BIN" ] || { echo "  kein Programm unter $BIN"; exit 1; }

# Erst wirklich anhalten. `stop` ist nicht abgeschlossen, wenn es zurückkommt.
systemctl --user stop swiftly.service 2>/dev/null
pkill -f "$BIN" 2>/dev/null
for _ in $(seq 40); do
  systemctl --user is-active --quiet swiftly.service || break
  sleep 0.1
done
# Eine gescheiterte Einheit belegt den Namen weiter, bis sie zurückgesetzt wird.
systemctl --user reset-failed swiftly.service 2>/dev/null

FEHLER=$(systemd-run --user --collect --unit=swiftly \
  --setenv=XDG_RUNTIME_DIR="/run/user/$(id -u)" \
  --setenv=WAYLAND_DISPLAY=wayland-0 \
  --setenv=GDK_BACKEND=wayland \
  --setenv=LD_LIBRARY_PATH="$HOME/.swift-compat" \
  --property=StandardOutput=append:"$LOG" \
  --property=StandardError=append:"$LOG" \
  "$BIN" 2>&1 >/dev/null)

sleep 1

# Der Beweis: die Startzeit des laufenden Prozesses gegen die Bauzeit des
# Programms. Sekundengenau reicht, weil zwischen Übersetzen und Starten immer
# mindestens ein Aufruf liegt.
GEBAUT=$(stat -c %Y "$BIN")
PID=$(systemctl --user show swiftly.service -p MainPID --value 2>/dev/null)
if [ -n "${PID:-}" ] && [ "$PID" != "0" ] && [ -d "/proc/$PID" ]; then
  GESTARTET=$(stat -c %Y "/proc/$PID")
  if [ "$GESTARTET" -ge "$GEBAUT" ]; then
    echo "  läuft — PID $PID, $(( GESTARTET - GEBAUT ))s nach dem Bau gestartet"
    exit 0
  fi
  echo "  !! ALTE FASSUNG laeuft weiter (PID $PID, $(( GEBAUT - GESTARTET ))s aelter als das Programm)"
else
  echo "  !! nicht gestartet."
fi
[ -n "$FEHLER" ] && echo "$FEHLER" | sed 's/^/     /'
tail -6 "$LOG" 2>/dev/null | sed 's/^/     /'
exit 1
