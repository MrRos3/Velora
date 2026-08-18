--[[
    Velora v0.3.2 "Nocturne" 🥀🎹
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
    Version = "0.3.2",
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
    Name = "Preview Only",
    Available = false,
    Send = nil,
}

local keypressFn = findGlobal("keypress")
local keyreleaseFn = findGlobal("keyrelease")
local keytapFn = findGlobal("keytap")
local virtualInput = nil

pcall(function()
    virtualInput = game:GetService("VirtualInputManager")
end)

local function sendExecutorKey(note)
    local vk, needsShift = keyToVk(note)
    if not vk then
        return false
    end

    if type(keytapFn) == "function" then
        return pcall(keytapFn, vk)
    end

    if type(keypressFn) ~= "function" or type(keyreleaseFn) ~= "function" then
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

local function sendVirtualKey(note)
    if not virtualInput then
        return false
    end

    local keyCode, needsShift = keyToEnum(note)
    if not keyCode then
        return false
    end

    local ok = pcall(function()
        if needsShift then
            virtualInput:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        end
        virtualInput:SendKeyEvent(true, keyCode, false, game)
        task.delay(CONFIG.InputHold, function()
            pcall(function()
                virtualInput:SendKeyEvent(false, keyCode, false, game)
                if needsShift then
                    virtualInput:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end
            end)
        end)
    end)
    return ok
end

local hasExecutorInput = type(keytapFn) == "function"
    or (type(keypressFn) == "function" and type(keyreleaseFn) == "function")

if hasExecutorInput or virtualInput then
    InputBackend.Name = virtualInput and "Roblox Input" or "Executor Input"
    InputBackend.Available = true
    InputBackend.Send = function(note)
        -- VirtualInputManager targets the Roblox client directly. Some executors
        -- expose key APIs that return successfully without forwarding to the game.
        if virtualInput and sendVirtualKey(note) then
            return true
        end
        if hasExecutorInput then
            return sendExecutorKey(note)
        end
        return false
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
    local registry = safeLoadTable(RAW_BASE .. "Songs.lua?velora=0.3.2")
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
        local sent = InputBackend.Send(note)
        if not sent then
            stopConnection()
            state.Playing = false
            state.Paused = false
            state.AutoInput = false
            emit("input-error")
            warn("[Velora] Piano output rejected a key; playback stopped instead of continuing silently")
        end
        return sent
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
    local focused = UserInputService:GetFocusedTextBox()
    if focused then
        focused:ReleaseFocus()
        task.wait()
    end

    if not state.Timeline or #state.Timeline.Events == 0 then
        return false, "No playable notes are loaded"
    end

    local _, connected = self:GetInputMode()
    if not connected then
        state.Playing = false
        state.Paused = false
        emit("input-required")
        warn("[Velora] Playback needs keyboard input support or Velora:BindPiano(callback)")
        return false, "No piano output is connected"
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
-- Compact Velora UI
-- =========================================================

local oldGui = PlayerGui:FindFirstChild("Velora")
if oldGui then oldGui:Destroy() end
local oldBlur = Lighting:FindFirstChild("VeloraBlur")
if oldBlur then oldBlur:Destroy() end

local function inst(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(object, radius)
    inst("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, object)
    return object
end

local function outline(object, color, transparency)
    inst("UIStroke", { Color = color or Color3.fromRGB(66, 71, 91), Transparency = transparency or 0 }, object)
    return object
end

local function pad(object, left, right, top, bottom)
    inst("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or top or 0),
    }, object)
end

local gui = inst("ScreenGui", {
    Name = "Velora", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 78,
}, PlayerGui)

local window = round(outline(inst("Frame", {
    Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(650, 360),
    BackgroundColor3 = Color3.fromRGB(22, 22, 28), BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui), Color3.fromRGB(77, 80, 99), 0.2), 8)

local top = inst("Frame", {
    Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = Color3.fromRGB(45, 48, 62),
    BorderSizePixel = 0,
}, window)
round(top, 8)
inst("Frame", {
    Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 8),
    BackgroundColor3 = top.BackgroundColor3, BorderSizePixel = 0,
}, top)

inst("TextLabel", {
    Position = UDim2.fromOffset(18, 7), Size = UDim2.fromOffset(250, 30),
    BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "VELORA",
    TextSize = 25, TextColor3 = Color3.fromRGB(245, 245, 250),
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)
inst("TextLabel", {
    Position = UDim2.fromOffset(19, 34), Size = UDim2.fromOffset(280, 13),
    BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
    Text = "PIANO PLAYER  •  NOCTURNE 0.3.2", TextSize = 8,
    TextColor3 = Color3.fromRGB(174, 165, 255), TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local inputBadge = round(outline(inst("TextLabel", {
    Position = UDim2.new(1, -190, 0, 13), Size = UDim2.fromOffset(130, 29),
    BackgroundColor3 = Color3.fromRGB(35, 37, 48), BorderSizePixel = 0,
    Font = Enum.Font.GothamBold, Text = "●  CHECKING INPUT", TextSize = 8,
    TextColor3 = Color3.fromRGB(204, 207, 220),
}, top), Color3.fromRGB(85, 88, 106), 0.35), 6)

local close = round(inst("TextButton", {
    Position = UDim2.new(1, -45, 0, 13), Size = UDim2.fromOffset(29, 29),
    BackgroundColor3 = Color3.fromRGB(35, 37, 48), BorderSizePixel = 0,
    Font = Enum.Font.GothamBold, Text = "×", TextSize = 17,
    TextColor3 = Color3.fromRGB(210, 212, 222), AutoButtonColor = false,
}, top), 6)

local body = inst("Frame", {
    Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 1, -54),
    BackgroundTransparency = 1,
}, window)

local left = inst("Frame", {
    Size = UDim2.fromOffset(128, 306), BackgroundColor3 = Color3.fromRGB(27, 27, 34),
    BorderSizePixel = 0,
}, body)
local center = inst("Frame", {
    Position = UDim2.fromOffset(128, 0), Size = UDim2.fromOffset(300, 306),
    BackgroundColor3 = Color3.fromRGB(22, 22, 28), BorderSizePixel = 0,
}, body)
local right = inst("Frame", {
    Position = UDim2.fromOffset(428, 0), Size = UDim2.fromOffset(222, 306),
    BackgroundColor3 = Color3.fromRGB(27, 27, 34), BorderSizePixel = 0,
}, body)
inst("Frame", { Position=UDim2.fromOffset(127,0), Size=UDim2.fromOffset(1,306), BackgroundColor3=Color3.fromRGB(56,58,72), BorderSizePixel=0 }, body)
inst("Frame", { Position=UDim2.fromOffset(427,0), Size=UDim2.fromOffset(1,306), BackgroundColor3=Color3.fromRGB(56,58,72), BorderSizePixel=0 }, body)

inst("TextLabel", {
    Position=UDim2.fromOffset(12,12), Size=UDim2.fromOffset(104,16), BackgroundTransparency=1,
    Font=Enum.Font.GothamBold, Text="LIBRARY", TextSize=9, TextColor3=Color3.fromRGB(140,143,162),
    TextXAlignment=Enum.TextXAlignment.Left,
}, left)

local navHolder=inst("Frame",{Position=UDim2.fromOffset(8,35),Size=UDim2.fromOffset(112,190),BackgroundTransparency=1},left)
inst("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},navHolder)
local activeFilter="All Songs"
local searchQuery=""
local navButtons={}

local searchBox=round(inst("TextBox",{
    Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(276,30),
    BackgroundColor3=Color3.fromRGB(39,40,51),BorderSizePixel=0,ClearTextOnFocus=false,
    PlaceholderText="Search songs...",PlaceholderColor3=Color3.fromRGB(133,136,154),
    Text="",TextSize=10,TextColor3=Color3.fromRGB(242,242,247),Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left,
},center),6)
pad(searchBox,10,10,0,0)

local list=inst("ScrollingFrame",{
    Position=UDim2.fromOffset(10,51),Size=UDim2.fromOffset(280,246),
    BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
    ScrollBarImageColor3=Color3.fromRGB(139,124,255),CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
},center)
inst("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},list)
pad(list,0,4,0,4)

inst("TextLabel",{
    Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(190,16),BackgroundTransparency=1,
    Font=Enum.Font.GothamBold,Text="NOW PLAYING",TextSize=9,
    TextColor3=Color3.fromRGB(140,143,162),TextXAlignment=Enum.TextXAlignment.Left,
},right)

local songTitle=inst("TextLabel",{
    Position=UDim2.fromOffset(14,42),Size=UDim2.fromOffset(194,36),BackgroundTransparency=1,
    Font=Enum.Font.GothamBold,Text="Choose a song",TextSize=16,TextColor3=Color3.fromRGB(245,245,250),
    TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
},right)
local songMeta=inst("TextLabel",{
    Position=UDim2.fromOffset(14,79),Size=UDim2.fromOffset(194,18),BackgroundTransparency=1,
    Font=Enum.Font.Gotham,Text="Nothing selected",TextSize=9,TextColor3=Color3.fromRGB(148,151,169),
    TextXAlignment=Enum.TextXAlignment.Left,
},right)

local progressBack=round(inst("Frame",{
    Position=UDim2.fromOffset(14,111),Size=UDim2.fromOffset(194,5),
    BackgroundColor3=Color3.fromRGB(53,55,67),BorderSizePixel=0,
},right),3)
local progressFill=round(inst("Frame",{
    Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(139,124,255),BorderSizePixel=0,
},progressBack),3)

local play=round(inst("TextButton",{
    Position=UDim2.fromOffset(75,135),Size=UDim2.fromOffset(72,38),
    BackgroundColor3=Color3.fromRGB(139,124,255),BorderSizePixel=0,
    Font=Enum.Font.GothamBold,Text="PLAY",TextSize=11,TextColor3=Color3.new(1,1,1),
    AutoButtonColor=false,
},right),7)
local stop=round(inst("TextButton",{
    Position=UDim2.fromOffset(14,135),Size=UDim2.fromOffset(52,38),
    BackgroundColor3=Color3.fromRGB(48,50,62),BorderSizePixel=0,
    Font=Enum.Font.GothamBold,Text="STOP",TextSize=9,TextColor3=Color3.fromRGB(211,213,224),
    AutoButtonColor=false,
},right),7)
local fav=round(inst("TextButton",{
    Position=UDim2.fromOffset(156,135),Size=UDim2.fromOffset(52,38),
    BackgroundColor3=Color3.fromRGB(48,50,62),BorderSizePixel=0,
    Font=Enum.Font.GothamBold,Text="♡",TextSize=18,TextColor3=Color3.fromRGB(211,213,224),
    AutoButtonColor=false,
},right),7)

local bpmLabel=inst("TextLabel",{
    Position=UDim2.fromOffset(14,194),Size=UDim2.fromOffset(60,28),BackgroundTransparency=1,
    Font=Enum.Font.GothamBold,Text="BPM",TextSize=9,TextColor3=Color3.fromRGB(148,151,169),
    TextXAlignment=Enum.TextXAlignment.Left,
},right)
local bpmBox=round(inst("TextBox",{
    Position=UDim2.fromOffset(73,194),Size=UDim2.fromOffset(70,28),
    BackgroundColor3=Color3.fromRGB(45,47,58),BorderSizePixel=0,ClearTextOnFocus=false,
    Font=Enum.Font.GothamBold,Text="120",TextSize=10,TextColor3=Color3.fromRGB(239,240,245),
},right),6)
local loop=round(inst("TextButton",{
    Position=UDim2.fromOffset(151,194),Size=UDim2.fromOffset(57,28),
    BackgroundColor3=Color3.fromRGB(45,47,58),BorderSizePixel=0,
    Font=Enum.Font.GothamBold,Text="LOOP",TextSize=8,TextColor3=Color3.fromRGB(174,176,190),
    AutoButtonColor=false,
},right),6)
local feedback=round(inst("TextLabel",{
    Position=UDim2.fromOffset(14,239),Size=UDim2.fromOffset(194,50),
    BackgroundColor3=Color3.fromRGB(36,38,48),BorderSizePixel=0,
    Font=Enum.Font.Gotham,Text="Select a song, then press Play.",TextWrapped=true,
    TextSize=9,TextColor3=Color3.fromRGB(160,163,181),
},right),7)
pad(feedback,9,9,6,6)

local refreshList
local categories={"All Songs","Favorites","Recent"}
for _,entry in ipairs(state.Registry) do
    for _,category in ipairs(entry.Categories or {}) do
        if not table.find(categories,category) then table.insert(categories,category) end
    end
end

local function setFilter(name)
    activeFilter=name
    for filter,button in pairs(navButtons) do
        button.BackgroundTransparency=filter==name and 0 or 1
        button.TextColor3=filter==name and Color3.new(1,1,1) or Color3.fromRGB(166,169,185)
    end
    refreshList()
end

for index,name in ipairs(categories) do
    local button=round(inst("TextButton",{
        Size=UDim2.new(1,0,0,29),BackgroundColor3=Color3.fromRGB(62,60,83),
        BackgroundTransparency=index==1 and 0 or 1,BorderSizePixel=0,AutoButtonColor=false,
        Font=Enum.Font.GothamMedium,Text="  "..name,TextSize=9,
        TextColor3=index==1 and Color3.new(1,1,1) or Color3.fromRGB(166,169,185),
        TextXAlignment=Enum.TextXAlignment.Left,
    },navHolder),6)
    navButtons[name]=button
    button.MouseButton1Click:Connect(function() setFilter(name) end)
end

local function matches(entry)
    local categoryMatch=activeFilter=="All Songs"
        or (activeFilter=="Favorites" and API:IsFavorite(entry.Id))
        or (activeFilter=="Recent" and table.find(state.Recent,entry.Id))
        or table.find(entry.Categories or {},activeFilter)
    local haystack=string.lower((entry.Name or "").." "..(entry.Artist or ""))
    return categoryMatch and (searchQuery=="" or string.find(haystack,searchQuery,1,true))
end

refreshList=function()
    for _,child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
    for _,entry in ipairs(state.Registry) do
        if matches(entry) then
            local card=round(outline(inst("TextButton",{
                Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(38,39,49),
                BorderSizePixel=0,AutoButtonColor=false,Text="",
            },list),Color3.fromRGB(67,69,84),0.5),7)
            inst("TextLabel",{
                Position=UDim2.fromOffset(12,7),Size=UDim2.new(1,-65,0,17),BackgroundTransparency=1,
                Font=Enum.Font.GothamBold,Text=entry.Name or "Untitled",TextSize=10,
                TextColor3=Color3.fromRGB(243,243,248),TextXAlignment=Enum.TextXAlignment.Left,
            },card)
            inst("TextLabel",{
                Position=UDim2.fromOffset(12,25),Size=UDim2.new(1,-65,0,14),BackgroundTransparency=1,
                Font=Enum.Font.Gotham,Text=(entry.Artist or "Unknown").."  •  "..tostring(entry.BPM or 120).." BPM",
                TextSize=8,TextColor3=Color3.fromRGB(143,146,164),TextXAlignment=Enum.TextXAlignment.Left,
            },card)
            inst("TextLabel",{
                Position=UDim2.new(1,-42,0,9),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,
                Font=Enum.Font.GothamBold,Text="›",TextSize=18,TextColor3=Color3.fromRGB(154,146,235),
            },card)
            card.MouseButton1Click:Connect(function()
                local ok,err=API:LoadSong(entry.Id,false)
                feedback.Text=ok and "Ready. Press Play to send notes into the game." or tostring(err)
            end)
        end
    end
end

local function render()
    local snap=API:GetSnapshot()
    local mode,connected=API:GetInputMode()
    inputBadge.Text=connected and ("●  "..string.upper(mode)) or "●  NO PIANO OUTPUT"
    inputBadge.TextColor3=connected and Color3.fromRGB(103,232,163) or Color3.fromRGB(255,190,105)
    if snap.Entry then
        songTitle.Text=snap.Entry.Name or "Untitled"
        songMeta.Text=(snap.Entry.Artist or "Unknown").."  •  "..tostring(snap.BPM or 120).." BPM"
        bpmBox.Text=tostring(math.floor(snap.BPM or 120))
        fav.Text=API:IsFavorite(snap.Entry.Id) and "♥" or "♡"
    end
    progressFill.Size=UDim2.new(snap.Progress,0,1,0)
    play.Text=snap.Playing and (snap.Paused and "RESUME" or "PAUSE") or "PLAY"
    loop.BackgroundColor3=snap.Loop and Color3.fromRGB(92,78,155) or Color3.fromRGB(45,47,58)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchQuery=string.lower(searchBox.Text)
    refreshList()
end)
play.MouseButton1Click:Connect(function()
    local snap=API:GetSnapshot()
    if snap.Playing and not snap.Paused then API:Pause(); feedback.Text="Paused."
    else
        local ok,err=API:Play()
        feedback.Text=ok and "Sending notes to the game…" or (tostring(err).." — click the piano once, then retry.")
    end
    render()
end)
stop.MouseButton1Click:Connect(function() API:Stop();feedback.Text="Stopped.";render() end)
fav.MouseButton1Click:Connect(function()
    if state.CurrentEntry then API:ToggleFavorite(state.CurrentEntry.Id);refreshList();render() end
end)
loop.MouseButton1Click:Connect(function() API:SetLoop(not state.Loop);render() end)
bpmBox.FocusLost:Connect(function()
    local bpm=API:SetBPM(tonumber(bpmBox.Text))
    feedback.Text=bpm and ("BPM set to "..math.floor(bpm)) or "Choose a song first."
    render()
end)

API.Changed:Connect(function(reason)
    if reason=="input-error" then
        feedback.Text="The game rejected keyboard input. Click the piano in-game once, then press Play."
    elseif reason=="input-required" then
        feedback.Text="No keyboard backend is available in this executor."
    elseif reason=="finished" then
        feedback.Text="Song finished."
    end
    render()
end)
API.NotePlayed:Connect(function(note)
    feedback.Text="Playing note  "..tostring(note)
end)

local dragging=false
local dragStart,startPosition
top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true;dragStart=input.Position;startPosition=window.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        window.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
UserInputService.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end
end)

close.MouseButton1Click:Connect(function() API:Stop();gui:Destroy() end)
RunService.RenderStepped:Connect(function() if gui.Parent then render() end end)

API.UI={Gui=gui,Window=window}
API.State=state
function API:Show() gui.Enabled=true end
function API:Hide() gui.Enabled=false end
function API:Destroy() API:Stop();gui:Destroy() end

refreshList()
if state.Registry[1] and not state.CurrentEntry then API:LoadSong(state.Registry[1].Id,false) end
render()
window.Size=UDim2.fromOffset(610,330)
TweenService:Create(window,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(650,360)}):Play()

_G.Velora=API
pcall(function() if type(getgenv)=="function" then getgenv().Velora=API end end)
return API
