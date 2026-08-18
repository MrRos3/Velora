-- Velora Standalone v0.1
-- Safe single-file LocalScript for Roblox Studio / experiences you control.
-- Drop into StarterPlayerScripts or StarterGui and press Play.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function parse(sheet, bpm, stepsPerBeat)
    bpm = tonumber(bpm) or 120
    stepsPerBeat = tonumber(stepsPerBeat) or 2
    local step = (60 / bpm) / stepsPerBeat
    local events, cursor = {}, 0

    for token in sheet:gmatch("%S+") do
        if token == "|" then
            -- visual separator
        elseif token == "-" then
            cursor += step
        else
            local notes = {}
            if token:sub(1,1) == "[" and token:sub(-1) == "]" then
                local chord = token:sub(2,-2)
                for i = 1, #chord do
                    table.insert(notes, chord:sub(i,i))
                end
            else
                table.insert(notes, token)
            end
            table.insert(events, {Time = cursor, Notes = notes})
            cursor += step
        end
    end

    return {Events = events, Duration = cursor}
end

local SONGS = {
    {
        Name = "Velora Demo",
        Artist = "Velora",
        BPM = 120,
        StepsPerBeat = 2,
        Notes = "a s d f | [gj] - h j | [ad] [sf] g -",
    },
}

local state = {
    song = SONGS[1],
    timeline = nil,
    playing = false,
    paused = false,
    position = 0,
    nextEvent = 1,
    speed = 1,
    loop = false,
    connection = nil,
}

-- Bind this function to the piano system in your own experience.
local function playNote(note)
    print("[Velora] PLAY", note)
end

local gui = Instance.new("ScreenGui")
gui.Name = "Velora"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(520, 330)
frame.Position = UDim2.new(0.5, -260, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(105, 92, 255)
stroke.Transparency = 0.4
stroke.Thickness = 1
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -32, 0, 38)
title.Position = UDim2.fromOffset(20, 16)
title.Font = Enum.Font.GothamBold
title.Text = "VELORA  🥀"
title.TextColor3 = Color3.fromRGB(245,245,255)
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1, -40, 0, 24)
subtitle.Position = UDim2.fromOffset(20, 54)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Piano player • v0.1 standalone"
subtitle.TextColor3 = Color3.fromRGB(155,160,180)
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local songCard = Instance.new("Frame")
songCard.Size = UDim2.new(1, -40, 0, 82)
songCard.Position = UDim2.fromOffset(20, 92)
songCard.BackgroundColor3 = Color3.fromRGB(24,27,39)
songCard.BorderSizePixel = 0
songCard.Parent = frame
Instance.new("UICorner", songCard).CornerRadius = UDim.new(0, 12)

local songName = Instance.new("TextLabel")
songName.BackgroundTransparency = 1
songName.Size = UDim2.new(1, -20, 0, 30)
songName.Position = UDim2.fromOffset(14, 10)
songName.Font = Enum.Font.GothamSemibold
songName.Text = state.song.Name
songName.TextColor3 = Color3.fromRGB(240,240,250)
songName.TextSize = 17
songName.TextXAlignment = Enum.TextXAlignment.Left
songName.Parent = songCard

local songMeta = Instance.new("TextLabel")
songMeta.BackgroundTransparency = 1
songMeta.Size = UDim2.new(1, -20, 0, 24)
songMeta.Position = UDim2.fromOffset(14, 42)
songMeta.Font = Enum.Font.Gotham
songMeta.Text = string.format("%s • %d BPM", state.song.Artist, state.song.BPM)
songMeta.TextColor3 = Color3.fromRGB(150,155,175)
songMeta.TextSize = 13
songMeta.TextXAlignment = Enum.TextXAlignment.Left
songMeta.Parent = songCard

local progressBack = Instance.new("Frame")
progressBack.Size = UDim2.new(1, -40, 0, 8)
progressBack.Position = UDim2.fromOffset(20, 194)
progressBack.BackgroundColor3 = Color3.fromRGB(40,43,58)
progressBack.BorderSizePixel = 0
progressBack.Parent = frame
Instance.new("UICorner", progressBack).CornerRadius = UDim.new(1,0)

local progress = Instance.new("Frame")
progress.Size = UDim2.new(0,0,1,0)
progress.BackgroundColor3 = Color3.fromRGB(120,105,255)
progress.BorderSizePixel = 0
progress.Parent = progressBack
Instance.new("UICorner", progress).CornerRadius = UDim.new(1,0)

local function button(text, x, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(105, 42)
    b.Position = UDim2.fromOffset(x, 228)
    b.BackgroundColor3 = Color3.fromRGB(31,35,50)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamSemibold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(235,235,245)
    b.TextSize = 14
    b.AutoButtonColor = true
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function stop()
    if state.connection then state.connection:Disconnect() state.connection = nil end
    state.playing = false
    state.paused = false
    state.position = 0
    state.nextEvent = 1
    progress.Size = UDim2.new(0,0,1,0)
end

local function play()
    if state.playing then return end
    if not state.timeline then
        state.timeline = parse(state.song.Notes, state.song.BPM, state.song.StepsPerBeat)
    end
    state.playing = true
    state.paused = false
    state.connection = RunService.Heartbeat:Connect(function(dt)
        if state.paused then return end
        state.position += dt * state.speed
        local events = state.timeline.Events
        while state.nextEvent <= #events and events[state.nextEvent].Time <= state.position do
            for _, note in ipairs(events[state.nextEvent].Notes) do
                playNote(note)
            end
            state.nextEvent += 1
        end
        local ratio = state.timeline.Duration > 0 and math.clamp(state.position/state.timeline.Duration,0,1) or 0
        progress.Size = UDim2.new(ratio,0,1,0)
        if state.position >= state.timeline.Duration then
            if state.loop then
                state.position = 0
                state.nextEvent = 1
            else
                stop()
            end
        end
    end)
end

button("▶ Play", 20, play)
button("⏸ Pause", 135, function() if state.playing then state.paused = not state.paused end end)
button("■ Stop", 250, stop)
button("↻ Loop", 365, function() state.loop = not state.loop end)

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, -40, 0, 36)
hint.Position = UDim2.fromOffset(20, 282)
hint.Font = Enum.Font.Gotham
hint.Text = "Safe standalone build • bind playNote() to your own piano system"
hint.TextColor3 = Color3.fromRGB(125,130,150)
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = frame

print("[Velora] Standalone GUI loaded")
