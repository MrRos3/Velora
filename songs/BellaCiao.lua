-- Velora complete piano conversion from a MIDI supplied by the repository owner.
-- Supplied file: bella-ciao.mid
-- Supplied file SHA-256: BF629C05C901147AFDE724C570B904BADB786BDD77E96A1CF63B27DDA3497D20
-- MIDI: 480 PPQ with source tempo changes.
-- Retained 1,421 source note-ons; 1,311 mapped notes remain after same-step duplicate merging.
-- Timing is normalized to real seconds at 120 BPM / 48 steps per beat, preserving MIDI tempo changes.
-- Notes outside Velora's C2-C7 keyboard range are octave-folded into the playable range.

local DATA = [=[
24:r 23:u 23:I 23:[3uoa] 23:[0wu] 23:7 23:[0w] 23:3 23:[0wr] 23:[7u] 23:[0wI] 23:[3o] 23:[0wu] 23:7 23:[0w] 23:3 23:[0wr] 23:[7u] 23:[0wI] 23:[3uo] 23:[0w] 23:[7I]
23:[0wu] 23:[2yIop] 23:[9Q] 23:[2I] 23:[9Qu] 23:[1tuoa] 23:[80] 23:[1tua] 23:[80] 23:[7rYIa] 23:[7(] 23:[7Ip] 23:[7(oa] 23:[6tups] 23:[80us] 23:3 23:[80] 23:6 23:[80osf]
23:[1Iad] 23:[80ups] 23:[3uIoasf] 23:[0wuad] 23:7 23:[0w] 23:3 23:[0w] 23:[7Ip] 23:[0wuo] 23:[$7YIpa] 23:[7(e] 23:[7Ia] 23:[7(e] 23:[$YI] 23:[7(e] 23:[7uo] 23:[7(e]
23:[3ruoa] 23:[0w] 23:7 23:[0w] 23:3 23:[0wr] 23:[7u] 23:[0wI] 23:[3uoa] 23:[0wu] 23:7 23:[0w] 23:3 23:[0wr] 23:[7u] 23:[0wI] 23:[3o] 23:[0wu] 23:7 23:[0w] 23:3 23:[0wr]
23:[7u] 23:[0wI] 23:[3uo] 23:[0w] 23:[7I] 23:[0wu] 23:[2yIop] 23:[9Q] 23:[2I] 23:[9Qu] 23:[1tuoa] 23:[80] 23:[1tua] 23:[80] 23:[7rYIa] 23:[7(] 23:[7Ip] 23:[7(oa]
23:[6tups] 23:[80us] 23:3 23:[80] 23:6 23:[80osf] 23:[1Iad] 23:[80ups] 23:[3uIoasf] 23:[0wuad] 23:7 23:[0w] 23:3 23:[0w] 23:[7Ip] 23:[0wuo] 23:[$7YIpa] 23:[7(e] 23:[7Ia]
23:[7(e] 23:[$YI] 23:[7(e] 23:[7uo] 23:[7(e] 23:[3ru] 23:[0w] 23:7 23:[0w] 23:3 23:[0w] 23:[7af] 23:[0w] 23:[4tiOsg] 23:[qW] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i] 23:[qWo]
23:[4O] 23:[qWi] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i] 23:[qWo] 23:[4O] 23:[qWi] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i] 23:[qWo] 23:[4iO] 23:[qW] 23:[1o] 23:[qWi] 23:[@YoOP]
23:[(w] 23:[@o] 23:[(wi] 23:[!tTiOs] 23:[*q] 23:[!Tis] 23:[*q] 23:[1tuos] 23:[80] 23:[1oP] 23:[80Os] 23:[^TiPS] 23:[*qiS] 23:4 23:[*q] 23:^ 23:[*qOSg] 23:[!osD]
23:[*qiPS] 23:[4tioOSg] 23:[qWisD] 23:1 23:[qW] 23:4 23:[qW] 23:[1oP] 23:[qWiO] 23:[15tuoP] 23:[80E] 23:[1os] 23:[80E] 23:[5uo] 23:[80E] 23:[1iO] 23:[80E] 23:[4tiO]
23:[qW] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i] 23:[qWo] 23:[4O] 23:[qWi] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i] 23:[qWo] 23:[4O] 23:[qWi] 23:1 23:[qW] 23:4 23:[qWt] 23:[1i]
23:[qWo] 23:[4iO] 23:[qW] 23:[1o] 23:[qWi] 23:[@YoOP] 23:[(w] 23:[@o] 23:[(wi] 23:[!tTiOs] 23:[*q] 23:[!Tis] 23:[*q] 23:[1tuos] 23:[80] 23:[1oP] 23:[80Os] 23:[^TiPS]
23:[*qiS] 23:4 23:[*q] 23:^ 23:[*qOSg] 23:[!osD] 23:[*qiPS] 23:[4tioOSg] 23:[qWisD] 23:1 23:[qW] 23:4 23:[qW] 23:[1oP] 23:[qWiO] 23:[15tuoP] 23:[80E] 23:[1os] 23:[80E]
23:[5uo] 23:[80E] 23:[1iO] 23:[80E] 23:[4ti] 23:[qW] 23:1 23:[qW] 23:4 23:[qW] 23:[1sg] 23:[qW] 23:[$TIpSG] 23:[Qe] 23:! 23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$p]
23:[QeI] 23:! 23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$p] 23:[QeI] 23:! 23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$Ip] 23:[Qe] 23:[!O] 23:[QeI] 23:[3uOpa] 23:[0W]
23:[3O] 23:[0WI] 23:[2TyIpS] 23:[9Q] 23:[2yIS] 23:[9Q] 23:[!TiOS] 23:[*q] 23:[!Oa] 23:[*qpS] 23:[7yIad] 23:[9QId] 23:$ 23:[9Q] 23:7 23:[9QpdG] 23:[2OSf] 23:[9QIad]
23:[$TIOpdG] 23:[QeISf] 23:! 23:[Qe] 23:$ 23:[Qe] 23:[!Oa] 23:[QeIp] 23:[!%TiOa] 23:[*qr] 23:[!OS] 23:[*qr] 23:[%iO] 23:[*qr] 23:[!Ip] 23:[*qr] 23:[$TIp] 23:[Qe] 23:!
23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$p] 23:[QeI] 23:! 23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$p] 23:[QeI] 23:! 23:[Qe] 23:$ 23:[QeT] 23:[!I] 23:[QeO] 23:[$Ip]
23:[Qe] 23:[!O] 23:[QeI] 23:[3uOpa] 23:[0W] 23:[3O] 23:[0WI] 23:[2TyIpS] 23:[9Q] 23:[2yIS] 23:[9Q] 23:[!TiOS] 23:[*q] 23:[!Oa] 23:[*qpS] 23:[7yIad] 23:[9QId] 23:$ 23:[9Q]
23:7 23:[9QpdG] 23:[2OSf] 23:[9QIad] 23:[$TIOpdG] 23:[QeISf] 23:! 23:[Qe] 23:$ 23:[Qe] 23:[!Oa] 23:[QeIp] 23:[!%TiOa] 23:[*qr] 23:[!OS] 23:[*qr] 23:[%iO] 23:[*qr]
23:[!Ip] 23:[*qr] 23:[$TI] 23:[Qe] 23:! 23:[Qe] 23:$ 23:[Qe] 23:[!Oa] 23:[QepS] 23:[7yIad] 23:[9QId] 23:$ 23:[9Q] 23:7 23:[9QpdG] 23:[2OSf] 23:[9QIad] 23:[$TIOpdG]
23:[QeISf] 23:! 23:[Qe] 23:$ 23:[Qe] 23:[!Oa] 23:[QeIp] 23:[!%TiOa] 23:[*qr] 23:[!OS] 23:[*qr] 23:[%iO] 23:[*qr] 23:[!Ip] 23:[*qr] 23:[$TIp] 23:[Qe] 23:! 23:[Qe] 23:$
23:[Qe] 23:[!Oa] 23:[QepS] 23:[7yIad] 23:[9QId] 23:$ 23:[9Q] 23:7 23:[9QpdG] 23:[2OSf] 23:[9QIad] 23:[$TIOpdG] 23:[QeISf] 23:! 23:[Qe] 23:$ 23:[Qe] 23:[!Oa] 23:[QeIp]
23:[!%TiOa] 23:[*qr] 23:[!OS] 23:[*qr] 23:[%iO] 23:[*qr] 23:[!Ip] 23:[*qr] 23:[$*eTIp]
]=]
local TRAILING_RESTS = 191

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
    Id="bella-ciao",
    Name="Bella Ciao",
    Artist="Traditional Italian",
    BPM=120,
    StepsPerBeat=48,
    Complete=true,
    DurationSeconds=117.000,
    OriginalDurationSeconds=117.001,
    TempoEvents=4,
    TimeSignatures={"2/4","4/4","4/4"},
    Source="User-supplied MIDI",
    SourceFile="bella-ciao.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Folk","Italian","Traditional","Piano","Complete"},
    Notes=table.concat(sheet, " "),
}
