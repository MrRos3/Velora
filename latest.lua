--[[
    Velora v0.3.0 "Nocturne" 🥀🎹
    Original Roblox piano player by MrRos3 / Velora.

    This implementation is independently written. It does not copy or adapt
    source code from TALENTLESS. Its design focuses on the same broad product
    category: a polished piano-song browser and playback workstation.

    Client behavior:
    - In environments with keypress/keyrelease or VirtualInputManager access,
      Velora can optionally send piano keyboard input.
    - Otherwise it runs in preview mode until Velora:BindPiano(callback) is used.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    error("Velora must run on the Roblox client.", 0)
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/main/"
local ICONS_URL = "https://raw.githubusercontent.com/MrRos3/Icons/main/lucide/dist/Icons.lua"

local CONFIG = {
    Version = "0.3.0",
    Codename = "Nocturne",
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(164, 112, 255),
    AccentAlt = Color3.fromRGB(255, 113, 191),
    ClickSound = "rbxassetid://4307186075",
    HoverSound = "rbxassetid://408524543",
    UiSounds = true,
    Blur = true,
    AutoInput = true,
    InputHold = 0.035,
}

local C = {
    Backdrop = Color3.fromRGB(5, 7, 13),
    Window = Color3.fromRGB(10, 13, 22),
    Window2 = Color3.fromRGB(14, 18, 29),
    Panel = Color3.fromRGB(18, 23, 37),
    Raised = Color3.fromRGB(25, 31, 49),
    Hover = Color3.fromRGB(34, 41, 63),
    Edge = Color3.new(1, 1, 1),
    Text = Color3.fromRGB(249, 249, 255),
    Sub = Color3.fromRGB(184, 190, 214),
    Muted = Color3.fromRGB(104, 113, 143),
    Success = Color3.fromRGB(101, 241, 172),
    Danger = Color3.fromRGB(255, 105, 130),
    Warning = Color3.fromRGB(255, 204, 102),
}

local function safeGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and result ~= "" then
        return result
    end
    return nil
end

local function safeLoadTable(url)
    local source = safeGet(url)
    if not source then
        return nil
    end
    local chunk = loadstring(source)
    if not chunk then
        return nil
    end
    local ok, result = pcall(chunk)
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

local Icons = safeLoadTable(ICONS_URL) or {}

local function create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
    }, parent)
end

local function stroke(parent, transparency, thickness, color)
    return create("UIStroke", {
        Color = color or C.Edge,
        Transparency = transparency == nil and 0.82 or transparency,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, first, second, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(first, second),
        Rotation = rotation or 0,
    }, parent)
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
    }, parent)
end

local function tween(target, duration, properties, style, direction)
    if not target or not target.Parent then
        return nil
    end
    local motion = TweenService:Create(
        target,
        TweenInfo.new(
            duration or 0.14,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    motion:Play()
    return motion
end

local function text(parent, value, size, color, font, alignment)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = value or "",
        TextColor3 = color or C.Text,
        TextSize = size or 12,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function icon(parent, name, size, color, fallback)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(size, size),
    }, parent)

    local asset = Icons[name]
    if asset then
        local image = create("ImageLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Image = asset,
            ImageColor3 = color or C.Text,
            ScaleType = Enum.ScaleType.Fit,
        }, holder)
        image:SetAttribute("LucideName", name)
        holder:SetAttribute("IconType", "image")
        holder:SetAttribute("IconName", name)
        return holder, image
    end

    local label = text(holder, fallback or "•", math.max(10, size - 1), color or C.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    label.Size = UDim2.fromScale(1, 1)
    holder:SetAttribute("IconType", "text")
    holder:SetAttribute("IconName", name)
    return holder, label
end

local function recolorIcon(holder, color)
    if not holder then
        return
    end
    local child = holder:FindFirstChildWhichIsA("ImageLabel") or holder:FindFirstChildWhichIsA("TextLabel")
    if child then
        if child:IsA("ImageLabel") then
            child.ImageColor3 = color
        else
            child.TextColor3 = color
        end
    end
end

local function playUiSound(id, volume)
    if not CONFIG.UiSounds then
        return
    end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.Name = "VeloraUISound"
        sound.SoundId = id
        sound.Volume = volume or 0.12
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            if sound.Parent then
                sound:Destroy()
            end
        end)
        task.delay(3, function()
            if sound.Parent then
                sound:Destroy()
            end
        end)
    end)
end

local function uiClick()
    playUiSound(CONFIG.ClickSound, 0.22)
end

local function uiHover()
    playUiSound(CONFIG.HoverSound, 0.07)
end

local function formatTime(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

local function truncate(value, maximum)
    value = tostring(value or "")
    maximum = maximum or 24
    if #value <= maximum then
        return value
    end
    return value:sub(1, maximum - 1) .. "…"
end

local function contains(haystack, needle)
    return string.find(string.lower(tostring(haystack or "")), string.lower(tostring(needle or "")), 1, true) ~= nil
end

-- =========================================================
-- Song parser
-- =========================================================

local function parseChord(token)
    local body = token:sub(2, -2)
    local notes = {}

    if body:find(",", 1, true) or body:find(" ", 1, true) then
        for note in body:gmatch("[^,%s]+") do
            if note ~= "" then
                table.insert(notes, note)
            end
        end
    else
        for index = 1, #body do
            table.insert(notes, body:sub(index, index))
        end
    end

    return notes
end

local function parseSheet(sheet, bpm, stepsPerBeat)
    bpm = math.clamp(tonumber(bpm) or 120, 30, 300)
    stepsPerBeat = math.clamp(tonumber(stepsPerBeat) or 2, 1, 16)

    local stepDuration = (60 / bpm) / stepsPerBeat
    local events = {}
    local cursor = 0

    for token in tostring(sheet or ""):gmatch("%S+") do
        if token == "|" then
            -- visual separator only
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
        Events = events,
        Duration = cursor,
    }
end

-- =========================================================
-- Optional keyboard input backend
-- =========================================================

local VK_PUNCT = {
    [";"] = 0xBA,
    ["="] = 0xBB,
    [","] = 0xBC,
    ["-"] = 0xBD,
    ["."] = 0xBE,
    ["/"] = 0xBF,
    ["`"] = 0xC0,
    ["["] = 0xDB,
    ["\\"] = 0xDC,
    ["]"] = 0xDD,
    ["'"] = 0xDE,
}

local ENUM_DIGITS = {
    ["0"] = Enum.KeyCode.Zero,
    ["1"] = Enum.KeyCode.One,
    ["2"] = Enum.KeyCode.Two,
    ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four,
    ["5"] = Enum.KeyCode.Five,
    ["6"] = Enum.KeyCode.Six,
    ["7"] = Enum.KeyCode.Seven,
    ["8"] = Enum.KeyCode.Eight,
    ["9"] = Enum.KeyCode.Nine,
}

local ENUM_PUNCT = {
    [";"] = Enum.KeyCode.Semicolon,
    ["="] = Enum.KeyCode.Equals,
    [","] = Enum.KeyCode.Comma,
    ["-"] = Enum.KeyCode.Minus,
    ["."] = Enum.KeyCode.Period,
    ["/"] = Enum.KeyCode.Slash,
    ["`"] = Enum.KeyCode.Backquote,
    ["["] = Enum.KeyCode.LeftBracket,
    ["\\"] = Enum.KeyCode.BackSlash,
    ["]"] = Enum.KeyCode.RightBracket,
    ["'"] = Enum.KeyCode.Quote,
}

local function findGlobal(name)
    local value = rawget(_G, name)
    if value ~= nil then
        return value
    end

    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            return rawget(env, name)
        end
    end

    return nil
end

local function keyToVk(note)
    note = tostring(note or "")
    if #note ~= 1 then
        return nil, false
    end

    local shift = note:match("%u") ~= nil
    local lower = string.lower(note)

    if lower:match("%a") then
        return string.byte(string.upper(lower)), shift
    elseif lower:match("%d") then
        return string.byte(lower), false
    end

    return VK_PUNCT[lower], false
end

local function keyToEnum(note)
    note = tostring(note or "")
    if #note ~= 1 then
        return nil, false
    end

    local shift = note:match("%u") ~= nil
    local lower = string.lower(note)

    if lower:match("%a") then
        local enumName = string.upper(lower)
        return Enum.KeyCode[enumName], shift
    elseif ENUM_DIGITS[lower] then
        return ENUM_DIGITS[lower], false
    end

    return ENUM_PUNCT[lower], false
end

local InputBackend = {
    Name = "Preview",
    Available = false,
    Send = nil,
}

local keypressFn = findGlobal("keypress")
local keyreleaseFn = findGlobal("keyrelease")

if type(keypressFn) == "function" and type(keyreleaseFn) == "function" then
    InputBackend.Name = "Executor Input"
    InputBackend.Available = true
    InputBackend.Send = function(note)
        local vk, needsShift = keyToVk(note)
        if not vk then
            return false
        end

        local ok = pcall(function()
            if needsShift then
                keypressFn(0x10)
            end
            keypressFn(vk)
            task.delay(CONFIG.InputHold, function()
                pcall(keyreleaseFn, vk)
                if needsShift then
                    pcall(keyreleaseFn, 0x10)
                end
            end)
        end)

        return ok
    end
else
    local vim = nil
    pcall(function()
        vim = game:GetService("VirtualInputManager")
    end)

    if vim then
        InputBackend.Name = "Virtual Input"
        InputBackend.Available = true
        InputBackend.Send = function(note)
            local keyCode, needsShift = keyToEnum(note)
            if not keyCode then
                return false
            end

             local ok = pcall(function()
                if needsShift then
                    vim:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                end
                vim:SendKeyEvent(true, keyCode, false, game)
                task.delay(CONFIG.InputHold, function()
                    pcall(function()
                        vim:SendKeyEvent(false, keyCode, false, game)
                        if needsShift then
                            vim:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                        end
                    end)
                end)
            end)

            return ok
        end
    end
end

-- =========================================================
-- Registry and playback state
-- =========================================================

local FALLBACK_SONGS = {
    {
        Id = "velora-demo",
        Name = "Velora Demo",
        Artist = "Velora",
        BPM = 100,
        Categories = { "Original", "Starter" },
        Inline = {
            BPM = 100,
            StepsPerBeat = 2,
            Notes = "a s d f | g h j k | [ad] - [sf] - | g h j k",
        },
    },
    {
        Id = "moonlit-keys",
        Name = "Moonlit Keys",
        Artist = "Velora",
        BPM = 88,
        Categories = { "Original", "Chill" },
        Inline = {
            BPM = 88,
            StepsPerBeat = 2,
            Notes = "a - s d | [fg] - h j | k j h g | [ad] - [sf] -",
        },
    },
}

local function loadRegistry()
    local registry = safeLoadTable(RAW_BASE .. "Songs.lua?velora=0.3.0")
    if type(registry) == "table" and #registry > 0 then
        return registry
    end
    return FALLBACK_SONGS
end

local Registry = loadRegistry()

local API = {
    Version = CONFIG.Version,
    Codename = CONFIG.Codename,
}

local state = {
    Registry = Registry,
    SongCache = {},
    CurrentEntry = nil,
    CurrentSong = nil,
    Timeline = nil,
    CurrentBPM = nil,
    Playing = false,
    Paused = false,
    Position = 0,
    NextEvent = 1,
    Speed = 1,
    Loop = false,
    Shuffle = false,
    AutoInput = CONFIG.AutoInput and InputBackend.Available,
    BoundCallback = nil,
    Favorites = {},
    Recent = {},
    Queue = {},
    Category = "All Songs",
    Search = "",
    Connection = nil,
    UI = nil,
    Destroyed = false,
}

local changed = Instance.new("BindableEvent")
local notePlayed = Instance.new("BindableEvent")

API.Changed = changed.Event
API.NotePlayed = notePlayed.Event

local function emit(reason)
    changed:Fire(reason or "changed")
end

local function getEntry(id)
    for _, entry in ipairs(state.Registry) do
        if entry.Id == id then
            return entry
        end
    end
    return nil
end

local function loadSongData(entry)
    if not entry then
        return nil, "Missing song entry"
    end

    if state.SongCache[entry.Id] then
        return state.SongCache[entry.Id]
    end

    if type(entry.Inline) == "table" then
        state.SongCache[entry.Id] = entry.Inline
        return entry.Inline
    end

    local file = tostring(entry.File or "")
    if file == "" then
        return nil, "Song has no File or Inline data"
    end

    local url = file:match("^https?://") and file or (RAW_BASE .. file)
    local source = safeGet(url .. (url:find("?", 1, true) and "&" or "?") .. "v=" .. CONFIG.Version)
    if not source then
        return nil, "Could not download " .. file
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        return nil, "Song compile error: " .. tostring(compileError)
    end

    local ok, result = pcall(chunk)
    if not ok or type(result) ~= "table" then
        return nil, "Song did not return a table"
    end

    state.SongCache[entry.Id] = result
    return result
end

local function addRecent(id)
    for index = #state.Recent, 1, -1 do
        if state.Recent[index] == id then
            table.remove(state.Recent, index)
        end
    end
    table.insert(state.Recent, 1, id)
    while #state.Recent > 12 do
        table.remove(state.Recent)
    end
end

local function stopConnection()
    if state.Connection then
        state.Connection:Disconnect()
        state.Connection = nil
    end
end

local function noteOutput(note)
    notePlayed:Fire(note)

    if type(state.BoundCallback) == "function" then
        local ok, err = pcall(state.BoundCallback, note)
        if not ok then
            warn("[Velora] piano callback failed:", err)
        end
        return true
    end

    if state.AutoInput and InputBackend.Available and InputBackend.Send then
        return InputBackend.Send(note)
    end

    return false
end

local function findNextEntry()
    if #state.Queue > 0 then
        local id = table.remove(state.Queue, 1)
        return getEntry(id)
    end

    if state.Shuffle and #state.Registry > 0 then
        if #state.Registry == 1 then
            return state.Registry[1]
        end

        local candidate
        repeat
            candidate = state.Registry[math.random(1, #state.Registry)]
        until not state.CurrentEntry or candidate.Id ~= state.CurrentEntry.Id
        return candidate
    end

    if state.CurrentEntry then
        for index, entry in ipairs(state.Registry) do
            if entry.Id == state.CurrentEntry.Id then
                return state.Registry[index + 1]
            end
        end
    end

    return nil
end

function API:GetSongs()
    return state.Registry
end

function API:GetSong(id)
    return getEntry(id)
end

function API:RefreshLibrary()
    local registry = loadRegistry()
    if type(registry) == "table" and #registry > 0 then
        state.Registry = registry
        state.SongCache = {}
        emit("library")
        return true
    end
    return false
end

function API:AddRuntimeSong(entry, data)
    assert(type(entry) == "table" and type(entry.Id) == "string", "Velora:AddRuntimeSong requires entry.Id")
    if getEntry(entry.Id) then
        return false, "Song id already exists"
    end

    if type(data) == "table" then
        entry.Inline = data
    end

    table.insert(state.Registry, entry)
    emit("library")
    return true
end

function API:LoadSong(id, autoplay)
    local entry = getEntry(id)
    if not entry then
        return false, "Unknown song: " .. tostring(id)
    end

    local song, loadError = loadSongData(entry)
    if not song then
        warn("[Velora] " .. tostring(loadError))
        emit("error")
        return false, loadError
    end

    stopConnection()

    local bpm = math.clamp(tonumber(song.BPM or entry.BPM) or 120, 30, 300)
    local timeline = parseSheet(song.Notes or "", bpm, song.StepsPerBeat)

    state.CurrentEntry = entry
    state.CurrentSong = song
    state.CurrentBPM = bpm
    state.Timeline = timeline
    state.Playing = false
    state.Paused = false
    state.Position = 0
    state.NextEvent = 1

    addRecent(entry.Id)
    emit("selection")

    if autoplay then
        return self:Play()
    end

    return true
end

function API:Play()
    if not state.Timeline or #state.Timeline.Events == 0 then
        return false
    end

    if state.Position >= state.Timeline.Duration then
        state.Position = 0
        state.NextEvent = 1
    end

    if state.Playing then
        if state.Paused then
            state.Paused = false
            emit("resumed")
        end
        return true
    end

    state.Playing = true
    state.Paused = false
    emit("playing")

    stopConnection()
    state.Connection = RunService.Heartbeat:Connect(function(dt)
        if state.Destroyed or state.Paused or not state.Timeline then
            return
        end

        state.Position += dt * state.Speed

        local events = state.Timeline.Events
        while state.NextEvent <= #events and events[state.NextEvent].Time <= state.Position do
            local event = events[state.NextEvent]
            for _, note in ipairs(event.Notes) do
                noteOutput(note)
            end
            state.NextEvent += 1
        end

        if state.Position >= state.Timeline.Duration then
            if state.Loop then
                state.Position = 0
                state.NextEvent = 1
                emit("looped")
            else
                stopConnection()
                state.Playing = false
                state.Paused = false
                state.Position = state.Timeline.Duration
                emit("finished")

                local nextEntry = findNextEntry()
                if nextEntry then
                    task.defer(function()
                        if not state.Destroyed then
                            API:LoadSong(nextEntry.Id, true)
                        end
                    end)
                end
            end
        end
    end)

    return true
end

function API:Pause()
    if not state.Playing then
        return false
    end
    state.Paused = not state.Paused
    emit(state.Paused and "paused" or "resumed")
    return state.Paused
end

function API:Stop()
    stopConnection()
    local hadState = state.Playing or state.Paused or state.Position > 0
    state.Playing = false
    state.Paused = false
    state.Position = 0
    state.NextEvent = 1
    if hadState then
        emit("stopped")
    end
end

function API:Seek(progress)
    if not state.Timeline then
        return false
    end

    progress = math.clamp(tonumber(progress) or 0, 0, 1)
    state.Position = state.Timeline.Duration * progress
    state.NextEvent = 1

    while state.NextEvent <= #state.Timeline.Events
        and state.Timeline.Events[state.NextEvent].Time < state.Position do
        state.NextEvent += 1
    end

    emit("seek")
    return true
end

function API:SetSpeed(value)
    state.Speed = math.clamp(tonumber(value) or 1, 0.5, 2)
    emit("speed")
    return state.Speed
end

function API:SetBPM(value)
    if not state.CurrentSong then
        return nil
    end

    local bpm = math.clamp(tonumber(value) or state.CurrentBPM or 120, 30, 300)
    local progress = 0
    if state.Timeline and state.Timeline.Duration > 0 then
        progress = math.clamp(state.Position / state.Timeline.Duration, 0, 1)
    end

    local playing = state.Playing and not state.Paused
    local paused = state.Paused

    stopConnection()
    state.Timeline = parseSheet(state.CurrentSong.Notes or "", bpm, state.CurrentSong.StepsPerBeat)
    state.CurrentBPM = bpm
    self:Seek(progress)

    state.Playing = false
    state.Paused = false

    if playing then
        self:Play()
    elseif paused then
        self:Play()
        self:Pause()
    end

    emit("bpm")
    return bpm
end

function API:SetLoop(enabled)
    state.Loop = enabled == true
    emit("loop")
    return state.Loop
end

function API:SetShuffle(enabled)
    state.Shuffle = enabled == true
    emit("shuffle")
    return state.Shuffle
end

function API:SetAutoInput(enabled)
    state.AutoInput = enabled == true and InputBackend.Available
    emit("input")
    return state.AutoInput
end

function API:BindPiano(callback)
    assert(type(callback) == "function", "Velora:BindPiano expects a function")
    state.BoundCallback = callback
    emit("input")
end

function API:UnbindPiano()
    state.BoundCallback = nil
    emit("input")
end

function API:GetInputMode()
    if state.BoundCallback then
        return "Bound Piano", true
    elseif state.AutoInput and InputBackend.Available then
        return InputBackend.Name, true
    end
    return "Preview Only", false
end

function API:IsFavorite(id)
    return state.Favorites[id] == true
end

function API:ToggleFavorite(id)
    if not getEntry(id) then
        return false
    end
    state.Favorites[id] = not state.Favorites[id]
    emit("favorites")
    return state.Favorites[id]
end

function API:AddToQueue(id)
    if not getEntry(id) then
        return false
    end
    table.insert(state.Queue, id)
    emit("queue")
    return true
end

function API:RemoveFromQueue(index)
    if state.Queue[index] then
        table.remove(state.Queue, index)
        emit("queue")
        return true
    end
    return false
end

function API:ClearQueue()
    table.clear(state.Queue)
    emit("queue")
end

function API:GetQueue()
    local output = {}
    for index, id in ipairs(state.Queue) do
        output[index] = id
    end
    return output
end

function API:GetRecent()
    local output = {}
    for index, id in ipairs(state.Recent) do
        output[index] = id
    end
    return output
end

function API:GetSnapshot()
    local progress = 0
    local duration = state.Timeline and state.Timeline.Duration or 0
    if duration > 0 then
        progress = math.clamp(state.Position / duration, 0, 1)
    end

    local mode, connected = self:GetInputMode()

    return {
        Entry = state.CurrentEntry,
        Song = state.CurrentSong,
        Playing = state.Playing,
        Paused = state.Paused,
        Position = state.Position,
        Duration = duration,
        Progress = progress,
        Speed = state.Speed,
        BPM = state.CurrentBPM,
        Loop = state.Loop,
        Shuffle = state.Shuffle,
        InputMode = mode,
        Connected = connected,
        QueueCount = #state.Queue,
    }
end

-- =========================================================
-- UI
-- =========================================================

local oldGui = PlayerGui:FindFirstChild("Velora")
if oldGui then
    oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("VeloraBlur")
if oldBlur then
    oldBlur:Destroy()
end

local ui = {
    Connections = {},
    CategoryButtons = {},
    SongCards = {},
    PianoKeys = {},
    CurrentFiltered = {},
}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(ui.Connections, connection)
    return connection
end

local blur = create("BlurEffect", {
    Name = "VeloraBlur",
    Size = CONFIG.Blur and 12 or 0,
}, Lighting)
ui.Blur = blur

local gui = create("ScreenGui", {
    Name = "Velora",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 78,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
ui.Gui = gui

local backdrop = create("Frame", {
    Name = "Backdrop",
    BackgroundColor3 = C.Backdrop,
    BackgroundTransparency = 0.34,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
}, gui)
ui.Backdrop = backdrop

local window = create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(920, 560),
    BackgroundColor3 = C.Window,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, backdrop)
corner(window, 22)
stroke(window, 0.60, 1.1)
ui.Window = window

local windowGradient = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 22, 40)),
        ColorSequenceKeypoint.new(0.42, C.Window2),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 13, 23)),
    }),
    Rotation = 32,
}, window)
ui.WindowGradient = windowGradient

local windowScale = create("UIScale", {
    Scale = 1,
}, window)
ui.WindowScale = windowScale

local topbar = create("Frame", {
    Name = "Topbar",
    BackgroundColor3 = C.Window2,
    BackgroundTransparency = 0.30,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 64),
}, window)
ui.Topbar = topbar

local topSeparator = create("Frame", {
    BackgroundColor3 = C.Edge,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 18, 1, -1),
    Size = UDim2.new(1, -36, 0, 1),
}, topbar)
ui.TopSeparator = topSeparator

local brand = create("Frame", {
    Position = UDim2.fromOffset(18, 14),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = C.Raised,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
}, topbar)
corner(brand, 11)
stroke(brand, 0.62)
local brandIcon = icon(brand, "music-2", 18, CONFIG.Accent, "♪")
brandIcon.AnchorPoint = Vector2.new(0.5, 0.5)
brandIcon.Position = UDim2.fromScale(0.5, 0.5)
ui.BrandIcon = brandIcon

local title = text(topbar, "VELORA", 18, C.Text, Enum.Font.GothamBold)
title.Position = UDim2.fromOffset(66, 12)
title.Size = UDim2.fromOffset(170, 22)

local subtitle = text(topbar, "NOCTURNE  •  PIANO WORKSTATION", 8, CONFIG.Accent, Enum.Font.GothamBold)
subtitle.Position = UDim2.fromOffset(67, 34)
subtitle.Size = UDim2.fromOffset(250, 16)

local statusPill = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -94, 0.5, 0),
    Size = UDim2.fromOffset(144, 32),
    BackgroundColor3 = C.Raised,
    BackgroundTransparency = 0.42,
    BorderSizePixel = 0,
}, topbar)
corner(statusPill, 10)
stroke(statusPill, 0.76)
ui.StatusPill = statusPill

local statusDot = create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 10, 0.5, 0),
    Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = C.Warning,
    BorderSizePixel = 0,
}, statusPill)
corner(statusDot, 6)
ui.StatusDot = statusDot

local statusText = text(statusPill, "PREVIEW ONLY", 8, C.Sub, Enum.Font.GothamBold)
statusText.Position = UDim2.fromOffset(24, 0)
statusText.Size = UDim2.new(1, -30, 1, 0)
ui.StatusText = statusText

local function topButton(x, iconName, fallback)
    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, x, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = C.Raised,
        BackgroundTransparency = 0.44,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, topbar)
    corner(button, 9)
    stroke(button, 0.80)

    local holder = icon(button, iconName, 14, C.Sub, fallback)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(0.5, 0.5)

    connect(button.MouseEnter, function()
        uiHover()
        tween(button, 0.12, { BackgroundTransparency = 0.24 })
        recolorIcon(holder, C.Text)
    end)

    connect(button.MouseLeave, function()
        tween(button, 0.12, { BackgroundTransparency = 0.44 })
        recolorIcon(holder, C.Sub)
    end)

    return button
end

local minimizeButton = topButton(-48, "minus", "−")
local closeButton = topButton(-12, "x", "×")
ui.MinimizeButton = minimizeButton
ui.CloseButton = closeButton

local body = create("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 64),
    Size = UDim2.new(1, 0, 1, -64),
}, window)
ui.Body = body

local sidebar = create("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = C.Window2,
    BackgroundTransparency = 0.48,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.new(0, 170, 1, -28),
}, body)
corner(sidebar, 15)
stroke(sidebar, 0.86)
ui.Sidebar = sidebar

local libraryLabel = text(sidebar, "LIBRARY", 9, C.Muted, Enum.Font.GothamBold)
libraryLabel.Position = UDim2.fromOffset(14, 12)
libraryLabel.Size = UDim2.new(1, -28, 0, 18)

local categoryList = create("ScrollingFrame", {
    Name = "Categories",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(8, 38),
    Size = UDim2.new(1, -16, 1, -126),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Muted,
    ScrollBarImageTransparency = 0.55,
}, sidebar)
ui.CategoryList = categoryList

local categoryLayout = create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, categoryList)
ui.CategoryLayout = categoryLayout

local libraryStats = create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 8, 1, -8),
    Size = UDim2.new(1, -16, 0, 72),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.42,
    BorderSizePixel = 0,
}, sidebar)
corner(libraryStats, 12)
stroke(libraryStats, 0.88)
ui.LibraryStats = libraryStats

local statTitle = text(libraryStats, "VELORA LIBRARY", 8, C.Muted, Enum.Font.GothamBold)
statTitle.Position = UDim2.fromOffset(11, 8)
statTitle.Size = UDim2.new(1, -22, 0, 14)

local statSongs = text(libraryStats, tostring(#state.Registry) .. " songs", 11, C.Text, Enum.Font.GothamSemibold)
statSongs.Position = UDim2.fromOffset(11, 26)
statSongs.Size = UDim2.new(1, -22, 0, 18)
ui.StatSongs = statSongs

local statHint = text(libraryStats, "GitHub-backed registry", 8, C.Muted, Enum.Font.Gotham)
statHint.Position = UDim2.fromOffset(11, 46)
statHint.Size = UDim2.new(1, -22, 0, 14)

local browser = create("Frame", {
    Name = "Browser",
    BackgroundColor3 = C.Window2,
    BackgroundTransparency = 0.56,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(194, 14),
    Size = UDim2.new(0, 352, 1, -28),
}, body)
corner(browser, 15)
stroke(browser, 0.86)
ui.Browser = browser

local browserTitle = text(browser, "All Songs", 15, C.Text, Enum.Font.GothamBold)
browserTitle.Position = UDim2.fromOffset(14, 10)
browserTitle.Size = UDim2.new(1, -28, 0, 24)
ui.BrowserTitle = browserTitle

local browserCount = text(browser, "0 tracks", 8, C.Muted, Enum.Font.GothamMedium)
browserCount.Position = UDim2.fromOffset(14, 31)
browserCount.Size = UDim2.new(1, -28, 0, 14)
ui.BrowserCount = browserCount

local searchShell = create("Frame", {
    Position = UDim2.fromOffset(12, 54),
    Size = UDim2.new(1, -64, 0, 38),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.28,
    BorderSizePixel = 0,
}, browser)
corner(searchShell, 11)
local searchStroke = stroke(searchShell, 0.78)
ui.SearchShell = searchShell
ui.SearchStroke = searchStroke

local searchIcon = icon(searchShell, "search", 14, C.Muted, "⌕")
searchIcon.AnchorPoint = Vector2.new(0, 0.5)
searchIcon.Position = UDim2.new(0, 11, 0.5, 0)
ui.SearchIcon = searchIcon

local searchBox = create("TextBox", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(34, 0),
    Size = UDim2.new(1, -42, 1, 0),
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamMedium,
    PlaceholderText = "Search songs, artists, tags...",
    PlaceholderColor3 = C.Muted,
    Text = "",
    TextColor3 = C.Text,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, searchShell)
ui.SearchBox = searchBox

local randomButton = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
     Position = UDim2.new(1, -12, 0, 54),
    Size = UDim2.fromOffset(40, 38),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.28,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
}, browser)
corner(randomButton, 11)
stroke(randomButton, 0.78)
local randomIcon = icon(randomButton, "shuffle", 15, C.Sub, "↝")
randomIcon.AnchorPoint = Vector2.new(0.5, 0.5)
randomIcon.Position = UDim2.fromScale(0.5, 0.5)
ui.RandomButton = randomButton
ui.RandomIcon = randomIcon

local songList = create("ScrollingFrame", {
    Name = "SongList",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(8, 104),
    Size = UDim2.new(1, -16, 1, -112),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Muted,
    ScrollBarImageTransparency = 0.55,
}, browser)
ui.SongList = songList

local songLayout = create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, songList)
ui.SongLayout = songLayout
padding(songList, 4, 4, 0, 4)

local playerPanel = create("Frame", {
    Name = "NowPlaying",
    BackgroundColor3 = C.Window2,
    BackgroundTransparency = 0.46,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(556, 14),
    Size = UDim2.new(1, -570, 1, -28),
}, body)
corner(playerPanel, 15)
stroke(playerPanel, 0.82)
ui.PlayerPanel = playerPanel

local nowHeader = text(playerPanel, "NOW PLAYING", 9, C.Muted, Enum.Font.GothamBold)
nowHeader.Position = UDim2.fromOffset(16, 12)
nowHeader.Size = UDim2.new(1, -32, 0, 18)

local trackVisual = create("Frame", {
    Position = UDim2.fromOffset(16, 40),
    Size = UDim2.new(1, -32, 0, 116),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.24,
    BorderSizePixel = 0,
}, playerPanel)
corner(trackVisual, 15)
stroke(trackVisual, 0.78)
ui.TrackVisual = trackVisual

local visualHeader = create("Frame", {
    Position = UDim2.fromOffset(12, 12),
    Size = UDim2.new(1, -24, 0, 32),
    BackgroundTransparency = 1,
}, trackVisual)
ui.VisualHeader = visualHeader

local trackGlyph = create("Frame", {
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
}, visualHeader)
corner(trackGlyph, 10)
stroke(trackGlyph, 0.68, 1, CONFIG.Accent)
local trackIcon = icon(trackGlyph, "music", 15, CONFIG.Accent, "♪")
trackIcon.AnchorPoint = Vector2.new(0.5, 0.5)
trackIcon.Position = UDim2.fromScale(0.5, 0.5)
ui.TrackGlyph = trackGlyph
ui.TrackIcon = trackIcon

local visualTitle = text(visualHeader, "Select a song", 12, C.Text, Enum.Font.GothamBold)
visualTitle.Position = UDim2.fromOffset(42, 0)
visualTitle.Size = UDim2.new(1, -42, 0, 17)
ui.VisualTitle = visualTitle

local visualArtist = text(visualHeader, "Velora Library", 8, C.Muted, Enum.Font.GothamMedium)
visualArtist.Position = UDim2.fromOffset(42, 16)
visualArtist.Size = UDim2.new(1, -42, 0, 15)
ui.VisualArtist = visualArtist

local keyboard = create("Frame", {
    Name = "PianoVisualizer",
    Position = UDim2.fromOffset(12, 56),
    Size = UDim2.new(1, -24, 0, 48),
    BackgroundTransparency = 1,
}, trackVisual)
ui.Keyboard = keyboard

local keyLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, keyboard)
ui.KeyLayout = keyLayout

local visualKeys = { "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'" }
for index, keyName in ipairs(visualKeys) do
    local key = create("Frame", {
        Name = "Key_" .. keyName,
        Size = UDim2.new(1 / #visualKeys, -3, 1, 0),
        BackgroundColor3 = C.Text,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        LayoutOrder = index,
    }, keyboard)
    corner(key, 5)

    local keyLabel = text(key, string.upper(keyName), 7, C.Window, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    keyLabel.AnchorPoint = Vector2.new(0.5, 1)
    keyLabel.Position = UDim2.new(0.5, 0, 1, -4)
    keyLabel.Size = UDim2.new(1, 0, 0, 12)

    ui.PianoKeys[string.lower(keyName)] = key
end

local trackName = text(playerPanel, "Nothing selected", 16, C.Text, Enum.Font.GothamBold)
trackName.Position = UDim2.fromOffset(16, 168)
trackName.Size = UDim2.new(1, -32, 0, 24)
ui.TrackName = trackName

local trackMeta = text(playerPanel, "Choose a song from the library", 9, C.Muted, Enum.Font.GothamMedium)
trackMeta.Position = UDim2.fromOffset(16, 192)
trackMeta.Size = UDim2.new(1, -32, 0, 18)
ui.TrackMeta = trackMeta

local progressHit = create("TextButton", {
    Position = UDim2.fromOffset(16, 222),
    Size = UDim2.new(1, -32, 0, 22),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
}, playerPanel)
ui.ProgressHit = progressHit

local progressBack = create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.Raised,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
}, progressHit)
corner(progressBack, 4)
ui.ProgressBack = progressBack

local progressFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
}, progressBack)
corner(progressFill, 4)
ui.ProgressFill = progressFill

local progressThumb = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.fromOffset(9, 9),
    BackgroundColor3 = C.Text,
    BorderSizePixel = 0,
}, progressBack)
corner(progressThumb, 7)
ui.ProgressThumb = progressThumb

local timeLeft = text(playerPanel, "0:00", 8, C.Muted, Enum.Font.GothamMedium)
timeLeft.Position = UDim2.fromOffset(16, 244)
timeLeft.Size = UDim2.fromOffset(50, 14)
ui.TimeLeft = timeLeft

local timeRight = text(playerPanel, "0:00", 8, C.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
timeRight.AnchorPoint = Vector2.new(1, 0)
timeRight.Position = UDim2.new(1, -16, 0, 244)
timeRight.Size = UDim2.fromOffset(50, 14)
ui.TimeRight = timeRight

local controls = create("Frame", {
    Position = UDim2.fromOffset(16, 268),
    Size = UDim2.new(1, -32, 0, 52),
    BackgroundTransparency = 1,
}, playerPanel)
ui.Controls = controls

local controlLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, controls)
ui.ControlLayout = controlLayout

local function controlButton(name, iconName, fallback, large, order)
    local button = create("TextButton", {
        Name = name,
        Size = UDim2.fromOffset(large and 48 or 38, large and 48 or 38),
        BackgroundColor3 = large and CONFIG.Accent or C.Raised,
        BackgroundTransparency = large and 0.08 or 0.26,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    }, controls)
    corner(button, large and 15 or 12)
    stroke(button, large and 0.54 or 0.78)

    local holder = icon(button, iconName, large and 18 or 15, large and C.Text or C.Sub, fallback)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(0.5, 0.5)

    connect(button.MouseEnter, function()
        uiHover()
        tween(button, 0.12, {
            BackgroundTransparency = large and 0 or 0.12,
        })
        recolorIcon(holder, C.Text)
    end)

    connect(button.MouseLeave, function()
        tween(button, 0.12, {
            BackgroundTransparency = large and 0.08 or 0.26,
        })
        recolorIcon(holder, large and C.Text or C.Sub)
    end)

    return button, holder
end

local shuffleButton, shuffleIcon = controlButton("Shuffle", "shuffle", "↝", false, 1)
local previousButton, previousIcon = controlButton("Previous", "skip-back", "|◀", false, 2)
local playButton, playIcon = controlButton("Play", "play", "▶", true, 3)
local stopButton, stopIcon = controlButton("Stop", "square", "■", false, 4)
local loopButton, loopIcon = controlButton("Loop", "repeat-2", "↻", false, 5)
ui.ShuffleButton = shuffleButton
ui.ShuffleIcon = shuffleIcon
ui.PreviousButton = previousButton
ui.PlayButton = playButton
ui.PlayIcon = playIcon
ui.StopButton = stopButton
ui.LoopButton = loopButton
ui.LoopIcon = loopIcon

local tweakPanel = create("Frame", {
    Position = UDim2.fromOffset(16, 314),
    Size = UDim2.new(1, -32, 0, 96),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.34,
    BorderSizePixel = 0,
}, playerPanel)
corner(tweakPanel, 13)
stroke(tweakPanel, 0.84)
ui.TweakPanel = tweakPanel

local function tweakRow(y, labelText, valueText)
    local row = create("Frame", {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundTransparency = 1,
    }, tweakPanel)

    local label = text(row, labelText, 9, C.Sub, Enum.Font.GothamMedium)
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.fromOffset(100, 43)

    local minus = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -100, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = C.Raised,
        BackgroundTransparency = 0.34,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = C.Sub,
        TextSize = 15,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
    }, row)
    corner(minus, 8)
    stroke(minus, 0.84)

    local value = text(row, valueText, 9, C.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    value.AnchorPoint = Vector2.new(1, 0.5)
    value.Position = UDim2.new(1, -44, 0.5, 0)
    value.Size = UDim2.fromOffset(50, 28)

    local plus = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = C.Raised,
        BackgroundTransparency = 0.34,
        BorderSizePixel = 0,
        Text = "+",
        TextColor3 = C.Sub,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
    }, row)
    corner(plus, 8)
    stroke(plus, 0.84)

    for _, button in ipairs({ minus, plus }) do
        connect(button.MouseEnter, function()
            uiHover()
            tween(button, 0.12, { BackgroundTransparency = 0.16 })
        end)
        connect(button.MouseLeave, function()
            tween(button, 0.12, { BackgroundTransparency = 0.34 })
        end)
    end

    return row, minus, value, plus
end

local speedRow, speedMinus, speedValue, speedPlus = tweakRow(5, "Playback speed", "1.00x")
local bpmRow, bpmMinus, bpmValue, bpmPlus = tweakRow(48, "Song BPM", "--")
ui.SpeedValue = speedValue
ui.BPMValue = bpmValue

local inputButton = create("TextButton", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 16, 1, -16),
    Size = UDim2.new(1, -32, 0, 38),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.32,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
}, playerPanel)
corner(inputButton, 11)
stroke(inputButton, 0.82)
ui.InputButton = inputButton

local inputIcon = icon(inputButton, "keyboard-music", 15, C.Muted, "⌨")
inputIcon.AnchorPoint = Vector2.new(0, 0.5)
inputIcon.Position = UDim2.new(0, 12, 0.5, 0)
ui.InputIcon = inputIcon

local inputLabel = text(inputButton, "PREVIEW ONLY", 8, C.Sub, Enum.Font.GothamBold)
inputLabel.Position = UDim2.fromOffset(36, 0)
inputLabel.Size = UDim2.new(1, -48, 1, 0)
ui.InputLabel = inputLabel

local mini = create("TextButton", {
    Name = "MiniPlayer",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -18, 1, -18),
    Size = UDim2.fromOffset(194, 52),
    BackgroundColor3 = C.Window2,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 50,
}, gui)
corner(mini, 15)
stroke(mini, 0.56)
ui.Mini = mini

local miniIconShell = create("Frame", {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.76,
    BorderSizePixel = 0,
    ZIndex = 51,
}, mini)
corner(miniIconShell, 11)
stroke(miniIconShell, 0.66, 1, CONFIG.Accent)

local miniIcon = icon(miniIconShell, "music-2", 16, CONFIG.Accent, "♪")
miniIcon.AnchorPoint = Vector2.new(0.5, 0.5)
miniIcon.Position = UDim2.fromScale(0.5, 0.5)

local miniTitle = text(mini, "VELORA", 9, C.Text, Enum.Font.GothamBold)
miniTitle.Position = UDim2.fromOffset(54, 8)
miniTitle.Size = UDim2.new(1, -62, 0, 16)
miniTitle.ZIndex = 51
ui.MiniTitle = miniTitle

local miniMeta = text(mini, "CLICK TO RESTORE", 7, C.Muted, Enum.Font.GothamBold)
miniMeta.Position = UDim2.fromOffset(54, 25)
miniMeta.Size = UDim2.new(1, -62, 0, 15)
miniMeta.ZIndex = 51
ui.MiniMeta = miniMeta

local function updateViewportScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    local value = math.clamp(math.min(viewport.X / 960, viewport.Y / 610) * 0.97, 0.48, 1)
    windowScale.Scale = value
end

updateViewportScale()
if workspace.CurrentCamera then
    connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateViewportScale)
end

-- drag
local dragging = false
local dragStart = nil
local dragPosition = nil

connect(topbar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        dragPosition = window.Position
    end
end)

connect(topbar.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and dragStart and dragPosition and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        window.Position = dragPosition + UDim2.fromOffset(delta.X, delta.Y)
    end
end)

local hidden = false
local function setHidden(value)
    hidden = value == true
    backdrop.Visible = not hidden
    mini.Visible = hidden
    if CONFIG.Blur then
        blur.Size = hidden and 0 or 12
    end
end

connect(minimizeButton.MouseButton1Click, function()
    uiClick()
    setHidden(true)
end)

connect(mini.MouseButton1Click, function()
    uiClick()
    setHidden(false)
end)

connect(UserInputService.InputBegan, function(input, processed)
    if not processed and input.KeyCode == CONFIG.ToggleKey then
        setHidden(not hidden)
    end
end)

local function destroyUI()
    if state.Destroyed then
        return
    end

    state.Destroyed = true
    stopConnection()

    for _, connection in ipairs(ui.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    pcall(function()
        changed:Destroy()
        notePlayed:Destroy()
    end)

    if blur and blur.Parent then
        blur:Destroy()
    end

    if gui and gui.Parent then
        gui:Destroy()
    end

    if rawget(_G, "Velora") == API then
        _G.Velora = nil
    end

    pcall(function()
        if type(getgenv) == "function" and getgenv().Velora == API then
            getgenv().Velora = nil
        end
    end)
end

connect(closeButton.MouseButton1Click, function()
    uiClick()
    destroyUI()
end)

local function categories()
    local output = { "All Songs", "Favorites", "Recent", "Queue" }
    local seen = {}

    for _, entry in ipairs(state.Registry) do
        for _, category in ipairs(entry.Categories or {}) do
            if not seen[category] then
                seen[category] = true
                table.insert(output, category)
            end
        end
    end

    return output
end

local categoryIcons = {
    ["All Songs"] = { "list-music", "≡" },
    ["Favorites"] = { "heart", "♡" },
    ["Recent"] = { "clock-3", "◷" },
    ["Queue"] = { "list-end", "☷" },
}

local function idsToEntries(ids)
    local output = {}
    for _, id in ipairs(ids) do
        local entry = getEntry(id)
        if entry then
            table.insert(output, entry)
        end
    end
    return output
end

local function entryMatchesSearch(entry)
    local query = state.Search
    if query == "" then
        return true
    end

    if contains(entry.Name, query) or contains(entry.Artist, query) then
        return true
    end

    for _, category in ipairs(entry.Categories or {}) do
        if contains(category, query) then
            return true
        end
    end

    return false
end

local function categoryEntries()
    local base = {}

    if state.Category == "Favorites" then
        for _, entry in ipairs(state.Registry) do
            if state.Favorites[entry.Id] then
                table.insert(base, entry)
            end
        end
    elseif state.Category == "Recent" then
        base = idsToEntries(state.Recent)
    elseif state.Category == "Queue" then
        base = idsToEntries(state.Queue)
    elseif state.Category == "All Songs" then
        for _, entry in ipairs(state.Registry) do
            table.insert(base, entry)
        end
    else
        for _, entry in ipairs(state.Registry) do
            for _, category in ipairs(entry.Categories or {}) do
                if category == state.Category then
                    table.insert(base, entry)
                    break
                end
            end
        end
    end

    local output = {}
    for _, entry in ipairs(base) do
        if entryMatchesSearch(entry) then
            table.insert(output, entry)
        end
    end

    return output
end

local rebuildSongs

local function selectCategory(name)
    state.Category = name
    browserTitle.Text = name

    for category, data in pairs(ui.CategoryButtons) do
        local selected = category == name
        tween(data.Button, 0.14, {
            BackgroundTransparency = selected and 0.12 or 1,
            BackgroundColor3 = selected and C.Raised or C.Panel,
        })
        recolorIcon(data.Icon, selected and CONFIG.Accent or C.Muted)
        data.Label.TextColor3 = selected and C.Text or C.Sub
        data.Indicator.Visible = selected
    end

    if rebuildSongs then
        rebuildSongs()
    end
end

local function rebuildCategories()
    for _, child in ipairs(categoryList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    table.clear(ui.CategoryButtons)

    local order = 0
    for _, name in ipairs(categories()) do
        order += 1
        local button = create("TextButton", {
            Name = "Category_" .. name,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = C.Raised,
            BackgroundTransparency = name == state.Category and 0.12 or 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
        }, categoryList)
        corner(button, 9)

        local indicator = create("Frame", {
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromOffset(2, 20),
            BackgroundColor3 = CONFIG.Accent,
            BorderSizePixel = 0,
            Visible = name == state.Category,
        }, button)
        corner(indicator, 2)

        local mapping = categoryIcons[name] or { "disc-3", "•" }
        local holder = icon(button, mapping[1], 13, name == state.Category and CONFIG.Accent or C.Muted, mapping[2])
        holder.AnchorPoint = Vector2.new(0, 0.5)
        holder.Position = UDim2.new(0, 11, 0.5, 0)

        local label = text(button, name, 9, name == state.Category and C.Text or C.Sub, Enum.Font.GothamMedium)
        label.Position = UDim2.fromOffset(34, 0)
        label.Size = UDim2.new(1, -42, 1, 0)

        ui.CategoryButtons[name] = {
            Button = button,
            Icon = holder,
            Label = label,
            Indicator = indicator,
        }

        connect(button.MouseEnter, function()
            uiHover()
            if state.Category ~= name then
                tween(button, 0.12, { BackgroundTransparency = 0.58 })
            end
        end)

        connect(button.MouseLeave, function()
            if state.Category ~= name then
                tween(button, 0.12, { BackgroundTransparency = 1 })
            end
        end)

        connect(button.MouseButton1Click, function()
            uiClick()
            selectCategory(name)
        end)
    end
end

local function makeSongCard(entry, order)
    local selected = state.CurrentEntry and state.CurrentEntry.Id == entry.Id

    local card = create("TextButton", {
        Name = "Song_" .. entry.Id,
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = selected and C.Raised or C.Panel,
        BackgroundTransparency = selected and 0.08 or 0.40,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    }, songList)
    corner(card, 12)
    local cardStroke = stroke(card, selected and 0.62 or 0.88)

    local selectedLine = create("Frame", {
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.fromOffset(2, 46),
        BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0,
        Visible = selected,
    }, card)
    corner(selectedLine, 2)

    local songGlyph = create("Frame", {
        Position = UDim2.fromOffset(10, 11),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = selected and 0.74 or 0.88,
        BorderSizePixel = 0,
    }, card)
    corner(songGlyph, 11)
    stroke(songGlyph, selected and 0.60 or 0.82, 1, CONFIG.Accent)

    local glyphIcon = icon(songGlyph, "music-2", 16, CONFIG.Accent, "♪")
    glyphIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    glyphIcon.Position = UDim2.fromScale(0.5, 0.5)

    local name = text(card, truncate(entry.Name, 25), 10, C.Text, Enum.Font.GothamSemibold)
    name.Position = UDim2.fromOffset(64, 10)
    name.Size = UDim2.new(1, -154, 0, 17)

    local artist = text(card, truncate(entry.Artist or "Unknown", 22), 8, C.Muted, Enum.Font.GothamMedium)
    artist.Position = UDim2.fromOffset(64, 28)
    artist.Size = UDim2.new(1, -154, 0, 14)

    local bpm = text(card, tostring(entry.BPM or "--") .. " BPM", 7, C.Muted, Enum.Font.GothamBold)
    bpm.Position = UDim2.fromOffset(64, 44)
    bpm.Size = UDim2.fromOffset(58, 13)

    local favorite = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -48, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)

    local favIcon = icon(favorite, "heart", 14, state.Favorites[entry.Id] and CONFIG.AccentAlt or C.Muted, state.Favorites[entry.Id] and "♥" or "♡")
    favIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    favIcon.Position = UDim2.fromScale(0.5, 0.5)

    local queue = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, card)

    local queueIcon = icon(queue, "list-plus", 14, C.Muted, "+")
    queueIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    queueIcon.Position = UDim2.fromScale(0.5, 0.5)

    connect(card.MouseEnter, function()
        uiHover()
        if not (state.CurrentEntry and state.CurrentEntry.Id == entry.Id) then
            tween(card, 0.12, { BackgroundTransparency = 0.20 })
            cardStroke.Transparency = 0.72
        end
    end)

    connect(card.MouseLeave, function()
        if not (state.CurrentEntry and state.CurrentEntry.Id == entry.Id) then
            tween(card, 0.12, { BackgroundTransparency = 0.40 })
            cardStroke.Transparency = 0.88
        end
    end)

    connect(card.MouseButton1Click, function()
        uiClick()
        API:LoadSong(entry.Id, false)
    end)

    connect(favorite.MouseButton1Click, function()
        uiClick()
        API:ToggleFavorite(entry.Id)
    end)

    connect(queue.MouseButton1Click, function()
        uiClick()
        API:AddToQueue(entry.Id)
    end)

    return card
end

rebuildSongs = function()
    for _, child in ipairs(songList:GetChildren()) do
        if not child:IsA("UIListLayout")
            and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    table.clear(ui.SongCards)

    local entries = categoryEntries()
    ui.CurrentFiltered = entries

    browserCount.Text = string.format("%d track%s", #entries, #entries == 1 and "" or "s")

    if #entries == 0 then
        local empty = create("Frame", {
            Size = UDim2.new(1, 0, 0, 120),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
        }, songList)

        local emptyIcon = icon(empty, "music", 22, C.Muted, "♪")
        emptyIcon.AnchorPoint = Vector2.new(0.5, 0)
        emptyIcon.Position = UDim2.new(0.5, 0, 0, 20)

        local emptyTitle = text(empty, "No songs here yet", 10, C.Sub, Enum.Font.GothamSemibold, Enum.TextXAlignment.Center)
        emptyTitle.Position = UDim2.fromOffset(0, 52)
        emptyTitle.Size = UDim2.new(1, 0, 0, 18)

        local emptySub = text(empty, "Try another category or search.", 8, C.Muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
        emptySub.Position = UDim2.fromOffset(0, 72)
        emptySub.Size = UDim2.new(1, 0, 0, 16)
        return
    end

    for index, entry in ipairs(entries) do
        ui.SongCards[entry.Id] = makeSongCard(entry, index)
    end
end

local function updateInputDisplay()
    local mode, connected = API:GetInputMode()
    statusText.Text = string.upper(mode)
    inputLabel.Text = string.upper(mode)
    statusDot.BackgroundColor3 = connected and C.Success or C.Warning
    recolorIcon(inputIcon, connected and C.Success or C.Muted)
end

local function updateNowPlaying(animated)
    local snap = API:GetSnapshot()
    local entry = snap.Entry

    if entry then
        local titleText = truncate(entry.Name, 27)
        local artistText = truncate(entry.Artist or "Unknown", 27)

        if animated then
            visualTitle.TextTransparency = 0.65
            visualArtist.TextTransparency = 0.65
            trackName.TextTransparency = 0.65
            tween(visualTitle, 0.16, { TextTransparency = 0 })
            tween(visualArtist, 0.16, { TextTransparency = 0 })
            tween(trackName, 0.16, { TextTransparency = 0 })
        end

        visualTitle.Text = titleText
        visualArtist.Text = artistText
        trackName.Text = titleText
        trackMeta.Text = string.format("%s  •  %s BPM  •  %d queued", artistText, tostring(snap.BPM or "--"), snap.QueueCount)
        miniTitle.Text = titleText
        miniMeta.Text = snap.Playing and (snap.Paused and "PAUSED" or "PLAYING") or "READY"
        bpmValue.Text = tostring(snap.BPM or "--")
    else
        visualTitle.Text = "Select a song"
        visualArtist.Text = "Velora Library"
        trackName.Text = "Nothing selected"
        trackMeta.Text = "Choose a song from the library"
        miniTitle.Text = "VELORA"
        miniMeta.Text = "CLICK TO RESTORE"
        bpmValue.Text = "--"
    end

    speedValue.Text = string.format("%.2fx", snap.Speed)
    recolorIcon(loopIcon, snap.Loop and CONFIG.Accent or C.Sub)
    recolorIcon(shuffleIcon, snap.Shuffle and CONFIG.Accent or C.Sub)

    loopButton.BackgroundTransparency = snap.Loop and 0.12 or 0.26
    shuffleButton.BackgroundTransparency = snap.Shuffle and 0.12 or 0.26

    local desiredIcon = snap.Playing and not snap.Paused and "pause" or "play"
    local imageChild = playIcon:FindFirstChildWhichIsA("ImageLabel")
    local textChild = playIcon:FindFirstChildWhichIsA("TextLabel")
    if imageChild and Icons[desiredIcon] then
        imageChild.Image = Icons[desiredIcon]
        imageChild:SetAttribute("LucideName", desiredIcon)
    elseif textChild then
        textChild.Text = snap.Playing and not snap.Paused and "Ⅱ" or "▶"
    end

    updateInputDisplay()
end

local function refreshAll(reason)
    if state.Destroyed then
        return
    end

    if reason == "library" then
        statSongs.Text = tostring(#state.Registry) .. " songs"
        rebuildCategories()
        rebuildSongs()
    elseif reason == "favorites" or reason == "queue" then
        rebuildCategories()
        rebuildSongs()
        updateNowPlaying(false)
    elseif reason == "selection" then
        rebuildSongs()
        updateNowPlaying(true)
    else
        updateNowPlaying(false)
    end
end

connect(searchBox:GetPropertyChangedSignal("Text"), function()
    state.Search = searchBox.Text
    rebuildSongs()
end)

connect(searchBox.Focused, function()
    searchStroke.Color = CONFIG.Accent
    searchStroke.Transparency = 0.38
    recolorIcon(searchIcon, CONFIG.Accent)
end)

connect(searchBox.FocusLost, function()
    searchStroke.Color = C.Edge
    searchStroke.Transparency = 0.78
    recolorIcon(searchIcon, C.Muted)
end)

connect(randomButton.MouseEnter, function()
    uiHover()
    tween(randomButton, 0.12, { BackgroundTransparency = 0.12 })
    recolorIcon(randomIcon, C.Text)
end)

connect(randomButton.MouseLeave, function()
    tween(randomButton, 0.12, { BackgroundTransparency = 0.28 })
    recolorIcon(randomIcon, C.Sub)
end)

connect(randomButton.MouseButton1Click, function()
    uiClick()
    local entries = categoryEntries()
    if #entries > 0 then
        local entry = entries[math.random(1, #entries)]
        API:LoadSong(entry.Id, true)
    end
end)

connect(playButton.MouseButton1Click, function()
    uiClick()
    if not state.CurrentEntry and state.Registry[1] then
        API:LoadSong(state.Registry[1].Id, false)
    end

    if state.Playing then
        API:Pause()
    else
        API:Play()
    end
end)

connect(stopButton.MouseButton1Click, function()
    uiClick()
    API:Stop()
end)

connect(loopButton.MouseButton1Click, function()
    uiClick()
    API:SetLoop(not state.Loop)
end)

connect(shuffleButton.MouseButton1Click, function()
    uiClick()
    API:SetShuffle(not state.Shuffle)
end)

connect(previousButton.MouseButton1Click, function()
    uiClick()
    if #state.Recent >= 2 then
        local previous = getEntry(state.Recent[2])
        if previous then
            API:LoadSong(previous.Id, true)
        end
    else
        API:Seek(0)
    end
end)

connect(speedMinus.MouseButton1Click, function()
    uiClick()
    API:SetSpeed(state.Speed - 0.1)
end)

connect(speedPlus.MouseButton1Click, function()
    uiClick()
    API:SetSpeed(state.Speed + 0.1)
end)

connect(bpmMinus.MouseButton1Click, function()
    uiClick()
    if state.CurrentBPM then
        API:SetBPM(state.CurrentBPM - 5)
    end
end)

connect(bpmPlus.MouseButton1Click, function()
    uiClick()
    if state.CurrentBPM then
        API:SetBPM(state.CurrentBPM + 5)
    end
end)

connect(inputButton.MouseEnter, function()
    uiHover()
    tween(inputButton, 0.12, { BackgroundTransparency = 0.18 })
end)

connect(inputButton.MouseLeave, function()
    tween(inputButton, 0.12, { BackgroundTransparency = 0.32 })
end)

connect(inputButton.MouseButton1Click, function()
    uiClick()
    if state.BoundCallback then
        return
    end
    if InputBackend.Available then
        API:SetAutoInput(not state.AutoInput)
    end
end)

local seeking = false
local function seekFromX(x)
    if progressHit.AbsoluteSize.X <= 0 then
        return
    end
    local alpha = math.clamp((x - progressHit.AbsolutePosition.X) / progressHit.AbsoluteSize.X, 0, 1)
    API:Seek(alpha)
end

connect(progressHit.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        seeking = true
        seekFromX(input.Position.X)
    end
end)

connect(progressHit.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        seeking = false
    end
end)

connect(UserInputService.InputChanged, function(input)
    if seeking and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        seekFromX(input.Position.X)
    end
end)

connect(changed.Event, refreshAll)

connect(notePlayed.Event, function(note)
    local keyName = string.lower(tostring(note or ""))
    local key = ui.PianoKeys[keyName]
    if not key then
        return
    end

    local token = (key:GetAttribute("PulseToken") or 0) + 1
    key:SetAttribute("PulseToken", token)

    tween(key, 0.045, {
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 0.02,
    }, Enum.EasingStyle.Quad)

    task.delay(0.11, function()
        if key.Parent and key:GetAttribute("PulseToken") == token then
            tween(key, 0.16, {
                BackgroundColor3 = C.Text,
                BackgroundTransparency = 0.06,
            })
        end
    end)
end)

connect(RunService.RenderStepped, function()
    if state.Destroyed then
        return
    end

    local snap = API:GetSnapshot()
    progressFill.Size = UDim2.new(snap.Progress, 0, 1, 0)
    progressThumb.Position = UDim2.new(snap.Progress, 0, 0.5, 0)
    timeLeft.Text = formatTime(snap.Position)
    timeRight.Text = formatTime(snap.Duration)

    if mini.Visible and snap.Entry then
        miniMeta.Text = snap.Playing and (snap.Paused and "PAUSED" or "PLAYING") or "READY"
    end
end)

rebuildCategories()
selectCategory("All Songs")
updateNowPlaying(false)

if state.Registry[1] then
    API:LoadSong(state.Registry[1].Id, false)
end

-- startup entrance: scale + 8px rise, no decorative blobs.
local finalPosition = window.Position
window.Position = finalPosition + UDim2.fromOffset(0, 8)
local targetScale = windowScale.Scale
windowScale.Scale = targetScale * 0.97
window.BackgroundTransparency = 0.20

tween(window, 0.24, {
    Position = finalPosition,
    BackgroundTransparency = 0.06,
})
tween(windowScale, 0.24, {
    Scale = targetScale,
})

API.UI = ui
API.State = state

function API:Show()
    setHidden(false)
end

function API:Hide()
    setHidden(true)
end

function API:Destroy()
    destroyUI()
end

_G.Velora = API
pcall(function()
    if type(getgenv) == "function" then
        getgenv().Velora = API
    end
end)

print(string.format(
    "[Velora] v%s %s loaded • %d songs • %s",
    CONFIG.Version,
    CONFIG.Codename,
    #state.Registry,
    select(1, API:GetInputMode())
))

return API
