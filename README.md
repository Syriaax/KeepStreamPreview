# KeepStreamPreview

Vencord-Plugin. Discord pausiert die Vorschau deines eigenen Streams, sobald das Discord-Fenster nicht mehr im Fokus ist
("Your stream is still running! We've paused this preview to save your resources."). Dieses Plugin verhindert das.

## Was Discord intern macht (Stand Discord-Build Nov 2026)

| Stelle | Bedingung für Pause | Nativ abschaltbar? |
|---|---|---|
| Stream-Kachel im Call | eigener Stream + Einstellung `pauseSelfStreamPreviewWhenUnfocused` (Standard: an) + Fenster nicht fokussiert + kein Popout | Ja: Rechtsklick auf eigenen Stream → Haken bei **"Pause Preview When Discord Isn't Focused"** entfernen |
| Bild-in-Bild-Player (wenn du im Call bist, aber einen Textkanal offen hast) | eigener Stream + Fenster nicht fokussiert | **Nein**, ignoriert die Einstellung |
| Popout-Fenster | wird nie pausiert | – |

Ohne Plugin: Haken im Rechtsklick-Menü entfernen oder Stream per Popout-Button in eigenes Fenster legen.
Mit Plugin: beide Stellen bleiben immer live.

## Einstellungen

- `callTile`: Kachel im Call-Fenster live halten (Standard: an)
- `pictureInPicture`: Bild-in-Bild-Player live halten (Standard: an)

## Installation

Eigene Plugins gehen nur mit Vencord aus dem Quellcode. Voraussetzung: Git und Node.js 22+.

Automatisch (klont Vencord nach `%USERPROFILE%\Vencord`, baut und injiziert):

```powershell
git clone https://github.com/Syriaax/KeepStreamPreview.git
powershell -ExecutionPolicy Bypass -File KeepStreamPreview\install.ps1
```

Manuell:

1. `git clone https://github.com/Vendicated/Vencord.git`
2. `cd Vencord\src\userplugins` und `git clone https://github.com/Syriaax/KeepStreamPreview.git keepStreamPreview`
3. Zurück im Vencord-Ordner: `npm i -g pnpm`, `pnpm install --frozen-lockfile`, `pnpm build`, `pnpm inject`
4. Discord komplett neu starten, unter Einstellungen → Vencord → Plugins **KeepStreamPreview** aktivieren, nochmal neu starten

Update: im Plugin-Ordner `git pull`, im Vencord-Ordner `pnpm build`, Discord neu laden (Strg+R).

## Hinweis

Dauerhaft laufende Vorschau kostet etwas CPU/GPU. Das ist der Grund, warum Discord sie pausiert.
