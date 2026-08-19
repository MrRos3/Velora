-- Velora 0.10.5 Nova Succession library boot.
local RELEASE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/d995fad1ec5c41255fdbfbf44e9e470b8363b6e3/release.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@d995fad1ec5c41255fdbfbf44e9e470b8363b6e3/release.lua",
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

local source
local downloadError
for _, url in ipairs(RELEASE_URLS) do
    local downloaded, result = pcall(function()
        return game:HttpGet(url)
    end)
    if downloaded and type(result) == "string" and result ~= "" then
        source = result
        break
    end
    downloadError = result
end
if not source then
    fail("download failed - " .. tostring(downloadError))
end

local chunk, compileError = loadstring(source)
if type(chunk) ~= "function" then
    fail("compile failed - " .. tostring(compileError))
end

local started, result = pcall(chunk)
if not started then
    fail("runtime error - " .. tostring(result))
end

return result

