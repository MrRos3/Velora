-- Velora complete piano conversion from a MIDI supplied by the repository owner.
-- Supplied file: any-last-words-hu-taos-theme-genshin-impact.mid
-- Supplied file SHA-256: 7952C2171F3228D74B8F9AA963A24F1F7874429F5E799598A0D2559B58F9C001
-- MIDI: 480 PPQ with 120 BPM source tempo.
-- Retained 610 source note-ons; 600 mapped notes remain after same-step duplicate merging.
-- Timing is normalized to real seconds at 120 BPM / 48 steps per beat, preserving MIDI tempo changes.
-- Notes outside Velora's C2-C7 keyboard range are octave-folded into the playable range.

local DATA = [=[
0:6 95:[WrY] 95:6 95:[WrY] 47:[3u] 35:[$I] 5:[%O] 5:[6p] 95:[WrY] 47:Z 11:b 11:Z 11:j 11:6 95:[WrY] 35:[4i] 5:[3u] 5:[@Y] 47:6 95:[WrY] 95:6 95:[WrY] 23:D 7:s 7:p 7:i
23:u 23:6 71:D 11:D 11:[WrYD] 23:D 23:[pD] 119:f 119:6 47:[0Wr] 47:q 71:0 23:6 47:[Wr] 47:( 23:[0p] 5:s 6:D 5:f 4:( 47:6 47:[0Wr] 47:q 71:[0f] 23:[epj] 23:[tsl] 23:[YDZ]
335:[ufx] 23:[ydz] 23:[tsl] 23:[rak] 23:[30u] 23:[29y] 23:[18t] 23:[7r] 23:[6e] 23:[8t] 23:[eu] 23:[6p] 23:[%WO] 23:7 23:[Wu] 23:[7O] 23:[5wo] 5:w 5:o 5:w 5:[7o] 5:w 5:o
5:w 5:[wu] 23:[5o] 23:[$QI] 23:7 23:[9y] 47:[4u] 5:0 5:u 5:0 5:[6u] 5:0 5:u 5:0 5:[8t] 23:[3u] 23:[@(Y] 23:$ 23:[7r] 23:$ 23:[@r] 5:7 5:r 5:7 5:[$r] 5:7 5:r 5:7 5:[7r]
35:t 5:y 5:[30u] 23:[7y] 23:[Wt] 23:[0r] 23:[6e] 23:[8t] 23:[0eu] 23:[6p] 23:[%WO] 5:W 5:O 5:W 5:[7O] 5:W 5:O 5:W 5:[0Wu] 23:[7O] 23:[5wo] 23:7 23:[0wu] 23:[5o] 23:[$QI]
5:Q 5:I 5:Q 5:[7I] 5:Q 5:I 5:Q 5:[9Qy] 35:y 5:u 5:[4qi] 23:[8u] 23:y 23:[4t] 23:[30r] 23:7 23:[0Wru] 47:[6ep] 71:p 5:s 5:f 5:H 5:[6j] 95:[6h] 23:0 23:( 23:[0H] 23:[qj]
23:0 23:( 23:0 23:q 23:0 23:( 23:0 11:g 5:j 5:[4x] 23:0 23:[3Z] 23:0 11:l 11:[6k] 23:[0j] 23:[(H] 23:[0k] 23:[qj] 23:[0g] 23:[(f] 23:0 11:D 5:f 5:[6g] 23:[0f] 23:[(d]
23:[0s] 23:[4a] 23:0 23:7 23:d 11:f 11:[4g] 23:[8qef] 23:[68qd] 23:[468s] 23:[3%0a] 71:p 11:a 11:[8s] 23:[qeta] 23:[8qep] 23:[68qi] 11:Y 11:[70Wu] 71:Y 23:[79qry] 23:i
23:p 23:a 23:d 23:g 23:[4j] 23:l 11:J 11:[3k] 23:[%70] 23:[%70] 23:[%70] 23:[68ql] 95:[^P] 23:[qS] 23:[*Eg] 23:[qJ] 23:[6j] 23:q 23:[8eg] 23:[qj] 23:[%H] 5:O 5:H 5:O
5:[(H] 5:O 5:H 5:O 5:[8Wg] 23:[(H] 23:[5h] 23:8 23:[80wD] 47:[SgG] 23:[gGJ] 23:[SgG] 23:[Sg] 23:[sfh] 47:[sfl] 47:[4qgc] 23:[$Q] 23:[4q] 23:[@(] 23:[!ig] 11:* 11:1 11:8
11:^ 11:^ 11:6 11:6 11:[^PJ] 11:^ 11:[*qESL] 23:[qETgc] 23:[^JB] 11:^ 11:[6L] 11:6 11:[8qe] 23:[qeTjb] 23:[6GC] 11:6 11:[%L] 11:% 11:[8(W] 23:[(WtHV] 23:[Wgc] 11:%
11:[57whv] 23:5 11:5 5:[gc] 5:[4DZ] 11:4 11:@ 11:[@D] 5:g 5:[@G] 23:[$^(g] 23:D 23:[$^(S] 23:[68qs] 47:8 11:q 11:e 11:t 11:[@G] 23:[QEYg] 23:D 23:[QEYS] 23:[etis] 83:P
5:s 5:[$QG] 23:[4qg] 23:[@(D] 23:[!*S] 23:[18s] 47:[4i] 35:o 5:p 5:[^P] 95:[EPJ] 95:[^P] 95:[EPJ] 95:[^P]
]=]
local TRAILING_RESTS = 22

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
    Id="any-last-words-hu-tao",
    Name="Any Last Words? — Hu Tao Theme",
    Artist="HOYO-MiX",
    BPM=120,
    StepsPerBeat=48,
    Complete=true,
    DurationSeconds=82.240,
    OriginalDurationSeconds=82.237,
    TempoEvents=1,
    TimeSignatures={"4/4"},
    Source="User-supplied MIDI",
    SourceFile="any-last-words-hu-taos-theme-genshin-impact.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Game OST","Genshin Impact","Hu Tao","Piano","Dramatic","Complete"},
    Notes=table.concat(sheet, " "),
}
