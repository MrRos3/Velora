# Velora — Encore 🥀

Velora v0.8.4 **Encore** is a rounded Roblox piano workstation with Lucide icons, static playback controls, full-song arrangements, and a clear selected-song state.

## Run the cache-breaking release

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/boot-084.lua",
    true
))()
```

## Encore 0.8.4

- 19 complete arrangements with explicit notes, chords, rests, and twelve timing steps per beat
- New: Kamado Tanjiro no Uta, a roughly 6:14 arrangement converted from the complete owner-supplied MIDI
- Ievan Polkka is also included from the complete owner-supplied MIDI
- Love Story by Indila is also included from the owner-supplied MIDI
- Long-form additions include In the Hall of the Mountain King, Eine kleine Nachtmusik, and Dies Irae
- Clean rounded selection border, `SELECTED` label, and Lucide check icon—with no cyan side rail
- Picking another song never interrupts the song currently playing
- The picked song becomes ready after Stop or after the current song ends, but never autoplays
- Static play button with no per-note pulse animation
- Lucide icons throughout; 🥀 remains the only interface emoji
- Draggable progress, BPM adjustment, RGB and HEX theming
- Stops at each song’s ending unless Loop is enabled

## Music sources

Arrangements are generated from credited Mutopia MIDI editions. The source URL and edition license are stored inside every song file. The three classical Encore additions use public-domain editions. Love Story, Ievan Polkka, and Kamado Tanjiro no Uta were converted from MIDIs supplied by the repository owner; their filenames and SHA-256 hashes are recorded in their song files. Canon per 3 Violini e Basso is credited to typesetter Michael Fischer v. Mollard and distributed under CC BY 4.0.

Before pressing Play, click the in-game piano once so it owns keyboard focus.
