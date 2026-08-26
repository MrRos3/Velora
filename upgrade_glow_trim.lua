-- Velora Upgrade Lab glow trim.
-- Test branch only. Keeps the breathing glow visible without a thick neon border.

return function(API)
    assert(type(API) == "table", "Velora glow trim expects the Velora API")

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")

    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    local playerCard
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == "NOW PLAYING" then
            playerCard = descendant.Parent
            break
        end
    end
    if not playerCard then return false, "Now Playing card not found" end

    local inner = playerCard:FindFirstChild("VeloraLabAmbientGlowInner")
    local outer = playerCard:FindFirstChild("VeloraLabAmbientGlowOuter")
    if not inner or not outer then return false, "Glow strokes not found" end

    local function snapshot()
        local ok, snap = pcall(function() return API:GetSnapshot() end)
        return ok and type(snap) == "table" and snap or {}
    end

    local noteKick = 0
    local noteConnection
    if API.NotePlayed then
        noteConnection = API.NotePlayed:Connect(function()
            noteKick = 1
        end)
    end

    -- RenderStepped runs after the playback Heartbeat styling and applies the final thin profile.
    local renderConnection
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        if not inner.Parent or not outer.Parent then
            if renderConnection then renderConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
            return
        end

        noteKick = math.max(0, noteKick - dt * 4.2)
        local snap = snapshot()
        local breath = (math.sin(os.clock() * 2.8) + 1) * 0.5

        if snap.Playing and not snap.Paused then
            inner.Thickness = 1.35 + breath * 0.25 + noteKick * 0.25
            outer.Thickness = 2.15 + breath * 0.35 + noteKick * 0.30
            inner.Transparency = math.clamp(0.44 - breath * 0.13 - noteKick * 0.12, 0.18, 0.48)
            outer.Transparency = math.clamp(0.80 - breath * 0.08 - noteKick * 0.08, 0.62, 0.82)
        elseif snap.Playing and snap.Paused then
            inner.Thickness = 1.25
            outer.Thickness = 2.0
            inner.Transparency = 0.66
            outer.Transparency = 0.86
        else
            inner.Thickness = 1.0
            outer.Thickness = 1.75
            inner.Transparency = 0.92
            outer.Transparency = 0.97
        end
    end)

    gui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if renderConnection then renderConnection:Disconnect() end
            if noteConnection then noteConnection:Disconnect() end
        end
    end)

    API.UpgradeLabGlowTrim = {Version = "0.4-test"}
    return true
end
