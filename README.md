# Velora — Nova 🥀

Velora v0.10.21 **Nova** is a rounded midnight-glass Roblox piano workstation with a seamless mix of public and protected arrangements.

## Run Velora

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/protected-playback-test/loader.lua"
))()
```

If GitHub is blocked by an executor, use the CDN launcher:

```lua
loadstring(game:HttpGet(
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@protected-playback-test/loader.lua"
))()
```

Before pressing Play, click the in-game piano once so it owns keyboard focus. Protected playback also requires an executor with an HTTP request function.

## Nova 0.10.21

- The visible library, song names, ordering, categories, player controls, favorites, queue, timing, and corrected 61-key piano mapping are preserved.
- Every shipped arrangement—including public-domain compositions—uses protected delivery; the public repository contains no complete song transcription.
- Copyrighted, purchased, user-supplied, and openly licensed readable masters live only in the private maintenance backend.
- Protected tracks use opaque backend IDs, an expiring playback session, and short just-in-time event chunks.
- The client keeps only a small forward buffer, discards played protected events, retries temporary failures, and renews expired sessions.
- Pause, stop, seek, loop, speed, and BPM controls work for both local and protected tracks.
- If protected playback is unavailable, Velora keeps the library visible, stops cleanly, and shows a retryable error instead of playing incomplete data.
- No GitHub credential, signing key, server secret, or reusable private-repository token is embedded in the client.

The visual Nova interface is otherwise unchanged: smoked black glass, crimson accents, compact player mode, responsive status borders, bundled icons, clipped marquee metadata, and the existing no-hover-motion behavior all remain.

## Protected playback

The public client contains only display metadata, opaque IDs, and the non-secret API address in `ProtectedConfig.lua`. The private backend owns the arrangements and issues signed, single-use chunk cursors. See `docs/PROTECTED_PLAYBACK.md` for the protocol and deployment handoff.

This design makes casual browsing and one-click copying much harder, but it cannot make extraction impossible. A determined user controlling the playback client can still record the streamed events over time.

## Music rights

Public playback is not the same as personal use. Verify that every purchased MIDI or third-party arrangement license permits public playback through Velora before enabling it for all users. Hiding the arrangement source does not grant redistribution or public-performance rights.

Source, attribution, and edition-license records belong with the readable masters in the private backend repository.
