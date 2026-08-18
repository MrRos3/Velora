-- Velora v0.1
-- Minimal UI shell. v0.2 can replace this with the full glass interface.

local Players = game:GetService("Players")

local UI = {}

function UI.create(controller)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "Velora"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "Window"
    frame.Size = UDim2.fromOffset(360, 220)
    frame.Position = UDim2.new(0.5, -180, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -32, 0, 42)
    title.Position = UDim2.fromOffset(16, 12)
    title.BackgroundTransparency = 1
    title.Text = "Velora  •  v0.1"
    title.TextColor3 = Color3.fromRGB(240, 240, 245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -32, 0, 24)
    status.Position = UDim2.fromOffset(16, 58)
    status.BackgroundTransparency = 1
    status.Text = "No song loaded"
    status.TextColor3 = Color3.fromRGB(170, 170, 180)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local function makeButton(text, x, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(96, 38)
        button.Position = UDim2.fromOffset(x, 110)
        button.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
        button.TextColor3 = Color3.fromRGB(240, 240, 245)
        button.Text = text
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 14
        button.AutoButtonColor = true
        button.Parent = frame

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = button

        button.MouseButton1Click:Connect(callback)
        return button
    end

    makeButton("Play", 16, function()
        controller:Play()
    end)

    makeButton("Pause", 132, function()
        controller:Pause()
    end)

    makeButton("Stop", 248, function()
        controller:Stop()
    end)

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -32, 0, 42)
    hint.Position = UDim2.fromOffset(16, 164)
    hint.BackgroundTransparency = 1
    hint.Text = "v0.1 foundation • song library + parser + player"
    hint.TextColor3 = Color3.fromRGB(120, 120, 135)
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 12
    hint.TextWrapped = true
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Parent = frame

    return {
        Gui = gui,
        Status = status,
    }
end

return UI
