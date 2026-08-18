-- Velora v0.3.1 song registry.
-- Add one entry for every standalone song file in songs/.

return {
    {
        Id = "velora-demo",
        Name = "Velora Demo",
        Artist = "Velora",
        BPM = 100,
        Categories = { "Original", "Starter" },
        File = "songs/VeloraDemo.lua",
    },
    {
        Id = "moonlit-keys",
        Name = "Moonlit Keys",
        Artist = "Velora",
        BPM = 88,
        Categories = { "Original", "Chill" },
        File = "songs/MoonlitKeys.lua",
    },
}
