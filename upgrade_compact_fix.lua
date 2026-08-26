-- Velora Upgrade Lab compact-mode visibility fix.
-- Test branch only. The Lab control belongs to the full workstation, not the mini player.

return function(API)
    assert(type(API) == "table", "Velora compact fix expects the Velora API")

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local gui = API.UI and API.UI.Gui
    if not gui and playerGui then
        gui = playerGui:FindFirstChild("Velora")
    end
    if not gui then return false, "Velora GUI not found" end

    local window = gui:FindFirstChild("Aurora", true)
    local labButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    if not window then return false, "Velora window not found" end
    if not labButton or not labButton:IsA("GuiObject") then return false, "Velora Lab button not found" end

    local function sync()
        if not window.Parent or not labButton.Parent then return end
        -- Full Velora is far wider than the 266px compact player. Using 420px leaves
        -- the Lab button hidden throughout the compact end-state while restoring it
        -- automatically as soon as the full workstation returns.
        labButton.Visible = window.AbsoluteSize.X >= 420
    end

    sync()
    local sizeConnection = window:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
    local ancestryConnection
    ancestryConnection = gui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if sizeConnection then sizeConnection:Disconnect() end
            if ancestryConnection then ancestryConnection:Disconnect() end
        end
    end)

    API.UpgradeLabCompactFix = {Version = "0.5-test"}
    return true
end
