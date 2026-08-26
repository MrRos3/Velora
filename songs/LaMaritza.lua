-- Velora Upgrade Lab test song — complete arrangement converted from a MIDI supplied by the repository owner.
-- Supplied file: la-maritza-sylvie-vartan.mid
-- Supplied file SHA-256: A8D96EC463D1718A52FB9E59B058FC12A0B85B211016C47134CDB701F0816A9C
-- MIDI: 480 PPQ, time-normalized at 76 BPM / 48 Velora steps per beat.
-- Both piano tracks retained; simultaneous duplicate pitches are merged.
-- 3 out-of-range note-on events were folded by octave into Velora's C2-C7 keyboard range.

local DATA = [=[
24:p 11:P 5:s 5:P 23:p 23:[9j] 7:e 7:y 7:[ih] 7:p 7:d 7:g 15:f 15:d 15:S 15:d 15:f 15:g 15:h 15:j 15:[5wJ] 11:z 11:x 11:c 11:x 11:z 11:[6eL] 11:z 11:x 11:z 11:L 11:J 11:[29j] 11:z 11:g 11:j 11:d 11:g
11:p 11:d 11:[30u] 11:o 11:P 11:d 11:f 11:d 11:S 11:P 11:[6p] 95:[7y] 3:o 3:a 39:[!*u] 3:p 3:S 39:[2i] 3:p 3:d 15:9 23:[qeuo] 23:9 23:[eyip] 23:9 23:[qeuo] 23:9 23:2 23:9 23:[qeuo] 23:9 23:[eyip] 23:9
23:[qeuo] 23:9 23:[2p] 3:d 3:j 15:9 23:[qey] 23:[9h] 11:g 11:[qeyf] 23:[9d] 23:[qeyf] 23:[9g] 23:[2p] 23:9 23:[qey] 23:[9h] 11:g 11:[qeyf] 23:[9d] 23:[qeyf] 23:[9g] 23:[5J] 23:w 23:[Eyo] 23:[wj] 11:h
11:[Eyog] 23:[wf] 23:[Eyog] 23:[wh] 23:[1s] 23:8 23:[0wt] 23:[8h] 11:f 11:[0wtJ] 23:[8s] 23:[0wtf] 23:[8J] 23:[4j] 23:q 23:[eti] 23:q 23:[eti] 23:q 23:[eti] 23:[qo] 23:[6T] 3:u 3:p 15:* 23:0 23:w 23:T
95:[pSfh] 161:[9j] 23:e 23:y 23:[ih] 11:g 11:[pf] 23:d 23:f 23:g 23:[9p] 23:e 23:y 23:[ih] 11:g 11:[pf] 23:d 23:f 23:g 23:[5J] 23:9 23:w 23:[yj] 11:h 11:[og] 23:f 23:g 23:h 23:[1s] 23:5 23:8 23:[wh]
11:f 11:[tJ] 23:s 23:f 23:J 23:[4j] 23:8 23:q 23:t 23:i 23:t 23:[qi] 23:[8o] 23:[6T] 3:u 3:p 15:* 23:0 23:w 23:[Ty] 3:o 3:a 39:u 1:p 1:S 91:[9qd] 71:[0wf] 98:[9qg] 97:[5J] 21:[9wJ] 10:j 10:[5h]
21:[9wg] 20:[8f] 10:d 10:[0Ef] 21:8 10:s 9:[0Ed] 10:f 10:[8j] 21:[qej] 10:h 10:[8g] 20:[qef] 21:[^d] 10:s 10:[qEd] 20:^ 10:P 10:[qEs] 10:d 10:[5h] 21:[0wh] 9:g 10:[5f] 21:[0wd] 21:[6S] 10:a 9:[*wS]
21:6 10:p 10:[*wa] 10:S 10:[9f] 20:[eyd] 10:S 10:[9d] 10:f 10:[qyg] 20:9 21:[eyd] 21:[9f] 21:[eyg] 20:[5J] 21:[9wJ] 10:j 10:[5h] 20:[9wg] 21:[8f] 10:d 10:[0Ef] 21:8 9:s 10:[0Ed] 10:f 10:[8j] 21:[qej]
10:h 9:[8g] 21:[qef] 21:[^d] 10:s 10:[qEd] 20:^ 10:P 10:[qEs] 10:d 10:[5h] 20:[0wh] 10:g 10:[5f] 21:[0wd] 21:[6S] 9:a 10:[*wS] 21:6 10:p 10:[*wa] 10:S 9:[9ipf] 21:[eyipd] 43:J 23:j 23:f 23:h 23:g
23:[9d] 23:e 23:[yuo] 23:e 23:[9ip] 47:[uo] 47:[2p] 2:d 4:j 15:9 23:[qey] 23:[9h] 11:g 11:[qeyf] 23:[9d] 23:[qeyf] 23:[9g] 23:[2p] 23:9 23:[qey] 23:[9h] 11:g 11:[qeyf] 23:[9d] 23:[qeyf] 23:[9g]
23:[5J] 23:w 23:[Eyo] 23:[wj] 11:h 11:[Eyog] 23:[wf] 23:[Eyog] 23:[wh] 23:[1s] 23:8 23:[0wt] 23:[8h] 11:f 11:[0wtJ] 23:[8s] 23:[0wtf] 23:[8J] 23:[4j] 23:q 23:[eti] 23:q 23:[eti] 23:q 23:[eti] 23:[qo]
23:[6T] 2:u 3:p 16:* 23:0 23:w 23:T 94:[pSfh] 161:[9j] 23:e 23:y 23:[ih] 11:g 11:[pf] 23:d 23:f 23:g 23:[9p] 23:e 23:y 23:[ih] 11:g 11:[pf] 23:d 23:f 23:g 23:[5J] 23:9 23:w 23:[yj] 11:h 11:[og] 23:f
23:g 23:h 23:[1s] 23:5 23:8 23:[wh] 11:f 11:[tJ] 23:s 23:f 23:J 23:[4j] 23:8 23:q 23:t 23:i 23:t 23:[qi] 23:[8o] 23:[6T] 3:u 3:p 15:* 23:0 23:w 23:[Ty] 3:o 3:a 39:u 1:p 1:S 91:[9qd] 72:[0wf] 97:[9qg]
98:[5J] 21:[9wJ] 10:j 9:[5h] 21:[9wg] 21:[8f] 10:d 10:[0Ef] 20:8 10:s 10:[0Ed] 10:f 10:[8j] 20:[qej] 10:h 10:[8g] 21:[qef] 21:[^d] 9:s 10:[qEd] 21:^ 10:P 10:[qEs] 10:d 9:[5h] 21:[0wh] 10:g 10:[5f]
21:[0wd] 20:[6S] 10:a 10:[*wS] 21:6 10:p 9:[*wa] 10:S 10:[9f] 21:[eyd] 10:S 10:[9d] 9:f 10:[qyg] 21:9 21:[eyd] 20:[9f] 21:[eyg] 21:[5J] 21:[9wJ] 9:j 10:[5h] 21:[9wg] 21:[8f] 10:d 9:[0Ef] 21:8 10:s
10:[0Ed] 10:f 10:[8j] 20:[qej] 10:h 10:[8g] 21:[qef] 20:[^d] 10:s 10:[qEd] 21:^ 10:P 10:[qEs] 9:d 10:[5h] 21:[0wh] 10:g 10:[5f] 20:[0wd] 21:[6S] 10:a 10:[*wS] 21:6 9:p 10:[*wa] 10:S 10:[9ipf]
21:[eyipd] 42:J 23:j 23:f 23:h 23:g 23:[9d] 23:e 23:[yuo] 23:e 23:[9ip] 47:[uo] 47:[2j] 23:9 23:[qey] 23:[9h] 11:g 11:[qeyf] 23:[9d] 23:[qeyf] 23:[9g] 23:[2p] 23:9 23:[qey] 23:[9h] 11:g 11:[qeyf]
23:[9d] 23:[qeyf] 23:[9g] 23:[5J] 23:w 23:[Eyo] 23:[wj] 11:h 11:[Eyog] 23:[wf] 23:[Eyog] 23:[wh] 23:[1s] 23:8 23:[0wt] 23:[8h] 11:f 11:[0wtJ] 23:[8s] 23:[^0wtf] 23:[8J] 23:[4j] 23:q 23:[eti] 23:q
23:[eti] 23:q 23:[eti] 23:[qo] 23:[6T] 3:u 3:p 15:* 23:0 23:w 23:[7y] 3:o 3:a 39:[!*u] 3:p 3:S 87:[9qd] 95:[0wf] 74:[9qg] 100:[5J] 20:[9wJ] 10:j 10:[5h] 21:[9wg] 21:[8f] 9:d 10:[0Ef] 21:8 10:s
10:[0Ed] 10:f 9:[8j] 21:[qej] 10:h 10:[8g] 21:[qef] 20:[^d] 10:s 10:[qEd] 21:^ 10:P 9:[qEs] 10:d 10:[5h] 21:[0wh] 10:g 10:[5f] 20:[0wd] 21:[6S] 10:a 10:[*wS] 20:6 10:p 10:[*wa] 10:S 10:[9f] 21:[eyd]
9:S 10:[9d] 10:f 10:[qyg] 21:9 20:[eyd] 21:[9f] 21:[eyg] 21:[5J] 20:[9wJ] 10:j 10:[5h] 21:[9wg] 20:[8f] 10:d 10:[0Ef] 21:8 10:s 10:[0Ed] 9:f 10:[8j] 21:[qej] 10:h 10:[8g] 20:[qef] 21:[^d] 10:s
10:[qEd] 21:^ 9:P 10:[qEs] 10:d 10:[5h] 21:[0wh] 10:g 9:[5f] 21:[0wd] 21:[6S] 10:a 10:[*wS] 20:6 10:p 10:[*wa] 10:S 10:[9ipf] 20:[eyipd]
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
    Id="la-maritza-sylvie-vartan",
    Name="La Maritza",
    Artist="Sylvie Vartan",
    BPM=76,
    StepsPerBeat=48,
    Complete=true,
    Source="User-supplied MIDI",
    SourceLicense="User-provided source file; arrangement converted for Velora.",
    Categories={"Famous","French","Chanson","Pop","Piano","Sylvie Vartan","Complete"},
    Notes=table.concat(sheet, " "),
}
