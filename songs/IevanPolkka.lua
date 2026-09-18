-- Velora 0.10.33 Nova — replacement Ievan Polkka arrangement converted from a MIDI supplied by the repository owner.
-- Source file: ievan-polka.mid
-- MIDI: 480 PPQ, 119 BPM, 4/4, key signature A major.
-- 3 piano tracks retained; simultaneous duplicate pitches are merged.
-- All 2,214 source note-ons fit Velora's C2-C7 keyboard range; no octave folding was required.
-- The source lands exactly on a 1/10-beat timing grid, so StepsPerBeat=10 preserves every note-on position without quantization.
-- 2,214 source note-ons became 2,110 mapped notes after same-step duplicate merging.

local DATA = [=[
0:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT]
4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:$ 4:[QeT] 4:! 4:[3QeT] 4:$ 4:[QeT] 4:! 4:[QeT] 4:[$QeT] 17:[QI] 1:[$*T] 4:[QeTI]
4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 2:[ep] 1:[QeTI] 2:[QI] 1:[!QI] 4:[3QeTI] 2:[ep] 1:[!WO] 4:[0WTu] 4:[30u] 4:[!0WTO] 4:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:! 2:[QI] 1:[3QeTI] 2:[ep] 1:[!TS]
2:[TS] 1:[0WTS] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:! 2:[0u] 1:[30WTu] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep]
4:[QeTI] 2:[QI] 1:! 4:[3QeT] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:[!0u] 2:[0u] 1:[30WTO] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$QeTp] 4:[QI] 2:[QI] 9:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT]
2:[WO] 1:[$ep] 2:[ep] 1:[QeTI] 2:[QI] 1:[!QI] 4:[3QeTI] 2:[ep] 1:[!WO] 4:[0WTu] 4:[30u] 4:[!0WTO] 4:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:! 2:[QI] 1:[3QeTI] 2:[ep] 1:[!TS] 2:[TS] 1:[0WTS]
2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:! 2:[0u] 1:[30WTu] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI]
1:! 4:[3QeT] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:[!0u] 2:[0u] 1:[30WTO] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$QeTp] 4:[QI] 2:[QI] 9:[QI] 1:[QT] 4:I 4:[*I] 4:0 2:O 1:[Qp]
2:p 1:I 2:I 1:[*I] 4:[0I] 2:p 1:[*O] 4:u 4:[0u] 4:[*O] 4:[Qp] 2:p 1:I 4:[*I] 4:[0I] 2:I 1:[QT] 4:I 4:[*I] 4:0 2:O 1:[Qp] 4:I 2:I 1:* 2:I 1:[0I] 2:p 1:[*S] 2:S 1:S 2:a
1:[0p] 2:p 1:[*O] 2:O 1:[Qp] 4:I 2:I 1:[*I] 4:[0I] 2:p 1:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QO] 4:[eTu] 2:u 1:[*u] 4:[0eT] 2:O 1:[*a] 2:a 1:[WTa] 2:a 1:[0p] 2:p 1:[*WTO] 2:O 1:[Qp] 4:[eTI] 2:I 1:[*I]
4:[0eT] 2:p 1:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QO] 4:[eTu] 2:u 1:[*u] 4:[0eT] 2:O 1:[*a] 2:a 1:[WTa] 2:a 1:[0p] 2:p 1:[*WTO] 2:O 1:[QeTp] 4:[QI] 2:[QI] 1:[QeT] 7:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 2:[ep]
1:[QeTI] 2:[QI] 1:[!QI] 4:[3QeTI] 2:[ep] 1:[!WO] 4:[0WTu] 4:[30u] 4:[!0WTO] 4:[$ep] 2:[ep] 1:[QeTI] 4:[!QI] 4:[3QeTI] 2:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:! 2:[QI] 1:[3QeTI] 2:[ep] 1:[!TS] 2:[TS] 1:[0WTS] 2:[ra] 1:[3ep]
2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:[!QI] 4:[3QeTI] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:[!0u] 4:[30WT] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:[!QI] 4:[3QeT]
2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:[!0u] 4:[30WT] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 4:[!0WTO] 4:[$QeTI] 17:[QI] 1:[QT] 4:[eTI] 4:[*I] 4:[0eT] 2:O 1:[Qp] 2:p 1:[eTI] 2:I 1:[*I] 4:[0eTI] 2:p 1:[*O]
4:[WTu] 4:[0u] 4:[WTO] 4:p 2:p 1:[eTI] 4:I 4:[eTI] 2:I 1:T 4:[eTI] 4:I 4:[eT] 2:O 1:p 4:[eTI] 2:I 1:* 2:I 1:[0eTI] 2:p 1:[*S] 2:S 1:[WTS] 2:a 1:[0p] 2:p 1:[*WTO] 2:O 1:p 4:[eTI] 4:[*I] 4:[0eTI]
2:p 1:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QO] 4:[WTu] 2:u 1:* 2:u 1:[0WTu] 2:O 1:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QO] 4:[WTu] 2:u 1:* 2:u 1:[0WTu] 2:O 1:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QS] 4:[eTS] 4:[*a] 4:[0eTp] 4:[QS]
4:[eTS] 4:[QS] 4:[eTS] 4:[QTS] 4:[eTS] 4:[TS] 2:[TS] 1:[TS] 2:[QI] 1:[$*T] 4:[QeTI] 4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 2:[ep] 1:[QeTI] 2:[QI] 1:[!QI] 4:[3QeTI] 2:[ep] 1:[!WO] 4:[0WTu] 4:[30u] 4:[!0WTO] 4:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[QI] 1:[$*T] 4:[QeTI]
4:[!QI] 4:[3QeT] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:! 2:[QI] 1:[3QeTI] 2:[ep] 1:[!TS] 2:[TS] 1:[0WTS] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 4:[!QI] 4:[3QeTI] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:! 2:[0u]
1:[30WTu] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep] 2:[ep] 1:[!0WTO] 2:[WO] 1:[$ep] 4:[QeTI] 2:[QI] 1:! 4:[3QeT] 2:[ep] 1:[$TS] 4:[QeTS] 4:[!ra] 4:[3QeTp] 4:[$WO] 4:[0WTu] 2:[0u] 1:[!0u] 2:[0u] 1:[30WTO] 2:[WO] 1:[!ra] 2:[ra] 1:[0WrTa] 2:[ra] 1:[3ep]
2:[ep] 1:[!0WTO] 2:[WO] 1:[$QeTp] 4:[QI] 2:[QI] 9:[IG] 1:[$TS] 4:[QeTIG] 4:[!IG] 4:[3QeT] 2:[OH] 1:[$pj] 2:[pj] 1:[QeTIG] 2:[IG] 1:[!IG] 4:[3QeTIG] 2:[pj] 1:[!OH] 4:[0WTuf] 4:[3uf] 4:[!0WTOH] 4:[$pj] 4:[QeTIG] 4:[!IG] 4:[3QeTIG] 2:[IG] 1:[$TS] 4:[QeTIG] 4:[!IG] 4:[3QeT]
2:[OH] 1:[$pj] 4:[QeTIG] 2:[IG] 1:! 2:[IG] 1:[3QeTIG] 2:[pj] 1:[!SL] 2:[SL] 1:[0WTSL] 2:[ak] 1:[3pj] 2:[pj] 1:[!0WTOH] 2:[OH] 1:[$pj] 4:[QeTIG] 4:[!IG] 4:[3QeTIG] 2:[pj] 1:[$SL] 4:[QeTSL] 4:[!ak] 4:[3QeTpj] 4:[$OH] 4:[0WTuf] 2:[uf] 1:! 2:[uf] 1:[30WTuf] 2:[OH]
1:[!ak] 2:[ak] 1:[0WTak] 2:[ak] 1:[3pj] 2:[pj] 1:[!0WTOH] 2:[OH] 1:[$pj] 4:[QeTIG] 2:[IG] 1:! 4:[3QeT] 2:[pj] 1:[$SL] 4:[QeTSL] 4:[!ak] 4:[3QeTpj] 4:[$OH] 4:[0WTuf] 2:[uf] 1:[!uf] 2:[uf] 1:[30WTOH] 2:[OH] 1:[!ak] 2:[ak] 1:[0WTak] 2:[ak] 1:[3pj] 2:[pj] 1:[!0WTOH]
2:[OH] 1:[$QeTpj] 4:[IG] 2:[IG] 9:[IG] 1:T 4:[eTI] 4:I 4:[eT] 2:O 1:p 2:p 1:[eTI] 2:I 1:I 4:[eTI] 2:p 1:O 4:[WTu] 4:u 4:[WTO] 4:p 2:p 1:[eTI] 4:I 4:[eTI] 2:I 1:T 4:[eTI] 4:I 4:[eT] 2:O
1:p 4:[eTI] 2:I 4:I 1:[eTI] 2:p 1:S 2:S 1:[WTS] 2:a 1:p 2:p 1:[WTO] 2:O 1:p 4:[eTI] 2:I 1:I 4:[eTI] 2:p 1:S 4:[eTS] 4:a 4:[eTp] 4:O 4:[WTu] 2:u 1:u 4:[WT] 2:O 1:a 2:a
1:[WTa] 2:a 1:p 2:p 1:[WTO] 2:O 1:p 4:[eTI] 2:I 1:I 4:[eT] 2:p 1:S 4:[eTS] 4:a 4:[eTp] 4:O 4:[WTu] 2:u 1:u 4:[WT] 2:O 1:a 2:a 1:[WTa] 2:a 1:p 2:p 1:[WTO] 2:O 1:[eTp] 4:I
2:I
]=]
local TRAILING_RESTS = 9

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
    Id="ievan-polkka",
    Name="Ievan Polkka",
    Artist="Traditional Finnish",
    BPM=119,
    StepsPerBeat=10,
    Complete=true,
    DurationSeconds=145.084,
    OriginalDurationSeconds=145.084,
    TempoEvents=1,
    TimeSignatures={"4/4"},
    Key="A major",
    Source="User-supplied MIDI file",
    SourceFile="ievan-polka.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","TikTok","Folk","Polka","Upbeat","Piano","Complete"},
    Notes=table.concat(sheet, " "),
}
