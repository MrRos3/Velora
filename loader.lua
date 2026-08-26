-- Velora Upgrade Lab test loader.
-- Test branch only. Main is intentionally untouched.
local LAB_REF = "3a232ef592b9594703eef8440272cf58b8e04dec"

local SMOOTH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/smooth.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/smooth.lua",
}

local UPGRADE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/upgrades.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/upgrades.lua",
}

local FIX_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/upgrade_fixes.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/upgrade_fixes.lua",
}

local CLEANUP_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/upgrade_cleanup.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/upgrade_cleanup.lua",
}

local GLOW_TRIM_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/upgrade_glow_trim.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/upgrade_glow_trim.lua",
}

local COMPACT_FIX_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. LAB_REF .. "/upgrade_compact_fix.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. LAB_REF .. "/upgrade_compact_fix.lua",
}

local function fail(reason)
    local message = "Velora Lab could not start: " .. tostring(reason)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Velora Lab could not start",
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

local smoothSource = download(SMOOTH_URLS, "smooth build")
local smoothChunk, smoothCompileError = loadstring(smoothSource)
if type(smoothChunk) ~= "function" then
    fail("smooth build compile failed - " .. tostring(smoothCompileError))
end

local smoothStarted, api = pcall(smoothChunk)
if not smoothStarted or type(api) ~= "table" then
    fail("smooth build runtime failed - " .. tostring(api))
end

local upgradeSource = download(UPGRADE_URLS, "upgrade pack")

-- Shortcuts are removed in this test revision, not merely hidden.
upgradeSource = replaceOncePlain(upgradeSource, "local shortcutsEnabled = true", "local shortcutsEnabled = false")
upgradeSource = replaceOncePlain(upgradeSource,
[[        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrl and input.KeyCode == Enum.KeyCode.J then
            if labButton.Visible then drawer.Visible = not drawer.Visible end
            return
        end
]],
"")

local upgradeChunk, upgradeCompileError = loadstring(upgradeSource)
if type(upgradeChunk) ~= "function" then
    fail("upgrade pack compile failed - " .. tostring(upgradeCompileError))
end

local upgradeLoaded, installer = pcall(upgradeChunk)
if not upgradeLoaded or type(installer) ~= "function" then
    fail("upgrade pack startup failed - " .. tostring(installer))
end

local installed, ok, installError = pcall(installer, api)
if not installed then
    fail("upgrade pack runtime failed - " .. tostring(ok))
end
if ok ~= true then
    fail("upgrade pack install failed - " .. tostring(installError or ok))
end

local fixSource = download(FIX_URLS, "upgrade polish")
-- Use the clean Creator Store click for the action-specific sound layer too.
fixSource = string.gsub(fixSource, "17582213219", "113397864512278")

local fixChunk, fixCompileError = loadstring(fixSource)
if type(fixChunk) ~= "function" then
    fail("upgrade polish compile failed - " .. tostring(fixCompileError))
end

local fixLoaded, fixInstaller = pcall(fixChunk)
if not fixLoaded or type(fixInstaller) ~= "function" then
    fail("upgrade polish startup failed - " .. tostring(fixInstaller))
end

local fixed, fixOk, fixError = pcall(fixInstaller, api)
if not fixed then
    fail("upgrade polish runtime failed - " .. tostring(fixOk))
end
if fixOk ~= true then
    fail("upgrade polish install failed - " .. tostring(fixError or fixOk))
end

local cleanupSource = download(CLEANUP_URLS, "upgrade cleanup")
local cleanupChunk, cleanupCompileError = loadstring(cleanupSource)
if type(cleanupChunk) ~= "function" then
    fail("upgrade cleanup compile failed - " .. tostring(cleanupCompileError))
end

local cleanupLoaded, cleanupInstaller = pcall(cleanupChunk)
if not cleanupLoaded or type(cleanupInstaller) ~= "function" then
    fail("upgrade cleanup startup failed - " .. tostring(cleanupInstaller))
end

local cleaned, cleanupOk, cleanupError = pcall(cleanupInstaller, api)
if not cleaned then
    fail("upgrade cleanup runtime failed - " .. tostring(cleanupOk))
end
if cleanupOk ~= true then
    fail("upgrade cleanup install failed - " .. tostring(cleanupError or cleanupOk))
end

local glowTrimSource = download(GLOW_TRIM_URLS, "glow trim")
local glowTrimChunk, glowTrimCompileError = loadstring(glowTrimSource)
if type(glowTrimChunk) ~= "function" then
    fail("glow trim compile failed - " .. tostring(glowTrimCompileError))
end

local glowTrimLoaded, glowTrimInstaller = pcall(glowTrimChunk)
if not glowTrimLoaded or type(glowTrimInstaller) ~= "function" then
    fail("glow trim startup failed - " .. tostring(glowTrimInstaller))
end

local trimmed, trimOk, trimError = pcall(glowTrimInstaller, api)
if not trimmed then
    fail("glow trim runtime failed - " .. tostring(trimOk))
end
if trimOk ~= true then
    fail("glow trim install failed - " .. tostring(trimError or trimOk))
end

local compactFixSource = download(COMPACT_FIX_URLS, "compact fix")
local compactFixChunk, compactFixCompileError = loadstring(compactFixSource)
if type(compactFixChunk) ~= "function" then
    fail("compact fix compile failed - " .. tostring(compactFixCompileError))
end

local compactFixLoaded, compactFixInstaller = pcall(compactFixChunk)
if not compactFixLoaded or type(compactFixInstaller) ~= "function" then
    fail("compact fix startup failed - " .. tostring(compactFixInstaller))
end

local compactFixed, compactOk, compactError = pcall(compactFixInstaller, api)
if not compactFixed then
    fail("compact fix runtime failed - " .. tostring(compactOk))
end
if compactOk ~= true then
    fail("compact fix install failed - " .. tostring(compactError or compactOk))
end

return api
