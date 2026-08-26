-- Velora 0.10.20 Nova — complete arrangement converted from a MIDI supplied by the repository owner.
-- Supplied file: Lana Del Rey — Once Upon a Dream [MIDIfind.com].mid
-- Supplied file SHA-256: 9282028E0E007536F208B19039FCAA4181329BE544BAD3475301E275A2A0AC71
-- MIDI: 480 PPQ, 1 source tempo event, source time signatures: 3/4.
-- Timing normalized to real seconds at 123 BPM / 48 Velora steps per beat.
-- All three non-drum instrument tracks retained; simultaneous duplicate pitches are merged.
-- 178 out-of-range note-on events were folded by octave into Velora's C2-C7 keyboard range.

local DATA = [=[
0:[48q] 143:4 143:[48q] 143:4 143:[48qt] 143:4 143:[48qt] 143:4 143:[48qeti] 143:[60etu] 143:[48qeti] 95:y 47:[60etu] 47:i 47:y 47:[180wtu] 95:o 47:[7QryYp] 95:I 47:[180wtu] 143:[48qe] 143:[180wtuos] 143:[7Qryuoa] 143:[^qEyuP] 95:o 47:[^0EP] 47:[ep] 47:[wo]
47:[48qetipd] 95:s 47:[4tiP] 95:p 47:[180wtup] 47:o 47:I 47:o 47:y 47:u 47:[48qeti] 143:[60etu] 143:[48qeti] 95:y 47:[60etu] 47:i 47:y 47:[180wtu] 95:o 47:[7QryYp] 95:I 47:[180wtuo] 143:1 47:a 47:d 47:[48qetips] 95:i 47:[29eyId]
95:s 47:[59wEyod] 47:P 47:o 47:[30ruOf] 95:d 47:[48qetpsg] 47:f 47:d 47:[60etups] 95:s 47:[@^(EoPD] 47:d 47:s 47:[^qEyiP] 95:d 47:[48qeti] 143:[60etu] 143:[48qeti] 143:4 143:[48qet] 47:[8tis] 47:[6p] 47:[60et] 47:[8tis] 47:[6p] 47:[48qet] 47:[8tis]
47:[6p] 47:[60etupf] 47:6 47:[6g] 47:[48qet] 47:[8tis] 47:[6p] 47:[60et] 47:[8tis] 47:[6p] 47:[48qet] 47:[8tis] 47:[6p] 47:[60etupf] 47:6 47:[6g] 47:[48qeto] 47:4 47:[4y] 47:[29eyI] 47:2 47:[2y] 47:[59wEyoP] 47:5 47:5 47:[30Wryu] 47:[3d] 47:[3f]
47:[48qetips] 47:4 47:[4i] 47:[29eyId] 47:2 47:[2s] 47:[59wEyod] 47:[5P] 47:[5o] 47:[30ruOf] 47:3 47:[3d] 47:[48qetpsg] 47:[4f] 47:[4d] 47:[60etups] 47:6 47:[6s] 47:[@^(EoPD] 47:[@d] 47:[@s] 47:[^qEyiP] 47:^ 47:[^d] 47:[48qeti] 47:4 47:4 47:[60etu]
47:6 47:6 47:[48qeti] 143:[48qet] 143:[60et] 143:[48qet] 143:[60et] 143:[48qeti] 47:4 47:4 47:[60etu] 47:6 47:6 47:[48qeti] 47:4 47:[4y] 47:[60etu] 47:[6i] 47:[6y] 47:[180wtu] 47:1 47:[1o] 47:[7QryYp] 47:7 47:[7I] 47:[180wtu] 47:1 47:1
47:[1458] 47:4 47:4 47:[180wtuos] 47:1 47:1 47:[7Qryuoa] 47:7 47:7 47:[^qEyuP] 47:^ 47:[^o] 47:[^0EP] 47:[^ep] 47:[^wo] 47:[48qetd] 47:4 47:[4s] 47:[48qP] 47:4 47:[4p] 47:[180wetp] 47:[1o] 47:[1I] 47:[5o] 47:y 47:u 47:[48qeti]
47:4 47:4 47:[60etu] 47:6 47:6 47:[48qeti] 47:4 47:[4y] 47:[60etu] 47:[6i] 47:[6y] 47:[180wtu] 47:1 47:[1o] 47:[7QryYp] 47:7 47:[7I] 47:[180wtuo] 47:1 47:1 47:1 47:[1a] 47:[1d] 47:[48qetips] 47:4 47:[4i] 47:[29eyId] 47:2
47:[2s] 47:[59wEyod] 47:[5P] 47:[5o] 47:[30ruOf] 47:3 47:[3d] 47:[48qetpsg] 47:[4f] 47:[4d] 47:[60etups] 47:6 47:[6s] 47:[@^(EoPD] 47:[@d] 47:[@s] 47:[^qEyiP] 47:^ 47:[^d] 47:[48qeti] 47:4 47:4 47:[60etu] 47:6 47:6 47:[48qeti] 47:4 47:4
47:4 47:4 47:4 47:[48qet] 47:[8qt] 47:e 47:[60et] 47:[8qt] 47:e 47:[48qet] 47:[8qt] 47:e 47:[680etu] 95:i 47:[48qet] 47:[8qt] 47:e 47:[60et] 47:[8qt] 47:e 47:[48qet] 47:[8qt] 47:e 47:[680etu] 95:i 47:[48qeti] 143:[48qet]
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
    Id="once-upon-a-dream-lana-del-rey",
    Name="Once Upon a Dream",
    Artist="Lana Del Rey",
    BPM=123,
    StepsPerBeat=48,
    Complete=true,
    Source="User-supplied MIDI",
    SourceLicense="User-provided source file; arrangement converted for Velora.",
    Categories={"Famous","Lana Del Rey","Soundtrack","Pop","Piano","Dark","Dreamy","Complete"},
    Notes=table.concat(sheet, " "),
}
