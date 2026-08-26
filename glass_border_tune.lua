-- Velora premium ruby-edge visibility pass.
-- Test branch only. Keeps the current dark smoked-glass palette and only
-- strengthens the glass edges so controls remain clearly readable.

return function(API)
    assert(type(API) == "table", "Velora border tune expects the Velora API")

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    local window = (API.UI and API.UI.Window) or gui:FindFirstChild("Aurora", true)
    if not window then return false, "Velora window not found" end

    local RUBY_DARK = Color3.fromRGB(106, 38, 45)
    local RUBY = Color3.fromRGB(211, 76, 90) -- #D34C5A
    local RUBY_BRIGHT = Color3.fromRGB(230, 112, 124)
    local RUBY_GLASS = Color3.fromRGB(211, 130, 140)

    local function findParentByLabel(wanted)
        for _, descendant in ipairs(gui:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Text == wanted then
                return descendant.Parent
            end
        end
    end

    local header = findParentByLabel("VELORA")
    local playerCard = findParentByLabel("NOW PLAYING")
    local nav = findParentByLabel("DISCOVER")
    local searchBox
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextBox") and string.find(descendant.PlaceholderText or "", "Search", 1, true) then
            searchBox = descendant
            break
        end
    end
    local browser = searchBox and searchBox.Parent

    -- Lock in the approved default dark smoked-glass base.
    if window:IsA("GuiObject") then
        window.BackgroundColor3 = Color3.fromRGB(2, 1, 3)
        window.BackgroundTransparency = 0.015
    end
    if header and header:IsA("GuiObject") then
        header.BackgroundColor3 = Color3.fromRGB(7, 3, 6)
        header.BackgroundTransparency = 0.08
    end
    for _, panel in ipairs({nav, browser}) do
        if panel and panel:IsA("GuiObject") then
            panel.BackgroundColor3 = Color3.fromRGB(6, 3, 5)
            panel.BackgroundTransparency = 0.10
        end
    end
    if playerCard and playerCard:IsA("GuiObject") then
        playerCard.BackgroundColor3 = Color3.fromRGB(8, 3, 6)
        playerCard.BackgroundTransparency = 0.06
    end

    local function brightenEdgeGradient(stroke)
        local gradient = stroke:FindFirstChild("VeloraPremiumEdgeReflection")
        if not gradient or not gradient:IsA("UIGradient") then return end
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, RUBY_DARK),
            ColorSequenceKeypoint.new(0.24, RUBY_GLASS),
            ColorSequenceKeypoint.new(0.52, RUBY),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(63, 20, 27)),
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.42),
            NumberSequenceKeypoint.new(0.24, 0.06),
            NumberSequenceKeypoint.new(0.55, 0.24),
            NumberSequenceKeypoint.new(1, 0.58),
        })
    end

    local function brighten(stroke, transparency, thickness, color)
        if not stroke or not stroke:IsA("UIStroke") then return end
        stroke.Enabled = true
        stroke.Color = color or RUBY
        stroke.Transparency = math.min(stroke.Transparency, transparency)
        stroke.Thickness = math.max(stroke.Thickness, thickness)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        brightenEdgeGradient(stroke)
    end

    local function isBpmPill(object)
        return object and object:IsA("Frame")
            and object.Size.X.Offset == 128
            and object.Size.Y.Offset == 38
            and playerCard and object.Parent == playerCard
    end

    local function isProgressTrack(object)
        return object and object:IsA("Frame")
            and object.Size.X.Offset == 206
            and object.Size.Y.Offset == 8
            and playerCard and object.Parent == playerCard
    end

    local function isProgressScrubber(object)
        return object and object:IsA("Frame")
            and object.Size.X.Offset == 15
            and object.Size.Y.Offset == 15
            and isProgressTrack(object.Parent)
    end

    local function softenProgressEdge(stroke)
        if not stroke or not stroke:IsA("UIStroke") then return end
        stroke.Enabled = true
        stroke.Color = RUBY
        stroke.Transparency = 0.70
        stroke.Thickness = 0.75
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local gradient = stroke:FindFirstChild("VeloraPremiumEdgeReflection")
        if gradient and gradient:IsA("UIGradient") then
            -- A uniform tint keeps the track glassy without the small moving-
            -- looking flare created by the previous directional reflection.
            gradient.Color = ColorSequence.new(RUBY, RUBY)
            gradient.Transparency = NumberSequence.new(0.35)
        end
    end

    local function restoreProgressScrubber(scrubber)
        if not isProgressScrubber(scrubber) then return end
        scrubber.Visible = true
        scrubber.BackgroundColor3 = Color3.fromRGB(224, 196, 202)
        scrubber.BackgroundTransparency = 0.10
        local stroke = scrubber:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = RUBY
            stroke.Transparency = 0.34
            stroke.Thickness = 1
        end
    end

    local function tuneStroke(stroke)
        if not stroke:IsA("UIStroke") then return end
        local parent = stroke.Parent
        local name = stroke.Name

        if name == "VeloraPremiumGlassOuterEdge" then
            if parent == window then
                brighten(stroke, 0.24, 2.2, RUBY)
            elseif parent == playerCard then
                brighten(stroke, 0.38, 1.2, RUBY)
            elseif parent == header then
                brighten(stroke, 0.46, 1.1, RUBY)
            elseif parent == nav or parent == browser then
                brighten(stroke, 0.50, 1.0, RUBY)
            else
                brighten(stroke, 0.48, 1.05, RUBY)
            end
        elseif name == "VeloraPremiumGlassInnerEdge" then
            brighten(stroke, 0.66, 0.8, RUBY_GLASS)
        elseif name == "VeloraPremiumInsetEdge" then
            if isProgressTrack(parent) then
                softenProgressEdge(stroke)
            elseif isBpmPill(parent) then
                brighten(stroke, 0.34, 1.15, RUBY)
            else
                brighten(stroke, 0.48, 0.95, RUBY)
            end
        elseif name == "VeloraPremiumButtonEdge" then
            local target = 0.46
            if parent and parent:IsA("TextButton") then
                -- Preserve already-brighter selected/play states while ensuring
                -- ordinary controls (BPM arrows, Loop, Stop, Favorite, header) show.
                if playerCard and parent:IsDescendantOf(playerCard) then target = 0.40 end
                if parent.Parent and isBpmPill(parent.Parent) then target = 0.30 end
            end
            brighten(stroke, target, 1.0, RUBY)
        elseif name == "VeloraPremiumInputEdge" then
            brighten(stroke, 0.42, 1.0, RUBY)
        end
    end

    local function tuneObject(object)
        if object:IsA("UIStroke") then
            tuneStroke(object)
        elseif isProgressScrubber(object) then
            restoreProgressScrubber(object)
        elseif isBpmPill(object) then
            local stroke = object:FindFirstChild("VeloraPremiumInsetEdge")
            if stroke then tuneStroke(stroke) end
            for _, child in ipairs(object:GetDescendants()) do
                if child:IsA("UIStroke") then tuneStroke(child) end
            end
        end
    end

    for _, descendant in ipairs(gui:GetDescendants()) do
        tuneObject(descendant)
    end

    -- Glass cards and controls are rebuilt dynamically when filters/songs change.
    -- Retune those new edges after the glass layer creates them.
    local descendantConnection = gui.DescendantAdded:Connect(function(descendant)
        task.defer(function()
            if descendant.Parent then tuneObject(descendant) end
        end)
        task.delay(0.03, function()
            if descendant.Parent then
                if descendant:IsA("GuiObject") then
                    for _, child in ipairs(descendant:GetDescendants()) do
                        if child:IsA("UIStroke") then tuneStroke(child) end
                    end
                elseif descendant:IsA("UIStroke") then
                    tuneStroke(descendant)
                end
            end
        end)
    end)

    local ancestryConnection
    ancestryConnection = gui.AncestryChanged:Connect(function(_, parent)
        if parent ~= nil then return end
        if descendantConnection then descendantConnection:Disconnect() end
        if ancestryConnection then ancestryConnection:Disconnect() end
    end)

    API.PremiumGlassBorderTune = {
        Version = "0.2.3-test",
        Default = "DarkSmokedRuby",
    }
    return true
end
