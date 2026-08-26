# Velora — Nova 🥀

Velora v0.10.12 **Nova** is a rounded midnight-glass Roblox piano workstation with responsive controls, Lucide icons, complete arrangements, and reliable public loading.

## Run Velora

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua"
))()
```

If GitHub is blocked by an executor, use the CDN launcher:

```lua
loadstring(game:HttpGet(
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@main/loader.lua"
))()
```

## Nova 0.10.12

- Executor-safe UI state with a much lower compiler register footprint.
- Compact player-only mode with a Lucide minimize/restore control.
- Long song titles and metadata stay clipped and move in a smooth loop.
- Playback status borders size themselves to READY, PLAYING, PAUSED, or DONE.
- Hover scaling and hover motion have been removed from buttons and song cards.

## Music sources

Arrangements are generated from credited MIDI editions and scores. Source and licensing details are stored inside each song file. Love Story now uses Anastazja Szczepiek's complete five-page piano score. Owner-supplied MIDI conversions include Ievan Polkka, Kamado Tanjiro no Uta, Erika, Anlatamam, and the opening section of Succession.

Before pressing Play, click the in-game piano once so it owns keyboard focus.

