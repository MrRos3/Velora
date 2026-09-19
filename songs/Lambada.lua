-- Velora 0.10.34 Nova — complete arrangement converted from a MIDI supplied by the repository owner.
-- Source file: lambada.mid
-- MIDI: 480 PPQ, 1 source tempo event(s), source time signature(s): 4/4.
-- 3 non-drum musical track(s) retained; simultaneous duplicate pitches are merged.
-- All source notes fit Velora's C2-C7 keyboard range; no octave folding was required.
-- 1,429 source note-ons became 1,423 mapped notes after same-step duplicate merging.

local DATA = [=[
0:9 7:[pdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:[qp] 7:e 7:[9j] 11:9 3:q 7:[eh] 7:[9g] 7:f 3:9 3:[qd]
7:e 7:[^d] 7:g 3:^ 3:[9f] 7:[qd] 7:[8s] 7:d 3:8 3:[0p] 7:[wo] 7:[4tip] 11:4 3:6 7:8 7:4 11:4 3:[6p] 7:8 7:[9j] 11:9 3:q 7:[eh] 7:[9g] 7:f 3:9 3:[qd] 7:e
7:[^d] 7:g 3:^ 3:[9f] 7:[qd] 7:[8s] 7:d 3:8 3:[0p] 7:[wo] 7:[4tip] 11:4 3:6 7:8 7:4 11:4 3:6 7:8 7:[5h] 11:5 3:[^h] 7:[9g] 7:[5P] 11:5 3:[^P] 7:[9d] 7:[5j] 11:5
3:[^h] 7:[9g] 7:[5P] 11:5 3:[^d] 7:[9g] 7:[8f] 7:f 3:[8d] 3:[0s] 7:[ws] 7:8 7:s 3:8 3:[0d] 7:[ws] 7:[9ipd] 11:9 3:q 7:e 7:9 11:9 3:q 7:e 7:[5h] 7:h 3:5 3:[^h]
7:[9g] 7:[5P] 11:5 3:[^P] 7:[9d] 7:[5j] 11:5 3:[^h] 7:[9g] 7:[5P] 11:5 3:[^d] 7:[9g] 7:[8f] 7:f 3:[8d] 3:[0s] 7:w 7:8 7:s 3:8 3:[0d] 7:[ws] 7:[9g] 3:f 3:d 3:9 3:[qip]
7:e 7:9 11:9 3:q 7:e 7:[9p] 7:[pdg] 3:9 3:q 7:[eopdg] 7:[9i] 7:[updg] 3:9 3:[qy] 7:[epdg] 7:[^y] 7:[iPdg] 3:^ 3:[9u] 7:[qyPdg] 7:[8t] 7:[yosf] 3:8 3:[0e] 7:[wosf] 7:[4etip] 11:4 3:6
7:[8ip] 3:[oP] 3:[4ps] 3:[ps] 7:[4oP] 3:[6eP] 3:[ip] 3:[8ps] 7:[9p] 7:[pdg] 3:9 3:q 7:[eopdg] 7:[9i] 7:[updg] 3:9 3:[qy] 7:[epdg] 7:[^y] 7:[iPdg] 3:^ 3:[9u] 7:[qyPdg] 7:[8t] 7:[yosf] 3:8 3:[0e] 7:[wosf]
7:[4etip] 7:[ip] 3:[4oP] 3:[6ps] 7:8 3:[ip] 3:[4p] 3:[oP] 3:[ps] 3:4 3:[6s] 7:8 7:[5o] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^E] 7:[9yoPd] 7:[5p] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E]
7:[oPd] 3:5 3:[^y] 7:[9ioPd] 7:[8u] 7:[uosf] 3:[8y] 3:[0t] 7:[wtosf] 7:8 7:[tosf] 3:8 3:[0y] 7:[wtosf] 7:[9y] 7:[pdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg] 7:[5o] 7:[oPd] 3:5 3:[^o]
7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^E] 7:[9yoPd] 7:[5p] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^y] 7:[9ioPd] 7:[8u] 7:[uosf] 3:[8y] 3:[0t] 7:[wosf] 7:8 7:[tosf] 3:8 3:[0y] 7:[wtosf] 7:[9i] 3:u
3:[ypdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg] 7:[9p] 7:[pdg] 3:9 3:q 7:[eopdg] 7:[9i] 7:[updg] 3:9 3:[qy] 7:[epdg] 7:[^y] 7:[iPdg] 3:^ 3:[9u] 7:[qyPdg] 7:[8t] 7:[yosf] 3:8 3:[0e]
7:[wosf] 7:[4etip] 11:4 3:6 7:[8ip] 3:[oP] 3:[4ps] 3:[ps] 7:[4oP] 3:[6eP] 3:[ip] 3:[8ps] 7:[9p] 7:[pdg] 3:9 3:q 7:[eopdg] 7:[9i] 7:[updg] 3:9 3:[qy] 7:[epdg] 7:[^y] 7:[iPdg] 3:^ 3:[9u] 7:[qyPdg] 7:[8t]
7:[yosf] 3:8 3:[0e] 7:[wosf] 7:[4etip] 7:[ip] 3:[4oP] 3:[6ps] 7:8 3:[ip] 3:[4p] 3:[oP] 3:[ps] 3:4 3:[6s] 7:8 7:[5o] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^E] 7:[9yoPd] 7:[5p] 7:[oPd]
3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^y] 7:[9ioPd] 7:[8u] 7:[uosf] 3:[8y] 3:[0t] 7:[wtosf] 7:8 7:[tosf] 3:8 3:[0y] 7:[wtosf] 7:[9y] 7:[pdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg]
7:[5o] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^E] 7:[9yoPd] 7:[5p] 7:[oPd] 3:5 3:[^o] 7:[9ioPd] 7:[5E] 7:[oPd] 3:5 3:[^y] 7:[9ioPd] 7:[8u] 7:[uosf] 3:[8y] 3:[0t] 7:[wosf] 7:8 7:[tosf] 3:8
3:[0y] 7:[wtosf] 7:[9i] 3:u 3:[ypdg] 3:9 3:q 7:[epdg] 7:9 7:[pdg] 3:9 3:q 7:[epdg] 7:[9p] 3:[dg] 7:[qdg] 3:[dg] 7:e 7:[9p] 3:[dg] 7:[qdg] 3:[dg] 7:e 7:[4s] 3:[gj] 7:[6gj] 3:[gj] 7:8
7:[4s] 3:[gj] 7:[6gj] 3:[gj] 7:8 7:[9p] 3:[dg] 3:[dg] 3:[qdg] 3:[dg] 7:e 7:[9p] 3:[dg] 7:[qdg] 3:[dg] 7:e 7:[4s] 3:[gj] 3:[gj] 3:[6gj] 3:[gj] 7:8 7:[4s] 3:[gj] 7:[6gj] 3:[gj] 7:8 7:[5oh]
11:5 3:[^oh] 7:[9ig] 7:[5EP] 11:5 3:[^EP] 7:[9yd] 7:[5pj] 11:5 3:[^oh] 7:[9ig] 7:[5EP] 11:5 3:[^yd] 7:[9ig] 7:[8uf] 7:[uf] 3:[8yd] 3:[0ts] 7:[wts] 7:8 7:[ts] 3:8 3:[0yd] 7:[wts] 7:[9yipd] 11:9 3:q
7:e 7:9 11:9 3:q 7:e 7:[5oh] 11:5 3:[^oh] 7:[9ig] 7:[5EP] 11:5 3:[^EP] 7:[9yd] 7:[5pj] 11:5 3:[^oh] 7:[9ig] 7:[5EP] 11:5 3:[^yd] 7:[9ig] 7:[8uf] 7:[uf] 3:[8yd] 3:[0ts] 7:[wts] 7:8 7:[ts]
3:8 3:[0yd] 7:[wts] 7:[9yd] 11:9 3:q 7:e 7:9 11:9 3:q 7:e 7:[9ep] 3:[idg] 7:[qidg] 3:[idg] 7:e 7:[9ep] 3:[idg] 7:[qidg] 3:[idg] 7:e 7:[4ts] 3:[pgj] 7:[6pgj] 3:[pgj] 7:8 7:[4ts] 3:[pgj]
7:[6pgj] 3:[pgj] 7:8 7:[9ep] 3:[idg] 3:[idg] 3:[qidg] 3:[idg] 7:e 7:[9ep] 3:[idg] 7:[qidg] 3:[idg] 7:e 7:[4ts] 3:[pgj] 3:[pgj] 3:[6pgj] 3:[pgj] 7:8 7:[4ts] 3:[pgj] 7:[6pgj] 3:[pgj] 7:8 7:[9ep] 3:[idg] 7:[qidg]
3:[idg] 7:e 7:[9ep] 3:[idg] 7:[qidg] 3:[idg] 7:e 7:[4ts] 3:[pgj] 7:[6pgj] 3:[pgj] 7:8 7:[4ts] 3:[pgj] 7:[6pgj] 3:[pgj] 7:8 7:[9ep] 3:[idg] 3:[idg] 3:[qidg] 3:[idg] 7:e 7:[9ep] 3:[idg] 7:[qidg] 3:[idg] 7:e
7:[4ts] 3:[pgj] 3:[pgj] 3:[6pgj] 3:[pgj] 7:8 7:[4ts] 3:[pgj] 7:[6pgj] 3:[pgj] 7:8
]=]
local TRAILING_RESTS = 7

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
    Id="lambada-kaoma",
    Name="Lambada",
    Artist="Kaoma",
    BPM=120,
    StepsPerBeat=16,
    Complete=true,
    DurationSeconds=128.000,
    OriginalDurationSeconds=128.000,
    TempoEvents=1,
    TimeSignatures={"4/4"},
    Source="User-supplied MIDI file",
    SourceFile="lambada.mid",
    SourceLicense="User-provided source file; converted for Velora at the repository owner's request.",
    Categories={"Famous","Latin","Dance","Kaoma","Piano","Upbeat","Complete"},
    Notes=table.concat(sheet, " "),
}
