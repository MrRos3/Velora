# Velora — Nova 🥀

Velora v0.10.6 **Nova** is a rounded midnight-glass Roblox piano workstation with responsive controls, Lucide icons, complete arrangements, and reliable public loading.

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

## Nova 0.10.6

- Replaced the 27-second Succession fragment with a complete 50-measure piano arrangement
- **Succession — Main Title Theme** now runs for about 1:23 at the score's half-note tempo of 72 BPM
- The complete arrangement includes the opening theme, quiet bridge, bass ostinato, reprise, final chord, black-key notes, chords, and explicit rests
- Clean scale-and-press hover motion on the existing buttons
- A quick heart pop and confirmation message when adding or removing a favorite
- Favorites save immediately to `Velora/favorites.json` when executor file APIs are available
- Session-memory fallback keeps favorites during re-execution when file APIs are unavailable
- Closing or destroying the GUI performs one final favorites save
- No piano input, playback timing, songs, or layout behavior changed
- Deeper ink surfaces and cleaner separation make the existing three-panel layout feel more premium
- Softer internal luminescence keeps the interface vivid without restoring the outer glow or glowing song cards
- More restrained borders, richer palette blending, and clearer selected/hover states

- Clean panel surfaces with no decorative blobs or header stripe
- A compact Nova studio capsule showing the complete library size
- Live READY, PLAYING, PAUSED, and DONE playback states
- A dynamic result counter for every search and category
- Clear TEMPO and LOOP labels plus a richer library summary card
- Palette-aware progress detail and interactive surface borders
- Fast hover feedback that only runs while the user is interacting
- The outer window glow is removed and replaced by soft luminous borders on internal panels and controls
- Song cards use a crisp selection outline without glow
- Extra list spacing keeps the first song's rounded top border fully visible
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
- 22 complete arrangements with explicit notes, chords, rests, and twelve timing steps per beat
- Clear selected-song highlight without a side rail
- Picking another song never interrupts the song already playing
- A completed song stops unless Loop is enabled
- Draggable progress, BPM controls, and RGB/HEX palette customization
- 🥀 remains the only interface emoji

## Music sources

Arrangements are generated from credited MIDI editions and scores. Source and licensing details are stored inside each song file. Owner-supplied MIDI conversions include Love Story, Ievan Polkka, Kamado Tanjiro no Uta, Erika, Anlatamam, and the opening section of Succession.

Before pressing Play, click the in-game piano once so it owns keyboard focus.

