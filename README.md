# Velora 🥀🎹

Velora v0.2 is an original, modular Roblox piano player for experiences you own. It combines a dense TALENTLESS-style browsing workflow with Velora's own purple glass design and safe Studio architecture.

## What's new in v0.2

- Full three-panel GUI: categories, searchable song browser, and now-playing controls
- Responsive desktop/mobile scaling, mouse/touch dragging, minimize/restore, and `RightShift` toggle
- Live search across title, artist, and categories
- Category filters and session favorites
- Random song selection
- Play, pause/resume, stop, loop, speed, editable BPM, progress, and click-to-seek
- Playback status and clear preview/connected-piano state
- Safer adapter errors and a more capable parser/player core
- Two original demo songs so filters and favorites can be tested immediately

Velora does not copy TALENTLESS source code and does not use executor-only file or input APIs.

## Studio setup

Create this hierarchy in `StarterPlayer > StarterPlayerScripts`:

```text
Velora (Folder)
├── Main (LocalScript)             <- Main.lua
├── Songs (ModuleScript)           <- Songs.lua
├── src (Folder)
│   ├── Parser (ModuleScript)
│   ├── PianoAdapter (ModuleScript)
│   ├── Player (ModuleScript)
│   └── UI (ModuleScript)
└── songs (Folder)
    ├── MoonlitKeys (ModuleScript)
    └── VeloraDemo (ModuleScript)
```

Press **Play** in Studio. `Main` creates the full interface in `PlayerGui`. `Test.lua` is only the engine test harness; it is not the GUI launcher.

If you use [Rojo](https://rojo.space/), `default.project.json` maps the repository into the correct hierarchy automatically.

## Connect your own piano

Velora starts in preview mode until your game binds a note callback. In `Main.lua`, after the controller is created, bind your own piano system:

```lua
controller:BindPiano(function(note)
    MyPiano:PlayNote(note)
end)
```

The callback is the only game-specific part. Keep validation and any authoritative gameplay on the server.

## Add your own song

1. Create a ModuleScript in `songs/`, for example `MySong.lua`:

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

2. Add its card metadata to `Songs.lua`:

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

### Sheet syntax

- `a s d f` — sequential notes
- `[ad]` or `[a,d]` — chord; notes fire together
- `-` or `_` — one timing-step rest
- `|` — visual bar separator; ignored by playback
- `BPM` + `StepsPerBeat` — timing controls

## Files

- `Main.lua` — controller and public API
- `Songs.lua` — searchable song registry
- `src/UI.lua` — complete v0.2 interface
- `src/Parser.lua` — sheet parser
- `src/Player.lua` — playback state engine
- `src/PianoAdapter.lua` — safe piano bridge
- `songs/` — individual song modules
- `Test.lua` — Studio engine checks

## Roadmap

- v0.3 — optional remote manifest for a GitHub-backed library
- v0.4 — playlists, shuffle queue, recents, and transpose
