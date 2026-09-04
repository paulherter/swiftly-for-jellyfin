#!/bin/bash
# Startet die App auf Pauls laufender Wayland-Sitzung. Ueber SSH erbt man die
# Sitzung nicht — Anzeige und Laufzeitverzeichnis muessen ausdruecklich gesetzt
# werden, sonst findet GTK keinen Bildschirm.
set -uo pipefail
BAUM="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$BAUM/Linux/.build/debug/SwiftlyLinux"
[ -x "$BIN" ] || { echo "  kein Programm unter $BIN"; exit 1; }

pkill -f "$BIN" 2>/dev/null && echo "  alte Instanz beendet"
sleep 0.3

source "$HOME/.swift-env.sh"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export GDK_BACKEND=wayland
setsid "$BIN" >"$HOME/swiftly-linux.log" 2>&1 &
sleep 1
if pgrep -f "$BIN" >/dev/null; then
  echo "  läuft (PID $(pgrep -f "$BIN" | head -1)) — Protokoll: ~/swiftly-linux.log"
else
  echo "  !! sofort beendet. Letzte Zeilen:"; tail -5 "$HOME/swiftly-linux.log"
fi
