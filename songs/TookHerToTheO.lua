-- Velora 0.10.36 Nova — complete arrangement converted from a MIDI supplied by the repository owner.
-- Source file: took-her-to-the-o-king-von.mid
-- Source SHA-256: 9DDC882898D656BD191761C750E1E634D9250B2B51095311CF1A9941636BEEDD
-- MIDI: 480 PPQ, 3 source tempo event(s), source time signature(s): 4/4, key signature E major.
-- 2 piano tracks retained; simultaneous duplicate pitches are merged.
-- 33 out-of-range note-on events were octave-folded into Velora's C2-C7 keyboard range.
-- 504 source note-ons became 499 mapped notes after same-step duplicate merging.
-- Real-time timing is preserved, including the final slowdown from 80 BPM to 40 BPM.

local DATA = [=[
0:[357r] 23:o 23:I 23:[356r] 23:t 23:I 23:[4%8o] 23:t 23:[357r] 23:o 23:I 23:[356r] 23:t 23:I 23:[145u] 23:t 23:[357r] 23:o 23:I 23:[356r] 23:t 23:I 23:[4%8o] 23:t 23:[357r] 23:o 23:I 23:[356r]
23:t 23:I 23:[145u] 23:t 23:[7ruo] 23:w 23:Q 23:7 23:[8p] 23:[Qo] 23:[wu] 23:[8r] 23:[7ruo] 23:w 23:Q 23:7 23:8 23:[Qp] 23:[8o] 23:[0I] 23:[7ruo] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7
11:[8ruo] 11:1 11:[QwYI] 11:$ 11:[wetu] 11:5 11:[80eu] 11:1 11:[7(Qr] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:[8(Qr] 11:1 11:[Qruo] 11:$ 11:[8wYI] 11:1 11:[0QeY] 11:3 11:[70tu] 11:7 11:w 11:5
11:Q 11:$ 11:7 11:7 11:[8u] 11:1 11:[QY] 11:$ 11:[wu] 11:5 11:[8I] 11:1 11:[7rYo] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:[8a] 11:1 11:[Qp] 11:$ 11:[8o] 11:1 11:[0t] 11:3
11:[7(Qr] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:8 11:[1I] 11:[Qu] 11:[$I] 11:[wo] 11:[5I] 11:[8u] 11:[1o] 11:[679Y] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:8 11:1 11:[Qwru] 11:$
11:8 11:1 11:0 11:3 11:[7QeY] 11:7 11:[wa] 11:5 11:[Qp] 11:$ 11:[7I] 11:7 11:[8u] 11:1 11:[Qo] 11:$ 11:[ws] 11:5 11:[8a] 11:1 11:[7wru] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7
11:8 11:1 11:[QerY] 11:$ 11:[80wy] 11:1 11:[0erY] 11:3 11:[7wru] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:8 11:1 11:[QeY] 11:$ 11:w 11:5 11:8 11:1 11:[7wru] 11:7 11:w 11:5
11:Q 11:$ 11:7 11:7 11:8 11:1 11:[QeY] 11:$ 11:8 11:1 11:0 11:3 11:[7wru] 11:[7QeY] 11:[wru] 11:[5QeY] 11:[Qwru] 11:[$QeY] 11:[7wru] 11:[7QeY] 11:[8wru] 11:1 11:Q 11:$ 11:w 11:5 11:8 11:1
11:[7wru] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:8 11:[1QeY] 11:[Qwru] 11:$ 11:8 11:1 11:0 11:3 11:[7wru] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:[8a] 11:1 11:[QI] 11:$
11:[wp] 11:5 11:[8o] 11:1 11:[7wru] 11:7 11:w 11:5 11:Q 11:$ 11:7 11:7 11:[8r] 11:1 11:[QY] 11:$ 11:8 11:1 11:[0o] 11:3 11:[7wru] 95:[0tup] 95:[QrI] 95:[7ruo] 95:[0Qru] 95:[7QrY] 95:[(Iaf] 95:[WYIpfk]
95:[0SHkx]
]=]
local TRAILING_RESTS = 383

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
for _ = 1, TRAILING_RESTS do
    sheet[#sheet + 1] = "-"
end

return {
    Id="took-her-to-the-o-king-von",
    Name="Took Her to the O",
    Artist="King Von",
    BPM=80,
    StepsPerBeat=48,
    Complete=true,
    DurationSeconds=78.000,
    OriginalDurationSeconds=78.000,
    TempoEvents=3,
    TimeSignatures={"4/4"},
    Key="E major",
    Source="User-supplied MIDI file",
    SourceFile="took-her-to-the-o-king-von.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Hip-Hop","Rap","King Von","Piano","Complete"},
    Notes=table.concat(sheet, " "),
}
