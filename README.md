# KeepStreamPreview

Vencord plugin. Discord pauses the preview of your own stream as soon as the Discord window loses focus
("Your stream is still running! We've paused this preview to save your resources."). This plugin stops that.

## What Discord does internally (Discord build, Nov 2026)

| Place | Pauses when | Can be disabled natively? |
|---|---|---|
| Stream tile in the call view | own stream + setting `pauseSelfStreamPreviewWhenUnfocused` (default: on) + window not focused + no popout | Yes: right-click your stream → uncheck **"Pause Preview When Discord Isn't Focused"** |
| Picture-in-picture player (in a call, but viewing a text channel) | own stream + window not focused | **No**, ignores the setting |
| Popout window | never paused | – |

Without the plugin: uncheck the option in the right-click menu, or move the stream into its own window with the popout button.
With the plugin: both places always stay live.

## Settings

- `callTile`: keep the call view tile live (default: on)
- `pictureInPicture`: keep the picture-in-picture player live (default: on)

## Installation

Custom plugins only work with Vencord built from source. Requirements: Git and Node.js 22+.

Automatic (clones Vencord to `%USERPROFILE%\Vencord`, builds and injects it):

```powershell
git clone https://github.com/Syriaax/KeepStreamPreview.git
powershell -ExecutionPolicy Bypass -File KeepStreamPreview\install.ps1
```

Manual:

1. `git clone https://github.com/Vendicated/Vencord.git`
2. `cd Vencord\src\userplugins` and `git clone https://github.com/Syriaax/KeepStreamPreview.git keepStreamPreview`
3. Back in the Vencord folder: `npm i -g pnpm`, `pnpm install --frozen-lockfile`, `pnpm build`, `pnpm inject`
4. Fully restart Discord, enable **KeepStreamPreview** under Settings → Vencord → Plugins, restart again

Update: run `git pull` in the plugin folder, `pnpm build` in the Vencord folder, then reload Discord (Ctrl+R).

## Note

A preview that never pauses uses some extra CPU/GPU. That is why Discord pauses it.
