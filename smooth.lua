-- Velora smooth public launcher.
-- Unique path to avoid stale executor/CDN caches from loader.lua.
local BUILD_REF = "204289be27d87e3c9e9e5acfddeab0518ded4e33"

local RELEASE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. BUILD_REF .. "/release.lua?v=smooth2",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. BUILD_REF .. "/release.lua?v=smooth2",
}

local PATCH_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/" .. BUILD_REF .. "/patches.lua?v=smooth2",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@" .. BUILD_REF .. "/patches.lua?v=smooth2",
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

local source = download(RELEASE_URLS, "release")
local patchSource = download(PATCH_URLS, "patch")

local patchChunk, patchCompileError = loadstring(patchSource)
if type(patchChunk) ~= "function" then
    fail("patch compile failed - " .. tostring(patchCompileError))
end

local patchLoaded, patcher = pcall(patchChunk)
if not patchLoaded or type(patcher) ~= "function" then
    fail("patch startup failed - " .. tostring(patcher))
end

local patched, patchedSource = pcall(patcher, source)
if not patched or type(patchedSource) ~= "string" then
    fail("patch apply failed - " .. tostring(patchedSource))
end

local chunk, compileError = loadstring(patchedSource)
if type(chunk) ~= "function" then
    fail("compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("runtime error - " .. tostring(result))
end

return result
