-- Velora 0.10.41 Nova — piano arrangement converted from a MIDI supplied by the repository owner.
-- Source file: theme-from-schindlers-list-piano-solo.mid
-- Source SHA-256: 55376A0A554E15709BDF13D7919F9BE3CD7166516D8CA35DB4073A7C5D3BC560
-- MIDI: 480 PPQ; 18 tempo event(s); time signatures: 1/4, 4/4; key signatures: Bb.
-- 2 source tracks, 467 playable note-ons; 1 same-step duplicate notes merged; 0 octave folds into Velora C2-C7.
-- Event onset timing follows real seconds through all source tempo changes; onsets quantized to 48 steps per 68 BPM beat.
-- Maximum onset quantization deviation: 9.026 ms.

local DATA = [=[
0:y 95:[5Ed] 5:9 17:o 23:[Ed] 23:o 23:[ED] 23:d 23:[EP] 23:y 23:[15(P] 23:t 23:[4(wYP] 23:[es] 23:[^tid] 6:q 20:E 27:[9eI] 67:[5Ed] 5:9 17:o 23:[Ed] 23:o 23:[8Eig] 5:Y 17:D 23:[EYid] 23:s 23:[4(wi] 23:Y
23:[ep] 23:s 23:[^qID] 23:[id] 23:[qYs] 23:[yP] 23:[6(wts] 23:Y 23:s 23:Y 23:[269tod] 23:s 23:[tIP] 23:s 23:[59pd] 5:E 41:o 47:[9EI] 47:o 23:y 23:[6s] 5:( 6:w 10:Y 23:s 23:Y 23:[9tod] 23:s 23:[tIP] 23:p
23:[@^(wyo] 47:t 47:[6weYop] 47:[2QyI] 47:[1EYP] 5:5 6:( 10:t 23:P 23:t 23:[9tod] 23:s 23:[tIP] 23:p 23:[5o] 27:9 32:E 40:[yd] 45:[wyP] 12:h 173:w 23:[Eyd] 11:s 11:D 23:[Eyd] 23:[wp] 23:[etY] 11:P 11:s 23:[etY]
23:w 23:[etYP] 11:s 11:p 23:[etYo] 11:I 11:[wp] 23:[Eyo] 47:[Ey] 23:5 23:[etYd] 11:s 11:[wetYg] 23:D 23:[wp] 23:[etY] 11:P 11:s 23:[etY] 23:6 23:[(t] 11:y 11:Y 23:[wY] 11:i 11:[to] 27:p 13:P 13:[(TopS] 67:[5d]
5:9 6:E 10:o 23:d 23:o 23:[5oD] 5:9 6:E 10:d 23:[9EP] 23:y 23:[15(E] 5:Y 6:P 10:t 23:[48wEYP] 23:[ets] 23:[^yid] 5:q 6:t 10:E 23:[9eI] 47:[59Ey] 5:o 6:d 10:o 23:[9ed] 23:[wo] 23:[8EYig] 23:D
23:[EYid] 23:s 23:[4(wi] 23:Y 23:[ep] 23:s 23:[^qtID] 23:[Eid] 23:[^QYs] 23:[wyP] 23:[6(wtos] 23:Y 23:s 23:Y 23:[9etod] 23:s 23:[tIP] 23:s 23:[59Eypd] 47:o 47:[59etI] 23:Y 23:[4Ey] 23:[ey] 23:[6wYos] 23:Y 23:[Yos] 23:[6Y] 23:[9wtod] 23:s
23:[9tyIP] 23:p 23:[@wyo] 11:^ 11:9 11:( 11:w 11:E 11:y 11:Y 11:[6wtYop] 47:[2QyI] 47:[1EYP] 5:5 6:( 10:t 23:P 23:t 23:[6wYod] 27:s 31:[29tIP] 33:p 35:[5io] 35:Y 36:[6y] 35:t 35:[8wY] 72:[9Qty] 71:[5o] 35:9
36:E 35:[yP] 35:[od] 35:[Ph] 36:[dJ] 35:z 35:[oJ] 6:[dz] 5:[hv]
]=]
local TRAILING_RESTS = 178

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
    Id="schindlers-list-theme",
    Name="Theme from Schindler's List",
    Artist="John Williams",
    BPM=68,
    StepsPerBeat=48,
    Complete=true,
    DurationSeconds=101.42,
    OriginalDurationSeconds=101.42,
    TempoEvents=18,
    TimeSignatures={"1/4","4/4"},
    KeySignatures={"Bb"},
    Source="User-supplied MIDI file",
    SourceFile="theme-from-schindlers-list-piano-solo.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Soundtrack","Film","Schindler's List","John Williams","Piano","Emotional","Complete"},
    Notes=table.concat(sheet," "),
}
