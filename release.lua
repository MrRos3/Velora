--[[
    Velora v0.10.2 "Nova"
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
    Version = "0.10.2",
    Codename = "Nova",
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(164, 112, 255),
    AccentAlt = Color3.fromRGB(255, 113, 191),
    ClickSound = "rbxassetid://4307186075",
    HoverSound = "rbxassetid://408524543",
    UiSounds = true,
    Blur = true,
    AutoInput = true,
    InputHold = 0.015,
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
        Font = font or Enum.Font.BuilderSans,
        TextXAlignment = alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function icon(parent, name, size, color, fallback)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(size, size),
        ZIndex = parent:IsA("GuiObject") and (parent.ZIndex + 1) or 1,
    }, parent)

    local asset = Icons[name]
    if type(asset) == "table" then
        asset = asset.Image or asset.AssetId or asset[1]
    end
    if type(asset) == "string" and asset ~= "" then
        local ok, image = pcall(function()
            local iconImage = create("ImageLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                Image = asset,
                ImageColor3 = color or C.Text,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = holder.ZIndex,
            }, holder)
            iconImage:SetAttribute("LucideName", name)
            holder:SetAttribute("IconType", "image")
            holder:SetAttribute("IconName", name)
            return iconImage
        end)
        if ok and image then
            return holder, image
        end
    end

    local label = text(holder, fallback or "", math.max(10, size - 1), color or C.Text, Enum.Font.BuilderSansBold, Enum.TextXAlignment.Center)
    label.Size = UDim2.fromScale(1, 1)
    label.ZIndex = holder.ZIndex
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
            -- Bar lines are visual separators. Exact rests are encoded as "-".
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

local VK_SHIFTED = {
    ["!"] = 0x31, ["@"] = 0x32, ["#"] = 0x33, ["$"] = 0x34,
    ["%"] = 0x35, ["^"] = 0x36, ["&"] = 0x37, ["*"] = 0x38, ["("] = 0x39,
}

local ENUM_SHIFTED = {
    ["!"] = Enum.KeyCode.One, ["@"] = Enum.KeyCode.Two, ["#"] = Enum.KeyCode.Three,
    ["$"] = Enum.KeyCode.Four, ["%"] = Enum.KeyCode.Five, ["^"] = Enum.KeyCode.Six,
    ["&"] = Enum.KeyCode.Seven, ["*"] = Enum.KeyCode.Eight, ["("] = Enum.KeyCode.Nine,
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

    if VK_SHIFTED[note] then
        return VK_SHIFTED[note], true
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

    if ENUM_SHIFTED[note] then
        return ENUM_SHIFTED[note], true
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

local function partitionNotes(notes, mapper)
    local plain, shifted = {}, {}
    for _, note in ipairs(notes or {}) do
        local code, needsShift = mapper(note)
        if code then
            table.insert(needsShift and shifted or plain, code)
        end
    end
    return plain, shifted
end

local function sendExecutorNotes(notes)
    local plain, shifted = partitionNotes(notes, keyToVk)
    if #plain + #shifted == 0 then
        return false
    end

    if type(keypressFn) ~= "function" or type(keyreleaseFn) ~= "function" then
        if type(keytapFn) ~= "function" then
            return false
        end
        local ok = true
        for _, code in ipairs(plain) do
            ok = pcall(keytapFn, code) and ok
        end
        for _, code in ipairs(shifted) do
            ok = pcall(keytapFn, code) and ok
        end
        return ok
    end

    return pcall(function()
        for _, code in ipairs(plain) do
            keypressFn(code)
        end
        if #shifted > 0 then
            keypressFn(0x10)
            for _, code in ipairs(shifted) do
                keypressFn(code)
            end
        end

        task.delay(CONFIG.InputHold, function()
            pcall(function()
                for index = #shifted, 1, -1 do
                    keyreleaseFn(shifted[index])
                end
                if #shifted > 0 then
                    keyreleaseFn(0x10)
                end
                for index = #plain, 1, -1 do
                    keyreleaseFn(plain[index])
                end
            end)
        end)
    end)
end

local function sendVirtualNotes(notes)
    if not virtualInput then
        return false
    end

    local plain, shifted = partitionNotes(notes, keyToEnum)
    if #plain + #shifted == 0 then
        return false
    end

    return pcall(function()
        for _, keyCode in ipairs(plain) do
            virtualInput:SendKeyEvent(true, keyCode, false, game)
        end
        if #shifted > 0 then
            virtualInput:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            for _, keyCode in ipairs(shifted) do
                virtualInput:SendKeyEvent(true, keyCode, false, game)
            end
        end

        task.delay(CONFIG.InputHold, function()
            pcall(function()
                for index = #shifted, 1, -1 do
                    virtualInput:SendKeyEvent(false, shifted[index], false, game)
                end
                if #shifted > 0 then
                    virtualInput:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end
                for index = #plain, 1, -1 do
                    virtualInput:SendKeyEvent(false, plain[index], false, game)
                end
            end)
        end)
    end)
end

local hasExecutorInput = type(keytapFn) == "function"
    or (type(keypressFn) == "function" and type(keyreleaseFn) == "function")

if hasExecutorInput or virtualInput then
    InputBackend.Name = virtualInput and "Roblox Input" or "Executor Input"
    InputBackend.Available = true
    InputBackend.SendMany = function(notes)
        -- Send each chord as one event so shifted black notes cannot leak into
        -- neighboring lowercase notes.
        if virtualInput and sendVirtualNotes(notes) then
            return true
        end
        if hasExecutorInput then
            return sendExecutorNotes(notes)
        end
        return false
    end
    InputBackend.Send = function(note)
        return InputBackend.SendMany({ note })
    end
end

-- =========================================================
-- Registry and playback state
-- =========================================================

local FALLBACK_SONGS = {
    {Id="anlatamam-kara-sevda",Name="Anlatamam (Kara Sevda OST)",Artist="Toygar Işıklı",BPM=50,Categories={"Famous","Soundtrack","Turkish","Emotional","Complete"},File="songs/AnlatamamKaraSevda.lua"},
    {Id="love-story-indila",Name="Love Story",Artist="Indila",BPM=90,Categories={"Famous","TikTok","Pop","Romantic","Complete"},File="songs/LoveStoryIndila.lua"},
    {Id="ievan-polkka",Name="Ievan Polkka",Artist="Traditional Finnish",BPM=110,Categories={"Famous","TikTok","Folk","Upbeat","Complete"},File="songs/IevanPolkka.lua"},
    {Id="kamado-tanjiro-no-uta",Name="Kamado Tanjiro no Uta",Artist="Go Shiina feat. Nami Nakagawa",BPM=151,Categories={"Famous","Anime","Demon Slayer","Emotional","Complete"},File="songs/KamadoTanjiroNoUta.lua"},
    {Id="erika",Name="Erika",Artist="Herms Niel",BPM=112,Categories={"Famous","Historical","German","March","Complete"},File="songs/Erika.lua"},
    {Id="mountain-king",Name="In the Hall of the Mountain King",Artist="Edvard Grieg",BPM=138,Categories={"Famous","TikTok Classics","Classical","Dramatic","Complete"},File="songs/MountainKing.lua"},
    {Id="eine-kleine-nachtmusik",Name="Eine kleine Nachtmusik — Allegro",Artist="W. A. Mozart",BPM=144,Categories={"Famous","TikTok Classics","Classical","Upbeat","Complete"},File="songs/EineKleineNachtmusik.lua"},
    {Id="dies-irae",Name="Dies Irae — Requiem",Artist="W. A. Mozart",BPM=180,Categories={"Famous","TikTok Classics","Classical","Dark","Complete"},File="songs/DiesIrae.lua"},
    {Id="fur-elise",Name="Für Elise",Artist="L. van Beethoven",BPM=72,Categories={"Famous","Classical","Romantic","Complete"},File="songs/FurElise.lua"},
    {Id="moonlight-sonata",Name="Moonlight Sonata — Adagio",Artist="L. van Beethoven",BPM=60,Categories={"Famous","Classical","Dark","Complete"},File="songs/MoonlightSonata.lua"},
    {Id="turkish-march",Name="Turkish March",Artist="W. A. Mozart",BPM=126,Categories={"Famous","Classical","Upbeat","Complete"},File="songs/TurkishMarch.lua"},
    {Id="clair-de-lune",Name="Clair de Lune",Artist="Claude Debussy",BPM=60,Categories={"Famous","Classical","Dreamy","Complete"},File="songs/ClairDeLune.lua"},
    {Id="canon-in-d",Name="Canon in D",Artist="Johann Pachelbel",BPM=55,Categories={"Famous","Classical","Wedding","Complete"},File="songs/CanonInD.lua"},
    {Id="nocturne-op9",Name="Nocturne Op. 9 No. 2",Artist="Frédéric Chopin",BPM=66,Categories={"Famous","Classical","Romantic","Complete"},File="songs/NocturneOp9.lua"},
    {Id="gymnopedie",Name="Gymnopédie No. 1",Artist="Erik Satie",BPM=60,Categories={"Famous","Classical","Calm","Complete"},File="songs/Gymnopedie.lua"},
    {Id="bach-prelude",Name="Prelude in C Major",Artist="J. S. Bach",BPM=60,Categories={"Famous","Classical","Study","Complete"},File="songs/BachPrelude.lua"},
    {Id="minute-waltz",Name="Minute Waltz",Artist="Frédéric Chopin",BPM=240,Categories={"Famous","Classical","Fast","Complete"},File="songs/MinuteWaltz.lua"},
    {Id="fantaisie-impromptu",Name="Fantaisie-Impromptu",Artist="Frédéric Chopin",BPM=168,Categories={"Famous","Classical","Virtuoso","Complete"},File="songs/FantaisieImpromptu.lua"},
    {Id="pathetique-adagio",Name="Pathétique — Adagio Cantabile",Artist="L. van Beethoven",BPM=36,Categories={"Famous","Classical","Emotional","Complete"},File="songs/PathetiqueAdagio.lua"},
    {Id="mozart-k545-allegro",Name="Piano Sonata K.545 — Allegro",Artist="W. A. Mozart",BPM=132,Categories={"Famous","Classical","Upbeat","Complete"},File="songs/MozartSonataK545.lua"},
    {Id="ode-to-joy",Name="Ode to Joy",Artist="L. van Beethoven",BPM=100,Categories={"Famous","Classical","Starter","Complete"},File="songs/OdeToJoy.lua"}
}

local function loadRegistry()
    local registry = safeLoadTable(RAW_BASE .. "Songs.lua?velora=0.10.2")
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
    EntryById = {},
    SongCache = {},
    CurrentEntry = nil,
    CurrentSong = nil,
    SelectedEntryId = nil,
    PendingEntryId = nil,
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
    UIConnections = {},
    Cleaning = false,
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

local function rebuildEntryIndex()
    table.clear(state.EntryById)
    for _, entry in ipairs(state.Registry) do
        state.EntryById[entry.Id] = entry
    end
end

rebuildEntryIndex()

local function getEntry(id)
    return state.EntryById[id]
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

local function noteOutputGroup(notes)
    for _, note in ipairs(notes or {}) do
        notePlayed:Fire(note)
    end

    if type(state.BoundCallback) == "function" then
        local ok = true
        for _, note in ipairs(notes or {}) do
            local sent, err = pcall(state.BoundCallback, note)
            if not sent then
                warn("[Velora] piano callback failed:", err)
                ok = false
            end
        end
        return ok
    end

    if state.AutoInput and InputBackend.Available and InputBackend.SendMany then
        local sent = InputBackend.SendMany(notes)
        if not sent then
            stopConnection()
            state.Playing = false
            state.Paused = false
            state.AutoInput = false
            emit("input-error")
            warn("[Velora] Piano output rejected a chord; playback stopped instead of continuing silently")
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
        rebuildEntryIndex()
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
    state.EntryById[entry.Id] = entry
    emit("library")
    return true
end

function API:SelectSong(id)
    local entry = getEntry(id)
    if not entry then
        return false, "Unknown song: " .. tostring(id)
    end

    state.SelectedEntryId = entry.Id

    if state.Playing then
        if state.CurrentEntry and state.CurrentEntry.Id == entry.Id then
            state.PendingEntryId = nil
            emit("selection-focus")
            return true, "current"
        end

        state.PendingEntryId = entry.Id
        emit("pending-selection")
        return true, "pending"
    end

    state.PendingEntryId = nil
    return self:LoadSong(entry.Id, false)
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
    state.SelectedEntryId = entry.Id
    state.PendingEntryId = nil
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
            noteOutputGroup(event.Notes)
            state.NextEvent += 1
        end

        if state.Position >= state.Timeline.Duration then
            if state.Loop then
                state.Position = 0
                state.NextEvent = 1
                emit("looped")
            else
                local pendingId = state.PendingEntryId
                stopConnection()
                state.Playing = false
                state.Paused = false
                state.Position = state.Timeline.Duration
                emit("finished")

                -- Encore never autoplays another song. A song picked during
                -- playback only becomes the ready selection after this one ends.
                if pendingId then
                    state.PendingEntryId = nil
                    task.defer(function()
                        if not state.Destroyed then
                            local loaded = self:LoadSong(pendingId, false)
                            if loaded then
                                emit("pending-ready")
                            end
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
        SelectedId = state.SelectedEntryId,
        PendingId = state.PendingEntryId,
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

pcall(function()
    local previous=_G.Velora
    if type(previous)~="table" and type(getgenv)=="function" then previous=getgenv().Velora end
    if type(previous)=="table" and type(previous.Destroy)=="function" then previous:Destroy() end
end)
local oldGui=PlayerGui:FindFirstChild("Velora")
if oldGui then oldGui:Destroy() end
local oldBlur=Lighting:FindFirstChild("VeloraBlur")
if oldBlur then oldBlur:Destroy() end

local function make(className,props,parent)
    local o=Instance.new(className)
    for k,v in pairs(props or {}) do
        local ok,propertyError=pcall(function() o[k]=v end)
        if not ok then warn("[Velora UI] Skipped "..className.."."..tostring(k)..": "..tostring(propertyError)) end
    end
    local ok,parentError=pcall(function() o.Parent=parent end)
    if not ok then warn("[Velora UI] Could not parent "..className..": "..tostring(parentError)) end
    return o
end
local function trackConnection(connection)
    if connection then table.insert(state.UIConnections,connection) end
    return connection
end
local function radius(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 14)},o);return o end
local function edge(o,color,t,width) make("UIStroke",{Color=color or Color3.fromRGB(101,92,145),Transparency=t or .45,Thickness=width or 1},o);return o end
local function glowEdge(o,color,haloTransparency,rimTransparency,haloWidth)
    local halo=make("UIStroke",{Name="GlowHalo",Color=color or Color3.fromRGB(143,108,255),Transparency=haloTransparency or .84,Thickness=haloWidth or 4,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
    local rim=make("UIStroke",{Name="GlowRim",Color=color or Color3.fromRGB(143,108,255),Transparency=rimTransparency or .24,Thickness=1.25,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
    return halo,rim
end
local function padding(o,l,r,t,b) make("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or l or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or t or 0)},o) end
local function gradient(o,a,b,rotation)
    make("UIGradient",{Color=ColorSequence.new(a,b),Rotation=rotation or 0},o)
    return o
end
local function label(parent,textValue,pos,size,font,sizePx,color)
    return make("TextLabel",{BackgroundTransparency=1,Position=pos,Size=size,Font=font or Enum.Font.BuilderSans,Text=textValue,TextSize=sizePx or 11,TextColor3=color or Color3.fromRGB(244,243,250),TextXAlignment=Enum.TextXAlignment.Left},parent)
end
local liveTweens=setmetatable({}, {__mode="k"})
local function animate(o,props,time)
    local previous=liveTweens[o]
    if previous then previous:Cancel() end
    local motion=TweenService:Create(o,TweenInfo.new(time or .12,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
    liveTweens[o]=motion
    motion:Play()
    return motion
end
local function clock(seconds)
    seconds=math.max(0,tonumber(seconds) or 0)
    return string.format("%d:%02d",math.floor(seconds/60),math.floor(seconds%60))
end

local P={
    Ink=Color3.fromRGB(14,12,24),Surface=Color3.fromRGB(25,22,39),Card=Color3.fromRGB(34,30,51),
    Lift=Color3.fromRGB(45,39,66),Text=Color3.fromRGB(255,254,255),Sub=Color3.fromRGB(205,199,220),
    Muted=Color3.fromRGB(154,147,177),Violet=Color3.fromRGB(143,108,255),Pink=Color3.fromRGB(255,102,188),
    Cyan=Color3.fromRGB(96,220,238),Green=Color3.fromRGB(105,235,171),
}
local nova={}

local gui=make("ScreenGui",{Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=78,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)
local shadow=radius(make("Frame",{Visible=false,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.fromOffset(760,440),BackgroundTransparency=1,BorderSizePixel=0},gui),24)
local window=radius(edge(gradient(make("Frame",{Name="Aurora",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(760,440),BackgroundColor3=P.Ink,BorderSizePixel=0,ClipsDescendants=true},gui),Color3.fromRGB(29,23,49),Color3.fromRGB(11,13,24),25),Color3.fromRGB(80,75,96),.76,1),24)
local windowBorder=window:FindFirstChildOfClass("UIStroke")

local header=radius(edge(gradient(make("Frame",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,64),BackgroundColor3=P.Surface,BorderSizePixel=0},window),Color3.fromRGB(59,42,92),Color3.fromRGB(29,28,49),10),Color3.fromRGB(143,119,207),.48),18)
local headerBorder=header:FindFirstChildOfClass("UIStroke")
local headerGlow,headerRim=glowEdge(header,P.Violet,.88,.48,3.5)
local logo=radius(gradient(make("Frame",{Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(44,44),BackgroundColor3=P.Violet,BorderSizePixel=0},header),P.Violet,P.Pink,45),14)
local logoGlow,logoRim=glowEdge(logo,P.Violet,.78,.12,5)
local logoText=label(logo,"🥀",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.BuilderSans,21,P.Text);logoText.TextXAlignment=Enum.TextXAlignment.Center
label(header,"VELORA",UDim2.fromOffset(68,10),UDim2.fromOffset(190,24),Enum.Font.BuilderSansExtraBold,20,P.Text)
label(header,"AURORA  •  PIANO STUDIO",UDim2.fromOffset(69,35),UDim2.fromOffset(210,14),Enum.Font.BuilderSansBold,9,Color3.fromRGB(220,211,244))

nova.studioBadge=radius(edge(make("Frame",{Position=UDim2.new(1,-292,0,14),Size=UDim2.fromOffset(180,36),BackgroundColor3=P.Card,BackgroundTransparency=.08,BorderSizePixel=0},header),P.Violet,.62,1),12)
nova.studioBadgeBorder=nova.studioBadge:FindFirstChildOfClass("UIStroke")
nova.studioBadgeIcon=icon(nova.studioBadge,"sparkles",16,P.Cyan,"");nova.studioBadgeIcon.AnchorPoint=Vector2.new(.5,.5);nova.studioBadgeIcon.Position=UDim2.fromOffset(18,18)
label(nova.studioBadge,"NOVA INTERFACE",UDim2.fromOffset(35,4),UDim2.fromOffset(134,14),Enum.Font.BuilderSansExtraBold,9,P.Text)
label(nova.studioBadge,tostring(#state.Registry).." COMPLETE TRACKS",UDim2.fromOffset(35,18),UDim2.fromOffset(134,12),Enum.Font.BuilderSansBold,7,P.Sub)

local settingsButton=radius(edge(make("TextButton",{Position=UDim2.new(1,-98,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(49,42,65),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),Color3.fromRGB(105,94,143),.55),12)
local settingsIcon=icon(settingsButton,"settings",17,P.Sub,"");settingsIcon.AnchorPoint=Vector2.new(.5,.5);settingsIcon.Position=UDim2.fromScale(.5,.5)
local close=radius(make("TextButton",{Position=UDim2.new(1,-52,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(49,42,65),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),12)
local closeIcon=icon(close,"x",18,P.Sub,"");closeIcon.AnchorPoint=Vector2.new(.5,.5);closeIcon.Position=UDim2.fromScale(.5,.5)
close.MouseEnter:Connect(function() animate(close,{BackgroundColor3=Color3.fromRGB(104,48,76)});recolorIcon(closeIcon,P.Text) end)
close.MouseLeave:Connect(function() animate(close,{BackgroundColor3=Color3.fromRGB(49,42,65)});recolorIcon(closeIcon,P.Sub) end)

local windowScale=make("UIScale",{Scale=1},window)
local shadowScale=make("UIScale",{Scale=1},shadow)
local function fitViewport()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local view=camera.ViewportSize
    local value=math.min(1,math.max(.68,math.min(view.X/810,view.Y/490)))
    windowScale.Scale=value
    shadowScale.Scale=value
end
local fitOk,fitError=pcall(fitViewport)
if not fitOk then warn("[Velora UI] Viewport fit skipped: "..tostring(fitError)) end
if workspace.CurrentCamera then
    local signalOk,signalError=pcall(function()
        trackConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitViewport))
    end)
    if not signalOk then warn("[Velora UI] Viewport listener skipped: "..tostring(signalError)) end
end

local body=make("Frame",{Position=UDim2.fromOffset(14,90),Size=UDim2.new(1,-28,1,-104),BackgroundTransparency=1},window)
local nav=radius(edge(make("Frame",{Size=UDim2.fromOffset(148,336),BackgroundColor3=P.Surface,BackgroundTransparency=.08,BorderSizePixel=0},body),Color3.fromRGB(88,81,119),.58),18)
local navBorder=nav:FindFirstChildOfClass("UIStroke")
local navGlow,navRim=glowEdge(nav,P.Violet,.91,.57,3)
local browser=radius(edge(make("Frame",{Position=UDim2.fromOffset(158,0),Size=UDim2.fromOffset(326,336),BackgroundColor3=P.Surface,BackgroundTransparency=.08,BorderSizePixel=0},body),Color3.fromRGB(88,81,119),.58),18)
local browserBorder=browser:FindFirstChildOfClass("UIStroke")
local browserGlow,browserRim=glowEdge(browser,P.Violet,.91,.57,3)
local playerCard=radius(edge(make("Frame",{Position=UDim2.fromOffset(494,0),Size=UDim2.fromOffset(238,336),BackgroundColor3=P.Surface,BackgroundTransparency=.04,BorderSizePixel=0},body),Color3.fromRGB(106,88,153),.5),18)
local playerBorder=playerCard:FindFirstChildOfClass("UIStroke")
local playerGlow,playerRim=glowEdge(playerCard,P.Violet,.86,.38,4)

label(nav,"DISCOVER",UDim2.fromOffset(16,16),UDim2.fromOffset(116,14),Enum.Font.BuilderSansBold,9,P.Muted)
local navList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,42),Size=UDim2.fromOffset(128,215),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=P.Violet,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},nav)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},navList)
padding(navList,0,4,0,4)
local activeFilter="All Songs"
local searchQuery=""
local navButtons={}
local refreshList

local search=radius(edge(make("TextBox",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,38),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Search the library",PlaceholderColor3=P.Sub,Text="",TextSize=11,TextColor3=P.Text,Font=Enum.Font.BuilderSansMedium,TextXAlignment=Enum.TextXAlignment.Left},browser),Color3.fromRGB(87,78,119),.55),12)
local searchBorder=search:FindFirstChildOfClass("UIStroke")
local searchGlow,searchRim=glowEdge(search,P.Violet,.93,.62,3)
padding(search,39,13,0,0)
local searchIcon=icon(browser,"search",15,P.Muted,"");searchIcon.Position=UDim2.fromOffset(27,26)
search.Focused:Connect(function() animate(searchGlow,{Transparency=.72});animate(searchRim,{Transparency=.10}) end)
search.FocusLost:Connect(function() animate(searchGlow,{Transparency=.93});animate(searchRim,{Transparency=.62}) end)
local resultTitle=label(browser,"ALL SONGS",UDim2.fromOffset(16,62),UDim2.fromOffset(200,20),Enum.Font.BuilderSansExtraBold,12,P.Text)
nova.viewCountPill=radius(edge(make("Frame",{Position=UDim2.new(1,-88,0,62),Size=UDim2.fromOffset(74,20),BackgroundColor3=P.Card,BackgroundTransparency=.08,BorderSizePixel=0},browser),P.Violet,.68,1),9)
nova.viewCountBorder=nova.viewCountPill:FindFirstChildOfClass("UIStroke")
nova.viewCountText=label(nova.viewCountPill,"0 TRACKS",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.BuilderSansExtraBold,8,P.Sub);nova.viewCountText.TextXAlignment=Enum.TextXAlignment.Center
local songList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,88),Size=UDim2.new(1,-20,1,-98),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=P.Violet,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},browser)
make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},songList)
padding(songList,2,5,4,5)

label(playerCard,"NOW PLAYING",UDim2.fromOffset(16,14),UDim2.fromOffset(160,14),Enum.Font.BuilderSansBold,9,P.Muted)
nova.playbackBadge=radius(edge(make("Frame",{Position=UDim2.new(1,-88,0,10),Size=UDim2.fromOffset(72,20),BackgroundColor3=P.Card,BackgroundTransparency=.06,BorderSizePixel=0},playerCard),P.Green,.62,1),9)
nova.playbackBadgeBorder=nova.playbackBadge:FindFirstChildOfClass("UIStroke")
nova.playbackDot=radius(make("Frame",{Position=UDim2.fromOffset(9,7),Size=UDim2.fromOffset(6,6),BackgroundColor3=P.Green,BorderSizePixel=0},nova.playbackBadge),6)
nova.playbackStatus=label(nova.playbackBadge,"READY",UDim2.fromOffset(20,0),UDim2.fromOffset(45,20),Enum.Font.BuilderSansExtraBold,8,P.Sub)
local art=radius(gradient(make("Frame",{Position=UDim2.fromOffset(16,39),Size=UDim2.fromOffset(72,72),BackgroundColor3=P.Violet,BorderSizePixel=0},playerCard),P.Violet,P.Pink,45),18)
local artBorderGlow,artBorderRim=glowEdge(art,P.Violet,.75,.12,5)
local artGlow=radius(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(44,44),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.86,BorderSizePixel=0},art),22)
local artIcon=icon(artGlow,"music-2",23,P.Text,"");artIcon.AnchorPoint=Vector2.new(.5,.5);artIcon.Position=UDim2.fromScale(.5,.5)
local nowTitle=label(playerCard,"Choose a song",UDim2.fromOffset(101,45),UDim2.fromOffset(122,38),Enum.Font.BuilderSansExtraBold,14,P.Text);nowTitle.TextWrapped=true;nowTitle.TextYAlignment=Enum.TextYAlignment.Top
local nowMeta=label(playerCard,"Ready when you are",UDim2.fromOffset(101,86),UDim2.fromOffset(122,18),Enum.Font.BuilderSansMedium,9,P.Sub)

local progress=radius(make("Frame",{Position=UDim2.fromOffset(16,127),Size=UDim2.fromOffset(206,8),BackgroundColor3=Color3.fromRGB(54,48,72),BorderSizePixel=0},playerCard),4)
nova.progressGlow,nova.progressRim=glowEdge(progress,P.Violet,.91,.42,3)
local fill=radius(gradient(make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=P.Violet,BorderSizePixel=0},progress),P.Cyan,P.Pink,0),4)
local scrubber=radius(edge(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(15,15),BackgroundColor3=P.Text,BorderSizePixel=0,ZIndex=4},progress),P.Violet,.15),8)
local seekHit=make("TextButton",{Position=UDim2.fromOffset(16,119),Size=UDim2.fromOffset(206,24),BackgroundTransparency=1,BorderSizePixel=0,Text="",ZIndex=5},playerCard)
local timeLeft=label(playerCard,"0:00",UDim2.fromOffset(16,139),UDim2.fromOffset(70,13),Enum.Font.BuilderSansMedium,8,P.Sub)
local timeRight=label(playerCard,"0:00",UDim2.fromOffset(152,139),UDim2.fromOffset(70,13),Enum.Font.BuilderSansMedium,8,P.Sub);timeRight.TextXAlignment=Enum.TextXAlignment.Right

local stop=radius(make("TextButton",{Position=UDim2.fromOffset(16,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},playerCard),15)
local stopIcon=icon(stop,"square",17,P.Sub,"");stopIcon.AnchorPoint=Vector2.new(.5,.5);stopIcon.Position=UDim2.fromScale(.5,.5)
local play=radius(edge(gradient(make("TextButton",{Position=UDim2.fromOffset(76,157),Size=UDim2.fromOffset(86,62),BackgroundColor3=P.Violet,BorderSizePixel=0,AutoButtonColor=false,Text=""},playerCard),P.Violet,P.Pink,35),Color3.new(1,1,1),.7),20)
local playBorder=play:FindFirstChildOfClass("UIStroke")
local playGlow,playRim=glowEdge(play,P.Violet,.72,.06,6)
local playIcon=icon(play,"play",25,P.Text,"");playIcon.AnchorPoint=Vector2.new(.5,.5);playIcon.Position=UDim2.fromScale(.5,.5)
local pauseIcon=icon(play,"pause",25,P.Text,"");pauseIcon.AnchorPoint=Vector2.new(.5,.5);pauseIcon.Position=UDim2.fromScale(.5,.5);pauseIcon.Visible=false
local favorite=radius(make("TextButton",{Position=UDim2.fromOffset(172,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},playerCard),15)
local favoriteIcon=icon(favorite,"heart",20,P.Sub,"");favoriteIcon.AnchorPoint=Vector2.new(.5,.5);favoriteIcon.Position=UDim2.fromScale(.5,.5)

label(playerCard,"TEMPO",UDim2.fromOffset(19,218),UDim2.fromOffset(120,12),Enum.Font.BuilderSansExtraBold,8,P.Muted)
nova.loopLabel=label(playerCard,"LOOP",UDim2.fromOffset(157,218),UDim2.fromOffset(62,12),Enum.Font.BuilderSansExtraBold,8,P.Muted);nova.loopLabel.TextXAlignment=Enum.TextXAlignment.Center
local bpmPill=radius(edge(make("Frame",{Position=UDim2.fromOffset(16,232),Size=UDim2.fromOffset(128,38),BackgroundColor3=P.Card,BorderSizePixel=0},playerCard),P.Violet,.68,1),13)
nova.bpmBorder=bpmPill:FindFirstChildOfClass("UIStroke")
local bpmDown=radius(make("TextButton",{Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(30,30),BackgroundColor3=P.Lift,BorderSizePixel=0,AutoButtonColor=false,Text=""},bpmPill),10)
local bpmDownIcon=icon(bpmDown,"chevron-left",16,P.Sub,"");bpmDownIcon.AnchorPoint=Vector2.new(.5,.5);bpmDownIcon.Position=UDim2.fromScale(.5,.5)
local bpm=make("TextBox",{Position=UDim2.fromOffset(38,0),Size=UDim2.fromOffset(52,38),BackgroundTransparency=1,ClearTextOnFocus=false,Font=Enum.Font.BuilderSansExtraBold,Text="120",TextSize=10,TextColor3=P.Text},bpmPill)
local bpmUp=radius(make("TextButton",{Position=UDim2.fromOffset(94,4),Size=UDim2.fromOffset(30,30),BackgroundColor3=P.Lift,BorderSizePixel=0,AutoButtonColor=false,Text=""},bpmPill),10)
local bpmUpIcon=icon(bpmUp,"chevron-right",16,P.Sub,"");bpmUpIcon.AnchorPoint=Vector2.new(.5,.5);bpmUpIcon.Position=UDim2.fromScale(.5,.5)
local loop=radius(edge(make("TextButton",{Position=UDim2.fromOffset(154,232),Size=UDim2.fromOffset(68,38),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},playerCard),P.Violet,.72,1),13)
nova.loopBorder=loop:FindFirstChildOfClass("UIStroke")
local loopIcon=icon(loop,"repeat-2",18,P.Sub,"");loopIcon.AnchorPoint=Vector2.new(.5,.5);loopIcon.Position=UDim2.fromScale(.5,.5)
local resetBpm=radius(edge(make("TextButton",{Position=UDim2.fromOffset(16,283),Size=UDim2.fromOffset(206,37),BackgroundColor3=Color3.fromRGB(31,29,46),BorderSizePixel=0,AutoButtonColor=false,Text=""},playerCard),P.Violet,.58,1),12)
local resetBorder=resetBpm:FindFirstChildOfClass("UIStroke")
local resetGlow,resetRim=glowEdge(resetBpm,P.Violet,.88,.38,3.5)
local resetIcon=icon(resetBpm,"rotate-ccw",15,P.Sub,"");resetIcon.AnchorPoint=Vector2.new(.5,.5);resetIcon.Position=UDim2.fromOffset(19,18)
label(resetBpm,"RESET BPM",UDim2.fromOffset(35,4),UDim2.fromOffset(158,14),Enum.Font.BuilderSansExtraBold,10,P.Text)
local feedback=label(resetBpm,"Restore the song's original tempo",UDim2.fromOffset(35,18),UDim2.fromOffset(158,13),Enum.Font.BuilderSansMedium,8,P.Sub)
feedback.TextTruncate=Enum.TextTruncate.AtEnd
play.MouseEnter:Connect(function() animate(playGlow,{Transparency=.56});animate(playRim,{Transparency=0}) end)
play.MouseLeave:Connect(function() animate(playGlow,{Transparency=.72});animate(playRim,{Transparency=.06}) end)
resetBpm.MouseEnter:Connect(function() animate(resetGlow,{Transparency=.70});animate(resetRim,{Transparency=.10}) end)
resetBpm.MouseLeave:Connect(function() animate(resetGlow,{Transparency=.88});animate(resetRim,{Transparency=.38}) end)
local function bindSurfaceHover(button,baseColor)
    button.MouseEnter:Connect(function() animate(button,{BackgroundColor3=P.Violet:Lerp(P.Ink,.48)}) end)
    button.MouseLeave:Connect(function()
        local target=type(baseColor)=="function" and baseColor() or baseColor
        animate(button,{BackgroundColor3=target or P.Card})
    end)
end
bindSurfaceHover(settingsButton,function() return P.Violet:Lerp(P.Ink,.72) end)
bindSurfaceHover(stop,function() return P.Card end)
bindSurfaceHover(favorite,function() return P.Card end)
bindSurfaceHover(bpmDown,function() return P.Lift end)
bindSurfaceHover(bpmUp,function() return P.Lift end)
bindSurfaceHover(loop,function() return state.Loop and P.Violet:Lerp(P.Ink,.45) or P.Card end)

local libraryCount=radius(edge(gradient(make("Frame",{Position=UDim2.fromOffset(10,273),Size=UDim2.fromOffset(128,51),BackgroundColor3=P.Card,BorderSizePixel=0},nav),P.Violet:Lerp(P.Ink,.68),P.Card,0),P.Violet,.62,1),14)
nova.libraryBorder=libraryCount:FindFirstChildOfClass("UIStroke")
nova.libraryGlow,nova.libraryRim=glowEdge(libraryCount,P.Violet,.91,.48,3)
nova.libraryIcon=icon(libraryCount,"library",16,P.Cyan,"");nova.libraryIcon.AnchorPoint=Vector2.new(.5,.5);nova.libraryIcon.Position=UDim2.fromOffset(18,26)
label(libraryCount,"AURORA LIBRARY",UDim2.fromOffset(33,8),UDim2.fromOffset(86,12),Enum.Font.BuilderSansBold,8,P.Sub)
local countText=label(libraryCount,tostring(#state.Registry).." SONGS",UDim2.fromOffset(33,24),UDim2.fromOffset(86,16),Enum.Font.BuilderSansExtraBold,10,P.Text)

local paletteDim=radius(make("TextButton",{Visible=false,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.38,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=40},window),24)
local palette=radius(edge(make("Frame",{Visible=false,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,88),Size=UDim2.fromOffset(280,322),BackgroundColor3=Color3.fromRGB(27,23,42),BorderSizePixel=0,ZIndex=50},window),Color3.fromRGB(142,116,210),.25,1.2),20)
label(palette,"PALETTE STUDIO",UDim2.fromOffset(18,16),UDim2.fromOffset(190,22),Enum.Font.BuilderSansExtraBold,13,P.Text).ZIndex=51
label(palette,"Shape Velora around your favorite color.",UDim2.fromOffset(18,39),UDim2.fromOffset(235,16),Enum.Font.BuilderSans,8,P.Sub).ZIndex=51
local paletteClose=radius(make("TextButton",{Position=UDim2.new(1,-45,0,12),Size=UDim2.fromOffset(31,31),BackgroundColor3=P.Card,BorderSizePixel=0,Text="",ZIndex=52},palette),10)
local paletteCloseIcon=icon(paletteClose,"x",16,P.Sub,"");paletteCloseIcon.AnchorPoint=Vector2.new(.5,.5);paletteCloseIcon.Position=UDim2.fromScale(.5,.5);paletteCloseIcon.ZIndex=53

local swatchColors={
    Color3.fromRGB(143,108,255),Color3.fromRGB(255,94,171),Color3.fromRGB(72,190,238),
    Color3.fromRGB(69,217,161),Color3.fromRGB(255,145,76),Color3.fromRGB(225,82,255),
}
local swatchRow=make("Frame",{Position=UDim2.fromOffset(18,70),Size=UDim2.fromOffset(244,38),BackgroundTransparency=1,ZIndex=51},palette)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},swatchRow)
local rgbInputs={}
for index,name in ipairs({"R","G","B"}) do
    label(palette,name,UDim2.fromOffset(18+(index-1)*82,129),UDim2.fromOffset(20,16),Enum.Font.BuilderSansBold,8,P.Muted).ZIndex=51
    rgbInputs[index]=radius(make("TextBox",{Position=UDim2.fromOffset(18+(index-1)*82,148),Size=UDim2.fromOffset(72,36),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,Text=({"143","108","255"})[index],Font=Enum.Font.BuilderSansBold,TextSize=10,TextColor3=P.Text,ZIndex=51},palette),11)
end
label(palette,"HEX",UDim2.fromOffset(18,202),UDim2.fromOffset(35,16),Enum.Font.BuilderSansBold,8,P.Muted).ZIndex=51
local hexInput=radius(make("TextBox",{Position=UDim2.fromOffset(18,221),Size=UDim2.fromOffset(158,40),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,Text="#8F6CFF",Font=Enum.Font.Code,TextSize=11,TextColor3=P.Text,ZIndex=51},palette),12)
local preview=radius(make("Frame",{Position=UDim2.fromOffset(188,221),Size=UDim2.fromOffset(74,40),BackgroundColor3=P.Violet,BorderSizePixel=0,ZIndex=51},palette),12)
local applyColorButton=radius(gradient(make("TextButton",{Position=UDim2.fromOffset(18,276),Size=UDim2.fromOffset(244,31),BackgroundColor3=P.Violet,BorderSizePixel=0,Text="APPLY COLOR",Font=Enum.Font.BuilderSansExtraBold,TextSize=9,TextColor3=P.Text,ZIndex=51},palette),P.Violet,P.Pink,0),11)

local function setPaletteVisible(visible)
    paletteDim.Visible=visible
    palette.Visible=visible
    if visible then palette.Size=UDim2.fromOffset(250,292);animate(palette,{Size=UDim2.fromOffset(280,322)},.22) end
end

local accentGradients={
    logo=logo:FindFirstChildOfClass("UIGradient"),
    art=art:FindFirstChildOfClass("UIGradient"),
    play=play:FindFirstChildOfClass("UIGradient"),
    fill=fill:FindFirstChildOfClass("UIGradient"),
    apply=applyColorButton:FindFirstChildOfClass("UIGradient"),
    window=window:FindFirstChildOfClass("UIGradient"),
    header=header:FindFirstChildOfClass("UIGradient"),
    library=libraryCount:FindFirstChildOfClass("UIGradient"),
}
local themedStrokes={
    headerBorder,headerGlow,headerRim,logoGlow,logoRim,
    nova.studioBadgeBorder,
    navBorder,navGlow,navRim,browserBorder,browserGlow,browserRim,
    playerBorder,playerGlow,playerRim,searchBorder,searchGlow,searchRim,nova.viewCountBorder,
    artBorderGlow,artBorderRim,nova.progressGlow,nova.progressRim,playBorder,playGlow,playRim,
    nova.bpmBorder,nova.loopBorder,resetBorder,resetGlow,resetRim,
    nova.libraryBorder,nova.libraryGlow,nova.libraryRim,palette:FindFirstChildOfClass("UIStroke"),
}
local function applyAccent(color)
    local h,s,v=color:ToHSV()
    local secondary=Color3.fromHSV((h+.10)%1,math.clamp(s*.72,.28,1),math.clamp(v*1.08,0,1))
    local deep=color:Lerp(Color3.fromRGB(12,10,22),.76)
    local surface=color:Lerp(Color3.fromRGB(29,25,44),.82)
    P.Violet=color
    P.Pink=secondary
    P.Surface=surface
    P.Card=color:Lerp(Color3.fromRGB(34,30,51),.84)
    P.Lift=color:Lerp(Color3.fromRGB(48,42,67),.72)

    preview.BackgroundColor3=color
    for _,object in ipairs({nav,browser,playerCard,palette}) do object.BackgroundColor3=P.Surface end
    for _,object in ipairs({nova.studioBadge,search,nova.viewCountPill,nova.playbackBadge,stop,favorite,bpmPill,loop,resetBpm,libraryCount,paletteClose,close}) do object.BackgroundColor3=P.Card end
    for _,object in ipairs(rgbInputs) do object.BackgroundColor3=P.Card end
    hexInput.BackgroundColor3=P.Card
    songList.ScrollBarImageColor3=color
    navList.ScrollBarImageColor3=color
    scrubber.UIStroke.Color=color
    settingsButton.BackgroundColor3=color:Lerp(P.Ink,.72)
    progress.BackgroundColor3=color:Lerp(Color3.fromRGB(48,44,63),.82)
    bpmPill.BackgroundColor3=P.Card
    bpmDown.BackgroundColor3=P.Lift
    bpmUp.BackgroundColor3=P.Lift
    loop.BackgroundColor3=state.Loop and color:Lerp(P.Ink,.45) or P.Card
    libraryCount.BackgroundColor3=P.Card
    resetBpm.BackgroundColor3=deep:Lerp(P.Card,.45)
    recolorIcon(settingsIcon,P.Sub);recolorIcon(closeIcon,P.Sub);recolorIcon(searchIcon,P.Muted)
    recolorIcon(artIcon,P.Text);recolorIcon(stopIcon,P.Sub);recolorIcon(playIcon,P.Text);recolorIcon(pauseIcon,P.Text)
    recolorIcon(bpmDownIcon,P.Sub);recolorIcon(bpmUpIcon,P.Sub);recolorIcon(resetIcon,P.Sub);recolorIcon(paletteCloseIcon,P.Sub)
    recolorIcon(nova.studioBadgeIcon,secondary);recolorIcon(nova.libraryIcon,P.Cyan)
    recolorIcon(favoriteIcon,state.CurrentEntry and API:IsFavorite(state.CurrentEntry.Id) and secondary or P.Sub)
    recolorIcon(loopIcon,state.Loop and P.Text or P.Sub)

    for _,object in ipairs({logo,art,play,fill,applyColorButton}) do object.BackgroundColor3=color end
    for name,g in pairs(accentGradients) do
        if g then
            if name=="window" then
                g.Color=ColorSequence.new(color:Lerp(P.Ink,.78),Color3.fromRGB(11,13,24))
            elseif name=="header" then
                g.Color=ColorSequence.new(color:Lerp(P.Ink,.58),color:Lerp(P.Surface,.72))
            else
                g.Color=ColorSequence.new(color,secondary)
            end
        end
    end
    for _,strokeObject in ipairs(themedStrokes) do
        if strokeObject then strokeObject.Color=color:Lerp(Color3.new(1,1,1),.34) end
    end
    for filter,button in pairs(navButtons) do
        button.BackgroundColor3=color:Lerp(P.Ink,.48)
        if filter==activeFilter then button.BackgroundTransparency=0 end
    end
    refreshList(true)
end

local function syncRgb()
    local r=math.clamp(tonumber(rgbInputs[1].Text) or 0,0,255)
    local g=math.clamp(tonumber(rgbInputs[2].Text) or 0,0,255)
    local b=math.clamp(tonumber(rgbInputs[3].Text) or 0,0,255)
    for index,value in ipairs({r,g,b}) do rgbInputs[index].Text=tostring(math.floor(value)) end
    hexInput.Text=string.format("#%02X%02X%02X",r,g,b)
    preview.BackgroundColor3=Color3.fromRGB(r,g,b)
    return Color3.fromRGB(r,g,b)
end

for _,color in ipairs(swatchColors) do
    local swatch=radius(edge(make("TextButton",{Size=UDim2.fromOffset(34,34),BackgroundColor3=color,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=52},swatchRow),Color3.new(1,1,1),.72),12)
    swatch.MouseButton1Click:Connect(function()
        local r,g,b=math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5)
        rgbInputs[1].Text=tostring(r);rgbInputs[2].Text=tostring(g);rgbInputs[3].Text=tostring(b)
        hexInput.Text=string.format("#%02X%02X%02X",r,g,b);applyAccent(color)
    end)
end
for _,box in ipairs(rgbInputs) do box.FocusLost:Connect(function() syncRgb() end) end
hexInput.FocusLost:Connect(function()
    local raw=hexInput.Text:gsub("#","")
    if raw:match("^%x%x%x%x%x%x$") then
        for index=1,3 do rgbInputs[index].Text=tostring(tonumber(raw:sub(index*2-1,index*2),16)) end
    end
    syncRgb()
end)
applyColorButton.MouseButton1Click:Connect(function() applyAccent(syncRgb());setPaletteVisible(false) end)
settingsButton.MouseButton1Click:Connect(function() setPaletteVisible(true) end)
paletteClose.MouseButton1Click:Connect(function() setPaletteVisible(false) end)
paletteDim.MouseButton1Click:Connect(function() setPaletteVisible(false) end)

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
    local button=radius(make("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(73,57,111),BackgroundTransparency=index==1 and 0 or 1,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.BuilderSansMedium,Text="   "..name,TextSize=11,TextColor3=index==1 and P.Text or P.Sub,TextXAlignment=Enum.TextXAlignment.Left},navList),11)
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

local function songPalette(index)
    local h,s,v=P.Violet:ToHSV()
    local offset=((index-1)%5)*.025
    local first=Color3.fromHSV((h+offset)%1,math.clamp(s*.92,.35,1),math.clamp(v,0,1))
    local second=Color3.fromHSV((h+.10+offset)%1,math.clamp(s*.72,.3,1),math.clamp(v*1.08,0,1))
    return {first,second}
end

refreshList=function(force)
    local selectedId=state.SelectedEntryId or (state.CurrentEntry and state.CurrentEntry.Id)
    local playingId=state.Playing and state.CurrentEntry and state.CurrentEntry.Id or ""
    local signature=table.concat({activeFilter,searchQuery,selectedId or "",playingId},"\0")
    if not force and nova.listSignature==signature then return end
    nova.listSignature=signature

    for _,child in ipairs(songList:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    local shown=0

    for index,entry in ipairs(state.Registry) do
        if entryMatches(entry) then
            shown+=1

            local selected=entry.Id==selectedId
            local playingCurrent=entry.Id==playingId
            local cardBase=selected and P.Violet:Lerp(P.Ink,.62) or P.Card
            local cardHover=selected and P.Violet:Lerp(P.Ink,.50) or P.Lift

            local card=radius(make("TextButton",{
                Size=UDim2.new(1,0,0,61),
                BackgroundColor3=cardBase,
                BorderSizePixel=0,
                AutoButtonColor=false,
                Text="",
            },songList),15)
            edge(card,selected and P.Violet or Color3.fromRGB(86,77,117),selected and .08 or .58,selected and 1.6 or 1)
            local palette=songPalette(index)
            local tile=radius(gradient(make("Frame",{
                Position=UDim2.fromOffset(9,7),
                Size=UDim2.fromOffset(47,47),
                BackgroundColor3=palette[1],
                BorderSizePixel=0,
            },card),palette[1],palette[2],45),13)
            if selected then
                edge(tile,P.Text,.45,1.2)
            end

            local cardMusicIcon=icon(tile,"music-2",17,P.Text,"")
            cardMusicIcon.AnchorPoint=Vector2.new(.5,.5)
            cardMusicIcon.Position=UDim2.fromScale(.5,.5)

            label(card,entry.Name or "Untitled",UDim2.fromOffset(68,9),UDim2.new(1,-112,0,19),Enum.Font.BuilderSansBold,11,P.Text)

            local statusText=selected and "  •  SELECTED" or (playingCurrent and "  •  PLAYING" or "")
            local meta=label(card,(entry.Artist or "Velora").."  •  "..tostring(entry.BPM or 120).." BPM"..statusText,UDim2.fromOffset(68,32),UDim2.new(1,-112,0,15),Enum.Font.BuilderSansMedium,9,selected and P.Cyan or (playingCurrent and P.Green or P.Sub))

            local indicatorName=selected and "check" or (playingCurrent and "volume-2" or "chevron-right")
            local indicatorColor=selected and P.Cyan or (playingCurrent and P.Green or Color3.fromRGB(188,172,255))
            local indicator=icon(card,indicatorName,17,indicatorColor,"")
            indicator.AnchorPoint=Vector2.new(.5,.5)
            indicator.Position=UDim2.new(1,-24,.5,0)

            card.MouseEnter:Connect(function()
                animate(card,{BackgroundColor3=cardHover})
                animate(tile,{Size=UDim2.fromOffset(49,49),Position=UDim2.fromOffset(8,6)})
            end)
            card.MouseLeave:Connect(function()
                animate(card,{BackgroundColor3=cardBase})
                animate(tile,{Size=UDim2.fromOffset(47,47),Position=UDim2.fromOffset(9,7)})
            end)
            card.MouseButton1Click:Connect(function()
                local ok,mode=API:SelectSong(entry.Id)
                if not ok then
                    feedback.Text=tostring(mode)
                elseif mode=="pending" then
                    feedback.Text="Picked "..tostring(entry.Name)..". The current song keeps playing."
                elseif mode=="current" then
                    feedback.Text=tostring(entry.Name).." is still playing."
                else
                    feedback.Text="Selected "..tostring(entry.Name)..". Press Play when ready."
                end
            end)
        end
    end

    nova.viewCountText.Text=tostring(shown)..(shown==1 and " TRACK" or " TRACKS")

    if shown==0 then
        local empty=label(songList,"No songs in this view",UDim2.new(),UDim2.new(1,0,0,90),Enum.Font.BuilderSansBold,10,P.Muted)
        empty.TextXAlignment=Enum.TextXAlignment.Center
    end
end

local seeking=false
local function seekAt(screenX)
    local ratio=math.clamp((screenX-progress.AbsolutePosition.X)/math.max(1,progress.AbsoluteSize.X),0,1)
    fill.Size=UDim2.new(ratio,0,1,0)
    scrubber.Position=UDim2.new(ratio,0,.5,0)
    API:Seek(ratio)
end

local function render()
    local entry=state.CurrentEntry
    local duration=state.Timeline and state.Timeline.Duration or 0
    local progressValue=duration>0 and math.clamp(state.Position/duration,0,1) or 0
    if entry then
        local titleValue=entry.Name or "Untitled"
        local bpmValue=tostring(math.floor(state.CurrentBPM or 120))
        local metaValue=(entry.Artist or "Velora").."  •  "..bpmValue.." BPM"
        if nowTitle.Text~=titleValue then nowTitle.Text=titleValue end
        if nowMeta.Text~=metaValue then nowMeta.Text=metaValue end
        if not bpm:IsFocused() and bpm.Text~=bpmValue then bpm.Text=bpmValue end
        local favoriteValue=state.Favorites[entry.Id]==true
        if nova.lastFavorite~=favoriteValue then
            nova.lastFavorite=favoriteValue
            recolorIcon(favoriteIcon,favoriteValue and P.Pink or P.Sub)
        end
    end
    if not seeking then
        fill.Size=UDim2.new(progressValue,0,1,0)
        scrubber.Position=UDim2.new(progressValue,0,.5,0)
    end
    local leftValue,rightValue=clock(state.Position),clock(duration)
    if timeLeft.Text~=leftValue then timeLeft.Text=leftValue end
    if timeRight.Text~=rightValue then timeRight.Text=rightValue end
    local showPause=state.Playing and not state.Paused
    if nova.lastShowPause~=showPause then
        nova.lastShowPause=showPause
        playIcon.Visible=not showPause
        pauseIcon.Visible=showPause
    end
    if nova.lastLoop~=state.Loop then
        nova.lastLoop=state.Loop
        loop.BackgroundColor3=state.Loop and P.Violet:Lerp(P.Ink,.45) or P.Card
        recolorIcon(loopIcon,state.Loop and P.Text or P.Sub)
        nova.loopLabel.TextColor3=state.Loop and P.Text or P.Muted
    end
    local statusText,statusColor="READY",P.Cyan
    if state.Playing and not state.Paused then
        statusText,statusColor="PLAYING",P.Green
    elseif state.Paused then
        statusText,statusColor="PAUSED",P.Pink
    elseif duration>0 and progressValue>=.999 then
        statusText,statusColor="DONE",P.Cyan
    end
    if nova.lastStatus~=statusText or nova.lastStatusColor~=statusColor then
        nova.lastStatus=statusText
        nova.lastStatusColor=statusColor
        nova.playbackStatus.Text=statusText
        nova.playbackStatus.TextColor3=statusColor
        nova.playbackDot.BackgroundColor3=statusColor
        nova.playbackBadgeBorder.Color=statusColor
        nova.playbackBadge.BackgroundColor3=statusColor:Lerp(P.Ink,.84)
    end
end

search:GetPropertyChangedSignal("Text"):Connect(function() searchQuery=string.lower(search.Text);refreshList() end)
seekHit.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then seeking=true;seekAt(input.Position.X) end
end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
    if seeking and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then seekAt(input.Position.X) end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input)
    if seeking and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then seekAt(input.Position.X);seeking=false end
end))
bpmDown.MouseButton1Click:Connect(function() API:SetBPM((state.CurrentBPM or 120)-5);render() end)
bpmUp.MouseButton1Click:Connect(function() API:SetBPM((state.CurrentBPM or 120)+5);render() end)
play.MouseButton1Click:Connect(function()
    if state.Playing and not state.Paused then API:Pause();feedback.Text="Paused in the moonlight."
    else local ok,err=API:Play();feedback.Text=ok and "Aurora is playing into the game." or (tostring(err).." — click the piano once.") end
    render()
end)
stop.MouseButton1Click:Connect(function()
    local pendingId=state.PendingEntryId
    API:Stop()

    if pendingId then
        state.PendingEntryId=nil
        local ok,err=API:LoadSong(pendingId,false)
        feedback.Text=ok and "Selected song is ready. Press Play when you want." or tostring(err)
    else
        feedback.Text="Stopped. The song is ready to restart."
    end

    render()
end)
favorite.MouseButton1Click:Connect(function() if state.CurrentEntry then API:ToggleFavorite(state.CurrentEntry.Id) end end)
loop.MouseButton1Click:Connect(function() API:SetLoop(not state.Loop);render() end)
resetBpm.MouseButton1Click:Connect(function()
    if not state.CurrentSong or not state.CurrentEntry then
        feedback.Text="Choose a song first."
        return
    end
    local original=math.clamp(tonumber(state.CurrentSong.BPM or state.CurrentEntry.BPM) or 120,30,300)
    local value=API:SetBPM(original)
    feedback.Text=value and ("Restored original tempo  •  "..math.floor(value).." BPM") or "Could not reset this song."
    render()
end)
bpm.FocusLost:Connect(function() local value=API:SetBPM(tonumber(bpm.Text));feedback.Text=value and ("Tempo set to "..math.floor(value).." BPM.") or "Choose a song first.";render() end)

API.Changed:Connect(function(reason)
    if reason=="finished" then
        feedback.Text=state.PendingEntryId and "Song complete. Preparing your selected song." or "Song complete. Autoplay stopped."
    elseif reason=="pending-ready" then
        feedback.Text="Your selected song is ready. Press Play when you want."
    elseif reason=="pending-selection" then
        local picked=getEntry(state.PendingEntryId)
        feedback.Text="Picked "..tostring(picked and picked.Name or "song")..". The current song keeps playing."
    elseif reason=="input-error" then
        feedback.Text="Input was rejected. Click the in-game piano, then retry."
    elseif reason=="input-required" then
        feedback.Text="This executor has no compatible piano output."
    elseif reason=="selection" then
        animate(art,{Rotation=3})
        task.delay(.09,function() if art.Parent then animate(art,{Rotation=0},.1) end end)
    end

    if reason=="favorites" or reason=="library" then
        refreshList(true)
    elseif reason=="selection" or reason=="selection-focus" or reason=="pending-selection"
        or reason=="pending-ready" or reason=="playing" or reason=="stopped" or reason=="finished" then
        refreshList()
    end
    render()
end)
local lastNoteStatus=0
API.NotePlayed:Connect(function(note)
    if state.PendingEntryId then
        local picked=getEntry(state.PendingEntryId)
        feedback.Text="Picked "..tostring(picked and picked.Name or "song")..". The current song keeps playing."
    elseif os.clock()-lastNoteStatus>=.25 then
        lastNoteStatus=os.clock()
        feedback.Text="Playing  "..tostring(note).."  •  Aurora output active"
    end
end)

local dragging=false
local dragStart,startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=input.Position;startPos=window.Position end
end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local delta=input.Position-dragStart;window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)  end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end))
trackConnection(UserInputService.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end))

local function cleanup()
    if state.Cleaning then return end
    state.Cleaning=true
    state.Destroyed=true
    stopConnection()
    for index=#state.UIConnections,1,-1 do
        pcall(function() state.UIConnections[index]:Disconnect() end)
    end
    table.clear(state.UIConnections)
    pcall(function() changed:Destroy() end)
    pcall(function() notePlayed:Destroy() end)
    if _G.Velora==API then _G.Velora=nil end
    pcall(function() if type(getgenv)=="function" and getgenv().Velora==API then getgenv().Velora=nil end end)
end

close.MouseButton1Click:Connect(function() API:Destroy() end)

local lastRender=0
trackConnection(RunService.RenderStepped:Connect(function()
    if not gui.Parent then return end
    local now=os.clock()
    if now-lastRender>=1/30 then
        lastRender=now
        render()
    end
end))
trackConnection(gui.AncestryChanged:Connect(function(_,parent) if not parent then cleanup() end end))

API.UI={Gui=gui,Window=window}
API.State=state
function API:Show() gui.Enabled=true end
function API:Hide() gui.Enabled=false end
function API:Destroy()
    cleanup()
    if gui.Parent then gui:Destroy() end
end

refreshList()
if state.Registry[1] and not state.CurrentEntry then API:LoadSong(state.Registry[1].Id,false) end
render()
window.Size=UDim2.fromOffset(710,400);shadow.Size=UDim2.fromOffset(710,400)
animate(window,{Size=UDim2.fromOffset(760,440)},.2)

_G.Velora=API
pcall(function() if type(getgenv)=="function" then getgenv().Velora=API end end)
return API

