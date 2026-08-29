-- Velora song adapter for TALENTLESS's historical LEVAN_POLKKA arrangement.
-- TALENTLESS used the filename LEVAN_POLKKA; this converts its keypress/rest
-- event stream into Velora's native high-resolution sheet format at runtime.

local BPM = 119
local STEPS_PER_BEAT = 64

local SOURCES = {
    "https://hellohellohell0.com/talentless-raw/SONGS/LEVAN_POLKKA",
    "https://raw.githubusercontent.com/hellohellohell012321/TALENTLESS/c101dcd8ed43f868ad70a1bcd32281954e87ca70/LEVAN_POLKKA",
}

local function fetchArrangement()
    local lastError

    for _, url in ipairs(SOURCES) do
        local ok, body = pcall(function()
            return game:HttpGet(url, true)
        end)

        if ok
            and type(body) == "string"
            and #body > 64
            and body:find("keypress", 1, true)
            and body:find("rest", 1, true) then
            return body, url
        end

        lastError = body
    end

    error("Velora could not fetch the Ievan Polkka arrangement: " .. tostring(lastError), 0)
end

local source, sourceUrl = fetchArrangement()
local sheet = {}
local pendingKeys = {}
local pendingGap = 0
local restBuffer = 0
local emitted = false

local function appendDashes(count)
    for _ = 1, math.max(0, count) do
        sheet[#sheet + 1] = "-"
    end
end

local function gapToDashes(beats, isFirst)
    local steps = math.max(0, math.floor((tonumber(beats) or 0) * STEPS_PER_BEAT + 0.5))
    if isFirst then
        return steps
    end
    return math.max(steps - 1, 0)
end

local function appendKeys(keys)
    for index = 1, #keys do
        pendingKeys[#pendingKeys + 1] = keys:sub(index, index)
    end
end

local function flushPending()
    if #pendingKeys == 0 then
        return
    end

    appendDashes(gapToDashes(pendingGap, not emitted))

    if #pendingKeys == 1 then
        sheet[#sheet + 1] = pendingKeys[1]
    else
        sheet[#sheet + 1] = "[" .. table.concat(pendingKeys) .. "]"
    end

    table.clear(pendingKeys)
    emitted = true
end

for line in source:gmatch("[^\r\n]+") do
    local keys = line:match('^%s*keypress%(%s*"([^"]+)"')

    if keys then
        if #pendingKeys == 0 then
            pendingGap = restBuffer
            restBuffer = 0
            appendKeys(keys)
        elseif restBuffer > 0 then
            flushPending()
            pendingGap = restBuffer
            restBuffer = 0
            appendKeys(keys)
        else
            -- Consecutive TALENTLESS keypress calls with no rest are one chord.
            appendKeys(keys)
        end
    else
        local restValue = line:match("^%s*rest%(%s*([%d%.]+)")
        if restValue then
            restBuffer += tonumber(restValue) or 0
        end
    end
end

flushPending()

if emitted and restBuffer > 0 then
    appendDashes(gapToDashes(restBuffer, false))
end

if #sheet == 0 then
    error("Velora parsed zero notes from the Ievan Polkka arrangement.", 0)
end

return {
    Id = "ievan-polkka",
    Name = "Ievan Polkka",
    Artist = "Traditional Finnish",
    BPM = BPM,
    StepsPerBeat = STEPS_PER_BEAT,
    Complete = true,
    Source = sourceUrl,
    SourceLicense = "Upstream TALENTLESS arrangement; see the source repository/license for terms.",
    Categories = {"Famous", "TikTok", "Folk", "Upbeat", "Piano", "Complete"},
    Notes = table.concat(sheet, " "),
}
