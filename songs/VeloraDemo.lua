-- Velora v0.1 starter song
-- Notes are whitespace-delimited tokens. Chords use [abc].
-- A dash (-) is a rest. Timing is determined by BPM and StepsPerBeat.

return {
    Id = "velora-demo",
    Name = "Velora Demo",
    Artist = "Velora",
    BPM = 100,
    StepsPerBeat = 2,
    Categories = { "Demo", "Starter" },

    Notes = [[
        a s d f | g h j k |
        [ad] - [sf] - | [dg] - [fh] - |
        k j h g | f d s a
    ]],
}
