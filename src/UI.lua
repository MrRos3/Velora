-- Velora v0.2
-- Original responsive piano browser inspired by the dense three-column workflow
-- of classic Roblox piano players. Built for PlayerGui and mobile input.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI = {}

local COLORS = {
    Backdrop = Color3.fromRGB(8, 10, 17),
    Window = Color3.fromRGB(17, 19, 30),
    Panel = Color3.fromRGB(23, 26, 40),
    Raised = Color3.fromRGB(31, 35, 52),
    Hover = Color3.fromRGB(42, 46, 66),
    Accent = Color3.fromRGB(178, 92, 255),
    Accent2 = Color3.fromRGB(255, 92, 166),
    Text = Color3.fromRGB(248, 246, 255),
    Subtext = Color3.fromRGB(169, 170, 190),
    Muted = Color3.fromRGB(102, 105, 128),
    Success = Color3.fromRGB(91, 232, 162),
    Danger = Color3.fromRGB(255, 103, 125),
    Stroke = Color3.fromRGB(255, 255, 255),
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
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, transparency, thickness, color)
    return create("UIStroke", {
        Color = color or COLORS.Stroke,
        Transparency = transparency or 0.88,
        Thickness = thickness or 1,
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

local function text(parent, value, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = value or "",
        TextColor3 = color or COLORS.Text,
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function baseButton(parent, value)
    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.Raised,
        BorderSizePixel = 0,
        Text = value or "",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
    }, parent)
    corner(button, 10)
    stroke(button, 0.9)
    return button
end

local function hover(button, normalColor, hoverColor)
    normalColor = normalColor or button.BackgroundColor3
    hoverColor = hoverColor or COLORS.Hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), { BackgroundColor3 = hoverColor }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.14), { BackgroundColor3 = normalColor }):Play()
    end)
end

local function formatTime(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    return string.format("%d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
end

local function containsCategory(song, category)
    if category == "All songs" then
        return true
    end
    for _, value in ipairs(song.Categories or {}) do
        if value == category then
            return true
        end
    end
    return false
end

function UI.create(controller)
    local localPlayer = Players.LocalPlayer
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local previous = playerGui:FindFirstChild("Velora")
    if previous then
        previous:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "Velora",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 72,
    }, playerGui)

    local dim = create("Frame", {
        Name = "Dim",
        BackgroundColor3 = COLORS.Backdrop,
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    }, gui)

    local window = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = COLORS.Window,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(760, 500),
        ClipsDescendants = true,
    }, dim)
    corner(window, 18)
    stroke(window, 0.76, 1)

    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 24, 43)),
            ColorSequenceKeypoint.new(0.5, COLORS.Window),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 20, 31)),
        }),
        Rotation = 28,
    }, window)

    local uiScale = create("UIScale", { Scale = 1 }, window)
    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local viewport = camera.ViewportSize
        uiScale.Scale = math.clamp(math.min(viewport.X / 790, viewport.Y / 535) * 0.96, 0.45, 1)
    end
    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    local topbar = create("Frame", {
        Name = "Topbar",
        BackgroundColor3 = Color3.fromRGB(27, 29, 44),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 58),
    }, window)

    local brandMark = create("Frame", {
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 15),
        Size = UDim2.fromOffset(28, 28),
    }, topbar)
    corner(brandMark, 9)
    create("UIGradient", {
        Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2),
        Rotation = 45,
    }, brandMark)
    local note = text(brandMark, "♪", 19, COLORS.Text, Enum.Font.GothamBold)
    note.Size = UDim2.fromScale(1, 1)
    note.TextXAlignment = Enum.TextXAlignment.Center

    local title = text(topbar, "VELORA", 19, COLORS.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(56, 8)
    title.Size = UDim2.fromOffset(150, 24)

    local version = text(topbar, "PIANO PLAYER  •  v0.2", 10, COLORS.Muted, Enum.Font.GothamMedium)
    version.Position = UDim2.fromOffset(57, 31)
    version.Size = UDim2.fromOffset(190, 17)

    local minimize = baseButton(topbar, "—")
    minimize.Position = UDim2.new(1, -82, 0, 14)
    minimize.Size = UDim2.fromOffset(28, 28)
    minimize.BackgroundColor3 = Color3.fromRGB(42, 44, 61)
    hover(minimize)

    local close = baseButton(topbar, "×")
    close.Position = UDim2.new(1, -45, 0, 14)
    close.Size = UDim2.fromOffset(28, 28)
    close.BackgroundColor3 = Color3.fromRGB(58, 39, 52)
    close.TextColor3 = COLORS.Danger
    close.TextSize = 18
    hover(close, close.BackgroundColor3, Color3.fromRGB(82, 44, 59))

    local restore = baseButton(gui, "♪  VELORA")
    restore.Name = "Restore"
    restore.AnchorPoint = Vector2.new(1, 1)
    restore.Position = UDim2.new(1, -18, 1, -18)
    restore.Size = UDim2.fromOffset(112, 38)
    restore.BackgroundColor3 = COLORS.Accent
    restore.Visible = false
    restore.ZIndex = 20
    hover(restore, COLORS.Accent, COLORS.Accent2)

    local function setOpen(isOpen)
        dim.Visible = isOpen
        restore.Visible = not isOpen
    end
    minimize.Activated:Connect(function() setOpen(false) end)
    close.Activated:Connect(function() setOpen(false) end)
    restore.Activated:Connect(function() setOpen(true) end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            setOpen(not dim.Visible)
        end
    end)

    -- Dragging works with both mouse and touch.
    local dragging = false
    local dragStart
    local startPosition
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 1, -58),
    }, window)

    -- Left category rail.
    local rail = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 20, 31),
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 154, 1, 0),
    }, body)
    create("Frame", {
        BackgroundColor3 = COLORS.Stroke,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
    }, rail)

    local libraryLabel = text(rail, "LIBRARY", 10, COLORS.Muted, Enum.Font.GothamBold)
    libraryLabel.Position = UDim2.fromOffset(16, 15)
    libraryLabel.Size = UDim2.fromOffset(120, 18)

    local categoryScroll = create("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(10, 40),
        ScrollBarImageColor3 = COLORS.Accent,
        ScrollBarThickness = 2,
        Size = UDim2.new(1, -20, 1, -104),
    }, rail)
    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, categoryScroll)

    local randomButton = baseButton(rail, "↻  Random song")
    randomButton.Position = UDim2.new(0, 10, 1, -52)
    randomButton.Size = UDim2.new(1, -20, 0, 38)
    randomButton.BackgroundColor3 = Color3.fromRGB(48, 34, 69)
    randomButton.TextColor3 = Color3.fromRGB(222, 190, 255)
    hover(randomButton, randomButton.BackgroundColor3, Color3.fromRGB(64, 41, 91))

    -- Center song browser.
    local browser = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(154, 0),
        Size = UDim2.new(0, 334, 1, 0),
    }, body)

    local browserTitle = text(browser, "Songs", 22, COLORS.Text, Enum.Font.GothamBold)
    browserTitle.Position = UDim2.fromOffset(18, 13)
    browserTitle.Size = UDim2.fromOffset(130, 30)

    local songCount = text(browser, "0 tracks", 11, COLORS.Muted, Enum.Font.GothamMedium)
    songCount.Position = UDim2.new(1, -104, 0, 18)
    songCount.Size = UDim2.fromOffset(86, 22)
    songCount.TextXAlignment = Enum.TextXAlignment.Right

    local search = create("TextBox", {
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = COLORS.Muted,
        PlaceholderText = "Search title, artist, category...",
        Position = UDim2.fromOffset(18, 51),
        Size = UDim2.new(1, -36, 0, 38),
        Text = "",
        TextColor3 = COLORS.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, browser)
    corner(search, 11)
    stroke(search, 0.88)
    padding(search, 14, 14, 0, 0)

    local songsScroll = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(18, 101),
        ScrollBarImageColor3 = COLORS.Accent,
        ScrollBarThickness = 3,
        Size = UDim2.new(1, -36, 1, -115),
    }, browser)

    local songsContent = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -6, 0, 0),
    }, songsScroll)
    local songsLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, songsContent)
    songsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        songsScroll.CanvasSize = UDim2.fromOffset(0, songsLayout.AbsoluteContentSize.Y + 6)
    end)

    -- Right now-playing panel.
    local now = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 23, 35),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(488, 0),
        Size = UDim2.new(1, -488, 1, 0),
    }, body)
    create("Frame", {
        BackgroundColor3 = COLORS.Stroke,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
    }, now)
    local nowLabel = text(now, "NOW PLAYING", 10, COLORS.Muted, Enum.Font.GothamBold)
    nowLabel.Position = UDim2.fromOffset(18, 16)
    nowLabel.Size = UDim2.new(1, -36, 0, 17)

    local cover = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(46, 32, 65),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 43),
        Size = UDim2.fromOffset(64, 64),
    }, now)
    corner(cover, 16)
    stroke(cover, 0.78)
    create("UIGradient", {
        Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2),
        Rotation = 135,
    }, cover)
    local coverNote = text(cover, "♫", 29, COLORS.Text, Enum.Font.GothamBold)
    coverNote.Size = UDim2.fromScale(1, 1)
    coverNote.TextXAlignment = Enum.TextXAlignment.Center

    local selectedName = text(now, "Choose a song", 16, COLORS.Text, Enum.Font.GothamBold)
    selectedName.Position = UDim2.fromOffset(94, 45)
    selectedName.Size = UDim2.new(1, -147, 0, 25)
    selectedName.TextTruncate = Enum.TextTruncate.AtEnd

    local selectedArtist = text(now, "Velora Library", 11, COLORS.Subtext, Enum.Font.Gotham)
    selectedArtist.Position = UDim2.fromOffset(94, 70)
    selectedArtist.Size = UDim2.new(1, -147, 0, 20)
    selectedArtist.TextTruncate = Enum.TextTruncate.AtEnd

    local favorite = baseButton(now, "☆")
    favorite.Position = UDim2.new(1, -48, 0, 55)
    favorite.Size = UDim2.fromOffset(30, 30)
    favorite.BackgroundColor3 = COLORS.Raised
    favorite.TextSize = 20
    hover(favorite)

    local tags = text(now, "No categories", 10, COLORS.Muted, Enum.Font.GothamMedium)
    tags.Position = UDim2.fromOffset(94, 90)
    tags.Size = UDim2.new(1, -112, 0, 17)
    tags.TextTruncate = Enum.TextTruncate.AtEnd

    local divider = create("Frame", {
        BackgroundColor3 = COLORS.Stroke,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 124),
        Size = UDim2.new(1, -36, 0, 1),
    }, now)

    local bpmLabel = text(now, "BPM", 10, COLORS.Muted, Enum.Font.GothamBold)
    bpmLabel.Position = UDim2.fromOffset(18, 142)
    bpmLabel.Size = UDim2.fromOffset(60, 18)

    local bpmBox = create("TextBox", {
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(18, 164),
        Size = UDim2.fromOffset(68, 36),
        Text = "120",
        TextColor3 = COLORS.Text,
        TextSize = 13,
    }, now)
    corner(bpmBox, 9)
    stroke(bpmBox, 0.87)

    local speedButton = baseButton(now, "1× speed")
    speedButton.Position = UDim2.fromOffset(96, 164)
    speedButton.Size = UDim2.fromOffset(72, 36)
    hover(speedButton)

    local loopButton = baseButton(now, "Loop off")
    loopButton.Position = UDim2.fromOffset(178, 164)
    loopButton.Size = UDim2.new(1, -196, 0, 36)
    hover(loopButton)

    local statusPill = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(29, 51, 46),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 217),
        Size = UDim2.new(1, -36, 0, 30),
    }, now)
    corner(statusPill, 9)
    local status = text(statusPill, "●  Ready • preview mode", 10, COLORS.Success, Enum.Font.GothamMedium)
    status.Size = UDim2.new(1, -20, 1, 0)
    status.Position = UDim2.fromOffset(10, 0)
    status.TextXAlignment = Enum.TextXAlignment.Center

    local progressHitbox = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.Raised,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 269),
        Size = UDim2.new(1, -36, 0, 8),
        Text = "",
    }, now)
    corner(progressHitbox, 4)
    local progressFill = create("Frame", {
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
    }, progressHitbox)
    corner(progressFill, 4)
    create("UIGradient", {
        Color = ColorSequence.new(COLORS.Accent, COLORS.Accent2),
    }, progressFill)

    local elapsed = text(now, "0:00", 10, COLORS.Muted, Enum.Font.GothamMedium)
    elapsed.Position = UDim2.fromOffset(18, 282)
    elapsed.Size = UDim2.fromOffset(55, 18)
    local duration = text(now, "0:00", 10, COLORS.Muted, Enum.Font.GothamMedium)
    duration.Position = UDim2.new(1, -73, 0, 282)
    duration.Size = UDim2.fromOffset(55, 18)
    duration.TextXAlignment = Enum.TextXAlignment.Right

    local stopButton = baseButton(now, "■")
    stopButton.Position = UDim2.fromOffset(18, 315)
    stopButton.Size = UDim2.fromOffset(54, 48)
    stopButton.TextSize = 13
    hover(stopButton)

    local playButton = baseButton(now, "▶  Play")
    playButton.Position = UDim2.fromOffset(81, 315)
    playButton.Size = UDim2.new(1, -162, 0, 48)
    playButton.BackgroundColor3 = COLORS.Accent
    playButton.Font = Enum.Font.GothamBold
    hover(playButton, COLORS.Accent, COLORS.Accent2)

    local pauseButton = baseButton(now, "Ⅱ")
    pauseButton.Position = UDim2.new(1, -72, 0, 315)
    pauseButton.Size = UDim2.fromOffset(54, 48)
    hover(pauseButton)

    local hint = text(now, "RightShift toggles Velora", 10, COLORS.Muted, Enum.Font.Gotham)
    hint.Position = UDim2.new(0, 18, 1, -43)
    hint.Size = UDim2.new(1, -36, 0, 20)
    hint.TextXAlignment = Enum.TextXAlignment.Center

    local selectedCategory = "All songs"
    local categoryButtons = {}
    local selectedId = nil

    local function matches(song)
        if selectedCategory == "Favorites" and not controller:IsFavorite(song.Id) then
            return false
        elseif selectedCategory ~= "Favorites" and not containsCategory(song, selectedCategory) then
            return false
        end

        local query = search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        if query == "" then
            return true
        end

        local haystack = string.lower(table.concat({
            song.Name or "",
            song.Artist or "",
            table.concat(song.Categories or {}, " "),
        }, " "))
        return string.find(haystack, query, 1, true) ~= nil
    end

    local refreshSongs
    local function selectCategory(category)
        selectedCategory = category
        for name, button in pairs(categoryButtons) do
            local active = name == category
            button.BackgroundColor3 = active and Color3.fromRGB(58, 38, 80) or Color3.fromRGB(26, 29, 43)
            button.TextColor3 = active and Color3.fromRGB(229, 205, 255) or COLORS.Subtext
        end
        refreshSongs()
    end

    local categories = { "All songs", "Favorites" }
    local seen = { ["All songs"] = true, Favorites = true }
    for _, song in ipairs(controller:GetSongs()) do
        for _, category in ipairs(song.Categories or {}) do
            if not seen[category] then
                seen[category] = true
                table.insert(categories, category)
            end
        end
    end

    for index, category in ipairs(categories) do
        local button = baseButton(categoryScroll, category == "Favorites" and "☆  Favorites" or category)
        button.LayoutOrder = index
        button.Size = UDim2.new(1, -4, 0, 36)
        button.BackgroundColor3 = Color3.fromRGB(26, 29, 43)
        button.TextColor3 = COLORS.Subtext
        button.TextXAlignment = Enum.TextXAlignment.Left
        padding(button, 12, 8, 0, 0)
        hover(button, button.BackgroundColor3, Color3.fromRGB(39, 42, 60))
        button.Activated:Connect(function()
            selectCategory(category)
        end)
        categoryButtons[category] = button
    end

    refreshSongs = function()
        for _, child in ipairs(songsContent:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end

        local visible = 0
        for order, song in ipairs(controller:GetSongs()) do
            if matches(song) then
                visible += 1
                local card = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = song.Id == selectedId and Color3.fromRGB(52, 37, 72) or COLORS.Panel,
                    BorderSizePixel = 0,
                    LayoutOrder = order,
                    Size = UDim2.new(1, 0, 0, 66),
                    Text = "",
                }, songsContent)
                corner(card, 12)
                stroke(card, song.Id == selectedId and 0.58 or 0.9, 1,
                    song.Id == selectedId and COLORS.Accent or COLORS.Stroke)
                hover(card, card.BackgroundColor3, song.Id == selectedId
                    and Color3.fromRGB(62, 42, 84) or COLORS.Hover)

                local cardName = text(card, song.Name, 13, COLORS.Text, Enum.Font.GothamBold)
                cardName.Position = UDim2.fromOffset(14, 9)
                cardName.Size = UDim2.new(1, -76, 0, 22)
                cardName.TextTruncate = Enum.TextTruncate.AtEnd

                local cardMeta = text(card,
                    string.format("%s  •  %d BPM", song.Artist or "Unknown", song.BPM or 120),
                    10, COLORS.Subtext, Enum.Font.Gotham)
                cardMeta.Position = UDim2.fromOffset(14, 31)
                cardMeta.Size = UDim2.new(1, -76, 0, 18)
                cardMeta.TextTruncate = Enum.TextTruncate.AtEnd

                local cardTags = text(card, table.concat(song.Categories or {}, "  ·  "),
                    9, COLORS.Muted, Enum.Font.GothamMedium)
                cardTags.Position = UDim2.fromOffset(14, 48)
                cardTags.Size = UDim2.new(1, -76, 0, 13)
                cardTags.TextTruncate = Enum.TextTruncate.AtEnd

                local star = baseButton(card, controller:IsFavorite(song.Id) and "★" or "☆")
                star.Position = UDim2.new(1, -48, 0.5, -17)
                star.Size = UDim2.fromOffset(34, 34)
                star.BackgroundColor3 = Color3.fromRGB(37, 39, 56)
                star.TextColor3 = controller:IsFavorite(song.Id) and COLORS.Accent2 or COLORS.Subtext
                star.TextSize = 18
                star.ZIndex = 3
                star.Activated:Connect(function()
                    controller:ToggleFavorite(song.Id)
                end)

                card.Activated:Connect(function()
                    controller:LoadSong(song.Id)
                end)
            end
        end

        songCount.Text = string.format("%d track%s", visible, visible == 1 and "" or "s")
    end

    local function updateSelection()
        local entry = controller.CurrentEntry
        if not entry then
            return
        end

        selectedId = entry.Id
        selectedName.Text = entry.Name or "Untitled"
        selectedArtist.Text = entry.Artist or "Unknown artist"
        tags.Text = table.concat(entry.Categories or {}, "  ·  ")
        favorite.Text = controller:IsFavorite(entry.Id) and "★" or "☆"
        favorite.TextColor3 = controller:IsFavorite(entry.Id) and COLORS.Accent2 or COLORS.Text
        bpmBox.Text = tostring(math.floor(controller.CurrentBPM or entry.BPM or 120))
        refreshSongs()
    end

    search:GetPropertyChangedSignal("Text"):Connect(refreshSongs)
    favorite.Activated:Connect(function()
        if controller.CurrentEntry then
            controller:ToggleFavorite(controller.CurrentEntry.Id)
        end
    end)
    randomButton.Activated:Connect(function()
        controller:PickRandom(matches)
    end)
    bpmBox.FocusLost:Connect(function()
        local bpm = controller:SetBPM(bpmBox.Text)
        if bpm then
            bpmBox.Text = tostring(math.floor(bpm))
        end
    end)

    local speeds = { 0.75, 1, 1.25, 1.5, 2 }
    local speedIndex = 2
    speedButton.Activated:Connect(function()
        speedIndex = speedIndex % #speeds + 1
        local value = controller:SetSpeed(speeds[speedIndex])
        speedButton.Text = string.format("%g× speed", value)
    end)

    loopButton.Activated:Connect(function()
        local enabled = not controller:GetSnapshot().Loop
        controller:SetLoop(enabled)
        loopButton.Text = enabled and "Loop on" or "Loop off"
        loopButton.TextColor3 = enabled and COLORS.Accent2 or COLORS.Text
    end)

    playButton.Activated:Connect(function() controller:Play() end)
    pauseButton.Activated:Connect(function() controller:Pause() end)
    stopButton.Activated:Connect(function() controller:Stop() end)

    local function seekFromInput(input)
        local x = math.clamp(input.Position.X - progressHitbox.AbsolutePosition.X, 0, progressHitbox.AbsoluteSize.X)
        if progressHitbox.AbsoluteSize.X > 0 then
            controller:Seek(x / progressHitbox.AbsoluteSize.X)
        end
    end
    progressHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            seekFromInput(input)
        end
    end)

    controller.Changed.Event:Connect(function(reason)
        if reason == "selection" or reason == "bpm" then
            updateSelection()
        elseif reason == "favorites" then
            updateSelection()
            if selectedCategory == "Favorites" then
                refreshSongs()
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not gui.Parent then
            return
        end
        local snapshot = controller:GetSnapshot()
        progressFill.Size = UDim2.fromScale(snapshot.Progress, 1)
        elapsed.Text = formatTime(snapshot.Position)
        duration.Text = formatTime(snapshot.Duration)

        local suffix = snapshot.IsBound and "piano connected" or "preview mode"
        status.Text = string.format("●  %s • %s", snapshot.State, suffix)
        status.TextColor3 = snapshot.State == "Playing" and COLORS.Accent2 or COLORS.Success
        playButton.Text = snapshot.Paused and "▶  Resume" or "▶  Play"
        pauseButton.Text = snapshot.Paused and "▶" or "Ⅱ"
    end)

    selectCategory("All songs")

    return {
        Gui = gui,
        Window = window,
        Status = status,
        Refresh = refreshSongs,
        SetOpen = setOpen,
    }
end

return UI
