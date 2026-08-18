-- Velora v0.2
-- Converts compact piano sheets into a validated playback timeline.

local Parser = {}

local function clampNumber(value, fallback, minimum, maximum)
    value = tonumber(value) or fallback
    return math.clamp(value, minimum, maximum)
end

local function parseChord(token)
    local notes = {}
    local body = token:sub(2, -2)

    for note in body:gmatch("[^,%s]+") do
        if #note == 1 then
            table.insert(notes, note)
        else
            for index = 1, #note do
                table.insert(notes, note:sub(index, index))
            end
        end
    end

    return notes
end

function Parser.parse(sheet, bpm, stepsPerBeat)
    assert(type(sheet) == "string", "Velora Parser: sheet must be a string")

    bpm = clampNumber(bpm, 120, 30, 300)
    stepsPerBeat = clampNumber(stepsPerBeat, 2, 1, 16)

    local stepDuration = (60 / bpm) / stepsPerBeat
    local events = {}
    local cursor = 0

    for token in sheet:gmatch("%S+") do
        if token == "|" then
            -- Visual bar separator; it does not consume time.
        elseif token == "-" or token == "_" then
            cursor += stepDuration
        else
            local notes
            if token:sub(1, 1) == "[" and token:sub(-1) == "]" then
                notes = parseChord(token)
            else
                notes = { token }
            end

            if #notes > 0 then
                table.insert(events, {
                    Time = cursor,
                    Notes = notes,
                    Token = token,
                    Index = #events + 1,
                })
            end

            cursor += stepDuration
        end
    end

    return {
        BPM = bpm,
        StepsPerBeat = stepsPerBeat,
        StepDuration = stepDuration,
        Duration = cursor,
        Events = events,
    }
end

return Parser
