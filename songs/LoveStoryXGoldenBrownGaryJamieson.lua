-- Velora 0.10.43 Nova - additional complete piano arrangement from a user-provided MIDI.
-- Source file: love-story-x-golden-brown-gary-jamieson.mid
-- Source SHA-256: D41535D2D497652B2B9CD26CCB722FDB439580D9430EF7F0BBB86F7A13398C07
-- MIDI: 1323 source notes, 1211 playable mapped notes across 2 piano tracks.
-- 2 tempo events, 142 octave folds. Real-time note onsets preserved.
-- Maximum mapped onset rounding: 0.01 ms.
local DATA=[=[
0:^ 11:[ETi] 11:[ETi] 11:4 11:[qWt] 11:[qWt] 11:$ 11:[QET] 11:[QET] 11:% 11:[WtY] 11:[WtY] 11:^ 11:[ETi] 11:[ETi] 11:4 11:[qWt] 11:[qWt] 11:$ 11:[QET] 11:[QET] 11:% 11:[WtY] 11:[WtY] 11:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg]
8:P 2:[4i] 8:[Os] 2:[qWt] 8:I 2:[qWtOs] 11:[$I] 8:[PS] 2:[QET] 8:I 2:[QETPS] 8:I 2:[%O] 8:[sD] 2:[WtY] 8:O 2:[WtYsD] 8:O 2:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg] 8:P 2:[4i] 11:[qWtOs] 11:[qWtOs] 11:[$I] 8:[PS]
2:[QET] 8:I 2:[QETPS] 8:I 2:[%O] 8:[sD] 2:[WtY] 8:O 2:[WtYsD] 8:O 2:[^PJ] 11:[ETi] 11:[ETi] 11:[4sl] 11:[qWt] 11:[qWt] 11:[$SL] 11:[QET] 11:[QET] 11:[%GC] 11:[WtYgc] 11:[WtYSL] 11:[^HV] 11:[ETiGC] 11:[ETigc] 11:[4sl] 11:[qWt] 11:[qWt] 11:[$SL]
11:[QET] 11:[QET] 11:[%sl] 11:[WtY] 11:[WtY] 11:[^PSgJ] 11:[ETi] 11:[ETi] 11:[4sgHl] 11:[qWt] 11:[qWt] 11:[$SGJL] 11:[QET] 11:[QET] 11:[%GlC] 11:[WtYgc] 11:[WtYSL] 11:[^HlcV] 11:[ETiGC] 11:[ETigc] 11:[4sgHl] 11:[qWt] 11:[qWt] 11:[$SGJL] 11:[QET] 11:[QET] 11:[%sDHl] 11:[WtYs] 3:D
3:H 3:[WtYl] 3:Z 3:[HV] 3:[^JLcB] 11:[ETi] 11:[ETi] 11:[4lcVm] 11:[qWt] 11:[qWt] 11:[$LCB] 11:[QET] 11:[QET] 11:[%CVm] 11:[WtYc] 11:[WtYL] 11:[^LVB] 11:[ETiC] 11:[ETic] 11:[4lcVm] 11:[qWt] 11:[qWt] 11:[$LCB] 11:[QET] 11:[QET] 11:[%lZVm] 11:[WtY] 11:[WtY] 11:[^LcB]
5:J 5:[ETiLcB] 5:J 5:[ETiLcB] 5:J 5:[4cVm] 5:l 5:[qWtcVm] 5:l 5:[qWtcVm] 5:l 5:[$LCB] 5:L 5:[QETLCB] 5:L 5:[QETLCB] 5:L 5:[%Cm] 5:V 5:[WtYcm] 5:V 5:[WtYL] 5:V 5:[^L] 5:V 5:[ETiLC] 5:V 5:[ETiLc] 5:V
5:[4cVm] 5:l 5:[qWtcVm] 5:l 5:[qWtcVm] 5:l 5:[$LCB] 5:L 5:[QETLCB] 5:L 5:[QETLCB] 5:L 5:[%ZVm] 5:l 5:[WtYZVm] 5:l 5:[WtYZVm] 5:l 5:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg] 8:P 2:[4i] 8:[Os] 2:[qWt] 8:I 2:[qWtOs]
11:[$I] 8:[PS] 2:[QET] 8:I 2:[QETPS] 8:I 2:[%O] 8:[sD] 2:[WtY] 8:O 2:[WtYsD] 8:O 2:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg] 8:P 2:[4i] 11:[qWtOs] 11:[qWtOs] 11:[$I] 8:[PS] 2:[QET] 8:I 2:[QETPS] 8:I 2:[%O] 8:[sD]
2:[WtY] 8:O 2:[WtYsD] 8:O 2:[^PJ] 11:[ETi] 11:[ETi] 11:[4sl] 11:[qWt] 11:[qWt] 11:[$SL] 11:[QET] 11:[QET] 11:[%GC] 11:[WtYgc] 11:[WtYSL] 11:[^HV] 11:[ETiGC] 11:[ETigc] 11:[4sl] 11:[qWt] 11:[qWt] 11:[$SL] 11:[QET] 11:[QET] 11:[%sl] 11:[WtY] 11:[WtY] 11:[^PSgJ]
11:[ETi] 11:[ETi] 11:[4sgHl] 11:[qWt] 11:[qWt] 11:[$SGJL] 11:[QET] 11:[QET] 11:[%GlC] 11:[WtYgc] 11:[WtYSL] 11:[^HlcV] 11:[ETiGC] 11:[ETigc] 11:[4sgHl] 11:[qWt] 11:[qWt] 11:[$SGJL] 11:[QET] 11:[QET] 11:[%sDHl] 11:[WtYs] 3:D 3:H 3:[WtYl] 3:Z 3:[HV] 3:[^JLcB] 11:[ETi]
11:[ETi] 11:[4lcVm] 11:[qWt] 11:[qWt] 11:[$LCB] 11:[QET] 11:[QET] 11:[%CVm] 11:[WtYc] 11:[WtYL] 11:[^LVB] 11:[ETiC] 11:[ETic] 11:[4lcVm] 11:[qWt] 11:[qWt] 11:[$LCB] 11:[QET] 11:[QET] 11:[%lZVm] 11:[WtY] 11:[WtY] 11:[^LcB] 5:J 5:[ETiLcB] 5:J 5:[ETiLcB] 5:J 5:[4cVm]
5:l 5:[qWtcVm] 5:l 5:[qWtcVm] 5:l 5:[$LCB] 5:L 5:[QETLCB] 5:L 5:[QETLCB] 5:L 5:[%Cm] 5:V 5:[WtYcm] 5:V 5:[WtYL] 5:V 5:[^L] 5:V 5:[ETiLC] 5:V 5:[ETiLc] 5:V 5:[4cVm] 5:l 5:[qWtcVm] 5:l 5:[qWtcVm] 5:l
5:[$LCB] 5:L 5:[QETLCB] 5:L 5:[QETLCB] 5:L 5:[%ZVm] 5:l 5:[WtYZVm] 5:l 5:[WtYZVm] 5:l 5:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg] 8:P 2:[4i] 8:[Os] 2:[qWt] 8:I 2:[qWtOs] 11:[$I] 8:[PS] 2:[QET] 8:I 2:[QETPS] 8:I
2:[%O] 8:[sD] 2:[WtY] 8:O 2:[WtYsD] 8:O 2:[^P] 8:[sg] 2:[ETi] 8:P 2:[ETiSg] 8:P 2:[4i] 11:[qWtOs] 11:[qWtOs] 11:[$I] 8:[PS] 2:[QET] 8:I 2:[QETPS] 8:I 2:[%O] 8:[sD] 2:[WtY] 8:O 2:[WtYsD] 8:O
]=]
local sheet={}
for encoded in DATA:gmatch("%S+") do
    local gap,token=encoded:match("^(%d+):(.+)$")
    if gap and token then
        for _=1,tonumber(gap) do sheet[#sheet+1]="-" end
        sheet[#sheet+1]=token
    end
end
for _=1,146 do sheet[#sheet+1]="-" end
return {
    Id="love-story-x-golden-brown-gary-jamieson",
    Name="Love Story × Golden Brown (Gary Jamieson)",
    Artist="Indila × The Stranglers",
    BPM=184,StepsPerBeat=12,Complete=true,
    DurationSeconds=97.826,OriginalDurationSeconds=97.826,
    TempoEvents=2,TimeSignatures={"3/4"},KeySignatures={"Db"},
    Arrangement="Gary Jamieson",
    Source="User-supplied MIDI file",
    SourceFile="love-story-x-golden-brown-gary-jamieson.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Mashup","Indila","The Stranglers","Gary Jamieson","Piano","Complete"},
    Notes=table.concat(sheet," "),
}
