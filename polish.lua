-- Velora polish layer.
-- Final visual pass and boot reveal gate.
local SNAPSHOT = "41ff131a44c22e6225ffd8114dfabe416f59bab1"
local URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. SNAPSHOT .. "/glass_border_tune.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. SNAPSHOT .. "/glass_border_tune.lua",
}

local lastError
for _, url in ipairs(URLS) do
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(source) == "string" and source ~= "" then
        local chunk, compileError = loadstring(source)
        if type(chunk) == "function" then
            local loaded, installer = pcall(chunk)
            if loaded and type(installer) == "function" then
                return function(API)
                    local ran, result, installError = pcall(installer, API)
                    if not ran then
                        return false, result
                    end
                    if result ~= true then
                        return false, installError or result
                    end

                    -- The runtime creates Velora disabled so none of the base,
                    -- upgrade, visual, or border passes can flash on screen.
                    -- Polish is deliberately the last loader stage, so reveal here.
                    local gui = type(API) == "table" and API.UI and API.UI.Gui
                    if not gui then
                        return false, "Velora GUI missing at final reveal"
                    end

                    local RunService = game:GetService("RunService")
                    RunService.Heartbeat:Wait()
                    RunService.Heartbeat:Wait()

                    gui.Enabled = true
                    return true
                end
            end
            lastError = loaded and "polish module did not return an installer" or installer
        else
            lastError = compileError
        end
    else
        lastError = source
    end
end

error("Velora polish could not load: " .. tostring(lastError), 0)
