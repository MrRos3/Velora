-- Velora Upgrade Lab test loader.
-- Test branch only. Main is intentionally untouched.
local LAB_REF = "b1bcb1376742aa042d1dee30ed2f5f169ad31ff7"

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

return api
