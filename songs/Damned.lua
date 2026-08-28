-- Velora 0.10.20 Nova — verified COD Zombies arrangement converted from MIDI.
-- Song: Damned — Call of Duty: Black Ops Zombies.
-- Original composition: Kevin Sherwood. Source page presents the Black Ops II Zombies theme arrangement under Brian Tuey.
-- Verified source page: https://robloxpianosheet.com/sheets/black-ops-2-zombie-theme
-- MIDI source: https://robloxpianosheet.com/api/midi/black-ops-2-zombie-theme
-- Source verification: Online Sequencer MIDI export, verified by the source page on 2026-04-27.
-- Source MIDI SHA-256: 26F66A460AB29AB60B55B333AE05070A7C7C1A7D76D4112F4C077D37007774B5
-- MIDI: 384 PPQ, 1 source tempo event(s), source time signature(s): 4/4.
-- Timing normalized to real seconds at 200 BPM / 48 Velora steps per beat.
-- 3 non-drum musical tracks retained (Grand Piano (Classic), Steel Drums, Elec. Piano (Classic)); simultaneous duplicate pitches are merged.
-- 335 source note-on events processed.
-- 0 out-of-range note-on events were folded by octave into Velora's C2-C7 keyboard range.

local DATA = [=[
0:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P
23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D
23:G 23:L 23:S 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P
23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J
23:P 23:D 23:G 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:L 23:S 23:D 23:G
23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P
23:P 23:J 23:P 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:k 23:a
23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:L 23:S 23:D 23:G 23:a 23:a 23:k 23:a 23:D
23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G
23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:k 23:a 23:D 23:G 23:a 23:a 23:k
23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:L 23:S 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a
23:D 23:G 23:[0uJZ] 23:P 23:D 23:[GZ] 23:P 23:P 23:[JZ] 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:[7rJ] 23:P
23:D 23:[GJ] 23:P 23:P 23:J 23:P 23:D 23:G 23:P 23:P 23:J 23:P 23:D 23:G 23:[8tk] 23:a 23:D 23:[Gk] 23:a 23:a 23:k
23:a 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:L 23:S 23:D 23:G 23:a 23:a 23:k 23:a 23:D 23:G 23:a 23:a 23:k 23:a
23:D 23:G
]=]

local sheet = {}
for encoded in DATA:gmatch("%S+") do
    local gap, token = encoded:match("^(%d+):(.+)$")
    gap = tonumber(gap)
    if gap and token then
        for _ = 1, gap do
  sheet[#sheet + 1] = "-"
        end
        sheet[#sheet + 1] = token
    end
end

return {
    Id="damned-cod-black-ops-zombies",
    Name="Damned",
    Artist="Kevin Sherwood",
    BPM=200,
    StepsPerBeat=48,
    Complete=true,
    Source="Verified Roblox Piano Sheet / Online Sequencer MIDI export",
    SourceLicense="Third-party composition and arrangement; rights remain with their respective owners.",
    Categories={"Famous","Game OST","Call of Duty","Zombies","Dark","Piano","Horror","Complete"},
    Notes=table.concat(sheet, " "),
}
