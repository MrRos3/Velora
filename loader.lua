-- Velora main loader.
-- Fast atomic entrypoint: downloads independent layers concurrently, builds the
-- complete UI off-screen, then reveals it exactly once.

local function setAtomicBoot(enabled)
    local value = enabled and true or nil
    rawset(_G, "VeloraAtomicBoot", value)
    if type(getgenv) == "function" then
        pcall(function()
            local env = getgenv()
            if type(env) == "table" then
                env.VeloraAtomicBoot = value
            end
        end)
    end
end

setAtomicBoot(true)
pcall(function()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    local existing = playerGui and playerGui:FindFirstChild("Velora")
    if existing then
        if existing:IsA("ScreenGui") then existing.Enabled = false end
        existing:Destroy()
    end
end)

local VELORA_REF = "1ee440357b0448a01badba9b37df24e227c03d2c"
local VISUAL_REF = "41ff131a44c22e6225ffd8114dfabe416f59bab1"

local RUNTIME_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/main/runtime.lua?v=velora-fast-20260827-1",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@main/runtime.lua?v=velora-fast-20260827-1",
}

local UPGRADE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrades.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrades.lua",
}

local FIX_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrade_fixes.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrade_fixes.lua",
}

local CLEANUP_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrade_cleanup.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrade_cleanup.lua",
}

local GLOW_TRIM_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrade_glow_trim.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrade_glow_trim.lua",
}

local COMPACT_FIX_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrade_compact_fix.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrade_compact_fix.lua",
}

local WAVE2_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/upgrade_wave2.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/upgrade_wave2.lua",
}

-- Skip the public wrapper files here. They are useful clean repository names,
-- but the loader can go directly to their pinned proven implementations.
local VISUAL_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VISUAL_REF .. "/glassmorphism.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VISUAL_REF .. "/glassmorphism.lua",
}

local POLISH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VISUAL_REF .. "/glass_border_tune.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VISUAL_REF .. "/glass_border_tune.lua",
}

local function fail(reason)
    setAtomicBoot(false)
    local message = "Velora could not start: " .. tostring(reason)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Velora could not start",
            Text = message,
            Duration = 12,
        })
    end)
    error(message, 0)
end

if type(loadstring) ~= "function" then
    fail("this executor does not provide loadstring")
end

local function tryDownload(urls)
    local lastError
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
        lastError = result
    end
    return nil, lastError
end

-- Start every independent network request immediately. Runtime can begin as soon
-- as its own source arrives; by the time it finishes building the core UI, the
-- upgrade layers are normally already sitting in memory ready to install.
local prefetchSpecs = {
    runtime = RUNTIME_URLS,
    upgrade = UPGRADE_URLS,
    fix = FIX_URLS,
    cleanup = CLEANUP_URLS,
    glow = GLOW_TRIM_URLS,
    compact = COMPACT_FIX_URLS,
    wave2 = WAVE2_URLS,
    visuals = VISUAL_URLS,
    polish = POLISH_URLS,
}

local prefetched = {}
local finished = {}
for key, urls in pairs(prefetchSpecs) do
    task.spawn(function()
        local source, err = tryDownload(urls)
        prefetched[key] = {Source = source, Error = err}
        finished[key] = true
    end)
end

local function takeSource(key, label)
    while not finished[key] do
        task.wait()
    end
    local item = prefetched[key]
    if not item or not item.Source then
        fail(label .. " download failed - " .. tostring(item and item.Error))
    end
    return item.Source
end

local function replaceOncePlain(source, oldText, newText)
    local first, last = string.find(source, oldText, 1, true)
    if not first then return source end
    return source:sub(1, first - 1) .. newText .. source:sub(last + 1)
end

local function installSource(source, label, api, transform)
    if transform then source = transform(source) end
    local chunk, compileError = loadstring(source)
    if type(chunk) ~= "function" then
        fail(label .. " compile failed - " .. tostring(compileError))
    end
    local loaded, installer = pcall(chunk)
    if not loaded or type(installer) ~= "function" then
        fail(label .. " startup failed - " .. tostring(installer))
    end
    local ran, ok, installError = pcall(installer, api)
    if not ran then
        fail(label .. " runtime failed - " .. tostring(ok))
    end
    if ok ~= true then
        fail(label .. " install failed - " .. tostring(installError or ok))
    end
end

local runtimeSource = takeSource("runtime", "runtime")
local runtimeChunk, runtimeCompileError = loadstring(runtimeSource)
if type(runtimeChunk) ~= "function" then
    fail("runtime compile failed - " .. tostring(runtimeCompileError))
end

local runtimeStarted, api = pcall(runtimeChunk)
if not runtimeStarted or type(api) ~= "table" then
    fail("runtime failed - " .. tostring(api))
end

installSource(takeSource("upgrade", "upgrade pack"), "upgrade pack", api, function(source)
    source = replaceOncePlain(source, "local shortcutsEnabled = true", "local shortcutsEnabled = false")
    source = replaceOncePlain(source,
[[        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrl and input.KeyCode == Enum.KeyCode.J then
            if labButton.Visible then drawer.Visible = not drawer.Visible end
            return
        end
]],
"")
    return source
end)

installSource(takeSource("fix", "upgrade polish"), "upgrade polish", api, function(source)
    return string.gsub(source, "17582213219", "113397864512278")
end)

installSource(takeSource("cleanup", "upgrade cleanup"), "upgrade cleanup", api, function(source)
    -- Hide the Lab trigger whenever compact width would make it collide with VELORA.
    source = replaceOncePlain(source,
        "        labButton.Parent = header\n",
[[        labButton.Parent = header

        local function syncCompactLabVisibility()
            if not labButton.Parent or not window.Parent then return end
            local compact = window.Size.X.Offset < 400
            labButton.Visible = not compact
            if compact and drawer then
                drawer.Visible = false
            end
        end

        syncCompactLabVisibility()
        window:GetPropertyChangedSignal("Size"):Connect(syncCompactLabVisibility)
]])
    return source
end)

installSource(takeSource("glow", "glow trim"), "glow trim", api, function(source)
    source = replaceOncePlain(source,
        "            inner.Thickness = 1.35 + breath * 0.25 + noteKick * 0.25",
        "            inner.Thickness = 1.70 + breath * 0.25 + noteKick * 0.20"
    )
    source = replaceOncePlain(source,
        "            outer.Thickness = 2.15 + breath * 0.35 + noteKick * 0.30",
        "            outer.Thickness = 3.20 + breath * 0.60 + noteKick * 0.50"
    )
    source = replaceOncePlain(source,
        "            inner.Transparency = math.clamp(0.44 - breath * 0.13 - noteKick * 0.12, 0.18, 0.48)",
        "            inner.Transparency = math.clamp(0.30 - breath * 0.08 - noteKick * 0.08, 0.12, 0.32)"
    )
    source = replaceOncePlain(source,
        "            outer.Transparency = math.clamp(0.80 - breath * 0.08 - noteKick * 0.08, 0.62, 0.82)",
        "            outer.Transparency = math.clamp(0.62 - breath * 0.10 - noteKick * 0.10, 0.42, 0.64)"
    )
    source = replaceOncePlain(source,
        "            inner.Thickness = 1.25\n            outer.Thickness = 2.0\n            inner.Transparency = 0.66\n            outer.Transparency = 0.86",
        "            inner.Thickness = 1.45\n            outer.Thickness = 2.70\n            inner.Transparency = 0.58\n            outer.Transparency = 0.80"
    )
    source = replaceOncePlain(source,
        "            inner.Thickness = 1.0\n            outer.Thickness = 1.75\n            inner.Transparency = 0.92\n            outer.Transparency = 0.97",
        "            inner.Thickness = 1.0\n            outer.Thickness = 1.70\n            inner.Transparency = 0.94\n            outer.Transparency = 0.98"
    )
    return source
end)

installSource(takeSource("compact", "compact fix"), "compact fix", api)
installSource(takeSource("wave2", "wave 2"), "wave 2", api, function(source)
    source = replaceOncePlain(source,
        "            local startId = pickedId(snap)\n            countdownActive = true",
        "            local packedArgs = table.pack(...)\n            local startId = pickedId(snap)\n            countdownActive = true"
    )
    source = replaceOncePlain(source,
        "                rawPlay(self, ...)\n            end)",
        "                rawPlay(self, table.unpack(packedArgs, 1, packedArgs.n))\n            end)"
    )
    return source
end)

-- These sources were already prefetched while runtime was constructing the core UI.
installSource(takeSource("visuals", "visual layer"), "visual layer", api)
installSource(takeSource("polish", "polish layer"), "polish layer", api)

local gui = api.UI and api.UI.Gui
if not gui then
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    gui = playerGui and playerGui:FindFirstChild("Velora")
end
if not gui or not gui:IsA("ScreenGui") then
    fail("final Velora ScreenGui was not created")
end

-- One render boundary is enough now that the visual work is already complete.
pcall(function()
    game:GetService("RunService").RenderStepped:Wait()
end)

if gui.Parent then
    gui.Enabled = true
end
setAtomicBoot(false)

return api
