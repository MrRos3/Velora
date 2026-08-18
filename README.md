# Velora 🥀🎹

Velora v0.3.2 **Nocturne** is a compact standalone Roblox piano workstation with an original three-column library, song list, and now-playing layout.

## Run

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MrRos3/Velora/main/boot-032.lua"))()
```

Press **Right Shift** to hide or restore the interface.

## Playback

Before pressing Play, click the in-game piano once so it owns keyboard focus. Velora then tries output in this order:

1. A callback registered with `Velora:BindPiano(callback)`
2. Executor keyboard input (`keytap` or `keypress` + `keyrelease`)
3. Roblox virtual input when the environment permits it

If a backend rejects a key, playback stops and reports the problem instead of continuing with a false “playing” state.

For a piano system in an experience you own:

```lua
local Velora = getgenv().Velora
Velora:BindPiano(function(note)
    MyPiano:PlayNote(note)
end)
```

The release files are intentionally small: `latest.lua`, `boot-032.lua`, `Songs.lua`, and `songs/`.

Velora is independently implemented and contains no TALENTLESS source or assets.


## Cached executors

Version 0.3.2 uses unique release filenames so executors cannot reuse the former dashboard from `latest.lua`.
