# Diese Adresse ist umgezogen

**Swiftly for Jellyfin heißt jetzt Swiftly Player**, und das Verzeichnis liegt
unter **[paulherter/swiftly-player](https://github.com/paulherter/swiftly-player)**.

Apple hat die Einreichung nach Richtlinie 4.1(c) abgelehnt: der Name einer App
darf die Produktmarke eines anderen Entwicklers nicht tragen. Die App ist
dieselbe geblieben — nur der Name hat sich geändert.

## Warum es diese Ablage noch gibt

Wer die Linux-Paketquelle unter der alten Adresse eingetragen hat, bekäme sonst
bei jedem `apt update` einen Fehler. Die Pakete hier bleiben deshalb erreichbar.
**Neue Fassungen erscheinen aber nur noch unter der neuen Adresse** — trag sie
einmal um:

```sh
# Debian, Ubuntu und Verwandte
sudo sed -i 's|swiftly-for-jellyfin|swiftly-player|' /etc/apt/sources.list.d/swiftly.list
sudo apt update

# Fedora und Verwandte
sudo sed -i 's|swiftly-for-jellyfin|swiftly-player|' /etc/yum.repos.d/swiftly.repo

# Arch und Verwandte
sudo sed -i 's|swiftly-for-jellyfin|swiftly-player|' /etc/pacman.conf
```

Alles andere — Fehlerberichte, Quelltext, Releases — gehört nach
[paulherter/swiftly-player](https://github.com/paulherter/swiftly-player).
