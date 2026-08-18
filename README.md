# Velora 🥀🎹

A modular Roblox piano player and GitHub-powered song library.

## v0.1

Velora v0.1 establishes the core architecture:

- `Main.lua` — controller / entrypoint
- `Songs.lua` — central song registry
- `src/Parser.lua` — converts compact sheets into timed note events
- `src/Player.lua` — playback, pause, stop, speed, loop, and progress
- `src/PianoAdapter.lua` — isolated bridge to a piano implementation
- `src/UI.lua` — minimal v0.1 interface shell
- `songs/` — individual song modules

## Song format

Create a new file inside `songs/`:

```lua
return {
    Id = "my-song",
    Name = "My Song",
    Artist = "Artist",
    BPM = 120,
    StepsPerBeat = 2,
    Categories = { "Chill" },

    Notes = [[
        a s d f | g h j k |
        [ad] - [sf] -
    ]],
}
```

Then add it to `Songs.lua`:

```lua
{
    Id = "my-song",
    Name = "My Song",
    Artist = "Artist",
    BPM = 120,
    Categories = { "Chill" },
    File = "songs/MySong.lua",
},
```

### Sheet syntax

- `a s d f` — sequential notes
- `[ad]` — chord; notes fire together
- `-` — one timing-step rest
- `|` — visual bar separator; ignored by playback
- `BPM` + `StepsPerBeat` control note timing

## Piano adapter

Velora deliberately keeps piano-specific behavior outside the playback engine.

Bind the adapter to a piano system in an experience you control:

```lua
adapter:Bind(function(note)
    MyPiano:PlayNote(note)
end)
```

That means the parser, song library, UI, timing engine, and future features can stay unchanged when the piano implementation changes.

## Roadmap

- v0.2 — full glass UI, searchable song browser, categories, favorites
- v0.3 — GitHub-backed song manifest / remote library workflow
- v0.4 — playlists, shuffle, recently played, transpose controls

Velora is being built as an original modular project rather than a copy of another piano script.
