#!/bin/bash
# Startet die App auf Pauls laufender Wayland-Sitzung. Ueber SSH erbt man die
# Sitzung nicht — Anzeige und Laufzeitverzeichnis muessen ausdruecklich gesetzt
# werden, sonst findet GTK keinen Bildschirm.
#
# **Vollstaendig abnabeln, nicht nur in den Hintergrund schicken.** Ein
# gestarteter Prozess erbt die offenen Leitungen des Hooks; solange auch nur
# eine davon offen bleibt, wartet `git push` auf der anderen Seite weiter,
# obwohl die App laengst laeuft. Paul musste deshalb jeden Durchgang von Hand
# abbrechen. Deswegen: Eingabe von /dev/null, Ausgabe ins Protokoll, und
# `disown`, damit die Shell den Prozess auch nicht mehr beobachtet.
set -uo pipefail
BAUM="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$BAUM/Linux/.build/debug/SwiftlyLinux"
LOG="$HOME/swiftly-linux.log"
[ -x "$BIN" ] || { echo "  kein Programm unter $BIN"; exit 1; }

pkill -f "$BIN" 2>/dev/null && echo "  alte Instanz beendet"
sleep 0.3

source "$HOME/.swift-env.sh"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export GDK_BACKEND=wayland
setsid "$BIN" </dev/null >"$LOG" 2>&1 &
disown 2>/dev/null || true
sleep 1
if pgrep -f "$BIN" >/dev/null; then
  echo "  läuft (PID $(pgrep -f "$BIN" | head -1))"
else
  echo "  !! sofort beendet. Letzte Zeilen:"; tail -5 "$LOG"
fi
exit 0
