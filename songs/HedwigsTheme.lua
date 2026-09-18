-- Velora 0.10.30 Nova — complete arrangement matched to the sheet music supplied by the repository owner.
-- Reference: Hedwig's Theme — John Williams.
-- MIDI timing reference: reality3d/3d-piano-player/midi/hedwigs_theme.mid
-- MIDI: 1024 PPQ, 109 source tempo events, source time signature(s): 3/8, 4/4.
-- Timing normalized to real seconds at 66 BPM / 48 Velora steps per beat, preserving all source tempo changes.
-- 2 non-drum piano tracks retained; simultaneous duplicate pitches are merged.
-- All source notes already fit Velora's C2-C7 keyboard range.
-- 450 source note-ons became 450 mapped notes after same-step duplicate merging.

local DATA = [=[
48:a 24:[uf] 36:h 11:G 23:[uf] 47:k 23:[uj] 71:[uG] 71:[uf] 35:h 11:G 23:[PD] 47:[rg] 24:[ua] 48:o 22:a 48:[ra] 24:[uf] 36:h 10:G 23:[uf] 47:k 15:d 3:h 3:[yoPz] 47:L 15:s 3:g 3:[tiOl] 47:H 15:s 3:f
3:[tupl] 36:k 10:J 23:[TuIP] 47:h 23:[uf] 47:o 23:a 48:[rh] 23:[uk] 48:[oh] 23:[ak] 47:[rh] 24:[ul] 48:[ok] 23:[sJ] 47:[rG] 23:[uh] 36:k 11:[oJ] 23:[tP] 48:[oa] 23:[uk] 47:o 23:a 47:[rh] 24:[uk] 48:[oh] 23:[ak] 47:[oh] 15:d 3:h
3:[yoPz] 48:L 15:s 3:g 3:[tiOl] 47:H 15:s 3:f 3:[tupl] 35:k 11:J 24:[TuIP] 52:h 27:[uoaf] 29:r 27:w 30:[30] 97:[ua] 10:[ua] 10:[ua] 10:[ua] 10:[ua] 9:[ua] 10:[YP] 10:[ua] 10:[isd] 21:[ua] 10:[YP] 9:[ua] 21:[ro] 20:[tp] 22:[tp]
9:[rO] 10:[tp] 21:[et] 20:[wr] 21:[ru] 10:[ro] 10:[YP] 42:[ua] 11:[ua] 9:[ua] 10:[ua] 10:[ua] 10:[ua] 9:[YP] 10:[ua] 10:[od] 21:[is] 10:[ua] 10:[is] 20:[tO] 22:[is] 21:[ua] 10:[YP] 9:[ua] 21:[ru] 21:[ro] 42:[erY] 42:[pf] 11:[pf] 10:[pf] 9:[pf] 10:[pf]
10:[pf] 10:[OD] 9:[pf] 10:[Pg] 21:[pf] 10:[OD] 10:[pf] 20:[us] 21:[id] 21:[id] 10:[uS] 10:[id] 20:[yi] 21:[tu] 21:[up] 10:[os] 10:[OD] 42:[pf] 10:[pf] 10:[pf] 10:[pf] 9:[pf] 10:[pf] 10:[OD] 10:[pf] 9:[sh] 22:[Pg] 9:[pf] 10:[Pg] 21:[TiP] 21:[Pg] 22:[pf]
9:[OD] 10:[pf] 21:[up] 20:[is] 43:[%Wu] 20:u 5:y 4:t 4:r 5:[60e] 5:t 4:u 5:p 4:s 5:f 4:j 4:l 5:x 4:l 5:j 4:f 4:s 10:[gh] 10:g 10:S 10:f 5:S 4:P 4:S 5:f 4:s 4:p
5:u 4:t 5:u 4:p 4:s 5:[6ed] 5:p 4:i 4:y 5:q 10:i 4:O 4:[6ep] 5:d 4:p 4:i 5:y 10:i 4:p 4:e 6:t 4:u 4:p 5:s 4:f 4:j 5:l 4:Z 42:[60] 5:t 5:u 4:p
5:s 4:f 4:j 4:l 5:[eupx] 5:l 4:j 4:f 5:[tsd] 20:[6h] 5:D 5:s 4:D 4:[eg] 5:S 4:P 4:S 5:[6g] 4:S 5:P 4:S 4:[Ti] 5:P 4:i 4:S 5:[6g] 5:S 4:P 5:S 4:[erf] 5:S 4:P
4:S 5:[6uf] 4:s 4:p 5:u 4:[tO] 10:p 10:[qtp] 21:[tpsf] 20:[isH] 21:[uOadHkx]
]=]
local TRAILING_RESTS = 20

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
    Id="hedwigs-theme-john-williams",
    Name="Hedwig's Theme",
    Artist="John Williams",
    BPM=66,
    StepsPerBeat=48,
    Complete=true,
    DurationSeconds=85.766,
    OriginalDurationSeconds=85.766,
    TempoEvents=109,
    TimeSignatures={"3/8","4/4"},
    Source="User-provided sheet screenshots matched to a public piano MIDI timing reference",
    SourceFile="hedwigs_theme.mid",
    Categories={"Famous","Soundtrack","Film","Harry Potter","John Williams","Piano","Complete"},
    Notes=table.concat(sheet, " "),
}
