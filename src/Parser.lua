-- Velora v0.1
-- Converts a compact text sheet into timed playback events.

local Parser = {}

local function cleanToken(token)
    return token:gsub("^%s+", ""):gsub("%s+$", "")
end

function Parser.parse(sheet, bpm, stepsPerBeat)
    assert(type(sheet) == "string", "Velora Parser: sheet must be a string")

    bpm = tonumber(bpm) or 120
    stepsPerBeat = tonumber(stepsPerBeat) or 2

    local secondsPerStep = (60 / bpm) / stepsPerBeat
    local events = {}
    local cursor = 0

    for token in sheet:gmatch("%S+") do
        token = cleanToken(token)

        if token == "|" then
            -- visual bar separator only
        elseif token == "-" then
            cursor += secondsPerStep
        else
            local notes = {}

            if token:sub(1, 1) == "[" and token:sub(-1) == "]" then
                local chord = token:sub(2, -2)
                for i = 1, #chord do
                    table.insert(notes, chord:sub(i, i))
                end
            else
                table.insert(notes, token)
            end

            table.insert(events, {
                Time = cursor,
                Notes = notes,
                Token = token,
            })

            cursor += secondsPerStep
        end
    end

    return {
        BPM = bpm,
        StepsPerBeat = stepsPerBeat,
        StepDuration = secondsPerStep,
        Duration = cursor,
        Events = events,
    }
end

return Parser
