-- Velora Upgrade Lab cleanup pass.
-- Test branch only. Removes experimental UI the user rejected and restyles the Lab trigger.

return function(API)
    assert(type(API) == "table", "Velora cleanup expects the Velora API")

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")

    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    local window = gui:FindFirstChild("Aurora", true)
    if not window then return false, "Velora window not found" end

    local header
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == "VELORA" then
            header = descendant.Parent
            break
        end
    end

    -- Remove the contextual info button completely.
    local info = gui:FindFirstChild("VeloraSongInfoButton", true)
    if info then info:Destroy() end

    -- Remove the compact song/progress strip that was added under VELORA.
    if header then
        for _, child in ipairs(header:GetChildren()) do
            if child:IsA("GuiObject") then
                local y = child.Position.Y.Offset
                local x = child.Position.X.Offset
                if x == 62 and (y == 43 or y == 57) and child.ZIndex >= 220 then
                    child:Destroy()
                end
            end
        end
    end

    -- Disable keyboard shortcuts in the module state as well as removing their controls.
    if API.UpgradeLab and type(API.UpgradeLab.SetShortcuts) == "function" then
        pcall(API.UpgradeLab.SetShortcuts, false)
    end

    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    if drawer then
        for _, descendant in ipairs(drawer:GetDescendants()) do
            if descendant:IsA("TextButton") and (descendant.Text == "KEYS ON" or descendant.Text == "KEYS OFF") then
                descendant:Destroy()
            elseif descendant:IsA("TextLabel") then
                if descendant.Text == "PRACTICE • MEMORY • SHORTCUTS" then
                    descendant.Text = "PRACTICE • MEMORY"
                elseif string.find(descendant.Text, "Space play/pause", 1, true) then
                    descendant:Destroy()
                end
            end
        end

        for _, descendant in ipairs(drawer:GetDescendants()) do
            if descendant:IsA("TextButton") and (descendant.Text == "MEMORY ON" or descendant.Text == "MEMORY OFF") then
                descendant.Position = UDim2.fromOffset(118, 28)
                descendant.Size = UDim2.fromOffset(100, 29)
            end
        end
    end

    -- Rebuild the Lab trigger instead of recoloring the old button. The original Lab
    -- button had hover connections from the prototype button helper that kept restoring
    -- its reddish background, so replacing it is the only reliable way to match the
    -- three dark header controls exactly.
    local oldLabButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    if oldLabButton and oldLabButton:IsA("TextButton") and header then
        oldLabButton:Destroy()

        local dark = Color3.fromRGB(8, 6, 7)
        local darkHover = Color3.fromRGB(14, 10, 11)
        local edge = Color3.fromRGB(118, 58, 65)
        local iconNormal = Color3.fromRGB(218, 202, 205)
        local iconHover = Color3.fromRGB(255, 248, 249)

        local labButton = Instance.new("TextButton")
        labButton.Name = "VeloraUpgradeLab"
        labButton.AnchorPoint = Vector2.new(0, 0)
        labButton.Position = UDim2.new(1, -190, 0, 14)
        labButton.Size = UDim2.fromOffset(36, 36)
        labButton.BackgroundColor3 = dark
        labButton.BackgroundTransparency = 0
        labButton.BorderSizePixel = 0
        labButton.AutoButtonColor = false
        labButton.Text = ""
        labButton.ZIndex = 40
        labButton.Parent = header

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = labButton

        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = edge
        stroke.Transparency = 0.58
        stroke.Thickness = 1
        stroke.Parent = labButton

        local icon = Instance.new("ImageLabel")
        icon.Name = "VeloraLabLucide"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(16, 16)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Image = "rbxassetid://8997388430"
        icon.ImageColor3 = iconNormal
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 41
        icon.Parent = labButton

        labButton.MouseEnter:Connect(function()
            TweenService:Create(labButton, TweenInfo.new(0.12), {BackgroundColor3 = darkHover}):Play()
            TweenService:Create(icon, TweenInfo.new(0.12), {ImageColor3 = iconHover}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.34}):Play()
        end)
        labButton.MouseLeave:Connect(function()
            TweenService:Create(labButton, TweenInfo.new(0.12), {BackgroundColor3 = dark}):Play()
            TweenService:Create(icon, TweenInfo.new(0.12), {ImageColor3 = iconNormal}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.58}):Play()
        end)
        labButton.Activated:Connect(function()
            if drawer then drawer.Visible = not drawer.Visible end
        end)
    end

    API.UpgradeLabCleanup = {Version = "0.4-test"}
    return true
end
