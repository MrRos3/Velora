-- Velora main loader.
-- Permanent public entrypoint for the upgraded smooth Velora workstation.
local VELORA_REF = "1ee440357b0448a01badba9b37df24e227c03d2c"

local SMOOTH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. VELORA_REF .. "/smooth.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. VELORA_REF .. "/smooth.lua",
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

-- Visual test layer. Keep this branch reference out of main until the user
-- has approved the smoked-glass redesign in Roblox.
local GLASS_TEST_REF = "glassmorphism-redesign-test"
local GLASS_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. GLASS_TEST_REF .. "/glassmorphism.lua?v=premium-smoked-glass-3",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. GLASS_TEST_REF .. "/glassmorphism.lua?v=premium-smoked-glass-3",
}

local function fail(reason)
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

local function download(urls, label)
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
    fail(label .. " download failed - " .. tostring(lastError))
end

local function replaceOncePlain(source, oldText, newText)
    local first, last = string.find(source, oldText, 1, true)
    if not first then return source end
    return source:sub(1, first - 1) .. newText .. source:sub(last + 1)
end

local function installModule(urls, label, api, transform)
    local source = download(urls, label)
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

local smoothSource = download(SMOOTH_URLS, "smooth build")
local smoothChunk, smoothCompileError = loadstring(smoothSource)
if type(smoothChunk) ~= "function" then
    fail("smooth build compile failed - " .. tostring(smoothCompileError))
end

local smoothStarted, api = pcall(smoothChunk)
if not smoothStarted or type(api) ~= "table" then
    fail("smooth build runtime failed - " .. tostring(api))
end

installModule(UPGRADE_URLS, "upgrade pack", api, function(source)
    -- Keyboard shortcuts stay removed from the public build.
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

installModule(FIX_URLS, "upgrade polish", api, function(source)
    -- Keep the clean UI click for the action-specific sound layer too.
    return string.gsub(source, "17582213219", "113397864512278")
end)

installModule(CLEANUP_URLS, "upgrade cleanup", api)

installModule(GLOW_TRIM_URLS, "glow trim", api, function(source)
    -- Strong-but-classy Now Playing bloom. Keep the rim crisp while allowing
    -- the softer outer stroke to read as a real glow instead of a faint border.
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

installModule(COMPACT_FIX_URLS, "compact fix", api)
installModule(WAVE2_URLS, "wave 2", api, function(source)
    -- Capture Play varargs before the optional countdown coroutine.
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

-- Load last so the premium glass treatment sits above every existing visual
-- upgrade without replacing the layout or playback implementation.
installModule(GLASS_URLS, "premium glass visual layer", api)

return api
