-- Velora Upgrade Lab polish fixes v3.
-- Test branch only: stronger continuous glow, Lucide Lab button, relocated info button,
-- and clearly differentiated action sound design.

return function(API)
    assert(type(API) == "table", "Velora Upgrade Lab fixes expect the Velora API")

    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local SoundService = game:GetService("SoundService")

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
    if not window then
        return false, "Velora window not found"
    end

    local ACCENT = Color3.fromRGB(211, 76, 90)
    local ACCENT_DARK = Color3.fromRGB(127, 31, 42)
    local EDGE = Color3.fromRGB(118, 58, 65)
    local SURFACE = Color3.fromRGB(18, 12, 14)
    local TEXT = Color3.fromRGB(255, 247, 249)
    local SUB = Color3.fromRGB(220, 198, 203)

    local SOFT_CLICK = "rbxassetid://17582213219"
    local LUCIDE_SPARKLES = "rbxassetid://8997388430"

    local ICONS = {
        minimize = "rbxassetid://7733997870",
        settings = "rbxassetid://7734053495",
        close = "rbxassetid://7743878857",
        music = "rbxassetid://7734020554",
        square = "rbxassetid://7743872181",
        play = "rbxassetid://7743871480",
        pause = "rbxassetid://7734021897",
        heart = "rbxassetid://7733956134",
        left = "rbxassetid://7733717651",
        right = "rbxassetid://7733717755",
        loop = "rbxassetid://7734051454",
    }

    local function snapshot()
        local ok, snap = pcall(function()
            return API:GetSnapshot()
        end)
        return ok and type(snap) == "table" and snap or {}
    end

    local function findButtonByImage(root, imageId)
        if not root then return nil end
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("ImageLabel") and descendant.Image == imageId then
                local node = descendant.Parent
                while node and node ~= root.Parent do
                    if node:IsA("TextButton") then return node end
                    if node == root then break end
                    node = node.Parent
                end
            end
        end
        return nil
    end

    local function findButtonByLabel(root, wanted)
        if not root then return nil end
        for _, descendant in ipairs(root:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Text == wanted then
                local node = descendant.Parent
                while node and node ~= root.Parent do
                    if node:IsA("TextButton") then return node end
                    if node == root then break end
                    node = node.Parent
                end
            end
        end
        return nil
    end

    local header
    local playerCard
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            if descendant.Text == "VELORA" and not header then
                header = descendant.Parent
            elseif descendant.Text == "NOW PLAYING" and not playerCard then
                playerCard = descendant.Parent
            end
        end
    end

    if not playerCard then
        return false, "Now Playing card not found"
    end

    -- ---------------------------------------------------------
    -- Header Lab button: same geometry/style family as the 3 header controls,
    -- with a real Lucide sparkles icon instead of the text glyph.
    -- ---------------------------------------------------------

    local labButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    local minimizeButton = header and findButtonByImage(header, ICONS.minimize)

    if labButton and labButton:IsA("TextButton") and header and header:IsA("GuiObject") then
        labButton.Parent = header
        labButton.Text = ""
        labButton.AutoButtonColor = false
        labButton.ZIndex = 40

        if minimizeButton then
            labButton.AnchorPoint = minimizeButton.AnchorPoint
            labButton.Size = minimizeButton.Size
            labButton.Position = UDim2.new(
                minimizeButton.Position.X.Scale,
                minimizeButton.Position.X.Offset - 46,
                minimizeButton.Position.Y.Scale,
                minimizeButton.Position.Y.Offset
            )
            labButton.BackgroundColor3 = minimizeButton.BackgroundColor3
            labButton.BackgroundTransparency = minimizeButton.BackgroundTransparency
        else
            labButton.AnchorPoint = Vector2.new(1, 0)
            labButton.Position = UDim2.new(1, -190, 0, 14)
            labButton.Size = UDim2.fromOffset(36, 36)
            labButton.BackgroundColor3 = Color3.fromRGB(27, 19, 21)
            labButton.BackgroundTransparency = 0
        end

        for _, child in ipairs(labButton:GetChildren()) do
            if child.Name == "VeloraLabLucide" then child:Destroy() end
        end

        local corner = labButton:FindFirstChildOfClass("UICorner")
        if not corner then
            corner = Instance.new("UICorner")
            corner.Parent = labButton
        end
        corner.CornerRadius = UDim.new(0, 12)

        local labStroke = labButton:FindFirstChildOfClass("UIStroke")
        local minimizeStroke = minimizeButton and minimizeButton:FindFirstChildOfClass("UIStroke")
        if not labStroke then
            labStroke = Instance.new("UIStroke")
            labStroke.Parent = labButton
        end
        labStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        labStroke.Color = minimizeStroke and minimizeStroke.Color or EDGE
        labStroke.Transparency = minimizeStroke and minimizeStroke.Transparency or 0.58
        labStroke.Thickness = minimizeStroke and minimizeStroke.Thickness or 1

        local icon = Instance.new("ImageLabel")
        icon.Name = "VeloraLabLucide"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(17, 17)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Image = LUCIDE_SPARKLES
        icon.ImageColor3 = SUB
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = labButton.ZIndex + 1
        icon.Parent = labButton

        labButton.MouseEnter:Connect(function()
            TweenService:Create(icon, TweenInfo.new(0.12), {ImageColor3 = TEXT}):Play()
            TweenService:Create(labStroke, TweenInfo.new(0.12), {Transparency = 0.28}):Play()
        end)
        labButton.MouseLeave:Connect(function()
            TweenService:Create(icon, TweenInfo.new(0.12), {ImageColor3 = SUB}):Play()
            local target = minimizeStroke and minimizeStroke.Transparency or 0.58
            TweenService:Create(labStroke, TweenInfo.new(0.12), {Transparency = target}):Play()
        end)
    end

    -- ---------------------------------------------------------
    -- Song info button: move it onto the artwork as a contextual overlay.
    -- ---------------------------------------------------------

    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    local scroller = drawer and drawer:FindFirstChildWhichIsA("ScrollingFrame", true)
    local infoSection
    if drawer then
        for _, descendant in ipairs(drawer:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Text == "SONG INFORMATION" then
                infoSection = descendant.Parent
                break
            end
        end
    end

    local oldInfo = gui:FindFirstChild("VeloraSongInfoButton", true)
    if oldInfo then oldInfo:Destroy() end

    local artFrame
    for _, descendant in ipairs(playerCard:GetDescendants()) do
        if descendant:IsA("ImageLabel") and descendant.Image == ICONS.music then
            local node = descendant.Parent
            while node and node ~= playerCard do
                if node:IsA("GuiObject") then
                    local sx, sy = node.Size.X.Offset, node.Size.Y.Offset
                    if sx >= 68 and sx <= 76 and sy >= 68 and sy <= 76 then
                        artFrame = node
                        break
                    end
                end
                node = node.Parent
            end
            if artFrame then break end
        end
    end

    local infoParent = artFrame or playerCard
    local infoButton = Instance.new("TextButton")
    infoButton.Name = "VeloraSongInfoButton"
    infoButton.AnchorPoint = Vector2.new(1, 0)
    infoButton.Size = UDim2.fromOffset(24, 24)
    infoButton.BackgroundColor3 = Color3.fromRGB(16, 11, 13)
    infoButton.BackgroundTransparency = 0.04
    infoButton.BorderSizePixel = 0
    infoButton.AutoButtonColor = false
    infoButton.Text = "i"
    infoButton.TextColor3 = SUB
    infoButton.TextSize = 12
    infoButton.Font = Enum.Font.BuilderSansExtraBold
    infoButton.ZIndex = 70
    infoButton.Parent = infoParent

    if artFrame then
        infoButton.Position = UDim2.new(1, -5, 0, 5)
    else
        infoButton.Position = UDim2.new(1, -17, 0, 43)
    end

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoButton

    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = ACCENT
    infoStroke.Transparency = 0.48
    infoStroke.Thickness = 1
    infoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    infoStroke.Parent = infoButton

    infoButton.MouseEnter:Connect(function()
        TweenService:Create(infoButton, TweenInfo.new(0.12), {
            BackgroundTransparency = 0,
            TextColor3 = TEXT,
        }):Play()
        TweenService:Create(infoStroke, TweenInfo.new(0.12), {Transparency = 0.16}):Play()
    end)
    infoButton.MouseLeave:Connect(function()
        TweenService:Create(infoButton, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.04,
            TextColor3 = SUB,
        }):Play()
        TweenService:Create(infoStroke, TweenInfo.new(0.12), {Transparency = 0.48}):Play()
    end)

    infoButton.Activated:Connect(function()
        if not drawer or not scroller or not infoSection then return end
        drawer.Visible = true
        task.defer(function()
            if not drawer.Parent or not infoSection.Parent then return end
            local targetY = infoSection.AbsolutePosition.Y - scroller.AbsolutePosition.Y + scroller.CanvasPosition.Y - 6
            scroller.CanvasPosition = Vector2.new(0, math.max(0, targetY))
        end)
    end)

    -- ---------------------------------------------------------
    -- Stronger continuous Now Playing glow.
    -- Two stacked strokes approximate a soft halo, with note hits kicking brighter.
    -- ---------------------------------------------------------

    for _, name in ipairs({"VeloraLabAmbientGlow", "VeloraLabAmbientGlowV2", "VeloraLabAmbientGlowInner", "VeloraLabAmbientGlowOuter"}) do
        local old = playerCard:FindFirstChild(name)
        if old then old:Destroy() end
    end

    local innerGlow = Instance.new("UIStroke")
    innerGlow.Name = "VeloraLabAmbientGlowInner"
    innerGlow.Color = ACCENT
    innerGlow.Transparency = 0.92
    innerGlow.Thickness = 1.2
    innerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerGlow.Parent = playerCard

    local outerGlow = Instance.new("UIStroke")
    outerGlow.Name = "VeloraLabAmbientGlowOuter"
    outerGlow.Color = Color3.fromRGB(235, 96, 112)
    outerGlow.Transparency = 0.96
    outerGlow.Thickness = 4.8
    outerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerGlow.Parent = playerCard

    local innerGradient = Instance.new("UIGradient")
    innerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 139)),
        ColorSequenceKeypoint.new(0.5, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT_DARK),
    })
    innerGradient.Rotation = 18
    innerGradient.Parent = innerGlow

    local outerGradient = innerGradient:Clone()
    outerGradient.Rotation = 198
    outerGradient.Parent = outerGlow

    local noteKick = 0
    local noteConnection
    if API.NotePlayed then
        noteConnection = API.NotePlayed:Connect(function()
            noteKick = 1
        end)
    end

    local glowConnection
    glowConnection = RunService.Heartbeat:Connect(function(dt)
        if not innerGlow.Parent or not outerGlow.Parent then
            if glowConnection then glowConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
            return
        end

        noteKick = math.max(0, noteKick - dt * 3.6)
        local snap = snapshot()
        local now = os.clock()

        if snap.Playing and not snap.Paused then
            local breath = (math.sin(now * 2.8) + 1) * 0.5
            innerGlow.Transparency = math.clamp(0.48 - breath * 0.16 - noteKick * 0.18, 0.12, 0.52)
            innerGlow.Thickness = 2.6 + breath * 1.0 + noteKick * 0.9
            outerGlow.Transparency = math.clamp(0.73 - breath * 0.11 - noteKick * 0.15, 0.42, 0.76)
            outerGlow.Thickness = 5.4 + breath * 1.7 + noteKick * 1.3
            innerGradient.Rotation = (now * 18) % 360
            outerGradient.Rotation = (innerGradient.Rotation + 180) % 360
        elseif snap.Playing and snap.Paused then
            innerGlow.Transparency = 0.66
            innerGlow.Thickness = 2.0
            outerGlow.Transparency = 0.84
            outerGlow.Thickness = 5.0
        else
            innerGlow.Transparency = 0.91
            innerGlow.Thickness = 1.2
            outerGlow.Transparency = 0.96
            outerGlow.Thickness = 4.2
        end
    end)

    -- ---------------------------------------------------------
    -- Distinct action sound design.
    -- The base tap in smooth.lua is intentionally very quiet in this test build.
    -- ---------------------------------------------------------

    local function playLayer(speed, volume, delaySeconds)
        task.delay(delaySeconds or 0, function()
            pcall(function()
                local sound = Instance.new("Sound")
                sound.Name = "VeloraActionTone"
                sound.SoundId = SOFT_CLICK
                sound.Volume = volume
                sound.PlaybackSpeed = speed
                sound.Parent = SoundService
                sound:Play()
                sound.Ended:Connect(function()
                    if sound.Parent then sound:Destroy() end
                end)
                task.delay(2, function()
                    if sound.Parent then sound:Destroy() end
                end)
            end)
        end)
    end

    local function playProfile(profile)
        if profile == "play" then
            playLayer(0.82, 0.060, 0)
            playLayer(1.08, 0.020, 0.018)
        elseif profile == "stop" then
            playLayer(0.70, 0.055, 0)
        elseif profile == "favorite" then
            playLayer(1.24, 0.045, 0)
            playLayer(1.48, 0.016, 0.016)
        elseif profile == "bpm" then
            playLayer(1.12, 0.036, 0)
        elseif profile == "loop" then
            playLayer(0.94, 0.046, 0)
            playLayer(1.18, 0.012, 0.014)
        elseif profile == "info" then
            playLayer(1.28, 0.036, 0)
        elseif profile == "lab" then
            playLayer(1.04, 0.048, 0)
            playLayer(1.34, 0.014, 0.016)
        elseif profile == "header" then
            playLayer(0.90, 0.038, 0)
        end
    end

    local function bindAction(buttonObject, profile)
        if not buttonObject or not buttonObject:IsA("TextButton") then return end
        local key = "VeloraActionSound_" .. profile
        if buttonObject:GetAttribute(key) then return end
        buttonObject:SetAttribute(key, true)
        buttonObject.Activated:Connect(function()
            playProfile(profile)
        end)
    end

    bindAction(findButtonByImage(playerCard, ICONS.play), "play")
    bindAction(findButtonByImage(playerCard, ICONS.square), "stop")
    bindAction(findButtonByImage(playerCard, ICONS.heart), "favorite")
    bindAction(findButtonByImage(playerCard, ICONS.left), "bpm")
    bindAction(findButtonByImage(playerCard, ICONS.right), "bpm")
    bindAction(findButtonByImage(playerCard, ICONS.loop), "loop")
    bindAction(infoButton, "info")
    bindAction(labButton, "lab")

    if header then
        bindAction(findButtonByImage(header, ICONS.minimize), "header")
        bindAction(findButtonByImage(header, ICONS.settings), "header")
        bindAction(findButtonByImage(header, ICONS.close), "header")
    end

    gui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if glowConnection then glowConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
        end
    end)

    API.UpgradeLabPolish = {
        Version = "0.3-test",
        InfoButton = infoButton,
        InnerGlow = innerGlow,
        OuterGlow = outerGlow,
        LabButton = labButton,
    }

    return true
end
