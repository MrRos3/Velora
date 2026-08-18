# Velora — Pulse 🥀

Velora v0.9.1 **Pulse** is a rounded Roblox piano workstation with a responsive glowing interface, Lucide icons, complete arrangements, and reliable public loading.

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

## Pulse 0.9.1

- The outer window glow is removed and replaced by soft luminous borders on internal panels and controls
- Selected and currently playing songs have distinct palette-aware glows
- Search, artwork, play, and Reset BPM controls brighten on focus or hover
- Brighter secondary text, larger labels, and clearer font weights improve readability
- The panel beneath the tempo arrows is now a one-click Reset BPM control
- Palette colors update the window, internal glows, cards, controls, and icons together
- Faster 0.12-second interaction motion with stale tween cancellation
- Clicks and selections render immediately
- Playback progress is capped at a smooth 30 FPS to reduce unnecessary UI work
- Defensive Lucide icon loading so one unavailable asset cannot stop the GUI
- Compatibility loader with GitHub and jsDelivr release fallbacks
- Clear in-game error notifications instead of silent launcher failures
- 21 complete arrangements with explicit notes, chords, rests, and twelve timing steps per beat
- Clear selected-song highlight without a side rail
- Picking another song never interrupts the song already playing
- A completed song stops unless Loop is enabled
- Draggable progress, BPM controls, and RGB/HEX palette customization
- 🥀 remains the only interface emoji

## Music sources

Arrangements are generated from credited MIDI editions. Source and licensing details are stored inside each song file. Owner-supplied MIDI conversions include Love Story, Ievan Polkka, Kamado Tanjiro no Uta, Erika, and Anlatamam.

Before pressing Play, click the in-game piano once so it owns keyboard focus.

