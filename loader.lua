-- Velora 0.10.18 Nova glassmorphism loader.
local RELEASE_URLS = {
    "https://raw.githubusercontent.com/MrRos3/Velora/dd416c135451aa10c3b3e3b2fe74da029ba48d20/release.lua",
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@dd416c135451aa10c3b3e3b2fe74da029ba48d20/release.lua",
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

