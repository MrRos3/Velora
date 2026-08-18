--[[
    Velora v0.4.0 "Nocturne" 🥀🎹
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
    Version = "0.4.0",
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
    local registry = safeLoadTable(RAW_BASE .. "Songs.lua?velora=0.4.0")
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

                -- Aurora stops on the final note. The current selection stays
                -- visible so Play can restart it; only explicit Loop repeats it.
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
-- Aurora UI — original rounded floating-card design
-- =========================================================

local oldGui=PlayerGui:FindFirstChild("Velora")
if oldGui then oldGui:Destroy() end
local oldBlur=Lighting:FindFirstChild("VeloraBlur")
if oldBlur then oldBlur:Destroy() end

local function make(className,props,parent)
    local o=Instance.new(className)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent
    return o
end
local function radius(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 14)},o);return o end
local function edge(o,color,t,width) make("UIStroke",{Color=color or Color3.fromRGB(101,92,145),Transparency=t or .45,Thickness=width or 1},o);return o end
local function padding(o,l,r,t,b) make("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or l or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or t or 0)},o) end
local function gradient(o,a,b,rotation)
    make("UIGradient",{Color=ColorSequence.new(a,b),Rotation=rotation or 0},o)
    return o
end
local function label(parent,textValue,pos,size,font,sizePx,color)
    return make("TextLabel",{BackgroundTransparency=1,Position=pos,Size=size,Font=font or Enum.Font.Gotham,Text=textValue,TextSize=sizePx or 11,TextColor3=color or Color3.fromRGB(244,243,250),TextXAlignment=Enum.TextXAlignment.Left},parent)
end
local function animate(o,props,time)
    TweenService:Create(o,TweenInfo.new(time or .18,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play()
end
local function clock(seconds)
    seconds=math.max(0,tonumber(seconds) or 0)
    return string.format("%d:%02d",math.floor(seconds/60),math.floor(seconds%60))
end

local P={
    Ink=Color3.fromRGB(14,12,24),Surface=Color3.fromRGB(25,22,39),Card=Color3.fromRGB(34,30,51),
    Lift=Color3.fromRGB(45,39,66),Text=Color3.fromRGB(250,248,255),Sub=Color3.fromRGB(170,164,190),
    Muted=Color3.fromRGB(112,106,136),Violet=Color3.fromRGB(143,108,255),Pink=Color3.fromRGB(255,102,188),
    Cyan=Color3.fromRGB(96,220,238),Green=Color3.fromRGB(105,235,171),
}

local gui=make("ScreenGui",{Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=78,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)
local shadow=radius(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,8),Size=UDim2.fromOffset(782,462),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.56,BorderSizePixel=0},gui),28)
local window=radius(edge(gradient(make("Frame",{Name="Aurora",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(760,440),BackgroundColor3=P.Ink,BorderSizePixel=0,ClipsDescendants=true},gui),Color3.fromRGB(29,23,49),Color3.fromRGB(11,13,24),25),Color3.fromRGB(133,112,204),.38,1.2),24)

local glowA=radius(make("Frame",{Position=UDim2.fromOffset(-65,-85),Size=UDim2.fromOffset(230,230),BackgroundColor3=P.Violet,BackgroundTransparency=.83,BorderSizePixel=0},window),115)
local glowB=radius(make("Frame",{Position=UDim2.new(1,-115,1,-80),Size=UDim2.fromOffset(180,180),BackgroundColor3=P.Pink,BackgroundTransparency=.91,BorderSizePixel=0},window),90)

local header=radius(edge(gradient(make("Frame",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,64),BackgroundColor3=P.Surface,BorderSizePixel=0},window),Color3.fromRGB(59,42,92),Color3.fromRGB(29,28,49),10),Color3.fromRGB(143,119,207),.48),18)
local logo=radius(gradient(make("Frame",{Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(44,44),BackgroundColor3=P.Violet,BorderSizePixel=0},header),P.Violet,P.Pink,45),14)
local logoText=label(logo,"V",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBlack,20,P.Text);logoText.TextXAlignment=Enum.TextXAlignment.Center
label(header,"VELORA",UDim2.fromOffset(68,10),UDim2.fromOffset(190,24),Enum.Font.GothamBlack,20,P.Text)
label(header,"AURORA  •  PIANO STUDIO",UDim2.fromOffset(69,35),UDim2.fromOffset(210,14),Enum.Font.GothamBold,8,Color3.fromRGB(192,174,255))

local inputBadge=radius(edge(make("TextLabel",{Position=UDim2.new(1,-208,0,14),Size=UDim2.fromOffset(142,36),BackgroundColor3=Color3.fromRGB(30,30,47),BorderSizePixel=0,Font=Enum.Font.GothamBold,Text="●  CHECKING OUTPUT",TextSize=8,TextColor3=P.Sub},header),Color3.fromRGB(110,105,145),.5),12)
local close=radius(make("TextButton",{Position=UDim2.new(1,-52,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(49,42,65),BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="×",TextSize=18,TextColor3=P.Sub},header),12)
close.MouseEnter:Connect(function() animate(close,{BackgroundColor3=Color3.fromRGB(104,48,76),TextColor3=P.Text}) end)
close.MouseLeave:Connect(function() animate(close,{BackgroundColor3=Color3.fromRGB(49,42,65),TextColor3=P.Sub}) end)

local body=make("Frame",{Position=UDim2.fromOffset(14,90),Size=UDim2.new(1,-28,1,-104),BackgroundTransparency=1},window)
local nav=radius(edge(make("Frame",{Size=UDim2.fromOffset(148,336),BackgroundColor3=P.Surface,BackgroundTransparency=.08,BorderSizePixel=0},body),Color3.fromRGB(88,81,119),.58),18)
local browser=radius(edge(make("Frame",{Position=UDim2.fromOffset(158,0),Size=UDim2.fromOffset(326,336),BackgroundColor3=P.Surface,BackgroundTransparency=.08,BorderSizePixel=0},body),Color3.fromRGB(88,81,119),.58),18)
local playerCard=radius(edge(make("Frame",{Position=UDim2.fromOffset(494,0),Size=UDim2.fromOffset(238,336),BackgroundColor3=P.Surface,BackgroundTransparency=.04,BorderSizePixel=0},body),Color3.fromRGB(106,88,153),.5),18)

label(nav,"DISCOVER",UDim2.fromOffset(16,16),UDim2.fromOffset(116,14),Enum.Font.GothamBold,8,P.Muted)
local navList=make("Frame",{Position=UDim2.fromOffset(10,42),Size=UDim2.fromOffset(128,205),BackgroundTransparency=1},nav)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},navList)
local activeFilter="All Songs"
local searchQuery=""
local navButtons={}
local refreshList

local search=radius(edge(make("TextBox",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,38),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="⌕  Search the library",PlaceholderColor3=P.Muted,Text="",TextSize=10,TextColor3=P.Text,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},browser),Color3.fromRGB(87,78,119),.55),12)
padding(search,13,13,0,0)
local resultTitle=label(browser,"ALL SONGS",UDim2.fromOffset(16,62),UDim2.fromOffset(200,20),Enum.Font.GothamBlack,12,P.Text)
local songList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,88),Size=UDim2.new(1,-20,1,-98),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=P.Violet,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},browser)
make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},songList)
padding(songList,2,5,0,5)

label(playerCard,"NOW PLAYING",UDim2.fromOffset(16,14),UDim2.fromOffset(160,14),Enum.Font.GothamBold,8,P.Muted)
local art=radius(gradient(make("Frame",{Position=UDim2.fromOffset(16,39),Size=UDim2.fromOffset(72,72),BackgroundColor3=P.Violet,BorderSizePixel=0},playerCard),P.Violet,P.Pink,45),18)
local artGlow=radius(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(44,44),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.86,BorderSizePixel=0},art),22)
local noteLabel=label(artGlow,"♫",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBold,23,P.Text);noteLabel.TextXAlignment=Enum.TextXAlignment.Center
local nowTitle=label(playerCard,"Choose a song",UDim2.fromOffset(101,45),UDim2.fromOffset(122,38),Enum.Font.GothamBlack,14,P.Text);nowTitle.TextWrapped=true;nowTitle.TextYAlignment=Enum.TextYAlignment.Top
local nowMeta=label(playerCard,"Ready when you are",UDim2.fromOffset(101,86),UDim2.fromOffset(122,18),Enum.Font.Gotham,8,P.Sub)

local progress=radius(make("Frame",{Position=UDim2.fromOffset(16,128),Size=UDim2.fromOffset(206,6),BackgroundColor3=Color3.fromRGB(54,48,72),BorderSizePixel=0},playerCard),3)
local fill=radius(gradient(make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=P.Violet,BorderSizePixel=0},progress),P.Cyan,P.Pink,0),3)
local timeLeft=label(playerCard,"0:00",UDim2.fromOffset(16,139),UDim2.fromOffset(70,13),Enum.Font.GothamMedium,7,P.Muted)
local timeRight=label(playerCard,"0:00",UDim2.fromOffset(152,139),UDim2.fromOffset(70,13),Enum.Font.GothamMedium,7,P.Muted);timeRight.TextXAlignment=Enum.TextXAlignment.Right

local stop=radius(make("TextButton",{Position=UDim2.fromOffset(16,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="■",TextSize=12,TextColor3=P.Sub},playerCard),15)
local play=radius(edge(gradient(make("TextButton",{Position=UDim2.fromOffset(76,157),Size=UDim2.fromOffset(86,62),BackgroundColor3=P.Violet,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBlack,Text="PLAY",TextSize=11,TextColor3=P.Text},playerCard),P.Violet,P.Pink,35),Color3.new(1,1,1),.7),20)
local favorite=radius(make("TextButton",{Position=UDim2.fromOffset(172,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="♡",TextSize=20,TextColor3=P.Sub},playerCard),15)

local bpmPill=radius(make("Frame",{Position=UDim2.fromOffset(16,232),Size=UDim2.fromOffset(128,38),BackgroundColor3=P.Card,BorderSizePixel=0},playerCard),13)
label(bpmPill,"BPM",UDim2.fromOffset(12,0),UDim2.fromOffset(35,38),Enum.Font.GothamBold,8,P.Muted)
local bpm=make("TextBox",{Position=UDim2.fromOffset(52,0),Size=UDim2.fromOffset(64,38),BackgroundTransparency=1,ClearTextOnFocus=false,Font=Enum.Font.GothamBlack,Text="120",TextSize=11,TextColor3=P.Text},bpmPill)
local loop=radius(make("TextButton",{Position=UDim2.fromOffset(154,232),Size=UDim2.fromOffset(68,38),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="↻  LOOP",TextSize=8,TextColor3=P.Sub},playerCard),13)
local feedback=radius(make("TextLabel",{Position=UDim2.fromOffset(16,283),Size=UDim2.fromOffset(206,37),BackgroundColor3=Color3.fromRGB(31,29,46),BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text="Pick a song and make some magic.",TextWrapped=true,TextSize=8,TextColor3=P.Sub},playerCard),12)
padding(feedback,9,9,4,4)

local libraryCount=radius(make("Frame",{Position=UDim2.fromOffset(10,273),Size=UDim2.fromOffset(128,51),BackgroundColor3=P.Card,BorderSizePixel=0},nav),14)
label(libraryCount,"AURORA LIBRARY",UDim2.fromOffset(11,8),UDim2.fromOffset(106,12),Enum.Font.GothamBold,7,P.Muted)
local countText=label(libraryCount,tostring(#state.Registry).." SONGS",UDim2.fromOffset(11,24),UDim2.fromOffset(106,16),Enum.Font.GothamBlack,10,P.Text)

local categories={"All Songs","Favorites","Recent"}
for _,entry in ipairs(state.Registry) do
    for _,category in ipairs(entry.Categories or {}) do
        if not table.find(categories,category) then table.insert(categories,category) end
    end
end

local function chooseFilter(name)
    activeFilter=name
    resultTitle.Text=string.upper(name)
    for filter,button in pairs(navButtons) do
        local selected=filter==name
        animate(button,{BackgroundTransparency=selected and 0 or 1,TextColor3=selected and P.Text or P.Sub})
    end
    refreshList()
end

for index,name in ipairs(categories) do
    local button=radius(make("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(73,57,111),BackgroundTransparency=index==1 and 0 or 1,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.GothamBold,Text="   "..name,TextSize=9,TextColor3=index==1 and P.Text or P.Sub,TextXAlignment=Enum.TextXAlignment.Left},navList),11)
    navButtons[name]=button
    button.MouseEnter:Connect(function() if activeFilter~=name then animate(button,{BackgroundTransparency=.55}) end end)
    button.MouseLeave:Connect(function() if activeFilter~=name then animate(button,{BackgroundTransparency=1}) end end)
    button.MouseButton1Click:Connect(function() chooseFilter(name) end)
end

local function entryMatches(entry)
    local cat=activeFilter=="All Songs" or (activeFilter=="Favorites" and API:IsFavorite(entry.Id)) or (activeFilter=="Recent" and table.find(state.Recent,entry.Id)) or table.find(entry.Categories or {},activeFilter)
    local textValue=string.lower((entry.Name or "").." "..(entry.Artist or "").." "..table.concat(entry.Categories or {}," "))
    return cat and (searchQuery=="" or string.find(textValue,searchQuery,1,true))
end

local hues={
    {Color3.fromRGB(143,108,255),Color3.fromRGB(255,102,188)},
    {Color3.fromRGB(64,189,230),Color3.fromRGB(137,112,255)},
    {Color3.fromRGB(255,145,91),Color3.fromRGB(255,91,159)},
    {Color3.fromRGB(83,214,171),Color3.fromRGB(66,161,232)},
}

refreshList=function()
    for _,child in ipairs(songList:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    local shown=0
    for index,entry in ipairs(state.Registry) do
        if entryMatches(entry) then
            shown+=1
            local card=radius(edge(make("TextButton",{Size=UDim2.new(1,0,0,61),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},songList),Color3.fromRGB(86,77,117),.58),15)
            local palette=hues[(index-1)%#hues+1]
            local tile=radius(gradient(make("Frame",{Position=UDim2.fromOffset(7,7),Size=UDim2.fromOffset(47,47),BackgroundColor3=palette[1],BorderSizePixel=0},card),palette[1],palette[2],45),13)
            local glyph=label(tile,"♫",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBold,17,P.Text);glyph.TextXAlignment=Enum.TextXAlignment.Center
            label(card,entry.Name or "Untitled",UDim2.fromOffset(66,11),UDim2.new(1,-110,0,18),Enum.Font.GothamBold,10,P.Text)
            label(card,(entry.Artist or "Velora").."  •  "..tostring(entry.BPM or 120).." BPM",UDim2.fromOffset(66,32),UDim2.new(1,-110,0,14),Enum.Font.Gotham,8,P.Sub)
            local arrow=label(card,"›",UDim2.new(1,-38,0,12),UDim2.fromOffset(25,36),Enum.Font.GothamBold,21,Color3.fromRGB(188,172,255));arrow.TextXAlignment=Enum.TextXAlignment.Center
            card.MouseEnter:Connect(function() animate(card,{BackgroundColor3=P.Lift});animate(tile,{Size=UDim2.fromOffset(49,49),Position=UDim2.fromOffset(6,6)}) end)
            card.MouseLeave:Connect(function() animate(card,{BackgroundColor3=P.Card});animate(tile,{Size=UDim2.fromOffset(47,47),Position=UDim2.fromOffset(7,7)}) end)
            card.MouseButton1Click:Connect(function()
                local ok,err=API:LoadSong(entry.Id,false)
                feedback.Text=ok and "Loaded. Press the glowing Play button." or tostring(err)
            end)
        end
    end
    if shown==0 then
        local empty=label(songList,"No songs in this view  ✦",UDim2.new(),UDim2.new(1,0,0,90),Enum.Font.GothamBold,10,P.Muted)
        empty.TextXAlignment=Enum.TextXAlignment.Center
    end
end

local function render()
    local snap=API:GetSnapshot()
    local mode,connected=API:GetInputMode()
    inputBadge.Text=connected and ("●  "..string.upper(mode)) or "●  OUTPUT NEEDED"
    inputBadge.TextColor3=connected and P.Green or Color3.fromRGB(255,190,105)
    if snap.Entry then
        nowTitle.Text=snap.Entry.Name or "Untitled"
        nowMeta.Text=(snap.Entry.Artist or "Velora").."  •  "..tostring(math.floor(snap.BPM or 120)).." BPM"
        bpm.Text=tostring(math.floor(snap.BPM or 120))
        favorite.Text=API:IsFavorite(snap.Entry.Id) and "♥" or "♡"
    end
    fill.Size=UDim2.new(snap.Progress,0,1,0)
    timeLeft.Text=clock(snap.Position);timeRight.Text=clock(snap.Duration)
    play.Text=snap.Playing and (snap.Paused and "RESUME" or "PAUSE") or "PLAY"
    loop.BackgroundColor3=snap.Loop and Color3.fromRGB(84,61,137) or P.Card
    loop.TextColor3=snap.Loop and P.Text or P.Sub
end

search:GetPropertyChangedSignal("Text"):Connect(function() searchQuery=string.lower(search.Text);refreshList() end)
play.MouseButton1Click:Connect(function()
    local snap=API:GetSnapshot()
    if snap.Playing and not snap.Paused then API:Pause();feedback.Text="Paused in the moonlight."
    else local ok,err=API:Play();feedback.Text=ok and "Aurora is playing into the game  ✦" or (tostring(err).." — click the piano once.") end
    render()
end)
stop.MouseButton1Click:Connect(function() API:Stop();feedback.Text="Stopped. The song is ready to restart.";render() end)
favorite.MouseButton1Click:Connect(function() if state.CurrentEntry then API:ToggleFavorite(state.CurrentEntry.Id);refreshList();render() end end)
loop.MouseButton1Click:Connect(function() API:SetLoop(not state.Loop);render() end)
bpm.FocusLost:Connect(function() local value=API:SetBPM(tonumber(bpm.Text));feedback.Text=value and ("Tempo set to "..math.floor(value).." BPM.") or "Choose a song first.";render() end)

API.Changed:Connect(function(reason)
    if reason=="finished" then feedback.Text="Song complete  ✦  Autoplay stopped."
    elseif reason=="input-error" then feedback.Text="Input was rejected. Click the in-game piano, then retry."
    elseif reason=="input-required" then feedback.Text="This executor has no compatible piano output."
    elseif reason=="selection" then animate(art,{Rotation=3});task.delay(.15,function() if art.Parent then animate(art,{Rotation=0}) end end) end
    render()
end)
API.NotePlayed:Connect(function(note)
    feedback.Text="Playing  "..tostring(note).."  •  Aurora output active"
    animate(play,{Size=UDim2.fromOffset(90,66),Position=UDim2.fromOffset(74,155)},.08)
    task.delay(.09,function() if play.Parent then animate(play,{Size=UDim2.fromOffset(86,62),Position=UDim2.fromOffset(76,157)},.12) end end)
end)

local dragging=false
local dragStart,startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=input.Position;startPos=window.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local delta=input.Position-dragStart;window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y);shadow.Position=UDim2.new(window.Position.X.Scale,window.Position.X.Offset,window.Position.Y.Scale,window.Position.Y.Offset+8) end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
UserInputService.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end)
close.MouseButton1Click:Connect(function() API:Stop();gui:Destroy() end)

local renderConnection=RunService.RenderStepped:Connect(function() if gui.Parent then render() end end)
gui.AncestryChanged:Connect(function(_,parent) if not parent and renderConnection then renderConnection:Disconnect() end end)

API.UI={Gui=gui,Window=window}
API.State=state
function API:Show() gui.Enabled=true end
function API:Hide() gui.Enabled=false end
function API:Destroy() API:Stop();gui:Destroy() end

refreshList()
if state.Registry[1] and not state.CurrentEntry then API:LoadSong(state.Registry[1].Id,false) end
render()
window.Size=UDim2.fromOffset(710,400);shadow.Size=UDim2.fromOffset(732,422)
animate(window,{Size=UDim2.fromOffset(760,440)},.3);animate(shadow,{Size=UDim2.fromOffset(782,462)},.3)

_G.Velora=API
pcall(function() if type(getgenv)=="function" then getgenv().Velora=API end end)
return API
