-- Velora Upgrade Lab polish fixes.
-- Test branch only: persistent playing glow, real info button, cleaner Lab placement.

return function(API)
    assert(type(API) == "table", "Velora Upgrade Lab fixes expect the Velora API")

    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")

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

    local accent = Color3.fromRGB(211, 76, 90)
    local surface = Color3.fromRGB(18, 12, 14)
    local sub = Color3.fromRGB(220, 198, 203)

    local function snapshot()
        local ok, snap = pcall(function()
            return API:GetSnapshot()
        end)
        return ok and type(snap) == "table" and snap or {}
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

    -- Move the floating Lab trigger into the header so it no longer hangs at the edge.
    local labButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    if labButton and labButton:IsA("TextButton") and header and header:IsA("GuiObject") then
        labButton.Parent = header
        labButton.AnchorPoint = Vector2.new(1, 0)
        labButton.Position = UDim2.new(1, -154, 0, 14)
        labButton.Size = UDim2.fromOffset(36, 36)
        labButton.ZIndex = 40
        local corner = labButton:FindFirstChildOfClass("UICorner")
        if corner then corner.CornerRadius = UDim.new(0, 12) end
    end

    -- Replace the one-shot note pulse stroke with a continuous breathing playback glow.
    local oldGlow = playerCard:FindFirstChild("VeloraLabAmbientGlow")
    if oldGlow then
        oldGlow:Destroy()
    end

    local glow = Instance.new("UIStroke")
    glow.Name = "VeloraLabAmbientGlowV2"
    glow.Color = accent
    glow.Transparency = 0.92
    glow.Thickness = 1.2
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = playerCard

    local glowGradient = Instance.new("UIGradient")
    glowGradient.Name = "VeloraLabAmbientGradient"
    glowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 116, 127)),
        ColorSequenceKeypoint.new(0.5, accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 31, 42)),
    })
    glowGradient.Rotation = 18
    glowGradient.Parent = glow

    local noteKick = 0
    local noteConnection
    if API.NotePlayed then
        noteConnection = API.NotePlayed:Connect(function()
            noteKick = 1
        end)
    end

    local glowConnection
    glowConnection = RunService.Heartbeat:Connect(function(dt)
        if not glow.Parent then
            if glowConnection then glowConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
            return
        end

        noteKick = math.max(0, noteKick - dt * 4.2)
        local snap = snapshot()

        if snap.Playing and not snap.Paused then
            local breath = (math.sin(os.clock() * 3.15) + 1) * 0.5
            glow.Transparency = math.clamp(0.66 - breath * 0.18 - noteKick * 0.16, 0.28, 0.70)
            glow.Thickness = 1.7 + breath * 0.65 + noteKick * 0.55
            glowGradient.Rotation = (os.clock() * 14) % 360
        elseif snap.Playing and snap.Paused then
            glow.Transparency = 0.76
            glow.Thickness = 1.45
        else
            glow.Transparency = 0.92
            glow.Thickness = 1.15
        end
    end)

    -- Locate the existing Lab drawer and its Song Information section.
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

    -- Real info icon beside the Now Playing status badge.
    local oldInfo = playerCard:FindFirstChild("VeloraSongInfoButton")
    if oldInfo then oldInfo:Destroy() end

    local infoButton = Instance.new("TextButton")
    infoButton.Name = "VeloraSongInfoButton"
    infoButton.AnchorPoint = Vector2.new(1, 0)
    infoButton.Position = UDim2.new(1, -95, 0, 9)
    infoButton.Size = UDim2.fromOffset(22, 22)
    infoButton.BackgroundColor3 = surface
    infoButton.BackgroundTransparency = 0.08
    infoButton.BorderSizePixel = 0
    infoButton.AutoButtonColor = false
    infoButton.Text = "i"
    infoButton.TextColor3 = sub
    infoButton.TextSize = 12
    infoButton.Font = Enum.Font.BuilderSansExtraBold
    infoButton.ZIndex = 45
    infoButton.Parent = playerCard

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(1, 0)
    infoCorner.Parent = infoButton

    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = accent
    infoStroke.Transparency = 0.54
    infoStroke.Thickness = 1
    infoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    infoStroke.Parent = infoButton

    infoButton.MouseEnter:Connect(function()
        TweenService:Create(infoButton, TweenInfo.new(0.12), {
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 247, 249),
        }):Play()
        TweenService:Create(infoStroke, TweenInfo.new(0.12), {Transparency = 0.22}):Play()
    end)

    infoButton.MouseLeave:Connect(function()
        TweenService:Create(infoButton, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.08,
            TextColor3 = sub,
        }):Play()
        TweenService:Create(infoStroke, TweenInfo.new(0.12), {Transparency = 0.54}):Play()
    end)

    infoButton.Activated:Connect(function()
        if not drawer or not scroller or not infoSection then
            return
        end
        drawer.Visible = true
        task.defer(function()
            if not drawer.Parent or not infoSection.Parent then return end
            local targetY = infoSection.AbsolutePosition.Y - scroller.AbsolutePosition.Y + scroller.CanvasPosition.Y - 6
            scroller.CanvasPosition = Vector2.new(0, math.max(0, targetY))
        end)
    end)

    -- Keep the info button hidden only when its parent disappears.
    gui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if glowConnection then glowConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
        end
    end)

    API.UpgradeLabPolish = {
        Version = "0.2-test",
        InfoButton = infoButton,
        Glow = glow,
    }

    return true
end
