-- Velora 0.10.44 Nova - full arrangement converted from a MIDI supplied by the repository owner.
-- Source: floating-in-reverie-moayad-aljabal.mid
-- SHA-256: 28446c6b5155974d69dcda1fb1deb53634f7f188f7766e3613698fdfdb1ddc28
-- MIDI: 480 PPQ, 90 BPM, 2 piano tracks, B major, meter 6/4 -> 9/8 -> 6/4.
-- 721 source note-ons -> 717 distinct playable note-ons, 1 bass note octave-folded.
-- All note onsets are on an exact 60-tick grid: 8 Velora steps per beat. No onset quantization.
local DATA=[=[
0:[%WYOaH] 3:[rY] 3:[rY] 3:[WD] 3:[rY] 3:[rYS] 3:[WD] 3:[rY] 3:[rY] 3:W 3:[rY] 3:[rY] 3:[$QYIPH] 3:[EY] 3:[EY] 3:[QD] 3:[WY] 3:[EYS] 3:[QD] 3:[EY]
3:[EY] 3:Q 3:[EY] 3:[EY] 3:[30YOaH] 3:[WT] 3:[WT] 3:[0J] 3:[WT] 3:[WTk] 3:[0J] 3:[WT] 3:[WT] 3:0 3:[WT] 3:[WT] 3:[@(YIPH] 3:[QE] 3:[QE] 3:[(D]
3:[QE] 3:[QES] 3:[(G] 3:[QE] 3:[QE] 3:[(f] 3:[QE] 3:[QE] 1:S 0:D 0:[%WYOaH] 3:[rY] 3:[rY] 3:[WD] 3:[rY] 3:[rYS] 3:[WD] 3:[rY] 3:[rY] 3:W
3:[rY] 3:Y 3:[$QYIPH] 3:[EY] 3:[EY] 3:[QD] 3:[EY] 3:[EYS] 3:[QD] 3:[EY] 3:[EY] 3:Q 3:[EY] 3:[EY] 3:[30YOaH] 3:[WT] 3:[WT] 3:[0J] 3:[WT] 3:[WTk]
3:[0J] 3:[WT] 3:[WT] 3:0 3:[WT] 3:[WT] 3:[@(YoPhv] 3:[wE] 3:[wE] 3:[(HV] 3:[wE] 3:[wE] 3:[(JB] 3:[wE] 3:[wE] 3:( 3:[wE] 3:[wE] 3:[%WYOaH] 3:[rYD]
3:[rYS] 3:[WH] 3:[rYD] 3:[rYS] 3:[WH] 3:[rYD] 3:[rYS] 3:[WH] 3:[rYD] 3:[rYS] 3:[$QYIPH] 3:[EYD] 3:[EYS] 3:[QH] 3:[EYD] 3:[EYS] 3:[QH] 3:[EYD] 3:[EYS] 3:[QH]
3:[EYD] 3:[EYS] 3:[30TuOJ] 3:[WTH] 3:[WTD] 3:[0J] 3:[WTH] 3:[WTD] 3:[0J] 3:[WTH] 3:[WTD] 3:[0J] 3:[WTH] 3:[WTD] 3:[@(YIPk] 3:[QEH] 3:[QED] 3:[(k] 3:[QEH] 3:[QED]
3:[(L] 3:[QEH] 3:[ED] 3:[(Z] 3:[QEH] 3:[QED] 3:[%WYOaH] 3:[rYD] 3:[rYS] 3:[WJ] 3:[rYD] 3:[rYS] 3:[Wk] 3:[rYD] 3:[rYS] 3:[$QYIPH] 3:[EYD] 3:[EYS] 3:[QJ] 3:[EYD]
3:[EYS] 3:[Qk] 3:[EYD] 3:[EYS] 3:[3QTuOJ] 3:[WTH] 3:[WTD] 3:[0k] 3:[WTH] 3:[WTD] 3:[0L] 3:[WTH] 3:[WTD] 3:[@(YIPJ] 3:[QEH] 3:[QED] 3:[(k] 3:[QEH] 3:[QED] 3:[(L]
3:[QEH] 3:[ED] 3:[(Z] 3:[QEH] 3:[ED] 3:[%WYOaH] 3:[rY] 3:[rY] 3:[WG] 3:[rY] 3:[rYf] 3:[WD] 3:[rY] 3:[rY] 3:W 3:[rYD] 3:[rY] 1:D 0:f 0:[$QYIPH]
3:[EY] 3:[EY] 3:[QD] 3:[WY] 3:[EYS] 3:[QD] 3:[EY] 3:[EY] 3:Q 3:[EY] 3:Y 3:[30TuOH] 3:[WT] 3:[WT] 3:[0J] 3:[WT] 3:[WTk] 3:[0J] 3:[WT] 3:[WT]
3:0 3:[WT] 3:[WT] 3:[@(YoPhv] 3:[wE] 3:[wE] 3:[(HV] 3:[wE] 3:[wE] 3:[(JB] 3:[wE] 3:[wE] 15:[%WYOaH] 3:[rY] 3:[rY] 3:[WD] 3:[rY] 3:[rYS] 3:[WD] 3:[rY]
3:[rY] 3:W 3:[rY] 3:[rY] 3:[$QYIPH] 3:[EY] 3:[EY] 3:[QD] 3:[EY] 3:[EYS] 3:[QD] 3:[EY] 3:[EY] 3:Q 3:[EY] 3:[EY] 3:[30TuOH] 3:[WT] 3:[WT] 3:[0J]
3:[WT] 3:[WTk] 3:[0J] 3:[WT] 3:[WT] 3:0 3:[WT] 3:[WT] 3:[@(YIPH] 3:[QE] 3:[QE] 3:[(D] 3:[QE] 3:[QES] 3:[(G] 3:[QE] 3:[QEG] 3:[(f] 3:[QEf] 3:[QE]
3:[QE]
]=]
local sheet={}
for encoded in DATA:gmatch("%S+") do
    local gap,token=encoded:match("^(%d+):(.+)$")
    if gap and token then
        for _=1,tonumber(gap) do sheet[#sheet+1]="-" end
        sheet[#sheet+1]=token
    end
end
for _=1,47 do sheet[#sheet+1]="-" end
return {
    Id="floating-in-reverie-moayad-aljabal",
    Name="Floating in Reverie",
    Artist="Moayad Aljabal",
    BPM=90, StepsPerBeat=8, Complete=true,
    DurationSeconds=97.001, OriginalDurationSeconds=97.001,
    TempoEvents=1, TimeSignatures={"6/4","9/8","6/4"}, KeySignatures={"B"},
    Source="User-supplied MIDI file",
    SourceFile="floating-in-reverie-moayad-aljabal.mid",
    Categories={"Famous","Piano","Instrumental","Moayad Aljabal","Complete"},
    Notes=table.concat(sheet," ")
}
