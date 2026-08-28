-- Velora 0.10.20 Nova — exact conversion from the user-supplied MIDI.
-- Supplied file: Damned (Call of Duty Black Ops Zombies OST).mid
-- Supplied file SHA-256: 8E379736FC36AE0EAAA3B55507DABE8EAA5528D72849D7CCD6B0967E35FA3DA8
-- MIDI: 384 PPQ, 1 source tempo event(s), source time signature(s): 4/4.
-- Source tempo: 89 BPM. Duration: 140.225 seconds.
-- Retained all 4 non-drum musical tracks: Grand Piano 2 (416 note-ons), Grand Piano (415 note-ons), Electric Piano (48 note-ons), Grand Piano 4 (126 note-ons).
-- 1,005 source note-on events processed; simultaneous duplicate pitches are merged.
-- Timing normalized to real seconds at 89 BPM / 48 Velora steps per beat.
-- 16 out-of-range note-on events were folded by octave into Velora's C2-C7 keyboard range.

local DATA = [=[
0:J 23:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:J 11:D 11:D 11:J 11:P 11:D 11:J 11:P 11:D
11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k
11:L 11:D 11:D 11:L 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:J 11:P 11:D 11:J 11:P 11:D 11:J
11:P 11:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:J 11:D 11:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:P 11:D 11:J 11:P
11:D 11:J 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:L 11:D 11:D 11:L 11:a
11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D 11:[JZ]
11:P 11:D 11:J 11:P 11:D 11:J 11:[JB] 11:D 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:J 11:P 11:D
11:J 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:k 11:a 11:D 11:k 11:L 11:D 11:D 11:L
11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D
11:[JZ] 11:P 11:D 11:J 11:P 11:D 11:J 11:[JB] 11:D 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:J
11:P 11:D 11:J 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:k 11:a 11:D 11:k 11:L 11:D
11:D 11:L 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D 11:[JZ] 11:P
11:D 11:[JZ] 11:P 11:D 11:J 11:P 11:D 11:J 11:[JB] 11:D 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D
11:J 11:P 11:D 11:J 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:[kn] 11:a 11:D 11:k 11:a 11:D 11:k 11:L
11:D 11:D 11:L 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:[JZ] 11:P 11:D 11:[JZ] 11:P 11:D 11:[JZ]
11:P 11:D 11:[JZ] 11:P 11:D 11:J 11:P 11:D 11:J 11:[JB] 11:D 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P 11:D 11:[JB] 11:P
11:D 11:J 11:P 11:D 11:J 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:[kV] 11:a 11:D 11:k 11:a 11:D 11:k
11:L 11:D 11:D 11:L 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:a 11:D 11:k 11:j 11:S 11:G 11:j 11:S 11:G 11:j
11:S 11:G 11:j 11:S 11:G 11:j 11:S 11:G 11:j 11:j 11:G 11:G 11:j 11:S 11:G 11:j 11:S 11:G 11:j 11:S 11:G 11:j 11:S
11:G 11:j 11:J 11:D 11:G 11:J 11:D 11:G 11:J 11:D 11:G 11:J 11:D 11:G 11:J 11:D 11:G 11:J 11:Z 11:D 11:G 11:Z 11:D
11:G 11:L 11:D 11:G 11:L 11:D 11:G 11:J 11:D 11:G 11:J 11:j 11:S 11:G 11:j 11:S 11:G 11:j 11:S 11:G 11:j 11:S 11:G
11:j 11:S 11:G 11:j 11:j 11:G 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:j 11:g 11:g
11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:j 11:g 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j
11:S 11:g 11:j 11:S 11:g 11:j 11:j 11:g 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:j
11:g 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:[3J] 11:P 11:D 11:[wJ] 11:[rP] 11:[uD]
11:[IJ] 11:P 11:D 11:[iJ] 11:P 11:D 11:[uJ] 11:P 11:[rD] 11:J 11:[3J] 11:D 11:D 11:[wJ] 11:[rP] 11:[uD] 11:[IJ] 11:P
11:D 11:[iJ] 11:P 11:D 11:[uJ] 11:P 11:[rD] 11:J 11:[1k] 11:a 11:D 11:[0k] 11:[ta] 11:[uD] 11:[Ik] 11:a 11:D 11:[ik]
11:a 11:D 11:[uk] 11:a 11:[tD] 11:k 11:[1L] 11:D 11:D 11:[0L] 11:[ta] 11:[uD] 11:[Ik] 11:a 11:D 11:[ik] 11:a 11:D
11:[uk] 11:a 11:[tD] 11:k 11:[3J] 11:P 11:D 11:[wJ] 11:[rP] 11:[uD] 11:[IJ] 11:P 11:D 11:[iJ] 11:P 11:D 11:[uJ] 11:P
11:[rD] 11:J 11:[3J] 11:D 11:D 11:[wJ] 11:[rP] 11:[uD] 11:[IJ] 11:P 11:D 11:[iJ] 11:P 11:D 11:[uJ] 11:P 11:[rD] 11:J
11:[1k] 11:a 11:D 11:[0k] 11:[ta] 11:[uD] 11:[Ik] 11:a 11:D 11:[ik] 11:a 11:D 11:[uk] 11:a 11:[tD] 11:k 11:[1L] 11:D
11:D 11:[0L] 11:[ta] 11:[uD] 11:[Ik] 11:a 11:D 11:[ik] 11:a 11:D 11:[uk] 11:a 11:[tD] 11:k 11:[5j] 11:S 11:G 11:[wj]
11:[ES] 11:[IG] 11:[pj] 11:S 11:G 11:[Ij] 11:S 11:G 11:[yj] 11:S 11:[EG] 11:j 11:[5j] 11:G 11:G 11:[wj] 11:[ES]
11:[IG] 11:[pj] 11:S 11:G 11:[Ij] 11:S 11:G 11:[yj] 11:S 11:[EG] 11:j 11:[3J] 11:D 11:G 11:[wJ] 11:[rD] 11:[uG]
11:[IJ] 11:D 11:G 11:[iJ] 11:D 11:G 11:[uJ] 11:D 11:[rG] 11:J 11:[3Z] 11:D 11:G 11:[wZ] 11:[rD] 11:[uG] 11:[IL] 11:D
11:G 11:L 11:D 11:G 11:[uJ] 11:D 11:[rG] 11:J 11:[5j] 11:S 11:G 11:[wj] 11:[ES] 11:[IG] 11:[pj] 11:S 11:G 11:[Ij] 11:S
11:G 11:[yj] 11:S 11:[EG] 11:j 11:[5j] 11:G 11:G 11:[wj] 11:[ES] 11:[IG] 11:[pj] 11:S 11:G 11:[Ij] 11:S 11:G 11:[yj]
11:S 11:[EG] 11:j 11:[$j] 11:g 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j 11:j 11:g 11:g
11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:j 11:g 11:g 11:j 11:s 11:g 11:j 11:s 11:g 11:j
11:s 11:g 11:j 11:s 11:g 11:j 11:j 11:g 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j 11:S 11:g 11:j
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
    BPM=89,
    StepsPerBeat=48,
    Complete=true,
    Source="User-supplied MIDI",
    SourceLicense="User-provided source file; all four musical tracks converted for Velora.",
    Categories={"Famous","Game OST","Call of Duty","Zombies","Dark","Piano","Horror","Complete"},
    Notes=table.concat(sheet, " "),
}
