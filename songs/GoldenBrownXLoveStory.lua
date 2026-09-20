-- Velora 0.10.35 Nova — complete arrangement converted from a MIDI supplied by the repository owner.
-- Source file: golden-brown-x-love-story.mid
-- Source SHA-256: D3822263E3E8312545B21900D4FB1E0D4CD95CEA3A966F99F775FAA98A6BB134
-- MIDI: 480 PPQ, 1 tempo event(s), source time signature(s): 3/4, key signature D-flat major.
-- 2 piano tracks retained; simultaneous duplicate pitches are merged.
-- 27 out-of-range note-on events were octave-folded into Velora's C2-C7 keyboard range.
-- 688 source note-ons became 680 mapped notes after same-step duplicate merging.
-- Source timing lands exactly on a 1/30-beat grid, so StepsPerBeat=30 preserves every note-on position without quantization.

local DATA = [=[
0:^ 29:[ETi] 29:[ETi] 29:4 29:[qWt] 29:[qWt] 29:$ 29:[QET] 29:[QET] 29:% 29:[WtY] 29:[WtY] 29:^ 29:[ETi] 29:[ETi] 29:4 29:[qWt] 29:[qWt] 29:$ 29:[QET] 29:[QET] 29:% 29:[WtY] 29:[WtY] 29:[^P] 17:[Sg] 11:[ETi] 17:P 11:[ETiSg] 17:P 11:[4i] 29:[qWtOs]
29:[qWtOs] 29:[$I] 17:[PS] 11:[QET] 17:I 11:[QETPS] 17:I 11:[%O] 17:[sD] 11:[WtY] 17:O 11:[WtYsD] 17:O 11:[^P] 17:[Sg] 11:[ETi] 17:P 11:[ETiSg] 17:P 11:[4i] 29:[qWtOs] 29:[qWtOs] 29:[$I] 17:[PS] 11:[QET] 17:I 11:[QETPS] 17:I 11:[%O] 17:[sD] 11:[WtY] 17:O
11:[WtYsD] 17:O 11:[^PJ] 29:[qET] 29:[qET] 29:[4sl] 29:[qWt] 29:[qWt] 29:[$SL] 29:[QET] 29:[QET] 29:[%GC] 29:[WtYgc] 29:[WtYSL] 29:[^HV] 29:[qETGC] 29:[qETgc] 29:[4sl] 29:[qWt] 29:[qWt] 29:[$SL] 29:[QET] 29:[QET] 29:[%sl] 29:[WtY] 29:[WtY] 29:[^PSgJ] 29:[qET] 29:[qET] 29:[4sgHl] 29:[qWt] 29:[qWt]
29:[$SGJL] 29:[QET] 29:[QET] 29:[%GlZC] 29:[WtYglc] 29:[WtYSL] 29:[^HLV] 29:[qETGLC] 29:[qETgc] 29:[4sgHl] 29:[qWt] 29:[qWt] 29:[$SGJL] 29:[QET] 29:[QET] 29:[%sDHl] 29:[WtYs] 9:D 9:H 9:[WtYl] 9:Z 9:V 9:[^EJLcB] 29:[qET] 29:[qET] 29:[4qlVm] 29:[qWt] 29:[qWt] 29:[$QLB] 29:[QET] 29:[QET] 29:[%WZC]
29:[WtYc] 29:[WtYL] 29:[^EcV] 29:[qETC] 29:[qETc] 29:[4qlVm] 29:[qWt] 29:[qWt] 29:[$QLB] 29:[QET] 29:[QET] 29:[%WlVm] 29:[WtY] 29:[WtY] 29:[^EcB] 14:J 14:[qETcB] 14:J 14:[qETcB] 14:J 14:[4qcm] 14:l 14:[qWtcm] 14:l 14:[qWtcm] 14:l 14:[$QLB] 14:L 14:[QETLB] 14:L 14:[QETLB] 14:L
14:[%WZC] 14:C 14:[WtYLc] 14:c 14:[WtYLB] 14:L 14:[^EcV] 14:V 14:[qETZC] 14:C 14:[qETLc] 14:c 14:[4qVm] 14:l 14:[qWtVm] 14:l 14:[qWtVm] 14:l 14:[$QLB] 14:L 14:[QETLB] 14:L 14:[QETLB] 14:L 14:[%WVm] 14:l 14:[WtYVm] 14:l 14:[WtYVm] 14:l 14:[^P] 17:[Sg]
11:[ETi] 17:P 11:[ETiSg] 17:P 11:[4i] 29:[qWtOs] 29:[qWtOs] 29:[$I] 17:[PS] 11:[QET] 17:I 11:[QETPS] 17:I 11:[%O] 17:[sD] 11:[WtY] 17:O 11:[WtYsD] 17:O 11:[^P] 17:[Sg] 11:[ETi] 17:P 11:[ETiSg] 17:P 11:[4i] 29:[qWtOs] 29:[qWtOs] 29:[$I] 17:[PS] 11:[QET] 17:I
11:[QETPS] 17:I 11:[%O] 17:[sD] 11:[WtY] 17:O 11:[WtYsD] 17:O
]=]
local TRAILING_RESTS = 11

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
    Id="golden-brown-x-love-story",
    Name="Golden Brown × Love Story",
    Artist="The Stranglers × Indila",
    BPM=183,
    StepsPerBeat=30,
    Complete=true,
    DurationSeconds=55.082,
    OriginalDurationSeconds=55.082,
    TempoEvents=1,
    TimeSignatures={"3/4"},
    Key="D-flat major",
    Source="User-supplied MIDI file",
    SourceFile="golden-brown-x-love-story.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Mashup","TikTok","The Stranglers","Indila","Piano","Complete"},
    Notes=table.concat(sheet, " "),
}
