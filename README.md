# Velora 🥀🎹

**Velora v0.3.0 "Nocturne"** is an original Roblox piano workstation built around a polished song-library workflow, smooth playback controls, and a GitHub-backed song registry.

Velora is independently implemented. The TALENTLESS repository is source-available for study only and forbids derivative works, so Velora does **not** reuse or adapt TALENTLESS source code. We keep the broad product idea, then build Velora's own UI, engine, and identity.

## ✨ Nocturne UI

The new `latest.lua` is the premium standalone build:

- Three-zone interface: library navigation, searchable song browser, and now-playing workstation
- Favorites, recents, queue, categories, live search, and random song selection
- Smooth glass transitions with thin white borders and Velora violet/pink accents
- Live piano-key visualizer that reacts to every played note
- Play / pause / stop, seek, loop, shuffle, queue autoplay, speed, and editable BPM
- Compact mini-player and `RightShift` hide/restore
- Mouse + touch dragging and responsive viewport scaling
- Lucide icons loaded from `MrRos3/Icons` with graceful text fallbacks
- No decorative blobs/orbs

## 🚀 Execute the standalone build

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/latest.lua"
))()
```

Or use the guarded loader:

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua"
))()
```

After loading, the public API is available as:

```lua
local Velora = _G.Velora
```

and, where supported:

```lua
local Velora = getgenv().Velora
```

## 🎹 Piano output modes

Velora chooses the best available client mode automatically:

1. A callback supplied with `Velora:BindPiano(...)`
2. Executor keyboard input when `keypress` / `keyrelease` are available
3. Virtual input when available
4. Preview mode when no input backend can be used

To connect Velora to a piano system you own:

```lua
Velora:BindPiano(function(note)
    MyPiano:PlayNote(note)
end)
```

You can toggle automatic keyboard input with:

```lua
Velora:SetAutoInput(true)
```

## 🎼 Add songs from GitHub

Each song remains its own Lua file under `songs/`.

Example `songs/MySong.lua`:

```lua
return {
    Id = "my-song",
    Name = "My Song",
    Artist = "MrRos3",
    BPM = 120,
    StepsPerBeat = 2,
    Categories = { "Original", "Chill" },

    Notes = [[
        a s d f | g h j k |
        [ad] - [sf] -
    ]],
}
```

Then add its metadata to `Songs.lua`:

```lua
{
    Id = "my-song",
    Name = "My Song",
    Artist = "MrRos3",
    BPM = 120,
    Categories = { "Original", "Chill" },
    File = "songs/MySong.lua",
},
```

The standalone build downloads the registry at startup and fetches a song file only when you select it, so adding songs does not require rebuilding `latest.lua`.

### Sheet syntax

- `a s d f` → sequential notes
- `[ad]` → chord
- `[a,d]` → chord with explicit separators
- `-` or `_` → one timing-step rest
- `|` → visual bar separator
- uppercase letters are preserved for input backends that use shifted/high piano notes
- `BPM` + `StepsPerBeat` control timing

## 🧩 Public API

Useful methods include:

```lua
Velora:LoadSong("velora-demo", true)
Velora:Play()
Velora:Pause()
Velora:Stop()
Velora:Seek(0.5)
Velora:SetSpeed(1.25)
Velora:SetBPM(110)
Velora:SetLoop(true)
Velora:SetShuffle(true)
Velora:ToggleFavorite("velora-demo")
Velora:AddToQueue("moonlit-keys")
Velora:RefreshLibrary()
Velora:Show()
Velora:Hide()
Velora:Destroy()
```

You can also add a temporary song during a session:

```lua
Velora:AddRuntimeSong({
    Id = "runtime-demo",
    Name = "Runtime Demo",
    Artist = "Velora",
    BPM = 120,
    Categories = { "Runtime" },
}, {
    BPM = 120,
    StepsPerBeat = 2,
    Notes = "a s d f | g h j k",
})
```

## 🧱 Studio modular source

The older modular Studio architecture is still kept in the repository:

- `Main.lua`
- `Songs.lua`
- `src/Parser.lua`
- `src/Player.lua`
- `src/PianoAdapter.lua`
- `src/UI.lua`
- `songs/`
- `Standalone.client.lua`

`latest.lua` is the new v0.3 Nocturne standalone entrypoint. The modular source can be upgraded to the same UI in a later release without disturbing the standalone build.

## Roadmap

- v0.3.x: playlists, persistent favorites, import panel, transpose, and better mobile layout
- v0.4: remote manifests, update channels, per-song artwork/themes, and plugin adapters
- future: optional SaltyGlass integration and shared key/config infrastructure
