--[[
    Velora Upgrade Lab
    Test-branch-only additive feature pack.

    Adds:
      1. Live 61-key piano visualizer
      2. A/B loop points
      3. Tempo presets + accelerating +/- controls
      4. Layered action sound design
      5. Current note/chord display
      6. Progress-bar hover time preview
      7. Per-song state memory
      8. Compact-mode status/progress enhancement
      9. Keyboard shortcuts
     10. Ambient now-playing glow
     11. Wait-for-me practice mode
     12. Song information panel

    This module does not replace Velora's playback engine. It attaches to the
    public API returned by the smooth build so the test can be removed cleanly.
]]

return function(API)
    assert(type(API) == "table", "Velora Upgrade Lab expects the Velora API")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local SoundService = game:GetService("SoundService")
    local HttpService = game:GetService("HttpService")

    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then
        return false, "Velora GUI not found"
    end

    local window = gui:FindFirstChild("Aurora", true)
    if not window or not window:IsA("GuiObject") then
        return false, "Velora window not found"
    end

    if gui:FindFirstChild("VeloraUpgradeLab", true) then
        return true
    end

    local COLORS = {
        Ink = Color3.fromRGB(8, 6, 7),
        Surface = Color3.fromRGB(18, 12, 14),
        Raised = Color3.fromRGB(31, 19, 22),
        Raised2 = Color3.fromRGB(45, 25, 29),
        Accent = Color3.fromRGB(211, 76, 90),
        AccentSoft = Color3.fromRGB(167, 55, 68),
        Edge = Color3.fromRGB(145, 72, 82),
        Text = Color3.fromRGB(255, 247, 249),
        Sub = Color3.fromRGB(220, 198, 203),
        Muted = Color3.fromRGB(155, 126, 132),
        Good = Color3.fromRGB(232, 101, 113),
        BlackKey = Color3.fromRGB(31, 23, 25),
        WhiteKey = Color3.fromRGB(206, 184, 188),
    }

    local function make(className, props, parent)
        local object = Instance.new(className)
        for key, value in pairs(props or {}) do
            object[key] = value
        end
        object.Parent = parent
        return object
    end

    local function round(object, radius)
        make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, object)
        return object
    end

    local function edge(object, transparency, thickness, color)
        make("UIStroke", {
            Color = color or COLORS.Edge,
            Transparency = transparency == nil and 0.5 or transparency,
            Thickness = thickness or 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, object)
        return object
    end

    local function label(parent, textValue, size, color, bold)
        return make("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = size or UDim2.new(1, 0, 0, 18),
            Font = bold and Enum.Font.BuilderSansExtraBold or Enum.Font.BuilderSans,
            Text = textValue or "",
            TextColor3 = color or COLORS.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, parent)
    end

    local function button(parent, textValue, size)
        local b = round(edge(make("TextButton", {
            BackgroundColor3 = COLORS.Raised,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = textValue or "",
            TextColor3 = COLORS.Sub,
            TextSize = 9,
            Font = Enum.Font.BuilderSansExtraBold,
            Size = size or UDim2.fromOffset(58, 28),
        }, parent), 0.62, 1), 9)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Raised2, TextColor3 = COLORS.Text}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.Raised, TextColor3 = COLORS.Sub}):Play()
        end)
        return b
    end

    local function setButtonActive(b, active)
        if not b then return end
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = active and COLORS.AccentSoft or COLORS.Raised,
            TextColor3 = active and COLORS.Text or COLORS.Sub,
        }):Play()
    end

    local function formatTime(seconds)
        seconds = math.max(0, tonumber(seconds) or 0)
        return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
    end

    local function snapshot()
        local ok, result = pcall(function()
            return API:GetSnapshot()
        end)
        return ok and type(result) == "table" and result or {}
    end

    local function currentId(snap)
        snap = snap or snapshot()
        return (snap.Entry and snap.Entry.Id) or snap.SelectedId
    end

    local function currentBaseBpm(snap)
        snap = snap or snapshot()
        return tonumber(snap.Entry and snap.Entry.BPM)
            or tonumber(snap.Song and snap.Song.BPM)
            or tonumber(snap.BPM)
            or 120
    end

    -- ---------------------------------------------------------
    -- Upgrade Lab drawer
    -- ---------------------------------------------------------

    local labButton = round(edge(make("TextButton", {
        Name = "VeloraUpgradeLab",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 86),
        Size = UDim2.fromOffset(32, 30),
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "✦",
        TextColor3 = COLORS.Accent,
        TextSize = 14,
        Font = Enum.Font.BuilderSansExtraBold,
        ZIndex = 220,
    }, window), 0.45, 1, COLORS.Accent), 10)

    local drawer = round(edge(make("Frame", {
        Name = "UpgradeDrawer",
        Visible = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 120),
        Size = UDim2.fromOffset(360, 302),
        BackgroundColor3 = COLORS.Ink,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 230,
    }, window), 0.25, 1.2, COLORS.Accent), 18)

    local drawerTitle = label(drawer, "VELORA LAB", UDim2.fromOffset(180, 24), COLORS.Text, true)
    drawerTitle.Position = UDim2.fromOffset(16, 10)
    drawerTitle.TextSize = 12

    local drawerSub = label(drawer, "UPGRADE PACK • TEST BRANCH", UDim2.fromOffset(220, 14), COLORS.Muted, true)
    drawerSub.Position = UDim2.fromOffset(16, 31)
    drawerSub.TextSize = 7

    local drawerClose = button(drawer, "×", UDim2.fromOffset(28, 28))
    drawerClose.Position = UDim2.new(1, -40, 0, 10)
    drawerClose.TextSize = 14
    drawerClose.ZIndex = 232

    local scroller = make("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 54),
        Size = UDim2.new(1, -20, 1, -64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ZIndex = 231,
    }, drawer)
    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, scroller)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 8),
    }, scroller)

    local function section(titleText, height)
        local frame = round(edge(make("Frame", {
            Size = UDim2.new(1, -7, 0, height),
            BackgroundColor3 = COLORS.Surface,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            ZIndex = 232,
        }, scroller), 0.72, 1), 13)
        local t = label(frame, titleText, UDim2.new(1, -24, 0, 18), COLORS.Muted, true)
        t.Position = UDim2.fromOffset(12, 7)
        t.TextSize = 8
        return frame
    end

    labButton.Activated:Connect(function()
        drawer.Visible = not drawer.Visible
    end)
    drawerClose.Activated:Connect(function()
        drawer.Visible = false
    end)

    -- ---------------------------------------------------------
    -- 1 + 5: Live piano visualizer + current chord display
    -- ---------------------------------------------------------

    local visualSection = section("LIVE PIANO • CURRENT CHORD", 92)
    local chordLabel = label(visualSection, "WAITING FOR NOTES", UDim2.new(1, -24, 0, 22), COLORS.Text, true)
    chordLabel.Position = UDim2.fromOffset(12, 25)
    chordLabel.TextSize = 11

    local keyboard = round(make("Frame", {
        Position = UDim2.fromOffset(12, 52),
        Size = UDim2.new(1, -24, 0, 28),
        BackgroundColor3 = Color3.fromRGB(12, 9, 10),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 233,
    }, visualSection), 7)

    local KEY_CHARS = {
        "1","!","2","@","3","4","$","5","%","6","^","7","8","*","9","(","0",
        "q","Q","w","W","e","E","r","t","T","y","Y","u","i","I","o","O","p","P","a",
        "s","S","d","D","f","g","G","h","H","j","J","k","l","L","z","Z","x","c","C",
        "v","V","b","B","n","m"
    }

    local keyByChar = {}
    local keyBaseColor = {}
    local keyPulse = {}
    for index, char in ipairs(KEY_CHARS) do
        local midi = index + 35
        local semitone = midi % 12
        local black = semitone == 1 or semitone == 3 or semitone == 6 or semitone == 8 or semitone == 10
        local base = black and COLORS.BlackKey or COLORS.WhiteKey
        local key = make("Frame", {
            Position = UDim2.new((index - 1) / #KEY_CHARS, 0, 0, black and 0 or 5),
            Size = UDim2.new(1 / #KEY_CHARS, -1, 1, black and -6 or -5),
            BackgroundColor3 = base,
            BorderSizePixel = 0,
            ZIndex = black and 235 or 234,
        }, keyboard)
        keyByChar[char] = key
        keyBaseColor[char] = base
        keyPulse[char] = 0
    end

    local NOTE_NAMES = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"}
    local charToNote = {}
    for index, char in ipairs(KEY_CHARS) do
        local midi = index + 35
        local octave = math.floor(midi / 12) - 1
        charToNote[char] = NOTE_NAMES[(midi % 12) + 1] .. tostring(octave)
    end

    local function collectChars(output, value, depth)
        depth = depth or 0
        if depth > 3 then return end
        if type(value) == "string" then
            if #value == 1 and keyByChar[value] then
                output[value] = true
                return
            end
            for char in value:gmatch(".") do
                if keyByChar[char] then output[char] = true end
            end
        elseif type(value) == "table" then
            for _, nested in pairs(value) do
                collectChars(output, nested, depth + 1)
            end
        end
    end

    local function notesFromArgs(...)
        local chars = {}
        for index = 1, select("#", ...) do
            collectChars(chars, select(index, ...), 0)
        end
        local ordered = {}
        for _, char in ipairs(KEY_CHARS) do
            if chars[char] then table.insert(ordered, char) end
        end
        return ordered
    end

    local chordToken = 0
    local function showNotes(chars)
        if #chars == 0 then return end
        local names = {}
        for _, char in ipairs(chars) do
            table.insert(names, charToNote[char] or char)
            local key = keyByChar[char]
            if key then
                keyPulse[char] += 1
                local pulse = keyPulse[char]
                key.BackgroundColor3 = COLORS.Accent
                task.delay(0.16, function()
                    if key.Parent and keyPulse[char] == pulse then
                        TweenService:Create(key, TweenInfo.new(0.18), {BackgroundColor3 = keyBaseColor[char]}):Play()
                    end
                end)
            end
        end
        chordToken += 1
        local token = chordToken
        chordLabel.Text = table.concat(names, " + ")
        chordLabel.TextTransparency = 0
        task.delay(1.1, function()
            if chordLabel.Parent and chordToken == token then
                TweenService:Create(chordLabel, TweenInfo.new(0.35), {TextTransparency = 0.45}):Play()
            end
        end)
    end

    -- ---------------------------------------------------------
    -- 2 + 3: A/B loop + enhanced tempo controls
    -- ---------------------------------------------------------

    local controlSection = section("A/B LOOP • TEMPO WORKBENCH", 111)
    local aPoint, bPoint
    local aButton = button(controlSection, "SET A", UDim2.fromOffset(62, 28))
    aButton.Position = UDim2.fromOffset(12, 28)
    local bButton = button(controlSection, "SET B", UDim2.fromOffset(62, 28))
    bButton.Position = UDim2.fromOffset(80, 28)
    local clearAB = button(controlSection, "CLEAR", UDim2.fromOffset(62, 28))
    clearAB.Position = UDim2.fromOffset(148, 28)
    local abStatus = label(controlSection, "A --:--   B --:--", UDim2.new(1, -232, 0, 28), COLORS.Sub, true)
    abStatus.Position = UDim2.fromOffset(218, 28)
    abStatus.TextSize = 8

    local function refreshAB()
        abStatus.Text = string.format("A %s   B %s", aPoint and formatTime(aPoint) or "--:--", bPoint and formatTime(bPoint) or "--:--")
        setButtonActive(aButton, aPoint ~= nil)
        setButtonActive(bButton, bPoint ~= nil)
    end

    aButton.Activated:Connect(function()
        aPoint = tonumber(snapshot().Position) or 0
        if bPoint and bPoint <= aPoint then bPoint = nil end
        refreshAB()
    end)
    bButton.Activated:Connect(function()
        bPoint = tonumber(snapshot().Position) or 0
        if aPoint and bPoint <= aPoint then aPoint = nil end
        refreshAB()
    end)
    clearAB.Activated:Connect(function()
        aPoint, bPoint = nil, nil
        refreshAB()
    end)

    local minusBpm = button(controlSection, "−", UDim2.fromOffset(28, 28))
    minusBpm.Position = UDim2.fromOffset(12, 68)
    minusBpm.TextSize = 13
    local plusBpm = button(controlSection, "+", UDim2.fromOffset(28, 28))
    plusBpm.Position = UDim2.fromOffset(44, 68)
    plusBpm.TextSize = 13

    local presetValues = {50, 75, 100, 125}
    local presetButtons = {}
    for index, percent in ipairs(presetValues) do
        local b = button(controlSection, tostring(percent) .. "%", UDim2.fromOffset(49, 28))
        b.Position = UDim2.fromOffset(82 + (index - 1) * 54, 68)
        presetButtons[index] = b
        b.Activated:Connect(function()
            local snap = snapshot()
            local base = currentBaseBpm(snap)
            API:SetBPM(math.clamp(math.floor(base * percent / 100 + 0.5), 30, 300))
        end)
    end

    local function adjustBpm(delta)
        local snap = snapshot()
        if snap.BPM then
            API:SetBPM((tonumber(snap.BPM) or 120) + delta)
        end
    end

    local holdGeneration = 0
    local function bindAccelerating(buttonObject, delta)
        buttonObject.MouseButton1Down:Connect(function()
            holdGeneration += 1
            local generation = holdGeneration
            adjustBpm(delta)
            task.delay(0.34, function()
                local interval = 0.10
                while holdGeneration == generation and buttonObject.Parent do
                    adjustBpm(delta)
                    task.wait(interval)
                    interval = math.max(0.045, interval * 0.9)
                end
            end)
        end)
        local function stopHold()
            holdGeneration += 1
        end
        buttonObject.MouseButton1Up:Connect(stopHold)
        buttonObject.MouseLeave:Connect(stopHold)
    end
    bindAccelerating(minusBpm, -1)
    bindAccelerating(plusBpm, 1)

    -- ---------------------------------------------------------
    -- 7 + 9 + 11: memory, shortcuts, wait-for-me practice
    -- ---------------------------------------------------------

    local featureSection = section("PRACTICE • MEMORY • SHORTCUTS", 112)
    local practiceButton = button(featureSection, "WAIT-FOR-ME", UDim2.fromOffset(100, 29))
    practiceButton.Position = UDim2.fromOffset(12, 28)
    local memoryButton = button(featureSection, "MEMORY ON", UDim2.fromOffset(92, 29))
    memoryButton.Position = UDim2.fromOffset(118, 28)
    local shortcutsButton = button(featureSection, "KEYS ON", UDim2.fromOffset(76, 29))
    shortcutsButton.Position = UDim2.fromOffset(216, 28)

    local practiceHint = label(featureSection, "Practice: Velora pauses on each chord until you play the expected keys. Enter skips.", UDim2.new(1, -24, 0, 30), COLORS.Sub, false)
    practiceHint.Position = UDim2.fromOffset(12, 61)
    practiceHint.TextSize = 8
    practiceHint.TextWrapped = true

    local shortcutHint = label(featureSection, "Space play/pause • ←/→ seek 5s • ↑/↓ BPM • L loop • F favorite • Ctrl+J Lab", UDim2.new(1, -24, 0, 24), COLORS.Muted, false)
    shortcutHint.Position = UDim2.fromOffset(12, 88)
    shortcutHint.TextSize = 7
    shortcutHint.TextWrapped = true

    local memoryEnabled = true
    local shortcutsEnabled = true
    local practiceEnabled = false
    local practiceExpected = {}
    local practiceRestoreAuto = false

    setButtonActive(memoryButton, true)
    setButtonActive(shortcutsButton, true)

    local MEMORY_KEY = "VeloraUpgradeSongMemoryV1"
    local MEMORY_DIR = "Velora"
    local MEMORY_PATH = MEMORY_DIR .. "/song_state_lab.json"
    local songMemory = {}

    local function environment()
        if type(getgenv) == "function" then
            local ok, env = pcall(getgenv)
            if ok and type(env) == "table" then return env end
        end
        return _G
    end

    local function loadMemory()
        local env = environment()
        if type(env[MEMORY_KEY]) == "table" then
            for id, data in pairs(env[MEMORY_KEY]) do songMemory[id] = data end
        end
        pcall(function()
            if type(isfile) == "function" and type(readfile) == "function" and isfile(MEMORY_PATH) then
                local decoded = HttpService:JSONDecode(readfile(MEMORY_PATH))
                if type(decoded) == "table" then
                    for id, data in pairs(decoded) do songMemory[id] = data end
                end
            end
        end)
        env[MEMORY_KEY] = songMemory
    end
    loadMemory()

    local memoryWriteToken = 0
    local function scheduleMemoryWrite()
        environment()[MEMORY_KEY] = songMemory
        memoryWriteToken += 1
        local token = memoryWriteToken
        task.delay(0.55, function()
            if token ~= memoryWriteToken then return end
            pcall(function()
                if type(writefile) ~= "function" then return end
                if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(MEMORY_DIR) then
                    makefolder(MEMORY_DIR)
                end
                writefile(MEMORY_PATH, HttpService:JSONEncode(songMemory))
            end)
        end)
    end

    local restoringMemory = false
    local lastMemoryId
    local function saveSongState(snap)
        if not memoryEnabled or restoringMemory then return end
        local id = currentId(snap)
        if not id then return end
        songMemory[id] = {
            BPM = tonumber(snap.BPM),
            Speed = tonumber(snap.Speed),
            Progress = tonumber(snap.Progress),
            Loop = snap.Loop == true,
        }
        scheduleMemoryWrite()
    end

    local function restoreSongState(id)
        if not memoryEnabled then return end
        local data = songMemory[id]
        if type(data) ~= "table" then return end
        local snap = snapshot()
        if currentId(snap) ~= id or snap.Playing then return end
        restoringMemory = true
        if tonumber(data.Speed) then pcall(API.SetSpeed, API, data.Speed) end
        if tonumber(data.BPM) then pcall(API.SetBPM, API, data.BPM) end
        if data.Loop ~= nil then pcall(API.SetLoop, API, data.Loop == true) end
        if tonumber(data.Progress) and data.Progress > 0 and data.Progress < 0.995 then
            pcall(API.Seek, API, data.Progress)
        end
        restoringMemory = false
    end

    memoryButton.Activated:Connect(function()
        memoryEnabled = not memoryEnabled
        memoryButton.Text = memoryEnabled and "MEMORY ON" or "MEMORY OFF"
        setButtonActive(memoryButton, memoryEnabled)
    end)

    shortcutsButton.Activated:Connect(function()
        shortcutsEnabled = not shortcutsEnabled
        shortcutsButton.Text = shortcutsEnabled and "KEYS ON" or "KEYS OFF"
        setButtonActive(shortcutsButton, shortcutsEnabled)
    end)

    local function setPractice(enabled)
        practiceEnabled = enabled == true
        practiceExpected = {}
        practiceButton.Text = practiceEnabled and "WAITING MODE" or "WAIT-FOR-ME"
        setButtonActive(practiceButton, practiceEnabled)
        local snap = snapshot()
        if practiceEnabled then
            practiceRestoreAuto = snap.InputMode ~= nil and snap.InputMode ~= "Preview Only"
            pcall(API.SetAutoInput, API, false)
            practiceHint.Text = "Practice armed. Start playback: each chord pauses until you play it. Enter skips."
        else
            if practiceRestoreAuto then pcall(API.SetAutoInput, API, true) end
            practiceRestoreAuto = false
            practiceHint.Text = "Practice: Velora pauses on each chord until you play the expected keys. Enter skips."
        end
    end

    practiceButton.Activated:Connect(function()
        setPractice(not practiceEnabled)
    end)

    local DIGIT_KEYS = {
        [Enum.KeyCode.Zero] = "0", [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3", [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6", [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
    }
    local SHIFT_DIGITS = { ["1"]="!", ["2"]="@", ["3"]="#", ["4"]="$", ["5"]="%", ["6"]="^", ["7"]="&", ["8"]="*", ["9"]="(", ["0"]= ")" }

    local function keyToVeloraChar(input)
        local code = input.KeyCode
        local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        local digit = DIGIT_KEYS[code]
        if digit then return shift and SHIFT_DIGITS[digit] or digit end
        local name = code.Name
        if #name == 1 and name:match("%a") then
            return shift and string.upper(name) or string.lower(name)
        end
        return nil
    end

    -- ---------------------------------------------------------
    -- 12: Song information panel
    -- ---------------------------------------------------------

    local infoSection = section("SONG INFORMATION", 122)
    local infoTitle = label(infoSection, "No song selected", UDim2.new(1, -24, 0, 20), COLORS.Text, true)
    infoTitle.Position = UDim2.fromOffset(12, 25)
    infoTitle.TextSize = 11
    local infoArtist = label(infoSection, "", UDim2.new(1, -24, 0, 16), COLORS.Sub, false)
    infoArtist.Position = UDim2.fromOffset(12, 45)
    infoArtist.TextSize = 8
    local infoStats = label(infoSection, "", UDim2.new(1, -24, 0, 28), COLORS.Sub, false)
    infoStats.Position = UDim2.fromOffset(12, 64)
    infoStats.TextSize = 8
    infoStats.TextWrapped = true
    local infoCats = label(infoSection, "", UDim2.new(1, -24, 0, 24), COLORS.Muted, false)
    infoCats.Position = UDim2.fromOffset(12, 94)
    infoCats.TextSize = 7
    infoCats.TextWrapped = true

    local function countEvents(song)
        local sheet = type(song) == "table" and song.Notes
        if type(sheet) ~= "string" then return nil end
        local count = 0
        for token in sheet:gmatch("%S+") do
            if token ~= "|" and token ~= "-" and token ~= "_" then count += 1 end
        end
        return count
    end

    local function updateSongInfo(snap)
        snap = snap or snapshot()
        local entry = snap.Entry
        if not entry then
            infoTitle.Text = "No song selected"
            infoArtist.Text = ""
            infoStats.Text = ""
            infoCats.Text = ""
            return
        end
        infoTitle.Text = tostring(entry.Name or entry.Id or "Unknown song")
        infoArtist.Text = tostring(entry.Artist or "Unknown artist")
        local events = countEvents(snap.Song)
        local duration = tonumber(snap.Duration) or 0
        local bpm = tonumber(snap.BPM) or tonumber(entry.BPM) or 0
        local eventText = events and (tostring(events) .. " events") or "event count unavailable"
        infoStats.Text = string.format("%s • %d BPM • %s • Speed %.2fx", formatTime(duration), bpm, eventText, tonumber(snap.Speed) or 1)
        local categories = {}
        if type(entry.Categories) == "table" then
            for _, category in ipairs(entry.Categories) do table.insert(categories, tostring(category)) end
        end
        infoCats.Text = (#categories > 0 and table.concat(categories, "  •  ") or "No categories") .. (API:IsFavorite(entry.Id) and "  •  FAVORITE" or "")
    end

    -- ---------------------------------------------------------
    -- 8 + 10: compact status line + ambient now-playing glow
    -- ---------------------------------------------------------

    local header
    local playerCard
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            if descendant.Text == "VELORA" and not header then header = descendant.Parent end
            if descendant.Text == "NOW PLAYING" and not playerCard then playerCard = descendant.Parent end
        end
    end

    local miniBar, miniFill, miniText
    if header and header:IsA("GuiObject") then
        miniBar = round(make("Frame", {
            Visible = false,
            Position = UDim2.fromOffset(62, 57),
            Size = UDim2.new(1, -174, 0, 3),
            BackgroundColor3 = Color3.fromRGB(54, 31, 35),
            BorderSizePixel = 0,
            ZIndex = 225,
        }, header), 2)
        miniFill = round(make("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = COLORS.Accent,
            BorderSizePixel = 0,
            ZIndex = 226,
        }, miniBar), 2)
        miniText = label(header, "", UDim2.new(1, -174, 0, 11), COLORS.Muted, true)
        miniText.Position = UDim2.fromOffset(62, 43)
        miniText.TextSize = 7
        miniText.ZIndex = 225
        miniText.Visible = false
    end

    local ambientStroke
    if playerCard and playerCard:IsA("GuiObject") then
        ambientStroke = make("UIStroke", {
            Name = "VeloraLabAmbientGlow",
            Color = COLORS.Accent,
            Transparency = 0.88,
            Thickness = 2.1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, playerCard)
    end

    local ambientPulse = 0
    local function pulseAmbient()
        if not ambientStroke or not ambientStroke.Parent then return end
        ambientPulse += 1
        local pulse = ambientPulse
        ambientStroke.Transparency = 0.28
        ambientStroke.Thickness = 2.7
        task.delay(0.04, function()
            if ambientStroke.Parent and ambientPulse == pulse then
                TweenService:Create(ambientStroke, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Transparency = 0.86,
                    Thickness = 1.5,
                }):Play()
            end
        end)
    end

    local function syncCompact(snap)
        local compact = window.Size.X.Offset > 0 and window.Size.X.Offset < 420
        labButton.Visible = not compact
        if compact and drawer.Visible then drawer.Visible = false end
        if miniBar then miniBar.Visible = compact end
        if miniText then miniText.Visible = compact end
        if compact and miniFill and miniText then
            local progress = math.clamp(tonumber(snap.Progress) or 0, 0, 1)
            miniFill.Size = UDim2.new(progress, 0, 1, 0)
            local name = snap.Entry and snap.Entry.Name or "Ready"
            miniText.Text = string.format("%s  •  %s / %s", tostring(name), formatTime(snap.Position), formatTime(snap.Duration))
        end
    end

    -- ---------------------------------------------------------
    -- 6: seek hover-time preview
    -- ---------------------------------------------------------

    local hoverTooltip = round(edge(make("TextLabel", {
        Visible = false,
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(48, 22),
        BackgroundColor3 = COLORS.Ink,
        BorderSizePixel = 0,
        Text = "0:00",
        TextColor3 = COLORS.Text,
        TextSize = 8,
        Font = Enum.Font.BuilderSansExtraBold,
        ZIndex = 400,
    }, window), 0.35, 1, COLORS.Accent), 8)

    local function attachSeekPreview()
        local seekHit
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant:IsA("TextButton") and descendant.Text == "" and descendant.BackgroundTransparency >= 0.95 then
                local width = descendant.Size.X.Offset
                local height = descendant.Size.Y.Offset
                if width >= 190 and width <= 220 and height >= 20 and height <= 28 then
                    seekHit = descendant
                    break
                end
            end
        end
        if not seekHit then return end

        local hovering = false
        local function updateHover()
            if not hovering or not seekHit.Parent then return end
            local snap = snapshot()
            if not snap.Duration or snap.Duration <= 0 then
                hoverTooltip.Visible = false
                return
            end
            local mouse = UserInputService:GetMouseLocation()
            local ratio = math.clamp((mouse.X - seekHit.AbsolutePosition.X) / math.max(1, seekHit.AbsoluteSize.X), 0, 1)
            hoverTooltip.Text = formatTime(snap.Duration * ratio)
            local localX = mouse.X - window.AbsolutePosition.X
            local localY = seekHit.AbsolutePosition.Y - window.AbsolutePosition.Y - 5
            hoverTooltip.Position = UDim2.fromOffset(localX, localY)
            hoverTooltip.Visible = true
        end
        seekHit.MouseEnter:Connect(function() hovering = true; updateHover() end)
        seekHit.MouseLeave:Connect(function() hovering = false; hoverTooltip.Visible = false end)
        seekHit.MouseMoved:Connect(updateHover)
    end
    task.delay(0.15, attachSeekPreview)

    -- ---------------------------------------------------------
    -- 4: layered action sound design
    -- ---------------------------------------------------------

    local function playTone(speed, volume)
        pcall(function()
            local sound = Instance.new("Sound")
            sound.Name = "VeloraLabTone"
            sound.SoundId = "rbxassetid://17582213219"
            sound.Volume = volume or 0.035
            sound.PlaybackSpeed = speed or 1
            sound.Parent = SoundService
            sound:Play()
            sound.Ended:Connect(function() if sound.Parent then sound:Destroy() end end)
            task.delay(2, function() if sound.Parent then sound:Destroy() end end)
        end)
    end

    local function buttonHasIcon(buttonObject, iconName)
        for _, child in ipairs(buttonObject:GetDescendants()) do
            if child:GetAttribute("IconName") == iconName then return true end
        end
        return false
    end

    local function hasLabel(buttonObject, textValue)
        for _, child in ipairs(buttonObject:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text == textValue then return true end
        end
        return false
    end

    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextButton") then
            if buttonHasIcon(descendant, "play") or buttonHasIcon(descendant, "pause") then
                descendant.Activated:Connect(function() playTone(0.88, 0.045) end)
            elseif buttonHasIcon(descendant, "heart") then
                descendant.Activated:Connect(function() playTone(1.18, 0.03) end)
            elseif hasLabel(descendant, "RESET BPM") then
                descendant.Activated:Connect(function() playTone(0.78, 0.035) end)
            end
        end
    end

    -- ---------------------------------------------------------
    -- Shared event/state wiring
    -- ---------------------------------------------------------

    local connections = {}
    local destroyed = false
    local lastUiTick = 0
    local lastMemoryTick = 0

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    if API.NotePlayed then
        connect(API.NotePlayed, function(...)
            local chars = notesFromArgs(...)
            showNotes(chars)
            pulseAmbient()

            if practiceEnabled and #chars > 0 then
                local snap = snapshot()
                if snap.Playing and not snap.Paused then
                    practiceExpected = {}
                    local names = {}
                    for _, char in ipairs(chars) do
                        practiceExpected[char] = true
                        table.insert(names, charToNote[char] or char)
                    end
                    practiceHint.Text = "PLAY: " .. table.concat(names, " + ") .. "   •   Enter skips"
                    task.defer(function()
                        local current = snapshot()
                        if practiceEnabled and current.Playing and not current.Paused then
                            pcall(API.Pause, API)
                        end
                    end)
                end
            end
        end)
    end

    if API.Changed then
        connect(API.Changed, function()
            local snap = snapshot()
            local id = currentId(snap)
            updateSongInfo(snap)
            syncCompact(snap)

            if id and id ~= lastMemoryId then
                lastMemoryId = id
                task.defer(function()
                    if not destroyed and currentId(snapshot()) == id then restoreSongState(id) end
                end)
            elseif id then
                saveSongState(snap)
            end
        end)
    end

    connect(UserInputService.InputBegan, function(input, gameProcessed)
        if destroyed or gameProcessed then return end
        if UserInputService:GetFocusedTextBox() then return end

        if practiceEnabled and next(practiceExpected) ~= nil then
            if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
                practiceExpected = {}
                practiceHint.Text = "Skipped. Waiting for the next chord…"
                local snap = snapshot()
                if snap.Playing and snap.Paused then pcall(API.Pause, API) end
                return
            end
            local char = keyToVeloraChar(input)
            if char and practiceExpected[char] then
                practiceExpected[char] = nil
                if next(practiceExpected) == nil then
                    practiceHint.Text = "Nice. Waiting for the next chord…"
                    local snap = snapshot()
                    if snap.Playing and snap.Paused then pcall(API.Pause, API) end
                end
            end
            return
        end

        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrl and input.KeyCode == Enum.KeyCode.J then
            if labButton.Visible then drawer.Visible = not drawer.Visible end
            return
        end
        if not shortcutsEnabled then return end

        local snap = snapshot()
        if input.KeyCode == Enum.KeyCode.Space then
            if snap.Playing then pcall(API.Pause, API) else pcall(API.Play, API) end
        elseif input.KeyCode == Enum.KeyCode.Left then
            if snap.Duration and snap.Duration > 0 then pcall(API.Seek, API, math.clamp((snap.Position - 5) / snap.Duration, 0, 1)) end
        elseif input.KeyCode == Enum.KeyCode.Right then
            if snap.Duration and snap.Duration > 0 then pcall(API.Seek, API, math.clamp((snap.Position + 5) / snap.Duration, 0, 1)) end
        elseif input.KeyCode == Enum.KeyCode.Up then
            if snap.BPM then pcall(API.SetBPM, API, snap.BPM + 1) end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if snap.BPM then pcall(API.SetBPM, API, snap.BPM - 1) end
        elseif input.KeyCode == Enum.KeyCode.L then
            pcall(API.SetLoop, API, not snap.Loop)
        elseif input.KeyCode == Enum.KeyCode.F and snap.Entry and snap.Entry.Id then
            pcall(API.ToggleFavorite, API, snap.Entry.Id)
        end
    end)

    connect(RunService.Heartbeat, function()
        if destroyed then return end
        local now = os.clock()
        local snap = snapshot()

        if aPoint and bPoint and bPoint > aPoint + 0.05 and snap.Playing and not snap.Paused
            and tonumber(snap.Position) and snap.Position >= bPoint and tonumber(snap.Duration) and snap.Duration > 0 then
            pcall(API.Seek, API, math.clamp(aPoint / snap.Duration, 0, 1))
        end

        if now - lastUiTick >= 0.10 then
            lastUiTick = now
            syncCompact(snap)
            updateSongInfo(snap)
        end

        if memoryEnabled and now - lastMemoryTick >= 2.0 then
            lastMemoryTick = now
            if snap.Entry then saveSongState(snap) end
        end
    end)

    local function cleanup()
        if destroyed then return end
        destroyed = true
        if practiceEnabled and practiceRestoreAuto then pcall(API.SetAutoInput, API, true) end
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        table.clear(connections)
    end

    connect(gui.AncestryChanged, function(_, parent)
        if parent == nil then cleanup() end
    end)

    refreshAB()
    updateSongInfo(snapshot())
    syncCompact(snapshot())

    API.UpgradeLab = {
        Version = "0.1-test",
        SetPractice = setPractice,
        SetMemory = function(enabled)
            memoryEnabled = enabled == true
            memoryButton.Text = memoryEnabled and "MEMORY ON" or "MEMORY OFF"
            setButtonActive(memoryButton, memoryEnabled)
        end,
        SetShortcuts = function(enabled)
            shortcutsEnabled = enabled == true
            shortcutsButton.Text = shortcutsEnabled and "KEYS ON" or "KEYS OFF"
            setButtonActive(shortcutsButton, shortcutsEnabled)
        end,
        ClearAB = function()
            aPoint, bPoint = nil, nil
            refreshAB()
        end,
        Open = function() if labButton.Visible then drawer.Visible = true end end,
        Close = function() drawer.Visible = false end,
    }

    return true
end
