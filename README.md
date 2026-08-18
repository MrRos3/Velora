# Velora — Encore 🥀

Velora v0.8.2 **Encore** is a rounded Roblox piano workstation with Lucide icons, static playback controls, full-song arrangements, and a clear selected-song state.

## Run the cache-breaking release

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/boot-082.lua",
    true
))()
```

## Encore 0.8.2

- 17 complete arrangements with explicit notes, chords, rests, and twelve timing steps per beat
- New: Love Story by Indila, converted from the complete MIDI supplied by the repository owner
- Long-form additions include In the Hall of the Mountain King, Eine kleine Nachtmusik, and Dies Irae
- Clean rounded selection border, `SELECTED` label, and Lucide check icon—with no cyan side rail
- Picking another song never interrupts the song currently playing
- The picked song becomes ready after Stop or after the current song ends, but never autoplays
- Static play button with no per-note pulse animation
- Lucide icons throughout; 🥀 remains the only interface emoji
- Draggable progress, BPM adjustment, RGB and HEX theming
- Stops at each song’s ending unless Loop is enabled

## Music sources

Arrangements are generated from credited Mutopia MIDI editions. The source URL and edition license are stored inside every song file. The three classical Encore additions use public-domain editions. Love Story was converted from a MIDI supplied by the repository owner; its filename and SHA-256 are recorded in the song file. Canon per 3 Violini e Basso is credited to typesetter Michael Fischer v. Mollard and distributed under CC BY 4.0.

Before pressing Play, click the in-game piano once so it owns keyboard focus.
