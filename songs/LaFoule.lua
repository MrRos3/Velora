-- Velora 0.10.20 Nova — piano arrangement converted from a MIDI supplied by the repository owner.
-- Supplied file: Edith_Piaf_La_Foule.mid
-- Supplied file SHA-256: C6D48A49CE9E1EBC297B6A1AE7E60864B31AD39B625115D6DDB2B82763B4A995
-- MIDI: 384 PPQ with source tempo changes and 3/4 time after the intro.
-- Retained the source melody, acoustic-bass, and piano tracks (1,169 note-ons total).
-- Timing is normalized to real seconds at 170 BPM / 48 steps per beat, preserving the MIDI's accelerando.
-- Only notes outside Velora's C2-C7 keyboard range were folded by one octave.

local DATA = [=[
320:[7a] 46:8 0:s 47:[*S] 43:[9d] 43:[(D] 40:0 0:[6fjx] 20:[fjx] 19:e 0:t 19:G 0:B 19:[0eGC] 0:t 33:6 4:[fx] 0:j 18:f 0:[jx] 18:[0e] 0:t 19:[GC] 18:[GC] 0:[0et] 36:3 0:[fkx] 19:x
0:[fk] 18:r 0:[0w] 18:[GC] 19:[0wrGC] 36:5 1:[fk] 0:x 18:[fx] 0:k 18:[wr] 0:0 17:C 0:G 18:[0rGC] 0:w 38:[DZ] 2:$ 16:Z 0:D 18:[(er] 18:C 0:G 18:[(erG] 0:C 38:[DZ] 2:7 16:[DZ]
19:[(er] 19:[GC] 18:[(erC] 0:G 37:[wr] 0:[30fx] 38:r 0:[0w] 37:W 0:q 0:t 38:[QeT] 38:[wEy] 39:[WrY] 38:[eu] 0:[6t] 38:e 0:t 37:e 0:[tu] 33:6 5:6 37:u 0:[et] 39:[etu] 37:3 0:3 38:w
0:[ru] 38:r 0:[wu] 36:5 2:5 37:[wru] 39:[ru] 0:w 38:@ 2:$ 35:r 0:[eY] 37:Y 0:[er] 38:7 2:7 37:[erY] 37:[er] 0:Y 38:[0wr] 0:[3u] 39:7 36:5 1:5 37:3 0:[3wr] 0:u 53:a
39:a 11:a 13:0 1:f 63:D 12:f 14:G 17:h 5:7 39:G 30:f 14:D 14:f 14:6 30:s 88:6 39:3 38:@ 7:G 16:h 15:2 5:j 45:h 26:h 14:G 14:j 7:2 24:d
33:d 18:d 21:d 21:7 176:a 37:a 16:D 3:7 53:D 26:D 11:f 17:G 6:7 45:G 34:f 12:D 19:G 6:3 47:f 159:s 27:s 1:1 42:s 39:s 22:f 9:$ 57:f 20:G
18:f 19:7 23:D 97:7 43:a 50:a 21:f 1:0 50:f 34:f 18:G 13:7 8:h 41:G 26:f 19:D 19:6 5:f 51:s 107:G 36:h 24:j 13:2 42:h 37:h 18:G 19:j 1:2
46:d 51:d 18:5 0:d 37:d 83:5 55:a 34:a 24:D 0:7 53:D 34:D 17:f 13:7 7:G 42:G 36:f 19:D 9:3 28:G 44:f 131:f 18:f 16:8 3:s 42:s 35:d 21:s
22:a 0:7 52:a 32:D 37:D 64:3 3:f 351:d 40:f 80:d 44:S 26:d 41:6 0:G 88:f 31:f 26:d 20:2 6:G 68:f 35:f 26:d 28:5 3:h 59:f 29:f 27:d 20:2
4:h 39:f 38:f 22:d 27:6 13:G 40:f 31:f 25:d 18:2 1:G 28:f 27:f 50:s 19:5 33:a 11:9 40:8 43:7 41:6 6:a 19:a 17:7 0:a 30:D 22:$ 51:D 34:D
18:f 20:G 0:7 37:G 27:f 19:D 22:G 26:3 34:f 148:f 16:f 18:f 17:f 18:f 5:8 54:f 19:f 16:f 21:f 19:f 1:$ 42:h 59:h 27:7 36:G 100:7 34:d 26:f
53:d 49:S 43:d 42:6 0:G 90:f 27:d 20:2 11:G 49:f 42:d 34:h 0:5 53:f 38:f 20:d 21:2 4:h 32:f 29:f 19:d 27:G 8:6 48:f 38:f 27:d 16:2 9:G
26:f 23:f 25:s 42:5 22:a 109:5 23:a 17:s 19:a 21:P 21:a 23:D 3:$ 44:h 32:D 25:f 24:7 3:G 39:G 36:f 21:D 26:G 3:3 59:f 71:0 19:f 18:f 19:f
21:f 2:9 20:f 23:f 3:8 22:f 20:f 23:f 25:f 26:f 16:7 11:D 55:h 6:7 75:G 59:[60fjx] 0:f 20:[fx] 0:j 21:[et] 21:C 0:G 20:[0eG] 0:[tC] 37:6 5:[fx] 22:[fx] 21:[0et]
21:[GC] 21:[0etGC] 41:3 0:f 0:x 20:x 0:f 20:[0wr] 20:C 0:G 20:[wr] 0:[0GC] 40:5 1:[fx] 20:x 0:f 20:0 0:[wr] 20:C 0:G 19:[wr] 0:[0GC] 43:[DZ] 2:$ 18:[DZ] 21:[(er] 20:C 0:G
20:[(erGC] 42:Z 0:D 0:7 19:[DZ] 20:( 0:[er] 20:[GC] 21:[(erG] 0:C 41:[30wx] 0:[rf] 42:[0wr] 43:[qWt] 41:T 0:[Qe] 42:[wE] 0:y 41:[Wr] 0:Y 41:6 0:[6t] 0:[eu] 41:[et] 41:e 0:[tu] 34:6 6:6
42:[eu] 0:t 40:[et] 0:u 39:3 2:3 41:[wru] 41:u 0:[wr] 38:5 2:5 42:[wu] 0:Y 40:u 0:r 0:w 40:@ 2:$ 39:[rY] 0:e 40:e 0:[rY] 42:7 1:7 39:[er] 0:Y 41:e 0:[rY]
40:[3u] 0:[0wr] 42:7 42:5 38:3 3:[wru] 0:3 46:a 54:a 23:f 0:0 55:f 36:f 19:G 13:7 10:h 43:G 28:f 21:D 19:6 6:f 55:s 114:G 39:h 26:j 12:2 47:h 39:h
19:G 20:j 1:2 50:d 54:d 19:5 1:d 39:d 88:5 60:a 37:a 25:[7D] 57:D 38:D 17:f 13:7 9:G 45:G 39:f 20:D 8:3 31:G 48:f 140:f 19:f 16:8 4:s 44:s
35:d 17:s 19:[7a] 42:a 25:D 29:D 56:3 5:f 350:d 40:f 81:d 43:S 26:d 39:6 2:G 87:f 31:f 26:d 19:2 7:G 69:f 34:f 26:d 27:5 4:h 59:f 29:f 27:d
19:2 5:h 39:f 38:f 22:d 26:6 14:G 40:f 31:f 25:d 17:2 2:G 28:f 27:f 50:s 19:5 33:a 10:9 40:8 43:7 41:6 7:a 19:a 16:5 2:a 29:D 21:$ 52:D
34:D 18:f 21:[7G] 37:G 28:f 18:D 22:G 25:3 35:f 148:f 16:f 18:f 17:f 18:f 4:8 55:f 19:f 17:f 20:f 19:f 0:$ 43:h 60:h 25:7 40:G 131:7 25:d 18:f
41:d 42:S 36:d 33:6 1:G 110:f 33:d 23:2 15:G 58:f 51:d 41:[5h] 58:f 43:f 21:d 22:2 4:h 34:f 29:f 19:d 27:G 7:6 50:f 38:f 27:d 15:2 10:G 27:f
24:f 24:s 42:5 23:a 110:5 24:a 17:s 19:a 21:P 22:a 23:D 2:$ 45:D 33:D 25:f 23:7 4:G 40:G 36:f 22:D 26:G 2:3 61:f 70:0 21:f 18:f 18:f 22:f
1:9 21:f 24:f 3:8 31:f 26:f 28:f 31:f 37:f 20:7 17:D 62:h 5:7 85:G 65:6 1:[0fx] 22:[fx] 23:[et] 22:C 0:G 20:[0eG] 0:[tC] 34:6 7:[fx] 22:[fx] 20:[0t] 0:e 20:C
0:G 20:[0etGC] 40:3 1:f 0:x 21:[fx] 21:[0wr] 20:C 0:G 20:w 0:[0rGC] 38:5 3:[fx] 21:x 0:f 20:0 0:[wr] 20:C 0:G 20:[0wr] 0:[GC] 42:[DZ] 1:$ 19:[DZ] 21:[(er] 21:[GC] 21:[(erGC] 43:[DZ]
0:7 20:[DZ] 20:( 0:[er] 20:[GC] 21:[erG] 0:[(C] 41:3 0:[0wx] 0:[rf] 42:[0w] 0:r 42:t 0:[qW] 41:T 0:[Qe] 43:[wE] 0:y 42:[WrY] 41:6 0:t 0:[6eu] 42:[et] 42:[et] 0:u 33:6 7:6 42:[eu]
0:t 41:[et] 0:u 38:3 3:3 42:[wru] 41:u 0:[wr] 38:5 3:5 42:[wu] 0:r 41:u 0:[wY] 41:@ 1:$ 41:[rY] 0:e 40:e 0:[rY] 42:7 0:7 41:[er] 0:Y 41:e 0:Y 42:[30] 38:0
3:[7r] 34:9 7:t 0:8 33:8 8:[7r] 20:[8t] 9:7 11:[*T] 19:[9y] 7:^ 13:Y 0:( 20:[0u] 19:6 1:[6etu] 41:[et] 40:t 0:[eu] 33:6 7:6 41:[et] 0:u 40:[et] 0:u 37:3 3:3 40:[ru]
0:w 40:[wru] 37:5 3:5 41:r 0:[wu] 40:[wu] 0:Y 41:@ 0:$ 39:[rY] 0:e 40:[rY] 0:e 41:7 0:7 39:[rY] 0:e 41:[erY] 41:[0wf] 0:[rx] 36:0 2:w 0:[0r] 33:9 7:[qWt] 33:8 7:[QeT]
30:7 10:[wE] 0:y 26:^ 13:[WrY] 40:6 0:[6etu] 39:[et] 38:u 0:[et] 31:6 6:6 38:e 0:[tu] 38:[et] 0:u 35:3 2:3 38:u 0:[wr] 38:r 0:[wu] 34:5 2:5 39:[wr] 0:u 37:w 0:r
0:u 37:@ 1:$ 37:[rY] 0:e 37:[eY] 0:r 39:7 38:[er] 0:Y 37:Y 0:[er] 37:3 0:[0wru] 39:7 37:5 0:5 36:3 2:[3wru]
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
    Id="la-foule-edith-piaf",
    Name="La Foule",
    Artist="Édith Piaf",
    BPM=170,
    StepsPerBeat=48,
    Complete=true,
    Source="User-supplied MIDI",
    SourceLicense="User-provided source file; melody, bass, and piano tracks converted for Velora.",
    Categories={"Famous","French","Chanson","Waltz","Édith Piaf","Piano","Dramatic","Complete"},
    Notes=table.concat(sheet, " "),
}
