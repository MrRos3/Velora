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

    local labButton = gui:FindFirstChild("VeloraUpgradeLab", true)
    if not labButton or not labButton:IsA("GuiObject") then
        return false, "Velora Lab button not found"
    end

    local drawer = gui:FindFirstChild("UpgradeDrawer", true)
    local header
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == "VELORA" then
            header = descendant.Parent
            break
        end
    end
    if not header then return false, "Velora header not found" end

    local MINIMIZE_ICON_ID = "7733997870"
    local minimizeButton
    for _, descendant in ipairs(header:GetDescendants()) do
        if descendant:IsA("ImageLabel") and string.find(descendant.Image or "", MINIMIZE_ICON_ID, 1, true) then
            local node = descendant.Parent
            while node and node ~= header.Parent do
                if node:IsA("TextButton") then
                    minimizeButton = node
                    break
                end
                if node == header then break end
                node = node.Parent
            end
            if minimizeButton then break end
        end
    end

    if not minimizeButton then
        return false, "Velora minimize button not found"
    end

    -- The workstation always launches expanded. Track the actual minimize/restore
    -- button instead of guessing from AbsoluteSize, which is unreliable under UIScale.
    local compact = false
    labButton.Visible = true

    local minimizeConnection = minimizeButton.Activated:Connect(function()
        compact = not compact
        if compact then
            labButton.Visible = false
            if drawer then drawer.Visible = false end
        else
            -- Let the shell expand first, then return the Lab control with the other header buttons.
            labButton.Visible = false
            task.delay(0.12, function()
                if not compact and labButton.Parent and gui.Parent then
                    labButton.Visible = true
                end
            end)
        end
    end)

    local ancestryConnection
    ancestryConnection = gui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if minimizeConnection then minimizeConnection:Disconnect() end
            if ancestryConnection then ancestryConnection:Disconnect() end
        end
    end)

    API.UpgradeLabCompactFix = {Version = "0.6-test"}
    return true
end
