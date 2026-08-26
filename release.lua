--[[
    Velora v0.10.21 "Nova"
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
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    error("Velora must run on the Roblox client.", 0)
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RAW_BASE = "https://raw.githubusercontent.com/MrRos3/Velora/protected-playback-test/"

local CONFIG = {
    Version = "0.10.21",
    AssetRevision = "0.10.21-seekfix1",
    Codename = "Nova",
    ToggleKey = Enum.KeyCode.RightShift,
    Accent = Color3.fromRGB(211, 76, 90),
    AccentAlt = Color3.fromRGB(127, 31, 42),
    ClickSound = "rbxassetid://4307186075",
    HoverSound = "rbxassetid://408524543",
    UiSounds = true,
    Blur = false,
    AutoInput = true,
    InputHold = 0.015,
}

local C = {
    Backdrop = Color3.fromRGB(4, 4, 5),
    Window = Color3.fromRGB(9, 7, 8),
    Window2 = Color3.fromRGB(14, 10, 11),
    Panel = Color3.fromRGB(18, 13, 15),
    Raised = Color3.fromRGB(28, 19, 21),
    Hover = Color3.fromRGB(42, 26, 29),
    Edge = Color3.fromRGB(210, 151, 157),
    Text = Color3.fromRGB(255, 248, 249),
    Sub = Color3.fromRGB(218, 202, 205),
    Muted = Color3.fromRGB(148, 129, 133),
    Success = Color3.fromRGB(232, 101, 113),
    Danger = Color3.fromRGB(246, 81, 97),
    Warning = Color3.fromRGB(225, 139, 91),
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

local ProtectedClient
local protectedConfig = safeLoadTable(RAW_BASE .. "ProtectedConfig.lua?v=" .. CONFIG.AssetRevision)
local protectedModule = safeLoadTable(RAW_BASE .. "ProtectedPlayback.lua?v=" .. CONFIG.AssetRevision)
if type(protectedConfig) == "table" and type(protectedModule) == "table"
    and type(protectedModule.new) == "function" then
    local ok, client = pcall(protectedModule.new, {
        HttpService = HttpService,
        ApiBase = protectedConfig.ApiBase,
        Version = CONFIG.Version,
        InitialChunks = protectedConfig.InitialChunks,
        RetryCount = protectedConfig.RetryCount,
        RequestTimeout = protectedConfig.RequestTimeout,
    })
    if ok and type(client) == "table" then
        ProtectedClient = client
    end
end

-- Bundled LucideBlox mappings keep the interface independent of an external icon repository.
local Icons = {
    ["sparkles"] = "rbxassetid://8997388430",
    ["settings"] = "rbxassetid://7734053495",
    ["minimize-2"] = "rbxassetid://7733997870",
    ["maximize-2"] = "rbxassetid://7733992901",
    ["x"] = "rbxassetid://7743878857",
    ["search"] = "rbxassetid://7734052925",
    ["music-2"] = "rbxassetid://7734020554",
    ["square"] = "rbxassetid://7743872181",
    ["play"] = "rbxassetid://7743871480",
    ["pause"] = "rbxassetid://7734021897",
    ["heart"] = "rbxassetid://7733956134",
    ["chevron-left"] = "rbxassetid://7733717651",
    ["chevron-right"] = "rbxassetid://7733717755",
    ["repeat-2"] = "rbxassetid://7734051454",
    ["rotate-ccw"] = "rbxassetid://7734051861",
    ["library"] = "rbxassetid://7743869054",
    ["check"] = "rbxassetid://7733715400",
    ["volume-2"] = "rbxassetid://7743877250",
}

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
    -- Detailed scores such as Love Story use 24 timing steps per displayed
    -- half-note beat. Capping this at 16 stretches every rest and corrupts the
    -- song's tempo, so retain high-resolution grids while keeping a safe cap.
    stepsPerBeat = math.clamp(tonumber(stepsPerBeat) or 2, 1, 64)

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
    {Id="mariage-damour",Name="Mariage d'Amour",Artist="Paul de Senneville",BPM=85,Categories={"Famous","Piano","Romantic","Complete"},Protected={Id="pv1_KotsQb0E9WH8Txo1",Duration=240.368,ChunkMs=2500}},
    {Id="la-petite-fille-de-la-mer",Name="La petite fille de la mer",Artist="Vangelis",BPM=80,Categories={"Famous","Soundtrack","Ambient","Piano","Emotional","Complete"},Protected={Id="pv1_gJkVKTf_njT_a6XA",Duration=404.625,ChunkMs=2500}},
    {Id="salvatore-lana-del-rey",Name="Salvatore",Artist="Lana Del Rey",BPM=58,Categories={"Famous","Lana Del Rey","Pop","Piano","Cinematic","Emotional","Complete"},Protected={Id="pv1_pzgK4CVZ3m8JlXTe",Duration=261.789,ChunkMs=2500}},
    {Id="idea-22",Name="Idea 22",Artist="Gibran Alcocer",BPM=120,Categories={"Famous","Piano","Instrumental","Emotional","Modern Classical","Gibran Alcocer","Complete"},Protected={Id="pv1_hosq4XudJbLnogFn",Duration=152.01,ChunkMs=2500}},
    {Id="idea-10",Name="Idea 10",Artist="Gibran Alcocer",BPM=170,Categories={"Famous","Piano","Instrumental","Emotional","Modern Classical","Gibran Alcocer","Complete"},Protected={Id="pv1_wX8VHQTBR2U-ZCS-",Duration=131.14,ChunkMs=2500}},
    {Id="tourner-dans-le-vide-indila",Name="Tourner dans le vide",Artist="Indila",BPM=120,Categories={"Famous","French","Pop","Piano","Dramatic","Complete"},Protected={Id="pv1_whU-pqdYU8lNRDSt",Duration=247.375,ChunkMs=2500}},
    {Id="derniere-danse-indila",Name="Dernière Danse",Artist="Indila",BPM=120,Categories={"Famous","French","Pop","Piano","Dramatic","Complete"},Protected={Id="pv1_h5ffvHf864OkHqEU",Duration=74,ChunkMs=2500}},
    {Id="another-love-tom-odell",Name="Another Love",Artist="Tom Odell",BPM=113,Categories={"Famous","Pop","Piano","Emotional","Complete"},Protected={Id="pv1_QOGGcpvxaBlOZZrr",Duration=259.159,ChunkMs=2500}},
    {Id="snowfall-oneheart-reidenshi",Name="Snowfall",Artist="Øneheart & reidenshi",BPM=100,Categories={"Famous","Ambient","TikTok","Piano","Dreamy","Complete"},Protected={Id="pv1_ZkN6xn4ZVZj29Qjs",Duration=115.2,ChunkMs=2500}},
    {Id="the-perfect-girl-mareux",Name="The Perfect Girl",Artist="Mareux",BPM=125,Categories={"Famous","Darkwave","TikTok","Piano","Dark","Complete"},Protected={Id="pv1_g3XVQhjSmMz3xlBk",Duration=42.36,ChunkMs=2500}},
    {Id="merry-go-round-of-life",Name="Merry-Go-Round of Life — Easy Piano Excerpt",Artist="Joe Hisaishi",BPM=120,Categories={"Famous","Soundtrack","Anime","Waltz","Piano","Excerpt"},Protected={Id="pv1_LewtFAdQGZFiLMb-",Duration=123,ChunkMs=2500}},
    {Id="eysan-unutamiyorum-ezel",Name="Eyşan Unutamıyorum (Ezel Theme)",Artist="Toygar Işıklı",BPM=70,Categories={"Famous","Soundtrack","Turkish","TV","Emotional","Piano","Complete"},Protected={Id="pv1_EcbeO1krb1Pc4VKE",Duration=146.732,ChunkMs=2500}},
    {Id="carol-of-the-bells",Name="Carol of the Bells",Artist="Mykola Leontovych",BPM=200,Categories={"Famous","Classical","Holiday","Dramatic","Piano","Complete"},Protected={Id="pv1_iTATTp79NKwf0pNx",Duration=140.55,ChunkMs=2500}},
    {Id="swan-lake",Name="Swan Lake",Artist="Pyotr Ilyich Tchaikovsky",BPM=100,Categories={"Famous","Classical","Ballet","Dramatic","Piano","Complete"},Protected={Id="pv1_ksmkyNk_Ct-1O7N2",Duration=105.488,ChunkMs=2500}},
    {Id="gnossienne-no-1",Name="Gnossienne No. 1",Artist="Erik Satie",BPM=100,Categories={"Famous","Classical","Piano","Calm","Haunting","Complete"},Protected={Id="pv1_PcI83ESDKxZkxFLd",Duration=196.25,ChunkMs=2500}},
    {Id="hungarian-dance-no-5",Name="Hungarian Dance No. 5",Artist="Johannes Brahms",BPM=130,Categories={"Famous","Classical","Dance","Dramatic","Piano","Complete"},Protected={Id="pv1_jKPM6J9IY3qRZRW5",Duration=165.462,ChunkMs=2500}},
    {Id="la-foule-edith-piaf",Name="La Foule",Artist="Édith Piaf",BPM=170,Categories={"Famous","French","Chanson","Waltz","Édith Piaf","Piano","Dramatic","Complete"},Protected={Id="pv1_vesvC2XPWRCJp4uA",Duration=175.257,ChunkMs=2500}},
    {Id="uae-national-anthem",Name="Ishy Bilady — UAE National Anthem",Artist="United Arab Emirates",BPM=125,Categories={"Famous","National Anthem","UAE","Patriotic","Piano","Complete"},Protected={Id="pv1_7GXDm5kl6yK1AV5L",Duration=45.14,ChunkMs=2500}},
    {Id="succession-main-title",Name="Succession — Main Title Theme",Artist="Nicholas Britell",BPM=144,Categories={"Famous","Soundtrack","TV","Dark","Piano","Complete"},Protected={Id="pv1_7-WAon3BVo8DaioU",Duration=83.281,ChunkMs=2500}},
    {Id="anlatamam-kara-sevda",Name="Anlatamam (Kara Sevda OST)",Artist="Toygar Işıklı",BPM=50,Categories={"Famous","Soundtrack","Turkish","Emotional","Complete"},Protected={Id="pv1_JNSHWkWxtLKiMUt6",Duration=137.2,ChunkMs=2500}},
    {Id="love-story-indila",Name="Love Story",Artist="Indila",BPM=190,Categories={"Famous","French","Pop","Romantic","Piano","Complete"},Protected={Id="pv1_zQ-NtHZ77n3I-_x7",Duration=104.316,ChunkMs=2500}},
    {Id="ievan-polkka",Name="Ievan Polkka",Artist="Traditional Finnish",BPM=110,Categories={"Famous","TikTok","Folk","Upbeat","Complete"},Protected={Id="pv1_Ze7OlD36ewCSGWBe",Duration=158.318,ChunkMs=2500}},
    {Id="kamado-tanjiro-no-uta",Name="Kamado Tanjiro no Uta",Artist="Go Shiina feat. Nami Nakagawa",BPM=151,Categories={"Famous","Anime","Demon Slayer","Emotional","Complete"},Protected={Id="pv1_2EcfKveSNpfglcHg",Duration=373.543,ChunkMs=2500}},
    {Id="erika",Name="Erika",Artist="Herms Niel",BPM=112,Categories={"Famous","Historical","German","March","Complete"},Protected={Id="pv1_ciebOP5OwfVcQ9tN",Duration=219.687,ChunkMs=2500}},
    {Id="mountain-king",Name="In the Hall of the Mountain King",Artist="Edvard Grieg",BPM=138,Categories={"Famous","TikTok Classics","Classical","Dramatic","Complete"},Protected={Id="pv1_fkZstY5plmv9nt5h",Duration=151.848,ChunkMs=2500}},
    {Id="eine-kleine-nachtmusik",Name="Eine kleine Nachtmusik — Allegro",Artist="W. A. Mozart",BPM=144,Categories={"Famous","TikTok Classics","Classical","Upbeat","Complete"},Protected={Id="pv1_oPDTuHBnVwVDATMA",Duration=319.201,ChunkMs=2500}},
    {Id="dies-irae",Name="Dies Irae — Requiem",Artist="W. A. Mozart",BPM=180,Categories={"Famous","TikTok Classics","Classical","Dark","Complete"},Protected={Id="pv1_6X3ehWlN_rkNYVaB",Duration=89.694,ChunkMs=2500}},
    {Id="fur-elise",Name="Für Elise",Artist="L. van Beethoven",BPM=72,Categories={"Famous","Classical","Romantic","Complete"},Protected={Id="pv1_K3ec_E8rmmz4CWdZ",Duration=130.069,ChunkMs=2500}},
    {Id="moonlight-sonata",Name="Moonlight Sonata — Adagio",Artist="L. van Beethoven",BPM=60,Categories={"Famous","Classical","Dark","Complete"},Protected={Id="pv1_XXKrWOJ4lqWdYFsU",Duration=272.083,ChunkMs=2500}},
    {Id="turkish-march",Name="Turkish March",Artist="W. A. Mozart",BPM=126,Categories={"Famous","Classical","Upbeat","Complete"},Protected={Id="pv1_vp9QSst2lMbJM2Aa",Duration=120.992,ChunkMs=2500}},
    {Id="clair-de-lune",Name="Clair de Lune",Artist="Claude Debussy",BPM=60,Categories={"Famous","Classical","Dreamy","Complete"},Protected={Id="pv1_9C2UWDBGL-B047Yw",Duration=319.583,ChunkMs=2500}},
    {Id="canon-in-d",Name="Canon in D",Artist="Johann Pachelbel",BPM=55,Categories={"Famous","Classical","Wedding","Complete"},Protected={Id="pv1_YV1B2QAi7-6vfM6K",Duration=244.455,ChunkMs=2500}},
    {Id="nocturne-op9",Name="Nocturne Op. 9 No. 2",Artist="Frédéric Chopin",BPM=60,Categories={"Famous","Classical","Romantic","Piano","Complete"},Protected={Id="pv1_jOy15iPjTwk-tCy0",Duration=219.833,ChunkMs=2500}},
    {Id="gymnopedie",Name="Gymnopédie No. 1",Artist="Erik Satie",BPM=60,Categories={"Famous","Classical","Calm","Complete"},Protected={Id="pv1_hiRlhykXE7bIdEL1",Duration=138.083,ChunkMs=2500}},
    {Id="bach-prelude",Name="Prelude in C Major",Artist="J. S. Bach",BPM=60,Categories={"Famous","Classical","Study","Complete"},Protected={Id="pv1_GjGxo2GMS29EzOZW",Duration=136.083,ChunkMs=2500}},
    {Id="minute-waltz",Name="Minute Waltz",Artist="Frédéric Chopin",BPM=240,Categories={"Famous","Classical","Fast","Complete"},Protected={Id="pv1_mhJVA234uSu9TyTK",Duration=104.521,ChunkMs=2500}},
    {Id="fantaisie-impromptu",Name="Fantaisie-Impromptu",Artist="Frédéric Chopin",BPM=168,Categories={"Famous","Classical","Virtuoso","Complete"},Protected={Id="pv1_HB1uKWr3m8LO4g0I",Duration=195.744,ChunkMs=2500}},
    {Id="pathetique-adagio",Name="Pathétique — Adagio Cantabile",Artist="L. van Beethoven",BPM=36,Categories={"Famous","Classical","Emotional","Complete"},Protected={Id="pv1_933RWrIwRkVXOMlF",Duration=241.806,ChunkMs=2500}},
    {Id="mozart-k545-allegro",Name="Piano Sonata K.545 — Allegro",Artist="W. A. Mozart",BPM=132,Categories={"Famous","Classical","Upbeat","Complete"},Protected={Id="pv1_1NSEQ_fjYLLP9YWr",Duration=131.856,ChunkMs=2500}},
    {Id="ode-to-joy",Name="Ode to Joy",Artist="L. van Beethoven",BPM=100,Categories={"Famous","Classical","Starter","Complete"},Protected={Id="pv1_ZCbTka-WqEDc9vw4",Duration=37.25,ChunkMs=2500}}
}

local function loadRegistry()
    local registry = safeLoadTable(RAW_BASE .. "Songs.lua?velora=" .. CONFIG.AssetRevision)
    if type(registry) == "table" and #registry > 0 then
        return registry
    end
    return FALLBACK_SONGS
end

local Registry = loadRegistry()

local FAVORITES_DIRECTORY = "Velora"
local FAVORITES_PATH = FAVORITES_DIRECTORY .. "/favorites.json"
local FAVORITES_MEMORY_KEY = "VeloraFavorites"

local function favoritesSnapshot(source)
    local snapshot = {}
    for id, enabled in pairs(type(source) == "table" and source or {}) do
        if type(id) == "string" and enabled == true then
            snapshot[id] = true
        end
    end
    return snapshot
end

local function runtimeEnvironment()
    if type(getgenv) == "function" then
        local ok, environment = pcall(getgenv)
        if ok and type(environment) == "table" then
            return environment
        end
    end
    return _G
end

local function loadFavorites()
    local favorites = {}

    pcall(function()
        if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(FAVORITES_PATH) then
            return
        end

        local decoded = HttpService:JSONDecode(readfile(FAVORITES_PATH))
        if type(decoded) ~= "table" then
            return
        end

        for id, enabled in pairs(decoded) do
            if type(id) == "string" and enabled == true then
                favorites[id] = true
            elseif type(enabled) == "string" then
                favorites[enabled] = true
            end
        end
    end)

    local environment = runtimeEnvironment()
    for id, enabled in pairs(type(environment[FAVORITES_MEMORY_KEY]) == "table" and environment[FAVORITES_MEMORY_KEY] or {}) do
        if type(id) == "string" and enabled == true then
            favorites[id] = true
        end
    end

    return favorites
end

local function saveFavorites(source)
    local snapshot = favoritesSnapshot(source)
    runtimeEnvironment()[FAVORITES_MEMORY_KEY] = snapshot

    local wroteFile = false
    pcall(function()
        if type(writefile) ~= "function" then
            return
        end
        if type(isfolder) == "function" and not isfolder(FAVORITES_DIRECTORY) and type(makefolder) == "function" then
            makefolder(FAVORITES_DIRECTORY)
        end
        writefile(FAVORITES_PATH, HttpService:JSONEncode(snapshot))
        wroteFile = true
    end)

    return wroteFile
end

local API = {
    Version = CONFIG.Version,
    Codename = CONFIG.Codename,
}

local state = {
    Registry = Registry,
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
    Favorites = loadFavorites(),
    Recent = {},
    Queue = {},
    Category = "All Songs",
    Search = "",
    Connection = nil,
    ProtectedStream = nil,
    StreamGeneration = 0,
    SeekGeneration = 0,
    SeekResumeMode = nil,
    PendingSeekProgress = nil,
    PendingProtectedSource = nil,
    Buffering = false,
    StreamError = nil,
    LastPlaybackError = nil,
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

local function isProtectedEntry(entry)
    return type(entry) == "table" and type(entry.Protected) == "table"
        and type(entry.Protected.Id) == "string"
end

local function decodeProtectedNotes(value)
    local notes = {}
    if type(value) == "string" then
        for index = 1, #value do
            notes[#notes + 1] = value:sub(index, index)
        end
    elseif type(value) == "table" then
        for _, note in ipairs(value) do
            note = tostring(note or "")
            if #note == 1 then
                notes[#notes + 1] = note
            end
        end
    end
    return notes
end

local function protectedTimeScale(stream, bpm)
    return (tonumber(stream and stream.BaseBPM) or 120) / math.clamp(tonumber(bpm) or 120, 30, 300)
end

local function appendProtectedChunk(timeline, stream, chunk, bpm)
    local scale = protectedTimeScale(stream, bpm)
    local minimumSourceMs = tonumber(stream.StartMs) or 0
    for _, packed in ipairs(type(chunk) == "table" and chunk.events or {}) do
        local sourceMs = type(packed) == "table" and tonumber(packed[1]) or nil
        local notes = type(packed) == "table" and decodeProtectedNotes(packed[2]) or {}
        if sourceMs and sourceMs >= minimumSourceMs and #notes > 0 then
            timeline.Events[#timeline.Events + 1] = {
                Time = (sourceMs / 1000) * scale,
                SourceTime = sourceMs / 1000,
                Notes = notes,
                Index = #timeline.Events + 1,
            }
        end
    end
    timeline.BufferedUntil = ((tonumber(chunk and chunk.chunkEndMs) or 0) / 1000) * scale
end

local function openProtectedSession(entry, bpm, startSourceSeconds, replaceStream, shouldContinue)
    if not ProtectedClient then
        return nil, nil, nil, "Protected playback client could not load"
    end

    local stream, chunks, openError = ProtectedClient:OpenAndPrime(
        entry,
        startSourceSeconds,
        replaceStream,
        shouldContinue
    )
    if not stream then
        return nil, nil, nil, openError
    end

    stream.StartMs = math.max(0, (tonumber(startSourceSeconds) or 0) * 1000)
    local scale = protectedTimeScale(stream, bpm)
    local song = {
        Id = entry.Id,
        Name = entry.Name,
        Artist = entry.Artist,
        BPM = tonumber(stream.BaseBPM) or tonumber(entry.BPM) or bpm,
        Protected = true,
        Complete = true,
        Categories = entry.Categories,
    }
    local timeline = {
        BPM = bpm,
        StepsPerBeat = nil,
        StepDuration = nil,
        Events = {},
        Duration = (tonumber(stream.DurationMs) or 0) / 1000 * scale,
        BufferedUntil = 0,
        Protected = true,
    }
    for _, chunk in ipairs(chunks or {}) do
        appendProtectedChunk(timeline, stream, chunk, bpm)
    end
    return song, timeline, stream
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
    local source = safeGet(url .. (url:find("?", 1, true) and "&" or "?") .. "v=" .. CONFIG.AssetRevision)
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

local function installProtectedSession(song, timeline, stream, startSourceSeconds)
    state.StreamGeneration += 1
    stream.Generation = state.StreamGeneration
    state.ProtectedStream = stream
    state.CurrentSong = song or state.CurrentSong
    state.Timeline = timeline
    state.Position = (tonumber(startSourceSeconds) or 0) * protectedTimeScale(stream, state.CurrentBPM)
    state.NextEvent = 1
    state.Buffering = false
    state.StreamError = nil
    state.LastPlaybackError = nil
    state.PendingSeekProgress = nil
end

local function currentProtectedSourcePosition()
    local stream = state.ProtectedStream
    if not stream then
        return tonumber(state.PendingProtectedSource) or 0
    end
    return state.Position / protectedTimeScale(stream, state.CurrentBPM)
end

local function restartProtectedSession(startSourceSeconds, shouldContinue)
    if not isProtectedEntry(state.CurrentEntry) then
        return false, "Current song is not protected"
    end
    local previousStream = state.ProtectedStream
    local song, timeline, stream, streamError = openProtectedSession(
        state.CurrentEntry,
        state.CurrentBPM or state.CurrentEntry.BPM,
        startSourceSeconds,
        previousStream,
        shouldContinue
    )
    if not stream then
        return false, streamError
    end
    installProtectedSession(song, timeline, stream, startSourceSeconds)
    state.PendingProtectedSource = nil
    return true
end

local function requestProtectedChunk()
    local stream = state.ProtectedStream
    if not stream or stream.Fetching or stream.Ended or state.StreamError or not ProtectedClient then
        return
    end

    stream.Fetching = true
    local generation = stream.Generation
    task.spawn(function()
        local chunk, chunkError, errorKind = ProtectedClient:Next(stream)
        stream.Fetching = false
        if state.Destroyed or not state.ProtectedStream or state.ProtectedStream.Generation ~= generation then
            return
        end

        if chunk then
            appendProtectedChunk(state.Timeline, stream, chunk, state.CurrentBPM)
            if state.Buffering then
                state.Buffering = false
                emit("stream-ready")
            end
            return
        end

        if errorKind == "expired" then
            local sourcePosition = currentProtectedSourcePosition()
            local song, timeline, recovered, recoveryError = openProtectedSession(
                state.CurrentEntry,
                state.CurrentBPM,
                sourcePosition,
                stream,
                function()
                    return not state.Destroyed and state.ProtectedStream == stream
                        and stream.Generation == generation
                end
            )
            if state.Destroyed or not state.ProtectedStream or state.ProtectedStream.Generation ~= generation then
                return
            end
            if recovered then
                installProtectedSession(song, timeline, recovered, sourcePosition)
                emit("stream-ready")
                return
            end
            chunkError = recoveryError
        end

        state.StreamError = chunkError or "Protected playback stream failed"
        emit("stream-warning")
    end)
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

    state.SeekGeneration += 1
    local loadGeneration = state.SeekGeneration
    state.SeekResumeMode = nil
    state.PendingSeekProgress = nil
    state.Buffering = false
    state.StreamError = nil

    local song, timeline, protectedStream, loadError
    local bpm = math.clamp(tonumber(entry.BPM) or 120, 30, 300)
    if isProtectedEntry(entry) then
        local previousStream = state.ProtectedStream
        song, timeline, protectedStream, loadError = openProtectedSession(
            entry,
            bpm,
            0,
            previousStream,
            function()
                return not state.Destroyed and loadGeneration == state.SeekGeneration
            end
        )
    else
        song, loadError = loadSongData(entry)
        if song then
            bpm = math.clamp(tonumber(song.BPM or entry.BPM) or 120, 30, 300)
            timeline = parseSheet(song.Notes or "", bpm, song.StepsPerBeat)
        end
    end

    if loadGeneration ~= state.SeekGeneration then
        return false, "Protected song load was cancelled"
    end

    if not song or not timeline then
        warn("[Velora] " .. tostring(loadError))
        state.Buffering = false
        state.StreamError = nil
        state.LastPlaybackError = loadError
        emit("error")
        return false, loadError
    end

    stopConnection()
    state.SeekResumeMode = nil
    state.PendingSeekProgress = nil
    state.CurrentEntry = entry
    state.SelectedEntryId = entry.Id
    state.PendingEntryId = nil
    state.CurrentBPM = bpm
    state.Playing = false
    state.Paused = false
    state.PendingProtectedSource = nil

    if protectedStream then
        installProtectedSession(song, timeline, protectedStream, 0)
    else
        state.StreamGeneration += 1
        state.ProtectedStream = nil
        state.Buffering = false
        state.StreamError = nil
        state.CurrentSong = song
        state.Timeline = timeline
        state.Position = 0
        state.NextEvent = 1
    end

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

    if isProtectedEntry(state.CurrentEntry) and not state.ProtectedStream then
        local startSource = tonumber(state.PendingProtectedSource) or 0
        state.SeekGeneration += 1
        state.SeekResumeMode = nil
        local restarted, restartError = restartProtectedSession(startSource)
        if not restarted then
            state.Buffering = false
            state.StreamError = nil
            state.LastPlaybackError = restartError
            emit("stream-error")
            return false, restartError
        end
    end

    if not state.Timeline or (#state.Timeline.Events == 0 and not state.Timeline.Protected) then
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
        if state.Timeline.Protected then
            local previousStream = state.ProtectedStream
            local song, timeline, replacement, restartError = openProtectedSession(
                state.CurrentEntry,
                state.CurrentBPM,
                0,
                previousStream
            )
            if not replacement then
                state.StreamError = nil
                state.LastPlaybackError = restartError
                emit("stream-error")
                return false, restartError
            end
            installProtectedSession(song, timeline, replacement, 0)
            state.PendingProtectedSource = nil
        else
            state.Position = 0
            state.NextEvent = 1
        end
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

        local protectedStream = state.ProtectedStream
        if state.Timeline.Protected and protectedStream then
            local sourcePosition = currentProtectedSourcePosition()
            local bufferedSource = (tonumber(protectedStream.BufferedUntilMs) or 0) / 1000
            if not protectedStream.Ended and bufferedSource - sourcePosition < 5 then
                requestProtectedChunk()
            end
            if not protectedStream.Ended and sourcePosition >= bufferedSource - 0.05 then
                if state.StreamError then
                    stopConnection()
                    state.Playing = false
                    state.Paused = false
                    state.Buffering = false
                    emit("stream-error")
                elseif not state.Buffering then
                    state.Buffering = true
                    emit("buffering")
                    requestProtectedChunk()
                end
                return
            elseif state.Buffering then
                state.Buffering = false
                emit("stream-ready")
            end
        end

        state.Position += dt * state.Speed

        local events = state.Timeline.Events
        while state.NextEvent <= #events and events[state.NextEvent].Time <= state.Position do
            local event = events[state.NextEvent]
            noteOutputGroup(event.Notes)
            state.NextEvent += 1
        end

        if state.Timeline.Protected and state.NextEvent > 64 then
            for _ = 1, state.NextEvent - 1 do
                table.remove(events, 1)
            end
            state.NextEvent = 1
        end

        if state.Position >= state.Timeline.Duration then
            if state.Loop then
                if state.Timeline.Protected then
                    emit("looped")
                    self:Seek(0)
                else
                    state.Position = 0
                    state.NextEvent = 1
                    emit("looped")
                end
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
    local activeStream = state.ProtectedStream
    if activeStream then
        activeStream.Fetching = false
    end
    state.SeekGeneration += 1
    state.SeekResumeMode = nil
    state.PendingSeekProgress = nil
    local hadState = state.Playing or state.Paused or state.Buffering or state.Position > 0
    local protected = state.Timeline and state.Timeline.Protected
    state.Playing = false
    state.Paused = false
    state.Buffering = false
    state.StreamError = nil
    state.LastPlaybackError = nil
    state.Position = 0
    state.NextEvent = 1
    if protected then
        state.StreamGeneration += 1
        state.ProtectedStream = nil
        state.PendingProtectedSource = 0
        state.Timeline.Events = {}
        state.Timeline.BufferedUntil = 0
    end
    if hadState then
        emit("stopped")
    end
end

function API:Seek(progress)
    if not state.Timeline then
        return false
    end

    progress = math.clamp(tonumber(progress) or 0, 0, 1)

    if state.Timeline.Protected and isProtectedEntry(state.CurrentEntry) then
        local stream = state.ProtectedStream
        local sourceDuration = stream and (tonumber(stream.DurationMs) or 0) / 1000
            or tonumber(state.CurrentEntry.Protected.Duration) or 0
        local sourceTarget = sourceDuration * progress
        local previousSource = currentProtectedSourcePosition()
        local resumeMode = state.SeekResumeMode
            or (state.Playing and not state.Paused and "playing")
            or (state.Paused and "paused")
            or "ready"
        local previousPosition = state.Position
        local previousEntry = state.CurrentEntry
        local previousStream = state.ProtectedStream

        stopConnection()
        state.Playing = false
        state.Paused = false
        state.Buffering = true
        state.StreamError = nil
        state.LastPlaybackError = nil
        state.SeekResumeMode = resumeMode
        state.PendingSeekProgress = progress
        state.SeekGeneration += 1
        local seekGeneration = state.SeekGeneration

        task.spawn(function()
            local function seekIsCurrent()
                return not state.Destroyed and seekGeneration == state.SeekGeneration
                    and state.CurrentEntry == previousEntry
            end

            local song, timeline, replacement, seekError = openProtectedSession(
                previousEntry,
                state.CurrentBPM or previousEntry.BPM,
                sourceTarget,
                previousStream,
                seekIsCurrent
            )
            if not seekIsCurrent() then
                return
            end

            state.SeekResumeMode = nil
            state.PendingSeekProgress = nil
            state.Buffering = false
            state.StreamError = nil
            if not replacement then
                state.Position = previousPosition
                state.PendingProtectedSource = previousStream and nil or previousSource
                state.LastPlaybackError = seekError or "Protected seek failed; the previous position was restored"
                emit("seek-error")
                if resumeMode == "playing" then
                    self:Play()
                elseif resumeMode == "paused" and self:Play() then
                    self:Pause()
                end
                return
            end

            installProtectedSession(song, timeline, replacement, sourceTarget)
            state.PendingProtectedSource = nil
            emit("seek")
            if resumeMode == "playing" then
                self:Play()
            elseif resumeMode == "paused" then
                if self:Play() then
                    self:Pause()
                end
            end
        end)
        emit("buffering")
        return true
    end

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

    if state.Timeline and state.Timeline.Protected and isProtectedEntry(state.CurrentEntry) then
        local sourcePosition = currentProtectedSourcePosition()
        local song, timeline, stream, streamError = openProtectedSession(
            state.CurrentEntry,
            bpm,
            sourcePosition,
            state.ProtectedStream
        )
        if not stream then
            warn("[Velora] " .. tostring(streamError))
            state.Buffering = false
            state.StreamError = nil
            state.LastPlaybackError = streamError
            return nil
        end

        stopConnection()
        state.SeekGeneration += 1
        state.SeekResumeMode = nil
        state.PendingSeekProgress = nil
        state.CurrentBPM = bpm
        state.Playing = false
        state.Paused = false
        installProtectedSession(song, timeline, stream, sourcePosition)

        if playing then
            self:Play()
        elseif paused then
            self:Play()
            self:Pause()
        end

        emit("bpm")
        return bpm
    end

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
    local enabled = state.Favorites[id] ~= true
    state.Favorites[id] = enabled and true or nil
    saveFavorites(state.Favorites)
    emit("favorites")
    return enabled
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
        Buffering = state.Buffering,
        StreamError = state.StreamError,
        PendingSeekProgress = state.PendingSeekProgress,
        Protected = state.Timeline and state.Timeline.Protected == true,
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
    for k,v in pairs(props or {}) do
        local ok,propertyError=pcall(function() o[k]=v end)
        if not ok then warn("[Velora UI] Skipped "..className.."."..tostring(k)..": "..tostring(propertyError)) end
    end
    local ok,parentError=pcall(function() o.Parent=parent end)
    if not ok then warn("[Velora UI] Could not parent "..className..": "..tostring(parentError)) end
    return o
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

local marqueeTracks=setmetatable({}, {__mode="k"})
local function marqueeLabel(parent,textValue,pos,size,font,sizePx,color)
    local clip=make("Frame",{BackgroundTransparency=1,Position=pos,Size=size,ClipsDescendants=true},parent)
    local first=label(clip,textValue,UDim2.fromOffset(0,0),UDim2.fromScale(1,1),font,sizePx,color)
    local second=label(clip,textValue,UDim2.fromOffset(0,0),UDim2.fromScale(1,1),font,sizePx,color)
    second.Visible=false

    local function syncMarquee()
        if not clip.Parent then return end
        second.Text=first.Text
        second.TextColor3=first.TextColor3
        local availableWidth=clip.AbsoluteSize.X
        local availableHeight=math.max(1,clip.AbsoluteSize.Y)
        local bounds=TextService:GetTextSize(first.Text,first.TextSize,first.Font,Vector2.new(10000,availableHeight))
        local textWidth=math.ceil(bounds.X)+2
        first.Size=UDim2.fromOffset(textWidth,availableHeight)
        second.Size=UDim2.fromOffset(textWidth,availableHeight)

        if availableWidth>0 and textWidth>availableWidth then
            local distance=textWidth+28
            first.Position=UDim2.fromOffset(0,0)
            second.Position=UDim2.fromOffset(distance,0)
            second.Visible=true
            marqueeTracks[clip]={First=first,Second=second,Distance=distance,Start=os.clock()+1.15,Speed=24}
        else
            first.Position=UDim2.fromOffset(0,0)
            second.Visible=false
            marqueeTracks[clip]=nil
        end
    end

    first:GetPropertyChangedSignal("Text"):Connect(syncMarquee)
    first:GetPropertyChangedSignal("TextColor3"):Connect(syncMarquee)
    clip:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncMarquee)
    task.defer(syncMarquee)
    return first,clip
end

local function updateMarquees(now)
    for clip,item in pairs(marqueeTracks) do
        if not clip.Parent or not item.First.Parent or not item.Second.Parent then
            marqueeTracks[clip]=nil
        elseif now<item.Start then
            item.First.Position=UDim2.fromOffset(0,0)
            item.Second.Position=UDim2.fromOffset(item.Distance,0)
        else
            local offset=((now-item.Start)*item.Speed)%item.Distance
            item.First.Position=UDim2.fromOffset(-offset,0)
            item.Second.Position=UDim2.fromOffset(item.Distance-offset,0)
        end
    end
end

local liveTweens=setmetatable({}, {__mode="k"})
local function animate(o,props,time)
    local previous=liveTweens[o]
    if previous then previous:Cancel() end
    local motion=TweenService:Create(o,TweenInfo.new(time or .16,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
    liveTweens[o]=motion
    motion:Play()
    return motion
end
local function clock(seconds)
    seconds=math.max(0,tonumber(seconds) or 0)
    return string.format("%d:%02d",math.floor(seconds/60),math.floor(seconds%60))
end

local P={
    Ink=Color3.fromRGB(6,5,6),Surface=Color3.fromRGB(15,11,12),Card=Color3.fromRGB(25,17,19),
    Lift=Color3.fromRGB(39,25,28),Text=Color3.fromRGB(255,248,249),Sub=Color3.fromRGB(223,205,208),
    Muted=Color3.fromRGB(163,137,142),Violet=Color3.fromRGB(211,76,90),Pink=Color3.fromRGB(127,31,42),
    Cyan=Color3.fromRGB(243,128,138),Green=Color3.fromRGB(232,101,113),
}
local nova={}
nova.glassLayers=setmetatable({}, {__mode="k"})

function nova.glassify(object,backgroundTransparency,tint)
    if not object then return object end
    object.BackgroundTransparency=backgroundTransparency or .12
    tint=tint or P.Violet
    local surface=object:FindFirstChildOfClass("UIGradient")
    if not surface then
        surface=make("UIGradient",{
            Name="GlassSurface",
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(62,43,47)),
                ColorSequenceKeypoint.new(.34,tint:Lerp(Color3.fromRGB(22,17,18),.72)),
                ColorSequenceKeypoint.new(1,P.Ink),
            }),
            Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,.28),
                NumberSequenceKeypoint.new(.46,.48),
                NumberSequenceKeypoint.new(1,.36),
            }),
            Rotation=112,
        },object)
    end
    local stroke=object:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke=make("UIStroke",{Color=Color3.fromRGB(190,116,125),Transparency=.46,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},object)
    end
    stroke.Color=tint:Lerp(Color3.fromRGB(225,181,186),.42)
    stroke.Transparency=math.min(stroke.Transparency,.56)
    stroke.Thickness=math.max(stroke.Thickness,1)
    local rim=stroke:FindFirstChild("GlassRim")
    if not rim then
        rim=make("UIGradient",{
            Name="GlassRim",
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(235,194,198)),
                ColorSequenceKeypoint.new(.48,tint:Lerp(Color3.fromRGB(225,174,180),.34)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(115,49,57)),
            }),
            Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,.18),
                NumberSequenceKeypoint.new(.45,.58),
                NumberSequenceKeypoint.new(1,.34),
            }),
            Rotation=32,
        },stroke)
    end
    nova.glassLayers[object]={Surface=surface,Stroke=rim}
    return object
end

function nova.disposeVisuals()
    if nova.blur then nova.blur:Destroy();nova.blur=nil end
end

nova.gui=make("ScreenGui",{Name="Velora",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=78,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)
nova.shadow=radius(make("Frame",{Visible=false,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),Size=UDim2.fromOffset(760,440),BackgroundTransparency=1,BorderSizePixel=0},nova.gui),24)
local window=radius(edge(gradient(make("Frame",{Name="Aurora",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(760,440),BackgroundColor3=P.Ink,BorderSizePixel=0,ClipsDescendants=true},nova.gui),Color3.fromRGB(19,11,13),Color3.fromRGB(5,4,5),32),Color3.fromRGB(123,54,63),.66,1),24)
nova.windowBorder=window:FindFirstChildOfClass("UIStroke")
nova.glassify(window,.04,P.Violet)

local header=radius(edge(gradient(make("Frame",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,64),BackgroundColor3=P.Surface,BorderSizePixel=0},window),Color3.fromRGB(38,18,22),Color3.fromRGB(12,9,10),16),Color3.fromRGB(147,67,76),.52),18)
nova.headerBorder=header:FindFirstChildOfClass("UIStroke")
nova.headerGlow,nova.headerRim=glowEdge(header,P.Violet,.91,.55,3.2)
nova.glassify(header,.08,P.Violet)
local logo=radius(gradient(make("Frame",{Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(44,44),BackgroundColor3=P.Card,BorderSizePixel=0},header),Color3.fromRGB(30,20,22),P.Ink,45),14)
nova.logoGlow,nova.logoRim=glowEdge(logo,P.Violet,.76,.28,3.4)
nova.logoText=label(logo,"🥀",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.BuilderSans,21,P.Text);nova.logoText.TextXAlignment=Enum.TextXAlignment.Center
nova.brandTitle=label(header,"VELORA",UDim2.fromOffset(68,10),UDim2.fromOffset(190,24),Enum.Font.BuilderSansExtraBold,20,P.Text)
nova.brandSubtitle=label(header,"MADE BY SALTY",UDim2.fromOffset(69,35),UDim2.fromOffset(210,14),Enum.Font.BuilderSansBold,9,Color3.fromRGB(222,202,205))

local settingsButton=radius(edge(make("TextButton",{Position=UDim2.new(1,-98,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),Color3.fromRGB(118,58,65),.58),12)
local settingsIcon=icon(settingsButton,"settings",17,P.Sub,"");settingsIcon.AnchorPoint=Vector2.new(.5,.5);settingsIcon.Position=UDim2.fromScale(.5,.5)
nova.minimizeButton=radius(edge(make("TextButton",{Position=UDim2.new(1,-144,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),Color3.fromRGB(118,58,65),.58),12)
nova.minimizeIcon=icon(nova.minimizeButton,"minimize-2",17,P.Sub,"");nova.minimizeIcon.AnchorPoint=Vector2.new(.5,.5);nova.minimizeIcon.Position=UDim2.fromScale(.5,.5)
nova.restoreIcon=icon(nova.minimizeButton,"maximize-2",17,P.Sub,"");nova.restoreIcon.AnchorPoint=Vector2.new(.5,.5);nova.restoreIcon.Position=UDim2.fromScale(.5,.5);nova.restoreIcon.Visible=false
nova.close=radius(make("TextButton",{Position=UDim2.new(1,-52,0,14),Size=UDim2.fromOffset(36,36),BackgroundColor3=Color3.fromRGB(27,19,21),BorderSizePixel=0,AutoButtonColor=false,Text=""},header),12)
nova.closeIcon=icon(nova.close,"x",18,P.Sub,"");nova.closeIcon.AnchorPoint=Vector2.new(.5,.5);nova.closeIcon.Position=UDim2.fromScale(.5,.5)
for _,object in ipairs({settingsButton,nova.minimizeButton,nova.close}) do nova.glassify(object,.24,P.Violet) end

nova.compactMode=false
nova.windowScale=make("UIScale",{Scale=1},window)
nova.shadowScale=make("UIScale",{Scale=1},nova.shadow)
local function fitViewport(duration)
    local camera=workspace.CurrentCamera
    if not camera then return end
    local view=camera.ViewportSize
    local baseWidth=nova.compactMode and 316 or 810
    local value=math.min(1,math.max(.68,math.min(view.X/baseWidth,view.Y/490)))
    if duration then
        animate(nova.windowScale,{Scale=value},duration)
        animate(nova.shadowScale,{Scale=value},duration)
    else
        nova.windowScale.Scale=value
        nova.shadowScale.Scale=value
    end
end
local fitOk,fitError=pcall(fitViewport)
if not fitOk then warn("[Velora UI] Viewport fit skipped: "..tostring(fitError)) end
if workspace.CurrentCamera then
    local signalOk,signalError=pcall(function()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitViewport)
    end)
    if not signalOk then warn("[Velora UI] Viewport listener skipped: "..tostring(signalError)) end
end

nova.body=make("Frame",{Position=UDim2.fromOffset(14,90),Size=UDim2.new(1,-28,1,-104),BackgroundTransparency=1},window)
nova.nav=radius(edge(make("Frame",{Size=UDim2.fromOffset(148,336),BackgroundColor3=P.Surface,BackgroundTransparency=.18,BorderSizePixel=0},nova.body),Color3.fromRGB(88,81,119),.60),18)
nova.navBorder=nova.nav:FindFirstChildOfClass("UIStroke")
nova.navGlow,nova.navRim=glowEdge(nova.nav,P.Violet,.94,.66,2.5)
nova.browser=radius(edge(make("Frame",{Position=UDim2.fromOffset(158,0),Size=UDim2.fromOffset(326,336),BackgroundColor3=P.Surface,BackgroundTransparency=.18,BorderSizePixel=0},nova.body),Color3.fromRGB(88,81,119),.60),18)
nova.browserBorder=nova.browser:FindFirstChildOfClass("UIStroke")
nova.browserGlow,nova.browserRim=glowEdge(nova.browser,P.Violet,.92,.60,2.5)
nova.navScale=make("UIScale",{Scale=1},nova.nav)
nova.browserScale=make("UIScale",{Scale=1},nova.browser)
nova.playerCard=radius(edge(make("Frame",{Position=UDim2.fromOffset(494,0),Size=UDim2.fromOffset(238,336),BackgroundColor3=P.Surface,BackgroundTransparency=.20,BorderSizePixel=0},nova.body),Color3.fromRGB(106,88,153),.61),18)
nova.playerBorder=nova.playerCard:FindFirstChildOfClass("UIStroke")
nova.playerGlow,nova.playerRim=glowEdge(nova.playerCard,P.Violet,.91,.55,3.2)
nova.glassify(nova.nav,.08,P.Violet)
nova.glassify(nova.browser,.08,P.Violet)
nova.glassify(nova.playerCard,.06,P.Violet)

label(nova.nav,"DISCOVER",UDim2.fromOffset(16,16),UDim2.fromOffset(116,14),Enum.Font.BuilderSansExtraBold,10,P.Sub)
nova.navList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,42),Size=UDim2.fromOffset(128,215),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=P.Violet,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},nova.nav)
make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},nova.navList)
padding(nova.navList,0,4,0,4)
local activeFilter="All Songs"
local searchQuery=""
local navButtons={}
local refreshList

nova.search=radius(edge(make("TextBox",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,38),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Search the library",PlaceholderColor3=Color3.fromRGB(245,230,233),Text="",TextSize=12,TextColor3=P.Text,Font=Enum.Font.BuilderSansBold,TextXAlignment=Enum.TextXAlignment.Left},nova.browser),Color3.fromRGB(126,58,67),.48),12)
nova.searchBorder=nova.search:FindFirstChildOfClass("UIStroke")
nova.searchGlow,nova.searchRim=glowEdge(nova.search,P.Violet,.95,.68,2.6)
padding(nova.search,39,13,0,0)
nova.searchIcon=icon(nova.browser,"search",15,P.Sub,"");nova.searchIcon.Position=UDim2.fromOffset(27,26)
nova.search.Focused:Connect(function() animate(nova.searchGlow,{Transparency=.78});animate(nova.searchRim,{Transparency=.18}) end)
nova.search.FocusLost:Connect(function() animate(nova.searchGlow,{Transparency=.95});animate(nova.searchRim,{Transparency=.68}) end)
nova.resultTitle=label(nova.browser,"ALL SONGS",UDim2.fromOffset(16,62),UDim2.fromOffset(200,20),Enum.Font.BuilderSansExtraBold,12,P.Text)
nova.viewCountPill=radius(edge(make("Frame",{Position=UDim2.new(1,-88,0,62),Size=UDim2.fromOffset(74,20),BackgroundColor3=P.Card,BackgroundTransparency=.02,BorderSizePixel=0},nova.browser),P.Violet,.72,1),9)
nova.viewCountBorder=nova.viewCountPill:FindFirstChildOfClass("UIStroke")
nova.glassify(nova.viewCountPill,.28,P.Violet)
nova.viewCountText=label(nova.viewCountPill,"0 TRACKS",UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.BuilderSansExtraBold,8,P.Sub);nova.viewCountText.TextXAlignment=Enum.TextXAlignment.Center
nova.songList=make("ScrollingFrame",{Position=UDim2.fromOffset(10,88),Size=UDim2.new(1,-20,1,-98),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=P.Violet,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},nova.browser)
make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},nova.songList)
padding(nova.songList,2,5,4,5)

label(nova.playerCard,"NOW PLAYING",UDim2.fromOffset(16,14),UDim2.fromOffset(160,14),Enum.Font.BuilderSansBold,9,P.Muted)
nova.playbackBadge=radius(edge(make("Frame",{Position=UDim2.new(1,-88,0,10),Size=UDim2.fromOffset(72,20),BackgroundColor3=P.Card,BackgroundTransparency=.02,BorderSizePixel=0},nova.playerCard),P.Green,.68,1),9)
nova.playbackBadgeBorder=nova.playbackBadge:FindFirstChildOfClass("UIStroke")
nova.glassify(nova.playbackBadge,.24,P.Green)
nova.playbackDot=radius(make("Frame",{Position=UDim2.fromOffset(9,7),Size=UDim2.fromOffset(6,6),BackgroundColor3=P.Green,BorderSizePixel=0},nova.playbackBadge),6)
nova.playbackStatus=label(nova.playbackBadge,"READY",UDim2.fromOffset(20,0),UDim2.fromOffset(45,20),Enum.Font.BuilderSansExtraBold,8,P.Sub)
function nova.setPlaybackBadgeText(textValue)
    if nova.playbackStatus.Text~=textValue then nova.playbackStatus.Text=textValue end
    local bounds=TextService:GetTextSize(textValue,nova.playbackStatus.TextSize,nova.playbackStatus.Font,Vector2.new(200,20))
    local width=math.max(48,math.ceil(bounds.X)+31)
    nova.playbackBadge.Size=UDim2.fromOffset(width,20)
    nova.playbackBadge.Position=UDim2.new(1,-(16+width),0,10)
    nova.playbackStatus.Size=UDim2.fromOffset(math.ceil(bounds.X)+2,20)
end
nova.setPlaybackBadgeText("READY")
local art=radius(gradient(make("Frame",{Position=UDim2.fromOffset(16,39),Size=UDim2.fromOffset(72,72),BackgroundColor3=P.Card,BorderSizePixel=0},nova.playerCard),Color3.fromRGB(34,20,23),P.Ink,45),18)
nova.artBorderGlow,nova.artBorderRim=glowEdge(art,P.Violet,.80,.20,4.5)
nova.artGlow=radius(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(44,44),BackgroundColor3=P.Violet,BackgroundTransparency=.72,BorderSizePixel=0},art),22)
nova.artIcon=icon(nova.artGlow,"music-2",23,P.Cyan,"");nova.artIcon.AnchorPoint=Vector2.new(.5,.5);nova.artIcon.Position=UDim2.fromScale(.5,.5)
nova.nowTitle=marqueeLabel(nova.playerCard,"Choose a song",UDim2.fromOffset(101,45),UDim2.fromOffset(122,38),Enum.Font.BuilderSansExtraBold,14,P.Text)
nova.nowMeta=marqueeLabel(nova.playerCard,"Ready when you are",UDim2.fromOffset(101,86),UDim2.fromOffset(122,18),Enum.Font.BuilderSansMedium,9,P.Sub)

nova.progress=radius(make("Frame",{Position=UDim2.fromOffset(16,127),Size=UDim2.fromOffset(206,8),BackgroundColor3=Color3.fromRGB(38,25,28),BorderSizePixel=0},nova.playerCard),4)
nova.progressGlow,nova.progressRim=glowEdge(nova.progress,P.Violet,.94,.54,2.4)
local fill=radius(gradient(make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=P.Violet,BorderSizePixel=0},nova.progress),P.Cyan,P.Pink,0),4)
nova.scrubber=radius(edge(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(15,15),BackgroundColor3=P.Text,BorderSizePixel=0,ZIndex=4},nova.progress),P.Violet,.15),8)
nova.seekHit=make("TextButton",{Position=UDim2.fromOffset(16,119),Size=UDim2.fromOffset(206,24),BackgroundTransparency=1,BorderSizePixel=0,Text="",ZIndex=5},nova.playerCard)
nova.timeLeft=label(nova.playerCard,"0:00",UDim2.fromOffset(16,139),UDim2.fromOffset(70,13),Enum.Font.BuilderSansMedium,8,P.Sub)
nova.timeRight=label(nova.playerCard,"0:00",UDim2.fromOffset(152,139),UDim2.fromOffset(70,13),Enum.Font.BuilderSansMedium,8,P.Sub);nova.timeRight.TextXAlignment=Enum.TextXAlignment.Right

nova.stop=radius(make("TextButton",{Position=UDim2.fromOffset(16,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),15)
nova.stopIcon=icon(nova.stop,"square",17,P.Sub,"");nova.stopIcon.AnchorPoint=Vector2.new(.5,.5);nova.stopIcon.Position=UDim2.fromScale(.5,.5)
local play=radius(edge(gradient(make("TextButton",{Position=UDim2.fromOffset(76,157),Size=UDim2.fromOffset(86,62),BackgroundColor3=P.Violet,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),P.Violet,P.Pink,35),Color3.new(1,1,1),.76),20)
nova.playBorder=play:FindFirstChildOfClass("UIStroke")
nova.playGlow,nova.playRim=glowEdge(play,P.Violet,.78,.12,5)
nova.playIcon=icon(play,"play",25,P.Text,"");nova.playIcon.AnchorPoint=Vector2.new(.5,.5);nova.playIcon.Position=UDim2.fromScale(.5,.5)
nova.pauseIcon=icon(play,"pause",25,P.Text,"");nova.pauseIcon.AnchorPoint=Vector2.new(.5,.5);nova.pauseIcon.Position=UDim2.fromScale(.5,.5);nova.pauseIcon.Visible=false
nova.favorite=radius(make("TextButton",{Position=UDim2.fromOffset(172,165),Size=UDim2.fromOffset(50,46),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),15)
nova.favoriteIcon=icon(nova.favorite,"heart",20,P.Sub,"");nova.favoriteIcon.AnchorPoint=Vector2.new(.5,.5);nova.favoriteIcon.Position=UDim2.fromScale(.5,.5)

label(nova.playerCard,"TEMPO",UDim2.fromOffset(19,218),UDim2.fromOffset(120,12),Enum.Font.BuilderSansExtraBold,8,P.Muted)
nova.loopLabel=label(nova.playerCard,"LOOP",UDim2.fromOffset(157,218),UDim2.fromOffset(62,12),Enum.Font.BuilderSansExtraBold,8,P.Muted);nova.loopLabel.TextXAlignment=Enum.TextXAlignment.Center
nova.bpmPill=radius(edge(make("Frame",{Position=UDim2.fromOffset(16,232),Size=UDim2.fromOffset(128,38),BackgroundColor3=P.Card,BorderSizePixel=0},nova.playerCard),P.Violet,.74,1),13)
nova.bpmBorder=nova.bpmPill:FindFirstChildOfClass("UIStroke")
nova.bpmDown=radius(make("TextButton",{Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(30,30),BackgroundColor3=P.Lift,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.bpmPill),10)
nova.bpmDownIcon=icon(nova.bpmDown,"chevron-left",16,P.Sub,"");nova.bpmDownIcon.AnchorPoint=Vector2.new(.5,.5);nova.bpmDownIcon.Position=UDim2.fromScale(.5,.5)
nova.bpm=make("TextBox",{Position=UDim2.fromOffset(38,0),Size=UDim2.fromOffset(52,38),BackgroundTransparency=1,ClearTextOnFocus=false,Font=Enum.Font.BuilderSansExtraBold,Text="120",TextSize=10,TextColor3=P.Text},nova.bpmPill)
nova.bpmUp=radius(make("TextButton",{Position=UDim2.fromOffset(94,4),Size=UDim2.fromOffset(30,30),BackgroundColor3=P.Lift,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.bpmPill),10)
nova.bpmUpIcon=icon(nova.bpmUp,"chevron-right",16,P.Sub,"");nova.bpmUpIcon.AnchorPoint=Vector2.new(.5,.5);nova.bpmUpIcon.Position=UDim2.fromScale(.5,.5)
nova.loop=radius(edge(make("TextButton",{Position=UDim2.fromOffset(154,232),Size=UDim2.fromOffset(68,38),BackgroundColor3=P.Card,BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),P.Violet,.76,1),13)
nova.loopBorder=nova.loop:FindFirstChildOfClass("UIStroke")
nova.loopIcon=icon(nova.loop,"repeat-2",18,P.Sub,"");nova.loopIcon.AnchorPoint=Vector2.new(.5,.5);nova.loopIcon.Position=UDim2.fromScale(.5,.5)
nova.resetBpm=radius(edge(make("TextButton",{Position=UDim2.fromOffset(16,283),Size=UDim2.fromOffset(206,37),BackgroundColor3=Color3.fromRGB(27,25,40),BorderSizePixel=0,AutoButtonColor=false,Text=""},nova.playerCard),P.Violet,.66,1),12)
nova.resetBorder=nova.resetBpm:FindFirstChildOfClass("UIStroke")
nova.resetGlow,nova.resetRim=glowEdge(nova.resetBpm,P.Violet,.91,.50,3)
nova.resetIcon=icon(nova.resetBpm,"rotate-ccw",15,P.Sub,"");nova.resetIcon.AnchorPoint=Vector2.new(.5,.5);nova.resetIcon.Position=UDim2.fromOffset(19,18)
label(nova.resetBpm,"RESET BPM",UDim2.fromOffset(35,4),UDim2.fromOffset(158,14),Enum.Font.BuilderSansExtraBold,10,P.Text)
nova.feedback=label(nova.resetBpm,"Restore the song's original tempo",UDim2.fromOffset(35,18),UDim2.fromOffset(158,13),Enum.Font.BuilderSansMedium,8,P.Sub)
nova.feedback.TextTruncate=Enum.TextTruncate.AtEnd
nova.glassify(art,.08,P.Violet)
nova.glassify(play,.08,P.Violet)
nova.glassify(nova.progress,.18,P.Violet)
for _,object in ipairs({nova.stop,nova.favorite,nova.bpmPill,nova.bpmDown,nova.bpmUp,nova.loop,nova.resetBpm}) do
    nova.glassify(object,.26,P.Violet)
end
local function bindButtonMotion(button)
    local scale=make("UIScale",{Scale=1},button)
    button.MouseButton1Down:Connect(function() animate(scale,{Scale=.965},.06) end)
    button.MouseButton1Up:Connect(function() animate(scale,{Scale=1},.09) end)
    return scale
end

bindButtonMotion(settingsButton)
bindButtonMotion(nova.minimizeButton)
bindButtonMotion(nova.close)
bindButtonMotion(nova.stop)
bindButtonMotion(play)
bindButtonMotion(nova.favorite)
bindButtonMotion(nova.bpmDown)
bindButtonMotion(nova.bpmUp)
bindButtonMotion(nova.loop)
bindButtonMotion(nova.resetBpm)

nova.libraryCount=radius(edge(gradient(make("Frame",{Position=UDim2.fromOffset(10,273),Size=UDim2.fromOffset(128,51),BackgroundColor3=P.Card,BorderSizePixel=0},nova.nav),P.Violet:Lerp(P.Ink,.74),P.Card,0),P.Violet,.68,1),14)
nova.libraryBorder=nova.libraryCount:FindFirstChildOfClass("UIStroke")
nova.libraryGlow,nova.libraryRim=glowEdge(nova.libraryCount,P.Violet,.94,.60,2.6)
nova.libraryIcon=icon(nova.libraryCount,"library",16,P.Cyan,"");nova.libraryIcon.AnchorPoint=Vector2.new(.5,.5);nova.libraryIcon.Position=UDim2.fromOffset(18,26)
label(nova.libraryCount,"AURORA LIBRARY",UDim2.fromOffset(33,8),UDim2.fromOffset(86,12),Enum.Font.BuilderSansBold,8,P.Sub)
nova.countText=label(nova.libraryCount,tostring(#state.Registry).." SONGS",UDim2.fromOffset(33,24),UDim2.fromOffset(86,16),Enum.Font.BuilderSansExtraBold,10,P.Text)

nova.paletteDim=radius(make("TextButton",{Visible=false,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.10,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=40},window),24)
nova.palette=radius(edge(make("Frame",{Visible=false,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,88),Size=UDim2.fromOffset(280,322),BackgroundColor3=Color3.fromRGB(10,7,8),BackgroundTransparency=0,BorderSizePixel=0,ZIndex=50},window),Color3.fromRGB(151,66,76),.25,1.2),20)
label(nova.palette,"PALETTE STUDIO",UDim2.fromOffset(18,16),UDim2.fromOffset(190,22),Enum.Font.BuilderSansExtraBold,13,P.Text).ZIndex=51
label(nova.palette,"Shape Velora around your favorite color.",UDim2.fromOffset(18,39),UDim2.fromOffset(235,16),Enum.Font.BuilderSans,8,P.Sub).ZIndex=51
nova.paletteClose=radius(make("TextButton",{Position=UDim2.new(1,-45,0,12),Size=UDim2.fromOffset(31,31),BackgroundColor3=P.Card,BorderSizePixel=0,Text="",ZIndex=52},nova.palette),10)
nova.paletteCloseIcon=icon(nova.paletteClose,"x",16,P.Sub,"");nova.paletteCloseIcon.AnchorPoint=Vector2.new(.5,.5);nova.paletteCloseIcon.Position=UDim2.fromScale(.5,.5);nova.paletteCloseIcon.ZIndex=53

nova.swatchColors={
    Color3.fromRGB(211,76,90),Color3.fromRGB(164,47,61),Color3.fromRGB(116,31,41),
    Color3.fromRGB(230,119,128),Color3.fromRGB(188,78,87),Color3.fromRGB(89,24,31),
}
nova.swatchRow=make("Frame",{Position=UDim2.fromOffset(18,70),Size=UDim2.fromOffset(244,38),BackgroundTransparency=1,ZIndex=51},nova.palette)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},nova.swatchRow)
nova.rgbInputs={}
for index,name in ipairs({"R","G","B"}) do
    label(nova.palette,name,UDim2.fromOffset(18+(index-1)*82,129),UDim2.fromOffset(20,16),Enum.Font.BuilderSansBold,8,P.Muted).ZIndex=51
    nova.rgbInputs[index]=radius(make("TextBox",{Position=UDim2.fromOffset(18+(index-1)*82,148),Size=UDim2.fromOffset(72,36),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,Text=({"211","76","90"})[index],Font=Enum.Font.BuilderSansBold,TextSize=10,TextColor3=P.Text,ZIndex=51},nova.palette),11)
end
label(nova.palette,"HEX",UDim2.fromOffset(18,202),UDim2.fromOffset(35,16),Enum.Font.BuilderSansBold,8,P.Muted).ZIndex=51
nova.hexInput=radius(make("TextBox",{Position=UDim2.fromOffset(18,221),Size=UDim2.fromOffset(158,40),BackgroundColor3=P.Card,BorderSizePixel=0,ClearTextOnFocus=false,Text="#D34C5A",Font=Enum.Font.Code,TextSize=11,TextColor3=P.Text,ZIndex=51},nova.palette),12)
nova.preview=radius(make("Frame",{Position=UDim2.fromOffset(188,221),Size=UDim2.fromOffset(74,40),BackgroundColor3=P.Violet,BorderSizePixel=0,ZIndex=51},nova.palette),12)
nova.applyColorButton=radius(make("TextButton",{Position=UDim2.fromOffset(18,276),Size=UDim2.fromOffset(244,31),BackgroundColor3=P.Violet,BorderSizePixel=0,Text="APPLY COLOR",Font=Enum.Font.BuilderSansExtraBold,TextSize=10,TextColor3=P.Text,ZIndex=51},nova.palette),11)
nova.glassify(nova.libraryCount,.24,P.Violet)
gradient(nova.palette,Color3.fromRGB(22,12,14),Color3.fromRGB(7,6,7),90)
nova.glassify(nova.paletteClose,.24,P.Violet)
bindButtonMotion(nova.paletteClose)
bindButtonMotion(nova.applyColorButton)

local function setPaletteVisible(visible)
    nova.paletteDim.Visible=visible
    nova.palette.Visible=visible
    if visible then nova.palette.Size=UDim2.fromOffset(250,292);animate(nova.palette,{Size=UDim2.fromOffset(280,322)},.22) end
end

nova.accentGradients={
    logo=logo:FindFirstChildOfClass("UIGradient"),
    art=art:FindFirstChildOfClass("UIGradient"),
    play=play:FindFirstChildOfClass("UIGradient"),
    fill=fill:FindFirstChildOfClass("UIGradient"),
    apply=nova.applyColorButton:FindFirstChildOfClass("UIGradient"),
    window=window:FindFirstChildOfClass("UIGradient"),
    header=header:FindFirstChildOfClass("UIGradient"),
    library=nova.libraryCount:FindFirstChildOfClass("UIGradient"),
}
nova.themedStrokes={
    nova.headerBorder,nova.headerGlow,nova.headerRim,nova.logoGlow,nova.logoRim,
    nova.navBorder,nova.navGlow,nova.navRim,nova.browserBorder,nova.browserGlow,nova.browserRim,
    nova.playerBorder,nova.playerGlow,nova.playerRim,nova.searchBorder,nova.searchGlow,nova.searchRim,nova.viewCountBorder,
    nova.artBorderGlow,nova.artBorderRim,nova.progressGlow,nova.progressRim,nova.playBorder,nova.playGlow,nova.playRim,
    nova.bpmBorder,nova.loopBorder,nova.resetBorder,nova.resetGlow,nova.resetRim,
    nova.libraryBorder,nova.libraryGlow,nova.libraryRim,nova.palette:FindFirstChildOfClass("UIStroke"),
}
local function applyAccent(color)
    local h,s,v=color:ToHSV()
    local secondary=Color3.fromHSV((h+.98)%1,math.clamp(s*.76,.28,1),math.clamp(v*.82,0,1))
    local deep=color:Lerp(Color3.fromRGB(5,4,5),.88)
    local surface=color:Lerp(Color3.fromRGB(13,9,10),.92)
    P.Violet=color
    P.Pink=secondary
    P.Surface=surface
    P.Card=color:Lerp(Color3.fromRGB(24,16,18),.91)
    P.Lift=color:Lerp(Color3.fromRGB(38,24,27),.82)

    nova.preview.BackgroundColor3=color
    for _,object in ipairs({nova.nav,nova.browser,nova.playerCard,nova.palette}) do object.BackgroundColor3=P.Surface end
    for _,object in ipairs({nova.search,nova.viewCountPill,nova.playbackBadge,nova.stop,nova.favorite,nova.bpmPill,nova.loop,nova.resetBpm,nova.libraryCount,nova.paletteClose,nova.minimizeButton,nova.close}) do object.BackgroundColor3=P.Card end
    for _,object in ipairs(nova.rgbInputs) do object.BackgroundColor3=P.Card end
    nova.hexInput.BackgroundColor3=P.Card
    nova.songList.ScrollBarImageColor3=color
    nova.navList.ScrollBarImageColor3=color
    nova.scrubber.UIStroke.Color=color
    settingsButton.BackgroundColor3=color:Lerp(P.Ink,.78)
    nova.progress.BackgroundColor3=color:Lerp(Color3.fromRGB(37,24,27),.90)
    nova.bpmPill.BackgroundColor3=P.Card
    nova.bpmDown.BackgroundColor3=P.Lift
    nova.bpmUp.BackgroundColor3=P.Lift
    nova.loop.BackgroundColor3=state.Loop and color:Lerp(P.Ink,.58) or P.Card
    nova.libraryCount.BackgroundColor3=P.Card
    nova.resetBpm.BackgroundColor3=deep:Lerp(P.Card,.55)
    recolorIcon(settingsIcon,P.Sub);recolorIcon(nova.minimizeIcon,P.Sub);recolorIcon(nova.restoreIcon,P.Sub);recolorIcon(nova.closeIcon,P.Sub);recolorIcon(nova.searchIcon,P.Muted)
    recolorIcon(nova.artIcon,P.Cyan);recolorIcon(nova.stopIcon,P.Sub);recolorIcon(nova.playIcon,P.Text);recolorIcon(nova.pauseIcon,P.Text)
    recolorIcon(nova.bpmDownIcon,P.Sub);recolorIcon(nova.bpmUpIcon,P.Sub);recolorIcon(nova.resetIcon,P.Sub);recolorIcon(nova.paletteCloseIcon,P.Sub)
    recolorIcon(nova.libraryIcon,P.Cyan)
    recolorIcon(nova.favoriteIcon,state.CurrentEntry and API:IsFavorite(state.CurrentEntry.Id) and secondary or P.Sub)
    recolorIcon(nova.loopIcon,state.Loop and P.Text or P.Sub)

    logo.BackgroundColor3=P.Card
    art.BackgroundColor3=P.Card
    for _,object in ipairs({play,fill,nova.applyColorButton}) do object.BackgroundColor3=color end
    for name,g in pairs(nova.accentGradients) do
        if g then
            if name=="window" then
                g.Color=ColorSequence.new(color:Lerp(P.Ink,.92),Color3.fromRGB(5,4,5))
            elseif name=="header" then
                g.Color=ColorSequence.new(color:Lerp(P.Ink,.84),color:Lerp(P.Surface,.90))
            elseif name=="logo" or name=="art" then
                g.Color=ColorSequence.new(P.Card,color:Lerp(P.Ink,.62))
            elseif name=="library" then
                g.Color=ColorSequence.new(P.Card,color:Lerp(P.Ink,.70))
            else
                g.Color=ColorSequence.new(color,secondary)
            end
        end
    end
    for _,strokeObject in ipairs(nova.themedStrokes) do
        if strokeObject then strokeObject.Color=color:Lerp(Color3.new(1,1,1),.22) end
    end
    for object,layers in pairs(nova.glassLayers) do
        if not object.Parent then
            nova.glassLayers[object]=nil
        else
            if layers.Surface then
                if object==window then
                    layers.Surface.Color=ColorSequence.new(color:Lerp(P.Ink,.92),Color3.fromRGB(5,4,5))
                elseif object==header then
                    layers.Surface.Color=ColorSequence.new(color:Lerp(P.Ink,.84),color:Lerp(P.Surface,.90))
                else
                    layers.Surface.Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,Color3.fromRGB(62,43,47)),
                        ColorSequenceKeypoint.new(.34,color:Lerp(Color3.fromRGB(22,17,18),.72)),
                        ColorSequenceKeypoint.new(1,P.Ink),
                    })
                end
            end
            if layers.Stroke then
                layers.Stroke.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(235,194,198)),
                    ColorSequenceKeypoint.new(.48,color:Lerp(Color3.fromRGB(225,174,180),.34)),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(115,49,57)),
                })
            end
        end
    end
    for filter,button in pairs(navButtons) do
        button.BackgroundColor3=color:Lerp(P.Ink,.76)
        button.TextColor3=filter==activeFilter and P.Text or Color3.fromRGB(232,214,217)
        button.BackgroundTransparency=filter==activeFilter and .06 or .34
    end
    refreshList()
end

local function syncRgb()
    local r=math.clamp(tonumber(nova.rgbInputs[1].Text) or 0,0,255)
    local g=math.clamp(tonumber(nova.rgbInputs[2].Text) or 0,0,255)
    local b=math.clamp(tonumber(nova.rgbInputs[3].Text) or 0,0,255)
    for index,value in ipairs({r,g,b}) do nova.rgbInputs[index].Text=tostring(math.floor(value)) end
    nova.hexInput.Text=string.format("#%02X%02X%02X",r,g,b)
    nova.preview.BackgroundColor3=Color3.fromRGB(r,g,b)
    return Color3.fromRGB(r,g,b)
end

for _,color in ipairs(nova.swatchColors) do
    local swatch=radius(edge(make("TextButton",{Size=UDim2.fromOffset(34,34),BackgroundColor3=color,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=52},nova.swatchRow),Color3.new(1,1,1),.72),12)
    bindButtonMotion(swatch)
    swatch.MouseButton1Click:Connect(function()
        local r,g,b=math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5)
        nova.rgbInputs[1].Text=tostring(r);nova.rgbInputs[2].Text=tostring(g);nova.rgbInputs[3].Text=tostring(b)
        nova.hexInput.Text=string.format("#%02X%02X%02X",r,g,b);applyAccent(color)
    end)
end
for _,box in ipairs(nova.rgbInputs) do box.FocusLost:Connect(function() syncRgb() end) end
nova.hexInput.FocusLost:Connect(function()
    local raw=nova.hexInput.Text:gsub("#","")
    if raw:match("^%x%x%x%x%x%x$") then
        for index=1,3 do nova.rgbInputs[index].Text=tostring(tonumber(raw:sub(index*2-1,index*2),16)) end
    end
    syncRgb()
end)
nova.applyColorButton.MouseButton1Click:Connect(function() applyAccent(syncRgb());setPaletteVisible(false) end)
function nova.setCompactMode(enabled)
    if nova.compactMode==enabled or nova.compactBusy then return end
    nova.compactMode=enabled
    nova.compactBusy=true
    nova.compactTransition=(nova.compactTransition or 0)+1
    local transition=nova.compactTransition
    local settingsGlyph=settingsIcon:FindFirstChildWhichIsA("ImageLabel") or settingsIcon:FindFirstChildWhichIsA("TextLabel")
    nova.minimizeButton.Active=false
    nova.minimizeIcon.Visible=not enabled
    nova.restoreIcon.Visible=enabled
    nova.nav.Position=UDim2.fromOffset(0,0)
    nova.browser.Position=UDim2.fromOffset(158,0)
    nova.nav.Visible=true
    nova.browser.Visible=true

    if enabled then
        nova.navScale.Scale=1
        nova.browserScale.Scale=1
        animate(nova.brandTitle,{TextTransparency=1},.16)
        animate(nova.brandSubtitle,{TextTransparency=1},.16)
        animate(settingsButton,{BackgroundTransparency=1},.16)
        if settingsGlyph then animate(settingsGlyph,settingsGlyph:IsA("ImageLabel") and {ImageTransparency=1} or {TextTransparency=1},.16) end
        animate(window,{Size=UDim2.fromOffset(266,440)},.38)
        animate(nova.shadow,{Size=UDim2.fromOffset(266,440)},.38)
        animate(nova.playerCard,{Position=UDim2.fromOffset(0,0)},.38)
        animate(nova.minimizeButton,{Position=UDim2.new(1,-98,0,14)},.34)
        task.delay(.17,function()
            if transition==nova.compactTransition then
                nova.brandTitle.Visible=false
                nova.brandSubtitle.Visible=false
                settingsButton.Visible=false
            end
        end)
        task.delay(.39,function()
            if transition==nova.compactTransition then
                nova.nav.Visible=false
                nova.browser.Visible=false
            end
        end)
    else
        nova.navScale.Scale=.985
        nova.browserScale.Scale=.985
        nova.brandTitle.Visible=true
        nova.brandSubtitle.Visible=true
        settingsButton.Visible=true
        nova.brandTitle.TextTransparency=1
        nova.brandSubtitle.TextTransparency=1
        settingsButton.BackgroundTransparency=1
        if settingsGlyph then
            if settingsGlyph:IsA("ImageLabel") then settingsGlyph.ImageTransparency=1 else settingsGlyph.TextTransparency=1 end
        end
        animate(window,{Size=UDim2.fromOffset(760,440)},.40)
        animate(nova.shadow,{Size=UDim2.fromOffset(760,440)},.40)
        animate(nova.playerCard,{Position=UDim2.fromOffset(494,0)},.40)
        animate(nova.navScale,{Scale=1},.32)
        animate(nova.browserScale,{Scale=1},.32)
        animate(nova.minimizeButton,{Position=UDim2.new(1,-144,0,14)},.34)
        task.delay(.06,function()
            if transition==nova.compactTransition then
                animate(nova.brandTitle,{TextTransparency=0},.22)
                animate(nova.brandSubtitle,{TextTransparency=0},.22)
                animate(settingsButton,{BackgroundTransparency=.16},.22)
                if settingsGlyph then animate(settingsGlyph,settingsGlyph:IsA("ImageLabel") and {ImageTransparency=0} or {TextTransparency=0},.22) end
            end
        end)
    end
    fitViewport(.36)
    task.delay(.42,function()
        if transition==nova.compactTransition then
            nova.compactBusy=false
            nova.minimizeButton.Active=true
        end
    end)
end

nova.minimizeButton.MouseButton1Click:Connect(function() nova.setCompactMode(not nova.compactMode) end)
settingsButton.MouseButton1Click:Connect(function() setPaletteVisible(true) end)
nova.paletteClose.MouseButton1Click:Connect(function() setPaletteVisible(false) end)
nova.paletteDim.MouseButton1Click:Connect(function() setPaletteVisible(false) end)

nova.categories={"All Songs","Favorites","Recent"}
for _,entry in ipairs(state.Registry) do
    for _,category in ipairs(entry.Categories or {}) do
        if not table.find(nova.categories,category) then table.insert(nova.categories,category) end
    end
end

local function chooseFilter(name)
    activeFilter=name
    nova.resultTitle.Text=string.upper(name)
    for filter,button in pairs(navButtons) do
        local selected=filter==name
        animate(button,{BackgroundTransparency=selected and .06 or .34,TextColor3=selected and P.Text or Color3.fromRGB(232,214,217)},.20)
    end
    refreshList()
end

for index,name in ipairs(nova.categories) do
    local button=radius(make("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(73,57,111),BackgroundTransparency=index==1 and .16 or .78,BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.BuilderSansMedium,Text="   "..name,TextSize=11,TextColor3=index==1 and P.Text or Color3.fromRGB(232,214,217),TextXAlignment=Enum.TextXAlignment.Left},nova.navList),11)
    button.BackgroundTransparency=index==1 and .06 or .34
    edge(button,P.Violet,index==1 and .34 or .72,1)
    navButtons[name]=button
    button.MouseButton1Click:Connect(function() chooseFilter(name) end)
end

local function entryMatches(entry)
    local cat=activeFilter=="All Songs" or (activeFilter=="Favorites" and API:IsFavorite(entry.Id)) or (activeFilter=="Recent" and table.find(state.Recent,entry.Id)) or table.find(entry.Categories or {},activeFilter)
    local textValue=string.lower((entry.Name or "").." "..(entry.Artist or "").." "..table.concat(entry.Categories or {}," "))
    return cat and (searchQuery=="" or string.find(textValue,searchQuery,1,true))
end

local function songPalette(index)
    local tones={
        Color3.fromRGB(222,82,96),
        Color3.fromRGB(196,61,75),
        Color3.fromRGB(168,45,58),
        Color3.fromRGB(232,105,116),
        Color3.fromRGB(139,35,47),
    }
    local accent=tones[((index-1)%#tones)+1]:Lerp(P.Violet,.28)
    local first=P.Card:Lerp(accent,.12)
    local second=P.Ink:Lerp(accent,.28)
    return {first,second,accent}
end

refreshList=function()
    for _,child in ipairs(nova.songList:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    local shown=0
    local selectedId=state.SelectedEntryId or (state.CurrentEntry and state.CurrentEntry.Id)

    for index,entry in ipairs(state.Registry) do
        if entryMatches(entry) then
            shown+=1

            local selected=entry.Id==selectedId
            local playingCurrent=state.Playing and state.CurrentEntry and entry.Id==state.CurrentEntry.Id
            local cardBase=selected and P.Violet:Lerp(P.Ink,.72) or P.Card

            local card=radius(make("TextButton",{
                Size=UDim2.new(1,0,0,61),
                BackgroundColor3=cardBase,
                BorderSizePixel=0,
                AutoButtonColor=false,
                Text="",
            },nova.songList),15)
            edge(card,selected and P.Violet or Color3.fromRGB(92,45,52),selected and .14 or .58,selected and 1.4 or 1)
            nova.glassify(card,selected and .06 or .12,P.Violet)
            local songColors=songPalette(index)
            local tile=radius(gradient(make("Frame",{
                Position=UDim2.fromOffset(9,7),
                Size=UDim2.fromOffset(47,47),
                BackgroundColor3=songColors[1],
                BorderSizePixel=0,
            },card),songColors[1],songColors[2],45),13)
            edge(tile,selected and P.Violet or songColors[3],selected and .22 or .48,1)

            local cardMusicIcon=icon(tile,"music-2",17,selected and P.Text or songColors[3],"")
            cardMusicIcon.AnchorPoint=Vector2.new(.5,.5)
            cardMusicIcon.Position=UDim2.fromScale(.5,.5)

            marqueeLabel(card,entry.Name or "Untitled",UDim2.fromOffset(68,9),UDim2.new(1,-112,0,19),Enum.Font.BuilderSansBold,11,P.Text)

            local statusText=selected and "  •  SELECTED" or (playingCurrent and "  •  PLAYING" or "")
            marqueeLabel(card,(entry.Artist or "Velora").."  •  "..tostring(entry.BPM or 120).." BPM"..statusText,UDim2.fromOffset(68,32),UDim2.new(1,-112,0,15),Enum.Font.BuilderSansMedium,9,selected and P.Cyan or (playingCurrent and P.Green or P.Sub))

            local indicatorName=selected and "check" or (playingCurrent and "volume-2" or "chevron-right")
            local indicatorColor=selected and P.Cyan or (playingCurrent and P.Green or P.Sub)
            local indicator=icon(card,indicatorName,17,indicatorColor,"")
            indicator.AnchorPoint=Vector2.new(.5,.5)
            indicator.Position=UDim2.new(1,-24,.5,0)

            card.MouseButton1Click:Connect(function()
                local ok,mode=API:SelectSong(entry.Id)
                if not ok then
                    nova.feedback.Text=tostring(mode)
                elseif mode=="pending" then
                    nova.feedback.Text="Picked "..tostring(entry.Name)..". The current song keeps playing."
                elseif mode=="current" then
                    nova.feedback.Text=tostring(entry.Name).." is still playing."
                else
                    nova.feedback.Text="Selected "..tostring(entry.Name)..". Press Play when ready."
                end
                refreshList()
            end)
        end
    end

    nova.viewCountText.Text=tostring(shown)..(shown==1 and " TRACK" or " TRACKS")

    if shown==0 then
        local empty=label(nova.songList,"No songs in this view",UDim2.new(),UDim2.new(1,0,0,90),Enum.Font.BuilderSansBold,10,P.Muted)
        empty.TextXAlignment=Enum.TextXAlignment.Center
    end
end

nova.seeking=false
nova.seekPreview=nil
local function previewSeekAt(screenX)
    local ratio=math.clamp((screenX-nova.progress.AbsolutePosition.X)/math.max(1,nova.progress.AbsoluteSize.X),0,1)
    nova.seekPreview=ratio
    fill.Size=UDim2.new(ratio,0,1,0)
    nova.scrubber.Position=UDim2.new(ratio,0,.5,0)
    local snap=API:GetSnapshot()
    nova.timeLeft.Text=clock((snap.Duration or 0)*ratio)
    return ratio
end

local function render()
    local snap=API:GetSnapshot()
    if snap.Entry then
        nova.nowTitle.Text=snap.Entry.Name or "Untitled"
        nova.nowMeta.Text=(snap.Entry.Artist or "Velora").."  •  "..tostring(math.floor(snap.BPM or 120)).." BPM"
        if not nova.bpm:IsFocused() then nova.bpm.Text=tostring(math.floor(snap.BPM or 120)) end
        recolorIcon(nova.favoriteIcon,API:IsFavorite(snap.Entry.Id) and P.Pink or P.Sub)
    end
    local displayProgress=snap.PendingSeekProgress or snap.Progress
    if not nova.seeking then
        fill.Size=UDim2.new(displayProgress,0,1,0)
        nova.scrubber.Position=UDim2.new(displayProgress,0,.5,0)
    end
    local displayPosition=snap.PendingSeekProgress and (snap.Duration*snap.PendingSeekProgress) or snap.Position
    if nova.seeking and nova.seekPreview then displayPosition=snap.Duration*nova.seekPreview end
    nova.timeLeft.Text=clock(displayPosition);nova.timeRight.Text=clock(snap.Duration)
    local showPause=snap.Playing and not snap.Paused
    nova.playIcon.Visible=not showPause;nova.pauseIcon.Visible=showPause
    nova.loop.BackgroundColor3=snap.Loop and P.Violet:Lerp(P.Ink,.58) or P.Card
    recolorIcon(nova.loopIcon,snap.Loop and P.Text or P.Sub)
    nova.loopLabel.TextColor3=snap.Loop and P.Text or P.Muted
    local statusText,statusColor="READY",P.Cyan
    if snap.Buffering then
        statusText,statusColor="BUFFERING",P.Cyan
    elseif snap.Playing and not snap.Paused then
        statusText,statusColor="PLAYING",P.Green
    elseif snap.Paused then
        statusText,statusColor="PAUSED",P.Pink
    elseif snap.Duration>0 and snap.Progress>=.999 then
        statusText,statusColor="DONE",P.Cyan
    end
    nova.setPlaybackBadgeText(statusText)
    nova.playbackStatus.TextColor3=statusColor
    nova.playbackDot.BackgroundColor3=statusColor
    nova.playbackBadgeBorder.Color=statusColor
    nova.playbackBadge.BackgroundColor3=statusColor:Lerp(P.Ink,.84)
end

nova.search:GetPropertyChangedSignal("Text"):Connect(function() searchQuery=string.lower(nova.search.Text);refreshList() end)
nova.seekHit.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then nova.seeking=true;previewSeekAt(input.Position.X) end
end)
UserInputService.InputChanged:Connect(function(input)
    if nova.seeking and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then previewSeekAt(input.Position.X) end
end)
UserInputService.InputEnded:Connect(function(input)
    if nova.seeking and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        local ratio=previewSeekAt(input.Position.X)
        nova.seeking=false
        nova.seekPreview=nil
        API:Seek(ratio)
    end
end)
nova.bpmDown.MouseButton1Click:Connect(function() local snap=API:GetSnapshot();API:SetBPM((snap.BPM or 120)-5);render() end)
nova.bpmUp.MouseButton1Click:Connect(function() local snap=API:GetSnapshot();API:SetBPM((snap.BPM or 120)+5);render() end)
play.MouseButton1Click:Connect(function()
    local snap=API:GetSnapshot()
    if snap.Playing and not snap.Paused then API:Pause();nova.feedback.Text="Paused in the moonlight."
    else local ok,err=API:Play();nova.feedback.Text=ok and "Aurora is playing into the game." or (tostring(err).." — click the piano once.") end
    render()
end)
nova.stop.MouseButton1Click:Connect(function()
    local pendingId=state.PendingEntryId
    API:Stop()

    if pendingId then
        state.PendingEntryId=nil
        local ok,err=API:LoadSong(pendingId,false)
        nova.feedback.Text=ok and "Selected song is ready. Press Play when you want." or tostring(err)
        refreshList()
    else
        nova.feedback.Text="Stopped. The song is ready to restart."
    end

    render()
end)
nova.favorite.MouseButton1Click:Connect(function()
    if not state.CurrentEntry then
        nova.feedback.Text="Choose a song before adding a favorite."
        return
    end

    local entry=state.CurrentEntry
    local enabled=API:ToggleFavorite(entry.Id)
    nova.feedback.Text=enabled and ("Saved "..tostring(entry.Name).." to Favorites.") or ("Removed "..tostring(entry.Name).." from Favorites.")
    refreshList()
    render()

    nova.favoriteIcon.Rotation=enabled and -12 or 10
    nova.favoriteIcon.Size=UDim2.fromOffset(15,15)
    animate(nova.favoriteIcon,{Rotation=0,Size=UDim2.fromOffset(enabled and 25 or 21,enabled and 25 or 21)},.13)
    animate(nova.favorite,{BackgroundColor3=enabled and P.Pink:Lerp(P.Ink,.72) or P.Lift},.13)
    task.delay(.14,function()
        if nova.favoriteIcon.Parent then animate(nova.favoriteIcon,{Size=UDim2.fromOffset(20,20)},.14) end
        if nova.favorite.Parent then animate(nova.favorite,{BackgroundColor3=P.Card},.16) end
    end)
end)
nova.loop.MouseButton1Click:Connect(function() API:SetLoop(not state.Loop);render() end)
nova.resetBpm.MouseButton1Click:Connect(function()
    if not state.CurrentSong or not state.CurrentEntry then
        nova.feedback.Text="Choose a song first."
        return
    end
    local original=math.clamp(tonumber(state.CurrentSong.BPM or state.CurrentEntry.BPM) or 120,30,300)
    local value=API:SetBPM(original)
    nova.feedback.Text=value and ("Restored original tempo  •  "..math.floor(value).." BPM") or "Could not reset this song."
    render()
end)
nova.bpm.FocusLost:Connect(function() local value=API:SetBPM(tonumber(nova.bpm.Text));nova.feedback.Text=value and ("Tempo set to "..math.floor(value).." BPM.") or "Choose a song first.";render() end)

API.Changed:Connect(function(reason)
    if reason=="finished" then
        nova.feedback.Text=state.PendingEntryId and "Song complete. Preparing your selected song." or "Song complete. Autoplay stopped."
    elseif reason=="pending-ready" then
        nova.feedback.Text="Your selected song is ready. Press Play when you want."
    elseif reason=="pending-selection" then
        local picked=getEntry(state.PendingEntryId)
        nova.feedback.Text="Picked "..tostring(picked and picked.Name or "song")..". The current song keeps playing."
    elseif reason=="input-error" then
        nova.feedback.Text="Input was rejected. Click the in-game piano, then retry."
    elseif reason=="input-required" then
        nova.feedback.Text="This executor has no compatible piano output."
    elseif reason=="buffering" then
        nova.feedback.Text="Buffering protected playback…"
    elseif reason=="stream-ready" then
        nova.feedback.Text="Protected playback is ready."
    elseif reason=="stream-warning" then
        nova.feedback.Text="Connection interrupted. Velora will stop safely if the buffer runs out."
    elseif reason=="stream-error" then
        nova.feedback.Text=tostring(state.StreamError or state.LastPlaybackError or "Protected playback is unavailable. Try again shortly.")
    elseif reason=="seek-error" then
        nova.feedback.Text=tostring(state.LastPlaybackError or "Seek failed safely. Press Play to continue.")
    elseif reason=="selection" then
        animate(art,{Rotation=3})
        task.delay(.09,function() if art.Parent then animate(art,{Rotation=0},.1) end end)
    end

    if reason=="selection" or reason=="selection-focus" or reason=="pending-selection"
        or reason=="pending-ready" or reason=="playing" or reason=="stopped" or reason=="finished" or reason=="favorites" then
        refreshList()
    end
    render()
end)
nova.lastNoteStatus=0
API.NotePlayed:Connect(function(note)
    if state.PendingEntryId then
        local picked=getEntry(state.PendingEntryId)
        nova.feedback.Text="Picked "..tostring(picked and picked.Name or "song")..". The current song keeps playing."
    elseif os.clock()-nova.lastNoteStatus>=.25 then
        nova.lastNoteStatus=os.clock()
        nova.feedback.Text="Playing  "..tostring(note).."  •  Aurora output active"
    end
end)

nova.dragging=false
local dragStart,startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then nova.dragging=true;dragStart=input.Position;startPos=window.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if nova.dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local delta=input.Position-dragStart;window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)  end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then nova.dragging=false end end)
UserInputService.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.RightShift then nova.gui.Enabled=not nova.gui.Enabled end end)
function nova.dismiss()
    if nova.closing then return end
    nova.closing=true
    saveFavorites(state.Favorites)
    API:Stop()
    if nova.reveal then animate(nova.reveal,{GroupTransparency=1},.20) end
    animate(nova.windowScale,{Scale=nova.windowScale.Scale*.96},.20)
    task.delay(.21,function()
        nova.disposeVisuals()
        if nova.gui then nova.gui:Destroy() end
    end)
end
nova.close.MouseButton1Click:Connect(nova.dismiss)

nova.lastRender=0
nova.renderConnection=RunService.RenderStepped:Connect(function()
    if not nova.gui.Parent then return end
    local now=os.clock()
    updateMarquees(now)
    if now-nova.lastRender>=1/30 then
        nova.lastRender=now
        render()
    end
end)
nova.gui.AncestryChanged:Connect(function(_,parent)
    if not parent then
        if nova.renderConnection then nova.renderConnection:Disconnect() end
        nova.disposeVisuals()
    end
end)

API.UI={Gui=nova.gui,Window=window}
API.State=state
function API:Show() nova.gui.Enabled=true end
function API:Hide() nova.gui.Enabled=false end
function API:Destroy() nova.dismiss() end

refreshList()
if state.Registry[1] and not state.CurrentEntry then
    local loaded, initialError = API:LoadSong(state.Registry[1].Id,false)
    if not loaded then
        nova.feedback.Text=tostring(initialError or "Protected playback is unavailable. Please try again shortly.")
    end
end
render()
nova.reveal=make("CanvasGroup",{Name="GlassReveal",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,BorderSizePixel=0},window)
for _,child in ipairs(window:GetChildren()) do
    if child~=nova.reveal and child:IsA("GuiObject") then child.Parent=nova.reveal end
end
nova.loadScale=nova.windowScale.Scale
nova.windowScale.Scale=nova.loadScale*.94
window.BackgroundTransparency=1
animate(nova.windowScale,{Scale=nova.loadScale},.42)
animate(window,{BackgroundTransparency=.18},.36)
animate(nova.reveal,{GroupTransparency=0},.36)

_G.Velora=API
pcall(function() if type(getgenv)=="function" then getgenv().Velora=API end end)
return API

