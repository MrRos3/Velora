-- Velora 0.10.20 Nova — complete arrangement converted from a MIDI supplied by the repository owner.
-- Supplied file: great-fairy-fountain-the-legend-of-zelda-breath-of-the-wild.mid
-- Supplied file SHA-256: 6199A64D181319F8F66616BA9B5C43B3CA0B559C3A27975B5675D99608867A36
-- MIDI: 480 PPQ, 10 source tempo events, source time signatures: 6/4, 2/2.
-- Timing normalized to real seconds at 90 BPM / 48 Velora steps per beat.
-- Both piano tracks retained; simultaneous duplicate pitches are merged.
-- 4 out-of-range note-on events were folded by octave into Velora's C2-C7 keyboard range.

local DATA = [=[
0:[1f] 4:h 4:J 3:z 33:h 4:J 3:z 4:x 39:J 4:z 4:x 4:v 56:z 4:x 4:v 4:B 80:x 4:v 4:B 4:z 86:v 3:B 4:z 4:x 273:[Ej] 11:b 3:i 7:J
7:P 3:z 11:[dh] 11:v 3:P 7:J 7:i 3:z 11:[EG] 11:C 3:u 7:J 7:o 3:L 11:[Sh] 11:v 3:o 7:J 7:u 3:L 11:[eh] 11:v 3:i 7:j 7:p 3:l 11:[sg] 11:c
3:p 7:j 7:i 3:l 11:[ef] 11:x 3:i 7:j 7:p 3:l 11:[sg] 11:c 3:p 7:j 7:i 3:l 11:[wg] 11:c 3:y 7:h 7:i 3:J 11:[Pf] 11:x 3:i 7:h 7:y 3:J
11:[wD] 11:Z 3:t 7:h 7:u 3:J 11:[Pf] 11:x 3:u 7:h 7:t 3:J 11:[qf] 11:x 3:t 7:g 7:u 3:j 11:[pd] 11:z 3:i 7:g 7:t 3:j 11:[qS] 11:L 3:t 7:g
7:u 3:j 11:[pd] 11:z 3:t 7:l 7:Y 3:J 11:[Ej] 11:b 3:i 7:J 7:P 3:z 11:[dh] 11:v 3:P 7:J 7:i 3:z 11:[EG] 11:C 3:u 7:J 7:o 3:L 11:[Sh] 11:v
3:o 7:J 7:u 3:L 11:[eJ] 11:B 3:Y 7:l 7:I 3:Z 11:[sj] 11:b 3:I 7:l 7:Y 3:Z 11:[yH] 11:V 3:I 7:l 7:s 3:Z 11:[dj] 11:b 3:s 7:l 7:I 3:z
11:[wl] 11:m 3:y 7:z 7:o 3:b 11:[PJ] 11:B 3:o 7:z 7:y 3:v 11:[wj] 11:b 3:y 7:z 7:o 3:C 11:[PJ] 11:B 3:o 7:z 7:y 3:v 11:[tj] 11:b 3:o 7:J
7:P 3:z 11:[dh] 11:v 3:P 7:J 7:o 3:z 11:[tg] 11:c 3:o 7:J 7:P 3:l 11:f 11:x 3:P 7:J 7:o 3:l 11:[Ej] 11:b 3:i 7:J 7:P 3:z 11:[dh] 11:v
3:P 7:J 7:i 3:z 11:[EG] 11:C 3:u 7:J 7:o 3:L 11:[Sh] 11:v 3:o 7:J 7:u 3:L 11:[eh] 11:v 3:i 7:j 7:p 3:l 11:[sg] 11:c 3:p 7:j 7:i 3:l
11:[ef] 11:x 3:i 7:j 7:p 3:l 11:[sg] 11:c 3:p 7:j 7:i 3:l 11:[wg] 11:c 3:y 7:h 7:i 3:J 11:[Pf] 11:x 3:i 7:h 7:y 3:J 11:[wD] 11:Z 3:t 7:h
7:u 3:J 11:[Pf] 11:x 3:u 7:h 7:t 3:J 11:[qf] 11:x 3:t 7:g 7:u 3:j 11:[pd] 11:z 3:i 7:g 7:t 3:j 11:[qS] 11:L 3:t 7:g 7:u 3:j 11:[pd] 11:z
3:t 7:l 7:Y 3:J 11:[Ej] 11:b 3:i 7:J 7:P 3:z 11:[dh] 11:v 3:P 7:J 7:i 3:z 11:[EG] 11:C 3:u 7:J 7:o 3:L 11:[Sh] 11:v 3:o 7:J 7:u 3:L
11:[eJ] 11:B 3:Y 7:l 7:I 3:Z 11:[sj] 11:b 3:I 7:l 7:Y 3:Z 11:[yH] 11:V 3:I 7:l 7:s 3:Z 11:[dj] 11:b 3:s 7:l 7:I 3:z 11:[wl] 11:m 3:y 7:z
7:o 3:b 11:[PJ] 11:B 3:o 7:z 7:y 3:v 11:[wj] 11:b 3:y 7:z 7:o 3:C 11:[PJ] 11:B 3:o 7:z 7:y 3:v 11:[tj] 11:b 3:o 7:J 7:P 3:z 11:[dh] 11:v
3:P 7:J 7:o 3:z 11:[tg] 11:c 3:o 7:J 7:P 3:l 11:f 11:x 3:P 7:J 7:o 3:l
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
    Id="great-fairy-fountain",
    Name="Great Fairy Fountain",
    Artist="The Legend of Zelda: Breath of the Wild",
    BPM=90,
    StepsPerBeat=48,
    Complete=true,
    Source="User-supplied MIDI",
    SourceLicense="User-provided source file; arrangement converted for Velora.",
    Categories={"Famous","Soundtrack","The Legend of Zelda","Nintendo","Fantasy","Piano","Dreamy","Complete"},
    Notes=table.concat(sheet, " "),
}
